# Data naming — batch 11: bank `$00` (Ryu AI scripts and helper tables)

- **Status:** **APPLIED** — 31 names applied; 175 labels deferred (P3); ROM SHA-1 unchanged. Pending commit authorization.
- **Scope:** the 206 automatic `D00_*` labels of `src/bank_00.s`: 96 metasprites (`$8000`–`$8E49`),
  1 script table (`$8E72`), 19 scripts (`$8E82`–`$8F3B`), 11 helper tables (`$9051`–`$9148`) and
  79 collision records (`$91C1`–`$9467`).
- **Source of truth:** `src/bank_00.s`, `src/bank_3F.s` (`AiUpdate`, `AiOp00`–`AiOp11`),
  `docs/FORMATS.md` §14/§15, `src/bank_3C.s` (fiche) and `src/bank_01.s` (`RyuSpcTrans`).
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

### 1.1 Script bytecode

`docs/FORMATS.md` §14 defines the bytecode: bytes `$80`–`$91` are opcodes dispatched by `AiOpLo`/`AiOpHi`
(`3F:E5??`) to `AiOp00`–`AiOp11`, operands are `< $80`, and `$FF` ends the script. Decoding each of the
19 scripts with that table gave an unambiguous action sequence, for example:

| Address | Bytes | Decoded action |
|---------|-------|----------------|
| `$8E82` | `80 04 89 8B 82 00 82 89 FF` | neutral, wait idle `$58`, wait projectile free, special 0 twice, wait idle |
| `$8E98` | `80 06 85 08 8C 20 FF` | hold back (`$06`) until moved `$20` px |
| `$8EA6` | `80 0A 88 04 80 04 FF` | press up-back, wait airborne, release |
| `$8F11` | `82 02 82 89 FF` | special 2 twice, wait idle |
| `$8F29` | `81 08 03 87 10 80 04 89 FF` | down + strong kick, wait state class `$10`, wait idle |

### 1.2 Script identity comes from the consumer

Several scripts share bytes or differ only in one operand, so the consumer was used as the tie-breaker:

| Script | Consumer | Why this name |
|--------|----------|---------------|
| `$8E82` / `$8E8B` | `$8E72` entries 4–7 | special indexes 0 and 1 = hadouken weak/strong (`RyuSpcTrans`) |
| `$8E98` / `$8E9F` | `$8E72` entries 0–1 | `$06` = back, `$05` = forward |
| `$8EA6` / `$8EAD` | `$8E72` entries 2–3 | `$0A` = up-back, `$09` = up-forward |
| `$8ECA` | `RyuAiOpponentSpecial` (`$9063`) | fires when the opponent has a special state |
| `$8EEB` / `$8EFB` | `RyuAiAirScriptPick` / `RyuAiAirScriptDefault` | airborne punch scripts |
| `$8F03` / `$8F0A` | jump-up / jump-in branches | `$07` = up, `$09` = up-forward |
| `$8F1B` | `$9051`, `RyuAiOpponentScript` | strong punch, neutral |
| `$8F24` | `AiOp03` semantics (`$83`) | defend: back, or down-diagonal if opponent crouches |
| `$8F29` / `$8F32` | `RyuAiAntiAirScript8F29`, `RyuAiState58Script32` | crouch strong kick / crouch strong punch |
| `$8F3B` | `RyuAiState58DistDiv8` (throw branch) | forward + strong kick, throw |

`RyuSpcTrans` (`01:A01A`) fixes the special order: 0 hadouken weak, 1 hadouken strong, 2 shoryuken weak,
3 shoryuken strong, 4 tatsumaki weak, 5 tatsumaki strong. `InputAttack` is 0 weak punch, 1 strong punch,
2 weak kick, 3 strong kick, `$FF` none (`3F:E9FC`).

### 1.3 Table structure

| Table | Entries | Index | Evidence |
|-------|---------|-------|----------|
| `$8E72` | 8 words | `Random & 7` | fiche `ram_0342/ram_0344`; drawn when a script ends (`3F:E7B6`) |
| `$9051`/`$9053` | 2 + 2 bytes | `Random & 1` | `RyuAiCloseScript` reads `y` from `Random & 1` |
| `$90ED`/`$90F1` | 4 + 4 bytes | `Random & 3` | four scripts: throw, shoryuken weak, defend ×2 |
| `$90EE`/`$90F2` | entry 1 of the same arrays | `Random & 1` | overlapping view used by the distance/16 branch (y = 0–1) |
| `$913C`/`$9140` | 4 + 4 bytes | `(Random & 7) >> 2` | only entries 0–1 reachable |
| `$9144`/`$9146` | 2 + 2 bytes | `(Random & 7) >> 3` | only entry 0 reachable |
| `$9148` | 1 word | opponent `FighterChar` | RTS trick in `$8FDC`–`$8FE8`; single entry `RyuAiAntiAir-1` |

The two `Mid` labels (`$90EE`, `$90F2`) are not independent arrays: they name entry 1 of the 4-entry
tables at `$90ED`/`$90F1`, used by the distance/16 branch with `y = 0–1`. The comments state this
explicitly so that a later reader does not resize the table.

## 2. Applied names (31)

### 2.1 Script table (1)

| Address | Current | Applied | Role | Confidence | Priority |
|---------|---------|---------|------|------------|----------|
| `00:8E72` | `D00_8E72` | `RyuAiIdleScriptTbl` | 8 scripts drawn when the current script ends | HIGH | P1 |

### 2.2 AI scripts (19)

| Address | Current | Applied | Bytecode identity | Confidence | Priority |
|---------|---------|---------|-------------------|------------|----------|
| `00:8E82` | `D00_8E82` | `RyuAiScriptHadoukenWeak` | special 0 ×2 | HIGH | P2 |
| `00:8E8B` | `D00_8E8B` | `RyuAiScriptHadoukenStrong` | special 1 ×2 | HIGH | P2 |
| `00:8E98` | `D00_8E98` | `RyuAiScriptWalkBack` | `$06` + moved test | HIGH | P2 |
| `00:8E9F` | `D00_8E9F` | `RyuAiScriptWalkForward` | `$05` + moved test | HIGH | P2 |
| `00:8EA6` | `D00_8EA6` | `RyuAiScriptJumpBack` | `$0A` + airborne wait | HIGH | P2 |
| `00:8EAD` | `D00_8EAD` | `RyuAiScriptJumpForward` | `$09` + airborne wait | HIGH | P2 |
| `00:8ECA` | `D00_8ECA` | `RyuAiScriptVsSpecial` | back off, kicks, forward + strong kick | HIGH | P2 |
| `00:8EEB` | `D00_8EEB` | `RyuAiScriptAirStrongPunchCombo` | strong punch neutral + down | HIGH | P2 |
| `00:8EFB` | `D00_8EFB` | `RyuAiScriptAirStrongPunch` | strong punch neutral | HIGH | P2 |
| `00:8F03` | `D00_8F03` | `RyuAiScriptJumpUp` | `$07` + airborne wait | HIGH | P2 |
| `00:8F0A` | `D00_8F0A` | `RyuAiScriptJumpIn` | `$09` + airborne wait | HIGH | P2 |
| `00:8F11` | `D00_8F11` | `RyuAiScriptShoryukenWeak` | special 2 ×2 | HIGH | P2 |
| `00:8F16` | `D00_8F16` | `RyuAiScriptShoryukenStrong` | special 3 ×2 | HIGH | P2 |
| `00:8F1B` | `D00_8F1B` | `RyuAiScriptStrongPunch` | strong punch + state `$13` wait | HIGH | P2 |
| `00:8F24` | `D00_8F24` | `RyuAiScriptDefend` | opcode `$83` | HIGH | P2 |
| `00:8F26` | `D00_8F26` | `RyuAiScriptCrouch` | `$08` for one frame | HIGH | P2 |
| `00:8F29` | `D00_8F29` | `RyuAiScriptCrouchStrongKick` | down + strong kick | HIGH | P2 |
| `00:8F32` | `D00_8F32` | `RyuAiScriptCrouchStrongPunch` | down + strong punch | HIGH | P2 |
| `00:8F3B` | `D00_8F3B` | `RyuAiScriptThrow` | forward + strong kick | HIGH | P2 |

### 2.3 Helper tables (11)

| Address | Current | Applied | Role | Confidence | Priority |
|---------|---------|---------|------|------------|----------|
| `00:9051` | `D00_9051` | `RyuAiCloseScriptLoTbl` | low bytes: strong punch, shoryuken strong | HIGH | P2 |
| `00:9053` | `D00_9053` | `RyuAiCloseScriptHiTbl` | high bytes for the above | HIGH | P2 |
| `00:90ED` | `D00_90ED` | `RyuAiState69ScriptLoTbl` | 4 low bytes (throw, shoryuken weak, defend ×2) | HIGH | P2 |
| `00:90EE` | `D00_90EE` | `RyuAiState69MidLoTbl` | entry 1 of the same array (distance/16 branch) | HIGH | P2 |
| `00:90F1` | `D00_90F1` | `RyuAiState69ScriptHiTbl` | 4 high bytes | HIGH | P2 |
| `00:90F2` | `D00_90F2` | `RyuAiState69MidHiTbl` | entry 1 of the same array | HIGH | P2 |
| `00:913C` | `D00_913C` | `RyuAiState69RandomLoTbl` | 4 low bytes; entries 0–1 reachable | HIGH | P2 |
| `00:9140` | `D00_9140` | `RyuAiState69RandomHiTbl` | 4 high bytes | HIGH | P2 |
| `00:9144` | `D00_9144` | `RyuAiState69NowLoTbl` | 2 low bytes; entry 0 reachable | HIGH | P2 |
| `00:9146` | `D00_9146` | `RyuAiState69NowHiTbl` | 2 high bytes | HIGH | P2 |
| `00:9148` | `D00_9148` | `AiHitReactRoutineTbl` | per-character routine, RTS trick | HIGH | P1 |

## 3. Deferred (175, P3, keep automatic)

- **96 metasprites** (`$8000`–`$8E49`): frame graphics referenced by the state banks; naming needs the
  drawing consumer and is out of this batch's evidence.
- **79 collision records** (`$91C1`–`$9467`): hit/hurt boxes and metadata; same reason.

No name was applied to the three dead fragments below, because nothing references them.

## 4. Traps found while decoding

- **Overlapping tables.** `$90EE`/`$90F2` are entry 1 of the 4-entry arrays at `$90ED`/`$90F1`, not a
  second table. The labels say so; do not "fix" the apparent 1-byte size.
- **Unreachable entries.** `$913C` has 4 entries but `(Random & 7) >> 2` yields only 0–1; `$9144` has 2
  entries but `(Random & 7) >> 3` yields only 0. The comments record the reachable range.
- **Dead bytes after `$FF`.** `$8EB4`–`$8EC9` (two script bodies) and `$8F43`–`$8F45` (`80 04 FF`) are
  never referenced; they stayed automatic and unlabelled.
- **Byte-identical scripts.** `$8EAD` and `$8F0A` are the same 7 bytes (`80 09 88 04 80 04 FF`); only the
  consumer distinguishes jump-forward from jump-in.
- **Misleading pre-existing code label.** `RyuAiAirAttack` (`$91BA`) starts `$8F24`, which is `$83 FF`
  = defend. The label was kept (code naming is out of scope) but its comment now says it starts
  `RyuAiScriptDefend`, so the old name is not read as "air attack".

## 5. Comment and reference updates

| File | Change |
|------|--------|
| `annotations/sf2ne.ann` | `$00` data batch block with the 31 labels; 14 comments now cite script names instead of raw addresses |
| `src/bank_00.s` | regenerated: 31 labels + all internal operands |
| `src/globals.inc` | `D00_8E72` → `.global RyuAiIdleScriptTbl` |
| `src/bank_3C.s` | fiche `CharAiScriptLoTbl`/`HiTbl` comments cite `RyuAiIdleScriptTbl` (operands stay numeric) |
| `src/bank_04.s` | Ken AI stub comment cites `RyuAiIdleScriptTbl` (comment only) |
| `docs/PROJECT_STATUS.md`, `README.md`, `tasks/DATA_LABEL_CANDIDATES.md`, `tasks/PHASE_3_EXECUTION_REPORT.md`, `docs/lessons.md` | metrics and batch history |

`src/bank_01.s` and Ryu's column 0 are untouched.

## 6. Validation

| Check | Result |
|-------|--------|
| `make gen` | OK; second run produced no further diff |
| `make` | OK — canonical build with `DEST_FLAG_BLINK` |
| SHA-1 of `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to baseline |
| Directive operands | `src/bank_00.s` 688 directives before/after; 31 labels and their internal operands normalized to the same addresses; no numeric operand changed |
| `grep -c '^D00_' src/bank_00.s` | 175 (96 metasprites + 79 collisions) |
| Renamed `D00_*` tokens left | 0 in `src/bank_00.s` and `annotations/sf2ne.ann` |
| `src/bank_01.s` | untouched |
| Metrics | automatic data `920 -> 889`; unique semantic `1,220 -> 1,251`; definitions `2,145` and unique names `2,140` unchanged; bank `$00` now 175 automatic / 82 semantic |

Commit is still pending explicit authorization; nothing was pushed.
