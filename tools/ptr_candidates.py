#!/usr/bin/env python3
"""Procura, por PADRAO, pares de imediatos que parecem ponteiros para o ROM e que o trace NAO confirmou
(codigo nunca executado, ou ponteiro usado de um jeito que o ptrtrace.lua nao enxerga).
Nao altera nada: so lista candidatos para revisao. Para aceitar um, use `imm BB:AAAA <Rotulo` / `>Rotulo`
em annotations/sf2ne.ann.   uso: ptr_candidates.py"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from disasm import *

def main():
    P = Project(); P.load_annotations(); P.load_trace(); P.analyze(); P.apply_pointers(); P.collect_labels()
    import collections
    P.imports = collections.defaultdict(set); P.exports = set(); P.kernel_imports = set(); P.ram_used = set()
    done = set(P.immsym) | set(P.immtext)
    far = set()
    for st, fc in P.farcalls.items(): far.update(range(st, st + fc[2]))
    out = []
    offs = sorted(o for o in P.ins if not (P.in_kernel(o) and (o >> 13) != KERNEL_REF) and o not in far)
    nxt = {a: b for a, b in zip(offs, offs[1:])}
    LOAD = {'LDA': 'A', 'LDX': 'X', 'LDY': 'Y'}; STORE = {'STA': 'A', 'STX': 'X', 'STY': 'Y'}
    for o in offs:
        r = P.ins[o]
        if r[1] not in LOAD or r[2] != 'imm' or o in done: continue
        # padrao 1: carga #a / grava zp ; carga #b / grava zp+-1
        o2 = nxt.get(o); o3 = nxt.get(o2) if o2 else None; o4 = nxt.get(o3) if o3 else None
        cands = []
        if o2 and o3 and o4:
            r2, r3, r4 = P.ins[o2], P.ins[o3], P.ins[o4]
            if r2[1] in STORE and r3[1] in LOAD and r3[2] == 'imm' and r4[1] in STORE and r2[2] in ('zp', 'abs') and r4[2] in ('zp', 'abs') \
               and STORE[r2[1]] == LOAD[r[1]] and STORE[r4[1]] == LOAD[r3[1]] and o3 not in done:
                if r4[3] == r2[3] + 1: cands.append((o, o3, r[3] | (r3[3] << 8), 'grava em $%02X/$%02X' % (r2[3], r4[3])))
                if r4[3] == r2[3] - 1: cands.append((o3, o, r3[3] | (r[3] << 8), 'grava em $%02X/$%02X' % (r4[3], r2[3])))
        # padrao 2: dois registradores carregados e em seguida jsr/jmp
        if o2 and o3:
            r2, r3 = P.ins[o2], P.ins[o3]
            if r2[1] in LOAD and r2[2] == 'imm' and r2[1] != r[1] and r3[1] in ('JSR', 'JMP') and o2 not in done:
                order = {'A': 0, 'X': 1, 'Y': 2}
                a, b = (o, o2) if order[LOAD[r[1]]] < order[LOAD[r2[1]]] else (o2, o)
                cands.append((a, b, P.ins[a][3] | (P.ins[b][3] << 8), 'argumentos de %s %s' % (r3[1].lower(), P.fmt_ins(o3, r3).split()[-1])))
        for lo, hi, val, why in cands:
            if val < 0x8000: continue
            # o alvo existe como inicio de dado/rotulo em algum banco daquela janela?
            hits = []
            for b in range(64):
                if bank_base(b) != (val & 0xE000): continue
                t = ba2off(b, val)
                if P.canon(t) in P.labels: hits.append(P.labels[P.canon(t)])
            tr = any(P.traced[x] for x in P.kernel_copies(o))
            out.append('%s / %s  -> $%04X  %-34s %s  rotulos nesse endereco: %s' % (
                fmt_off(lo), fmt_off(hi), val, why, 'executado' if tr else 'NUNCA executado', ', '.join(hits) or '-'))
    print('\n'.join(out))
    print('# %d candidatos' % len(out))

if __name__ == '__main__':
    main()
