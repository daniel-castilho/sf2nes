#!/bin/bash
# uso: reset_test.sh <rom> <frame_do_reset> <dir_saida>
set -e
MESEN_DIR=${MESEN_DIR:-/tmp/mesen}
export SF2_RESET_AT=$2 SF2_OUT=$3 HOME=$MESEN_DIR/home LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
mkdir -p "$SF2_OUT" "$HOME"
timeout 300 "$MESEN_DIR/Mesen" --testrunner --timeout=240 "$(realpath "$1")" "$(realpath "$(dirname "$0")/reset_test.lua")" > "$SF2_OUT/mesen.out" 2>&1 || echo "mesen exit=$?"
cat "$SF2_OUT/reset.txt"
