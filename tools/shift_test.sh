#!/bin/bash
# Teste de "relocabilidade": desloca TODO o conteudo de um banco de codigo em 1 byte (insere um byte no inicio e tira
# um do enchimento antes do kernel) e monta build/shift/sf2ne_shift_<banco>.nes.
# Se o disassembly estiver 100% simbolico naquele banco, o jogo roda igual. Qualquer ponteiro que tenha ficado como
# numero cru (em tabelas de dados, por exemplo) aparece como diferenca de comportamento.
# uso: tools/shift_test.sh <banco> [<banco> ...]      ex.: shift_test.sh 3F   |   shift_test.sh 37 3B 3F   |   shift_test.sh 01
# (serve tambem para bancos de dados; nesses o teste mostra ponteiros ainda nao simbolizados dentro dos dados)
set -e
cd "$(dirname "$0")/.."
B=$(echo "$*" | tr ' ' '_'); [ "$1" = all ] && set -- 37 3B 3F
W=build/shift/$B; rm -rf $W; mkdir -p $W/src
cp src/* $W/src/
shift_bank() {   # $1 = banco
  f=$W/src/bank_$1.s
  python3 - "$f" "$1" <<'PY'
import sys, re
f, bank = sys.argv[1], sys.argv[2]
s = open(f).read()
s = s.replace('.segment "BANK%s"\n' % bank, '.segment "BANK%s"\n    .byte $EA        ; <-- byte inserido pelo shift_test\n' % bank, 1)
# tira 1 byte do ultimo enchimento de $FF antes do kernel
k = s.index('.include "kernel.inc"') if '.include "kernel.inc"' in s else len(s)   # bancos de dados: usa o enchimento final
m = list(re.finditer(r'\.res (\d+), \$FF', s[:k]))
if m and int(m[-1].group(1)) > 1:
    a, b = m[-1].span(1); s = s[:a] + str(int(m[-1].group(1)) - 1) + s[b:]
else:
    i = s.rindex(',$FF', 0, s.index('.ifdef FIX_SOFT_RESET')); s = s[:i] + s[i + 4:]
open(f, 'w').write(s)
PY
}
for x in "$@"; do shift_bank $x; done
for s in $W/src/*.s; do ca65 -I $W/src --bin-include-dir . "$s" -o $W/$(basename "$s" .s).o; done
ld65 -C sf2ne.cfg $W/*.o -o build/shift/sf2ne_shift_$B.nes
echo "ok: build/shift/sf2ne_shift_$B.nes ($(cmp -l build/shift/sf2ne_shift_$B.nes rom/sf2ne_demo.nes | wc -l) bytes diferentes do original)"
