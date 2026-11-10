#!/bin/bash
# Lote 2 de traces: caminhos que o jogador aleatorio nunca alcanca (vitoria por KO, perfect, time over, empate,
# terceiro round), forcando a energia ($0E/$0F) e o relogio ($BA/$BB) via SF2_HOLD / pokes.
cd "$(dirname "$0")"
OUT=${OUT:-/tmp/sf2trace}
TP=""; for f in $(seq 2400 400 16000); do TP="$TP,$f:BB:00"; done; TP=${TP#,}      # zera a dezena do relogio periodicamente
run() { n=$1; hold=$2; pokes=$3; seed=$4; frames=${5:-16000}; plan=${6:-p1random}
        SF2_HOLD="$hold" ./run_trace.sh $plan $frames $seed $OUT/$n 400 "$pokes" > /dev/null 2>&1; echo "done: $n"; }
(
  run ko_perfect "0E:58:2200:99999,0F:01:2200:99999" ""    21
  run time_win   "0E:58:2200:99999"                  "$TP" 23
  run time_lose  "0E:10:2200:99999,0F:40:2200:99999" "$TP" 25
  run mixed_r3w  "0E:58:2200:3300,0F:01:2200:3300,0E:58:5200:99999,0F:01:5200:99999" "" 27
) &
(
  run ko_win     "0E:30:2200:99999,0F:01:2200:99999" ""    22
  run time_draw  "0E:40:2200:99999,0F:40:2200:99999" "$TP" 24
  run mixed_r3l  "0E:58:2200:3300,0F:01:2200:3300"   ""    26
  run p2_ram     ""                                  ""    28 6000 p2join
) &
wait
echo ALL-DONE
