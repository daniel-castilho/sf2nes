#!/bin/bash
# Lote de rastreamento de ponteiros (ptrtrace.lua) cobrindo os mesmos caminhos dos lotes 1-3.
cd "$(dirname "$0")"
OUT=${OUT:-/tmp/sf2trace}
TP=""; for f in $(seq 2400 400 14000); do TP="$TP,$f:BB:00"; done; TP=${TP#,}
run() { n=$1; hold=$2; pokes=$3; seed=$4; frames=${5:-14000}; plan=${6:-p1random}
        SF2_SCRIPT=ptrtrace.lua SF2_HOLD="$hold" ./run_trace.sh $plan $frames $seed $OUT/$n 0 "$pokes" > /dev/null 2>&1; echo "done: $n"; }
(
  run ptr_random  ""                                   ""    1 30000
  run ptr_kowin   "0E:30:2200:99999,0F:01:2200:99999"  ""    22
  run ptr_tlose   "0E:10:2200:99999,0F:40:2200:99999"  "$TP" 25
  run ptr_idle    ""                                   ""    35 9000 idle
) &
(
  run ptr_perfect "0E:58:2200:99999,0F:01:2200:99999"  ""    21
  run ptr_draw    "0E:40:2200:99999,0F:40:2200:99999"  "$TP" 24
  run ptr_mixed   "0E:58:2200:3300,0F:01:2200:3300,0E:58:5200:99999,0F:01:5200:99999" "" 27
  run ptr_random2 ""                                   ""    2 30000
  run ptr_p2      ""                                   ""    4 14000 p2join
) &
wait
echo ALL-DONE
