# Execution plan — project stabilization and maintainability

**Status:** proposed plan; does not authorize implementation, build, or test execution.  
**Product decision:** pause new characters and features to reduce cost and risk of maintaining what already exists.  
**Project:** Street Fighter II NE (`daniel-castilho/sf2nes`).  
**Date:** 2026-11-10.  
**Audience:** project Maintainer and Software Engineer responsible for eventual execution.

## 1. Objective

Organize an internal improvement phase that makes the project easier to understand, edit, and validate, without expanding game content. The plan leverages valuable external suggestions, corrects recommendations incompatible with the existing flow, and postpones refactorings or features without demonstrated need.

The focus is:

1. establish a reliable portrait of current state and reconcile divergent documentation;
2. improve the way state and frame data are authored;
3. reduce code navigation cost with evidence-based naming;
4. leave hypotheses, sources of truth, and planned validations explicit;
5. prepare a future validation proposal without executing it in this stage.

## 2. Non-negotiable principles and limits

- **No new characters or features** during this phase. Do not implement new Ken states nor start another fighter.
- Ken scope decision remains: human P2, ID `1`; one-player CPU opponent remains Ryu; Ken-specific AI out of scope. No other character must be declared implemented.
- Arcade AI REA is separate research. No arcade code, bytecode, data, or asset may be copied into the project.
- `src/` is generated in the current flow. Do not freeze or informally edit these files; any source-of-truth swap requires documented decision and explicit migration.
- Do not use `clean`, `reset`, `restore`, or operations that discard local changes without authorization.
- This document **does not authorize** modifying sources, annotations, tools, assets, ROMs, compiling, running emulator, running tests, or validating gameplay. These actions require later authorization with specific scope.
- Tests and verifications cited ahead are future Engineer tasks, not authorization to execute them now.
- No percentage of named labels is an isolated success criterion. Priority is reducing ambiguity in routines and data that most hinder maintenance.

## 3. Critical reading of external suggestions

| Suggestion | Decision | Reason/treatment |
|------------|----------|------------------|
| Improve naming | **Adopt with focus** | Start with central routines, frequent calls, dispatchers, and shared RAM. Name only when evidence exists; keep hypothesis marked. |
| Create text format for states/frames | **High priority, specify before implementing** | Already in `docs/ROADMAP.md` as future tool. Use current Ryu data as reference case, without creating new content. Preserve a source of truth. |
| Freeze `src/` and edit generated assembly | **Not adopted informally** | Contradicts current `annotations` → generator → `src/` flow and may cause overwrite or divergence. Any future freeze needs ADR, migration plan, and explicit new canonical source indication. |
| Create Ken-specific tests | **Defer** | Idea may be useful when Ken is resumed, but Ken AI and Ken-vs-Ken conflict with current scope. Prepare only a future coverage proposal; do not create or execute tests now. |
| Create PNG→CHR and WAV→DPCM converters | **Defer** | Content production tools; do not reduce main immediate friction without art/audio demand. Before resuming them, verify tools, availability, licenses, and formats. |
| Extract kernel to dedicated bank | **Defer / not prioritize** | There are empty PRG banks, and roadmap already describes how to accommodate additional code. Kernel repetition serves vectors/interrupts and has cycle constraints; refactoring without measured need increases risk. |
| Difficulty/versus UI | **Out of this phase** | Player-visible functionality, not internal maintenance. |
| Plan new code banks | **Keep map, no preventive expansion** | `docs/ARCHITECTURE.md` and `docs/ROADMAP.md` already document occupancy and alternative for additional banks. Update only if current data diverge. |
| Document decisions and formats | **Adopt as ongoing work** | `docs/FORMATS.md`, `docs/ARCHITECTURE.md`, and hypothesis markings already exist; work is to reconcile and complete gaps with evidence, without duplicating content. |

## 4. Proposed execution order

The order below is deliberate: first measure and organize; then design the tool; only then alter the flow. No implementation phase starts automatically by approval of this plan.

### Phase 0 — freeze scope and prepare work

**Objective:** prevent content tasks from infiltrating the maintainability phase.

**Future activities**

- Register in `docs/ROADMAP.md` or an ADR the pause of new characters and features.
- Separate structural maintenance, REA/documentation, and game content into distinct lists.
- Create a pending-decision list, with owner and necessary evidence.

**Output:** agreed stabilization scope; no task in this phase may introduce a playable change.

**Gate:** Maintainer authorization before editing project documentation.

### Phase 1 — reproducible audit of current state

**Objective:** create a single reliable baseline, without inferring numbers from possibly outdated documents.

**Future activities**

- Inventory sources of truth: `annotations/sf2ne.ann`, generator, `src/`, `docs/`, scripts in `tools/`, and build configurations.
- Define how to count total labels, semantic names, code labels, and data labels. Document criterion to avoid comparing different categories.
- Reconcile README's published label count with roadmap notes and current generator output.
- Confirm bank map, free space, and kernel location, distinguishing per-bank occupancy from total PRG occupancy.
- Inventory comparison/regression scripts and documents mentioning them. Mark "existing", "documented", "previously executed", or "pending" only with available evidence; do not execute any script in this phase.
- Identify contradictions among README, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, `docs/FORMATS.md`, `docs/BUGS.md`, and task specifications.

**Proposed outputs**

- A current state record with metrics and counting criteria.
- A document → source of truth → divergence → proposed action matrix.
- An inventory of existing and pending validations, without new test results.

**Exit criteria**

- Numbers used in the plan are reproducible by a described method.
- "Code", "data", "generic label", and "semantic label" are not mixed into a single metric.
- No claim of approved test without existing evidence.

### Phase 2 — state and frame authoring format specification

**Objective:** define a human-readable format for current data, without altering its semantics or adding content.

**Future activities**

- Use `docs/FORMATS.md` as initial contract and list all fields, sizes, pointers, loops, sentinels, selection tables, and documented exceptions.
- Choose between ca65 macros and an external declarative entry (e.g., YAML/TOML/JSON) only after comparing readability, typing, validation, diffs, and integration with generator.
- Define how to represent symbolic labels, banks, relative/absolute pointers, optional fields, and hypotheses.
- Prohibit silent conversions of invalid values or loss of unknown fields.
- Specify how the generator reports errors with file/line/field and how it avoids overwriting canonical sources.
- Use first a representative subset of existing Ryu data to document coverage proof; do not create Ken states in this phase.

**Proposed outputs**

- Format ADR and explicit canonical source decision.
- Language/schema schema and record grammar.
- Stepwise existing-bank conversion plan, with documentary rollback.
- Structural equivalence criteria that the Engineer can verify after authorization.

**Exit criteria**

- All fields already documented in binary format have defined representation or a registered exception.
- Format does not require hand-editing generated `src/`.
- Specification separates original data from any future content.
- Conversion and verification are not executed by this plan.

### Phase 3 — evidence-guided naming

**Objective:** make the most expensive-to-navigate areas more understandable without producing speculative names.

**Suggested order**

1. Dispatchers, inter-bank calls, and central fight loop routines.
2. Character sheet loading, state change, input/commands, and shared movement.
3. Drawing, collision, damage, and other functions affecting many tables.
4. Character data/tables with recurrent function, always distinguishing code from data.
5. Rare auxiliary routines, only when touched by another authorized task.

**Naming rules**

- A semantic name needs static evidence, existing tracking annotation, or demonstrable data relationship.
- Do not replace generic label with "plausible" name without demonstrating function; mark uncertainties as hypothesis.
- Register shared RAM labels consistently with `docs/RAM.md`.
- Do not rename public symbols used by tools/scripts without controlled reference updates.
- Measure progress by coverage of critical named routines and ambiguity reduction, beyond global count.

**Proposed outputs**

- Prioritized list of critical labels and associated evidence.
- Future annotation/documentation changes generated by established flow.
- Before/after metrics produced with Phase 1 criterion.

**Exit criteria**

- New names are traceable to evidence.
- No direct divergent editing of generated `src/`.
- Goal is understanding/maintenance, not arbitrarily reaching 60–70% of total.

### Phase 4 — complete operational documentation and decisions

**Objective:** reduce project resumption cost and avoid different documents guiding incompatible actions.

**Future activities**

- Mark each format and behavior as confirmed, hypothesis, or unknown.
- Keep a documentation responsibility matrix: architecture describes structure; formats describe records/semantics; roadmap lists stages; bugs register defect and status; tasks specify point deliveries.
- Correct historical recommendations incompatible with current decisions, e.g., validations or scope changes already deferred.
- Register tool limits and interfaces: input files, output, options, whether generated, and expected error cases.
- Keep arcade REA in a separate document, without mixing it with NES data/implementation.

**Output:** consistent documentation, without duplicating functional specifications across multiple files.

**Exit criterion:** every critical fact has an identifiable source of truth and hypotheses remain explicitly signaled.

### Phase 5 — future validation proposal (specification only)

**Objective:** determine what should be verified when there is authorization and when content implementation is resumed.

**Future activities**

- Map what existing scripts claim to cover and which scenarios they do not cover, without executing them now.
- Propose distinct levels: generator/format integrity, structural data equivalence, build, regression of existing features, and manual acceptance in emulator.
- Define Ken cases only when implementation is resumed and respecting current scope; do not assume Ken-vs-Ken or Ken AI.
- Describe evidence required for any "approved" claim.

**Output:** validation plan with cases, preconditions, artifacts, and owner.

**Mandatory gate:** no automation is created and no test/build/emulator is executed without subsequent explicit authorization.

## 5. Work explicitly deferred or excluded

- Implementing Ken, Ken AI, new characters, or new playable moves/states.
- Adding difficulty/versus selection screen or any other new interface.
- Converting images/audio or integrating external asset tool.
- Extracting/refactoring kernel to dedicated bank.
- Changing bank layout only to anticipate hypothetical expansion.
- Redoing build or freezing `src/` without approved ADR.
- Running Mesen, MAME, regression, shift/relocation test, build, or manual test in this stage.
- Copying code, data, or assets from arcade or third-party ports.

Items may be reconsidered in future decisions, each with its own objective, risk, evidence, and scope.

## 6. Dependencies and risks

| Risk/dependency | Treatment |
|-----------------|-----------|
| Old metrics or different counting criteria | Define method in Phase 1 before setting goals. |
| `src/` and annotations diverge | Preserve generated flow; if canonical source changes, require ADR and explicit migration. |
| New format does not represent rare Ryu cases | Complete inventory of fields and exceptions before coding converter. |
| Speculative naming worsens documentation | Require evidence and register hypotheses instead of definitive names. |
| Documented tests appear as authorization to execute them | Repeat authorization gate in every execution specification. |
| Kernel refactoring disturbs vectors/IRQ timings | Defer until measurable need and specific compatibility/cycle plan exist. |
| External asset tools unavailable or inadequate license | Audit availability/license before including in future scope. |
| Arcade REA mixing into NES implementation | Keep documents and traceability separate; transport only authorized behavioral specifications. |

## 7. Decision gates

Each future execution phase requires an explicit Maintainer decision:

1. **Gate A — documentary audit:** authorizes reading and editing documentation; does not authorize code alteration or build/test execution.
2. **Gate B — format design:** authorizes producing format specification/ADR; does not authorize converter.
3. **Gate C — format implementation:** authorizes tool and data changes, with delimited input/output files; technical verifications only per express authorization.
4. **Gate D — naming:** authorizes annotation changes and symbolic source generation; any build/test continues dependent on specific authorization.
5. **Gate E — validation:** defines whether automated tests, build, emulator, or manual tests will be allowed, which files/artifacts, and which scenarios.

Approval of this document, by itself, **does not open any of these gates**.

## 8. Stabilization phase completion definition

The phase will be considered concluded only when:

- [ ] there is a verifiable baseline of labels, banks, tools, canonical sources, and validations;
- [ ] README, roadmap, architecture, formats, and bugs are consistent about project state;
- [ ] there is a documented decision on canonical state/frame authoring format and its generator;
- [ ] naming strategy prioritizes criticality and evidence, without arbitrary percentage goal;
- [ ] there is a future validation plan explicitly separated from authorization to execute it;
- [ ] new characters/features remain paused during the phase;
- [ ] no preexisting local change is discarded without authorization.

## 9. Recommended next action

First request **Gate A** to perform documentary audit and consolidate current metrics. After the baseline, decide whether the highest immediate return comes from text format specification or critical routine naming. Do not start converter, broad renaming campaign, test, build, or refactoring before that decision.
