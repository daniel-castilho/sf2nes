# Project Status — audit (Phase 1) and Phase 3 update

> **Reading note:** sections 1–10 preserve the Phase 1 static audit, performed on `ada6c6f`. **Section 11** records the status after Phase 3 naming batches (Gate D, P2, PAD, FamiTone2 and `$3C`/`$3F`/`$20` data), closed on 2026-11-16, with reconciled metrics. Where the two views diverge, section 11 prevails for current status.

## 1. Audit metadata and limitations

- **Audit date:** 2026-11-15
- **Commit HEAD examined:** `ada6c6fa5b26cb63119a0bdad8521966740dc64d` (Phase 0 completed and accepted, pushed to `origin/main`)
- **Working tree status:** clean (no uncommitted local modifications; the only untracked file is `tasks/PHASE_1_BASELINE_AUDIT_SPEC.md`, which is this audit's input file)
- **Pre-existing local changes preserved:** yes, no change was discarded
- **Activities NOT performed in this audit:** no assembly (`make`, `ca65`, `ld65`), no ROM execution, no emulation (Mesen/MAME), no testing, no validation/regression/shift/relocation scripts, no artifact generation (ROM, map, trace, video)

This document was produced exclusively by **static inspection** of source files and documentation. No claim of "tested", "passes" or "currently works" is made without existing and identifiable evidence.

## 2. Executive summary

Facts confirmed by static inspection in this audit:

- The repository contains the reconstructed source of the NES demo *Street Fighter II NE* (mapper 5/MMC5, 512 KB PRG-ROM, 512 KB CHR-ROM).
- The build flow is `annotations/sf2ne.ann` → `tools/disasm.py` (`make gen`) → `src/*.s` → `ca65`/`ld65` (`make`) → `build/sf2ne.nes`.
- The canonical build includes playable Ken (P1) and diverges from the original ROM; `make verify` warns by design.
- **2,145 label definitions** were identified in `src/bank_*.s` files, generating **2,140 unique names** (5 duplicate occurrences of 4 names, being 1 name duplicated within the same bank).
- Of these, **1,084 are semantic labels** (assigned name, not automatic address pattern) and **1,056 are automatic data labels** (`D<bb>_<aaaa>`); **no automatic code labels remain** (`L<bb>_<aaaa>`). *Metric updated after P0/P1, P2, PAD, FamiTone2 batches and data `$3C`, `$3F`, `$20`, `$36`, `$3B` and `$37` batches; the total number of definitions did not change — 2,145 — because renames neither create nor remove labels.*
- There are **322 `.global` directives** in `src/globals.inc` (symbols visible between banks).
- PRG bank occupancy is known only from values published in documentation (not revalidated in this audit — no build or linker map was produced).
- Validation scripts exist in `tools/` and `tools/mesen/`; none were executed in this audit, so no approval claim is made.

Items not confirmed (require build/execution/inspection outside scope):

- Real bank occupancy from a new linker map.
- Operation of any validation script (status unknown or only historical).
- Document divergences (registered in section 7, not corrected).

## 3. Sources of truth and generated artifacts

| Area | Declared canonical source | Generated/derived file/artifact | Current update method | Observation/risk |
|------|---------------------------|---------------------------------|----------------------|------------------|
| Labels, comments, fixes | `annotations/sf2ne.ann` | `src/*.s` (via `make gen`) | Manual `.ann` edit + regeneration | Generator overwrites `src/`; do not edit `src/` by hand |
| Generator | `tools/disasm.py` | `src/*.s`, `sf2ne.cfg`, `assets/chr/chr.bin`, `assets/dpcm/*.dmc` | `python3 tools/disasm.py` (`make gen`) | Reads ROM + trace + annotations |
| Config and build | `sf2ne.cfg`, `Makefile` | `build/sf2ne.nes`, `build/sf2ne_fixed.nes`, `prontos/*.nes` | `ca65` + `ld65` (`make`, `make fixed`, `make prontos`) | `build/` is not versioned |
| State/frame data structures | `annotations/sf2ne.ann` + `docs/FORMATS.md` | `src/bank_01.s` (Ryu states), `src/bank_05.s` (Ken states, hand-maintained) | `patch`/`keepbank` in annotations | Only Ryu and Ken have content; other 8 characters only portrait/name/quote/voice |
| Source assets vs `extracted/` | `assets/chr/chr.bin`, `assets/dpcm/*.dmc` | `extracted/chr/*.png`, `extracted/dpcm/*.wav` | `make assets` (`tools/extract_chr.py`, `tools/extract_dpcm.py`) | Production content export |
| Reference ROM | `rom/sf2ne_demo.nes` | (no derived versioned beyond `prontos/`) | SHA-1 `0bf9dc57…a9aed` declared in `Makefile` and `docs/ARCHITECTURE.md` | `make verify` compares build with original (warning by design) |
| Versioned output ROMs | `build/sf2ne.nes` (not versioned) | `prontos/sf2ne_reset_corrigido.nes`, `prontos/sf2ne_versus.nes`, `prontos/sf2ne_golpe_forte_unico.nes`, `prontos/sf2ne_golpe_na_borda.nes` | `make prontos` | Historical versions, without canonical Ken build |
| Trace/validation scripts and artifacts | `tools/`, `tools/mesen/`, `trace/` | `trace/*.txt` (merged traces) | Emulator execution (outside this audit's scope) | Merged traces already exist in repository |

**Observation/risk:** when documents disagree about the canonical source, the divergence is registered in section 7; no new source was chosen by inference.

## 4. Label metrics

### Reproducible method

- **Files analyzed:** all `src/bank_*.s` (26 generated code/data bank files). `.inc` files (`kernel.inc`, `globals.inc`, `ram.inc`, `defs.inc`, `hw.inc`, `macros.inc`) contain only `.global` directives and RAM/hardware definitions, no code/data labels per bank.
- **Command/script used:** textual inspection with `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s` (lines starting with a label followed by `:`).
- **Patterns identified in generator:**
  - Automatic code: `L<bb>_<aaaa>` (e.g. `L3F_E4DA`, `L00_8F46`).
  - Automatic data: `D<bb>_<aaaa>` (e.g. `D37_E1BD`, `D01_A4CB`).
  - Semantic: global label that **does not** match either automatic pattern above.
- **Exclusions:** local/temporary labels, anonymous labels, constants and RAM symbols (`ram.inc`) are outside the main metric of code/data labels per bank.

### Results by category

| Category | Unique names | Observations |
|----------|--------------|--------------|
| Total label definitions in `src/bank_*.s` | 2,145 occurrences | Counts each definition, including duplicates between banks |
| Globally unique names | 2,140 | 5 fewer than total (4 duplicate names) |
| Automatic code (`L<bb>_<aaaa>`) | **0** | Was 379 in Phase 1; zeroed by P0/P1, P2 and FamiTone2 batches |
| Automatic data (`D<bb>_<aaaa>`) | 1,056 unique | Pattern confirmed in generator; 33 renamed in `$3C`, 15 in `$3F`, 30 in `$20`, 27 in `$36`, 35 in `$3B` and 17 in `$37` |
| **Semantic (assigned name)** | **1,084 unique** | Global non-automatic labels (549 in Phase 1) |
| `.global` directives in `src/globals.inc` | 322 unique | Symbols visible between banks (subset of semantic) |

### Detail by bank (unique names)

| Bank | Total defs | Unique | Auto code (L) | Auto data (D) | Semantic |
|------|------------|--------|---------------|---------------|----------|
| `$00` | 257 | 257 | 0 | 206 | 51 |
| `$01` | 305 | 305 | 0 | 304 | 1 |
| `$04` | 3 | 3 | 0 | 3 | 0 |
| `$05` | 353 | 353 | 0 | 352 | 1 |
| `$08`, `$0C`, `$10`, `$1C`, `$24` | 5 | 5 | 0 | 5 | 0 |
| `$20` | 30 | 30 | 0 | 0 | 30 |
| `$29` | 103 | 103 | 0 | 103 | 0 |
| `$2D` | 70 | 70 | 0 | 70 | 0 |
| `$36` | 30 | 30 | 0 | 3 | 27 |
| `$37` | 277 | 277 | 0 | 10 | 267 |
| `$3B` | 263 | 263 | 0 | 0 | 263 |
| `$3C` | 38 | 38 | 0 | 0 | 38 |
| `$3F` | 411 | 410 | 0 | 0 | 411 |
| Others ($02,$06,$0A,$0E,$12,$16,$1A,$1E,$22,$26,$2A,$3A) | 0 | 0 | 0 | 0 | 0 |
| **Total** | **2,145** | **2,144**¹ | **0** | **1,056** | **1,089**¹ |

¹ Sum per bank. Globally there are **2,140 unique names** and **1,084 unique semantic**: `ResetStub` appears in three banks (`$37`, `$3B`, `$3F`), `ResetVectorFill` in two (`$37`, `$3B`), `RoundStart` in two (`$3B`, `$3F`) and `InputButtons` twice within `$3F`. The canonical regex also does not count three semantic labels with comment on same line (`EdgeARel`, `EdgeBRel`, `EdgeBBtn`); including them would raise per-bank sum to 1,092 and total unique to 1,087.

> No bank has automatic code labels anymore; the remaining 1,056 automatics are all data (`D<bb>_<aaaa>`).

### Rules applied and limitations

- The README historical number ("1,795 labels; 304 have real names") was replaced in Phase 3; counts above were recalculated from generated sources and README now publishes the canonical metric.
- Overlapping categories were not summed; total label count is not used as a single quality measure.
- Label `InputButtons` is duplicated inside `src/bank_3F.s` (2 definitions, 1 unique name). Labels `ResetStub` (banks `$37`, `$3B`, `$3F`), `ResetVectorFill` (banks `$37`, `$3B`) and `RoundStart` (banks `$3B`, `$3F`) appear in multiple banks; counted as 1 unique name each globally.
- Phase 1 audit did not rename labels. In Phase 3, P0/P1, P2, PAD and FamiTone2 batches renamed 388 labels and data `$3C`, `$3F`, `$20`, `$36`, `$3B` and `$37` batches renamed another 157 — **545 total** (see section 11, `tasks/NAMING_CANDIDATES.md` and `tasks/PHASE_3_EXECUTION_REPORT.md` §10), without altering any byte.
- No permanent tool was created or modified in `tools/` in this phase.

## 5. Bank map and documented capacity

The values below are **published in documentation (`docs/ARCHITECTURE.md` §7), not revalidated in this audit**. No build was compiled, no linker map produced, no occupancy recalculated from a new link.

| Bank | Window | Content | Bytes used (documented) | Validation status |
|------|--------|---------|-------------------------|-------------------|
| `$00` | `$8000` | Ryu: metasprites, AI scripts, `RyuAiThink`, collision boxes | 5.2 KB | Documented, not revalidated |
| `$01` | `$A000` | Ryu: states/animations | 4.5 KB | Documented, not revalidated |
| `$04` | `$8000` | Ken: frames/metasprites/collisions + portrait; AI stub at `$90E0` | 4.3 KB | Documented, not revalidated |
| `$05` | `$A000` | Ken: states/animations (hand-written source; original all `$FF`) | 4.5 KB | Documented, not revalidated |
| `$08 $0C $10 $1C $24` | `$8000` | Selection portraits | ~50 each | Documented, not revalidated |
| `$20` | `$8000` | HUD/effect sprites ("ROUND", "FIGHT", "YOU WIN"…) | 1.6 KB | Documented, not revalidated |
| `$29`, `$2D` | `$A000` | Music (FamiTone2) | 5.7 / 4.9 KB | Documented, not revalidated |
| `$36` | `$C000` | RLE screens + tables | 1.3 KB | Documented, not revalidated |
| `$3C` | `$8000` | Character fiches, names, victory quotes, selection/VS data | 1.8 KB | Documented, not revalidated |
| `$02…$2A` (step 4) | `$C000` | 11 DPCM voice banks | — | Documented, not revalidated |
| `$37` | `$E000` | Sound (FamiTone2 + voices), warning, title and selection screens | 6.4 KB | Documented, not revalidated |
| `$3B` | `$E000` | Fight (rounds, HUD, drawing, split screen), VS screens and final quote, video utilities | 8.1 KB (full!) | Documented, not revalidated |
| `$3F` | `$E000` | Reset, main loop, fight engine core | 7.3 KB | Documented, not revalidated |
| Other 36 banks | — | Empty (`$FF`) | 0 | Documented, not revalidated |

### Separation of concepts

- **Specific bank local limitation:** bank `$3B` is documented as "full" (~120 bytes free); any addition there overflows the bank (assembler warns via kernel `.assert`).
- **Total remaining PRG capacity:** documented as 36 of 64 banks empty (22% of PRG used). Not revalidated.
- **Kernel/vector requirements:** every bank mapped at `$E000` needs vectors at `$FFFA`–`$FFFF`; the kernel (`$FC7C`–`$FF9A`) is repeated in the three code banks (`$37`, `$3B`, `$3F`) via `src/kernel.inc`.
- **Date/version/build distinct claims:** README cites a historical delivered ROM SHA-1 (`843a869e…`) and an original ROM SHA-1 (`0bf9dc57…a9aed`); these are historical claims, not revalidated in this audit.

## 6. Tool and validation inventory

Inventoried by reading `tools/` and `tools/mesen/`. **No script was executed.** No approval claim is made.

| Tool/script | Declared purpose | Inferred inputs/outputs from reading | Scenario/claim covered | Audited status |
|-------------|------------------|--------------------------------------|------------------------|----------------|
| `tools/disasm.py` | Project generator (`make gen`) | ROM + trace + annotations → `src/*.s`, `sf2ne.cfg`, `assets/` | Source regeneration | EXISTS — not executed in this audit |
| `tools/show.py` | Show a routine with who calls it and which screens it runs on | Routine address → routine text + `; <-` and `; modos:` lines | Individual routine inspection | EXISTS — not executed |
| `tools/datamap.py` | List data ranges of a bank (read/typed/never touched) | Bank(s) → list of ranges | Data coverage per bank | EXISTS — not executed |
| `tools/ptr_candidates.py` | List immediate pairs that look like pointers but trace didn't confirm | — → suspicious pairs for manual review | Discovery of pointers not covered by trace | EXISTS — not executed |
| `tools/poke_prg.py` | Write swapped bytes in ROM copy (experiments) | Base ROM + bank/address/byte → modified ROM (copy) | Relocation experiments on copy | EXISTS — not executed |
| `tools/frame_census.py` | Census of animation frame bytes directly from ROM | Bank/ROM → statistics of effects, flags, modes, collision | Reachable Ryu frames | EXISTS — not executed |
| `tools/shift_test.sh` | Relocation test: inserts 1 byte at start of banks and assembles | Bank list → shifted ROM in `build/shift/` | Verify relocatability | EXISTS — not executed |
| `tools/extract_chr.py` / `extract_dpcm.py` | Export graphics (PNG) and voices (WAV) | — → `extracted/chr/`, `extracted/dpcm/` | `make assets` | EXISTS — not executed |
| `tools/trace_merge.py` | Merge raw emulator executions in `trace/` | Multiple trace dirs → merged `trace/` | Trace consolidation | EXISTS — not executed |
| `tools/sheet.py` | Screenshot contact sheet | Multiple PNG images → contact sheet | Capture visualization | EXISTS — not executed |
| `tools/d6502.py`, `tracelib.py` | Libraries (opcode table, trace reading) | — → used by other scripts | Tool support | EXISTS — not executed |
| `tools/mesen/batch1.sh`, `batch2.sh`, `batch3.sh`, `batch_ptr.sh` | Batches used to generate `trace/` | — → `trace/` | Historical trace generation | EXISTS — not executed |
| `tools/mesen/run_trace.sh` | Run a Mesen Lua script with parameters | Plan + frames + seed → trace output | Controlled execution in Mesen | EXISTS — not executed |
| `tools/mesen/reset_test.lua` / `reset_test.sh` | Press RESET at a frame and verify game restarts | ROM + frame → restart result | Soft reset test | EXISTS — not executed |
| `tools/mesen/ptrtrace.lua` | Trace pointers by value origin | Execution → immediate pairs recognized as pointers | Pointer discovery | EXISTS — not executed |
| `tools/mesen/regress.sh` | 5-match battery against original | ROM → behavior comparison | Regression of existing features | EXISTS — not executed |
| `tools/mesen/compare_roms.sh` | Run two ROMs with same inputs and compare | Two ROMs + plan + frames + seed → screens/sound/timeline comparison | Visual/temporal regression | EXISTS — not executed |
| `tools/mesen/cdl.lua` | Record executed code, data reads, indirect jumps, RAM use, MMC5, DPCM, screen mode, screenshots | Execution → `trace/` | Execution data collection | EXISTS — not executed |

**General status:** all scripts exist, none executed in this audit. Execution status: `EXISTS — not executed in this audit` for all.

## 7. Inconsistency matrix

Comparing `README.md`, `docs/ROADMAP.md`, `docs/ARCHITECTURE.md`, `docs/FORMATS.md`, `docs/RAM.md`, `docs/BUGS.md`, `docs/TOOLS.md` and task specifications. No divergence was corrected; all are registered for later prioritization.

| ID | Claim/subject | Document A | Document B | Category | Risk | Proposed destination |
|----|---------------|------------|------------|----------|------|----------------------|
| IN-01 | Label count: "1,795 labels; 304 have real names" (README §"What is not ready yet") | `README.md` | Recalculated count (2,145 definitions, 2,140 unique, 1,084 semantic, 0 automatic code) | Count/metric | Resolved in Phase 3 — README and this document reconciled | Keep canonical metric from section 4; D-01 resolved at Phase 3 close |
| IN-02 | Named variable count: "78 named" (README) | `README.md` | Not recalculated in this audit (would require `ram.inc` inspection) | Count/metric | Low | Verify against `src/ram.inc` in Phase 1 |
| IN-03 | "Never executed code (14–17% of banks `$37` and `$3F`)" (README) | `README.md` | Not revalidated (would require current traces) | Bank capacity/build | Medium — percentage may be outdated | Confirm with `datamap.py`/traces in Phase 1, without running emulator |
| IN-04 | "52 farcall and 7 farjmp" (ARCHITECTURE.md §2.7) | `docs/ARCHITECTURE.md` | Not recounted in this audit | Source of truth/generation | Low | Verify against annotations/generator in Phase 4 |
| IN-05 | "Bank `$3B` is full — ~120 bytes free" (ARCHITECTURE.md §7 and ROADMAP.md Step 5) | `docs/ARCHITECTURE.md`, `docs/ROADMAP.md` | Not revalidated (no build) | Bank capacity/build | Medium — limits code addition in `$3B` | Confirm with linker map if build authorized (Gate C/D) |
| IN-06 | README describes canonical build as "with playable Ken" and `make verify` warns it diverges from original | `README.md` | `Makefile` (`DEFS := -D DEST_FLAG_BLINK`, build diverges by design) | Source of truth/generation | Low — intentional behavior, documented | None; consistent in intent |
| IN-07 | "Ken has 4.3 KB of frames now integrated into bank $05" (README §Findings) vs "Bank $05 is hand-written source (original is all $FF)" (ROADMAP.md Step 3) | `README.md`, `docs/ROADMAP.md` | Sources describe complementary situations (frames vs states) | Status/scope | Low | Clarify in Phase 4 |

## 8. Stabilization decisions

Reference to `tasks/STABILIZATION_BACKLOG.md` (created in Phase 0). At Phase 3 close (2026-11-16), D-01 and D-03 were resolved; D-02 remains `PROPOSED`; D-04 to D-07 follow `PENDING`:

- **D-01 — RESOLVED:** reproducible label counting method, registered in section 4 and in `tasks/PHASE_3_EXECUTION_REPORT.md` §10.2.
- **D-02 — PROPOSED:** canonical source for state/frame authoring; did not block symbol naming (blocks implementing converter or migrating data).
- **D-03 — RESOLVED:** first naming batch and minimal evidence, registered in `tasks/NAMING_CANDIDATES.md` and batch reports.
- **D-04:** Criteria to reopen character/feature implementation (blocks resuming track C).
- **D-05:** Future validations authorized, by whom, in what scope (blocks creating/running tests, builds or emulator validation).
- **D-06:** Evaluation of external asset tools (blocks integrating external converters).
- **D-07:** Measurable need to change kernel/bank organization (blocks any kernel refactoring).

None of these was resolved in this audit.

## 9. Limitations and recommended next steps

### Limitations of this audit

- No assembly, execution, emulation or testing was performed. All bank occupancy metrics are documented/historical, not revalidated.
- No permanent audit tool was created (as Phase 1 scope prohibits).
- No document divergence was corrected; all were registered in section 7.
- README historical label count (1,795) was not used; a new count was made from generated sources and updated in Phase 3 and in `$3C`, `$3F`, `$20`, `$36`, `$3B` and `$37` batches (2,145 definitions, 2,140 unique names, 1,084 semantic).

### Recommended next steps (without implementing or choosing canonical source)

1. **Request Gate A** (documentary audit) to consolidate current metrics and resolve documented divergences (section 7).
2. **Label counting criterion** (D-01): resolved at Phase 3 close; canonical metric is in section 4.
3. **Decide canonical source for states/frames** (D-02) before specifying text format (Phase 2).
4. **Evaluate whether "never executed code" percentage (14–17%) needs revalidation** with existing traces, without running a new emulator.

## 10. Source index

| Relative path | Content | Used for |
|---------------|---------|----------|
| `README.md` | Overview, workflow, historical metrics | Sections 2, 3, 4, 7 |
| `Makefile` | Build commands, canonical build defines | Sections 3, 4 |
| `sf2ne.cfg` | PRG bank layout for ld65 | Section 5 |
| `annotations/sf2ne.ann` (1,711 lines) | Names, comments, corrections, `alt` blocks, `patch`, `keepbank` | Sections 3, 4, 7 |
| `src/bank_*.s` (26 files) | Generated source per code/data bank | Section 4 (label count) |
| `src/*.inc` (6 files: kernel, defs, ram, globals, hw, macros) | Shared between banks; `.global` in `globals.inc` | Sections 3, 4 |
| `docs/ARCHITECTURE.md` | Cartridge map, banks, code, flow, engine, format, sound, video | Sections 2, 5, 7 |
| `docs/FORMATS.md` | Field-by-field state, frame, command, AI formats | Sections 2, 3 |
| `docs/RAM.md` | Known RAM map | Section 3 |
| `docs/ROADMAP.md` | Steps, status, Phase 0 pause declaration | Sections 2, 5, 7 |
| `docs/BUGS.md` | Reported bugs and status | Section 2 |
| `docs/TOOLS.md` | Flow, Makefile, annotations, scripts, emulator | Sections 3, 6 |
| `tools/disasm.py` | Generator | Sections 3, 4 |
| `tools/show.py`, `datamap.py`, `ptr_candidates.py`, `poke_prg.py`, `frame_census.py`, `shift_test.sh`, `extract_chr.py`, `extract_dpcm.py`, `trace_merge.py`, `sheet.py`, `d6502.py`, `tracelib.py` | Tool scripts | Section 6 |
| `tools/mesen/` (14 files) | Emulation and validation scripts | Section 6 |
| `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md` | Phase 0 specification (prerequisite verified) | Section 1 |
| `tasks/STABILIZATION_BACKLOG.md` | Backlog created in Phase 0 | Sections 2, 8 |

**Label counting method:** `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s`, with classification by `L<bb>_<aaaa>` (code) and `D<bb>_<aaaa>` (data) patterns confirmed in generator; everything else is semantic. Files consulted: all `src/bank_*.s` listed in the index above.

## 11. Status after Phase 3 (naming) and data `$3C`/`$3F`/`$20`/`$36`/`$3B`/`$37` batches

- **Date:** 2026-11-17
- **Base committed:** `3ba99e3` (`$3B` batch; previous: `8108eb1` `$36`, `fa7c215`, `2df963c`, `64a29f8`, `92fbde1`)
- **Working tree:** `$37` batch applied (`annotations/sf2ne.ann`, `src/bank_37.s`, comments in `src/bank_20.s`/`src/kernel.inc`) and `tasks/DATA_NAMING_37.md`, pending commit. Phase 3 closed on 2026-11-16.

### 11.1 Reconciled metrics

| Metric | Phase 1 | Current status |
|--------|---------|----------------|
| Label definitions | 2,145 | **2,145** |
| Unique names | 2,141 | **2,140** |
| Automatic code (`L`) | 379 | **0** |
| Automatic data (`D`) | 1,213 | **1,056** |
| Unique semantic | 549 | **1,084** |
| Per-bank semantic sum | — | **1,089** |

The 1,089 vs 1,084 difference is explained by repeated names between banks: `ResetStub` (3×), `ResetVectorFill` (2×), `RoundStart` (2×) and `InputButtons` (2× within `$3F`). Canonical method (`grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s`) does not count three labels with comment on same line (`EdgeARel`, `EdgeBRel`, `EdgeBBtn`); including them would give 1,087 unique semantic and 1,092 per-bank sum.

### 11.2 Batches applied

| Batch | Lines | Scope | Verification |
|-------|-------|-------|--------------|
| P0/P1 (Gate D) | 21 | Engine core, vectors, timer, input, portrait, HUD, metasprites, projectile | `make` + identical SHA-1 |
| P2 | 251 | State engine, fight, screens, Ryu AI, sound/screens | `make` + identical SHA-1 |
| PAD | 7 | Standardized transition conditions in English (other 7 born in P2) | `make` + identical SHA-1 |
| FamiTone2 | 109 | 107 `_FT2*` internals + 2 top routines | `make` + identical SHA-1 |
| Data `$3C` | 33 | Fiches, palettes and portraits: 20 pointer tables (`Char*Tbl`), collision bank, 7 palettes and 5 portrait/name tables | `make` + identical SHA-1 |
| Data `$3F` | 15 | Fight core: projectile, impact SFX, knockback by class, fall/KO reaction and movement dispatches | `make` + identical SHA-1 |
| Data `$20` | 30 | HUD/effects: round intro/end texts, selection flags, cursor, projectiles, shock and M.Bison portrait | `make` + identical SHA-1 |
| Data `$36` | 27 | Stages: RLE backgrounds, CHR/split tables, attributes and palette | `make` + identical SHA-1 |
| Data `$3B` | 35 | Fight/VS/select HUD: fade bounds, projectile frames, HUD tiles, screen palettes/RLE, round-intro tables, stage banks, reset filler | `make` + identical SHA-1 |
| Data `$37` | 17 | Sound/select/title data: voice continuation, sfx dispatch/pointer list, FamiTone2 tables, select/title tables, reset filler | `make` + identical SHA-1 |
| **Total** | **545** | — | — |

Line-by-line inventory, with unique ID, previous ID, previous symbol, evidence, confidence and risk, is in `tasks/NAMING_CANDIDATES.md` (Phase 3), `tasks/DATA_NAMING_3C.md`, `tasks/DATA_NAMING_3F.md`, `tasks/DATA_NAMING_20.md`, `tasks/DATA_NAMING_36.md`, `tasks/DATA_NAMING_3B.md` and `tasks/DATA_NAMING_37.md` (data batches).

### 11.3 Integrity verification

| Verification | Result |
|--------------|--------|
| `make gen` | OK |
| `make` | OK — canonical build with `DEST_FLAG_BLINK` |
| SHA-1 of `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` (identical to baseline) |
| Byte columns vs `HEAD` | `$00` 297/297, `$37` 1723/1723, `$3B` 2461/2461, `$3C` 1232/1232, `$3F` 3001/3001 — identical |
| `.byte`/`.word` directives of `src/bank_3F.s` | 155 before, 155 after; identical operands (only labels/comments) |
| `.byte`/`.word` directives of `src/bank_20.s` | 144 before, 144 after; identical operands (only labels/comments) |
| `src/bank_36.s` | 27 `D36_*` replaced; 3 write-only labels kept automatic; identical `.byte`/`.word` operands |
| `src/bank_3B.s` after `$36` | only `VersusLoadStage`/`RoundInitLoadStage` now cite `Stage*` names |
| `src/bank_37.s` after `$37` | 17 `D37_*` replaced; 10 sfx streams kept automatic; identical `.byte`/`.word` operands except two `SfxStreamPtrTbl` and one `ResetVectorFill` label operands |
| `src/bank_05.s` (Ken, manual source) | 0 references to `D20_*` or `D36_*` |
| `make fixed` | OK — expected divergence (`-D FIX_SOFT_RESET`) |
| Automatic code labels | 0 |

No emulator execution was done in this phase; verification is static (flow, calls, comments) plus build and SHA-1/byte comparison.

### 11.4 Pending

- **Commit:** Phase 3 closed on 2026-11-16; `$3C`, `$3F` and `$20` batches committed (`64a29f8`, `92fbde1`, `2df963c`). The `$36` batch was applied before `fa7c215` and is recorded in `8108eb1`; the `$3B` batch is committed as `3ba99e3`; the `$37` batch is applied and awaits commit authorization. No push without explicit approval.
- **Decisions:** D-01 and D-03 resolved at close; D-02 remains `PROPOSED` (does not block naming); D-04…D-07 follow `PENDING` in `tasks/STABILIZATION_BACKLOG.md`.
- **Data (`D<bb>_<aaaa>`, 1,056):** inventoried and prioritized in `tasks/DATA_LABEL_INVENTORY.tsv`; `$3C` (33), `$3F` (15), `$20` (30), `$36` (27), `$3B` (35) and `$37` (17) batches applied. Next candidate: music (`$29`/`$2D`, 173); large Ryu/Ken banks (`$00`/`$01`/`$05`, 862) may remain P3.
- **`$36` write-only labels:** `D36_C005`, `D36_C00A` and `D36_C00F` remain automatic until a consumer appears (`MMC5_CHR_BG2` is never used).
- **State/frame migration to TOML:** not authorized and not started.
