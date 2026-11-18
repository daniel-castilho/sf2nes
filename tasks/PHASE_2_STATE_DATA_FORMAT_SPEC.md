# Technical specification — Phase 2: state and frame authoring format

- **Status:** ready for the Software Engineer to execute as design phase; does not authorize format/converter implementation.
- **Execution status:** COMPLETED; D-02 accepted on 2026-11-17 (`tasks/STATE_DATA_FORMAT_DECISION.md`).
- **Project:** Street Fighter II NE (`daniel-castilho/sf2nes`).
- **Origin:** Phase 2 of `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.
- **Prerequisites:** Phase 0 accepted and Phase 1 completed, with `docs/PROJECT_STATUS.md` available.
- **Type of work:** survey, alternative comparison, specification, and decision recommendation.
- **Code, data migration, build, compilation, ROM, tests, and emulator:** out of scope and not authorized by this specification.

## 1. Objective

Define a readable, safe, and sustainable way to **author in the future** the editing of existing state and animation frame data, reducing manual byte editing without losing control over the original format.

Phase 2 must produce a technical decision and a specification sufficient for a later phase to implement the tool. It **must not** build a converter, migrate data, alter `src/`, change annotations, or add states or character content.

Use current Ryu data only to verify the proposal represents existing structures. Do not create Ken data nor claim the format is already validated by generation/build/runtime.

## 2. Entry gate

Before starting this phase, the Engineer must confirm:

1. Phase 0 was concluded and accepted;
2. Phase 1 was concluded and `docs/PROJECT_STATUS.md` contains the sources of truth and generated inventory;
3. `docs/FORMATS.md`, annotations, generator, and `src/` sources are coherent enough to compare alternatives;
4. local tree and preexisting changes were registered and preserved.

If any requirement fails, stop and report the block. Do not resolve Phase 1 divergences by assumption nor start the converter to circumvent missing data.

## 3. Decision scope

The decision must explicitly answer:

- which file or set of files will be the **canonical authoring source** for states/frames;
- which tool transforms them into assembly/data consumed by the build;
- how that source integrates with the current generator without being overwritten by `make gen`;
- what part remains `annotations/sf2ne.ann` responsibility (labels, comments, corrections/alternates, code blocks, disassembly metadata);
- which files are generated and must never be manually edited;
- how to preserve symbols, references, banks, order, and current values without introducing semantic change.

Compare at minimum:

1. **ca65 macros/DSL:** state/frame declarations in assembly with macros and symbolic directives.
2. **External declarative format:** structured file processed by tool (e.g., TOML, YAML, or JSON), with assembly generation compatible with flow.

The Engineer may recommend a hybrid alternative only if explaining responsibility boundary and canonical source. Final decision belongs to the Maintainer. The Engineer's proposal must be marked `PROPOSED`, not `APPROVED`, until explicit decision is obtained.

## 4. Mandatory technical sources

Use as initial contract, without copying third-party content:

- `docs/FORMATS.md` — fields, sizes, tables, conditions, states, frames, loops, pointers;
- `docs/ARCHITECTURE.md` — state bank, frame bank, loader, mapping;
- `docs/RAM.md` — symbols/variables connecting data to engine;
- `annotations/sf2ne.ann` — annotation directives, bank marking, blocks, alternates;
- `tools/disasm.py` — current generation flow and read/write boundary;
- `src/` — assembly form currently consumed by build;
- `Makefile` and `sf2ne.cfg` — current generation/assembly/linking integration, read-only only.

Phase 1 report is reference for conflicts or doubts about canonical sources. If real code contradicts a documented statement, document divergence; do not alter generator, source, or build in this phase.

## 5. Structural coverage the proposal must represent

The format specification must describe all elements necessary to serialize without loss the current Ryu state/frame set, including unreachable or orphan records pointed out in documents.

At minimum:

### 5.1 Sheet tables and references

- pointer tables used for states by direction, buttons, specials, guard/defense, damage reactions, throws, and AI, per current inventory;
- byte table for state bank, frame bank, and collision source, if sheet is part of proposal;
- entry count/order, blanks, terminators, aliases, and out-of-bank references, when applicable;
- addresses by symbolic label; literal values only as explicit documented escape;
- clear separation between sheet metadata and bank content.

Phase 2 must not fill Ken's sheet nor alter existing tables.

### 5.2 State header

Represent fields documented in `docs/FORMATS.md`, including:

- entry condition/criterion;
- link/pointer to next alternative;
- link/pointer of natural chain;
- state class;
- state hit count.

Conditions and classes must accept symbolic names when a reliable definition exists, and in all cases allow a raw numeric value to keep records whose meaning remains uncertain.

### 5.3 Animation frames

Represent, without loss:

- duration;
- metasprite pointer;
- collision box pointer or absence;
- effect parameter/type;
- flags;
- movement mode;
- X/Y velocities;
- repetition and loop target pointer;
- pointer to next frame or end sentinel.

Representation must correctly handle documented variable-size records — normal frame and loop frame — and ensure the no-loop case does not emit or interpret nonexistent fields.

### 5.4 Not fully understood data

- Preserve literally the raw value of fields whose meaning is hypothesis or unknown.
- Allow comments/annotations per record and per field to indicate evidence, hypothesis, or documentary reference.
- Do not force semantic names for unconfirmed opcodes, conditions, effects, or flags.
- Distinguish "zero", "absent/null", "terminator", and "omitted field"; do not treat them as equivalent.
- Represent unreachable/orphan records when part of audited region, avoiding conversion based only on reachable state chain.

### 5.5 Relocation and generation

The proposal must specify how to conserve:

- labels and symbolic references between states and frames;
- association of each state to its state bank and of frames/metasprites to frame sources;
- alignment, emission order, and sentinels, if they affect structure;
- relocation by assembler/linker without duplicated absolute addresses in source;
- assembly format integrating into existing process.

Do not fix addresses or assume specific bank for future characters in this phase. Focus is modeling current records without blocking relocation.

## 6. Alternative comparison matrix

The decision must compare ca65 macros and external declarative format across the criteria below, with brief evaluation and evidence:

| Criterion | Question to answer |
|-----------|-------------------|
| Diff readability | Is it easy to review state/frame changes without decoding bytes? |
| Typing/validation | How to detect invalid condition, missing pointer, out-of-range duration, or malformed loop before generating assembly? |
| Coverage | Do all current fields and exceptions have lossless representation? |
| Symbols | How are state, frame, box, and bank names referenced without magic numbers? |
| Unknown data | Is it possible to preserve raw values and uncertainty comments? |
| Canonical source | Is there a single place the Engineer edits? What happens when running `make gen`? |
| Integration | What would be the entry point in current flow without overwriting annotations or `src/` manually? |
| Errors | Does diagnosis point to file, record, field, and invalid reference? |
| Determinism | Does same input produce ordered, reproducible assembly? |
| Dependencies | Does it require additional library or runtime? What is maintenance cost? |
| Migration | How to adopt gradually without transforming the whole tree at once? |
| Reversibility | How to undo adoption or correct format without losing data? |

Do not choose format merely by syntax preference. The proposal must demonstrate interaction with current generation and limitations found in Phase 1 audit.

## 7. Schema/grammar proposal requirements

The delivery must include a readable schema specification, independent of chosen syntax, with:

- measurement units and known limits;
- permitted symbolic names and their origin;
- required, optional, repeatable, and mutually exclusive fields;
- reference rule and nonexistent destination detection;
- ordering and serialization rule;
- raw values for unknown fields;
- null/absent/end/terminator representation;
- loop and no-loop frame representation;
- provenance and confidence comment not affecting emitted bytes;
- defined behavior for duplicate values, duplicate labels, and unresolved addresses;
- compatibility with documented binary sizes/limits, without silently correcting or normalizing data.

### Illustrative example

The specification may include a minimal **schematic** example to show schema design, but it must:

- use fictitious/symbolic values that do not reproduce a real game data sequence;
- not include complete data or arcade ROM bytecode;
- not present the example as valid data ready for assembly;
- mark fields whose meaning depends on confirmation.

Including an example is not mandatory if the grammar is clear without it.

## 8. Integration with existing flow — decision, not implementation

The ADR must draw a target flow and explicitly demarcate each layer's responsibility. Consider, without assuming solution:

- `annotations/sf2ne.ann` remains source for annotations, symbols, and disassembly corrections;
- state text data may need a dedicated file/source;
- `src/` continues generated, if that is the approved result;
- `make gen` cannot destroy or silently ignore new authoring data;
- build must consume artifacts foreseen by new flow, without depending on manual editing of generated file.

The proposal must indicate whether integration requires modifying `tools/disasm.py`, `Makefile`, directory layout, or linker configuration. These changes are only listed as future work. Do not perform them in Phase 2.

## 9. Mandatory outputs

Create the decision/design documents below:

1. `tasks/STATE_DATA_FORMAT_DECISION.md` — option matrix, Engineer recommendation, proposed canonical source, trade-offs, risks, and Maintainer approval state.
2. `tasks/STATE_DATA_FORMAT_SCHEMA.md` — conceptual schema/grammar, types, rules, references, unknown values, expected serialization.
3. `tasks/STATE_DATA_FORMAT_MIGRATION_PLAN.md` — future implementation/migration steps, files likely affected, `make gen` safeguards, rollback, and future verification criteria.

These are design documents. If a file already exists or an ADR convention is created after this specification, do not overwrite: preserve content, point out conflict, and request decision before creating duplicate.

## 10. Out of scope

- Implementing parser, converter, generator, macros, or new permanent scripts.
- Altering `tools/disasm.py`, `Makefile`, `sf2ne.cfg`, annotations, `src/`, data, or assets.
- Converting Ryu or Ken to new format.
- Adding, editing, or normalizing real game records.
- Creating Ken or any other character's sheet/states/frames.
- Running generator, assembler, linker, `make`, build, test, Mesen, MAME, or manual validation.
- Restructuring kernel, changing banks, or touching ROMs.
- Resolving format semantic gaps depending on further investigation; list them as open.

## 11. Acceptance criteria

- [ ] Entry gate (Phase 0 and Phase 1 completed) confirmed; without it, execution was interrupted.
- [ ] Current versions of §4 sources and Phase 1 result were consulted.
- [ ] ca65 macros and external declarative format compared per §6 matrix; any hybrid alternative justified.
- [ ] Engineer recommends an option and indicates proposed canonical source; final approval remains explicit Maintainer decision.
- [ ] Schema covers §5 elements and explicates how to preserve orphan records, unknown values, sentinels, loops, and symbolic references.
- [ ] Proposal distinguishes zero/null/absent/end and does not depend only on reachable states.
- [ ] Interaction with annotations, generator, `src/`, `make gen`, and build is designed without altering flow in this phase.
- [ ] Gradual migration, rollback, and future verification plan exists, without claiming execution.
- [ ] Decision, schema, and migration documents delivered, without new code/data source.
- [ ] No file outside §9 permitted documents was modified.
- [ ] No code, tool, annotation, asset, or ROM was altered; no build, test, or emulator executed.
- [ ] Preexisting local changes preserved.

## 12. Engineer delivery report

Upon concluding, inform:

1. documents created or updated;
2. alternatives compared and evidence used;
3. recommended format/canonical source and state `PROPOSED` or `APPROVED` (with explicit Maintainer decision);
4. still-unknown format cases and data that could not be classified;
5. files and tools a future implementation would likely need to alter;
6. risks, migration, and rollback proposed;
7. confirmation that no converter/migration/build/test/emulator was executed and local state was preserved.
