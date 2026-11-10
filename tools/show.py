#!/usr/bin/env python3
"""Mostra uma rotina do fonte gerado.  uso: show.py BB:AAAA [n_linhas]   (ex.: show.py 3F:E5B9 40)"""
import sys, os, re
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
b, a = sys.argv[1].split(':'); n = int(sys.argv[2]) if len(sys.argv) > 2 else 40
a = a.upper()
files = ['kernel.inc'] if b.upper() == 'K' else ['bank_%s.s' % b.upper(), 'kernel.inc']
for fn in files:
    lines = open(os.path.join(root, 'src', fn)).read().split('\n')
    for i, l in enumerate(lines):
        if re.search(r'; %s  ' % a, l):
            s = i
            while s > 0 and (lines[s - 1].startswith(';') or lines[s - 1].endswith(':')): s -= 1
            print('\n'.join(x[:118] for x in lines[s:s + n])); sys.exit(0)
print('nao achei', sys.argv[1])
