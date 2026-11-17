# Project tools

Everything runs on Linux with `python3` and `cc65`. The emulator (Mesen 2) is only needed to **generate new traces**;
the repository already brings merged traces in `trace/`, so `make gen` and `make` work without it.

```
sudo apt install cc65            # ca65 + ld65
tools/mesen/setup_mesen.sh       # optional: downloads Mesen 2.1.1 and leaves it ready to run headless
```

## Flow overview

```
 rom/sf2ne_demo.nes ──┐
 trace/*.txt ─────────┼──> tools/disasm.py ──> src/*.s, sf2ne.cfg, assets/ ──> ca65/ld65 ──> build/sf2ne.nes
 annotations/sf2ne.ann┘        (make gen)                                        (make)        canonical build (Ken)
```

* What is **code** and what is **data** is not a guess: it comes from real execution in the emulator (`trace/opstarts.txt`),
  completed by static analysis (jump targets, jump tables, never-called routines).
* What is a **pointer** also comes from execution (`trace/pointers.txt`).
* Names, comments, corrections and new data go in `annotations/sf2ne.ann`. **Do not edit `src/` by hand** —
  the generator overwrites it. The exception is a bank declared with `keepbank` (today only `src/bank_05.s`, Ken's
  state bank).

## Makefile

| Command | What it does |
|---------|--------------|
| `make` | assembles `build/sf2ne.nes` (canonical build, with Ken); does not compare with original |
| `make verify` | optional **historical** check: warns if build diverges from original ROM |
| `make gen` | regenerates `src/`, `sf2ne.cfg` and `assets/` from ROM + trace + annotations |
| `make fixed` | assembles `build/sf2ne_fixed.nes` with optional fixes (`-D FIX_SOFT_RESET`) |
| `make fixed FIXDEFS="-D A -D B"` | chooses which `alt` blocks to enable: `FIX_SOFT_RESET`, `FIX_HEAVY_ONCE`, `FIX_EDGE_ATTACK`, `MODE_VERSUS` |
| `make assets` | exports graphics (PNG) and voices (WAV) to `extracted/` |
| `make clean` | deletes `build/` |

## Annotations (`annotations/sf2ne.ann`)

One directive per line. `BB:AAAA` = bank:address; `K:AAAA` = kernel (valid for the three code banks).

| Directive | Effect |
|-----------|--------|
| `label BB:AAAA Nome` | routine or table name |
| `ram AAAA Nome [N]` | variable name (N bytes: `Nome`, `Nome+1`, …) |
| `comment BB:AAAA texto` | comment at end of line |
| `block BB:AAAA texto` | block comment before address (repeat line for multiple) |
| `code BB:AAAA` / `data BB:AAAA-BBBB` | force code / data |
| `table BB:AAAA split lo=… hi=… n=… delta=1` | split jump table (RTS-trick tables are detected on their own) |
| `table BB:AAAA words n=N` | 16-bit pointer table |
| `ptr BB:AAAA lo\|hi BB:TTTT` | manually declare half of a pointer (for what trace did not catch) |
| `imm BB:AAAA <Rotulo` | manually write operand of an immediate instruction (e.g. RAM addresses) |
| `statebank BB frames=BB from=AAAA to=AAAA` | fighter state bank: reads headers and frames by structure |
| `ramcode BB:AAAA TAM ORG` | chunk copied to RAM and executed there (the `FarCall` trampoline) |
| `alt SIMBOLO BB:AAAA TAM` + lines `\|…` | alternative code assembled only with `-D SIMBOLO` (optional fixes). `TAM` is replaced chunk size, **in hexadecimal**, and must fall at the end of an original instruction |
| `patch BB:AAAA XX XX …` | overwrites bytes of reference image before analysis/emission (new data or canonical build fixes); cannot cross bank |
| `keepbank BB` | hand-maintained bank (not generated); ensures segment in `sf2ne.cfg` (today `05`, Ken states) |

After any change: `make gen && make`. Canonical build includes Ken and may diverge from original;
`make verify` performs the optional historical comparison.

An `alt` whose interval contains another `alt` anchor emits the smaller **nested** inside the larger `.else`
branch: thus the smaller remains valid alone and is simply ignored when the larger is enabled.
Two `alt` overlapping only halfway are rejected by the generator (the `.else` would repeat bytes).

## Scripts in `tools/`

| Script | Use |
|--------|-----|
| `disasm.py` | project generator (it is `make gen`). Prints per-bank statistics and warnings. |
| `show.py BB:AAAA [n]` | shows a routine from generated source, with who calls it and which screens it runs on |
| `datamap.py 37,3B,3F [-u] [-m N]` | lists data ranges of a bank and whether they were read (R), typed (T) or never touched (?) |
| `ptr_candidates.py` | immediate pairs that **look like** pointers but trace did not confirm (manual review) |
| `poke_prg.py SAIDA BASE BANCO ADDR BYTE…` | writes `SAIDA` as copy of `BASE` with swapped bytes in bank window (experiments on a copy; original untouched). Shows current value and asks for confirmation (`--force` skips); `- SAIDA BASE` = copy without patch (baseline) |
| `frame_census.py [banco=01] [ROM]` | census of animation frame bytes directly from ROM (effects, flags, modes, collision) — only reachable frames |
| `shift_test.sh <banco> [<banco>…]` | relocation test: inserts 1 byte at start of each listed bank and assembles `build/shift/…` |
| `extract_chr.py`, `extract_dpcm.py` | export graphics and voices (`make assets`) |
| `trace_merge.py rom saida dir…` | merges raw emulator executions into `trace/` |
| `sheet.py out.png colunas escala a.png b.png …` | screenshot contact sheet |
| `d6502.py`, `tracelib.py` | libraries (opcode table, trace reading) |

Each routine in generated source brings two automatic lines:

```
; <- jsr FightersUpdate, tabela StateCondLo          who calls (JSR, JMP, farcall, jump table)
; modos: intro do round, luta                        screens where it executed (ScreenMode)
```

and each code line brings original address and bytes; `(nt)` = never executed in traces.

## Headless emulator (`tools/mesen/`)

Mesen 2 has a `--testrunner` mode that runs a Lua script without opening a window. Details that were hard to discover
and that `setup_mesen.sh` / `run_trace.sh` already solve:

* needs a `settings.json` **next to the executable**, otherwise it opens the configuration wizard and dies;
* `LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6`, otherwise it aborts with `std::bad_cast`;
* `AllowIoOsAccess: true` so Lua can write files; `--timeout=N` (default is 100 s);
* `Nes.Port1/Port2 = NesController`, otherwise `emu.setInput` does nothing.

| Script | What it records |
|--------|-----------------|
| `cdl.lua` | executed code, data reads (with the instruction that read), indirect jumps, RAM use, MMC5 registers, DPCM samples, which screen mode each instruction ran on, screenshots |
| `ptrtrace.lua` | **pointers**, by origin tracing (see below) |
| `reset_test.lua` / `reset_test.sh` | presses RESET at a chosen frame and verifies whether the game restarts |
| `compare_roms.sh A B plano quadros semente` | runs two ROMs with same inputs and compares screens, sound and timeline |
| `regress.sh ROM` | 5-match battery against original (use after changes that should not alter anything) |
| `run_trace.sh <plano> <quadros> <semente> <saida> [shots] [pokes]` | runs one of the above scripts (`SF2_SCRIPT=…`) |
| `batch1.sh`, `batch2.sh`, `batch3.sh`, `batch_ptr.sh` | batches used to generate `trace/` |

Input plans: `attract` (doesn't touch anything), `idle` (enters fight and stays still), `p1random` (P1 random,
including special move commands), `p2join`.

To reach paths a random player doesn't reach (win, perfect, draw, time out, 3rd round) batches force RAM:
`SF2_HOLD="0E:58:2200:99999,0F:01:2200:99999"` keeps P1 energy full and P2 at 1.

Example:

```
cd tools/mesen
./run_trace.sh p1random 6000 7 /tmp/sf2trace/teste 300        # cdl.lua
SF2_SCRIPT=ptrtrace.lua ./run_trace.sh p1random 6000 7 /tmp/sf2trace/ptr_teste 0
cd ../.. && python3 tools/trace_merge.py rom/sf2ne_demo.nes trace /tmp/sf2trace/*   # merges everything again
make gen && make
```

(`trace_merge.py` rewrites `trace/` with what it receives: always pass **all** executions.)

## How pointers are discovered (`ptrtrace.lua`)

A disassembly that assembles identically can still be "rigid": just an `lda #$8C / ldx #$F9` (address `$F98C`
written as two numbers) breaks the game when something moves.

`ptrtrace.lua` tracks, for A/X/Y and for each RAM byte, **which ROM byte the value came from** (immediate
operand or data read from table). When the game reads ROM via `(zp),y`, or does `RTS` to a manually stacked
address, the two origin bytes are certainly the halves of a pointer — and the read address tells where it points.
The generator then replaces numbers with symbols:

```
    lda #<RleSupportScreen        ; era  lda #$8C
    ldx #>RleSupportScreen        ; era  ldx #$F9
    .word D01_A0F6                ; era  .byte $F6,$A0
```

Limit: it only sees what was executed. What is missing is covered by two generator complements — table entries
squeezed between confirmed pointers and structural reading of the state bank (`statebank`) — and by
`tools/ptr_candidates.py`, which lists suspicious immediate pairs by default for manual review.

## Relocation test

```
tools/shift_test.sh 00 01 04 20 29 2D 36 3C 37 3B 3F      # shifts the 11 code and data banks
tools/mesen/regress.sh build/shift/sf2ne_shift_00_01_04_20_29_2D_36_3C_37_3B_3F.nes
# -> REGRESSAO OK: comportamento identico nas 5 partidas      (~8 minutos)
```

If this ever fails after new traces or annotations, `compare_roms.sh` leaves screenshots of the two ROMs
side by side in the temporary directory it reports: the first different frame shows where to look.
