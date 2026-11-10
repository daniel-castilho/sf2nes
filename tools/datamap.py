#!/usr/bin/env python3
"""Lista, por banco, as faixas que ficaram como DADOS e se foram lidas (R) ou nao (?) no trace."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from disasm import *

def main(banks, only_unknown=False, minlen=1):
    P = Project(); P.load_annotations(); P.load_trace(); P.analyze(); P.apply_pointers()
    read = bytearray(0x80000)
    for r, rgs in P.readers.items():
        for o1, o2 in rgs:
            for o in range(o1, o2 + 1): read[o] = 1
    for b in banks:
        print('== banco %02X ==' % b)
        o = b << 13; end = (b + 1) << 13
        def ffrun(o): return P.prg[o] == 0xFF and all(x == 0xFF for x in P.prg[o:min(o + 16, end)])
        while o < end:
            if P.kind[o] != DAT or ffrun(o): o += 1; continue
            s = o; flag = read[o]
            while o < end and P.kind[o] == DAT and read[o] == flag and not ffrun(o) and (o == s or P.canon(o) not in P.typed or P.canon(s) in P.typed): o += 1
            n = o - s
            if (only_unknown and flag) or n < minlen: continue
            ty = 'T' if P.canon(s) in P.typed else ('R' if flag else '?')
            print('  %s %04X-%04X (%4d) %s%s' % (ty, off2ba(s)[1], off2ba(o - 1)[1], n, P.prg[s:s + min(n, 28)].hex(' '), ' ..' if n > 28 else ''))

if __name__ == '__main__':
    banks = [int(x, 16) for x in sys.argv[1].split(',')]
    main(banks, only_unknown='-u' in sys.argv, minlen=int(sys.argv[sys.argv.index('-m') + 1]) if '-m' in sys.argv else 1)
