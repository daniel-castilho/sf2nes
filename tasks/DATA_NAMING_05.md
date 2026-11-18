# Data naming — batch 10: bank `$05` (Ken state bank, mirror of `$01`)

- **Status:** **APPLIED** — 38 structural names applied; 314 labels deferred (P3); ROM SHA-1 unchanged. Pending commit authorization.
- **Scope:** the 352 automatic `D05_*` labels of `src/bank_05.s` (hand-written source, `keepbank 05`).
- **Source of truth:** `src/bank_05.s`, `src/bank_01.s`, `tasks/DATA_NAMING_01.md`,
  `src/bank_3C.s` (fiche), `docs/FORMATS.md` §1–§3/§13 and `docs/ARCHITECTURE.md` §4.1–§4.2.
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

### 1.1 The bank is a structural copy of `$01`

`src/bank_05.s` is hand-written from Ryu's bank (`$01`): same 71 state headers and 274 frames in the
same window (`$A000`–`$BFFF`), with metasprite/collision pointers remapped to Ken's frame bank (`$04`).
The 8 pointer tables therefore have the same roles and addresses as in `$01`.

The assembled ROM was compared bank by bank:

| Check | Result |
|-------|--------|
| 8 pointer tables (`$A000`, `$A012`, `$A01A`, `$A026`, `$A03E`, `$A056`, `$A06E`, `$A086`) | all byte-identical between `$01` and `$05` |
| 31 state headers named in this batch | all byte-identical between `$01` and `$05` |
| `Char*LoTbl`/`Char*HiTbl` column 1 (`3C:800B`…) | points to the same `$A0xx` addresses as Ryu's column 0 |

The fiche patch only changes table offset `+1`; Ryu's column 0 is untouched. This is why every name in
this batch is the `$01` name with the `Ken` prefix.

### 1.2 Names already established for `$01`

`tasks/DATA_NAMING_01.md` documents the 38 structural names: 7 pointer tables (the special table
`$A01A` was already `RyuSpcTrans`), 8 direction entries, 17 button-chain states and 6 special-move
states. The same dispatch tables, `InputDir`/`InputAttack` indexes, chain order and `CmdMoveIdx` order
apply to `$05`, because the bytes are identical.

## 2. Applied names (38)

### 2.1 Pointer tables (7 new + `KenSpcTrans` already named)

| Address | Current | Applied | Role | Confidence | Priority |
|---------|---------|---------|------|------------|----------|
| `05:A000` | `D05_A000` | `KenDirTransTbl` | states by `InputDir` (9 entries) | HIGH | P1 |
| `05:A012` | `D05_A012` | `KenAttackTransTbl` | states by `InputAttack` (4) | HIGH | P1 |
| `05:A01A` | `KenSpcTrans` | *(unchanged)* | special moves (`CmdMoveIdx`) | HIGH | P1 |
| `05:A026` | `D05_A026` | `KenGuardReactTbl` | guard reaction (12) | HIGH | P1 |
| `05:A03E` | `D05_A03E` | `KenHitReactStandTbl` | standing damage reaction (12) | HIGH | P1 |
| `05:A056` | `D05_A056` | `KenHitReactCrouchTbl` | crouching damage reaction (12) | HIGH | P1 |
| `05:A06E` | `D05_A06E` | `KenHitReactNeutralTbl` | neutral damage reaction (12) | HIGH | P1 |
| `05:A086` | `D05_A086` | `KenThrowTbl` | throw reaction, class `$0C` (12) | HIGH | P1 |

### 2.2 Direction entries (8)

| Address | Current | Applied | Entry for | Confidence | Priority |
|---------|---------|---------|-----------|------------|----------|
| `05:A0F6` | `D05_A0F6` | `KenDirNeutralEntry` | `InputDir $04` | HIGH | P2 |
| `05:A16D` | `D05_A16D` | `KenDirForwardEntry` | `$05` | HIGH | P2 |
| `05:A3D5` | `D05_A3D5` | `KenDirBackEntry` | `$06` | HIGH | P2 |
| `05:A223` | `D05_A223` | `KenDirUpEntry` | `$07` | HIGH | P2 |
| `05:A373` | `D05_A373` | `KenDirDownEntry` | `$08` and `$0B` (down-forward) | HIGH | P2 |
| `05:A270` | `D05_A270` | `KenDirUpForwardEntry` | `$09` | HIGH | P2 |
| `05:A2E7` | `D05_A2E7` | `KenDirUpBackEntry` | `$0A` | HIGH | P2 |
| `05:A3EA` | `D05_A3EA` | `KenDirDownBackEntry` | `$0C` | HIGH | P2 |

### 2.3 Button-chain states (17)

| Address | Current | Applied | Chain node | Confidence | Priority |
|---------|---------|---------|------------|------------|----------|
| `05:AD86` | `D05_AD86` | `KenWeakPunchAir` | weak punch, airborne | HIGH | P2 |
| `05:AD55` | `D05_AD55` | `KenWeakPunchCrouch` | weak punch, down | HIGH | P2 |
| `05:AD08` | `D05_AD08` | `KenWeakPunch` | weak punch, default | HIGH | P2 |
| `05:AF07` | `D05_AF07` | `KenStrongPunchGround` | strong punch, ground/sliding | HIGH | P2 |
| `05:AEAC` | `D05_AEAC` | `KenStrongPunchAir` | strong punch, airborne | HIGH | P2 |
| `05:AE51` | `D05_AE51` | `KenStrongPunchCrouch` | strong punch, down | HIGH | P2 |
| `05:ADF6` | `D05_ADF6` | `KenStrongPunchNear` | strong punch, near (2 hits) | HIGH | P2 |
| `05:ADA9` | `D05_ADA9` | `KenStrongPunch` | strong punch, default | HIGH | P2 |
| `05:ABBF` | `D05_ABBF` | `KenWeakKickAir` | weak kick, airborne | HIGH | P2 |
| `05:AB8E` | `D05_AB8E` | `KenWeakKickCrouch` | weak kick, down | HIGH | P2 |
| `05:AB5D` | `D05_AB5D` | `KenWeakKickNear` | weak kick, near | HIGH | P2 |
| `05:AB2C` | `D05_AB2C` | `KenWeakKick` | weak kick, default | HIGH | P2 |
| `05:AADF` | `D05_AADF` | `KenThrowStart` | strong kick chain, can grab | HIGH | P2 |
| `05:ACC9` | `D05_ACC9` | `KenStrongKickAir` | strong kick, airborne | HIGH | P2 |
| `05:AC7C` | `D05_AC7C` | `KenStrongKickCrouch` | strong kick, down | HIGH | P2 |
| `05:AC2F` | `D05_AC2F` | `KenStrongKickNear` | strong kick, near | HIGH | P2 |
| `05:ABE2` | `D05_ABE2` | `KenStrongKick` | strong kick, default | HIGH | P2 |

### 2.4 Special-move states (6)

| Address | Current | Applied | Move | Confidence | Priority |
|---------|---------|---------|------|------------|----------|
| `05:AF54` | `D05_AF54` | `KenHadoukenWeak` | hadouken, weak kick | HIGH | P1 |
| `05:AFA1` | `D05_AFA1` | `KenHadoukenStrong` | hadouken, strong kick | HIGH | P1 |
| `05:AFEE` | `D05_AFEE` | `KenShoryukenWeak` | shoryuken, weak kick (2 hits) | HIGH | P1 |
| `05:B049` | `D05_B049` | `KenShoryukenStrong` | shoryuken, strong kick (2 hits) | HIGH | P1 |
| `05:B0B9` | `D05_B0B9` | `KenTatsumakiWeak` | tatsumaki, weak punch (6 hits) | HIGH | P1 |
| `05:B140` | `D05_B140` | `KenTatsumakiStrong` | tatsumaki, strong punch (6 hits) | HIGH | P1 |

## 3. Deferred (314, P3, keep automatic)

- **40 state headers** not listed above: round/victory/defeat, guard and damage-reaction states,
  walk-back, jump variants and orphan states.
- **274 frame labels** (`D05_*`): frame records and loop targets, named by the animation they belong to.

`$05` has 2 more state headers and 46 more frames than `$01` (Ken-specific records); they are part of
the deferred set. The 2 states and 1 frame the generator reports without a known pointer stay unlabelled.

## 4. Comment and reference updates

| File | Change |
|------|--------|
| `src/bank_05.s` | 38 labels renamed directly (hand-written source); 33 internal `.word` operands follow |
| `annotations/sf2ne.ann` | `# BANK $05` section documents the mirror; 13 `Ken:` fiche comments updated |
| `src/bank_3C.s` | regenerated: fiche column 1 comments cite the new names (operands remain numeric) |
| `docs/PROJECT_STATUS.md`, `README.md`, `tasks/DATA_LABEL_CANDIDATES.md`, `tasks/PHASE_3_EXECUTION_REPORT.md`, `docs/lessons.md` | metrics and batch history |

`src/bank_01.s` and Ryu's column 0 are untouched.

## 5. Validation

| Check | Result |
|-------|--------|
| `make gen` | OK; second run produced no further diff |
| `make` | OK — canonical build with `DEST_FLAG_BLINK` |
| SHA-1 of `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to baseline |
| Directive operands | `src/bank_05.s` 1,757 directives before/after; 71 occurrences renamed (38 labels + 33 `.word` operands), all normalized to the same addresses; no numeric operand changed |
| `grep -c '^D05_' src/bank_05.s` | 314 (40 state headers + 274 frames) |
| Renamed `D05_*` tokens left | 0 |
| `grep -c 'D05_' annotations/sf2ne.ann` | 0 |
| `src/bank_01.s` | untouched |
| Metrics | automatic data `958 -> 920`; unique semantic `1,182 -> 1,220`; definitions `2,145` and unique names `2,140` unchanged |

Commit is still pending explicit authorization; nothing was pushed.
