#!/usr/bin/env python3
"""
disasm.py — gera o projeto ca65 remontavel (src/) a partir de:
    rom/sf2ne_demo.nes        ROM original
    trace/*.txt               trace mesclado (instrucoes executadas, saltos indiretos, leituras de dados, RAM)
    annotations/sf2ne.ann     nomes, comentarios e tipos de dados mantidos a mao (ou com ajuda de IA)

Regra de ouro: `make` precisa sempre reproduzir o ROM original byte a byte.

Organizacao do ROM (MMC5, PRG modo 3): 64 bancos de 8K; o banco n fica SEMPRE na janela (n mod 4):
    n mod 4 = 0 -> $8000   1 -> $A000   2 -> $C000 (amostras DPCM / tabelas)   3 -> $E000 (codigo)
Os tres bancos de codigo ($37, $3B, $3F) terminam com uma copia identica do "kernel" (IRQ, NMI e apoio)
em $FC7C-$FF9A, gerada uma unica vez em src/kernel.inc e incluida nos tres.
"""
import sys, os, re, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from d6502 import OPS, LEN, decode
from tracelib import bank_base, off2ba, ba2off, fmt_off, parse_ba, RAMBASE, DPCM_BANKS

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROMFILE = os.path.join(ROOT, 'rom', 'sf2ne_demo.nes')
ANN = os.path.join(ROOT, 'annotations', 'sf2ne.ann')
TRACE = os.path.join(ROOT, 'trace')
SRC = os.path.join(ROOT, 'src')

CODE_BANKS = (0x37, 0x3B, 0x3F)
KERNEL_LO, KERNEL_HI = 0xFC7C, 0xFF9B      # [lo, hi) identico nos tres bancos de codigo
KERNEL_REF = 0x3F                          # copia usada para gerar kernel.inc
FARCALL = 0x049E

UNK, OPC, OPR, DAT = 0, 1, 2, 3            # classificacao de cada byte de PRG

HW = {
    0x2000: 'PPUCTRL', 0x2001: 'PPUMASK', 0x2002: 'PPUSTATUS', 0x2003: 'OAMADDR', 0x2004: 'OAMDATA',
    0x2005: 'PPUSCROLL', 0x2006: 'PPUADDR', 0x2007: 'PPUDATA',
    0x4000: 'SQ1_VOL', 0x4001: 'SQ1_SWEEP', 0x4002: 'SQ1_LO', 0x4003: 'SQ1_HI',
    0x4004: 'SQ2_VOL', 0x4005: 'SQ2_SWEEP', 0x4006: 'SQ2_LO', 0x4007: 'SQ2_HI',
    0x4008: 'TRI_LINEAR', 0x400A: 'TRI_LO', 0x400B: 'TRI_HI',
    0x400C: 'NOISE_VOL', 0x400E: 'NOISE_LO', 0x400F: 'NOISE_HI',
    0x4010: 'DMC_FREQ', 0x4011: 'DMC_RAW', 0x4012: 'DMC_START', 0x4013: 'DMC_LEN',
    0x4014: 'OAMDMA', 0x4015: 'SND_CHN', 0x4016: 'JOY1', 0x4017: 'JOY2',
    0x5000: 'MMC5_SQ1_VOL', 0x5002: 'MMC5_SQ1_LO', 0x5003: 'MMC5_SQ1_HI',
    0x5004: 'MMC5_SQ2_VOL', 0x5006: 'MMC5_SQ2_LO', 0x5007: 'MMC5_SQ2_HI',
    0x5010: 'MMC5_PCM_MODE', 0x5011: 'MMC5_PCM_RAW', 0x5015: 'MMC5_SND_CHN',
    0x5100: 'MMC5_PRG_MODE', 0x5101: 'MMC5_CHR_MODE', 0x5102: 'MMC5_RAM_PROT1', 0x5103: 'MMC5_RAM_PROT2',
    0x5104: 'MMC5_EXRAM_MODE', 0x5105: 'MMC5_NT_MAP', 0x5106: 'MMC5_FILL_TILE', 0x5107: 'MMC5_FILL_ATTR',
    0x5113: 'MMC5_PRG_6000', 0x5114: 'MMC5_PRG_8000', 0x5115: 'MMC5_PRG_A000', 0x5116: 'MMC5_PRG_C000',
    0x5117: 'MMC5_PRG_E000',
    0x5120: 'MMC5_CHR_SPR0', 0x5121: 'MMC5_CHR_SPR1', 0x5122: 'MMC5_CHR_SPR2', 0x5123: 'MMC5_CHR_SPR3',
    0x5124: 'MMC5_CHR_SPR4', 0x5125: 'MMC5_CHR_SPR5', 0x5126: 'MMC5_CHR_SPR6', 0x5127: 'MMC5_CHR_SPR7',
    0x5128: 'MMC5_CHR_BG0', 0x5129: 'MMC5_CHR_BG1', 0x512A: 'MMC5_CHR_BG2', 0x512B: 'MMC5_CHR_BG3',
    0x5130: 'MMC5_CHR_HI', 0x5200: 'MMC5_SPLIT_MODE', 0x5201: 'MMC5_SPLIT_SCROLL', 0x5202: 'MMC5_SPLIT_BANK',
    0x5203: 'MMC5_IRQ_LINE', 0x5204: 'MMC5_IRQ_STATUS', 0x5205: 'MMC5_MUL_A', 0x5206: 'MMC5_MUL_B',
}
STOPS = {'RTS', 'RTI', 'JMP', 'BRK'}
BRANCHES = {'BPL', 'BMI', 'BVC', 'BVS', 'BCC', 'BCS', 'BNE', 'BEQ'}


class Project:
    def __init__(self):
        rom = open(ROMFILE, 'rb').read()
        self.header = rom[:16]
        self.prg = rom[16:16 + 0x80000]
        self.chr = rom[16 + 0x80000:]
        self.kind = bytearray(0x80000)
        self.traced = bytearray(0x80000)          # 1 = instrucao vista no trace
        self.ins = {}                             # off -> (n, mn, mode, v)
        self.names = {}                           # off -> nome dado pelo usuario
        self.ramnames = {}                        # addr -> nome
        self.comments = collections.defaultdict(list)   # off -> comentarios de fim de linha
        self.blocks = collections.defaultdict(list)     # off -> comentarios de bloco
        self.forced_code = []
        self.forced_data = []                     # (off_ini, off_fim, tipo)
        self.tables = []                          # tabelas tipadas: dict
        self.ramcode = []                         # (off, len, org)
        self.labels = {}                          # off -> nome final (codigo e dados)
        self.farcalls = {}                        # off do inicio da sequencia -> (alvo_off)
        self.far_member = {}                      # off de instrucao dentro de uma sequencia farcall -> inicio
        self.xedges = collections.defaultdict(set)      # off origem -> destinos (XJSR/XJMP/RTS/JMPI)
        self.readers = collections.defaultdict(list)    # off leitor -> [(off_ini, off_fim)]
        self.ramuse = {}                          # addr -> (r, w)
        self.review = []                          # blocos aceitos so por analise estatica
        self.rejected = []
        self.typed = {}                           # off -> ('lo'|'hi'|'word', alvo_off, delta) p/ bytes de tabelas
        self.odd_far = set()                      # JMP FarCall fora do padrao da macro
        self.warn = set()
        self.rts_sites = set(); self.rts_tables = []; self.islands = []; self.island_fail = set()
        self.alts = {}; self.immtext = {}; self.manual_ptr = []; self.inferred = set(); self.statebanks = []; self.struct_fail = []; self.struct_kind = {}
        self.stateconds = []                        # (off da tabela lo, n) — condicoes da maquina de estados
        self.cond_names = {}                        # numero da condicao -> nome da rotina
        self.immsym = {}; self.ptr_conflicts = []; self.ptr_stats = (0, 0); self.ptr_ev = []
        self.nonempty = [b for b in range(64) if any(x != 0xFF for x in self.prg[b << 13:(b + 1) << 13])]

    # ------------------------------------------------------------------ utilidades
    def in_kernel(self, off):
        b, a = off2ba(off)
        return b in CODE_BANKS and KERNEL_LO <= a < KERNEL_HI

    def canon(self, off):
        """offset canonico: enderecos do kernel sao sempre representados pela copia do banco KERNEL_REF."""
        if self.in_kernel(off):
            return ba2off(KERNEL_REF, off2ba(off)[1])
        return off

    # ------------------------------------------------------------------ anotacoes
    def load_annotations(self):
        if not os.path.exists(ANN): return
        cur_alt = None
        for lineno, raw in enumerate(open(ANN, encoding='utf-8'), 1):
            ln = raw.strip()
            if ln.startswith('|'):                      # linha de assembly de um bloco `alt`
                if cur_alt is None: sys.exit('%s:%d: linha "|" fora de um bloco alt' % (ANN, lineno))
                cur_alt[2].append(raw.rstrip('\n').split('|', 1)[1])
                continue
            cur_alt = None
            if not ln or ln.startswith('#'): continue
            p = ln.split(None, 2)
            cmd = p[0]
            try:
                if cmd == 'ram':                        # ram AAAA Nome [tamanho]
                    q = ln.split()
                    base = int(q[1], 16)
                    self.ramnames[base] = q[2]
                    for i in range(1, int(q[3], 0) if len(q) > 3 else 1):
                        self.ramnames[base + i] = '%s+%d' % (q[2], i)
                elif cmd == 'label':
                    q = ln.split()
                    self.names[self.canon(self.parse(q[1]))] = q[2]
                elif cmd == 'comment':
                    self.comments[self.canon(self.parse(p[1]))].append(p[2])
                elif cmd == 'block':
                    self.blocks[self.canon(self.parse(p[1]))].append(p[2] if len(p) > 2 else '')
                elif cmd == 'code':
                    self.forced_code.append(self.parse(p[1]))
                elif cmd == 'data':
                    q = ln.split()
                    a, _, b = q[1].partition('-')
                    o1 = self.parse(a)
                    o2 = ba2off(o1 >> 13, int(b, 16)) if b else o1
                    self.forced_data.append((o1, o2, q[2] if len(q) > 2 else 'bytes'))
                elif cmd == 'table':
                    q = ln.split()
                    d = dict(kind=q[2], off=self.parse(q[1]))
                    for kv in q[3:]:
                        k, v = kv.split('=')
                        d[k] = v
                    self.tables.append(d)
                elif cmd == 'ramcode':
                    q = ln.split()
                    self.ramcode.append((self.parse(q[1]), int(q[2], 16), int(q[3], 16)))
                elif cmd == 'statebank':                # statebank BB frames=BB from=AAAA to=AAAA
                    q = ln.split()
                    d = dict(kv.split('=') for kv in q[2:])
                    self.statebanks.append((int(q[1], 16), int(d['frames'], 16), int(d['from'], 16), int(d['to'], 16)))
                elif cmd == 'statecond':               # statecond BB:AAAA n=N  (tabela de condicoes da maquina de estados)
                    q = ln.split()
                    d = dict(kv.split('=') for kv in q[2:])
                    self.stateconds.append((self.parse(q[1]), int(d.get('n', '0'), 0)))
                elif cmd == 'ptr':                      # ptr BB:AAAA lo|hi BB:TTTT   (metade de um ponteiro, confirmada a mao)
                    q = ln.split()
                    self.manual_ptr.append((self.parse(q[1]), q[2], self.parse(q[3])))
                elif cmd == 'imm':                      # imm BB:AAAA EXPRESSAO   (operando imediato escrito a mao, ex.: <FarCall)
                    self.immtext[self.canon(self.parse(p[1]))] = p[2]
                elif cmd == 'alt':                      # alt SIMBOLO BB:AAAA TAMANHO  (+ linhas "|...")
                    q = ln.split()
                    cur_alt = (q[1], int(q[3], 16), [])
                    self.alts[self.parse(q[2])] = cur_alt
                else:
                    raise ValueError('diretiva desconhecida')
            except Exception as e:
                sys.exit('%s:%d: %s  (%s)' % (ANN, lineno, ln, e))

    def parse(self, s):
        b, a = s.split(':')
        if b.upper() == 'K': return ba2off(KERNEL_REF, int(a, 16))
        return ba2off(int(b, 16), int(a, 16))

    # ------------------------------------------------------------------ trace
    def load_trace(self):
        for ln in open(os.path.join(TRACE, 'opstarts.txt')):
            if ln[0] == '#': continue
            self.traced[parse_ba(ln.strip())] = 1
        for ln in open(os.path.join(TRACE, 'edges.txt')):
            if ln[0] == '#': continue
            ty, a, b, n = ln.split()
            a, b = parse_ba(a), parse_ba(b)
            if b < RAMBASE: self.xedges[a].add(b)
        for ln in open(os.path.join(TRACE, 'readers.txt')):
            if ln[0] == '#': continue
            r, rest = ln.split()
            r = parse_ba(r)
            for rg in rest.split(','):
                a, b = rg.rsplit('-', 1)
                o1 = parse_ba(a)
                self.readers[r].append((o1, ba2off(o1 >> 13, int(b, 16))))
        for ln in open(os.path.join(TRACE, 'ram.txt')):
            if ln[0] == '#': continue
            p = ln.split()
            self.ramuse[int(p[0], 16)] = (int(p[1][2:]), int(p[2][2:]))
        self.ptr_ev = []
        pp = os.path.join(TRACE, 'pointers.txt')
        if os.path.exists(pp):
            for ln in open(pp):
                if ln[0] == '#' or not ln.strip(): continue
                kind, lo, hi, tgt, banks, cnt = ln.split()
                self.ptr_ev.append((kind, parse_ba(lo), parse_ba(hi), int(tgt, 16), [int(b, 16) for b in banks.split(',')], int(cnt)))
        self.modes = {}; self.execs = {}
        mp = os.path.join(TRACE, 'modes.txt')
        if os.path.exists(mp):
            for ln in open(mp):
                if ln[0] == '#': continue
                a, m, c = ln.split()
                self.modes[parse_ba(a)] = int(m, 16); self.execs[parse_ba(a)] = int(c)

    # ------------------------------------------------------------------ analise de fluxo
    def dec(self, off):
        b, a = off2ba(off)
        r = decode(self.prg, off, a)
        if r is None: return None
        if (off & 0x1FFF) + r[0] > 0x2000: return None
        return r

    def mark(self, off, r):
        self.kind[off] = OPC
        for i in range(1, r[0]): self.kind[off + i] = OPR
        self.ins[off] = r

    def far_at(self, off):
        """Se em `off` (um JMP $049E) termina uma sequencia de chamada/salto distante,
        devolve (inicio, alvo_off, tipo) com tipo 'call' (18 bytes, empilha retorno) ou 'jmp' (12 bytes, tail-call)."""
        p = self.prg
        if not (p[off] == 0x4C and p[off + 1] == 0x9E and p[off + 2] == 0x04): return None
        b, a = off2ba(off)
        def target(s):
            tb = p[s + 1]; ta = (((p[s + 3] << 8) | p[s + 5]) + 1) & 0xFFFF
            if not (p[s] == 0xA9 and p[s + 2] == 0xA2 and p[s + 4] == 0xA0): return None
            if tb > 0x3F or bank_base(tb) != (ta & 0xE000): return None
            return ba2off(tb, ta)
        t = target(off - 6)
        if t is None or ((off - 9) >> 13) != (off >> 13): return None
        own = (p[off - 9] == 0xA9 and p[off - 8] == b and p[off - 7] == 0x48)     # lda #banco_atual / pha
        if not own: return None
        s = off - 15
        if (s >> 13) == (off >> 13) and p[s] == 0xA9 and p[s + 2] == 0x48 and p[s + 3] == 0xA9 and p[s + 5] == 0x48:
            ret = ((p[s + 1] << 8) | p[s + 4]) + 1
            if ret == a + 3: return s, t, 'call'
        return off - 9, t, 'jmp'

    def successors(self, off, r):
        """-> lista de offsets alcancaveis a partir da instrucao em off."""
        n, mn, mode, v = r
        b, a = off2ba(off)
        out = []
        if mn in BRANCHES:
            out.append(off + n)
            if (v & 0xE000) == (a & 0xE000): out.append(ba2off(b, v))
        elif mn == 'JSR' or (mn == 'JMP' and mode == 'abs'):
            if mn == 'JSR': out.append(off + n)
            if v == FARCALL:
                f = self.far_at(off)
                if f:
                    out.append(f[1])
                    if f[2] == 'call': out.append(off + n)
                else:
                    self.odd_far.add(off)
            elif v >= 0x8000:
                if self.in_kernel(off) and (v & 0xE000) == 0xE000 and not (KERNEL_LO <= v < KERNEL_HI):
                    for cb in self.kernel_ext(off, v, True): out.append(ba2off(cb, v))
                elif (v & 0xE000) == (a & 0xE000): out.append(ba2off(b, v))
                else:
                    t = self.resolve_cross(off, v)
                    if t is not None: out.append(t)
        elif mn in ('RTS', 'RTI', 'BRK') or (mn == 'JMP' and mode == 'ind'):
            pass
        else:
            out.append(off + n)
        out.extend(self.xedges.get(off, ()))
        return [o for o in out if (o & 0x1FFF) + 1 <= 0x2000]

    def kernel_ext(self, off, v, code):
        """Instrucao do kernel (qualquer copia) que referencia endereco FORA do kernel na janela $E000.
        Como o kernel e' o mesmo nos 3 bancos, a referencia so faz sentido no(s) banco(s) em que foi usada:
        devolve a lista desses bancos, deduzida do trace."""
        a = off2ba(off)[1]
        cands = []
        for cb in CODE_BANKS:
            ko = ba2off(cb, a)
            if code:
                if self.traced[ko] and self.traced[ba2off(cb, v)]: cands.append(cb)
            else:
                if any((o1 >> 13) == cb for o1, o2 in self.readers.get(ko, ())): cands.append(cb)
        return cands

    def resolve_cross(self, off, v):
        """Alvo de JSR/JMP para outra janela: usa o trace; senao, tenta deduzir."""
        ts = [t for t in self.xedges.get(off, ()) if off2ba(t)[1] == v]
        if len(ts) == 1: return ts[0]
        b, a = off2ba(off)
        slot = (v - 0x8000) >> 13
        if slot == 3:
            if KERNEL_LO <= v < KERNEL_HI: return ba2off(KERNEL_REF, v)
            cands = [cb for cb in CODE_BANKS if self.traced[ba2off(cb, v)]]
            if len(cands) == 1: return ba2off(cands[0], v)
            # codigo de banco de dados (ex.: IA no banco $00) so roda com o banco $3F mapeado
            if b not in CODE_BANKS: return ba2off(0x3F, v)
        elif slot == 0:
            cands = [cb for cb in (0x00,) if self.kind[ba2off(cb, v)] == OPC or self.traced[ba2off(cb, v)]]
            if len(cands) == 1: return ba2off(cands[0], v)
        return None

    def tentative(self, off):
        """True se a partir de `off` um bloco decodifica limpo ate um terminador ou ate codigo ja conhecido."""
        o = off
        for _ in range(4000):
            if (o >> 13) != (off >> 13): return False
            if self.kind[o] == OPC: return True
            if self.kind[o] != UNK: return False
            r = self.dec(o)
            if r is None or r[1] == 'BRK': return False
            if any(self.kind[o + i] != UNK for i in range(1, r[0])): return False
            if r[1] in ('RTS', 'RTI', 'JMP'): return True
            o += r[0]
        return False

    def detect_rts_tables(self):
        """Procura o padrao   lda HI,y|x / pha / lda LO,y|x / pha / rts   (salto via RTS para tabela[indice]+1).
        Duas formas: tabelas separadas (LO[n] seguida de HI[n])  ou  palavras intercaladas (HI = LO+1)."""
        new = []
        for off in sorted(self.ins):
            if off in self.rts_sites: continue
            p = self.prg
            if p[off] not in (0xB9, 0xBD) or off + 9 > len(p): continue
            if not (p[off + 3] == 0x48 and p[off + 4] == p[off] and p[off + 7] == 0x48 and p[off + 8] == 0x60): continue
            if not all(self.kind[off + i] == OPC for i in (0, 3, 4, 7, 8)): continue
            hi = p[off + 1] | (p[off + 2] << 8); lo = p[off + 5] | (p[off + 6] << 8)
            b, a = off2ba(off)
            if (hi & 0xE000) != (a & 0xE000) or (lo & 0xE000) != (a & 0xE000): continue
            self.rts_sites.add(off)
            # destino: mesmo banco, a menos que o trace mostre outro (ex.: tabela de rotinas de IA no banco $00)
            def tgt_off(addr):
                if (addr & 0xE000) == (a & 0xE000): return ba2off(b, addr)
                for t in self.xedges.get(off + 8, ()):
                    if (off2ba(t)[1] & 0xE000) == (addr & 0xE000): return ba2off(t >> 13, addr)
                return None
            if hi == lo + 1:        # palavras intercaladas: so as entradas vistas no trace + as que decodificam
                n = 0
                while n < 64:
                    o = ba2off(b, lo + 2 * n)
                    if self.kind[o] in (OPC, OPR) or self.kind[o + 1] in (OPC, OPR): break
                    addr = ((p[o] | (p[o + 1] << 8)) + 1) & 0xFFFF
                    t = tgt_off(addr)
                    if t is None or addr < 0x8000 or not (self.kind[t] == OPC or (n > 0 and self.tentative(t) and self.prg[t] != 0xFF)): break
                    if n > 0 and self.kind[t] != OPC and not any(t in self.xedges.get(off + 8, ()) for _ in (0,)): break
                    self.typed[self.canon(o)] = ('word', t, 1); self.typed[self.canon(o + 1)] = ('skip',)
                    self.kind[o] = self.kind[o + 1] = DAT
                    new.append(t); n += 1
                self.rts_tables.append((off, 'words', lo, hi, n))
            elif 0 < hi - lo <= 64:
                n = hi - lo; cnt = 0
                for i in range(n):
                    ol = ba2off(b, lo + i); oh = ba2off(b, hi + i)
                    addr = (((p[oh] << 8) | p[ol]) + 1) & 0xFFFF
                    t = tgt_off(addr)
                    if t is None or not (self.kind[t] == OPC or self.tentative(t)):
                        self.warn.add('tabela de salto em %s: entrada %d ($%04X) nao parece codigo' % (fmt_off(off), i, addr)); continue
                    self.typed[self.canon(ol)] = ('lo', t, 1); self.typed[self.canon(oh)] = ('hi', t, 1)
                    self.kind[ol] = self.kind[oh] = DAT
                    new.append(t); cnt += 1
                self.rts_tables.append((off, 'split', lo, hi, n))
            else:
                self.warn.add('salto via RTS em %s com tabelas nao reconhecidas (lo=$%04X hi=$%04X)' % (fmt_off(off), lo, hi))
        return [t for t in new if self.kind[t] != OPC]

    def find_islands(self):
        """Codigo que ninguem referencia (rotinas nao usadas): trechos desconhecidos logo apos o fim de uma rotina
        que decodificam inteiros, terminam em RTS/RTI/JMP e cujos saltos caem em fronteiras de instrucao."""
        out = []
        for b in self.code_like_banks():
            o = b << 13; end = (b + 1) << 13
            while o < end:
                if self.kind[o] != UNK or self.prg[o] == 0xFF or o in self.island_fail:
                    o += 1; continue
                # precisa vir logo depois de um terminador de rotina
                p = o - 1
                while p >= (b << 13) and self.kind[p] == OPR: p -= 1
                prev_ok = p >= (b << 13) and self.kind[p] == OPC and (self.ins[p][1] in ('RTS', 'RTI', 'JMP'))
                if not prev_ok:
                    o += 1; continue
                # decodifica ate o proximo byte conhecido
                q = o; block = []; ok = True
                while q < end and self.kind[q] == UNK:
                    r = self.dec(q)
                    if r is None or r[1] == 'BRK' or any(self.kind[q + i] != UNK for i in range(1, r[0])): ok = False; break
                    block.append((q, r)); q += r[0]
                    if r[1] in ('RTS', 'RTI', 'JMP') and (q >= end or self.kind[q] != UNK or self.prg[q] == 0xFF): break
                if ok and block and block[-1][1][1] in ('RTS', 'RTI', 'JMP') and len(block) >= 2:
                    starts = {x for x, _ in block}
                    for x, r in block:
                        n, mn, mode, v = r
                        if mode == 'rel' or (mn in ('JSR', 'JMP') and mode == 'abs' and (v & 0xE000) == (off2ba(x)[1] & 0xE000)):
                            t = ba2off(b, v)
                            if not (t in starts or self.kind[t] == OPC or (self.kind[t] == UNK and self.tentative(t))): ok = False; break
                        if mode in ('abs', 'abx', 'aby') and 0x800 <= v < 0x2000: ok = False; break     # espelhos de RAM: improvavel
                        if mode in ('abs', 'abx', 'aby') and 0x2008 <= v < 0x4000: ok = False; break
                        if mode in ('abs', 'abx', 'aby') and 0x4018 <= v < 0x5000: ok = False; break
                else:
                    ok = False
                if ok:
                    out.append(o); self.islands.append((o, block[-1][0] + block[-1][1][0] - 1))
                    return out            # um de cada vez: o laco principal reanalisa
                self.island_fail.add(o)
                o += 1
        return out

    def code_like_banks(self):
        return sorted({o >> 13 for o in self.ins})

    def analyze(self):
        # fase 0: dados forcados
        for o1, o2, ty in self.forced_data:
            for o in range(o1, o2 + 1): self.kind[o] = DAT
        for o, ln_, org in self.ramcode:
            for i in range(ln_): self.kind[o + i] = DAT
        # fase 1: instrucoes confirmadas pelo trace
        work = []
        for off in range(0x80000):
            if self.traced[off]:
                r = self.dec(off)
                if r is None:
                    print('AVISO: trace marcou %s como instrucao, mas o opcode e invalido' % fmt_off(off)); continue
                self.mark(off, r)
        for off in list(self.ins):
            work.extend(self.successors(off, self.ins[off]))
        # o kernel e identico nos tres bancos: o que foi executado numa copia vale para as outras
        for off in list(self.ins):
            if self.in_kernel(off):
                a = off2ba(off)[1]
                for cb in CODE_BANKS: work.append(ba2off(cb, a))
        # vetores e entradas forcadas
        for cb in CODE_BANKS:
            base = cb << 13
            for vec in (0x1FFA, 0x1FFC, 0x1FFE):
                tgt = self.prg[base + vec] | (self.prg[base + vec + 1] << 8)
                if self.prg[ba2off(cb, tgt)] != 0xFF: work.append(ba2off(cb, tgt))
        work.extend(self.forced_code)
        # fase 2: extensao estatica, bloco a bloco, so aceita blocos que decodificam limpo
        seen_fail = set()
        while True:
            if not work:
                # fila vazia: procura tabelas de salto novas e ilhas de codigo nao alcancado; se achar, continua
                work.extend(self.detect_rts_tables())
                if not work: work.extend(self.find_islands())
                if not work: break
            off = work.pop()
            if self.kind[off] == OPC or off in seen_fail: continue
            if self.kind[off] in (OPR, DAT):
                seen_fail.add(off); self.rejected.append((off, 'cai no meio de instrucao/dado')); continue
            block = []; o = off; ok = True; why = ''
            while True:
                if self.kind[o] == OPC: break
                if self.kind[o] != UNK: ok = False; why = 'encosta em operando/dado em %s' % fmt_off(o); break
                r = self.dec(o)
                if r is None: ok = False; why = 'opcode invalido $%02X em %s' % (self.prg[o], fmt_off(o)); break
                if any(self.kind[o + i] != UNK for i in range(1, r[0])): ok = False; why = 'sobreposicao em %s' % fmt_off(o); break
                if r[1] == 'BRK': ok = False; why = 'BRK em %s' % fmt_off(o); break
                block.append((o, r))
                if r[1] in ('RTS', 'RTI') or r[1] == 'JMP': break
                o += r[0]
                if (o & 0x1FFF) == 0: ok = False; why = 'passa do fim do banco'; break
            # bloco feito so de $FF... nao acontece (FF e' invalido)
            if not ok:
                seen_fail.add(off); self.rejected.append((off, why)); continue
            for o, r in block: self.mark(o, r)
            if block: self.review.append((off, block[-1][0] + block[-1][1][0] - 1))
            for o, r in block: work.extend(self.successors(o, r))
        # sequencias de chamada distante
        for off, r in self.ins.items():
            if r[1] == 'JMP' and r[3] == FARCALL:
                f = self.far_at(off)
                if not f: continue
                opc = (0, 2, 3, 5, 6, 8, 9, 11, 13, 15) if f[2] == 'call' else (0, 2, 3, 5, 7, 9)
                ln_ = 18 if f[2] == 'call' else 12
                if all(self.kind[f[0] + i] == (OPC if i in opc else OPR) for i in range(ln_)):
                    self.farcalls[f[0]] = (f[1], f[2], ln_)
        # todo o resto: dado
        for off in range(0x80000):
            if self.kind[off] == UNK: self.kind[off] = DAT

    # ------------------------------------------------------------------ rotulos
    def apply_pointers(self):
        """Usa os ponteiros observados (trace/pointers.txt) para tornar simbolicos:
           - pares de imediatos  (lda #<Rotulo ... ldx #>Rotulo)
           - bytes de dados que guardam ponteiros (.word Rotulo / .byte <Rotulo / .byte >Rotulo)"""
        self.immsym = {}; self.ptr_conflicts = []; self.ptr_multibank = {}
        far_inner = set()
        for st, fc in self.farcalls.items():
            far_inner.update(range(st, st + fc[2]))
        ramcode = set()
        for o, ln_, org in self.ramcode: ramcode.update(range(o, o + ln_))
        def site_ok(o):
            # um byte de ponteiro so pode ser: operando de instrucao imediata, ou byte de dados
            co = self.canon(o)
            if co in ramcode: return True              # imagem do trampolim (tratada a parte)
            if self.kind[co] == DAT: return True
            return self.kind[co] == OPR and self.kind[co - 1] == OPC and self.ins[co - 1][2] == 'imm'
        sites = {}
        self.ptr_bad = 0
        for kind, lo, hi, tgt, banks, cnt in sorted(self.ptr_ev, key=lambda e: -e[5]):
            if not (site_ok(lo) and site_ok(hi)):
                self.ptr_bad += 1; continue             # origem impossivel (ruido do DMA do DMC): descarta o par todo
            delta = 1 if kind == 'R' else 0
            t = self.canon(ba2off(banks[0], tgt))
            for part, o in (('lo', lo), ('hi', hi)):
                co = self.canon(o)
                prev = sites.get(co)
                if prev is None:
                    sites[co] = (part, t, delta, cnt)
                    if len(banks) > 1: self.ptr_multibank[co] = banks
                elif prev[:3] != (part, t, delta):
                    self.ptr_conflicts.append((co, prev, (part, t, delta, cnt)))
        nimm = ndat = 0
        for co, (part, t, delta, cnt) in sorted(sites.items()):
            if co in self.typed or co in ramcode: continue
            k = self.kind[co]
            if k == OPR:
                st = co - 1
                if self.kind[st] == OPC and self.ins[st][2] == 'imm' and st not in far_inner:
                    self.immsym[st] = (part, t, delta); nimm += 1
            elif k == DAT:
                self.typed[co] = (part, t, delta); ndat += 1
        for o, part, t in self.manual_ptr:              # ponteiros confirmados a mao (anotacao `ptr`)
            co = self.canon(o)
            if self.kind[co] == OPC and self.ins[co][2] == 'imm': self.immsym[co] = (part, self.canon(t), 0)
            elif self.kind[co] == DAT: self.typed[co] = (part, self.canon(t), 0)
            else: self.warn.add('anotacao ptr em %s: nao e\' instrucao imediata nem dado' % fmt_off(o))
        # lo seguido de hi do mesmo alvo = palavra de 16 bits
        for co in sorted(self.typed):
            ty = self.typed[co]
            if ty[0] == 'lo' and (co + 1) in self.typed and self.typed[co + 1] == ('hi', ty[1], ty[2]) and ((co + 1) >> 13) == (co >> 13):
                self.typed[co] = ('word', ty[1], ty[2]); self.typed[co + 1] = ('skip',)
        self.ptr_stats = (nimm, ndat)
        self.infer_table_words()
        for sb in self.statebanks: self.infer_state_bank(*sb)

    def infer_table_words(self):
        """Completa tabelas de ponteiros: um trecho de dados nao tipado ESPREMIDO entre duas palavras-ponteiro ja
        confirmadas pelo trace, em que todos os pares de bytes sao 0 ou enderecos validos do mesmo banco-alvo,
        e' tratado como mais entradas da mesma tabela (marcado "(inferido)" no fonte)."""
        self.inferred = set()
        used_hi = {}
        for b in range(64):
            d = self.prg[b << 13:(b + 1) << 13]
            last = max((i for i in range(0x2000) if d[i] != 0xFF), default=-1)
            used_hi[b] = bank_base(b) + last
        words = sorted(o for o, ty in self.typed.items() if ty[0] == 'word')
        nxt = {a: b for a, b in zip(words, words[1:])}
        for a in words:
            b = nxt.get(a)
            if b is None or (a >> 13) != (b >> 13): continue
            s, e = a + 2, b                      # trecho [s, e)
            n = e - s
            if n <= 0 or n % 2 or n > 64: continue
            if any(self.kind[o] != DAT or self.canon(o) in self.typed for o in range(s, e)): continue
            if any(self.canon(o) in self.names for o in range(s + 1, e)): continue
            ta, tb = self.typed[a][1], self.typed[b][1]
            if (ta >> 13) != (tb >> 13): continue        # vizinhos apontam para bancos diferentes: nao arrisca
            tbank = ta >> 13
            vals = [self.prg[o] | (self.prg[o + 1] << 8) for o in range(s, e, 2)]
            if not all(v == 0 or (bank_base(tbank) <= v <= used_hi[tbank]) for v in vals): continue
            if not any(vals): continue
            for o, v in zip(range(s, e, 2), vals):
                if v == 0: continue
                self.typed[o] = ('word', ba2off(tbank, v), 0); self.typed[o + 1] = ('skip',)
                self.inferred.add(o)

    def infer_state_bank(self, bank, fbank, a_lo, a_hi):
        """Banco de estados de um lutador (formato descoberto no banco $01 do Ryu). Dois tipos de registro:
             CABECALHO DE ESTADO (7 bytes)   +1 ponteiro p/ estado alternativo, +3 ponteiro p/ o proximo estado (neste banco)
             QUADRO DE ANIMACAO (14 bytes)   +1 ponteiro p/ o metasprite e +3 p/ as caixas (banco de frames),
                                             +11 condicao de desvio, +12 ponteiro p/ o proximo quadro (neste banco);
                                             se +11 != 0 o quadro tem 16 bytes: +14 = ponteiro do desvio.
           Os trechos entre alvos de ponteiros confirmados pelo trace sao lidos em sequencia com essa gramatica; um trecho
           so e' aceito se fechar exatamente e todos os campos forem 0 ou enderecos validos. Assim os ponteiros dos
           estados que nenhum trace visitou tambem ficam simbolicos."""
        lo_o, hi_o = ba2off(bank, a_lo), ba2off(bank, a_hi)
        def last_used(bb):
            d = self.prg[bb << 13:(bb + 1) << 13]
            return bank_base(bb) + max((i for i in range(0x2000) if d[i] != 0xFF), default=0)
        s_end, f_end = last_used(bank), last_used(fbank)
        targets = sorted({ty[1] for ty in self.typed.values() if ty[0] in ('word', 'lo', 'hi') and lo_o <= ty[1] <= hi_o})
        bounds = targets + [hi_o + 1]
        def word(o): return self.prg[o] | (self.prg[o + 1] << 8)
        def in_s(v): return a_lo <= v <= s_end
        def in_f(v): return bank_base(fbank) <= v <= f_end
        n_new = 0
        for a, z in zip(bounds, bounds[1:]):
            p = a; items = []; ok = True
            while p < z:
                if p + 7 > z: ok = False; break
                w1, w3 = word(p + 1), word(p + 3)
                if in_f(w1):                                   # quadro
                    size = 16 if (p + 12 <= z and self.prg[p + 11] != 0) else 14
                    if p + size > z: ok = False; break
                    fl = [(1, fbank, True), (3, fbank, False), (12, bank, False)] + ([(14, bank, True)] if size == 16 else [])
                    kind = 'quadro'
                elif (w1 == 0 or in_s(w1)) and (w3 == 0 or in_s(w3)):   # cabecalho de estado
                    size = 7; fl = [(1, bank, False), (3, bank, False)]; kind = 'estado'
                else: ok = False; break
                for k, tb, req in fl:
                    v = word(p + k)
                    if v == 0:
                        if req: ok = False
                    elif not (in_s(v) if tb == bank else in_f(v)): ok = False
                if not ok: break
                items.append((p, kind, size, fl)); p += size
            if ok:
                fields = {it[0] + k: tb for it in items for k, tb, req in it[3]}
                # ponteiro confirmado pelo trace num lugar que a gramatica nao preve = o trecho nao e' deste formato
                for o in range(a, z):
                    ty = self.typed.get(o)
                    if ty and ty[0] == 'word' and (o not in fields or (ty[1] >> 13) != fields[o]): ok = False
                    if ty and ty[0] in ('lo', 'hi'): ok = False
            if not ok:
                self.struct_fail.append((a, z - a)); continue
            for o, tb in sorted(fields.items()):
                if o in self.typed or word(o) == 0: continue
                self.typed[o] = ('word', ba2off(tb, word(o)), 0); self.typed[o + 1] = ('skip',)
                self.inferred.add(o); n_new += 1
            for p, kind, size, fl in items: self.struct_kind[p] = (kind, size)
        self.struct_new = getattr(self, 'struct_new', 0) + n_new

    def build_cond_names(self):
        """Nomes das condicoes da maquina de estados, derivados da tabela de despacho (truque do RTS):
        cada entrada guarda endereco-1 da rotina que testa a condicao. O rotulo dessa rotina no .ann
        vira o nome impresso nos cabecalhos '; -- ESTADO' do banco de dados do lutador."""
        for off, n in self.stateconds:
            b = off >> 13
            for i in range(n):
                addr = (((self.prg[off + n + i] << 8) | self.prg[off + i]) + 1) & 0xFFFF
                t = ba2off(b, addr)
                nm = self.names.get(t) or self.labels.get(t)
                if nm: self.cond_names[i] = nm
                else: self.warn.add('statecond %s: entrada %d ($%04X) nao tem rotulo' % (fmt_off(off), i, addr))

    def auto_name(self, off):
        b, a = off2ba(off)
        code = self.kind[off] == OPC
        if self.in_kernel(off): return ('K_%04X' if code else 'KD_%04X') % a
        return ('L%02X_%04X' if code else 'D%02X_%04X') % (b, a)

    def need_label(self, off):
        off = self.canon(off)
        if off not in self.labels:
            self.labels[off] = self.names.get(off) or self.auto_name(off)
        return self.labels[off]

    def sym_for(self, off):
        """Expressao simbolica para o endereco de `off` (cria rotulo; se cair no meio de instrucao usa base+n)."""
        off = self.canon(off)
        if self.typed.get(off, ('',))[0] == 'skip':          # segundo byte de um .word
            return '%s+1' % self.need_label(off - 1)
        if self.kind[off] == OPR or off in self.far_inner:
            s = off
            if off in self.far_inner: s = self.far_inner[off]
            else:
                while self.kind[s] == OPR: s -= 1
            if s != off: return '%s+%d' % (self.need_label(s), off - s)
        return self.need_label(off)

    def operand_target(self, off, r):
        """Para instrucoes com operando de 16 bits >= $8000: offset do alvo (ou None se nao der p/ resolver)."""
        n, mn, mode, v = r
        b, a = off2ba(off)
        if v < 0x8000: return None
        if self.in_kernel(off) and (v & 0xE000) == 0xE000 and not (KERNEL_LO <= v < KERNEL_HI):
            c = self.kernel_ext(off, v, mn in ('JSR', 'JMP'))
            if len(c) > 1: self.warn.add('kernel %04X referencia $%04X valido em varios bancos: %s' % (a, v, c))
            return ba2off(c[0], v) if c else None
        if (v & 0xE000) == (a & 0xE000): return ba2off(b, v)
        if mn in ('JSR', 'JMP') and mode == 'abs': return self.resolve_cross(off, v)
        if mode in ('abs', 'abx', 'aby'):
            # dado em outra janela: se o trace mostra que esta instrucao so leu UM banco ali, usa o rotulo dele
            bs = set()
            for x in self.kernel_copies(off):
                for o1, o2 in self.readers.get(x, ()):
                    if bank_base(o1 >> 13) == (v & 0xE000): bs.add(o1 >> 13)
            if len(bs) == 1: return ba2off(bs.pop(), v)
        if (v & 0xE000) == 0xE000 and KERNEL_LO <= v < KERNEL_HI: return ba2off(KERNEL_REF, v)
        return None

    def collect_labels(self):
        self.far_inner = {}
        for s, fc in self.farcalls.items():
            for i in range(1, fc[2]): self.far_inner[s + i] = s
        for off in self.names: self.need_label(off)
        for off, r in sorted(self.ins.items()):
            n, mn, mode, v = r
            if self.in_kernel(off) and (off >> 13) != KERNEL_REF: continue     # o kernel e' emitido uma vez so
            if off in self.far_inner: continue
            if off in self.farcalls:
                self.need_label(self.farcalls[off][0]); continue
            if mode == 'rel':
                self.sym_for(ba2off(off >> 13, v))
            elif mode in ('abs', 'abx', 'aby', 'ind'):
                t = self.operand_target(off, r)
                if t is not None: self.sym_for(t)
        for t in self.tables:
            self.prepare_table(t)
        for o, ty in list(self.typed.items()):
            if ty[0] in ('lo', 'hi', 'word'): self.sym_for(ty[1])
        for o, ps in self.immsym.items(): self.sym_for(ps[1])
        for off, k, lo, hi, n in self.rts_tables:
            self.need_label(ba2off(off >> 13, lo))
            if k == 'split': self.need_label(ba2off(off >> 13, hi))
        for cb in CODE_BANKS:           # vetores
            for vec in (0xFFFA, 0xFFFC, 0xFFFE):
                o = ba2off(cb, vec)
                tgt = self.prg[o] | (self.prg[o + 1] << 8)
                self.typed[o] = ('word', ba2off(cb, tgt), 0); self.typed[o + 1] = ('skip',)
                self.sym_for(ba2off(cb, tgt))

    def collect_xrefs(self):
        """Quem chama cada rotina: JSR, JMP (para outro trecho), chamadas distantes e tabelas de salto."""
        self.xrefs = collections.defaultdict(list)
        for off, r in sorted(self.ins.items()):
            n, mn, mode, v = r
            if self.in_kernel(off) and (off >> 13) != KERNEL_REF: continue
            if off in self.far_inner: continue
            if off in self.farcalls:
                t, fk, fl = self.farcalls[off]
                self.xrefs[self.canon(t)].append((off, 'farcall' if fk == 'call' else 'farjmp')); continue
            if mn in ('JSR', 'JMP') and mode == 'abs':
                t = self.operand_target(off, r)
                if t is not None and self.kind[t] == OPC: self.xrefs[self.canon(t)].append((off, mn.lower()))
        for o, ty in sorted(self.typed.items()):
            if ty[0] in ('lo', 'word') and self.kind[ty[1]] == OPC:
                self.xrefs[self.canon(ty[1])].append((o, 'tabela'))
        self.sub_entries = {t for t, xs in self.xrefs.items() if any(k != 'jmp' for _, k in xs)}

    def near_label(self, off):
        co = self.canon(off); o = co
        while o >= ((co >> 13) << 13):
            if o in self.labels: return self.labels[o]
            o -= 1
        return fmt_off(off)

    def routine_of(self, off):
        """Rotulo de entrada (inicio de rotina) que contem a instrucao `off`."""
        co = self.canon(off); b = co >> 13; o = co
        while o >= (b << 13):
            if self.kind[o] == OPC and o in self.labels and (self.is_entry(o) or o in self.sub_entries): return self.labels[o]
            o -= 1
        return fmt_off(off)

    MODE_NAMES = ['aviso/QR', 'titulo', 'selecao', 'VS', 'intro do round', 'luta', 'fim do round', 'frase final']

    def entry_info(self, co):
        """Linhas de comentario automaticas para o inicio de uma rotina."""
        out = []
        xs = self.xrefs.get(co)
        if xs:
            seen = []; 
            for src, kind in xs:
                nm = ('%s %s' % (kind, self.routine_of(src))) if kind != 'tabela' else 'tabela %s' % self.near_label(src)
                if nm not in seen: seen.append(nm)
            more = len(seen) - 6
            out.append('; <- ' + ', '.join(seen[:6]) + (' ... (+%d)' % more if more > 0 else ''))
        ms = 0; ex = 0
        for x in self.kernel_copies(co):
            ms |= self.modes.get(x, 0); ex += self.execs.get(x, 0)
        if ms:
            names = [self.MODE_NAMES[i] for i in range(8) if ms & (1 << i)]
            out.append('; modos: %s' % ('todos' if len(names) == 8 else ', '.join(names)))
        return out

    def prepare_table(self, t):
        k = t['kind']; off = t['off']; b = off >> 13
        n = int(t.get('n', '0'), 0)
        delta = int(t.get('delta', '0'), 0)
        tb = int(t['bank'], 16) if 'bank' in t else b
        if k == 'split':            # tabela de enderecos dividida em bytes baixos (lo=) e altos (hi=)
            lo = ba2off(b, int(t['lo'], 16)); hi = ba2off(b, int(t['hi'], 16))
            for i in range(n):
                addr = ((self.prg[hi + i] << 8) | self.prg[lo + i]) + delta
                tgt = ba2off(tb, addr & 0xFFFF)
                self.typed[self.canon(lo + i)] = ('lo', tgt, delta); self.typed[self.canon(hi + i)] = ('hi', tgt, delta)
                self.sym_for(tgt)
        elif k == 'words':          # tabela de ponteiros de 16 bits
            for i in range(n):
                o = off + 2 * i
                addr = (self.prg[o] | (self.prg[o + 1] << 8)) + delta
                tgt = ba2off(tb, addr & 0xFFFF)
                self.typed[self.canon(o)] = ('word', tgt, delta); self.typed[self.canon(o + 1)] = ('skip',)
                self.sym_for(tgt)
        else:
            sys.exit('tipo de tabela desconhecido: ' + k)
        self.need_label(off) if k == 'words' else None

    # ------------------------------------------------------------------ emissao
    def ram_sym(self, v):
        if v in self.ramnames: return self.ramnames[v]
        # deslocamento a partir de um nome conhecido imediatamente anterior? (nao: mantem simples)
        return ('zp_%02X' % v) if v < 0x100 else ('ram_%04X' % v)

    def addr_expr(self, off, r):
        """Texto do operando de endereco (abs/abx/aby/ind/zp...)."""
        n, mn, mode, v = r
        if mode in ('zp', 'zpx', 'zpy', 'izx', 'izy'):
            self.ram_used.add(v); return self.ram_sym(v)
        if v < 0x800:
            self.ram_used.add(v)
            s = self.ram_sym(v)
            return ('a:' + s) if v < 0x100 else s
        if v in HW: return HW[v]
        if v >= 0x8000:
            t = self.operand_target(off, r)
            if t is not None:
                tb = t >> 13
                if tb != (off >> 13) and not (self.in_kernel(t) and (off >> 13) in CODE_BANKS):
                    self.imports[off >> 13].add(self.sym_base(t)); self.exports.add(self.sym_base(t))
                elif self.in_kernel(off) and not self.in_kernel(t):
                    # kernel referenciando endereco especifico de um banco
                    self.exports.add(self.sym_base(t)); self.kernel_imports.add(self.sym_base(t))
                return self.sym_for(t)
        return '$%04X' % v

    def sym_base(self, off):
        return self.sym_for(off).split('+')[0]

    def fmt_ins(self, off, r):
        n, mn, mode, v = r
        m = mn.lower()
        if mode == 'imp': return m
        if mode == 'acc': return m + ' a'
        if mode == 'imm':
            if self.canon(off) in self.immtext: return '%s #%s' % (m, self.immtext[self.canon(off)])
            ps = self.immsym.get(self.canon(off))
            if ps:
                nm = self.sym_for(ps[1]); self.note_ref(off, ps[1], nm)
                return '%s #%s(%s%s)' % (m, '<' if ps[0] == 'lo' else '>', nm, self.dl(ps[2])) if ps[2] else \
                       '%s #%s%s' % (m, '<' if ps[0] == 'lo' else '>', nm)
            return '%s #$%02X' % (m, v)
        if mode == 'rel': return '%s %s' % (m, self.sym_for(ba2off(off >> 13, v)))
        e = self.addr_expr(off, r)
        return {'zp': '%s %s', 'abs': '%s %s', 'zpx': '%s %s,x', 'abx': '%s %s,x', 'zpy': '%s %s,y', 'aby': '%s %s,y',
                'ind': '%s (%s)', 'izx': '%s (%s,x)', 'izy': '%s (%s),y'}[mode] % (m, e)

    def reader_note(self, off, r):
        """Comentario com os bancos/faixas que a instrucao leu no trace (para enderecos fora do proprio banco)."""
        rg = self.readers.get(off)
        if not rg: return ''
        n, mn, mode, v = r
        banks = sorted({o1 >> 13 for o1, o2 in rg})
        if mode in ('izx', 'izy'):
            return 'le bancos ' + ','.join('$%02X' % b for b in banks)
        if all(b == (off >> 13) for b in banks):
            hi = max(o2 for o1, o2 in rg); lo = min(o1 for o1, o2 in rg)
            return ('idx $%02X..$%02X' % (off2ba(lo)[1] - v, off2ba(hi)[1] - v)) if mode != 'abs' else ''
        hi = max(off2ba(o2)[1] for o1, o2 in rg); lo = min(off2ba(o1)[1] for o1, o2 in rg)
        s = 'bancos ' + ','.join('$%02X' % b for b in banks)
        if mode != 'abs': s += ' idx $%02X..$%02X' % (lo - v, hi - v)
        return s

    def emit_range(self, out, bank, a_lo, a_hi, for_kernel=False, in_alt=False):
        """Emite [a_lo, a_hi) do banco."""
        base = bank << 13
        o = ba2off(bank, a_lo); end = base + (a_hi - bank_base(bank))
        COL = 44
        def line(text, off, nbytes, extra=''):
            raw = ' '.join('%02X' % x for x in self.prg[off:off + nbytes][:8]) + (' ..' if nbytes > 8 else '')
            cm = '; %04X  %-11s' % (off2ba(off)[1], raw)
            if extra: cm += ' ' + extra
            out.append(('    %-*s%s' % (COL, text, cm)).rstrip())
        while o < end:
            co = self.canon(o)
            if o in self.alts and not in_alt:
                name, ln_, lines = self.alts[o]
                a0 = off2ba(o)[1]
                tag = '__alt_%02X_%04X' % (bank, a0)
                out.append(''); out.append('.ifdef %s' % name)
                out.append('%s:' % tag)
                out.extend(lines)
                out.append('    .assert * - %s <= $%X, error, "bloco alt %s em $%04X passou do tamanho"' % (tag, ln_, name, a0))
                out.append('    .res $%X - (* - %s), $FF' % (ln_, tag))
                out.append('.else')
                self.emit_range(out, bank, a0, a0 + ln_, in_alt=True)
                out.append('.endif'); out.append('')
                o += ln_; continue
            if co in self.blocks:
                out.append('')
                for t in self.blocks[co]: out.append('; ' + t if t else ';')
            if o in self.struct_kind and not in_alt:
                sk = self.struct_kind[o]
                out.append('')
                first = sk[0] == 'quadro' and self.struct_kind.get(o - 7, ('',))[0] == 'estado'
                note = '' if co in self.labels else ('   [1o quadro do estado acima: cabecalho+7]' if first
                                                      else '   [$%04X, nenhum ponteiro conhecido aponta para ca]' % off2ba(o)[1])
                if sk[0] == 'estado':
                    c = self.prg[o]
                    cs = 'cond=$%02X' % c
                    if c >= 0x80: cs += ' sempre'
                    elif c in self.cond_names: cs += ' %s' % self.cond_names[c]
                    summ = '   [%s | classe=$%02X | acertos=%d]' % (cs, self.prg[o + 5], self.prg[o + 6])
                else:
                    p = self.prg
                    sg = lambda v: v - 256 if v >= 128 else v
                    summ = '   [dur=%d efe=$%02X/$%02X fl=$%02X mov=$%02X vx=%d vy=%d rep=%d' % (
                        p[o], p[o + 5], p[o + 6], p[o + 7], p[o + 8], sg(p[o + 9]), sg(p[o + 10]), p[o + 11])
                    if sk[1] == 16: summ += ' br=$%04X' % (p[o + 14] | (p[o + 15] << 8))
                    summ += ']'
                out.append('; -- %s%s%s' % ('ESTADO (cabecalho, 7 bytes)' if sk[0] == 'estado' else 'quadro (%d bytes)' % sk[1], summ, note))
            if co in self.labels:
                if self.kind[o] == OPC and (o == base or self.is_entry(o) or co in self.xrefs) and co not in self.blocks: out.append('')
                if self.kind[o] == OPC and (co in self.xrefs or (self.is_entry(o) and co in self.names)):
                    out.extend(self.entry_info(co))
                out.append(self.labels[co] + ':')
            k = self.kind[o]
            if o in self.ramcode_at:
                ln_, org = self.ramcode_at[o]
                self.emit_ramcode(out, o, ln_, org, line); o += ln_; continue
            if k == OPC and o in self.farcalls:
                t, fkind, flen = self.farcalls[o]
                name = self.sym_for(t)
                if (t >> 13) != bank or self.in_kernel(o):
                    self.exports.add(name)
                    (self.kernel_imports if self.in_kernel(o) else self.imports[bank]).add(name)
                notes = ['-> %s' % fmt_off(t)] + self.comments.get(co, [])
                if not any(self.traced[x] for x in self.kernel_copies(o + flen - 3)): notes.append('(nt)')
                line('%s %s' % ('farcall' if fkind == 'call' else 'farjmp', name), o, flen, ' '.join(notes))
                if fkind == 'jmp': out.append('')
                o += flen; continue
            if k == OPC:
                r = self.ins[o]
                notes = []
                rn = self.reader_note(o, r)
                if rn: notes.append('[' + rn + ']')
                notes += self.comments.get(co, [])
                if not any(self.traced[x] for x in self.kernel_copies(o)): notes.append('(nt)')
                line(self.fmt_ins(o, r), o, r[0], ' '.join(notes))
                if r[1] in ('RTS', 'RTI') or r[1] == 'JMP': out.append('')
                o += r[0]; continue
            # dados
            if co in self.typed:
                ty = self.typed[co]
                notes = ' '.join(self.comments.get(co, []))
                if ty[0] == 'word':
                    nm = self.sym_for(ty[1]); self.note_ref(o, ty[1], nm)
                    if co in self.inferred: notes = ('(inferido) ' + notes).strip()
                    line('.word %s%s' % (nm, self.dl(ty[2])), o, 2, notes); o += 2; continue
                if ty[0] in ('lo', 'hi'):
                    nm = self.sym_for(ty[1]); self.note_ref(o, ty[1], nm)
                    line('.byte %s(%s%s)' % ('<' if ty[0] == 'lo' else '>', nm, self.dl(ty[2])), o, 1, notes); o += 1; continue
            # sequencia de bytes ate o proximo rotulo/tipo/instrucao
            j = o + 1
            while j < end and self.kind[j] == DAT and self.canon(j) not in self.labels and self.canon(j) not in self.typed \
                    and self.canon(j) not in self.blocks and j not in self.ramcode_at and j not in self.alts \
                    and j not in self.struct_kind:
                j += 1
            self.emit_bytes(out, o, j, line)
            o = j

    def dl(self, delta):
        return '' if delta == 0 else ('-%d' % delta if delta > 0 else '+%d' % -delta)

    def note_ref(self, o, t, name):
        base = name.split('+')[0]
        b = o >> 13
        if self.in_kernel(o):
            if not self.in_kernel(t): self.exports.add(base); self.kernel_imports.add(base)
        elif (t >> 13) != b and not self.in_kernel(t):
            self.exports.add(base); self.imports[b].add(base)

    def kernel_copies(self, o):
        if self.in_kernel(o):
            a = off2ba(o)[1]
            return [ba2off(cb, a) for cb in CODE_BANKS]
        return [o]

    def is_entry(self, o):
        """Instrucao que nao e' alcancada por queda da anterior (inicio de rotina)."""
        p = o - 1
        if (p >> 13) != (o >> 13): return True
        while self.kind[p] == OPR: p -= 1
        if self.kind[p] != OPC: return True
        r = self.ins[p]
        return r[1] in ('RTS', 'RTI') or r[1] == 'JMP'

    def emit_bytes(self, out, o, j, line):
        """Emite prg[o:j] como .byte (16 por linha); corridas de 16+ bytes $FF viram `.res n, $FF`."""
        cm = ' '.join(self.comments.get(self.canon(o), []))
        while o < j:
            k = o
            while k < j and self.prg[k] == 0xFF: k += 1
            if k - o >= 16:
                line('.res %d, $FF' % (k - o), o, 0, cm); o = k; cm = ''; continue
            # ate 16 bytes, parando antes de uma corrida longa de $FF
            k = o; lim = min(j, o + 16)
            while k < lim:
                if self.prg[k] == 0xFF:
                    u = k
                    while u < j and self.prg[u] == 0xFF: u += 1
                    if u - k >= 16: break
                    k = min(u, lim)
                else: k += 1
            k = max(k, o + 1)
            line('.byte ' + ','.join('$%02X' % x for x in self.prg[o:k]), o, 0, cm)
            o = k; cm = ''

    def emit_ramcode(self, out, o, ln_, org, line):
        """Trecho de codigo que e' copiado para a RAM e executado la (trampolim de chamada distante)."""
        out.append('.org $%04X' % org)
        p = 0
        local = {}
        # primeiro passe: alvos internos
        q = 0
        ins = []
        while q < ln_:
            r = decode(self.prg, o + q, org + q)
            ins.append((q, r)); q += r[0]
        for q, r in ins:
            if r[2] in ('abs', 'rel') and org <= r[3] < org + ln_ and r[3] != org: local[r[3]] = 'FarCall_%04X' % r[3]
        for q, r in ins:
            a = org + q
            if a == org: out.append('    .assert * = FarCall, error, "o trampolim precisa ficar em FarCall"')
            elif a in local: out.append(local[a] + ':')
            n, mn, mode, v = r
            m = mn.lower()
            if mode == 'imp': t = m
            elif mode == 'acc': t = m + ' a'
            elif mode == 'imm': t = '%s #$%02X' % (m, v)
            elif mode in ('abs', 'rel') and v == org: t = '%s FarCall' % m
            elif mode in ('abs', 'rel') and v in local: t = '%s %s' % (m, local[v])
            elif mode == 'abs': t = '%s %s' % (m, HW.get(v, '$%04X' % v))
            else: t = '.byte ' + ','.join('$%02X' % x for x in self.prg[o + q:o + q + n])
            cms = self.comments.get(self.canon(o + q), [])
            raw = ' '.join('%02X' % x for x in self.prg[o + q:o + q + n])
            out.append(('    %-44s; %04X  %-11s %s' % (t, a, raw, ' '.join(cms))).rstrip())
        out.append('.reloc')
        out.append('')

    def generate(self):
        self.ram_used = set()
        self.imports = collections.defaultdict(set)
        self.exports = set()
        self.kernel_imports = set()
        self.ramcode_at = {o: (l, org) for o, l, org in self.ramcode}
        self.build_cond_names()
        os.makedirs(SRC, exist_ok=True)
        files = {}
        # kernel
        kout = []
        self.emit_range(kout, KERNEL_REF, KERNEL_LO, KERNEL_HI, for_kernel=True)
        # bancos
        bank_out = {}
        for b in self.nonempty:
            if b in DPCM_BANKS: continue
            out = []
            base = bank_base(b)
            if b in CODE_BANKS:
                self.emit_range(out, b, base, KERNEL_LO)
                out.append(''); out.append('.assert * = $%04X, error, "o kernel precisa comecar em $%04X"' % (KERNEL_LO, KERNEL_LO))
                out.append('.include "kernel.inc"')
                out.append('')
                self.emit_range(out, b, KERNEL_HI, base + 0x2000)
            else:
                self.emit_range(out, b, base, base + 0x2000)
            bank_out[b] = out
        # rotulos do kernel usados por modulos sem kernel (ex.: banco $00)
        kexports = set()
        for b, names in self.imports.items():
            if b in CODE_BANKS: continue
            for nm in list(names):
                o = self.label_off(nm)
                if o is not None and self.in_kernel(o): kexports.add(nm)
        self.exports -= kexports
        globals_ = sorted(self.exports)
        # --- escreve arquivos
        hdr = '; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.\n' \
              '; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.\n'
        with open(os.path.join(SRC, 'kernel.inc'), 'w') as f:
            f.write(hdr)
            f.write(';\n; KERNEL — codigo identico no fim dos tres bancos de codigo ($37, $3B, $3F): $%04X-$%04X.\n' % (KERNEL_LO, KERNEL_HI - 1))
            f.write('; Contem os tratadores de IRQ (efeitos de raster via contador de scanline do MMC5) e de NMI.\n')
            f.write('; Precisa existir em todo banco que for mapeado em $E000, pois os vetores ficam em $FFFA-$FFFF.\n;\n')
            if kexports:
                f.write('.ifdef KERNEL_EXPORT\n')
                for nm in sorted(kexports): f.write('    .export %s\n' % nm)
                f.write('.endif\n')
            f.write('\n'.join(kout) + '\n')
        for b, out in bank_out.items():
            with open(os.path.join(SRC, 'bank_%02X.s' % b), 'w') as f:
                f.write(hdr)
                kindtxt = 'CODIGO' if b in CODE_BANKS else 'dados'
                f.write(';\n; Banco de PRG $%02X (%s) — janela $%04X-$%04X — offset no arquivo $%06X\n;\n' %
                        (b, kindtxt, bank_base(b), bank_base(b) + 0x1FFF, 16 + (b << 13)))
                f.write('.include "defs.inc"\n')
                if b not in CODE_BANKS:
                    for nm in sorted(n for n in self.imports[b] if n in kexports): f.write('.import %s\n' % nm)
                elif b == KERNEL_REF and kexports:
                    f.write('KERNEL_EXPORT = 1\n')
                f.write('.segment "BANK%02X"\n' % b)
                f.write('\n'.join(out) + '\n')
        with open(os.path.join(SRC, 'globals.inc'), 'w') as f:
            f.write(hdr + '; Simbolos visiveis entre bancos (.global = exporta onde e\' definido, importa nos demais).\n')
            for nm in globals_: f.write('.global %s\n' % nm)
        self.write_ram()
        self.write_static()
        self.write_cfg()
        return bank_out

    def label_off(self, name):
        for o, n in self.labels.items():
            if n == name: return o
        return None

    def write_ram(self):
        # tambem inclui enderecos nomeados nas anotacoes
        used = sorted(self.ram_used | set(self.ramnames))
        with open(os.path.join(SRC, 'ram.inc'), 'w') as f:
            f.write('; GERADO por tools/disasm.py — simbolos de RAM ($0000-$07FF).\n')
            f.write('; Para dar nome a uma variavel: linha `ram <endereco> <nome>` em annotations/sf2ne.ann.\n')
            f.write('; r/w = numero de leituras/escritas observadas no trace.\n\n')
            for a in used:
                r, w = self.ramuse.get(a, (0, 0))
                nm = self.ram_sym(a)
                if '+' in nm:        # apelido do tipo Base+1: nao define simbolo novo
                    f.write('; %-26s  = $%0*X    ; r=%d w=%d\n' % (nm, 2 if a < 0x100 else 4, a, r, w)); continue
                f.write('%-28s := $%0*X    ; r=%d w=%d\n' % (nm, 2 if a < 0x100 else 4, a, r, w))

    def write_static(self):
        with open(os.path.join(SRC, 'hw.inc'), 'w') as f:
            f.write('; Registradores de hardware: PPU, APU/controles e MMC5.\n\n')
            for a in sorted(HW): f.write('%-18s := $%04X\n' % (HW[a], a))
        with open(os.path.join(SRC, 'macros.inc'), 'w') as f:
            f.write(MACROS)
        with open(os.path.join(SRC, 'defs.inc'), 'w') as f:
            f.write('; Definicoes comuns a todos os modulos.\n.setcpu "6502X"     ; o jogo usa o opcode nao-oficial AXS #imm ($CB)\n.include "hw.inc"\n.include "ram.inc"\n.include "macros.inc"\n.include "globals.inc"\n')
        with open(os.path.join(SRC, 'header.s'), 'w') as f:
            h = self.header
            f.write('; Cabecalho NES 2.0: mapper 5 (MMC5), 512K PRG + 512K CHR, sem PRG-RAM.\n.segment "HEADER"\n')
            f.write('    .byte "NES", $1A\n')
            f.write('    .byte $%02X            ; PRG-ROM: %d x 16K\n' % (h[4], h[4]))
            f.write('    .byte $%02X            ; CHR-ROM: %d x 8K\n' % (h[5], h[5]))
            f.write('    .byte $%02X            ; flags 6: mapper (nibble baixo) = %d, espelhamento vertical\n' % (h[6], h[6] >> 4))
            f.write('    .byte $%02X            ; flags 7: NES 2.0\n' % h[7])
            f.write('    .byte ' + ','.join('$%02X' % x for x in h[8:16]) + '   ; byte 12 = $02: multi-regiao\n')
        with open(os.path.join(SRC, 'chr.s'), 'w') as f:
            f.write('; CHR-ROM: 512K = 512 paginas de 1K (o jogo usa o MMC5 em modo CHR 2: paginas de 2K).\n.segment "CHR"\n    .incbin "assets/chr/chr.bin"\n')
        os.makedirs(os.path.join(ROOT, 'assets', 'chr'), exist_ok=True)
        open(os.path.join(ROOT, 'assets', 'chr', 'chr.bin'), 'wb').write(self.chr)
        # bancos de amostras DPCM
        os.makedirs(os.path.join(ROOT, 'assets', 'dpcm'), exist_ok=True)
        for b in sorted(DPCM_BANKS):
            blk = self.prg[b << 13:(b + 1) << 13]
            n = len(blk.rstrip(b'\xFF')) if b != 0x2A else 0x2000
            open(os.path.join(ROOT, 'assets', 'dpcm', 'bank_%02X.dmc' % b), 'wb').write(blk[:n])
            with open(os.path.join(SRC, 'bank_%02X.s' % b), 'w') as f:
                f.write('; Banco de PRG $%02X — amostras DPCM (vozes), mapeado em $C000-$DFFF via $5116.\n' % b)
                f.write('; Veja docs/AUDIO.md para a lista de amostras (endereco/tamanho) dentro do banco.\n')
                f.write('.segment "BANK%02X"\n    .incbin "assets/dpcm/bank_%02X.dmc"\n' % (b, b))

    def write_cfg(self):
        with open(os.path.join(ROOT, 'sf2ne.cfg'), 'w') as f:
            f.write('# GERADO por tools/disasm.py — layout do ROM para o ld65.\n')
            f.write('# 64 bancos de PRG de 8K; o banco n roda na janela (n mod 4). `bank` alimenta a funcao .bank() do ca65.\n')
            f.write('MEMORY {\n    HDR:   file = %O, start = $0000, size = $0010, fill = yes;\n')
            for b in range(64):
                f.write('    PRG%02X: file = %%O, start = $%04X, size = $2000, fill = yes, fillval = $FF, bank = $%02X;\n' % (b, bank_base(b), b))
            f.write('    CHR:   file = %O, start = $0000, size = $80000, fill = yes, fillval = $FF;\n}\nSEGMENTS {\n')
            f.write('    HEADER: load = HDR, type = ro;\n')
            for b in self.nonempty:
                f.write('    BANK%02X: load = PRG%02X, type = ro;\n' % (b, b))
            f.write('    CHR:    load = CHR, type = ro;\n}\n')

    def report(self):
        tot = collections.Counter()
        for b in self.nonempty:
            if b in DPCM_BANKS: continue
            blk = range(b << 13, (b + 1) << 13)
            code = sum(1 for o in blk if self.kind[o] in (OPC, OPR))
            ninst = sum(1 for o in blk if self.kind[o] == OPC)
            ntr = sum(1 for o in blk if self.kind[o] == OPC and self.traced[o])
            data = sum(1 for o in blk if self.kind[o] == DAT and self.prg[o] != 0xFF)
            if code: print('  banco %02X: %5d bytes de codigo (%4d instrucoes, %4d vistas no trace = %3.0f%%), %5d bytes de dados' %
                           (b, code, ninst, ntr, 100.0 * ntr / max(1, ninst), data))
        print('  blocos aceitos so por analise estatica: %d ; rejeitados: %d ; chamadas distantes: %d ; rotulos: %d' %
              (len(self.review), len(self.rejected), len(self.farcalls), len(self.labels)))
        print('  tabelas de salto (RTS-trick): %d ; ilhas de codigo nao referenciado: %d' % (len(self.rts_tables), len(self.islands)))
        print('  ponteiros simbolizados a partir do trace: %d imediatos, %d bytes de dados ; conflitos: %d ; palavras inferidas em tabelas: %d' % (self.ptr_stats[0], self.ptr_stats[1], len(self.ptr_conflicts), len(self.inferred) - getattr(self, 'struct_new', 0)))
        if self.statebanks:
            print('  bancos de estados: %d registros reconhecidos, %d ponteiros completados pela estrutura, %d trechos fora do formato'
                  % (len(self.struct_kind), getattr(self, 'struct_new', 0), len(self.struct_fail)))
        for o in sorted(self.odd_far): print('  AVISO: JMP FarCall fora do padrao em', fmt_off(o))
        for w in sorted(self.warn): print('  AVISO:', w)


MACROS = r'''; Macros do projeto.

FarCall := $049E        ; trampolim de chamada distante (copiado do ROM para a RAM na inicializacao)

; ---------------------------------------------------------------------------------------------------------
; farcall <rotina>
;   Chamada "distante": executa uma rotina que esta em OUTRO banco de codigo (todos rodam em $E000-$FFFF).
;   Empilha o endereco de retorno e o banco atual e pula para o trampolim que fica na RAM (FarCall, $049E),
;   que troca o banco em $5117, chama a rotina, restaura o banco e retorna.
;   A, X e Y sao destruidos na ida (parametros vao por variaveis de pagina zero).
;   O banco de destino e o banco atual sao resolvidos pelo linker (.bank), entao da para mover rotinas.
;   Gera exatamente os mesmos 18 bytes do ROM original.
; ---------------------------------------------------------------------------------------------------------
.macro farcall target
    .local ret
    lda #>(ret-1)
    pha
    lda #<(ret-1)
    pha
    lda #<.bank(ret)
    pha
    lda #<.bank(target)
    ldx #>(target-1)
    ldy #<(target-1)
    jmp FarCall
ret:
.endmacro

; ---------------------------------------------------------------------------------------------------------
; farjmp <rotina>
;   Salto distante (tail-call): igual ao farcall, mas sem empilhar endereco de retorno — quando a rotina
;   de destino retornar, o trampolim restaura o banco atual e volta para QUEM CHAMOU a rotina atual.
;   Gera exatamente os mesmos 12 bytes do ROM original.
; ---------------------------------------------------------------------------------------------------------
.macro farjmp target
    .local here
here:
    lda #<.bank(here)
    pha
    lda #<.bank(target)
    ldx #>(target-1)
    ldy #<(target-1)
    jmp FarCall
.endmacro
'''


def main():
    P = Project()
    P.load_annotations()
    P.load_trace()
    P.analyze()
    P.apply_pointers()
    P.collect_labels()
    P.collect_xrefs()
    P.generate()
    P.report()
    with open(os.path.join(ROOT, 'scratch', 'static_blocks.txt'), 'w') as f:
        f.write('# blocos de codigo aceitos apenas por analise estatica (nao executados no trace)\n')
        for a, b in sorted(P.review): f.write('%s-%04X\n' % (fmt_off(a), off2ba(b)[1]))
        f.write('# entradas rejeitadas\n')
        for a, why in sorted(P.rejected): f.write('%s %s\n' % (fmt_off(a), why))
        f.write('# tabelas de salto via RTS: local tipo lo hi n\n')
        for off, k, lo, hi, n in P.rts_tables: f.write('%s %s lo=%04X hi=%04X n=%d\n' % (fmt_off(off), k, lo, hi, n))
        f.write('# ilhas de codigo nao referenciado\n')
        for a, b in sorted(P.islands): f.write('%s-%04X\n' % (fmt_off(a), off2ba(b)[1]))
    return P


if __name__ == '__main__':
    main()
