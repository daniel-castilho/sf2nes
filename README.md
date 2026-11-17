# Street Fighter II NE (DEMO, Parisoft) — reconstructed source code

**Remontable** disassembly of the NES demo `Street Fighter II – Nostalgic Edition`, made for study and to
continue the game. The source is 6502 assembly for `ca65` (the same tool the author uses).

```
make          # builds build/sf2ne.nes (canonical build: modified ROM, with Ken playable)
make verify   # optional HISTORICAL check: compares the build with the original ROM
make fixed    # builds build/sf2ne_fixed.nes with the soft reset freeze fix
make fixed FIXDEFS="-D FIX_SOFT_RESET -D MODE_VERSUS"   # same + versus mode (P2 on controller 2)
make fixed FIXDEFS="-D FIX_SOFT_RESET -D FIX_HEAVY_ONCE"   # same + strong attack without repetition (experimental)
make prontos  # rebuilds the three playable variants in prontos/
make assets   # exports graphics (PNG) and the 31 voices (WAV) to extracted/
make gen      # regenerates src/ after editing annotations/sf2ne.ann
```

Requirements: `python3` and `cc65` (`sudo apt install cc65`). The emulator is only needed to generate new traces.

## What is ready (and verified)

| | |
|---|---|
| **Historical reconstruction** | The original reconstruction (without Ken's `patch`s) reproduces the 1,048,592-byte ROM; SHA-1 `0bf9dc57…a9aed`. `make verify` performs this check and warns that the Ken build diverges. |
| **Ken playable (P1)** | Selectable with A (red) or B (blue), fights against Ryu CPU. Column 0 (Ryu) remains byte-for-byte untouched. The freeze on special moves was diagnosed and fixed (2 bytes in the AI anti-air dispatch); the step-by-step is in [`docs/lessons.md`](docs/lessons.md). Complete moveset and manual acceptance still pending. |
| **Relocatable** | All 11 code and data banks shifted by 1 byte at once (44,892 different bytes) → the game runs **identical to the original**: same screens, same sound, same result, in 5 test matches of 9,000–12,000 frames. That is: code and data can be inserted and removed. |
| **Code × data** | Separation taken from real emulator execution (7,805 instructions seen in 28 scripted matches) + static analysis. Coverage per bank: `$00` 96%, `$37` 83%, `$3B` 98%, `$3F` 86%. |
| **Symbolic pointers** | 114 immediate pairs and 2,550 bytes of data discovered by source tracing in the emulator; plus 187 completed by table structure. |
| **Structure understood** | cartridge and MMC5 map, IRQ/NMI kernel, inter-bank calls, screen flow, fight loop, sound (FamiTone2), voice directory, character fiche, **state bank format** (71 states, 274 frames). |
| **Bugs** | soft reset freeze: cause found, fixed (14 bytes per bank) and tested. Command delay and repetition: cause found and measured (`InputButtons`). |
| **Findings** | the engine already runs **2 players** — just needs connecting (option `MODE_VERSUS`, 1 byte); the planned roster of 10 fighters, with names and phrases, is in the ROM; Ken has 4.3 KB of frames ready now integrated into bank `$05`; versus and single player modes work. |

Read in this order:

1. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — how the game works internally.
2. [`docs/RAM.md`](docs/RAM.md) — known variables.
3. [`docs/BUGS.md`](docs/BUGS.md) — reported bugs: what is resolved and where the others are.
4. [`docs/ROADMAP.md`](docs/ROADMAP.md) — the path to finishing the game, and how to use AI without fooling yourself.
5. [`docs/TOOLS.md`](docs/TOOLS.md) — scripts, annotation format, headless emulator.
6. [`docs/lessons.md`](docs/lessons.md) — lessons learned: how Ken's freeze on special moves was diagnosed and fixed (symptom, PC trace, root cause, fix and verification) and what the data naming batches (`$3C`, `$3F` and `$20`) taught about table reading, metasprites and metrics.

## What is still **not** ready

**Current focus — stabilization and maintainability.** Implementation of new characters and gameplay features is paused, not cancelled. Phase 3 naming was closed on 2026-11-16 (`tasks/PHASE_3_EXECUTION_REPORT.md` §10); 1,135 automatic data labels remain, kept as P3/opaque backlog in `tasks/DATA_LABEL_INVENTORY.tsv`. The next work cycle will be defined from `tasks/NAMING_CANDIDATES.md`, `docs/PROJECT_STATUS.md` and `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.

There are 2,145 label definitions (2,141 unique names): **1,006 semantic** and **1,135 automatic data labels**
  (`D01_A4CB`…). **No automatic code labels remain** (`L3F_E4DA`…): the P0/P1, P2 and FamiTone2 batches of Phase 3 named the 379 that existed. The `$3C` (33), `$3F` (15) and `$20` (30) data batches already named fiches, palettes, portraits, the fight core and HUD/effects (`tasks/DATA_NAMING_3C.md`, `tasks/DATA_NAMING_3F.md`, `tasks/DATA_NAMING_20.md`); the remaining 1,135 are inventoried in
  `tasks/DATA_LABEL_INVENTORY.tsv`.
  Of the variables, 78 are named. The Phase 3 inventory is in `tasks/NAMING_CANDIDATES.md`.
* **Partially documented data formats:** metasprites and states are understood; collision boxes,
  bytes 5–10 of the animation frame, AI script opcodes and transition conditions are not yet documented.
* **Code never executed** (14–17% of banks `$37` and `$3F`): came from static analysis. These are mostly
  unused FamiTone2 resources and rare engine branches. It's disassembled but not exercised.
* **Voices:** the sample directory keeps address/64; moving a sample requires manually editing the table.

## Organization

```
rom/sf2ne_demo.nes        original ROM (reference for verification)
annotations/sf2ne.ann     NAMES, COMMENTS and FIXES — the file you edit
trace/                    what the emulator observed (code, reads, pointers, screen modes…)
src/                      GENERATED ca65 source (one file per bank + kernel.inc, ram.inc, hw.inc, macros.inc)
assets/                   CHR and voice banks, included with .incbin
tools/                    generator, extractors, tests; tools/mesen/ = emulator scripts
docs/                     documentation
extracted/                PNGs and WAVs (make assets)
prontos/                  assembled ROMs ready to play: reset fix, versus, strong attack once
ref/                      public libraries from the author (familib, pa65, yanct) for comparison
build/                    assembly output (do not version)
```

## Workflow

**Current phase — stabilization and maintainability (documentation only).** No new character or gameplay feature is being implemented in this phase. `src/` remains generated from `annotations/sf2ne.ann`; do not edit by hand. The next implementation phase will be defined after the Phase 1 documentation audit.

```
tools/show.py 3F:E4DA 60          # reads a routine (shows who calls it and on which screens it runs)
$EDITOR annotations/sf2ne.ann     # label / ram / comment / block / patch / keepbank ...
make gen && make                  # regenerates src/ and builds the canonical build
make verify                       # optional: checks the historical reconstruction against the original ROM
```

Changes in generated banks (Ken fiche, palette, selection and AI stub) are declared as `patch` in the
annotations, at offset **+1** from the character column; thus `make gen` does not erase Ken and Ryu's column 0
remains untouched.

**Next phase — modification.** When you want to really change the game (not just fix in place), there are three paths:

* small optional changes: `alt` blocks in annotations (like the reset fix was made) and
  `make fixed` builds the variant;
* new data or fixes that must enter the canonical build: `patch` directives (bytes) and `keepbank` (source
  kept by hand) in annotations — this is how Ken's fiche, palette, selection and AI stub are connected;
* large changes that don't go through the generator: freeze the bank in `src/` and edit it by hand, as in
  `src/bank_05.s`; in that case the test stops being "identical to the original" and becomes
  `tools/mesen/compare_roms.sh` (same inputs, same screens and sound) for everything that **should not** change.

## Usage

Study project, for personal use. The ROM and extracted data belong to their authors.

## Ken Implementation — Phase 6: Delivery

### Current Status

Ken's implementation is divided into 6 phases as specified in `tasks/KEN_IMPLEMENTATION_SPEC.md`:

| Phase | Achievement | Status |
|-------|-------------|--------|
| **Phase 1** | Relocatable bank at $A000-$BFFF with 10 defined states | ✅ Completed |
| **Phase 2** | States with headers and frames using sprites from bank $04 | ✅ Completed |
| **Phase 3** | Column 1 (Ken) connected to D05_A10B | ✅ Completed |
| **Phase 4** | Ken selectable, CPU remains Ryu in single player | ✅ Completed |
| **Phase 5** | Build produces modified ROM without byte-by-byte comparison | ✅ Completed |

### Modified Files

- `src/bank_05.s`: Relocatable state bank at $A000-$BFFF with 10 states
- `src/bank_3C.s`: Column 1 (Ken) changed from $00 to $05
- `src/globals.inc`: D05_ symbols exported for cross-bank linking
- `sf2ne.cfg`: Already contained BANK05 segment

### Build and ROM

```
make clean && make
# SHA1: 843a869e6f61c076ae1f8cfbd0b6cea073c164f6
```

### Variants

- **Versus mode, P1/P2=Ken**: Game uses bank $05 states + bank $04 graphics
- **Single player**: CPU remains Ryu (native behavior)
- **Special moves**: Hadouken, Shoryuken, Tatsumaki structured in bank $05

### Limitations

- Structural implementation (Phases 1-5): complete gameplay still requires Phases 5-6
- No Ken-specific AI: In single player, the opponent remains Ryu
- No automated tests: Manual acceptance recommended

### Delivered ROM Hash

`843a869e6f61c076ae1f8cfbd0b6cea073c164f6`
