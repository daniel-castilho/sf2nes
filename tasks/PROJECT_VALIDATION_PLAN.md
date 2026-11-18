# Project validation plan — Phase 5 (proposed)

**Status:** `PLAN PROPOSED — D-05 PENDING`  
**Type:** planning and specification document. It does not authorize execution, build, test, emulator run, manual acceptance or Gate C integration.  
**Base:** remote `main` at `c344034865b5b43e00d767995c1dd8de9cd72e5b` (reconfirmed 2026-11-17 during preparation). If `main` advances before a future execution, the newer commit becomes the base and must be recorded in the run record.  
**Specification:** [`tasks/PHASE_5_VALIDATION_SPEC.md`](PHASE_5_VALIDATION_SPEC.md).  
**Prerequisites:** Phases 0–4 completed; Phase 4 closeout in [`docs/PROJECT_STATUS.md`](../docs/PROJECT_STATUS.md) §12.  
**Companion documents:** [`docs/PROJECT_STATUS.md`](../docs/PROJECT_STATUS.md), [`docs/TOOLS.md`](../docs/TOOLS.md), [`docs/BUGS.md`](../docs/BUGS.md), [`docs/FORMATS.md`](../docs/FORMATS.md), [`docs/FORMATS_OPEN.md`](../docs/FORMATS_OPEN.md), [`docs/ROADMAP.md`](../docs/ROADMAP.md), [`tasks/STABILIZATION_BACKLOG.md`](STABILIZATION_BACKLOG.md), [`tasks/STATE_DATA_FORMAT_DECISION.md`](STATE_DATA_FORMAT_DECISION.md), [`tasks/STATE_DATA_FORMAT_SCHEMA.md`](STATE_DATA_FORMAT_SCHEMA.md), [`tasks/STATE_DATA_FORMAT_MIGRATION_PLAN.md`](STATE_DATA_FORMAT_MIGRATION_PLAN.md), [`tasks/PHASE_3_EXECUTION_REPORT.md`](PHASE_3_EXECUTION_REPORT.md).

> **No result is claimed here.** Nothing in this document was executed in Phase 5. A tool being present is not a result. A historical report proves only the artifact, configuration and date it describes. `PASS` must not be written for any case in this plan; `PASS` belongs only to a future run record with dated evidence and explicit authorization.

---

## 1. Objective and non-authorization

Define **what should be verified, how evidence should be recorded, and which permission is required** before any validation is run.

The plan separates:

- static/source or schema checks;
- generator and data-format integrity;
- build/link integrity;
- regression of already-existing behavior;
- manual acceptance of behavior explicitly in scope;
- historical verification versus a new run;
- a script/tool being present versus it being executed successfully.

**D-05 remains `PENDING`.** Completing this plan does not authorize any build, test, script, emulator, harness, generated artifact or manual gameplay check. The content pause remains in effect: this plan does not authorize Ken implementation, Ken AI, new characters, new features, roster expansion, arcade-derived AI or making the Gate C prototype canonical.

---

## 2. Base, preservation and allowed edits

### 2.1 Base verification (required before future execution)

1. Run `git fetch` and `git ls-remote origin refs/heads/main`.
2. Record remote SHA, local `HEAD` and any divergence.
3. Use an isolated worktree or preserve the current working tree and **all** pre-existing local changes and untracked files.
4. Stop and report if the remote status changes the scope, if the Gate C prototype has entered the canonical flow, if D-05 was explicitly decided, or if local changes conflict with the planned documentation.

### 2.2 Allowed edits for Phase 5 documentation

- Create [`tasks/PROJECT_VALIDATION_PLAN.md`](PROJECT_VALIDATION_PLAN.md) (this file).
- Optionally update [`tasks/STABILIZATION_BACKLOG.md`](STABILIZATION_BACKLOG.md) **Phase 5 status/link only**, to `PLAN PROPOSED — D-05 PENDING`.
- Nothing else. Do not edit `docs/TOOLS.md`, sources, annotations, tools, assets, Makefile, linker configuration or ROMs merely to make the plan convenient. Identify gaps and propose later changes instead.
- Do not run `clean`, `reset`, `restore` or destructive checkout.
- Do not delete pre-existing user data or generated test artifacts that existed before the run.

---

## 3. Validation levels V0–V5

| Level | Purpose | What it covers | What it does **not** cover |
|---|---|---|---|
| **V0** | Evidence and requirement traceability | Stable case ID, requirement/source, artifact and commit under test, setup, inputs, oracle, tool/version, evidence, cleanup, status and authorization reference | Proving correctness by itself |
| **V1** | Static format and source consistency | TOML schema syntax/types, IDs, references, zero/null/sentinel/loop distinction, record shape, raw unknowns, orphans, source-of-truth boundary, no silent normalization, exact `.word` target, comparator qualification | Generation, build or runtime behavior |
| **V2** | Generation and structural equivalence | Determinism, no overwrite of authored TOML, single authoritative record, pointer/bank resolution, field preservation, exact byte/record comparison including exact `.word`, repeatability, rollback | Adoption of the Gate C prototype; it is conditional on a separate Maintainer decision |
| **V3** | Build and link integrity | Build configuration/flags, expected outputs and hashes/maps/labels, bank/vector/assert/size constraints, variant separation, intentional differences, error handling, historical-hash non-reuse, clean-build reproducibility | Gameplay behavior |
| **V4** | Automated regression of existing behavior | Boot/menu/selection, Ryu versus CPU Ryu, input edge/promotion/special, movement, attacks/collision/damage, projectiles, timer/KO/rounds, soft reset, baseline comparison, relocatability; versus only when explicitly supported and authorized | New features, Ken-vs-Ken, Ken AI, full Ken acceptance |
| **V5** | Manual emulator acceptance | Emulator/version, ROM/build variant and hash, initial state, exact input sequence or movie, observed result, pass/fail criteria, evidence, game-defect versus emulator/configuration distinction | Automated proof; manual checks are not approved by this plan |

V0 is cross-cutting: every case in §6.1 must populate its V0 fields. V2 is **conditional** on Gate C authorization. V5 is **conditional** on explicit manual-test authorization.

---

## 4. Status and evidence vocabulary

### 4.1 Plan status values (used in §6.1)

| Value | Meaning |
|---|---|
| `PROPOSED — NOT RUN (D-05 PENDING)` | Case is defined; no execution is authorized in Phase 5. |
| `PROPOSED — CONDITIONAL (Gate C / D-05)` | Case depends on a separate Gate C or manual authorization. |
| `NOT APPLICABLE` | Out of scope for this plan or for the current artifact. |

### 4.2 Execution-status values (used in §6.2)

These are the only allowed values in the tool-coverage table:

| Value | Meaning |
|---|---|
| `EXISTS — NOT RUN in Phase 5` | Tool/case exists; it was not executed in Phase 5. |
| `HISTORICAL RESULT — cite report/commit/artifact` | A prior result exists for a named artifact/configuration/date; it was not revalidated. |
| `NOT DOCUMENTED / UNKNOWN` | No documented behavior or no reliable evidence. |
| `NOT APPLICABLE` | Out of scope for this plan. |

### 4.3 Future run-record values (not used in this plan)

A future authorized run record may use `PASS`, `FAIL`, `BLOCKED` and `NOT RUN`, each linked to a run record with base commit, tested commit, ROM hash, command, configuration, tool version and retained evidence. A case that cannot run must be reported `BLOCKED` or `NOT RUN`; it must not be silently skipped or implied successful.

---

## 5. Artifact and baseline identity

| Label | Artifact | Hash / identity | Role |
|---|---|---|---|
| **ORIG** | `rom/sf2ne_demo.nes` | SHA-1 `0bf9dc578de5a10bb9f429845c26fd2f958a9aed` | Original reconstruction; identity reference for changes that must not alter behavior. Historical artifact. |
| **CANON** | `build/sf2ne.nes` | No pinned current hash | Canonical modified build (Ken playable, `DEST_FLAG_BLINK`); expected to diverge from ORIG by design. |
| **FIX** | `build/sf2ne_fixed.nes`, `prontos/*` | No pinned current hash | Optional `FIXDEFS` variants: `FIX_SOFT_RESET`, `FIX_HEAVY_ONCE`, `FIX_EDGE_ATTACK`, `MODE_VERSUS`. |
| **HIST-P3** | `build/sf2ne.nes` at Phase 3 close | SHA-1 `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` | Historical Phase 3 artifact. Not a current pass criterion. |
| **HIST-KEN** | Ken delivery ROM | SHA-1 `843a869e6f61c076ae1f8cfbd0b6cea073c164f6`; commit `fccaae6` | Historical delivery (2026-11-13). Not current project status; Ken is paused. |

Rules:

- No historical hash is copied forward as a current pass criterion. A future `PASS` must identify the tested commit, build configuration and artifact hash.
- `make verify` compares a build with ORIG and **warns** on divergence; it is not a failure gate. CANON is expected to differ from ORIG.
- `regress.sh` compares a ROM against ORIG by identity. It is valid only for changes that must not alter behavior (relocation, refactor, naming). It must not be used to declare CANON correct against ORIG.
- Ken remains paused. Its frames are in bank `$04`; partial states are in the hand-written bank `$05`. No Ken acceptance case is introduced by default.

---

## 6. Coverage and status matrices

### 6.1 Test case table

Authorization codes are defined in §6.3. All cases are **not executed** in Phase 5.

| ID | Level | Requirement/source | Variant/preconditions | Procedure/input | Oracle/expected result | Evidence | Tool/interface | Authorization required | Status |
|---|---|---|---|---|---|---|---|---|---|
| TRC-01 | V0 | Evidence traceability; spec §5 V0 and §8 | Any future run | Fill a run record with base commit, tested commit, ROM hash, command, config, tool version, date, evidence paths | Every required field present; no field inferred | Run-record template | Manual/static review | AUTH-READ | PROPOSED — NOT RUN (D-05 PENDING) |
| TRC-02 | V0 | Artifact/variant identity; §5 above | ORIG, CANON, FIX, HIST | Classify the artifact under test before running | Variant and hash explicitly identified; historical hashes not reused | Identity table in run record | Manual/static review | AUTH-READ | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-01 | V1 | TOML syntax/types; [`STATE_DATA_FORMAT_SCHEMA.md`](STATE_DATA_FORMAT_SCHEMA.md) §2–§3 | Any `data/estados/*.toml`; no build | Parse with a TOML parser; validate declared types | Parses; required fields have declared types | Parser log; normalized field list | `tomllib` (Python 3.11+) or authorized validator | AUTH-STATIC | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-02 | V1 | Required fields per record; schema §3.1–§3.3 | State, frame and sheet records | Enumerate records; check required fields | No missing required field; no undocumented mandatory field | Field-coverage report | Authorized validator | AUTH-STATIC | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-03 | V1 | Unique IDs/symbols; schema | All records | Collect IDs; detect duplicates | Every ID unique within its namespace | Duplicate report | Authorized validator | AUTH-STATIC | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-04 | V1 | Reference resolution; schema + [`FORMATS.md`](../docs/FORMATS.md) §2–§8 | Records with references | Resolve state→frame, frame→metasprite, collision, loop target, condition | Every reference resolves or is an explicitly permitted null/terminal value | Resolution table; unresolved list | Authorized validator | AUTH-STATIC | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-05 | V1 | Zero vs null vs omitted vs sentinel vs loop; FORMATS §2–§8, schema | Edge records | Author each variant; round-trip | Five states remain distinct; no coercion | Round-trip diff | Authorized validator | AUTH-STATIC | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-06 | V1 | Normal versus loop frame shape; 14/16 bytes; variable collision record; FORMATS §6, [`FORMATS_OPEN.md`](../docs/FORMATS_OPEN.md) §1.2 | Normal, loop and collision records | Compare emitted length and shape | Length/shape matches the documented rule | Length/shape table | Authorized validator | AUTH-STATIC | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-07 | V1 | Raw integers and comments for unknown/hypothesis fields; schema | Records with hypothesis fields | Inspect authoring and emitted comment | Unknown value kept raw; comment retained | Sample records | Manual/static review | AUTH-READ | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-08 | V1 | Orphan/unreachable records; [`STATE_DATA_FORMAT_MIGRATION_PLAN.md`](STATE_DATA_FORMAT_MIGRATION_PLAN.md) §7 | Selected authoring set | Compare record inventory with baseline | No required orphan dropped | Inventory diff | Authorized validator | AUTH-STATIC | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-09 | V1 | Source-of-truth boundary; D-02 decision + schema | Authoring set | Check labels/comments/patches only in annotations; state/frame data only in TOML | No overlap; no duplicated authority | Boundary audit | Manual/static review | AUTH-READ | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-10 | V1 | No silent normalization; spec §5 V1 | Full set | Input→round-trip→diff | No undocumented byte/field lost or changed | Diff report | Authorized validator | AUTH-STATIC | PROPOSED — NOT RUN (D-05 PENDING) |
| FMT-11 | V1 | Exact `.word` pointer target; spec §5 V1 | Baseline versus generated | Resolve both sides to bank:address; compare exactly | Exact target equality, including bank | Pointer table | New exact comparator, not `comparar_estados.py` | AUTH-GATEC + AUTH-STATIC | PROPOSED — CONDITIONAL (Gate C / D-05) |
| FMT-12 | V1 | Comparator qualification; [`comparar_estados.py`](../tools/comparar_estados.py) lines 36–45 | Any use of the current comparator | Inspect semantics | `.word` zero/non-zero is not exact; it cannot be sole evidence | Tool-limitation note | Manual/static review | AUTH-READ | PROPOSED — NOT RUN (D-05 PENDING) |
| GEN-01 | V2 | Determinism; spec §5 V2 | Gate C authorized | Run generator twice on identical TOML; compare outputs | Byte-identical assembly | Two output hashes | `state_data_gen.py` or successor | AUTH-GATEC + AUTH-GEN | PROPOSED — CONDITIONAL (Gate C / D-05) |
| GEN-02 | V2 | Generator does not overwrite or ignore authored TOML; spec §5 V2 | Gate C authorized | Inspect writes and reads | TOML remains authoritative and unmodified | File listing; diff | Generator | AUTH-GATEC + AUTH-GEN | PROPOSED — CONDITIONAL (Gate C / D-05) |
| GEN-03 | V2 | Exactly one authoritative copy of each converted record; spec §5 V2 | Gate C authorized | Search generated assembly for duplicate records | One copy per record; no shadow copy | Record index | Generator + static check | AUTH-GATEC + AUTH-GEN | PROPOSED — CONDITIONAL (Gate C / D-05) |
| GEN-04 | V2 | Resolved symbolic pointers and bank associations; spec §5 V2 | Gate C authorized | Resolve pointers and banks; compare with baseline | Correct bank:address for every pointer | Pointer/bank table | Generator + exact comparator | AUTH-GATEC + AUTH-GEN | PROPOSED — CONDITIONAL (Gate C / D-05) |
| GEN-05 | V2 | Preservation of fields, raw unknowns, nulls, sentinels, loops and orphans; spec §5 V2 | Gate C authorized | Field-by-field and record-by-record comparison | All listed elements preserved | Preservation matrix | Generator + validator | AUTH-GATEC + AUTH-GEN | PROPOSED — CONDITIONAL (Gate C / D-05) |
| GEN-06 | V2 | Exact byte/record comparison against a selected baseline, including exact `.word`; spec §5 V2 | Gate C authorized; baseline chosen | Compare bytes and resolved pointer targets | Exact equality; `.word` targets not merely non-zero | Byte/pointer diff | New exact comparator | AUTH-GATEC + AUTH-STATIC | PROPOSED — CONDITIONAL (Gate C / D-05) |
| GEN-07 | V2 | Repeatability without unrelated changes; spec §5 V2 | Gate C authorized | Run generation twice; diff unrelated banks/assets/config | No unrelated change | Full-tree diff | Generator + `git diff` | AUTH-GATEC + AUTH-GEN | PROPOSED — CONDITIONAL (Gate C / D-05) |
| GEN-08 | V2 | Rollback to previous generation flow; spec §5 V2 and migration plan §6 | Gate C authorized | Deactivate converter; regenerate by previous flow | Previous flow restores expected output | Rollback log | Generator + build | AUTH-GATEC + AUTH-GEN + AUTH-BUILD | PROPOSED — CONDITIONAL (Gate C / D-05) |
| BLD-01 | V3 | Build configuration and flags; spec §5 V3 | Build authorized | Record `make` target, `DEFS`, `FIXDEFS`, tool versions | Configuration fully identified | Build log; version output | `make`, `ca65`, `ld65` | AUTH-BUILD | PROPOSED — NOT RUN (D-05 PENDING) |
| BLD-02 | V3 | Expected outputs and hashes/maps/labels; spec §5 V3 | Build authorized | Build; record ROM hash, map and label files | Outputs exist; hashes/maps retained | SHA-1; `.map`; labels | `make`, `sha1sum` | AUTH-BUILD | PROPOSED — NOT RUN (D-05 PENDING) |
| BLD-03 | V3 | Bank-window, vector, assertion and size constraints; spec §5 V3 | Build authorized | Inspect `.assert`, segment sizes, vectors, bank windows | No violated assertion; no unexpected overflow | Build log; map | `ca65`, `ld65` | AUTH-BUILD | PROPOSED — NOT RUN (D-05 PENDING) |
| BLD-04 | V3 | Separate ORIG, CANON, FIX and HIST; spec §5 V3 | Build authorized | Classify each build and its expected differences | Intentional differences identified; no cross-contamination | Variant matrix | `make` targets | AUTH-BUILD | PROPOSED — NOT RUN (D-05 PENDING) |
| BLD-05 | V3 | Historical hashes are not current pass criteria; spec §5 V3 | Any build | Check that no historical hash is used as the current oracle | Only current artifact/configuration hashes used | Hash-role audit | Manual/static review | AUTH-READ | PROPOSED — NOT RUN (D-05 PENDING) |
| BLD-06 | V3 | Error handling; spec §5 V3 | Build authorized | Exercise known failure modes: build error, bank overflow, duplicate symbol, generated-file drift | Failures reported explicitly; no silent success | Error logs | `make`, `ca65`, `ld65` | AUTH-BUILD | PROPOSED — NOT RUN (D-05 PENDING) |
| BLD-07 | V3 | `make verify` semantics; [`Makefile`](../Makefile), `docs/TOOLS.md` | Build authorized | Run `make verify` on CANON | Warning-only behavior; not treated as pass/fail | Command output | `make verify` | AUTH-BUILD | PROPOSED — NOT RUN (D-05 PENDING) |
| BLD-08 | V3 | Clean-build reproducibility; spec §5 V3 | Build authorized | Build twice from the recorded commit/config | Same outputs/hashes, or documented nondeterminism | Two build logs | `make clean` (authorized only), `make` | AUTH-BUILD | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-01 | V4 | Boot/menu/selection→round→return; [`ARCHITECTURE.md`](../docs/ARCHITECTURE.md) screen flow | ORIG and a build that must not change behavior | `regress.sh` p1random runs; inspect screenshots and timeline | Identical screens and timeline | Screenshots; `timeline.txt` | `regress.sh`, `compare_roms.sh`, `cdl.lua` | AUTH-TEST | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-02 | V4 | Ryu versus CPU Ryu, canonical single-player flow; `README.md`, ARCHITECTURE | ORIG versus behavior-preserving build | `regress.sh` default p1random scenarios | Identical screens, APU hash and timeline | Comparison output | `regress.sh` | AUTH-TEST | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-03 | V4 | Input edge, weak/strong promotion, special-command recognition; [`BUGS.md`](../docs/BUGS.md) §2, FORMATS §13 | ORIG versus behavior-preserving build | `regress.sh` p1random includes specials, but no dedicated assertion exists | Command recognition occurs; no regression in screens/timeline | Screenshots; timeline | `regress.sh` (indirect only) | AUTH-TEST | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-04 | V4 | Movement; FORMATS §8 | ORIG versus behavior-preserving build | Scripted random play; inspect screenshots/timeline | Movement behavior unchanged | Screenshots; timeline | `regress.sh` (indirect only) | AUTH-TEST | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-05 | V4 | Attacks, collision, damage; FORMATS §10–§11 | ORIG versus behavior-preserving build | Scripted random play; inspect screenshots/timeline | Hit/collision/damage behavior unchanged | Screenshots; timeline | `regress.sh` (indirect only) | AUTH-TEST | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-06 | V4 | Projectiles; FORMATS §12 | ORIG versus behavior-preserving build | Scripted random play; inspect screenshots/timeline | Projectile behavior unchanged | Screenshots; timeline | `regress.sh` (indirect only) | AUTH-TEST | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-07 | V4 | Round timer, KO, draw, extra round; FORMATS §11; `regress.sh` scenarios | ORIG versus behavior-preserving build | Scenarios with forced energy and timer holds | KO/time-over/draw/extra-round path unchanged | Screenshots; timeline | `regress.sh` scenarios 2, 4, 5 | AUTH-TEST | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-08 | V4 | Soft reset; [`BUGS.md`](../docs/BUGS.md) §1 | FIX with `FIX_SOFT_RESET`; reset at chosen frames | `reset_test.sh <rom> <frame> <out>` | `$B1` continues after reset; no freeze | `reset.txt`; before/after screenshots | `reset_test.sh`, `reset_test.lua` | AUTH-TEST + AUTH-EMU | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-09 | V4 | Baseline comparison for unchanged behavior; `docs/TOOLS.md` | Two ROMs that should be identical in behavior | `compare_roms.sh A B plan frames seed interval pokes` | Identical screenshots, APU hash and timeline | Comparison output; differing screenshots | `compare_roms.sh` | AUTH-TEST + AUTH-EMU | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-10 | V4 | Relocatability; `docs/TOOLS.md` “Relocation test” | Build from shifted banks | `shift_test.sh` then `regress.sh` on the shifted ROM | Game behavior identical to ORIG in all 5 matches | Shift ROM; regression output; byte-diff count | `shift_test.sh`, `regress.sh` | AUTH-BUILD + AUTH-TEST + AUTH-EMU | PROPOSED — NOT RUN (D-05 PENDING) |
| REG-11 | V4 | Versus mode; [`BUGS.md`](../docs/BUGS.md) 2P finding, `MODE_VERSUS` | FIX with `MODE_VERSUS`; explicit scope decision | `p2join` scenario and manual access | Versus works as specified; no effect on single-player | Screenshots; timeline; manual notes | `regress.sh`, `compare_roms.sh` | AUTH-TEST + AUTH-EMU | PROPOSED — CONDITIONAL (Gate C / D-05) |
| MAN-01 | V5 | Ryu core manual acceptance; `README.md`, BUGS §2 | CANON or ORIG; explicit manual authorization | Play the documented Ryu moveset and record inputs | Documented behavior observed; pass/fail per criterion | Video or `.mmo`; notes | Mesen or MAME | AUTH-MAN | PROPOSED — CONDITIONAL (Gate C / D-05) |
| MAN-02 | V5 | Soft-reset manual confirmation; BUGS §1 | FIX with `FIX_SOFT_RESET` | Press RESET at documented frames; observe restart | Game restarts; no freeze | Video or screenshots | Mesen | AUTH-MAN | PROPOSED — CONDITIONAL (Gate C / D-05) |
| MAN-03 | V5 | Versus manual acceptance; BUGS 2P finding | FIX with `MODE_VERSUS`; explicit scope decision | Select versus; play both controllers | Versus reachable and playable; no single-player regression | Video or `.mmo` | Mesen | AUTH-MAN | PROPOSED — CONDITIONAL (Gate C / D-05) |
| MAN-04 | V5 | RetroArch/fceumm selection bug; BUGS “not investigated” | Any ROM; emulator-dependent | Reproduce selection problem in RetroArch/fceumm | Defect documented or reproduced; distinguish game versus emulator issue | Video; emulator version/config | RetroArch/fceumm | AUTH-MAN | PROPOSED — CONDITIONAL (Gate C / D-05) |

**Case count:** 45 cases — V0: 2 (`TRC-01`–`TRC-02`); V1: 12 (`FMT-01`–`FMT-12`); V2: 8 (`GEN-01`–`GEN-08`); V3: 8 (`BLD-01`–`BLD-08`); V4: 11 (`REG-01`–`REG-11`); V5: 4 (`MAN-01`–`MAN-04`).

### 6.2 Existing tool coverage table

All entries were derived by **reading source and documentation only**; no tool was executed in Phase 5.

| Script/tool | Declared purpose | Assertions actually made (static reading) | Scenarios covered | Gaps/risks | Execution status |
|---|---|---|---|---|---|
| `tools/mesen/compare_roms.sh` | Run two ROMs with same inputs; compare screens, sound and timeline | `cmp -s` on every `shots/*.png`; `cmp -s` on `apu.txt`; `cmp -s` on `timeline.txt`; exits 1 if any differ; requires at least one screenshot | Whatever the chosen `cdl.lua` plan produces; used by `regress.sh` with p1random and p2join | Pixel identity is emulator-sensitive; no semantic assertions (damage values, hitboxes, command recognition); timeline watches only 9 addresses; APU is a write hash every 60 frames, not audio; CANON versus ORIG is expected to differ | `EXISTS — NOT RUN in Phase 5` |
| `tools/mesen/regress.sh` | 5-match battery against the original ROM | 5 `compare_roms.sh` calls: p1random 12000/seed 3/interval 200; p1random 9000/seed 22 with P1 full and P2 at 1; p1random 9000/seed 7; p1random 9000/seed 24 with both at `$40` and periodic timer reset; p2join 9000/seed 27 with energy holds. Fails if any comparison fails; prints `REGRESSAO OK` only then | Free play; KO/time win; another seed; time over/draw/extra round; perfect/3 rounds/controller 2 | Oracle is identity to ORIG, so only valid for changes that must not alter behavior; does not prove correctness against a written spec; no per-mechanic assertion; historical runtime about 8 minutes | `EXISTS — NOT RUN in Phase 5`; historical result for the shifted build is cited in `docs/TOOLS.md` “Relocation test” |
| `tools/shift_test.sh` | Relocate a bank by 1 byte and build | Inserts `.byte $EA` at segment start; removes 1 byte of trailing `$FF` fill; assembles all `src/*.s`; links `build/shift/sf2ne_shift_<banks>.nes`; prints the `cmp -l` byte-difference count against ORIG (counted with `wc -l`) | Any listed bank or `all` (`$37 $3B $3F`) | Does not assert behavior; behavior is proven only by a following `regress.sh`; byte-diff count is informational; no automatic pass/fail | `EXISTS — NOT RUN in Phase 5` |
| `tools/mesen/reset_test.sh` + `reset_test.lua` | Press RESET at a chosen frame and verify restart | Writes `reset.txt` with bank at `$E000`, PC, `$B0` and `$B1` every 100 frames after reset; compares `$B1` samples and prints `RESULTADO: o jogo continua rodando` or `RESULTADO: TRAVOU`; saves `antes.png` and `depois.png` | One reset frame per invocation (`SF2_RESET_AT`, default 2500, wait 700) | `$B1` movement is a proxy for “running”, not proof of a correct restart; one frame per run; no audio/video comparison; requires Mesen | `EXISTS — NOT RUN in Phase 5`; historical results in `docs/BUGS.md` §1 |
| `tools/mesen/run_trace.sh` | Run one Lua script headless | Sets environment, invokes Mesen `--testrunner`, writes to the output directory; does not assert; prints `mesen exit=` on failure | Any `SF2_SCRIPT` (default `cdl.lua`), plan, frames, seed, shots and pokes | Runner, not oracle; timeout derived from frame count; requires Mesen and settings | `EXISTS — NOT RUN in Phase 5` |
| `tools/mesen/cdl.lua` | Code/data log, edges, readers, RAM map, CHR writes, screenshots, first-seen, timeline, APU hash | Writes artifacts; no pass/fail; timeline watches `$B0,$B8,$10,$11,$B2,$12,$13,$00,$01`; APU hash every 60 frames | Plans `attract`, `idle`, `p1random`, `p2join` | Coverage is trace-dependent; no assertion | `EXISTS — NOT RUN in Phase 5`; historical trace set in `trace/README.txt` |
| `tools/mesen/ptrtrace.lua` | Discover pointers by origin tracing | Writes `ptr.txt`; only sees executed paths | Plans `p1random` and others via `run_trace.sh` | No assertion; coverage limited to executed code | `EXISTS — NOT RUN in Phase 5` |
| `tools/mesen/batch1.sh`, `batch2.sh`, `batch3.sh`, `batch_ptr.sh` | Trace batches | Orchestrate `run_trace.sh` runs; no assertions | Coverage and pointer batches | No oracle; output must be merged and inspected | `HISTORICAL RESULT — trace/README.txt` (29 merged runs) |
| `tools/disasm.py` | Project generator (`make gen`) | Emits `src/`, `sf2ne.cfg`, `assets/`, `scratch/static_blocks.txt`; contains `.assert` for alt sizes, kernel start and `FarCall`; prints per-bank statistics and warnings; does not compare output with ORIG by itself | Whole ROM generation | Destructive to generated outputs; warnings are not failures; requires generation authorization | `HISTORICAL RESULT — tasks/PHASE_3_EXECUTION_REPORT.md §10.3` |
| `tools/trace_merge.py` | Merge raw emulator runs into `trace/` | Rewrites `trace/` from the given inputs; no assertions | Any set of raw runs; always pass all runs | Destructive to `trace/`; no oracle | `HISTORICAL RESULT — trace/README.txt` |
| `tools/state_data_gen.py` | Gate C TOML→ca65 converter (prototype) | Validates required fields, duration range constants and references; writes only the given output; emits `.byte`/`.word` | Sample state/frame TOML in `data/estados/` | Non-canonical and unvalidated; no round-trip or baseline comparison; not part of `make gen` | `EXISTS — NOT RUN in Phase 5` |
| `tools/comparar_estados.py` | Gate C comparator (prototype) | `.byte` exact; `.word` label → `[1,1]`, zero → `[0,0]`; compares lengths and bytes; prints `EQUIVALENTE` or a difference count | Original versus generated assembly sample | **Cannot prove exact pointer equivalence**; `.word` is zero/non-zero only; strips `-1`; not sufficient as sole oracle | `EXISTS — NOT RUN in Phase 5` |
| `tools/datamap.py` | List data ranges and read/typed/untouched status | Read-only report; no assertions | Bank data ranges | Report only | `EXISTS — NOT RUN in Phase 5` |
| `tools/frame_census.py` | Census of frame bytes from ROM | Read-only report; reachable frames only | Animation frame data | Report only; reachability depends on traces | `EXISTS — NOT RUN in Phase 5` |
| `tools/ptr_candidates.py` | List suspicious immediate pairs | Read-only candidate list; no assertions | Pointer candidates | Manual review only | `EXISTS — NOT RUN in Phase 5` |
| `tools/poke_prg.py` | Patch a copy of a ROM | Writes an output copy; asks for confirmation unless `--force`; `- SAIDA BASE` copies without patch | Experiment ROMs | Mutates a copy; not an oracle | `EXISTS — NOT RUN in Phase 5` |
| `tools/show.py` | Show a routine with callers and screens | Read-only report | Routine inspection | Report only | `EXISTS — NOT RUN in Phase 5` |
| `tools/sheet.py`, `tools/extract_chr.py`, `tools/extract_dpcm.py` | Export graphics and voices | Write PNG, WAV and `INDICE.txt` | Asset export | Not a validation oracle | `EXISTS — NOT RUN in Phase 5` |
| `tools/mesen/setup_mesen.sh` | Download Mesen 2.1.1 and prepare headless mode | Downloads/unzips; writes settings; no validation | Emulator setup | Network and emulator-version dependent | `EXISTS — NOT RUN in Phase 5` |
| `Makefile` targets (`make`, `make verify`, `make gen`, `make fixed`, `make prontos`, `make gen-states`, `make assets`) | Build/generate/export | `make` assembles CANON; `make verify` compares with ORIG and warns only; `make gen` regenerates destructively; `make fixed` builds variants; `make prontos` builds four ROMs; `make gen-states` writes `src/`; `make assets` exports | Build and generation flows | `make verify` does not fail on divergence; `make gen` and `make gen-states` write into `src/`; requires explicit authorization | `EXISTS — NOT RUN in Phase 5`; historical `make`/`make gen`/`make fixed` results in `tasks/PHASE_3_EXECUTION_REPORT.md §10.3` |

### 6.3 Authorization matrix

| Activity | Permission needed before doing it | Default in Phase 5 |
|---|---|---|
| Read source, docs, script text, committed traces/reports | Phase 5 documentation gate | Allowed, read-only (`AUTH-READ`) |
| Create/edit tests, harnesses, comparators or generators | Separate implementation authorization (`AUTH-STATIC`) | Not authorized |
| Run `make gen`, state generator, assembler/linker or any build | Explicit build/generation authorization and artifact scope (`AUTH-GEN`, `AUTH-BUILD`) | Not authorized |
| Run regression/shift/reset scripts or other validation tools | Explicit test authorization, including target ROM and outputs (`AUTH-TEST`) | Not authorized |
| Launch Mesen/MAME or execute ROM | Explicit emulator/runtime authorization and scenario (`AUTH-EMU`) | Not authorized |
| Manual gameplay acceptance | Explicit manual-test authorization, ROM and evidence plan (`AUTH-MAN`) | Not authorized |
| Inspect arcade ROM/port behavior | Separate REA authorization; does not imply transfer of code/data | Not part of Phase 5 |
| Adopt or integrate the Gate C TOML prototype | Separate Maintainer decision plus implementation authorization (`AUTH-GATEC`) | Not authorized; prototype remains non-canonical and unvalidated |

---

## 7. Prioritization and risk

Order by risk and dependency, not by ease of running a script.

| Priority | Case IDs | Risk if omitted | Likelihood/impact | Dependencies | Blocking or informational |
|---|---|---|---|---|---|
| **P0 — data integrity** | `TRC-01`–`TRC-02`, `FMT-01`–`FMT-12` | Silent loss of unknown data, wrong pointer target, source-of-truth ambiguity | Medium likelihood / high impact if state/frame authoring is adopted | Schema, D-02, exact `.word` oracle | Blocking for any future format adoption; informational while no migration is authorized |
| **P1 — build safety** | `BLD-01`–`BLD-08`; `GEN-01`–`GEN-08` only if Gate C is authorized | Nondeterministic build, bank overflow, duplicate symbols, historical hash mistaken for current proof | Medium / high | Build authorization; Gate C decision for GEN | Blocking for any future build claim |
| **P2 — core regression** | `REG-01`–`REG-10`, `MAN-01`–`MAN-02` | Undetected regression in boot, fight, input, collision, damage, projectile, round end or reset | Medium / high | Test, emulator and manual authorizations | Blocking for any future “behavior unchanged” claim |
| **P3 — optional/conditional** | `REG-11`, `MAN-03`, `MAN-04`; any Ken scenario if later authorized | Unvalidated optional path presented as accepted | Low–medium / medium | Explicit scope decision, `MODE_VERSUS`, emulator-specific evidence | Informational; must not block P0/P1/P2 |

Notes:

- A low-risk feature suite must not block the critical preservation checks.
- `REG-11`, `MAN-03` and `MAN-04` are conditional and are not part of default acceptance.
- Ken-vs-Ken, Ken AI, new moves, new modes and full Ken acceptance are **not** in this plan. CPU remains Ryu.

---

## 8. Evidence and reporting rules

- A script’s presence is not a result.
- A previous report proves only the artifact/configuration/date it describes.
- Every future `PASS`/`FAIL` must link to a run record with base commit, tested commit, ROM hash, command, configuration, tool version and retained evidence.
- Report `BLOCKED` where the needed permission or prerequisite is missing; do not silently skip the case.
- Report `NOT RUN` rather than imply success for cases not executed.
- Keep manual and automated outcomes distinct.
- Never claim arcade equivalence or clean-room implementation correctness based on NES regression alone.
- Retain evidence: logs, output, screenshots, video, `.mmo`, hashes, maps, traces.
- Clean up generated test artifacts according to the run record; never delete pre-existing user data.

---

## 9. Preserved boundaries

### 9.1 Artifact boundaries

ORIG, CANON, FIX, HIST-P3 and HIST-KEN are distinct. A hash is valid only for the artifact, commit and configuration that produced it. No historical hash is a current pass criterion.

### 9.2 Ryu core versus optional behavior

- **Core (P2):** boot/menu/selection, Ryu versus CPU Ryu, input edge/promotion/special recognition, movement, attacks/collision/damage, projectiles, timer/KO/rounds, soft reset.
- **Optional/conditional (P3):** versus mode (`MODE_VERSUS`, `p2join`), RetroArch/fceumm behavior, any future Ken scenario.
- **Excluded:** Ken-vs-Ken, Ken AI, new moves, new modes, full Ken acceptance, arcade-derived AI, roster expansion.

### 9.3 Gate C prototype

`tools/state_data_gen.py`, `tools/comparar_estados.py`, `data/estados/*` and `make gen-states` exist as a **non-canonical, unvalidated prototype** outside the canonical flow. Validation of these tools requires a separate authorization and a review of their limitations. In particular, `comparar_estados.py` checks `.byte` exactly but treats `.word` as zero/non-zero; that is **not sufficient evidence of exact pointer equivalence**. No adoption is implied.

### 9.4 Content pause

Ken remains paused. Frames are in bank `$04`; partial states are in hand-written bank `$05`. The historical Ken delivery (`843a869e…`, commit `fccaae6`) is chronology, not current status. No new character, feature, mode, stage, music or ending is authorized by this plan.

---

## 10. Open decisions and exact permissions still needed

| Decision | State | What it would authorize | What this plan does |
|---|---|---|---|
| **D-05** — which future validations are authorized, by whom, and in what scope | `PENDING` | Build/generation, test/script execution, emulator runtime and manual acceptance within a defined scope | Proposes cases and permissions; resolves nothing |
| **D-06** — external asset tools | `PENDING` | Evaluation/integration of external converters | Out of scope |
| **D-07** — kernel/bank organization | `PENDING` | Kernel refactoring | Out of scope |
| **Gate C** — TOML prototype adoption | Not authorized | Integration of the prototype into the canonical flow | Marks it non-canonical and conditional |

Exact permissions still needed before any execution:

1. `AUTH-STATIC` — create/run static schema validators or exact comparators.
2. `AUTH-GEN` — run `make gen`, `make gen-states` or any generator.
3. `AUTH-BUILD` — run assembler/linker, `make`, `make fixed`, `make prontos`.
4. `AUTH-TEST` — run `regress.sh`, `compare_roms.sh`, `shift_test.sh`, `reset_test.sh` or other validation scripts.
5. `AUTH-EMU` — launch Mesen/MAME or execute a ROM.
6. `AUTH-MAN` — perform manual gameplay acceptance.
7. `AUTH-GATEC` — adopt/integrate the Gate C prototype, including a new exact `.word` oracle.

No authorization is inferred from this plan. D-05 remains `PENDING` until explicit Maintainer approval.

---

## 11. Delivery report mapping (spec §12)

When Phase 5 documentation is delivered, report:

1. Remote base commit and worktree-preservation method.
2. Files created/updated.
3. Validation levels and test-case ID ranges proposed.
4. Scripts reviewed and their actual coverage/gaps, with all statuses marked not run or historical.
5. How the Gate C prototype and its comparator limitation are handled.
6. D-05 status and exact permissions still needed.
7. Explicit confirmation that no tool, test, build, emulator or ROM validation was executed.
