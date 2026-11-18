# Stabilization backlog — Phase 0

**Origin:** `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md` and `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` (Phase 0).  
**Type:** planning document and pending-decision record.  
**No implementation, build, test, or emulator execution is authorized by this file.**

This backlog separates work into three distinct tracks. **D-01 and D-03 were resolved at Phase 3 closing (2026-11-16); D-02 was accepted on 2026-11-17; D-04 to D-07 remain `PENDING`.**

---

## Track A — stabilization/maintainability (candidates, without implementation approval)

- **Phase 1** — reproducible audit of metrics, sources of truth, documentation, banks, and existing validations → **AUDIT COMPLETED — DOCUMENT DELIVERED** (`docs/PROJECT_STATUS.md`, commit `ada6c6f`). No indication of approved tests.
- **Phase 2** — specification of text authoring format for states/frames and decision on canonical source → **DECISION ACCEPTED (D-02, 2026-11-17)** (`tasks/STATE_DATA_FORMAT_DECISION.md`, external TOML format; no implementation authorized). Did not block symbol naming.
- **Phase 3** — naming driven by criticality and evidence → **COMPLETED — REPORT DELIVERED** (`tasks/PHASE_3_EXECUTION_REPORT.md` §10; commits through `53b99f4`, full list in §10.1). **715 labels renamed; 886 data labels remain automatic** by scope decision.
- **Phase 4** — documentary reconciliation and technical decision registration.
- **Phase 5** — future validation proposal, without executing tests.

Refer to `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` and `docs/PROJECT_STATUS.md` instead of duplicating complete requirements.

---

## Track B — REA and technical documentation (research/documentation, separate)

Register separately:

- static REA of arcade AI and respective clean-room specification;
- conclusion of Ken gap analysis in the identified arcade revision, when that work is resumed;
- documentation of NES engine formats/hypotheses, when prioritized by the audit.

This track does not authorize porting bytecode, data, or arcade code to the project, nor executing the arcade ROM. Do not present REA as NES implementation.

---

## Track C — content and features (paused)

Register as paused, not cancelled:

- Ken implementation as playable character, per its current specification (`tasks/KEN_IMPLEMENTATION_SPEC.md`);
- any Ken-specific AI on NES;
- implementation of other characters;
- new screens, controls, modes, moves, stages, music, endings, or other game functions;
- asset production/conversion and tools directly tied to content creation, until a later decision.

This track must not rewrite or alter Ken's specification; it must reference it.

---

## Pending decisions

All items start as `PENDING`. The backlog does not resolve them on its own nor treats absence of decision as approval; resolutions below were recorded by explicit Maintainer instruction.

| ID | Question to resolve | State | Owner | Evidence/input needed | Blocks |
|----|---------------------|-------|-------|----------------------|--------|
| D-01 | What reproducible method will be used to count total labels, code/data labels, and semantically named labels? | RESOLVED | Maintainer | `docs/PROJECT_STATUS.md` §4/§11 and `tasks/PHASE_3_EXECUTION_REPORT.md` §10.2. | Naming metrics and future comparison. |
| D-02 | What will be the canonical source for state/frame authoring: annotations, ca65 macros, or external declarative format? | ACCEPTED (2026-11-17) | Maintainer | `tasks/STATE_DATA_FORMAT_DECISION.md` (external TOML). | Implementing converter or migrating data (still requires separate authorization). |
| D-03 | Which routines/tables will be the first naming batch, and what minimum evidence makes a name acceptable? | RESOLVED | Maintainer | P0/P1, P2, PAD, FamiTone2 and data batches `$3C` through `$04`; criteria in `tasks/NAMING_CANDIDATES.md` and batch reports. | Renaming campaign. |
| D-04 | What criteria and explicit decision reopen character/feature implementation? | PENDING | Maintainer | Maintainer priorities and stabilization conclusion. | Resuming Track C. |
| D-05 | What future validations will be authorized, by whom, and in what scope? | PENDING | Maintainer | Phase 5 validation proposal and explicit authorization. | Creating/running tests, builds, or emulator validation in future work. |
| D-06 | Will external asset tools be evaluated and when? | PENDING | Maintainer | Content need, availability, and license review. | Integrating external converters. |
| D-07 | Is there a measurable need to change kernel/bank organization? | PENDING | Maintainer | Space audit, vector requirements, and cycle constraints. | Any kernel refactoring. |

### Resolution record (2026-11-16; D-02 added 2026-11-17)

- **D-01 — RESOLVED.** Canonical method: `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s`, separating definitions from unique names and categories (code/data/semantic). The caveat of three labels with comment on the same line (`EdgeARel`, `EdgeBRel`, `EdgeBBtn`) is registered in `docs/PROJECT_STATUS.md` §11.
- **D-03 — RESOLVED.** First batch: P0/P1 (engine core), followed by P2/PAD/FamiTone2 and data batches `$3C` through `$04`. Minimum evidence: demonstrable consumer, table structure, or existing documentation; confidence HIGH/MEDIUM; LOW remains automatic.
- **D-02 — ACCEPTED (2026-11-17).** Maintainer accepted the external declarative format (TOML) as canonical source for future state/frame authoring. Implementation, migration, build, and tests remain unauthorized. Phase 3 acted only on symbols, whose canonical source is `annotations/sf2ne.ann`.

---

## State and language rules

- **ACTIVE:** work effectively authorized and in execution.
- **PLANNED / CANDIDATE:** work merely listed, not yet authorized.
- **PAUSED:** content that remains desired but cannot start in this phase.
- **PENDING:** decision still without answer.
- **PROPOSED:** Engineer recommendation awaiting explicit Maintainer acceptance.
- **RESOLVED:** decision taken and recorded with evidence.
- Do not use "ready", "validated", "tested", or "approved" to indicate that documentation was merely written.

---

## Acceptance criteria (Phase 0)

- [ ] The roadmap clearly declares the current phase and the content pause, without cancelling the old backlog.
- [ ] Future character and feature stages are labeled as paused, without changing the status of completed stages.
- [ ] The README points to the current priority and planning documents without claiming newly-executed validations.
- [ ] This file contains the three separate tracks and decisions D-01 to D-07 as pending.
- [ ] Each future task is correctly classified as active, planned/candidate, paused, or pending; no decision is implicitly taken.
- [ ] Internal links are relative and point to existing files.
- [ ] Only the files permitted in §3 of the Phase 0 specification were altered or created.
- [ ] No code, data, asset, configuration, ROM, or tool was altered.
- [ ] No build, test, emulator, or ROM validation was executed.

> Historical Phase 0 checklist. For current decision state, see the table and resolution record above.
