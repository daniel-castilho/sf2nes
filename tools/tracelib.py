"""Leitura/mesclagem dos traces gerados por tools/mesen/cdl.lua  (e leitura do trace mesclado em trace/)."""
import os, collections, sys
sys.path.insert(0, os.path.dirname(__file__))
from d6502 import OPS, LEN, decode

RAMBASE = 0x1000000
READS = {'LDA','LDX','LDY','ADC','SBC','AND','ORA','EOR','CMP','CPX','CPY','BIT','INC','DEC','ASL','LSR','ROL','ROR'}
DPCM_BANKS = {0x02, 0x06, 0x0A, 0x0E, 0x12, 0x16, 0x1A, 0x1E, 0x22, 0x26, 0x2A}

def bank_base(b):
    """Cada banco de 8K n fica sempre na janela (n mod 4): $8000/$A000/$C000/$E000."""
    return 0x8000 + (b & 3) * 0x2000

def off2ba(o):
    """offset PRG -> (banco, endereco CPU)"""
    b = o >> 13
    return b, bank_base(b) + (o & 0x1FFF)

def ba2off(b, a):
    return (b << 13) | (a & 0x1FFF)

def fmt_off(o):
    if o >= RAMBASE: return 'RAM:%04X' % (o - RAMBASE)
    b, a = off2ba(o)
    return '%02X:%04X' % (b, a)

def parse_ba(s):
    b, a = s.split(':')
    if b == 'RAM': return RAMBASE + int(a, 16)
    return ba2off(int(b, 16), int(a, 16))

class RawTrace:
    """Saida crua de uma ou mais execucoes do cdl.lua."""
    def __init__(self):
        self.opstart = bytearray(0x80000)
        self.dmcread = bytearray(0x80000)
        self.edges = collections.Counter()      # (tipo, from, to) -> n
        self.readers = {}                       # (reader_off, data_off) -> kind
        self.ram = {}                           # addr -> [r, w, set(who)]
        self.regs = collections.defaultdict(collections.Counter)
        self.dmc = collections.Counter()        # (bank, addr, len, rate) -> n

    def load(self, d):
        cdl = open(os.path.join(d, 'cdl.bin'), 'rb').read()
        for i, b in enumerate(cdl):
            if b:
                if b & 2: self.opstart[i] = 1
                if b & 8: self.dmcread[i] = 1
        for ln in open(os.path.join(d, 'edges.txt')):
            t, a, b, n = ln.split()
            self.edges[(t, int(a, 16), int(b, 16))] += int(n)
        for ln in open(os.path.join(d, 'readers.txt')):
            a, b, k = ln.split()
            self.readers[(int(a, 16), int(b, 16))] = int(k)
        for ln in open(os.path.join(d, 'ram.txt')):
            p = ln.split()
            a = int(p[0], 16); r = int(p[1][2:]); w = int(p[2][2:])
            who = set(p[3].split(',')) if len(p) > 3 else set()
            e = self.ram.setdefault(a, [0, 0, set()])
            e[0] += r; e[1] += w; e[2] |= who
        for ln in open(os.path.join(d, 'chr.txt')):
            p = ln.split()
            reg = int(p[0], 16)
            for vn in p[1:]:
                v, n = vn.split(':'); self.regs[reg][int(v, 16)] += int(n)
        fn = os.path.join(d, 'dmc.txt')
        if os.path.exists(fn):
            for ln in open(fn):
                p = ln.split()
                self.dmc[(int(p[0], 16), int(p[1], 16), int(p[2], 16), int(p[3], 16))] += int(p[5])
        return self

    def data_reads(self, prg):
        """Filtra pares leitor->dado, mantendo so leituras 'de verdade' (descarta busca de operando, leituras
        fantasma do 6502 e leituras do canal DMC).  -> dict reader_off -> set(data_off)"""
        by_reader = collections.defaultdict(set)
        for (r, dofs), kind in self.readers.items():
            if r >= RAMBASE: continue
            rb, addr = off2ba(r)
            ins = decode(prg, r, addr)
            if ins is None: continue
            n, mn, mode, v = ins
            db, daddr = off2ba(dofs)
            if rb == db and r <= dofs <= r + 2: continue          # busca dos proprios bytes da instrucao
            if daddr >= 0xFFFA: continue                          # leitura de vetor (interrupcao no meio)
            ok = False
            if mn == 'JMP' and mode == 'ind': ok = daddr in (v, v + 1)
            elif mn in READS:
                if mode == 'abs': ok = (daddr == v)
                elif mode in ('abx', 'aby'): ok = (v <= daddr <= v + 255)
                elif mode in ('izx', 'izy'): ok = db not in DPCM_BANKS     # nao da para distinguir de leitura do DMC
            if ok: by_reader[r].add(dofs)
        return by_reader
