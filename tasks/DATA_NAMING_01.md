# Data naming — batch 9: bank `$01` (Ryu state bank, structural anchors)

- **Status:** **APPLIED** — 38 structural names applied; 266 labels deferred (P3); ROM SHA-1 unchanged. Pending commit authorization.
- **Scope:** the 304 automatic `D01_*` labels of `src/bank_01.s`.
- **Source of truth:** `annotations/sf2ne.ann`, `src/bank_01.s`, `src/bank_3C.s` (fiche),
  `src/bank_3F.s` (`InputDispatch`, `DirCodeTbl`, damage routine), `docs/FORMATS.md` §1–§3/§13 and
  `docs/ARCHITECTURE.md` §4.1–§4.2.
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

### 1.1 State bank layout

`docs/FORMATS.md` §2: the bank starts with **8 pointer tables** of consecutive words
(`$0000` = empty), padding to `$A0AF`, then 71 state headers and 274 frames.

| Table | Entries | Role (FORMATS §1) | Copied to |
|-------|---------|-------------------|-----------|
| `$A000` | 9 | states by **direction** (`InputDir`) | `ram_031E` |
| `$A012` | 4 | states by **button** (`InputAttack`) | `ram_0322` |
| `$A01A` | 6 | **special moves** (`CmdMoveIdx`) — already named `RyuSpcTrans` | `ram_0326` |
| `$A026` | 12 | **guards** (received hit, `HitReactClass & $3F`) | `ram_032A` |
| `$A03E` | 12 | **standing** damage reaction | `ram_032E` |
| `$A056` | 12 | **crouching** damage reaction | `ram_0336` |
| `$A06E` | 12 | **neutral** damage reaction | `ram_0332` |
| `$A086` | 12 | **throws** (class `$0C`) | `ram_033A` |

`FighterLoadChar` (`3B:E000`) copies each table pointer to RAM; the fiche names the same slots
`CharDirTrans*`, `CharAttackTrans*`, `CharSpecialTrans*`, `CharGuardReact*`, `CharHitReact1*` (standing),
`CharHitReact2*` (crouching), `CharHitReact0*` (neutral) and `CharHitReact12*` (class 12 = `$0C`, throw).

### 1.2 Direction entries

`DirCodeTbl` (`3F:E963`) maps controller bits to `InputDir`; `InputDispatch` indexes the direction table
by `InputDir − $04`:

| Index | `InputDir` | Meaning | Table entry |
|-------|-----------|---------|-------------|
| 0 | `$04` | neutral | `$A0F6` |
| 1 | `$05` | forward | `$A16D` |
| 2 | `$06` | back (guard) | `$A3D5` |
| 3 | `$07` | up | `$A223` |
| 4 | `$08` | down | `$A373` |
| 5 | `$09` | up-forward | `$A270` |
| 6 | `$0A` | up-back | `$A2E7` |
| 7 | `$0B` | down-forward | `$A373` (shared with down) |
| 8 | `$0C` | down-back | `$A3EA` |

`DirCodeTbl` byte comment confirms the diagonals: `$09`/`$0A` are the up diagonals and `$0B`/`$0C` the
down diagonals; bit order (forward `$01`, back `$02`, down `$04`, up `$08`) fixes forward before back in
each pair. `GuardClassTbl` (`3F:F799`) also marks `$08`/`$0B`/`$0C` as crouching (`$2A`), matching `$A373`
and `$A3EA`.

### 1.3 Button chains

`docs/FORMATS.md` §13 documents the four chains at `$A012`. Each entry is the first node of a chain; the
`+1` alternative pointers in ROM were checked to match the documented order exactly:

| `InputAttack` | Chain (condition → state, class) | Table entry |
|---------------|----------------------------------|-------------|
| 0 weak punch | airborne (`$05`) → `$AD86` (`$8C`) · down (`$07`) → `$AD55` (`$8A`) · always → `$AD08` (`$89`) | `$AD86` |
| 1 strong punch | ground/sliding (`$06`) → `$AF07` (`$9C`) · airborne → `$AEAC` (`$9C`) · down → `$AE51` (`$9A`) · near (`$02`) → `$ADF6` (`$99`, 2 hits) · always → `$ADA9` (`$99`) | `$AF07` |
| 2 weak kick | airborne → `$ABBF` (`$74`) · down → `$AB8E` (`$72`) · near → `$AB5D` (`$71`) · always → `$AB2C` (`$71`) | `$ABBF` |
| 3 strong kick | can grab (`$09`) → `$AADF` (`$A1`) · airborne → `$ACC9` (`$84`) · down → `$AC7C` (`$82`) · near → `$AC2F` (`$81`) · always → `$ABE2` (`$81`) | `$AADF` |

### 1.4 Special moves

`RyuSpcTrans` (`$A01A`) is indexed by `CmdMoveIdx`; the special list `CmdKeyListRyu` (`3F:E0C0`) is
`02 03 06 07 04 05 FF`, and `CmdKeyAttackTbl` (`3F:E0AF`) requires weak kick for key `$02`, strong kick
for `$03`/`$07`, weak punch for `$04` and strong punch for `$05`:

| Index | Move | State | Class | Hits |
|-------|------|-------|-------|------|
| 0 | hadouken (weak kick) | `$AF54` | `$B1` | 0 |
| 1 | hadouken (strong kick) | `$AFA1` | `$B9` | 0 |
| 2 | shoryuken (weak kick) | `$AFEE` | `$C4` | 2 |
| 3 | shoryuken (strong kick) | `$B049` | `$CC` | 2 |
| 4 | tatsumaki (weak punch) | `$B0B9` | `$D4` | 6 |
| 5 | tatsumaki (strong punch) | `$B140` | `$DC` | 6 |

The hit counts match `docs/FORMATS.md` §11 (tatsumaki has 6); hadouken is a projectile (0 attack hits).

## 2. Proposed names (38)

### 2.1 Pointer tables (7)

| Address | Current | Proposed | Role | Confidence | Priority |
|---------|---------|----------|------|------------|----------|
| `01:A000` | `D01_A000` | `RyuDirTransTbl` | states by `InputDir` (9 entries) | HIGH | P1 |
| `01:A012` | `D01_A012` | `RyuAttackTransTbl` | states by `InputAttack` (4) | HIGH | P1 |
| `01:A026` | `D01_A026` | `RyuGuardReactTbl` | guard reaction (12) | HIGH | P1 |
| `01:A03E` | `D01_A03E` | `RyuHitReactStandTbl` | standing damage reaction (12) | HIGH | P1 |
| `01:A056` | `D01_A056` | `RyuHitReactCrouchTbl` | crouching damage reaction (12) | HIGH | P1 |
| `01:A06E` | `D01_A06E` | `RyuHitReactNeutralTbl` | neutral damage reaction (12) | HIGH | P1 |
| `01:A086` | `D01_A086` | `RyuThrowTbl` | throw reaction, class `$0C` (12) | HIGH | P1 |

### 2.2 Direction entries (8 distinct addresses)

| Address | Current | Proposed | Entry for | Confidence | Priority |
|---------|---------|----------|-----------|------------|----------|
| `01:A0F6` | `D01_A0F6` | `RyuDirNeutralEntry` | `InputDir $04` | HIGH | P2 |
| `01:A16D` | `D01_A16D` | `RyuDirForwardEntry` | `$05` | HIGH | P2 |
| `01:A3D5` | `D01_A3D5` | `RyuDirBackEntry` | `$06` | HIGH | P2 |
| `01:A223` | `D01_A223` | `RyuDirUpEntry` | `$07` | HIGH | P2 |
| `01:A373` | `D01_A373` | `RyuDirDownEntry` | `$08` and `$0B` (down-forward) | HIGH | P2 |
| `01:A270` | `D01_A270` | `RyuDirUpForwardEntry` | `$09` | HIGH | P2 |
| `01:A2E7` | `D01_A2E7` | `RyuDirUpBackEntry` | `$0A` | HIGH | P2 |
| `01:A3EA` | `D01_A3EA` | `RyuDirDownBackEntry` | `$0C` | HIGH | P2 |

These are the first node consulted for the direction; some are plain states (forward, jumps) and some
start a condition chain (neutral, back, down). The comment states the `InputDir` value, not a pose.

### 2.3 Button-chain states (17)

| Address | Current | Proposed | Chain node | Confidence | Priority |
|---------|---------|----------|------------|------------|----------|
| `01:AD86` | `D01_AD86` | `RyuWeakPunchAir` | weak punch, airborne | HIGH | P2 |
| `01:AD55` | `D01_AD55` | `RyuWeakPunchCrouch` | weak punch, down | HIGH | P2 |
| `01:AD08` | `D01_AD08` | `RyuWeakPunch` | weak punch, default | HIGH | P2 |
| `01:AF07` | `D01_AF07` | `RyuStrongPunchGround` | strong punch, ground/sliding | HIGH | P2 |
| `01:AEAC` | `D01_AEAC` | `RyuStrongPunchAir` | strong punch, airborne | HIGH | P2 |
| `01:AE51` | `D01_AE51` | `RyuStrongPunchCrouch` | strong punch, down | HIGH | P2 |
| `01:ADF6` | `D01_ADF6` | `RyuStrongPunchNear` | strong punch, near (2 hits) | HIGH | P2 |
| `01:ADA9` | `D01_ADA9` | `RyuStrongPunch` | strong punch, default | HIGH | P2 |
| `01:ABBF` | `D01_ABBF` | `RyuWeakKickAir` | weak kick, airborne | HIGH | P2 |
| `01:AB8E` | `D01_AB8E` | `RyuWeakKickCrouch` | weak kick, down | HIGH | P2 |
| `01:AB5D` | `D01_AB5D` | `RyuWeakKickNear` | weak kick, near | HIGH | P2 |
| `01:AB2C` | `D01_AB2C` | `RyuWeakKick` | weak kick, default | HIGH | P2 |
| `01:AADF` | `D01_AADF` | `RyuThrowStart` | strong kick chain, can grab | HIGH | P2 |
| `01:ACC9` | `D01_ACC9` | `RyuStrongKickAir` | strong kick, airborne | HIGH | P2 |
| `01:AC7C` | `D01_AC7C` | `RyuStrongKickCrouch` | strong kick, down | HIGH | P2 |
| `01:AC2F` | `D01_AC2F` | `RyuStrongKickNear` | strong kick, near | HIGH | P2 |
| `01:ABE2` | `D01_ABE2` | `RyuStrongKick` | strong kick, default | HIGH | P2 |

### 2.4 Special-move states (6)

| Address | Current | Proposed | Move | Confidence | Priority |
|---------|---------|----------|------|------------|----------|
| `01:AF54` | `D01_AF54` | `RyuHadoukenWeak` | hadouken, weak kick | HIGH | P1 |
| `01:AFA1` | `D01_AFA1` | `RyuHadoukenStrong` | hadouken, strong kick | HIGH | P1 |
| `01:AFEE` | `D01_AFEE` | `RyuShoryukenWeak` | shoryuken, weak kick (2 hits) | HIGH | P1 |
| `01:B049` | `D01_B049` | `RyuShoryukenStrong` | shoryuken, strong kick (2 hits) | HIGH | P1 |
| `01:B0B9` | `D01_B0B9` | `RyuTatsumakiWeak` | tatsumaki, weak punch (6 hits) | HIGH | P1 |
| `01:B140` | `D01_B140` | `RyuTatsumakiStrong` | tatsumaki, strong punch (6 hits) | HIGH | P1 |

Suggested comments:

- Tables: role, entry count and RAM copy (`ram_031E`…`ram_033A`); fiche slot name where it differs.
- Direction entries: `InputDir` value and the fact that the entry is the first node of that direction's chain.
- Button states: `InputAttack` value, chain position and class byte.
- Specials: `CmdMoveIdx`, required button and hit count.

## 3. Deferred (266, P3, keep automatic)

- **38 state headers** not listed above: round/victory/defeat, guard and damage-reaction states, walk-back,
  jump variants and the two orphan states. Their identity needs animation/pose reading, not just the
  dispatch table.
- **228 frame labels** (`D01_*`): frame records and their loop targets. They are named by the animation
  they belong to, which is exactly what is still undetermined.

The 2 states and 1 frame the generator reports without a known pointer have no label today and stay that
way.

## 4. Comment and reference updates required

| File | Change |
|------|--------|
| `annotations/sf2ne.ann` | expand the `# BANK $01` section with 38 `label`/`comment` pairs |
| `src/bank_01.s` | regenerated: 38 labels and their `.word` operands |
| `src/bank_3C.s` | regenerated: fiche references to the 7 renamed tables |
| `src/globals.inc` | 7 `.global` names renamed (`D01_A000`, `A012`, `A026`, `A03E`, `A056`, `A06E`, `A086`) |
| `docs/PROJECT_STATUS.md`, `README.md`, `tasks/DATA_LABEL_CANDIDATES.md`, `tasks/PHASE_3_EXECUTION_REPORT.md`, `docs/lessons.md` | metrics and batch history |

`src/bank_05.s` (Ken) is **not** touched in this batch; the mirror batch is separate because that file is
hand-written and must be edited directly.

## 5. Validation plan

1. Add the 38 pairs in the `# BANK $01` section of `annotations/sf2ne.ann`.
2. Run `make gen`; inspect the diff. Expected files: `src/bank_01.s`, `src/bank_3C.s`,
   `src/globals.inc`.
3. Run `make`; ROM SHA-1 must remain `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`.
4. Confirm no numeric `.byte`/`.word`/`.res` operand changed.
5. `grep -c '^D01_' src/bank_01.s` must be 266; `grep -rn 'D01_' annotations/sf2ne.ann` must be empty.
6. `src/bank_05.s` must remain untouched.
7. Re-measure: automatic data `996 -> 958`; unique semantic `1,144 -> 1,182`; unique names `2,140`
   unchanged.
8. Update the docs, then request commit authorization; no push without explicit approval.

## 6. Risks and notes

- **The direction entries are not all poses.** `$A0F6` starts with `CondRoundLost` and `$A3D5` with
  `CondOpponentAttacks`; the name identifies the table slot, not the animation. Keep the `Entry` suffix.
- **Down and down-forward share one entry.** `$A373` is referenced twice in `$A000`; name it once and
  mention both `InputDir` values.
- **The button chains are data, not code.** The `+1` alternative pointers were verified in ROM; do not
  reorder or infer a different chain from class bytes alone.
- **Weak/strong order comes from the command list.** Hadouken and shoryuken use kick strength, tatsumaki
  uses punch strength; swapping the pairs would invert the names.
- No emulator execution was used; confidence comes from the dispatch tables, the fiche slot names and
  the documented consumers.

## 7. Applied result and verification

| Check | Result |
|-------|--------|
| `annotations/sf2ne.ann` | `# BANK $01` section with 39 `label`/`comment` pairs (38 new + the existing `RyuSpcTrans`) |
| `src/bank_01.s` | 38 labels and their `.word` operands renamed; 266 `D01_*` labels remain |
| `src/bank_3C.s` | fiche references to the 7 renamed tables updated |
| `src/globals.inc` | 7 `.global` names renamed (`D01_A000`, `A012`, `A026`, `A03E`, `A056`, `A06E`, `A086`); count unchanged |
| `make gen` | OK; second run idempotent (same diff hash) |
| `make` | OK — canonical build with `DEST_FLAG_BLINK` |
| SHA-1 of `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to baseline |
| Directive operands | `src/bank_01.s` 1,587 directives before/after, 33 differ only by symbol rename; `src/bank_3C.s` 131 before/after, 14 differ only by symbol rename; no numeric operand changed |
| `grep -c '^D01_' src/bank_01.s` | 266 (38 state headers + 228 frames) |
| `grep -rn 'D01_' annotations/sf2ne.ann` | 0 |
| `src/bank_05.s` | untouched |
| Metrics | automatic data `996 -> 958`; unique semantic `1,144 -> 1,182`; unique names `2,140` unchanged |

Commit is still pending explicit authorization; nothing was pushed.
