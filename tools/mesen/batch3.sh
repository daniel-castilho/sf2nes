#!/bin/bash
# Lote 3: repete execucoes representativas com o cdl.lua v4, que marca em que modo de tela ($B0) cada instrucao rodou.
cd "$(dirname "$0")"
OUT=${OUT:-/tmp/sf2trace}
TP=""; for f in $(seq 2400 400 12000); do TP="$TP,$f:BB:00"; done; TP=${TP#,}
run() { n=$1; hold=$2; pokes=$3; seed=$4; frames=${5:-12000}; plan=${6:-p1random}
        SF2_HOLD="$hold" ./run_trace.sh $plan $frames $seed $OUT/$n 0 "$pokes" > /dev/null 2>&1; echo "done: $n"; }
(
  run m_random  ""                                   ""    31
  run m_kowin   "0E:30:2200:99999,0F:01:2200:99999"  ""    32
  run m_idle    ""                                   ""    35 9000 idle
) &
(
  run m_draw    "0E:40:2200:99999,0F:40:2200:99999"  "$TP" 33
  run m_mixed   "0E:58:2200:3300,0F:01:2200:3300,0E:58:5200:99999,0F:01:5200:99999" "" 34
  run m_p2      ""                                   ""    36 9000 p2join
) &
wait
echo ALL-DONE
