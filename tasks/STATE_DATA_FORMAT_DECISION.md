# Format decision — state and frame authoring (Phase 2)

**Status:** PROPOSED (Engineer recommendation; awaits explicit Maintainer decision)  
**Update 2026-11-16:** decision remains `PROPOSED`; Phase 3 closing did not use it as prerequisite, since naming acted only on symbols (`annotations/sf2ne.ann`). See `tasks/PHASE_3_EXECUTION_REPORT.md` §10.4.  
**Origin:** `tasks/PHASE_2_STATE_DATA_FORMAT_SPEC.md` (Phase 2 of stabilization plan)  
**Type:** decision/design document — does not authorize implementation, build, test, or migration  
**Prerequisites confirmed:** Phase 0 accepted, Phase 1 completed with `docs/PROJECT_STATUS.md` available

---

## 1. Recommended decision

The Engineer recommends **external declarative format** (structured file processed by dedicated tool) as canonical source for state and animation frame authoring, instead of ca65 macros/DSL.

**Status:** `PROPOSED` — final approval belongs to the Maintainer. No implementation, converter, migration, or build change is authorized by this document.

---

## 2. Comparison matrix of alternatives

| Criterion | ca65 macros/DSL | External declarative format (TOML/YAML/JSON) |
|-----------|-----------------|----------------------------------------------|
| Diff readability | Low. States and frames are in assembly with direct bytes; changing a parameter requires decoding hexadecimal values in the diff. | High. Named fields (duration, metasprite pointer, etc.) make the diff reviewable without manual decoding. |
| Typing/validation | Weak. The assembler only validates assembly syntax; invalid conditions, missing pointers, out-of-range duration, or malformed loops only appear at build/runtime (if at all). | Strong. A dedicated tool can validate before generating assembly: known conditions, duration in 1–100 range, resolved pointers, well-formed loop. |
| Coverage | Total (it is native assembly), but without distinction between "known value" and "uncertain value". | Total if schema covers all fields documented in `docs/FORMATS.md`; allows raw fields and uncertainty comments. |
| Symbols | Assembly labels; magic numbers for addresses and pointers. | Own symbolic names (state, frame, metasprite, box, bank), without magic numbers. |
| Unknown data | Difficult. Raw value in `.byte` without field for provenance comment. | Easy. `raw` field or comment per record/field; distinction between zero, absent, terminator, and omitted. |
| Canonical source | Ambiguous: mixes authoring data with disassembly-generated code. | Clear: a dedicated file/source that the Engineer edits; the generator reads that source without destroying it. |
| Integration with `make gen` | Direct (it is assembly), but `make gen` regenerates `src/` and can overwrite manual edits. | Needs a stage between `disasm.py` and `ca65`; `make gen` must not destroy or ignore new authoring data. |
| Error diagnosis | Line and file of generated assembly; hard to trace back to author intent. | File, record, field, and invalid reference pointed out by dedicated tool. |
| Determinism | Deterministic (assembly). | Deterministic if serialization is ordered. |
| Dependencies | None (ca65 already exists). | Requires parser + assembly generator; maintenance cost of new tool. |
| Migration | Gradual by bank, but with risk of overwrite by generator. | Gradual by character/bank; simple rollback (return to generated assembly). |
| Reversibility | Difficult (manual `src/` editing does not survive `make gen`). | Easy (turn off tool and continue with existing generated assembly). |

---

## 3. Proposed canonical source

- **Canonical authoring source:** external declarative file (format to define: TOML, YAML, or JSON — see section 4), separate from `annotations/sf2ne.ann` and `src/`.
- **Canonical source responsibilities:** states, animation frames, durations, metasprite/collision/effect pointers, flags, movement, loops, sentinels, provenance and confidence comments.
- **`annotations/sf2ne.ann` responsibilities:** labels, comments, `alt` blocks (corrections/alternates), `patch`, `keepbank`, disassembly metadata — remains unchanged as generator annotation source.
- **Generated files (never edit manually):** `src/*.s` (produced by `make gen`), `sf2ne.cfg`, `build/*.nes`.
- **Integration:** a new stage reading the declarative source must be inserted between generator and assembler, so `make gen` does not destroy or ignore authoring data. Implementation details are future work (Phase 3/Gate C).

---

## 4. TOML vs YAML vs JSON comparison (Phase 1 audit evidence)

Phase 1 audit (`docs/PROJECT_STATUS.md`) recorded 549 semantic labels vs 1,592 automatic (379 code + 1,213 data), and 322 `.global` symbols. This indicates symbolic names are valuable and the format should privilege readability and upfront validation.

| Criterion | TOML | YAML | JSON |
|-----------|------|------|------|
| Diff readability | Good (explicit sections, key=value) | Good, but indentation-sensitive | Regular (verbose brackets/quotes) |
| Native typing | Good (strings, integers, booleans, arrays, tables) | Good, but implicit in some cases | Good, but no comments |
| Comments | Yes | Yes | No |
| Mature Python tools | Yes (`tomllib` stdlib 3.11+, `tomli` before) | Yes (`PyYAML`) | Yes (`json` stdlib) |
| Ambiguity risk | Low | Medium (indentation, implicit types) | Low |
| Suitability for rigid schema | High | Medium | High |

**Recommended syntax (still PROPOSED):** TOML, for having comments, explicit typing, and standard parser in modern Python, with low indentation-ambiguity risk. Final decision between TOML/YAML/JSON belongs to the Maintainer.

---

## 5. Rules for preserving uncertain fields, references, and orphan records

### 5.1 Uncertain / unknown fields
- Raw value preserved literally (not normalized, not interpreted).
- Comment field per record and per field to indicate evidence, hypothesis, or documentary reference.
- Do not force semantic names for opcodes, conditions, effects, or flags not yet confirmed.
- Allow raw numeric value as explicit documented escape.

### 5.2 Sentinel distinction
- **zero:** numeric value `0` with its own meaning (e.g., zero duration if allowed by schema).
- **absent/null:** field omitted or explicitly null; not treated as zero.
- **end/terminator:** explicit sentinel (e.g., null pointer, byte `$FF`), distinct from "absent".
- **field omitted:** field not present in record; schema must define whether valid and what default applies.

### 5.3 Orphan / unreachable records
- Records not reachable via state chain but present in audited region must be represented without loss.
- Conversion cannot be based only on the state chain reachable from the initial state.

### 5.4 Symbolic references
- Labels and references between states and frames use symbolic names; raw numeric values only as documented escape.
- Association of each state to its state bank and of frames/metasprites to frame sources must be preserved.

---

## 6. Risks and proposal limitations

| Risk | Description | Proposed mitigation |
|------|-------------|---------------------|
| New parser/generator tool | Maintenance cost; additional dependency. | Keep tool minimal and documented; rollback to existing generated assembly. |
| Integration with `make gen` | Risk of overwriting or ignoring authoring data. | Design reading stage between `disasm.py` and `ca65`; safeguards in migration plan. |
| Unmapped orphan records | There may be binary records the schema doesn't represent. | List as unclassified data in Phase 1; treat as documented exception. |
| Duplicate symbols across banks | `InputButtons`, `ResetStub`, `RoundStart` appear in multiple banks. | Per-bank symbol scope; do not flatten namespaces. |
| Relocation | Absolute addresses cannot be fixed in source. | Use labels and symbolic references; leave alignment/order to assembler/linker. |

---

## 7. Approval status

| Item | Status |
|------|--------|
| External declarative format as preferred direction | PROPOSED |
| TOML as preferred syntax | PROPOSED |
| Canonical source vs. generated separation | PROPOSED |
| Final approval (Maintainer) | PENDING |

Final decision belongs to the Maintainer. Until explicit approval, no converter, migration, `make gen` change, build, or test is authorized.

---

## 8. Related files

- `tasks/PHASE_2_STATE_DATA_FORMAT_SPEC.md` — this phase's specification (input)
- `docs/PROJECT_STATUS.md` — Phase 1 baseline (metrics, sources of truth)
- `docs/FORMATS.md` — initial contract of fields, sizes, tables
- `docs/ARCHITECTURE.md` — state bank, frame bank, loader, mapping
- `docs/RAM.md` — symbols/variables connecting data to engine
- `annotations/sf2ne.ann` — annotation directives, symbols, corrections
- `tools/disasm.py` — current generation flow
- `src/*.s`, `src/*.inc`, `Makefile`, `sf2ne.cfg` — assembly form and current integration (read-only)

---

## 9. Next steps (after approval)

1. Gate C: authorize tool implementation (parser + assembly generator).
2. Implement converter and validate against current Ryu data (no Ken, no new content).
3. Gradual migration by bank/character, with documented rollback.
4. Future verification: build, ROM comparison, and regression of existing features.
