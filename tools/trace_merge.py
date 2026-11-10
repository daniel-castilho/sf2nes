#!/usr/bin/env python3
"""Mescla varios diretorios de trace (saida do cdl.lua) num conjunto compacto em trace/.
uso: trace_merge.py <rom.nes> <dir_saida> <dir_trace1> [<dir_trace2> ...]"""
import sys, os, collections
sys.path.insert(0, os.path.dirname(__file__))
from tracelib import *

rom, outdir, dirs = sys.argv[1], sys.argv[2], sys.argv[3:]
prg = open(rom, 'rb').read()[16:16 + 0x80000]
t = RawTrace()
used = []
for d in dirs:
    if os.path.exists(os.path.join(d, 'cdl.bin')):
        t.load(d); used.append(d)
os.makedirs(outdir, exist_ok=True)

# 1) inicios de instrucao executados
with open(os.path.join(outdir, 'opstarts.txt'), 'w') as f:
    f.write('# instrucoes executadas (banco:endereco), mescla de %d execucoes\n' % len(used))
    n = 0
    for o, b in enumerate(t.opstart):
        if b: f.write(fmt_off(o) + '\n'); n += 1
print('opstarts:', n)

# 2) saltos indiretos / RTS-trick / chamadas entre janelas (descarta retornos normais e interrupcoes)
VEC = {0xFC7C, 0xFE1E, 0xFF9F}
keep = collections.Counter()
for (ty, a, b), cnt in t.edges.items():
    if ty == 'RTI': continue
    if b < RAMBASE:
        bb, ba = off2ba(b)
        if ba in VEC: continue                                   # interrupcao logo apos a instrucao
        if ty == 'RTS':
            if (b & 0x1FFF) >= 3 and prg[b - 3] == 0x20: continue                       # retorno normal de JSR
            if (b & 0x1FFF) >= 3 and prg[b - 3:b] == bytes([0x4C, 0x9E, 0x04]): continue  # retorno de farcall
    else:
        if ty == 'RTS' and b - RAMBASE == 0x04A6: continue        # retorno da rotina distante p/ o trampolim
    keep[(ty, a, b)] += cnt
with open(os.path.join(outdir, 'edges.txt'), 'w') as f:
    f.write('# tipo origem destino contagem   (RTS = salto via RTS-trick; JMPI = JMP (ind); XJSR/XJMP = entre janelas)\n')
    for (ty, a, b), cnt in sorted(keep.items(), key=lambda x: (x[0][1], x[0][2])):
        f.write('%s %s %s %d\n' % (ty, fmt_off(a), fmt_off(b), cnt))
print('edges:', len(keep))

# 3) leituras de dados validadas, agrupadas por instrucao leitora e por faixas contiguas
by_reader = t.data_reads(prg)
with open(os.path.join(outdir, 'readers.txt'), 'w') as f:
    f.write('# instrucao_leitora  banco:inicio-fim[,banco:inicio-fim...]   (faixas de bytes de ROM lidos por ela)\n')
    for r in sorted(by_reader):
        offs = sorted(by_reader[r]); rngs = []
        s = p = offs[0]
        for o in offs[1:]:
            if o == p + 1 and (o >> 13) == (p >> 13): p = o; continue
            rngs.append((s, p)); s = p = o
        rngs.append((s, p))
        f.write('%s %s\n' % (fmt_off(r), ','.join('%s-%04X' % (fmt_off(a), off2ba(b)[1]) for a, b in rngs)))
print('readers:', len(by_reader), 'bytes de dados distintos:', len(set().union(*by_reader.values())) if by_reader else 0)

# 4) bytes tocados pelo canal DMC (janela $C000) nos bancos de amostras
with open(os.path.join(outdir, 'dmcread.txt'), 'w') as f:
    f.write('# faixas lidas na janela $C000-$DFFF (banco:inicio-fim)\n')
    s = None
    for o in range(0x80001):
        on = o < 0x80000 and t.dmcread[o] and (s is None or (o >> 13) == (s >> 13))
        if on and s is None: s = o
        elif not on and s is not None:
            f.write('%s-%04X\n' % (fmt_off(s), off2ba(o - 1)[1])); s = o if (o < 0x80000 and t.dmcread[o]) else None

# 5) RAM
with open(os.path.join(outdir, 'ram.txt'), 'w') as f:
    f.write('# end  leituras escritas  quem (r=le, w=escreve; banco:endereco da instrucao)\n')
    for a in sorted(t.ram):
        r, w, who = t.ram[a]
        ws = sorted(who, key=lambda s: (int(s[1:], 16), s[0]))
        f.write('%04X r=%d w=%d %s\n' % (a, r, w, ','.join(x[0] + fmt_off(int(x[1:], 16)) for x in ws)))

# 6) registradores do MMC5 e amostras
with open(os.path.join(outdir, 'regs.txt'), 'w') as f:
    f.write('# registrador: valores escritos (valor:contagem)\n')
    for reg in sorted(t.regs):
        f.write('%04X %s\n' % (reg, ' '.join('%02X:%d' % (v, n) for v, n in sorted(t.regs[reg].items()))))
with open(os.path.join(outdir, 'dmc.txt'), 'w') as f:
    f.write('# banco endereco tamanho taxa($4010) vezes\n')
    for (b, a, l, r), n in sorted(t.dmc.items()):
        f.write('%02X %04X %04X %02X %d\n' % (b, a, l, r, n))
print('amostras DPCM distintas:', len(t.dmc))
with open(os.path.join(outdir, 'README.txt'), 'w') as f:
    f.write('Trace mesclado de %d execucoes no Mesen 2 (tools/mesen/cdl.lua):\n' % len(used))
    for d in used: f.write('  ' + os.path.basename(d.rstrip('/')) + '\n')

# 7) modos de tela ($B0) em que cada instrucao executou + contagem (so execucoes feitas com cdl.lua v4)
modes = {}; counts = collections.Counter(); nm = 0
for d in used:
    p = os.path.join(d, 'first.txt')
    if not os.path.exists(p): continue
    rows = [l.split() for l in open(p)]
    if not rows or len(rows[0]) < 5: continue
    nm += 1
    for o, f1, f2, cnt, mask in rows:
        o = int(o, 16)
        if o >= RAMBASE: continue
        modes[o] = modes.get(o, 0) | int(mask, 16); counts[o] += int(cnt)
with open(os.path.join(outdir, 'modes.txt'), 'w') as f:
    f.write('# instrucao  mascara_de_modos(bit n = modo n de $B0)  execucoes   (mescla de %d execucoes)\n' % nm)
    for o in sorted(modes): f.write('%s %02X %d\n' % (fmt_off(o), modes[o], counts[o]))
print('modes: %d instrucoes (de %d execucoes com mascara)' % (len(modes), nm))

# 8) ponteiros descobertos por rastreamento de origem (ptrtrace.lua): valida e mescla
ptr = {}
np_runs = 0
for d in dirs:
    p = os.path.join(d, 'ptr.txt')
    if not os.path.exists(p): continue
    np_runs += 1
    for l in open(p):
        kind, lo, hi, cnt, amin, amax, banks = l.split()
        lo, hi, cnt, amin, amax = int(lo, 16), int(hi, 16), int(cnt), int(amin, 16), int(amax, 16)
        if lo >= 0x80000 or hi >= 0x80000: continue
        e = ptr.setdefault((kind, lo, hi), [0, amin, amax, set()])
        e[0] += cnt; e[1] = min(e[1], amin); e[2] = max(e[2], amax); e[3] |= {int(b, 16) for b in banks.split(',')}
ok = rej = 0
# origens de byte alto que participam de uma evidencia Y valida (byte baixo do ponteiro = 0, indice em Y)
# So vale quando os dois bytes de origem estao lado a lado (mesmo trecho de codigo ou mesma tabela): sem isso um
# indice constante (ldy #1) usado com um ponteiro alinhado em pagina ($A000) seria confundido com o byte baixo.
def y_ok(lo, hi, amin):
    return (lo >> 13) == (hi >> 13) and abs(lo - hi) <= 8 and amin == (prg[lo] | (prg[hi] << 8))
y_his = {hi for (kind, lo, hi), (cnt, amin, amax, banks) in ptr.items() if kind == 'Y' and y_ok(lo, hi, amin)}
with open(os.path.join(outdir, 'pointers.txt'), 'w') as f:
    f.write('# ponteiros observados (mescla de %d execucoes do ptrtrace.lua)\n' % np_runs)
    f.write('# tipo  byte_baixo  byte_alto  alvo  bancos_do_alvo  contagem     P = lido via (zp),y ; Y = idem, byte baixo passado em Y ; R = destino de RTS (guarda alvo-1)\n')
    rejl = []
    for (kind, lo, hi), (cnt, amin, amax, banks) in sorted(ptr.items(), key=lambda x: (x[0][1], x[0][2])):
        base = prg[lo] | (prg[hi] << 8)
        tgt = (base + 1) & 0xFFFF if kind == 'R' else base
        slot_banks = sorted(b for b in banks if bank_base(b) == (tgt & 0xE000))
        good = tgt >= 0x8000 and slot_banks and ((kind == 'R' and amin == tgt) or (kind == 'P' and base <= amin <= base + 0x2FF)
                                              or (kind == 'Y' and y_ok(lo, hi, amin)))
        if kind == 'P' and prg[lo] == 0 and hi in y_his: good = False       # era o idioma pagina+Y: vale a evidencia Y
        if good:
            f.write('%s %s %s %04X %s %d\n' % (kind, fmt_off(lo), fmt_off(hi), tgt, ','.join('%02X' % b for b in slot_banks), cnt)); ok += 1
        else:
            if kind == 'Y': continue          # evidencia Y recusada e' o caso normal (Y era so um indice)
            rejl.append('# REJEITADO %s %s %s valor=%04X lido=%04X-%04X bancos=%s n=%d' % (kind, fmt_off(lo), fmt_off(hi), base, amin, amax, ','.join('%02X' % b for b in sorted(banks)), cnt)); rej += 1
    f.write('\n'.join(rejl) + '\n')
print('pointers: %d aceitos, %d rejeitados (de %d execucoes)' % (ok, rej, np_runs))
