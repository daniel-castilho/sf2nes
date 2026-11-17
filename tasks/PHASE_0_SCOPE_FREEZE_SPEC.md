# Technical specification — Phase 0: scope freeze and preparation

**Status:** ready for the Software Engineer to execute; documentation only.  
**Project:** Street Fighter II NE (`daniel-castilho/sf2nes`).  
**Origin:** Phase 0 of `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.  
**Date:** 2026-11-10.  
**Type of change authorized by this specification:** documentation and backlog registration only.  
**Build, compilation, ROM execution, testing, and code changes:** out of scope and not authorized.

## 1. Objective

Record unequivocally that the project begins a stabilization and maintainability phase, during which new characters and game features remain paused. Separate the work into distinct tracks — maintenance, REA/documentation, and content — and create a small record of pending decisions, without prematurely resolving decisions that belong to later phases.

The pause means **postponement, not cancellation** of existing roadmap items. Content work continues to be documented, but it is not the next active execution.

## 2. Sources to consult

Before editing, the Engineer must read the current versions of these files and verify that references remain correct:

- `README.md` — project summary and indication of next work;
- `docs/ROADMAP.md` — stages, status, and scope decisions;
- `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` — global plan originating this phase;
- `tasks/KEN_IMPLEMENTATION_SPEC.md` — current Ken scope, only to maintain consistency; do not edit in this Phase 0;
- `tasks/GUILE_BEHAVIORAL_ENGINEERING_SPEC.md` and `tasks/ARCADE_AI_CLEAN_ROOM_REA.md` — references to independent work, only when necessary to avoid mixing scopes; do not edit in this Phase 0.

If the local tree or files differ from this specification, register the divergence in the delivery report and ask for a decision; do not silently overwrite local content.

## 3. Permitted files

The Engineer may alter only the following files:

1. `docs/ROADMAP.md` — declare the current phase, register the pause, and label future content stages as paused, preserving existing history and instructions.
2. `README.md` — update only the priority/next-work indication and point to the roadmap and this plan, without rewriting historical claims about results already obtained.
3. `tasks/STABILIZATION_BACKLOG.md` — create the work-track and pending-decision record described in §5.

No other file may be modified in this phase. In particular, do not edit `src/`, `annotations/`, `tools/`, `assets/`, `rom/`, `prontos/`, build configuration, character implementation specifications, nor the arcade REA report.

## 4. Required changes

### 4.1 `docs/ROADMAP.md`

Add at the beginning of the roadmap a brief section **"Current phase — stabilization and maintainability"** containing:

- objective: facilitate understanding, authorship, and maintenance of what already exists;
- pause statement: new characters and game features are not active work in this phase;
- relative links to `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` and `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md`;
- indication that the next active tasks will be chosen after the Phase 1 documentation audit, not presumed from the old roadmap order.

In future stages related to Ken, content tools, stages/music/endings, and other features:

- add a visible label `PAUSED — outside current phase` (or equivalent formulation);
- preserve lists, technical notes, and status boxes already present;
- do not mark incomplete items as completed, cancelled, or approved;
- do not reorder or rewrite the completed history of Stage 0/1/2.

If there is an old textual recommendation of the type "next stage is implement Ken", adjust it to reflect that Ken is paused and that its current specification was not cancelled.

### 4.2 `README.md`

Update only the block guiding the reader about "what is still missing" or the next step, to:

- identify stabilization/maintainability as the current focus;
- say that implementation of new characters and features is paused, not cancelled;
- point to `docs/ROADMAP.md` and to the stabilization plan/spec;
- keep descriptions of capability, historical experiments, and build/test state as historical statements, without promoting them to newly-verified results.

Do not execute commands cited in the README to confirm statements; this task is only documentary.

### 4.3 `tasks/STABILIZATION_BACKLOG.md`

Create the file with three separate tracks, an initial state, and the pending-decision record.

#### Track A — stabilization/maintainability (active as planning)

Register as candidates, without presuming implementation approval:

- Phase 1 — reproducible audit of metrics, sources of truth, documentation, banks, and existing validations;
- Phase 2 — specification of the text authoring format for states/frames and decision on canonical source;
- Phase 3 — naming driven by criticality and evidence;
- Phase 4 — documentary reconciliation and technical decision registration;
- Phase 5 — future validation proposal, without executing tests.

Refer to the global plan instead of duplicating complete requirements.

#### Track B — REA and technical documentation (research/documentation, separate)

Register separately:

- static REA of arcade AI and respective clean-room specification;
- conclusion of Ken gap analysis in the identified arcade revision, when that work is resumed;
- documentation of NES engine formats/hypotheses, when prioritized by the audit.

This track does not authorize porting bytecode, data, or arcade code to the project, nor executing the arcade ROM. Do not present REA as NES implementation.

#### Track C — content and features (paused)

Register as paused, not cancelled:

- Ken implementation as playable character, per its current specification;
- any Ken-specific AI on NES;
- implementation of other characters;
- new screens, controls, modes, moves, stages, music, endings, or other game functions;
- asset production/conversion and tools directly tied to content creation, until a later decision.

This track must not rewrite or alter Ken's specification; it must reference it.

#### Pending decisions

Include at least the items below, each with **ID**, **question**, **state**, **decision owner** (Maintainer), **evidence/input needed** and **blocks**:

| ID | Question to resolve | Evidence/input needed | Blocks |
|---|---|---|---|
| `D-01` | What reproducible method will be used to count total labels, code/data labels, and semantically named labels? | Phase 1 source inventory and classification criteria. | Naming metrics and future comparison. |
| `D-02` | What will be the canonical source for state/frame authoring: annotations, ca65 macros, or external declarative format? | Phase 2 inventory of formats/exceptions and maintenance comparison. | Implementing converter or migrating data. |
| `D-03` | Which routines/tables will be the first naming batch, and what minimum evidence makes a name acceptable? | Criticality and evidence map gathered in Phases 1/3. | Renaming campaign. |
| `D-04` | What criteria and explicit decision reopen character/feature implementation? | Maintainer priorities and conclusion of stabilization. | Resuming Track C. |
| `D-05` | What future validations will be authorized, by whom, and in what scope? | Phase 5 validation proposal and explicit authorization. | Creating/running tests, builds, or emulator validation in future work. |
| `D-06` | Will external asset tools be evaluated and when? | Content need, availability, and license review. | Integrating external converters. |
| `D-07` | Is there a measurable need to change kernel/bank organization? | Phase 1 space audit, vector requirements, and cycle constraints. | Any kernel refactoring. |

All items start as `PENDING`. The backlog does not resolve them on its own nor treat absence of decision as approval. Entries must remain concise; detailed technical plans belong to the global plan or a dedicated specification.

## 5. State and language rules

- Use **ACTIVE** only for work effectively authorized and in execution; work merely listed remains `PLANNED` or `CANDIDATE`.
- Use **PAUSED** for content that remains desired but cannot start in this phase.
- Use **PENDING** for decisions still without an answer.
- Do not use "ready", "validated", "tested", or "approved" to indicate that documentation was merely written.
- Approval of this Phase 0 does not authorize any Gate A–E of the global plan beyond the documentary editing defined here.

## 6. Out of scope

- Resolving decisions D-01 to D-07.
- Executing the Phase 1 audit.
- Designing or implementing the text format, converters, or naming batch.
- Making changes to code, annotations, tools, assets, ROMs, or configuration.
- Compiling, assembling, executing, or testing ROM; running Mesen/MAME or regression/relocation scripts or validation.
- Editing Ken's specification, Guile's specification, or the arcade REA.
- Resuming arcade AI or transferring arcade findings to the NES game.

## 7. Working state preservation

Before editing, verify and record the working directory state. Inspection must not discard changes. Preserve all existing modified or untracked files; do not run `clean`, `reset`, `restore`, destructive checkout, or equivalent. If one of the three permitted files already has local changes, edit only the necessary sections and report the conflict/diff for review.

## 8. Acceptance criteria

- [ ] The roadmap clearly declares the current phase and the content pause, without cancelling the old backlog.
- [ ] Future character and feature stages are labeled as paused, without changing the status of completed stages.
- [ ] The README points to the current priority and planning documents without claiming newly-executed validations.
- [ ] `tasks/STABILIZATION_BACKLOG.md` contains the three separate tracks and decisions D-01 to D-07 as pending.
- [ ] Each future task is correctly classified as active, planned/candidate, paused, or pending; no decision is implicitly taken.
- [ ] Internal links are relative and point to existing files.
- [ ] Only the files permitted in §3 were altered or created.
- [ ] No code, data, asset, configuration, ROM, or tool was altered.
- [ ] No build, test, emulator, or ROM validation was executed.
- [ ] The delivery reports altered files, included text summary, divergences found, and confirmation of limits respected.

## 9. Required delivery report

Upon completion, the Engineer must return:

1. exact list of files created/altered;
2. summary of pause statements and the three tracks registered;
3. pending decisions (D-01–D-07);
4. divergences found between README, roadmap, and specifications; not resolved without authorization;
5. explicit confirmation that code/ROM/tools were not altered, nothing compiled, and no tests or emulator were executed.
