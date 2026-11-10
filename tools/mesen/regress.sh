#!/bin/bash
# Bateria de regressao: compara um ROM com o original em 5 partidas roteirizadas (telas, som e linha do tempo).
# Use depois de qualquer mudanca que NAO deveria alterar o comportamento (mover codigo/dados, renomear, refatorar).
# uso: regress.sh <rom_a_testar> [rom_de_referencia]
#   ex.: tools/shift_test.sh 00 01 04 20 29 2D 36 3C 37 3B 3F && tools/mesen/regress.sh build/shift/sf2ne_shift_00_01_04_20_29_2D_36_3C_37_3B_3F.nes
D=$(dirname "$(realpath "$0")"); S=$(realpath "$1"); O=$(realpath "${2:-$D/../../rom/sf2ne_demo.nes}")
TP=""; for f in $(seq 2400 400 9000); do TP="$TP,$f:BB:00"; done; TP=${TP#,}
fail=0
"$D/compare_roms.sh" "$O" "$S" p1random 12000 3 200 || fail=1                                                   # jogo livre, varias partidas
SF2_HOLD="0E:30:2200:99999,0F:01:2200:99999" "$D/compare_roms.sh" "$O" "$S" p1random 9000 22 200 || fail=1      # P1 vence (KO / tempo)
"$D/compare_roms.sh" "$O" "$S" p1random 9000 7 200 || fail=1                                                    # jogo livre, outra semente
SF2_HOLD="0E:40:2200:99999,0F:40:2200:99999" "$D/compare_roms.sh" "$O" "$S" p1random 9000 24 200 "$TP" || fail=1 # tempo esgotado / empates / round extra
SF2_HOLD="0E:58:2200:3300,0F:01:2200:3300,0E:58:5200:99999,0F:01:5200:99999" "$D/compare_roms.sh" "$O" "$S" p2join 9000 27 200 || fail=1  # perfect, 3 rounds, controle 2
[ $fail = 0 ] && echo "REGRESSAO OK: comportamento identico nas 5 partidas" || { echo "REGRESSAO FALHOU"; exit 1; }
