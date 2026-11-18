# Technical Specification — Phase 4: Documentation Reconciliation and Decision Registration

**Status:** ready for Software Engineer planning/execution after the entry gate; this document does not authorize edits by itself.  
**Project:** `daniel-castilho/sf2nes`.  
**Origin:** Phase 4 of `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.  
**Remote baseline inspected:** `main` at `9a6c9f88cb965f8409114d8818d4b38a47cf0b88` (2026-11-17); if remote `main` has advanced when execution begins, use and record the newer remote commit.  
**Prerequisites:** Phases 0–3 completed; Phase 3 closeout and Phase 2 D-02 acceptance recorded in the current remote main.  
**Work type:** documentation-only reconciliation and source-of-truth/decision traceability.  
**Code, tools, assets, ROM, build, tests, emulator:** out of scope and not authorized.

## 1. Objective

Reduce the cost of resuming project work and prevent different documents from giving incompatible instructions. Reconcile the current project status, document ownership, evidence/confidence labels, tool interfaces and pending decisions using the completed Phase 1 audit and Phase 3 closeout as inputs.

Phase 4 does not redo completed work. It must preserve the history and evidence in `docs/PROJECT_STATUS.md` and `tasks/PHASE_3_EXECUTION_REPORT.md`, while ensuring current summaries point to the right conclusions. Where available evidence is insufficient, the Engineer must retain an explicit limitation instead of guessing or triggering a build/test/emulator run.

## 2. Current remote-main baseline and entry gate

The specification was prepared against remote `main` commit `9a6c9f88cb965f8409114d8818d4b38a47cf0b88`, which contains the Phase 1 audit, Phase 2 TOML decision/schema/migration plan, Phase 3 naming inventory and closeout, coding standards, project status and stabilization backlog.

Before execution, the Engineer must:

1. fetch/check the remote repository `https://github.com/daniel-castilho/sf2nes.git` or its configured equivalent;
2. record remote `main` SHA and local `HEAD`; do not use a stale local branch as evidence of current status;
3. use a clean, isolated worktree or otherwise preserve all pre-existing local changes; do not overwrite a dirty working tree to catch up;
4. confirm the Phase 3 execution report still records completion and that D-01/D-03 are resolved, D-02 is accepted, and D-04–D-07 remain pending;
5. stop and report any changed status or file rename that invalidates this specification.

Do not use `reset`, `clean`, `restore`, force checkout, or any destructive synchronization.

## 3. Documentation responsibility matrix

Maintain one source of truth for each kind of statement. Avoid duplicating long technical explanations across files.

| Document | Canonical responsibility | Must not become |
|---|---|---|
| `README.md` | Concise project overview, current focus, current headline status and links | Detailed audit, duplicate technical specification or unsupported test claim |
| `docs/PROJECT_STATUS.md` | Audited metrics, provenance, known inconsistencies, limitations, current status and evidence index | A new implementation plan or a claim that an unexecuted validation passed |
| `docs/ROADMAP.md` | Project stages, pause/resume status and future direction | A second copy of detailed engineering specifications |
| `docs/ARCHITECTURE.md` | Hardware, banks, runtime structure and system-level design | Unverified current linker occupancy or speculative behavior stated as fact |
| `docs/FORMATS.md` | Data-record formats and semantics supported by evidence | Unsupported certainty for fields explicitly marked open |
| `docs/FORMATS_OPEN.md` | Unresolved format/behavior questions and evidence needed | A competing canonical definition that silently overrides `FORMATS.md` |
| `docs/RAM.md` | RAM symbol/address map and confidence/usage information | Unsubstantiated count or stale duplicate variable descriptions |
| `docs/BUGS.md` | Defect, impact, fix/status and validation evidence | Gameplay feature backlog or claim of approval without evidence |
| `docs/TOOLS.md` | Tool purpose, interfaces, inputs/outputs/options and execution status | Proof that a tool works merely because its file exists |
| `docs/CODING_STANDARDS.md` | Coding/naming conventions and architectural rules | Conflicting operational status or authorization policy |
| `docs/lessons.md` | Incident narrative and lessons learned, with its historical context | Current project status or a general feature specification |
| `tasks/*` specifications/reports | Bounded task requirements, decisions and execution evidence | A second canonical architecture or undocumented scope changes |
| `tasks/STABILIZATION_BACKLOG.md` | Track status and open decisions D-04–D-07 | Resolution of those decisions without explicit Maintainer input |

If two documents reasonably need the same fact, keep the authoritative explanation in one file and link to it from the other.

## 4. Evidence and confidence language

Use status terms consistently in edited sections and new claims:

- **CONFIRMED — STATIC:** directly supported by current source, annotations, schema or unambiguous structure inspected in the recorded repository revision.
- **CONFIRMED — EXISTING TRACE:** supported by a trace already in the repository; name the trace/source and scenario. Do not imply a new emulator run.
- **HISTORICAL VALIDATION:** prior build/test/acceptance result with date, commit and artifact/command recorded in an existing report; do not imply it was rerun in Phase 4.
- **HYPOTHESIS:** interpretation not fully established; retain the reason and what would resolve it.
- **UNKNOWN / NOT REVALIDATED:** no sufficient evidence within this documentation-only phase.
- **PENDING DECISION:** requires Maintainer choice; lack of objection is not approval.

Do not relabel an old validation as current without rerunning it under separate authorization. Preserve `(nt)`, `hypothesis`, and open-point markers where relevant; translate/standardize wording only when meaning remains unchanged.

## 5. Required reconciliation work

### 5.1 Resolve or accurately carry forward the Phase 1 inconsistency matrix

Review `docs/PROJECT_STATUS.md` §7 and address each entry below. Keep stable IDs and retain an explanation of how each status was reached.

| ID | Required Phase 4 disposition | Allowed evidence/action in this phase |
|---|---|---|
| `IN-01` label count | Keep as **RESOLVED by Phase 3**. Confirm current summary links to the canonical metric and no current-status paragraph repeats the superseded `1,795 / 304` claim. Preserve historical sections as dated history where they explain prior state. | Read current `PROJECT_STATUS.md`, README and Phase 3 report; no recount is needed unless a discrepancy is found. |
| `IN-02` named-variable count | Reconcile the old README claim against `src/ram.inc` and `docs/RAM.md`, or explicitly keep the count `NOT REVALIDATED` if the category/definition is ambiguous. Do not infer from the number of `ram` directives alone. | Static inspection of current RAM declarations and documented naming method only. No trace/test. |
| `IN-03` unexecuted-code percentage | Treat the 14–17% as historical unless an existing committed trace and documented counting method directly support a current figure. If not, replace current-tense wording with the historical/unknown status and record what would be needed. | Inspect existing `trace/` artifacts and documentation only; do not run `datamap.py`, generate traces or start Mesen. |
| `IN-04` inter-bank call totals | Reconcile the documented “52 farcall / 7 farjmp” count with the current annotations/generator or mark the number historical/unverified. Do not update to a new total without a repeatable static method. | Read annotations and generator logic; no code-generation run. |
| `IN-05` `$3B` free-space estimate | Keep the bank-specific constraint distinct from total PRG capacity. Mark “~120 bytes free/full” and total empty-bank figures as published/documented, not revalidated, unless an already committed current linker map proves otherwise. | Existing docs/configuration only. No build or new linker map. |
| `IN-06` canonical build versus original ROM | Preserve the explanation that the canonical build intentionally differs if current `Makefile`/README still agree; ensure original-ROM identity and modified-build identity are not conflated. | Static reading of the current Makefile and existing status record; do not build or hash a new ROM. |
| `IN-07` Ken frames versus state bank | Clarify the distinction between Ken graphics/frames in bank `$04` and state data/source in bank `$05`; remove apparent contradiction without implying new playable content or changing Ken’s scope. | Static cross-reference to current architecture, project status and Ken task spec. |
| `IN-08` Phase 3 convention cross-reference | Verify the convention citation in `tasks/PHASE_3_EXECUTION_REPORT.md` §10.4. If it points to the wrong section, correct only the citation to the actual sources (expected: `docs/CODING_STANDARDS.md` §2 and `tasks/NAMING_CANDIDATES.md` §4), preserving the Phase 3 result and history. | Check actual headings in the current remote files before editing. |

`IN-02`–`IN-07` do not all have to become resolved facts. Closing an item as `NOT REVALIDATED` with a clear reason, current safe wording and evidence needed is acceptable when resolution would require prohibited validation. Do not mark a limitation as “resolved” merely because the claim was softened.

### 5.2 Preserve Phase 3 chronology while fixing current references

- `tasks/PHASE_3_EXECUTION_REPORT.md` §1–§9 contain a historical checkpoint; §10 is the later consolidated closeout and prevails for final metrics/status.
- Do not rewrite intermediate metrics to match the final numbers without keeping their historical date/context.
- Final naming status to reference is the Phase 3 closeout in §10 and current `docs/PROJECT_STATUS.md` §11: 2,145 label definitions, 2,140 unique names, 1,254 semantic, 886 automatic data, no automatic code labels, with the documented same-line/duplicate caveats.
- The 715 renamed labels and the 886 automatic data labels deliberately retained are not permission to start another naming batch in Phase 4.
- Correct the convention citation only after inspecting the section headings in the current `CODING_STANDARDS.md` and `NAMING_CANDIDATES.md`.

### 5.3 Format and behavior confidence markers

Audit only statements that Phase 4 touches or that are high-risk references in the inconsistency matrix. For each, identify whether the evidence is static, an existing trace, historical validation, hypothesis, unknown or pending.

- Use `docs/FORMATS.md` for the current field/behavior description and `docs/FORMATS_OPEN.md` for unresolved semantics.
- Do not expand this phase into a new REA of the arcade ROM, a reanalysis of all NES code, or a full rewriting of the format document.
- If a detail requires runtime evidence not already available, keep it open and cite the evidence needed; do not run emulator or tests.
- Preserve the distinction between NES implementation facts and the separate arcade clean-room REA.

### 5.4 Tool interfaces and limits

Review `docs/TOOLS.md` against source text and annotate discrepancies in the status matrix. For each tool interface that is edited, document:

- exact relative path/name;
- purpose;
- accepted arguments/options and defaults, when visible in source/help text;
- inputs read and outputs/artifacts written;
- generated versus hand-maintained files;
- destructive side effects, if any;
- error/failure behavior only when evident from code or existing documentation;
- execution status (`not executed in Phase 4`, historical record, or unknown).

Do not run a tool to learn its behavior. Do not claim the documented interface is runtime-verified solely from source inspection; label it static. Do not create a new tool, test, trace, or artifact.

### 5.5 Decision register and work status

- Update `tasks/STABILIZATION_BACKLOG.md` only if Phase 4 dispositions or links need recording.
- Keep D-01 and D-03 `RESOLVED`; keep D-02 `ACCEPTED` as external TOML for future state/frame authoring, with converter/migration still unauthorized.
- Keep D-04, D-05, D-06 and D-07 `PENDING` unless the Maintainer makes an explicit decision outside this specification.
- The Phase 4 status itself may be changed to `DOCUMENTATION RECONCILIATION COMPLETED` only when all Phase 4 acceptance criteria pass; it must not imply implementation/build/test approval.
- Do not change the content pause, Ken’s scope, the CPU Ryu decision or the arcade REA boundaries.

## 6. Permitted files

Edit only files needed to resolve a specific inconsistency or add a necessary canonical link/status. Expected files are:

- `README.md`
- `docs/PROJECT_STATUS.md`
- `docs/ROADMAP.md`
- `docs/ARCHITECTURE.md`
- `docs/FORMATS.md`
- `docs/FORMATS_OPEN.md`
- `docs/RAM.md`
- `docs/BUGS.md`
- `docs/TOOLS.md`
- `docs/CODING_STANDARDS.md`
- `docs/lessons.md`
- `tasks/PHASE_3_EXECUTION_REPORT.md` (citation correction only)
- `tasks/STABILIZATION_BACKLOG.md` (status/links only)

This list is not authorization to edit every file. The delivery must list each file changed and tie it to an IN-ID or a documented source-of-truth correction. Do not edit code, annotations, generator, state data, assets, ROM, Makefile, linker configuration, or character implementation specifications.

## 7. Required deliverables

1. **Reconciled `docs/PROJECT_STATUS.md`**: updated inconsistency dispositions, evidence-status wording, links and next steps; retain audit/phase chronology and Phase 3 final section.
2. **Targeted summary updates** in README/Roadmap or technical docs only where they contradict the reconciled status; link to the canonical details instead of duplicating them.
3. **Resolved reference correction** in the Phase 3 report, if current headings confirm the reported citation error.
4. **Decision/backlog status** with D-04–D-07 still pending unless explicitly resolved by Maintainer.
5. **Delivery report** listing exact diffs, each claim/status changed, evidence consulted, unresolved limitations and confirmation of prohibited actions not performed.

Do not add a second “current status” document. `docs/PROJECT_STATUS.md` remains the central audit/status artifact unless a later approved decision changes that responsibility.

## 8. Out of scope and authorization boundaries

- Re-running Phase 1 metrics or Phase 3 naming batches; renaming additional labels.
- Rewriting historical execution reports or erasing dated intermediate results.
- Implementing TOML parsing/conversion, migrating Ryu/Ken state data, modifying `make gen`, or changing the canonical source design.
- Resolving D-04–D-07 on behalf of the Maintainer.
- Changing project scope, implementing characters/features, or reopening Ken implementation.
- Reanalyzing arcade AI or transferring arcade code/data/assets into the NES project.
- Editing source, annotations, tools, configuration, assets or ROMs.
- Running `make`, `make gen`, assembler/linker, any script, test, regression, shift/relocation check, Mesen, MAME or gameplay validation.
- Producing new ROMs, maps, traces, screenshots, audio or other generated artifacts.

## 9. Acceptance criteria

- [ ] Execution used the latest fetched remote `main` or a recorded descendant; the base commit is documented.
- [ ] Pre-existing local changes were preserved; no destructive Git operation was used.
- [ ] Every Phase 1 inconsistency ID `IN-01`–`IN-07` has a current disposition and evidence/status; `IN-08` was checked and corrected only if wrong.
- [ ] The final Phase 3 metrics and 715-label result are referenced from the closeout, not re-derived with a different denominator.
- [ ] Intermediate Phase 3 metrics remain explicitly historical; they are not silently overwritten.
- [ ] Document responsibilities are consistent with §3 and no long duplicate technical specification was introduced.
- [ ] Claims touched in Phase 4 are marked as static, existing-trace, historical, hypothesis, unknown or pending as appropriate.
- [ ] Tool documentation is based on source/document inspection only and does not claim newly verified execution.
- [ ] D-01/D-03 remain resolved, D-02 accepted, and D-04–D-07 remain pending absent explicit Maintainer decision.
- [ ] Ken remains paused under current scope; no new character/game feature or arcade-to-NES transfer was introduced.
- [ ] No source/tool/ROM edit, build, test, emulator run or generated artifact was performed.
- [ ] Every changed file is allowed in §6 and tied to a specific reconciliation item.
- [ ] `docs/PROJECT_STATUS.md` remains the single current audit/status entry point.

## 10. Engineer delivery report

At completion, report:

1. remote base commit and whether it is still the latest `main`;
2. files changed and the IN-ID or responsibility correction each serves;
3. before/after wording for current-status claims, without deleting historical context;
4. evidence type for each disposition and unresolved items retained as unknown/pending;
5. Phase 3 citation result and correction, if any;
6. D-04–D-07 status;
7. explicit confirmation that no code/tools/assets/ROM were changed and no build, test, script, emulator or validation was run.
