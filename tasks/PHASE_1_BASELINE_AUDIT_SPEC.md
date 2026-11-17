# Technical specification — Phase 1: reproducible audit of current state

**Status:** ready for the Software Engineer to execute after entry gate.  
**Project:** Street Fighter II NE (`daniel-castilho/sf2nes`).  
**Origin:** Phase 1 of `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.  
**Prerequisite:** Phase 0 completed and accepted per `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md`.  
**Type of work:** static inspection and baseline documentation.  
**Build, compilation, ROM execution, tests, emulator, and code changes:** out of scope and not authorized by this specification.

## 1. Objective

Produce a verifiable, dated portrait of repository state, sources of truth, naming indicators, bank occupancy as documented, existing validation utilities, and document divergences.

The audit must allow later phases to make decisions based on reproducible data, without confusing:

- current counts with historical published numbers;
- code with data;
- address-generated labels with semantic names;
- existing scripts with approved tests;
- validation documentation with executed validation;
- planned work with authorized or completed work.

## 2. Required output

Create a main document:

- `docs/PROJECT_STATUS.md`

The document must be sufficient for someone to repeat purely textual counts using the criterion described in this specification and understand what remains unconfirmed because it requires build, execution, or out-of-scope inspection.

Optionally, update only corresponding states/links in:

- `tasks/STABILIZATION_BACKLOG.md`, if the file already exists by Phase 0 conclusion.

Do not correct divergences in other documents in this phase. Register them in the report for prioritization by the later documentary phase.

## 3. Entry gate and tree preservation

Before starting, the Engineer must:

1. confirm Phase 0 was accepted; if not, stop and report the block, without executing the audit;
2. record local date/time, commit hash (`HEAD`) and working tree summary state;
3. separate preexisting modified/untracked files from files produced by the task;
4. preserve all existing changes. It is forbidden to use `clean`, `reset`, `restore`, destructive checkout, or equivalent;
5. read current versions of input documents listed in §4, not trusting old conversation transcriptions.

If an output file already exists, do not replace it entirely: compare, keep local content, and add/update only the relevant section, registering the divergence.

## 4. Sources to inspect

### 4.1 Project core

- `README.md`
- `Makefile`
- `sf2ne.cfg`
- `annotations/sf2ne.ann`
- `src/bank_*.s` and `src/*.inc`
- `docs/ARCHITECTURE.md`
- `docs/FORMATS.md`
- `docs/RAM.md`
- `docs/ROADMAP.md`
- `docs/BUGS.md`
- `docs/TOOLS.md`

### 4.2 Tools and working documents

- `tools/` and `tools/mesen/` — reading names, arguments, inputs/outputs, and comments; **do not execute**;
- `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`;
- `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md`;
- `tasks/STABILIZATION_BACKLOG.md`, if existing;
- Ken, Guile, and arcade REA specifications, only to detect scope restrictions/duplications; do not alter content of these specifications.

Do not inspect or execute the arcade ROM in this phase. Arcade REA is a separate track.

## 5. Audit procedure

### 5.1 Provenance and tree state

In `docs/PROJECT_STATUS.md` header, register:

- audit date;
- `HEAD` commit examined;
- whether tree was clean or modified;
- which areas/files had relevant local changes, without attributing them to the audit;
- scope limitations: no assembly, execution, emulation, or testing performed in this audit.

Do not include credentials, sensitive configuration content, private user paths, or secret values.

### 5.2 Inventory of sources of truth and generated artifacts

Build a table with columns:

| Area | Declared canonical source | Generated/derived file/artifact | Current update method | Observation/risk |

Cover at minimum:

- labels/comments/corrections and `annotations/sf2ne.ann`;
- generator and `src/` files;
- build configuration and flow;
- state/frame data and structures;
- source assets vs `extracted/`;
- reference ROM and output/versioned ROMs;
- trace/validation scripts and their evidence artifacts.

When documents disagree about canonical source, register divergence; do not choose a new source by inference.

### 5.3 Label metrics

Calculate metrics from currently generated source files in `src/`, without executing generator or assembler. Register exact method (glob, parser/regex, exclusions, command/script version used) to allow repetition.

Report separately:

1. **global label definitions** found in `src/bank_*.s`;
2. **total occurrences** and **unique names** — do not assume they are equal;
3. labels generated from addresses, in exact generator-defined pattern (e.g., code families `L<bank>_<address>` and data `D<bank>_<address>`); confirm pattern in generator before counting;
4. semantic labels, defined for this audit as global labels not matching the confirmed automatic bank/address pattern;
5. count by bank and category, distinguishing code/data only when classification can be sustained by annotations/generator; otherwise register category `unclassified`;
6. local/temporary labels, anonymous labels, constants, and RAM symbols as separate categories or explicitly out of main metric.

Rules:

- Do not use README's published number as current result without recalculating.
- Do not sum overlapping categories nor use total labels as single quality measure.
- If a label is duplicated across banks, report occurrences and unique symbols separately.
- Do not create a permanent tool nor modify `tools/` in this phase. If a reproducible metric cannot be obtained by simple textual inspection, describe the block and propose a tool in a future decision; do not improvise a parser that alters or generates sources.
- Do not rename any label.

### 5.4 Bank occupancy and space

Register published map in `docs/ARCHITECTURE.md` and `docs/ROADMAP.md`, including:

- banks described as code, data, assets, music, or empty;
- published free/occupied byte values, when existing;
- method and historical evidence sustaining each number, if documented;
- divergences between documents.

As compiling/linking nor ROM execution is not allowed, **do not recalculate occupancy from a new linker map, do not generate build, and do not declare current space revalidated**. Identify values as "published in documentation, not revalidated in this audit" when no current static source is sufficient.

Clearly separate:

- specific bank local limitation (e.g., code concentrated in bank `$3B`);
- total remaining PRG capacity;
- kernel/vector requirements conditioning code placement;
- statements of different dates or versions/builds.

### 5.5 Script inventory and validation claims

Read `tools/mesen/`, `tools/` and documents referencing build/regression/relocation/tests. Do not execute scripts.

For each identified item, register:

| Tool/script | Declared purpose | Inferred inputs/outputs from reading | Covered scenario/claim | Existing execution evidence | Audited status |

Use controlled states:

- `EXISTS — not executed in this audit`;
- `DOCUMENTED HISTORICAL EXECUTION` (only if verifiable record exists in present documents/artifacts);
- `UNKNOWN STATUS`;
- `DOCUMENTED, ARTIFACT ABSENT`.

Do not turn script presence into approval. Do not run Mesen/MAME, shell scripts, assembler/linker, `make`, regression, shift/relocation test, or manual test. Do not produce new ROM, map, trace, or video.

### 5.6 Documentary consistency matrix

Compare README, roadmap, architecture, formats, RAM, bugs, tools, and task specifications. For each relevant conflict or ambiguity, register:

| ID | Claim/subject | Document A | Document B | Category | Risk | Proposed destination |

Minimum categories:

- status/scope;
- count/metric;
- source of truth/generation;
- bank/build capacity;
- format/semantics;
- validation/test;
- character/IA restriction.

The audit must not correct these documents. "Proposed destination" field is recommendation, not approved decision. Do not mark interpretation as fact if sources do not allow resolving it.

### 5.7 Backlog and pending decisions

If `tasks/STABILIZATION_BACKLOG.md` exists, update only:

- Phase 1 status to `AUDIT COMPLETED — DOCUMENT DELIVERED`, without indicating approved tests;
- relative links to new report;
- decisions D-01–D-07 with state/evidence only when audit brings information, preserving them as pending until Maintainer decision.

If backlog does not exist because Phase 0 was not executed, this is entry block; do not create backlog on behalf of Phase 0 within this task.

## 6. Mandatory `docs/PROJECT_STATUS.md` structure

1. **Audit metadata and limitations** — date, commit, modified/clean tree, activities not performed.
2. **Executive summary** — only audit facts; separate confirmed items from historical/unknown.
3. **Sources of truth and generated artifacts**.
4. **Label metrics** — reproducible method, categories, totals, limitations.
5. **Bank map and documented capacity** — explicit revalidation status.
6. **Tool/validation inventory** — no new approval claim.
7. **Inconsistency matrix** — stable IDs and involved documents.
8. **Pending decisions** — backlog reference, if exists.
9. **Limitations and recommended next steps** — without implementing or choosing canonical source.
10. **Source index** — relative internal paths, counting method, consulted files.

## 7. Writing and evidence rules

Each significant statement must be labeled by context, e.g.:

- **Confirmed by static inspection in this audit**;
- **Previously published, not revalidated now**;
- **Inferred from name/structure — hypothesis**;
- **Unknown/pending**.

Avoid expressions like "tested", "passes", "works currently", or "validated" without existing identifiable evidence. Preserve distinction between original ROM version, optional builds, and already-versioned `.nes` files.

## 8. Out of scope

- Correcting or rewriting README, roadmap, architecture, formats, bugs, or specifications; registering divergences for later work.
- Changing scope, resolving pending decisions, or authorizing new characters/features.
- Altering annotations, assembly, scripts, tools, assets, configs, or ROMs.
- Creating permanent audit tools in this phase.
- Executing generator, assembler, linker, build, Mesen, MAME, tests, regression, shift/relocation, or manual validation.
- Inspecting or validating arcade ROM, porting AI, or incorporating external data.

## 9. Acceptance criteria

- [ ] Phase 0 entry gate verified; otherwise task interrupted and reported as blocked.
- [ ] `docs/PROJECT_STATUS.md` exists and contains all §6 sections.
- [ ] Label metrics report method, files, patterns, exclusions, occurrences, and unique names.
- [ ] No label metric depends on number copied from README/roadmap without recalculation.
- [ ] Bank occupancy identified as documentary/historical or current static; no new linker map produced.
- [ ] Existing scripts and validations inventoried by reading, without execution or approval claim.
- [ ] Divergences have IDs, references, and proposal; not silently corrected.
- [ ] Each claim status distinguishes current confirmation, historical data, hypothesis, and unknown.
- [ ] No file outside §2 output list was altered.
- [ ] No build, test, emulator, validation script, or artifact-generating command was executed.
- [ ] Preexisting local state preserved.

## 10. Engineer delivery report

Upon closing, the Engineer must inform:

1. Phase 0 prerequisite confirmation;
2. files created/altered;
3. exact method used for label metrics and results per category;
4. which occupancy values are only historical/documented;
5. scripts inventoried and status, without inferring they were executed;
6. highest-risk divergences and where they should be resolved;
7. decisions still pending;
8. explicit statement that code/ROM/tools were not altered, nothing compiled, no build/test/emulator executed, and local changes preserved.
