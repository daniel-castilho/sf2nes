# Execution report — Phase 3 (evidence-guided naming)

**Date:** 2026-11-15 (code batches); updated 2026-11-16 (data batches and closing)  
**Committed base:** `3ba99e3` (`$3B` batch; previous: `8108eb1` `$36`, `fa7c215`, `2df963c`, `64a29f8`, `92fbde1`)  
**State:** Phase 3 concluded and verified; `$37` batch committed as `cfc7d78` and pushed.  
**Scope:** symbol and comment renaming; no code/data byte was altered.

> Sections 1–9 preserve the 2026-11-15 record, when only code batches were in the diff. Section 10 consolidates data batches, final metrics, and phase acceptance.

## 1. Altered files

| File | Nature of change |
|------|------------------|
| `annotations/sf2ne.ann` | Canonical source: 388 labels (21 P0/P1 already committed in Gate D; 367 in current diff: 251 P2, 7 PAD, and 109 FamiTone2) and evidence comments |
| `src/bank_00.s`, `src/bank_01.s`, `src/bank_37.s`, `src/bank_3B.s`, `src/bank_3F.s` | `make gen` output; only labels/comments |
| `tasks/NAMING_CANDIDATES.md` | Complete inventory, 388 lines with unique ID, previous ID, evidence, confidence, priority, risk, and decision |
| `docs/PROJECT_STATUS.md` | Reconciled metrics and new section 11 with post-Phase 3 state |
| `README.md` | Label metric updated (2,145 definitions; 928 semantic; 0 automatic code) |

No change in `tools/`, `Makefile`, `sf2ne.cfg`, assets, reference ROM, or gameplay code.

## 2. Renamed symbols

Address-level detail is in `tasks/NAMING_CANDIDATES.md` (tables 3.1 to 3.4). Summary:

| Batch | Lines | Distribution |
|-------|-------|--------------|
| P0/P1 (Gate D) | 21 | `$3F` 10, `$3B` 11 |
| P2 | 251 | `$00` 48, `$37` 49, `$3B` 142, `$3F` 12 |
| PAD | 7 | `$3F` 7 |
| FamiTone2 | 109 | `$37` 109 (107 internal `_FT2*` + 2 top routines) |
| **Total** | **388** | — |

## 3. Evidence and confidence

- **P0/P1:** demonstrable flow/calls; majority `HIGH`, with `MEDIUM` in portrait, HUD, and selection blocks.
- **P2:** static reading of flow and existing comments in `.ann`; `HIGH` in all applied lines.
- **PAD:** transition condition semantics confirmed in code; `HIGH`.
- **FamiTone2:** structure verified against public v1.15 library; `HIGH` for structural role.
- **No** name was applied with `LOW` confidence.
- Ambiguous or insufficiently evidenced names remained automatic (no renaming by assumption).

## 4. Before/after metrics

Canonical method: `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s`.

| Metric | Phase 1 | After Phase 3 |
|--------|---------|---------------|
| Label definitions | 2,145 | **2,145** |
| Unique names | 2,141 | **2,141** |
| Automatic code (`L`) | 379 | **0** |
| Automatic data (`D`) | 1,213 | **1,213** |
| Unique semantic | 549 | **928** |
| Semantic sum by bank | — | **931** |

Bank sum (931) differs from unique total (928) because `ResetStub` (3 banks), `RoundStart` (2 banks), and `InputButtons` (2× in `$3F`). The regex does not count three labels with comment on the same line (`EdgeARel`, `EdgeBRel`, `EdgeBBtn`). Published metric remains 928 to be reproducible.

## 5. Ambiguities and limitations

- `EdgeARel`, `EdgeBRel`, and `EdgeBBtn` are out of canonical metric due to same-line comment; published metric remains 928 for reproducibility.
- `InputButtons` remains duplicated within bank `$3F`; not renamed to avoid changing existing contract.
- No emulator execution; verification is static (flow, calls, comments) + build + SHA-1/bytes.
- In the 2026-11-15 state, D-01…D-07 were still `PENDING`; closing resolved D-01 and D-03 and kept D-02 `PROPOSED` (see §10.4).
- State/frame migration to TOML was not authorized nor started.

## 6. Effects on tools and documents

- `src/globals.inc` did not need changes (renamed labels did not change inter-bank exports).
- `docs/PROJECT_STATUS.md` was reconciled with canonical metric and gained section 11.
- `README.md` stopped publishing historical metric (1,795/304) and now publishes current one.
- No `tools/` script was created or modified.

## 7. Commands and validations executed

| Command/validation | Result |
|--------------------|--------|
| `make gen` | OK; `src/` regenerated from `annotations/sf2ne.ann` |
| `make` | OK; canonical build with `DEST_FLAG_BLINK` |
| `sha1sum build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to baseline |
| Byte columns vs `HEAD` | 29 banks compared, 8,891 bytes, all identical |
| `make fixed` | OK; expected divergence (`-D FIX_SOFT_RESET`) |
| Label count | `unique=2141 extra=4 autoL=0 autoD=1213 semantic=928` |

## 8. Preservation and scope

- Column 0 (Ryu) remained untouched; no character byte, state, frame, AI, or gameplay was altered.
- No new character, Ken AI, feature, converter, or kernel refactoring was started.
- Preexisting local changes were preserved; no `clean`, `reset`, or `restore`.
- In that session, nothing was committed or pushed; batches were committed later (see §10).

## 9. Commit proposal

> **Status:** executed in `e2e18f3`; this section is kept as historical record.

I recommend **a single commit** for the already-verified set, because the `annotations/sf2ne.ann` diff contains P2, PAD, and FamiTone2 batches interleaved in the same file and the inventory/documentation already describe the final state. Separating into two commits would require manual hunk staging and would leave the intermediate commit with inconsistent documentation.

Suggested message:

```text
Phase 3: evidence-guided naming (P2, PAD and FamiTone2)

- 251 P2 labels, 7 PAD conditions, and 109 FamiTone2 mappings
- complete inventory with 388 lines and unique IDs
- reconciled metrics: 0 automatic code, 1,213 automatic data, 928 semantic
- identical ROM SHA-1: 3ad177a0a7867a821e6c1709b4e6dbdda3555aa1
```

---

## 10. Final closing — data batches and consolidated state

Metrics in sections 4 and 7 are historical (before data batches). The metrics in this section prevail.

### 10.1 Applied data batches

| Batch | Lines | Scope | Commit |
|-------|-------|-------|--------|
| Data `$3C` | 33 | sheets, palettes, and portraits | `64a29f8` |
| Data `$3F` | 15 | fighting core | `92fbde1` |
| Data `$20` | 30 | HUD/effects, flags, projectiles, and M.Bison portrait | `2df963c` |
| Data `$36` | 27 | stages: RLE backgrounds, CHR/split tables, attributes and palette | `fa7c215`* |
| Data `$3B` | 35 | fight/VS/select HUD: fade bounds, projectile frames, HUD tiles, screen palettes/RLE, round-intro tables, stage banks, reset filler | `3ba99e3` |
| Data `$37` | 17 | sound/select/title data: voice continuation, sfx dispatch/pointer list, FamiTone2 tables, select/title tables, reset filler | `cfc7d78` |
| **Total** | **157** | — | — |

\* The `$36` batch was applied before `fa7c215` and entered the repository bundled with that English-translation commit; it has no separate commit.

With the 388 code labels, Phase 3 and the follow-up batches renamed **545 labels**.

### 10.2 Final metrics

Canonical method: `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s`, with the caveat of the three labels with same-line comment (`EdgeARel`, `EdgeBRel`, `EdgeBBtn`).

| Metric | Phase 1 | Closing | After `$36` | After `$3B` | After `$37` |
|--------|---------|---------|-------------|-------------|-------------|
| Label definitions | 2,145 | **2,145** | **2,145** | **2,145** | **2,145** |
| Unique names | 2,141 | **2,141** | **2,141** | **2,141** | **2,140** |
| Automatic code (`L`) | 379 | **0** | **0** | **0** | **0** |
| Automatic data (`D`) | 1,213 | **1,135** | **1,108** | **1,073** | **1,056** |
| Unique semantic | 549 | **1,006** | **1,033** | **1,068** | **1,084** |
| Semantic sum by bank | — | **1,010** | **1,037** | **1,072** | **1,089** |

The 1,089 vs 1,084 difference comes from `ResetStub` (3×), `ResetVectorFill` (2×), `RoundStart` (2×), and `InputButtons` (2× in `$3F`). The canonical regex does not count the three same-line-comment labels; including them would give 1,087 unique semantic and 1,092 bank sum.

### 10.3 Verification

| Verification | Result |
|--------------|--------|
| `make gen` | OK |
| `make` | OK — canonical build with `DEST_FLAG_BLINK` |
| SHA-1 of `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to baseline |
| `src/bank_20.s` | 0 `D20_*` labels; 144 `.byte`/`.word` directives with identical operands |
| `src/bank_37.s`, `src/bank_3B.s`, `src/bank_3C.s` | only swap of `D20_*` for new names; same addresses in comments |
| `src/bank_36.s` | 27 `D36_*` replaced; 3 write-only labels kept automatic; `.byte`/`.word` operands identical |
| `src/bank_3B.s` after `$36` | only `VersusLoadStage`/`RoundInitLoadStage` now cite `Stage*` names |
| `src/bank_37.s` after `$37` | 17 `D37_*` replaced; 10 sfx streams kept automatic; identical `.byte`/`.word` operands except two `SfxStreamPtrTbl` and one `ResetVectorFill` label operands |
| `src/bank_05.s` (Ken, manual source) | 0 references to `D20_*` or `D36_*` |
| `make fixed` | OK — expected divergence (`-D FIX_SOFT_RESET`) |

### 10.4 Decisions and acceptance

- **D-01 — RESOLVED.** Reproducible method registered in `docs/PROJECT_STATUS.md` §4/§11 and in this section: count definitions and unique names separately, distinguish code/data/semantic, and keep the caveat of the three same-line-comment labels.
- **D-03 — RESOLVED.** First batch was P0/P1 (engine core), followed by P2/PAD/FamiTone2 and `$3C`, `$3F`, `$20`, `$36`, `$3B` and `$37` data. Minimum evidence: demonstrable consumer, table structure, or existing documentation; confidence `HIGH`/`MEDIUM`; `LOW` remains automatic. In `$36`, three write-only labels (`C005`, `C00A`, `C00F`) stayed automatic for lack of a static consumer.
- **D-02 — PROPOSED, non-blocking for naming.** Decision on state/frame canonical source (`tasks/STATE_DATA_FORMAT_DECISION.md`) still awaits Maintainer. Phase 3 did not use it: naming acted only on symbols, whose canonical source is `annotations/sf2ne.ann`.
- **D-04…D-07 — PENDING**, no change in this phase.

Phase 3 spec §12 acceptance criteria:

| Criterion | State | Evidence |
|-----------|-------|----------|
| Gates of Phases 0–2 and canonical source available | MET for symbols | Phases 0/1 completed; symbol source = `annotations/sf2ne.ann`; D-02 (states/frames) remains `PROPOSED` and out of naming scope |
| Initial metric reconciled and method frozen | MET | §10.2 and `docs/PROJECT_STATUS.md` §4/§11 |
| Inventory with address, label, name, category, evidence, confidence, priority | MET | `tasks/NAMING_CANDIDATES.md` and `tasks/DATA_NAMING_3C.md`, `_3F.md`, `_20.md` |
| P0/P1 batches limited, reviewable, evidence-based; P3 without definitive rename | MET | batches by subsystem; no `LOW` name applied |
| Naming conventions registered | MET | `tasks/NAMING_CANDIDATES.md` §1 and batch reports |
| Source changed after authorization; `src/` not hand-edited | MET | `annotations/sf2ne.ann`; `src/` regenerated by `make gen` (except `$05`, manual and untouched) |
| No byte, address, flow, or content altered | MET | identical SHA-1; `.byte`/`.word` operands verified |
| Binary equivalence claimed only after authorized verification | MET | build/SHA-1 executed with authorization; result reported |
| Same Phase 1 metric, categories separate | MET | §10.2 |
| No character, feature, Ken AI, converter, or kernel refactoring started | MET | scope restricted to labels/comments |
| No build/test/emulator without own authorization | MET | `make gen`, `make`, and `make fixed` authorized in session |
| Preexisting local changes preserved | MET | no `clean`, `reset`, or `restore` |

### 10.5 Pendencies and next step

- **1,056 automatic data labels remain**; spec allows keeping them when semantics is undetermined (P3/opaque). Distribution: `$00` 206, `$01` 304, `$04` 3, `$05` 352, `$08/$0C/$10/$1C/$24` 5, `$29` 103, `$2D` 70, `$36` 3, `$37` 10.
- Next candidates by evidence/effort: music (`$29`/`$2D`, 173). Large Ryu/Ken banks (`$00`/`$01`/`$05`, 862) require state/frame analysis and may remain P3.
- The three `$36` write-only labels (`C005`, `C00A`, `C00F`) stay automatic until a consumer appears; `MMC5_CHR_BG2` is never used in the ROM.
- No character, feature, or playable content was started.
