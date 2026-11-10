#!/bin/bash
# Roda DOIS ROMs com exatamente as mesmas entradas e compara: screenshots, som (hash das escritas na APU)
# e a linha do tempo das variaveis de estado (modo de tela, rounds, vitorias).
# Serve para provar que uma mudanca "que nao deveria mudar nada" (mover codigo, refatorar, realocar) nao mudou mesmo.
# uso: [SF2_HOLD=...] compare_roms.sh <romA> <romB> <plano> <quadros> <semente> [intervalo=150] [pokes]
set -e
A=$(realpath "$1"); B=$(realpath "$2"); PLAN=$3; FR=$4; SEED=$5; EVERY=${6:-150}; POKES=${7:-}
D=$(dirname "$(realpath "$0")"); T=${TMPDIR:-/tmp}/sf2cmp.$$
( ROM=$A "$D/run_trace.sh" $PLAN $FR $SEED $T/a $EVERY "$POKES" >/dev/null 2>&1 ) &
( ROM=$B "$D/run_trace.sh" $PLAN $FR $SEED $T/b $EVERY "$POKES" >/dev/null 2>&1 ) &
wait
n=0; d=0; first=""
for f in $T/a/shots/*.png; do
  b=$(basename "$f"); n=$((n+1))
  if ! cmp -s "$f" "$T/b/shots/$b"; then d=$((d+1)); [ -z "$first" ] && first=$b; fi
done
som="som identico"; cmp -s $T/a/apu.txt $T/b/apu.txt || { som="SOM DIFERENTE (apu.txt)"; d=$((d+1)); first=${first:-apu.txt}; }
ram="estado final identico"; cmp -s $T/a/timeline.txt $T/b/timeline.txt || { ram="LINHA DO TEMPO DIFERENTE (timeline.txt)"; d=$((d+1)); first=${first:-timeline.txt}; }
if [ "$n" -gt 0 ] && [ "$d" -eq 0 ]; then echo "IGUAIS: $n screenshots identicos, $som, $ram ($PLAN, $FR quadros, semente $SEED)"; rm -rf $T
else echo "DIFERENTES: $d de $n screenshots (primeiro: $first) — veja $T/a e $T/b"; exit 1; fi
