#!/bin/bash
# lote de traces de cobertura (2 em paralelo)
cd "$(dirname "$0")"
run() { ./run_trace.sh "$@" > /dev/null 2>&1; echo "done: $*"; }
( run p1random 30000 1 /tmp/sf2trace/p1r_s1 600; run p2join 30000 4 /tmp/sf2trace/p2j_s4 600; run idle 14000 1 /tmp/sf2trace/idle 500 ) &
( run p1random 30000 2 /tmp/sf2trace/p1r_s2 600; run p2join 30000 5 /tmp/sf2trace/p2j_s5 600; run p1random 30000 3 /tmp/sf2trace/p1r_s3 600 ) &
wait
echo ALL-DONE
