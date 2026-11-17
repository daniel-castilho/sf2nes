# Technical specification — Phase 3: evidence-guided naming

**Status:** ready for detailing/future execution after entry gates; does not authorize changes in this conversation.  
**Execution status:** CONCLUDED on 2026-11-16; acceptance and reservations recorded in `tasks/PHASE_3_EXECUTION_REPORT.md` §10.4.  
**Project:** Street Fighter II NE (`daniel-castilho/sf2nes`).  
**Origin:** Phase 3 of `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.  
**Prerequisites:** Phase 0 accepted; Phase 1 completed with reproducible metric in `docs/PROJECT_STATUS.md`; Phase 2 completed with canonical source and generation flow decided/approved.  
**Type of future work:** documented triage and renaming of symbols in canonical flow.  
**Gameplay implementation, build, ROM, tests, and emulator:** out of scope and not authorized by this specification.

## 1. Objective

Improve navigability and understanding of existing code/data through semantic names sustained by evidence. Priority is reducing maintenance cost in central routines and tables; not reaching an arbitrary percentage of named labels.

Renaming is documentary/symbolic: it must not alter instructions, data bytes, pointers, ordering, address, execution flow, timing, or game behavior. Each new name must have sufficient evidence for another maintainer to understand why it was chosen.

## 2. Entry gates

Future execution must stop and be reported as blocked if any condition below is not satisfied:

1. **Phase 0 accepted:** character/feature pause and work tracks are registered.
2. **Phase 1 accepted:** `docs/PROJECT_STATUS.md` provides baseline metric, its method, categories, scope, and limitations. Do not use informally reported numbers as substitute.
3. **Reconciled metric:** occurrences vs unique names, global vs local labels and code vs data labels are defined without unresolved discrepancy. In particular, values that do not add up to declared total cannot be used to measure progress until methodology clarifies the difference.
4. **Phase 2 accepted:** canonical source and generated flow are defined. Naming must occur in the correct authoring file, not by manual editing of generated `src/`.
5. **Working tree inspected:** preexisting local changes are registered and will be preserved.
6. **Specific execution authorization:** this document is a specification, not authorization to edit annotations/sources, regenerate `src/`, compile, build, or run validations.

## 3. Sources and flow files

In preparation, consult current versions of:

- `docs/PROJECT_STATUS.md` — baseline/counting method;
- `docs/ARCHITECTURE.md`, `docs/FORMATS.md`, `docs/RAM.md`, and `docs/ROADMAP.md` — semantic contracts and structure;
- `docs/TOOLS.md` — annotation syntax and flow;
- `annotations/sf2ne.ann` — symbol, comment, and classification source per current flow;
- `tools/disasm.py` — generation rules and automatic naming;
- `src/` — generated artifacts, read-only for consultation during triage;
- `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` and Phase 2 ADR/approved format.

The above list does not presume annotations remain canonical source for all data after Phase 2. Labels must be changed in the approved canonical source for each information class.

## 4. Scope

### Included

- global automatic labels derived from bank/address, only in cases where function or structural identity is sufficiently determined;
- RAM symbols if their identity is demonstrable and Phase 1 registers corresponding source of truth;
- routine, table, dispatcher, structure, and entry point names related to central subsystems;
- evidence/confidence comments strictly necessary to explain a name or prevent hypothesis becoming fact;
- post-batch count update, using exactly the Phase 1 approved method.

### Excluded

- altering any opcode, operand, table, pointer, state, frame, condition, AI opcode, RAM value, or asset data byte;
- altering flow, semantics, addresses, bankswitching, timing, IRQ/NMI, calls, executable macros, or game code;
- creating features, characters, Ken AI, or playable content;
- renaming arcade content, bytecode, ROMs, or external assets; arcade REA remains separate;
- renaming opaque graphical data by assumption (e.g., giving move names to metasprites without demonstrated mapping);
- changing Phase 2 decided authoring syntax or canonical source.

## 5. Prioritization method

The Engineer must prepare a candidate list before editing. Use priority levels, not a percentage target:

| Level | Criterion | Treatment |
|-------|-----------|-----------|
| `P0 — central and confirmed` | Shared routine, dispatcher, loader, transition, or central table without useful name; demonstrable callers/use and high confidence. | First suggested batch. |
| `P1 — high impact and confirmed` | Routine/data frequently used by fight, character, input, collision, damage, drawing, or screen flow; clear evidence. | Next batches per subsystem. |
| `P2 — localized` | Auxiliary with limited use, but understood and relevant to maintenance. | Only after P0/P1 or if blocking another authorized task. |
| `P3 — opaque/hypothesis` | Undetermined semantics, contradictory evidence, non-executed code, or possibly dead structure. | Keep current label; document missing question/evidence, without renaming as fact. |

Prioritization must consider at minimum:

- number and criticality of known callers/cross-references;
- effect scope (shared, character, screen, or rare routine);
- role in documented essential paths;
- confidence level of interpretation;
- risk of a wrong name inducing future incorrect changes;
- dependency on an investigation not yet authorized or executed.

Do not use number of callers alone as proof of function; do not infer semantics from address or neighborhood alone.

## 6. Evidence requirements for a name

Each candidate in inventory must register:

| Field | Requirement |
|-------|-------------|
| ID / address | Current bank and address; preserve previous identifier for traceability. |
| Current symbol | Automatic label or current name. |
| Proposed symbol | Short name, consistent with documented conventions. |
| Category | Code, structured data, pointer, RAM, table, asset, or unclassified. |
| Evidence | Callers/xrefs, static reading, existing annotation/trace, table structure, or documentary reference. |
| Confidence | `HIGH`, `MEDIUM`, or `LOW`, with justification. |
| Impact/priority | P0–P3 per §5. |
| Risk/observation | Ambiguity, variant, unreachable data, or dependency. |
| Decision | `ACCEPTED`, `DEFERRED`, or `REJECTED`, with responsible/reviewer. |

Permitted evidence:

- demonstrable flow and cross-references by static reading;
- existing documents describing function and matching symbol/address;
- versioned historical traces, with origin and scenario identified;
- structural relationship consistent with other tables/routines.

Do not produce new trace nor execute emulator. If name depends on nonexistent dynamic observation, leave P3/pending and propose necessary evidence for another phase.

### Confidence convention

- **HIGH:** function confirmed by multiple converging evidences or by unequivocal flow/data use.
- **MEDIUM:** hypothesis strongly sustained, but with an important unresolved semantic aspect. Use explicit hypothesis comment; evaluate keeping old label.
- **LOW:** main semantics not proven. Do not replace label with definitive name.

## 7. Naming conventions

Existing project ADR/conventions prevail. If no sufficient standard exists, proposal must cover it before first batch:

- predominant language of names and technical terms;
- `PascalCase`/`camelCase`/subsystem suffixes and prefixes;
- function vs table, data, pointer, and RAM field names;
- player/slot distinction, if pertinent;
- index, family, or unit indication when confirmed;
- condition/opcode names already defined in `docs/FORMATS.md`;
- how to represent partially known labels without inventing meaning.

Principles:

- name by demonstrated role, not by value or data appearance;
- avoid names asserting unproven characteristic (e.g., `Random`, `Timer`, `Hitbox`, or move name without confirmation);
- keep existing names consistent, without mass cosmetic renaming;
- do not use comment as substitute for a name when function is already confirmed;
- preserve old name in batch inventory to map references in future review.

## 8. Batch execution

Each batch must correspond to a limited, reviewable subsystem.

### Batch preparation

1. Identify candidate in baseline and register in inventory.
2. Confirm location in approved canonical source.
3. Gather existing evidence and assign confidence/priority.
4. Separate confirmed names from hypotheses and candidates requiring trace/execution.
5. Request reviewer decision when P0/P1 ambiguity exists.

### Future authorized change

When explicit authorization to execute phase exists:

- edit exclusively the symbol canonical source indicated by Phase 2;
- never manually correct a generated `src/` file;
- change only label/comment/RAM symbol semantically, without touching directives or data that alter bytes;
- if generator rewrites `src/`, preserve and report preexisting changes and review produced diffs;
- do not mix naming with bug fix, refactoring, or unrelated formatting;
- stop and open decision if rename requires changing external reference, tool contract, or data.

`src/` generation is an execution action requiring specific authorization. Do not run automatically just because it is in habitual flow.

## 9. Future deliverables

Create, after execution authorization:

1. `tasks/NAMING_CANDIDATES.md` — prioritized inventory with evidence, confidence, state, and destination of each candidate;
2. canonical symbol source change batches, limited by subsystem;
3. `docs/PROJECT_STATUS.md` updated with same baseline metric, without summing different categories;
4. batch report containing label diff, unresolved ambiguities, and impact on tool references.

This specification does not define that all generic labels must be renamed. Automatic labels may remain adequate for opaque or low-maintenance-value data.

## 10. Future verification and non-authorization

Renaming has expected invariant of not altering binary content, but this fact can only be declared **verified** after authorized verification. Do not claim byte-for-byte equivalence merely because change was planned as symbolic.

A later phase, under explicit gate, must decide how to verify:

- absence of data/opcode/address changes;
- symbol/tool reference integrity;
- consistent source regeneration;
- artifact equivalence, if permitted and relevant.

This specification, global plan, or presence of existing scripts does not authorize executing generator, assembler/linker, build, Mesen, MAME, regression/relocation tests, or manual validation.

## 11. Files and preservation

For future execution, potentially alterable files are limited to:

- Phase 2-approved symbol canonical source (currently `annotations/sf2ne.ann`, if decision keeps this flow);
- `src/` only as output generated by authorized tool, never manual editing;
- `tasks/NAMING_CANDIDATES.md`;
- `docs/PROJECT_STATUS.md` for resulting metric.

Do not alter `tools/` code, assets, build configuration, ROM, or character scope documents. Register and preserve any preexisting local modification; do not use destructive operations (`clean`, `reset`, `restore`, or equivalents).

## 12. Phase 3 acceptance criteria

- [ ] Gates of Phases 0, 1, and 2 completed and canonical source decisions available.
- [ ] Initial metric reconciled and method frozen for before/after comparison.
- [ ] Candidate inventory with address, current label, proposed name, category, evidence, confidence, and priority exists.
- [ ] P0/P1 batches limited, reviewable, and evidence-based; P3 without definitive rename.
- [ ] Naming conventions registered and not contradicting approved canonical source.
- [ ] Symbol source changed only after explicit authorization and `src/` not hand-edited.
- [ ] No data/code byte, address, game flow, or character content intentionally altered.
- [ ] No binary equivalence/test approval claim without authorized verification and reported evidence.
- [ ] Result uses same Phase 1 metric definition and reports categories separately.
- [ ] No character, feature, Ken AI, converter, or kernel refactoring started.
- [ ] No build/test/emulator or ROM change executed without own authorization.
- [ ] Preexisting local changes preserved.

## 13. Future Engineer report

Upon concluding an authorized batch, report:

1. altered files and canonical source used;
2. symbols renamed by bank/address and proposed function;
3. evidence/confidence for each name or reference to inventory;
4. before/after metrics obtained by same method;
5. deferred ambiguities and missing evidence;
6. effects on symbols consumed by tools/documents;
7. commands/validations executed only if authorized, including results and artifacts;
8. explicit statement of local change preservation and that no gameplay scope was expanded.
