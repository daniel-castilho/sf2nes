#!/usr/bin/env python3
"""Censo dos bytes dos quadros de animacao, lendo o ROM diretamente.

Caminha o grafo do banco de estados (tabelas $A000-$A0AF + cadeias +1/+2 e
+3/+4 dos cabecalhos) e imprime estatisticas dos bytes +5..+11 dos quadros:
  +5 -> zp_3A (parametro do efeito)   +6 -> zp_3C (tipo do efeito)
  +7 -> zp_38 (flags)                 +8 -> zp_2E (modo de movimento)
  +9/+10 -> VelX/VelY                 +11 -> desvio (repeticoes)
Uso: frame_census.py [banco=01] [ROM=rom/sf2ne_demo.nes]

Nota: so conta o alcancavel a partir das tabelas de ponteiros e das cadeias
(+1/+2, +3/+4) dos cabecalhos; o gerador (disasm.py) ve o banco inteiro e
inclui os orfaos sem ponteiro -- banco 01 do Ryu: 69 estados/269 quadros
aqui contra 71/274 no `make gen`. Nao e bug.
"""
import re, sys
from collections import Counter, defaultdict

ROM = "rom/sf2ne_demo.nes"
BANK = 0x01

def load(rom):
    data = open(rom, "rb").read()
    base = 0x8000 + (BANK & 3) * 0x2000
    off = 16 + BANK * 0x2000 - base     # addr - base + file offset do inicio do banco
    def rd(addr, n=1):
        o = off + addr
        return data[o:o + n]
    def word(addr):
        b = rd(addr, 2)
        return b[0] | (b[1] << 8)
    return rd, word

def main(bank=1, rom=ROM):
    global BANK
    BANK = bank
    rd, word = load(rom)

    ann = open("annotations/sf2ne.ann").read()
    m = re.search(rf"statebank {bank:02X} frames=\S+ from=([0-9A-Fa-f]+) to=([0-9A-Fa-f]+)", ann)
    lo, hi = int(m.group(1), 16), int(m.group(2), 16)

    states = set()
    frames = {}
    # raizes: as oito tabelas de ponteiros no inicio do banco
    roots = []
    a = 0xA000
    while a < lo:
        roots.append(word(a))
        roots.append(word(a + 8))
        a += 2
    stack = [r for r in dict.fromkeys(roots) if lo <= r <= hi]
    # mais raizes: primeiro estado (from=) e cadeias
    stack.append(lo)
    def walk_frames(start, s):
        f = start
        while f and lo <= f <= hi + 1:
            if f in frames:
                return
            raw = rd(f, 14)
            cond = raw[11]
            full = list(raw) + (list(rd(f + 14, 2)) if cond else [])
            frames[f] = {"bytes": full, "state": s}
            if cond:                                  # ponteiro de desvio: comeca outra cadeia
                br = full[14] | (full[15] << 8)
                if br not in frames and lo <= br <= hi + 1:
                    walk_frames(br, s)
            f = full[12] | (full[13] << 8)

    while stack:
        s = stack.pop()
        if s in states or not (lo <= s <= hi):
            continue
        states.add(s)
        nxt = word(s + 1)                      # +1/+2 proxima alternativa
        if nxt:
            stack.append(nxt)
        end = word(s + 3)                      # +3/+4 estado seguinte
        if end:
            stack.append(end)
        # quadros: cadeia a partir de cabecalho+7
        walk_frames(s + 7, s)

    print(f"banco ${bank:02X}: {len(states)} estados, {len(frames)} quadros"
          " (alcancaveis; o gerador ve o banco inteiro)")
    rows = list(frames.values())
    B = lambda i, r: r["bytes"][i]

    for f_ in (5, 6, 7, 8, 9, 10, 11):
        c = Counter(B(f_, r) for r in rows)
        print(f"\n+{f_}: " + ", ".join(f"${v:02X}x{n}" for v, n in sorted(c.items())))

    print("\nmodo +8 x uso de +9/+10:")
    cross = defaultdict(Counter)
    for r in rows:
        cross[B(8, r)][(B(9, r) != 0, B(10, r) != 0)] += 1
    for mode in sorted(cross):
        print(f"  modo ${mode:02X}: " + ", ".join(f"vx={a},vy={b}: {n}" for (a, b), n in sorted(cross[mode].items())))

    print("\nefeito +6 x parametro +5 (+6 != 0):")
    eff = defaultdict(Counter)
    for r in rows:
        if B(6, r):
            eff[B(6, r)][B(5, r)] += 1
    for t in sorted(eff):
        print(f"  tipo ${t:02X}: params " + ", ".join(f"${v:02X}x{n}" for v, n in sorted(eff[t].items())))

    print("\nflags +7 (bits):")
    fl = Counter()
    for r in rows:
        for bit in range(8):
            if B(7, r) & (1 << bit):
                fl[bit] += 1
    print("  " + ", ".join(f"bit{b} (${1<<b:02X}): {n}" for b, n in sorted(fl.items())))

    coll = Counter()
    for r in rows:
        p = r["bytes"][3] | (r["bytes"][4] << 8)
        coll[p != 0] += 1
    print("\ncaixa de colisao (+3/+4): com ponteiro:", coll[True], "| sem:", coll[False])

    br = Counter()
    for r in rows:
        if B(11, r):
            br[B(11, r)] += 1
    print("desvio +11: " + (", ".join(f"${v:02X}x{n}" for v, n in sorted(br.items())) or "(nenhum)"))

if __name__ == "__main__":
    main(int(sys.argv[1], 16) if len(sys.argv) > 1 else 1,
         sys.argv[2] if len(sys.argv) > 2 else ROM)
