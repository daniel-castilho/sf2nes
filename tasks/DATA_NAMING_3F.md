# Data naming — batch 2: bank `$3F` (fighting core)

- **Status:** **APPLIED** in `annotations/sf2ne.ann`; build and SHA-1 validated.  
- **Scope:** the 15 automatic `D3F_*` labels of `src/bank_3F.s`.  
- **Source of truth:** `annotations/sf2ne.ann`, `docs/FORMATS.md` §11–§15 and reading of consumers in `src/bank_3F.s`.  
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

| Flow | Where | What it proves |
|------|-------|----------------|
| `ProjLaunch` | `3F:E837-E853` | `D3F_E064` = birth ΔX; `D3F_E05E` = step per speed |
| `ProjUpdate` | `3F:E854-E89D` | `D3F_E05B` = birth Y; `D3F_E05E` = step per subframe |
| `MoveVelSetup` | `3F:E4C2-E4CD` | `D3F_E4CE`/`$E4D4` = dispatch `address-1` by `MoveMode` (absolute/acceleration/subpixel) |
| `MoveDispatch_F0A5` | `3F:F0A5-F0B0` | `D3F_F0B1`/`$F0B7` = dispatch `address-1` by `MoveMode` (movement application) |
| `PostProc` / `RoundStart2` | `3F:EDE9-EE24` | `D3F_EF20`/`$EF06` (ground) and `$EF2D`/`$EF13` (neutral/air): knockback Y/X by class |
| `HitDamageHeavy` | `3F:EE27-EE3D` | `D3F_EF3A` = new reaction class on knockdown |
| `HitDamageKO` | `3F:EEF7-EF03` | `D3F_EF47` = new reaction class on KO |
| `AnimUpdate_EE78` → `HitDamageSfx` | `3F:EE78-EEC4` | `D3F_E055` = impact sfx by attacker's class |
| `CmdMotionAdvance` | `3F:EB73-EB7D` | `D3F_E068` = `CmdMotionTbl+1` (read next byte with same index) |

`docs/FORMATS.md` §11 (hit and damage) and §15 (auxiliary table index) already describe these tables at the same addresses, confirming the code reading.

Conventions: suffix `Tbl` for data table; `Lo`/`Hi` for the two halves of an `address-1` dispatch (like `CmdStepLo`/`CmdStepHi`); names in English.

## 2. Projectile

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `3F:E05B` | 3 (2 used) | `ProjUpdate` | `ProjSpawnYOffsetTbl` | HIGH |
| `3F:E05E` | 6 (2 used) | `ProjLaunch`/`ProjUpdate` | `ProjSpeedStepTbl` | HIGH |
| `3F:E064` | 3 (2 used) | `ProjLaunch` | `ProjSpawnXOffsetTbl` | HIGH |

## 3. Impact and reaction

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `3F:E055` | 6 (3 used) | `AnimUpdate_EE78` → `HitDamageSfx` | `HitSfxTbl` | HIGH |
| `3F:EF06` | 13 | `PostProc` (ground/crouched) | `KnockbackXGroundTbl` | HIGH |
| `3F:EF13` | 13 | `RoundStart2` (neutral/air) | `KnockbackXAirTbl` | HIGH |
| `3F:EF20` | 13 | `PostProc` (ground/crouched) | `KnockbackYGroundTbl` | HIGH |
| `3F:EF2D` | 13 | `RoundStart2` (neutral/air) | `KnockbackYAirTbl` | HIGH |
| `3F:EF3A` | 13 | `HitDamageHeavy` | `KnockdownReactTbl` | HIGH |
| `3F:EF47` | 45 (13 used) | `HitDamageKO` | `KOReactTbl` | HIGH |

> `KnockbackX/YGround` covers "standing/crouched"; `KnockbackX/YAir` covers "neutral/in air", per `docs/FORMATS.md` §11. The Ground/Air separation is what the code itself uses (`FighterState & 3`).

## 4. Movement dispatches (`address-1`, `RTS` trick)

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `3F:E4CE` | 6 | `MoveVelSetup` | `MoveVelDispatchLo` | HIGH |
| `3F:E4D4` | 6 | `MoveVelSetup` | `MoveVelDispatchHi` | HIGH |
| `3F:F0B1` | 6 | `MoveDispatch_F0A5` | `MoveApplyDispatchLo` | HIGH |
| `3F:F0B7` | 6 | `MoveDispatch_F0A5` | `MoveApplyDispatchHi` | HIGH |

## 5. Table alias

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `3F:E068` | 71 | `CmdMotionAdvance` (`EB79`) | `CmdMotionTblNext` | MEDIUM |

> `E068` is exactly `CmdMotionTbl+1` (the table starts at `E067`). The generator created a separate label because `EB79` references `E068` directly. `CmdMotionTblNext` documents this offset view without pretending it is an independent table. If preferred, this label may remain automatic.

## 6. Risks and validation

- **Risk:** low. No `.byte`/`.word`/`.patch` directive is touched; only `label 3F:XXXX <Name>` lines enter `annotations/sf2ne.ann`.
- **Expected side effect:** `src/bank_3F.s` and `src/globals.inc` start using the new names; generated comments citing `D3F_*` also change (text, not bytes).
- **Mandatory validation:**
  1. `make gen` without error;
  2. `make` without error;
  3. SHA-1 of `build/sf2ne.nes` = `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`;
  4. `git diff -U0 -- src` without any `.byte`/`.word` line;
  5. confirm that `src/bank_05.s` does not reference `D3F_*` (Ken is hand-written source).
- **Out of scope (document later):** `docs/FORMATS.md` §15 says `CmdMotionTbl` has 64 bytes (16 hits × 4), but the real table runs from `E067` to `E0AE` (72 bytes, 18 keys × 4). Do not correct in this batch.

## 7. Application result

The 15 names were applied in `annotations/sf2ne.ann`. Validation performed:

- `make gen`: OK; `src/bank_3F.s` and `src/globals.inc` regenerated only with new names.
- `make`: OK.
- SHA-1 of `build/sf2ne.nes`: `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` (identical).
- `.byte`/`.word` directives of `src/bank_3F.s`: **155 before, 155 after, identical operands**; only comments and labels changed.
- `src/bank_05.s` (Ken, hand-written) does not reference `D3F_*`.
- Canonical metric after batch: `autoD=1165`, `semantic=976` (before: 1,180 / 961).
- `docs/FORMATS.md` §11/§15 updated to the new names; incidentally corrected sizes of `E05B`/`E05E`/`E064`, of `CmdMotionTbl` (72 bytes, 18 keys) and of `CmdKeyAttackTbl` (17 bytes).
