#!/bin/bash
# Script para lançar o fceux com a ROM do Ken e input de teclado configurado
# Player 1: Setas = direcional, Z = A, X = B, Right Shift = Select, Enter = Start
# Player 2: WASD = direcional, V = A, B = B, Right Ctrl = Select, Espaço = Start

cd /home/castilho/projects/sf2ne
exec /usr/games/fceux --sound 0 build/sf2ne.nes "$@"
