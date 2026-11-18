# Technical Specification — Phase 5: Future Validation Plan

**Status:** ready for Software Engineer to prepare a validation plan; this phase is specification/documentation only.  
**Project:** `daniel-castilho/sf2nes`.  
**Origin:** Phase 5 of `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.  
**Remote baseline inspected:** `main` at `c344034865b5b43e00d767995c1dd8de9cd72e5b` (2026-11-17). If remote `main` advances before execution, fetch and record the newer remote commit.  
**Prerequisites:** Phases 0–4 completed; Phase 4 documentation closeout recorded in `docs/PROJECT_STATUS.md` §12.  
**Phase output:** a proposed validation plan with cases, preconditions, expected evidence and owners.  
**Tests, builds, emulator runs and validation execution:** not authorized by this specification.

## 1. Objective

Define what should be verified, how evidence should be recorded, and which permission is required before any validation is run. The deliverable is a future validation plan; it is not an execution report and must not report results that have not been produced.

The plan should distinguish:

- static/source or schema checks;
- generator and data-format integrity;
- build/link integrity;
- regression of already-existing behavior;
- manual acceptance of behavior explicitly in scope;
- historical verification versus a new run;
- a script/tool being present versus it being executed successfully.

The project’s current content pause remains in effect. Phase 5 must not become a reason to implement Ken, add features, expand the roster, build arcade-derived AI or integrate the TOML prototype into the canonical workflow.

## 2. Current remote baseline and authorization boundary

The current remote inspected for this specification is `main` at `c344034865b5b43e00d767995c1dd8de9cd72e5b`. Before a future execution, the Engineer must fetch the actual remote and record the latest base commit. Do not rely on a stale local `main`.

At this baseline:

- Phases 0–4 are recorded as completed in the stabilization backlog.
- D-01 and D-03 are resolved; D-02 is accepted for external TOML as a future state/frame authoring source.
- D-04, D-05, D-06 and D-07 remain pending.
- D-05 explicitly blocks creation/running of tests, builds or emulator validation until the Maintainer authorizes a defined scope.
- `tools/state_data_gen.py`, `tools/comparar_estados.py`, and `data/estados/*` exist as a Gate C prototype outside the canonical flow; they are documented as unvalidated and not authorized for adoption.
- Existing historical Phase 3 build/SHA-1 results remain historical evidence for that naming work, not proof that current `main` or future code passes validation.

This Phase 5 specification **does not resolve D-05**. Completing the plan does not authorize any build, test, script, emulator, test harness, generated artifact or manual gameplay check.

## 3. Entry requirements for the future Engineer

Before preparing the validation plan:

1. Fetch/check current remote `main`; record remote SHA, local `HEAD`, and any divergence.
2. Use an isolated worktree or preserve the current working tree and all pre-existing local changes.
3. Read the current versions of `docs/PROJECT_STATUS.md`, `docs/TOOLS.md`, `docs/BUGS.md`, `docs/FORMATS.md`, `docs/FORMATS_OPEN.md`, `docs/ROADMAP.md`, `tasks/STABILIZATION_BACKLOG.md`, the Phase 2 TOML decision/schema/migration plan, and the Phase 3 execution report.
4. Inventory candidate scripts by reading source/docs only; do not execute them.
5. Stop and report if the remote status changes the scope, the known Gate C prototype has entered the canonical flow, D-05 was explicitly decided, or local changes conflict with planned documentation.

## 4. Required deliverable

Create:

- `tasks/PROJECT_VALIDATION_PLAN.md`

It must contain the sections and matrices below. It should link to canonical docs instead of duplicating test instructions already maintained elsewhere.

If this file already exists, preserve it and propose a focused update; do not overwrite it. If `tasks/STABILIZATION_BACKLOG.md` is updated, change Phase 5 only to `PLAN PROPOSED — D-05 PENDING` (or equivalent); do not mark tests approved or passed.

## 5. Validation levels to plan

The plan should use distinct levels. Each level records candidate checks and future permission needed; no level is executed as part of Phase 5.

### V0 — Evidence and requirement traceability

Purpose: ensure a future result can be tied to a specific requirement and artifact.

Plan for each validation case to identify:

- stable case ID;
- requirement/feature and authoritative source;
- artifact/build variant and commit/hash under test;
- setup, initial state and preconditions;
- exact inputs or procedure;
- expected outcome/oracle and whether it is exact, comparative or qualitative;
- tool/version/configuration;
- evidence to retain (logs, output, screenshots, video, `.mmo`, hashes, maps, traces);
- cleanup or restoration procedure for generated test artifacts, without deleting pre-existing user data;
- status and authorization reference.

### V1 — Static format and source consistency

Candidate future coverage:

- TOML schema syntax and type checks;
- presence and uniqueness of symbols/record IDs;
- references resolve to a defined state/frame/metasprite/collision record or an explicitly permitted null/terminal value;
- distinction among numeric zero, null, omitted field, end sentinel and loop target;
- normal versus loop-frame shape, including the documented variable record length;
- preservation of raw integers and comments for unknown/hypothesis fields;
- inclusion of unreachable/orphan records where the authoring set requires them;
- source-of-truth boundary: annotations remain for labels/comments/patches; the TOML source is only used for approved state/frame data;
- no undocumented data is silently normalized or discarded.

The current prototype is not canonical and is marked unvalidated. The plan must explicitly state that validation of `state_data_gen.py` or `comparar_estados.py` requires a separate authorization and a review of their current limitations. The currently documented comparator checks `.byte` values exactly but treats `.word` values as zero/nonzero; that is **not sufficient evidence of exact pointer equivalence**.

### V2 — Generation and structural equivalence

Only if a future Maintainer decision authorizes integration (Gate C), propose checks for:

- deterministic output for identical canonical inputs;
- generator does not overwrite or ignore authored TOML;
- generated assembly contains exactly one authoritative copy of each converted record;
- resolved symbolic pointers and bank associations are correct;
- all known fields, raw unknown values, nulls, sentinels, loop branches and orphan records are preserved;
- exact byte/record comparison against the selected approved baseline, including exact `.word` targets—not merely zero/nonzero equivalence;
- generation is repeatable and does not change unrelated banks/assets/configuration;
- rollback to the previous generation flow remains possible.

The proposed plan must identify an oracle and limitations for each check. Do not assume that the current comparison prototype is a sufficient oracle.

### V3 — Build and link integrity

If and only if a separate Maintainer authorization permits build/link execution, propose:

- cleanly identified build configuration and flags;
- expected outputs and their hashes/maps/labels to record;
- bank-window, vector, assertion and size constraints to inspect;
- separate treatment of the original reconstruction, canonical modified build, optional `FIXDEFS` variants and versioned ROMs;
- expected, intentional differences from the original ROM, so a different SHA-1 is not misreported as a failure;
- handling of build errors, unexpected bank overflow, duplicate symbols and generated-file drift.

No current baseline hash should be copied forward without confirming its commit/configuration and role. Historical hashes in Phase 3 report `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` and the original-ROM hash identify specific historical artifacts; neither proves a future artifact is valid.

### V4 — Automated regression of existing behavior

Inventory existing scripts by reading their implementation and documentation. Candidate suites can include:

- boot/menu/selection to round start and return path;
- Ryu versus CPU Ryu on the canonical supported single-player flow;
- input edge, weak/strong promotion and special-command recognition where documented as existing behavior;
- movement, attacks, collision, damage, projectiles, round timer, KO/round transitions and soft-reset behavior where a requirement already exists;
- versus mode only for variants/configurations explicitly supported and authorized;
- comparison against a named baseline for behaviors that should remain unchanged.

For each suite, the proposed plan must specify which existing script can cover it, what that script actually asserts, blind spots, expected runtime/artifacts and failure diagnostics. Do not infer coverage from a script name or from `docs/TOOLS.md`; confirm semantics by source reading only, without running it.

Do not add Ken-vs-Ken, Ken AI, new moves, new modes, or full Ken implementation acceptance to this suite by default. Any Ken scenario is conditional on an explicit future scope decision and a requirement already accepted by the Maintainer. The current known constraint that CPU remains Ryu must be preserved.

### V5 — Manual emulator acceptance

For future authorized manual cases, specify:

- emulator/version and controller/configuration;
- ROM/build variant, commit and cryptographic hash;
- initial menu/round/state and exact human input sequence or reproducible movie;
- observed result and pass/fail criteria;
- evidence artifact (short video, `.mmo`, screenshots/logs where appropriate);
- how to distinguish a game defect from an emulator/configuration issue.

Manual checks are not approved by this plan. No Mesen/MAME launch or gameplay validation is permitted during Phase 5 specification work.

## 6. Coverage and status matrices

### 6.1 Test case table

`tasks/PROJECT_VALIDATION_PLAN.md` must include at least:

| ID | Level | Requirement/source | Variant/preconditions | Procedure/input | Oracle/expected result | Evidence | Tool/interface | Authorization required | Status |
|---|---|---|---|---|---|---|---|---|---|

Use stable IDs (for example, `FMT-*`, `GEN-*`, `BLD-*`, `REG-*`, `MAN-*`) and avoid one giant “smoke test” with no traceability.

### 6.2 Existing tool coverage table

| Script/tool | Declared purpose | Assertions actually made (static reading) | Scenarios covered | Gaps/risks | Execution status |
|---|---|---|---|---|---|

Allowed execution-status values for the plan:

- `EXISTS — NOT RUN in Phase 5`;
- `HISTORICAL RESULT — cite report/commit/artifact`;
- `NOT DOCUMENTED / UNKNOWN`;
- `NOT APPLICABLE`.

Do not write `PASS` for a proposed test. `PASS` is only valid in a later execution report with dated evidence and explicit authorization.

### 6.3 Authorization matrix

| Activity | Permission needed before doing it | Default in Phase 5 |
|---|---|---|
| Read source, docs, script text, committed traces/reports | Phase 5 documentation gate | Allowed, read-only |
| Create/edit tests, harnesses, comparators or generators | Separate implementation authorization | Not authorized |
| Run `make gen`, state generator, assembler/linker or any build | Explicit build/generation authorization and artifact scope | Not authorized |
| Run regression/shift/reset scripts or other validation tools | Explicit test authorization, including target ROM and outputs | Not authorized |
| Launch Mesen/MAME or execute ROM | Explicit emulator/runtime authorization and scenario | Not authorized |
| Manual gameplay acceptance | Explicit manual-test authorization, ROM and evidence plan | Not authorized |
| Inspect arcade ROM/port behavior | Separate REA authorization; does not imply transfer of code/data | Not part of Phase 5 |

## 7. Prioritization and risk

The Engineer should order proposed validation by risk and dependency, not by ease of running a script:

1. **P0 — data integrity:** source-of-truth boundaries, pointer/reference preservation, no silent loss of unknown data.
2. **P1 — build safety:** deterministic generation, bank/link integrity, expected differences and baseline identification.
3. **P2 — core regression:** boot, match flow, input, movement, hit/damage, projectile, round end/reset where already specified.
4. **P3 — optional/conditional behavior:** versus, state-format prototype, Ken behavior or other paths only when their requirements and authorization are explicit.

For each proposed check record risk if omitted, likelihood/impact estimate, dependencies, and whether a failure is blocking or informational. Do not let a low-risk feature suite block the critical preservation checks.

## 8. Evidence and reporting rules

- A script’s presence is not a result.
- A previous report proves only the artifact/configuration/date it describes.
- Every future `PASS`/`FAIL` must link to a run record with base commit, tested commit, ROM hash, command, configuration, tool version and retained evidence.
- Report `BLOCKED` where the needed permission or prerequisite is missing; do not silently skip the case.
- Report `NOT RUN` rather than imply success for cases not executed.
- Keep manual and automated outcomes distinct.
- Never claim arcade equivalence or clean-room implementation correctness based on NES regression alone.

## 9. Files and preservation

For future execution of Phase 5 documentation, allowed edits are limited to:

- `tasks/PROJECT_VALIDATION_PLAN.md` (new plan);
- `tasks/STABILIZATION_BACKLOG.md` (Phase 5 status/link only, if necessary).

Do not change `docs/TOOLS.md` or project sources merely to make the plan convenient; identify gaps and propose later changes. Preserve all pre-existing modifications and untracked files. Do not run `clean`, `reset`, `restore` or destructive checkout.

## 10. Out of scope

- Running any validation, even a supposedly read-only test or smoke test.
- Creating/updating test scripts, test harnesses, comparators, converters or CI.
- Building ROMs, generating source, running assemblers/linkers or producing artifacts.
- Launching Mesen/MAME or manually testing gameplay.
- Marking D-05 resolved; approval of a future test plan remains an explicit Maintainer decision.
- Implementing the TOML converter, moving state/frame data, or making the prototype canonical.
- Implementing Ken, Ken AI, other characters, new features, or changing controls/gameplay scope.
- Using arcade ROM data/code/assets or conflating the arcade REA with NES validation.

## 11. Acceptance criteria for Phase 5 specification

- [ ] The Engineer verifies a current remote-main base; the SHA is recorded.
- [ ] `tasks/PROJECT_VALIDATION_PLAN.md` exists and includes V0–V5 or documented, justified exclusions.
- [ ] Cases have stable IDs, source requirement, setup, procedure, oracle, evidence and permission need.
- [ ] Existing validation tools are mapped to their actual assertions by static inspection; none are executed.
- [ ] The Gate C TOML prototype is clearly marked non-canonical/unvalidated; the current `.word` comparator limitation is accounted for.
- [ ] Build/original/modified ROM baselines are distinguished; historical hashes are not treated as current pass criteria.
- [ ] Ryu core behavior and optional/conditional cases are separated; no automatic Ken-vs-Ken or Ken-AI requirement is introduced.
- [ ] Manual evidence and status vocabulary are specified.
- [ ] D-05 remains `PENDING` until explicit Maintainer approval; no authorization is inferred from this plan.
- [ ] The plan does not claim that tests/builds/emulator validation passed.
- [ ] No code, tool, asset, configuration, ROM or test file was altered; no test, build, script or emulator was run.
- [ ] Pre-existing local changes were preserved.

## 12. Engineer delivery report

At completion, report:

1. remote base commit and worktree-preservation method;
2. files created/updated;
3. validation levels and test-case ID ranges proposed;
4. scripts reviewed and their actual coverage/gaps, with all statuses marked not run or historical;
5. how the Gate C prototype and its comparator limitation are handled;
6. D-05 status and exact permissions still needed;
7. explicit confirmation that no tool, test, build, emulator or ROM validation was executed.
