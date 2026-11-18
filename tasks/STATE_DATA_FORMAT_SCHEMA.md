# Authoring schema — states and animation frames (Phase 2)

- **Status:** ACCEPTED (2026-11-17, part of D-02; no implementation authorized)
- **Origin:** `tasks/PHASE_2_STATE_DATA_FORMAT_SPEC.md` (Phase 2)
- **Type:** conceptual design document — not code, not a converter, not game data
- **Prerequisites confirmed:** Phase 0 and Phase 1 completed

---

## 1. Schema objective

Define a syntax-independent conceptual grammar that allows **lossless serialization** of the current set of Ryu states and animation frames, including unreachable records, unknown values, sentinels, loops, and symbolic references.

The schema is the contract between authoring source and the future assembly generation tool. It imposes no addresses, normalizes no data silently, and requires no specific bank for future characters.

---

## 2. Units of measurement and known limits

| Unit | Value / limit | Source |
|------|---------------|--------|
| Frame duration | 1–100 video frames | `docs/FORMATS.md` §6 |
| Attack hits (state) | `zp_28`; attack box count | `docs/FORMATS.md` §3 |
| State class | byte; low 3 bits = posture | `docs/FORMATS.md` §3 |
| Effect type | `$0B` projectile, `$20` sound, `$8x`/`$Cx` reaction | `docs/FORMATS.md` §7 |
| Movement mode | 0/1 absolute, 2/3 acceleration, 4/5 subpixel | `docs/FORMATS.md` §8 |
| VelX / VelY | signed, interpreted per mode | `docs/FORMATS.md` §8 |
| Loop repetitions | `zp_44`; 0 = no loop | `docs/FORMATS.md` §6 |
| End-of-frame sentinel | null pointer = end of state | `docs/FORMATS.md` §6 |
| Frame size | 14 bytes normal; 16 with loop | `docs/FORMATS.md` §6 |
| State header | 7 bytes | `docs/FORMATS.md` §3 |
| Transition conditions | 12 (`0`–`$0B`); `≥$80`/`$FF` = unconditional | `docs/FORMATS.md` §4 |

---

## 3. Authoring units

### 3.1 Character sheet (metadata)

Set of references linking the fighter to state tables by direction, buttons, specials, guard/defense, damage reactions, throws, and AI.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id_personagem | symbol/integer | yes | fighter identifier (0 = Ryu, 1 = Ken, …) |
| banco_estados | symbol/integer | yes | state bank (window `$A000`) |
| banco_frames | symbol/integer | yes | frame/metasprite bank (window `$8000`) |
| banco_colisao | symbol/integer | no | collision box source (if different from frames) |
| tabela_direcao | reference | no | state pointers by direction |
| tabela_botao | reference | no | state pointers by button |
| tabela_especial | reference | no | special move state pointers |
| tabela_guarda | reference | no | defense/hit reaction pointers |
| tabela_dano_pe | reference | no | standing damage reaction |
| tabela_dano_agachado | reference | no | crouching damage reaction |
| tabela_dano_neutro | reference | no | neutral damage reaction |
| tabela_agarrao | reference | no | throws |
| roteiro_ia | reference | no | character AI script table |
| lista_especiais | reference | no | command recognizer special list |

> The sheet is linkage metadata. Actual state/frame content lives in the records below.

### 3.2 State

A state is a header followed by one or more animation frames.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id_estado | symbol | yes | symbolic state name (e.g., `EstadoParado`) |
| condicao_entrada | symbol or raw integer | yes | entry criterion (transition condition; `0`–`$0B`, `≥$80` unconditional) |
| proxima_alternativa | state reference or null | no | link to next alternative in chained transition list |
| cadeia_natural | state reference or null | no | link to next state when this ends (`StateAdvance`) |
| classe | symbol or raw integer | yes | state class (state byte → `FighterState`) |
| acertos_golpe | integer or raw integer | yes | state hit count (`AttackHitsLeft`) |
| quadro_inicial | frame reference | yes | first animation frame (header + 7 in binary format) |

**Rules:**
- `condicao_entrada`, `classe`, and `acertos_golpe` accept symbolic name when a reliable definition exists, and raw numeric value as escape for uncertain meaning.
- `proxima_alternativa` and `cadeia_natural` can be null (list ends).
- `quadro_inicial` points to the first frame of the state.

### 3.3 Animation frame

A frame can be **normal** (14 bytes) or **with loop** (16 bytes).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id_quadro | symbol | yes | symbolic frame name |
| duracao | integer | yes | duration in video frames (1–100) |
| metasprite | metasprite reference or null | no | pointer to metasprite (frame bank) |
| colisao | collision reference or null | no | pointer to collision boxes, or absent if none |
| efeito_parametro | integer or raw integer | yes | effect parameter (damage `&$1F` or projectile speed) |
| efeito_tipo | symbol or raw integer | yes | effect type (`$0B`, `$20`, `$8x`, `$Cx`…) |
| flags | symbol or raw integer | yes | frame flags (`FrameFlags`: bit 0 special, bit 1 per button, bit 2 direction) |
| movimento_modo | symbol or raw integer | yes | movement mode (0/1, 2/3, 4/5) |
| velocidade_x | signed integer | yes | `VelX` |
| velocidade_y | signed integer | yes | `VelY` |
| repeticao | integer | yes | loop repetitions (`LoopRepeat`; 0 = no loop) |
| desvio_laco | frame reference or null | no | loop target pointer; present only if `repeticao != 0` |
| proximo_quadro | frame reference or null | no | pointer to next frame; null = end of state |

**Variable-size rules:**
- If `repeticao == 0`: `desvio_laco` **does not exist** nor is interpreted (normal frame, 14 bytes).
- If `repeticao != 0`: `desvio_laco` is required (loop frame, 16 bytes).
- `proximo_quadro == null` indicates end of state (sentinel).

---

## 4. Data types

| Type | Allowed values | Notes |
|------|----------------|-------|
| symbol | alphanumeric identifier | state, frame, metasprite, collision, bank label |
| integer | integer, can be signed | duration, velocity, parameters |
| raw integer | hexadecimal or decimal number | escape for values with uncertain meaning |
| symbol or raw integer | symbol | raw integer | fields with conditional meaning (condition, class, effect, flags, mode) |
| reference | symbol of another record or `null` | pointer between states/frames/metasprites/collisions |
| null | `null` / absent | end sentinel, omitted field, undefined pointer |
| comment | free text | provenance, confidence, hypothesis, documentary reference |

---

## 5. Permitted symbolic names and their origin

| Category | Name origin | Example |
|----------|-------------|---------|
| State | state header label | `EstadoParado`, `EstadoGolpe` |
| Frame | frame label within state | `Quadro1`, `QuadroAtaque` |
| Metasprite | metasprite label in frame bank | `MsParado`, `MsSoco` |
| Collision | collision box label | `ColPe`, `ColAgachado` |
| Bank | PRG bank symbol | `BancoEstadosRyu`, `BancoFramesRyu` |
| Condition | transition condition name (when known) | `CondOpponentNear`, `CondInAir` |
| Class | state class name (when known) | `ClaseEmPe`, `ClaseAgachado` |
| Effect | effect type name (when known) | `EfeitoProjetil`, `EfeitoSom` |

> Symbolic names are optional; any record can be referenced by raw integer if meaning is not yet reliable.

---

## 6. Reference rules and nonexistent destination detection

- Every reference (`proxima_alternativa`, `cadeia_natural`, `quadro_inicial`, `metasprite`, `colisao`, `desvio_laco`, `proximo_quadro`) must point to a symbol defined in the same authoring document or to `null`.
- Reference to undefined symbol is a **future tool validation error** (not silently normalized).
- References between states and frames of different banks must be valid within the scope of the character being authored.
- Do not assume a specific bank for future characters; state/frame-bank association is declared in the sheet.

---

## 7. Ordering and serialization rules

- Same input produces ordered, reproducible assembly (determinism).
- Emission order: states in declaration order; frames within each state in declaration order; fields within each record in schema order.
- Sentinels and alignment are assembler/linker responsibility; schema does not fix absolute addresses.
- Emission order does not alter data semantics.

---

## 8. Raw values for unknown fields

- Field whose meaning is hypothesis or unknown: use **raw integer** + provenance/confidence comment.
- Do not force semantic names for unconfirmed opcodes, conditions, effects, or flags.
- Comments do not affect emitted bytes.

---

## 9. Null / absent / end / terminator representation

| Concept | Representation | Semantics |
|---------|----------------|-----------|
| zero | integer `0` | numeric value with its own meaning |
| absent / null | field omitted or `null` | field not provided; is not zero |
| end | `proximo_quadro == null` | end of state |
| terminator | null pointer / explicit sentinel | end of list or chain |

These four concepts are **distinct** and not equivalent.

---

## 10. Frame with and without loop

| Case | `repeticao` | `desvio_laco` | Size |
|------|-------------|---------------|------|
| Without loop | `0` | **absent** (not emitted, not interpreted) | 14 bytes |
| With loop | `> 0` | required (frame reference) | 16 bytes |

- Without-loop case **does not emit or interpret** nonexistent loop fields.
- With-loop case requires valid `desvio_laco`.

---

## 11. Provenance and confidence comment

- Each record and each field can have an attached comment.
- Comment indicates: evidence, hypothesis, documentary reference (`docs/FORMATS.md` §X, `annotations/sf2ne.ann` line Y).
- Comments **do not affect emitted bytes**; authoring metadata only.

---

## 12. Behavior for duplicate values and unresolved addresses

| Situation | Future tool behavior |
|-----------|---------------------|
| Duplicate label within same document | Validation error (does not silently overwrite) |
| Duplicate label across different banks | Allowed; symbol scope per bank |
| Unresolved address | Validation error; do not assume address |
| Duplicate value in different fields | Allowed (values can repeat) |
| Missing required field | Validation error |
| Unknown field in document | Ignored or error, per tool policy (do not normalize) |

---

## 13. Compatibility with binary sizes and limits

- Schema respects documented sizes (7-byte state header, 14/16-byte frame, duration 1–100, etc.).
- **Does not correct or normalize data silently.** If current data are outside documented limits, the future tool must report an error, not adjust automatically.

---

## 14. Illustrative example (schematic, fictitious values)

> This example is **only illustrative of schema design**. It uses symbolic/fictitious values, does not reproduce a real game sequence, does not include arcade ROM bytecode, and is not ready for assembly. Fields whose meaning depends on confirmation are marked as raw integer + comment.

```toml
# Schematic example — NOT real game data
[[personagem]]
id = "ryu"
banco_estados = "BancoEstadosRyu"
banco_frames = "BancoFramesRyu"

[[personagem.estado]]
id = "estado_exemplo"
condicao_entrada = { simbolo = "CondOpponentNear", bruto = 0x02 }  # hypothesis
proxima_alternativa = nulo
cadeia_natural = "estado_seguinte"
classe = { simbolo = "ClasseEmPe", bruto = 0x59 }  # confirm
acertos_golpe = 0
quadro_inicial = "q1"

[[personagem.estado.quadro]]
id = "q1"
duracao = 8
metasprite = "ms_exemplo"
colisao = nulo
efeito_parametro = { bruto = 0x00 }  # uncertain meaning
efeito_tipo = { simbolo = "EfeitoNenhum", bruto = 0x00 }
flags = { bruto = 0x10 }  # confirm bits
movimento_modo = { simbolo = "MovAbsoluto", bruto = 0 }
velocidade_x = 0
velocidade_y = 0
repeticao = 0
# desvio_laco absent (no loop)
proximo_quadro = "q2"

[[personagem.estado.quadro]]
id = "q2"
duracao = 4
metasprite = "ms_exemplo2"
colisao = nulo
efeito_parametro = { bruto = 0x00 }
efeito_tipo = { simbolo = "EfeitoNenhum", bruto = 0x00 }
flags = { bruto = 0x10 }
movimento_modo = { simbolo = "MovAbsoluto", bruto = 0 }
velocidade_x = 0
velocidade_y = 0
repeticao = 0
proximo_quadro = nulo  # end of state
```

---

## 15. Scope and limitations

- Schema covers elements of §5 of `tasks/PHASE_2_STATE_DATA_FORMAT_SPEC.md` (sheet tables, state header, frames, uncomprehended data, relocation).
- Does not fill Ken's sheet nor alter existing tables.
- Does not add states or character content.
- Does not validate against runtime nor generate build.

---

## 16. Related files

- `tasks/STATE_DATA_FORMAT_DECISION.md` — decision and trade-offs
- `tasks/STATE_DATA_FORMAT_MIGRATION_PLAN.md` — future implementation steps
- `docs/FORMATS.md`, `docs/ARCHITECTURE.md`, `docs/RAM.md` — mandatory technical sources
- `annotations/sf2ne.ann`, `tools/disasm.py`, `src/*.s`, `Makefile`, `sf2ne.cfg` — current flow (read-only)
