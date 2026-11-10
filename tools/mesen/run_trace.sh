#!/bin/bash
# uso: [SF2_HOLD=addr:val:de:ate,...] [SF2_RAMDUMP=1] run_trace.sh <plano> <frames> <seed> <dir_saida> [shot_every] [pokes]
# Requer o Mesen 2 (Linux x64) em $MESEN_DIR (padrao /tmp/mesen) — veja docs/FERRAMENTAS.md
set -e
MESEN_DIR=${MESEN_DIR:-/tmp/mesen}
ROM=${ROM:-$(dirname "$0")/../../rom/sf2ne_demo.nes}
export SF2_PLAN=$1 SF2_FRAMES=$2 SF2_SEED=$3 SF2_OUT=$4 SF2_SHOT_EVERY=${5:-300} SF2_POKES=${6:-} SF2_RAMDUMP=${SF2_RAMDUMP:-0} SF2_HOLD=${SF2_HOLD:-}
mkdir -p "$SF2_OUT"
export HOME=$MESEN_DIR/home; mkdir -p "$HOME"
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6   # evita std::bad_cast do MesenCore em modo headless
T=$(( $2 / ${SF2_FPS_MIN:-20} + 120 ))
timeout $((T+30)) "$MESEN_DIR/Mesen" --testrunner --timeout=$T "$(realpath "$ROM")" "$(realpath "$(dirname "$0")/${SF2_SCRIPT:-cdl.lua}")" > "$SF2_OUT/mesen.out" 2>&1 || echo "mesen exit=$?"
ls "$SF2_OUT" | tr '\n' ' '; echo
