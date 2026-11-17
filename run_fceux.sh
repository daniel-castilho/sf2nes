#!/bin/bash
# Script to launch fceux with Ken's ROM and keyboard input configured
# Player 1: Arrows = d-pad, Z = A, X = B, Right Shift = Select, Enter = Start
# Player 2: WASD = d-pad, V = A, B = B, Right Ctrl = Select, Space = Start

cd /home/castilho/projects/sf2ne
exec /usr/games/fceux --sound 0 build/sf2ne.nes "$@"
