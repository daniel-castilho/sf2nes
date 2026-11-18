# Data naming — batch 5: bank `$3B` (fight HUD, VS and select screens)

- **Status:** **APPLIED** — 35 names applied in `annotations/sf2ne.ann` and `src/*.s`; ROM SHA-1 unchanged.
- **Scope:** the 35 automatic `D3B_*` labels of `src/bank_3B.s`.
- **Source of truth:** `annotations/sf2ne.ann`, `src/bank_3B.s` (consumers), `src/bank_20.s` (metasprite targets), `src/ram.inc`, `docs/RAM.md` and direct RLE stream decoding.
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

### 1.1 RLE format (corrected reading)

`PpuUnRle` (`3B:E3BE`) does **not** read a value byte after the repeat count. The stream is:

```
tag, literal, literal, ..., tag, count, tag, count, ..., tag, $00 (end)
```

- a byte different from `tag` is written literally and becomes the "last byte";
- `tag, count` repeats the **last literal byte** `count` times;
- `tag, $00` ends the stream.

This matters for sizes: an earlier screening pass that consumed an extra value byte produced 1011/456/471/61; the correct decode gives round numbers:

| Label | Raw bytes | Decompressed | Covers |
|-------|-----------|--------------|--------|
| `EA94` | 94 | **1,024** | `$2800`: 960 nametable + 64 attribute bytes (full screen) |
| `F3AB` | 270 | **480** | `$2800`: rows 0–14 |
| `F4B9` | 127 | **480** | rows 15–29 |
| `F538` | 13 | **64** | `$2BC0`: the 64 attribute bytes of the select screen |

The three select streams are written back-to-back at `$2800` (`SelectScreenBuild`, `3B:F38C-F3A8`), so 480 + 480 + 64 = 1,024 = nametable + attributes.

### 1.2 Fade tables

| Routine | Where | Reads | Meaning |
|---------|-------|-------|---------|
| `FadeOut_Bank3B` | `3B:E426` | `ldx #$09`, steps 9→0 | 10 fade-out steps |
| `FadeOutDarkenLoop` | `3B:E480-E497` | `E406,x` (upper bound), `E410,x` (lower bound) | darkens a color when `E410 ≤ color < E406` |
| `FadeIn` | `3B:E4D6` | `ldx #$06`, steps 6→0 | 7 fade-in steps |
| `FadeIn_ColorLoop` | `3B:E561-E577` | `E420,x` (lower), `E41A,x` (upper) | brightens a color when `E420 ≤ color < E41A` |

`E406`/`E410` have 10 bytes (steps 0–9); `E41A`/`E420` have 6 bytes (steps 0–5).

> **Quirk (do not fix):** `FadeIn` starts at `x = 6`, but the two 6-byte tables only cover 0–5. At `x = 6`, `E41A+6` is `E420[0] = $30` and `E420+6` is the first byte of `FadeOut_Bank3B` (`$A2`). Since a NES color is `$00–$3F`, the condition `$A2 ≤ color < $30` is impossible, so the first fade-in step is a no-op. Register in `docs/lessons.md` only if it becomes a recurring reading pitfall.

### 1.3 Projectile frames

`DrawProjectile` (`3B:F27F`) splits into two paths:

- **clash** (`ProjFlags` bit 7): `y = ((ProjStep >> 1) & 7) << 1`, then `E595,y` / `E595+1,y` → 4 metasprite pointers (`ProjectileClashFrame0..3` in `$20`).
- **flight**: `y = ((ProjSpeed >> 1) << 3) + (((ProjStep >> 1) & 3) << 1)`, then `E57D,y` / `E57D+1,y` → 4 pointers (`ProjectileFrame0`, `Frame0`, `Frame1`, `Frame1`).

`ProjSpeed` is `$00/$01/$02` (`3F:E837`); `ProjSpeedStepTbl` only fills 0 and 1. For speeds 0/1 `ProjSpeed >> 1 = 0`, so `E57D` is the table in use; speed 2 would read the 16 `$00` padding bytes at `E585-E594` (not reachable in the demo). `E595` has exactly 4 words.

### 1.4 HUD tables

| Data | Consumer | Use |
|------|----------|-----|
| `E808-E81B` | `3B:E6A0-E6EA` | 20-byte marquee `"     PRESS     START"` copied as a 5-byte window into `ram_040D-0411` (P1) or `ram_0413-0417` (P2). The window index advances 5 bytes every 32 frames (0, 5, 10, 15 → blank, `PRESS`, blank, `START`). Used when the fighter is CPU (`FighterIsCpu != 0`); a human fighter shows the fixed `"P1"`/`"P2"`. |
| `E81C-E824` | `3B:E6F9-E717` | P1 wins graphic: 3 rows (wins 0/1/2) × 3 tile bytes. `x = FighterWins * 3`; `E81C,x`/`E81D,x`/`E81E,x` are the three consecutive column bases. Each byte is written twice: `+$00` to `ram_0419-041B` and `+$10` to `ram_041C-041E` (second CHR row). |
| `E825-E82D` | `3B:E720-E73E` | same for P2 (`FighterWins+1` → `ram_041F-0421` / `ram_0422-0424`). |
| `E82E-E836` | `3B:E776` | P1 HP bar cell tiles, index 0–7 (8 gradient tiles), `+$08` = second CHR row. Byte 8 (`$70`) is the "full" tile written separately at round start (`3B:E5FB-E60A`). |
| `E837-E83F` | `3B:E799` | same for P2. |
| `E840-E841` | `3B:E7C9` | low-HP warning (HP < `$2C`), left tile for P1/P2; `+$10` = second row. |
| `E842-E843` | `3B:E7D5` | low-HP warning, right tile for P1/P2. |

The wins graphic sits at the outer end of each HP bar (left for P1 at `$2881-$2883`/`$28A1-$28A3`, right for P2 at `$289C-$289E`/`$28BC-$28BE`) and has 3 possible states (`FighterWins = 0..2`).

### 1.5 VS screen and win quote

`VersusDraw` (`3B:EAF2`) sets `PPUADDR = $2800`, decompresses `EA94` (full screen), then copies 6 bytes from `EA8E` to `PaletteBuf+6` (BG palettes 2 and 3).

`ScreenWinQuote` (`3B:EC1B`) re-copies `EA91`/`EA92`/`EA93` into `PaletteBuf+9/+10/+11` (BG palette 3) after clearing the screen. So `EA8E-EA90` are the three colors of BG palette 2 and `EA91-EA93` are the three colors of BG palette 3, shared by both screens.

### 1.6 Select screen

`SelectScreenBuild` (`3B:F376`):

- copies 6 bytes from `F545` to `PaletteBuf+6` (BG palettes 2/3);
- copies 6 bytes from `F54B` to `PaletteBuf+18` (sprite palettes 2/3 — `PaletteBuf` is 8 palettes × 3: 0–11 BG, 12–23 sprite);
- decompresses `F3AB` + `F4B9` + `F538` at `$2800`.

### 1.7 Round intro

`RoundIntroDraw` (`3B:F71C`) computes `x = ((RoundNumber * 8) + RoundStep) * 2` and loads a word from `F799` into `zp_D9`, then draws that metasprite (`FightTextZoomLarge/Medium/Small`, `FightText`, `RoundTextFlash`, `RoundText1..4`). 32 words cover 4 round groups × 8 steps.

`RoundIntro_StepDelay` (`3B:F6F2`) loads `F7D9,x` with `x = RoundStep` (0–7) and stores `value - 1` in `RoundStepTimer`; step 6 queues voice `"ROUND"`, step 5 the round number, step 3 `"FIGHT"`.

### 1.8 Stage bank table

`VersusLoadStage` (`3B:E298`) and `RoundInitLoadStage` (`3B:E383`) read `F8FE,x` with `x = ram_03B5` (country 0–9), then `ora #$80; sta MMC5_PRG_C000`: countries 0–4 → bank `$36`, 5–9 → bank `$3A`.

### 1.9 Reset vector filler

`D3B_FF9F` is 91 bytes of `$FF` (`FF9F-FFF9`). In non-`FIX_SOFT_RESET` builds the reset vector at `FFFC` points to it. In `FIX_SOFT_RESET` builds the vector points to `ResetStub` (`FC6D`), which switches to bank `$3F` and jumps to `$FF9F` there (the real `Reset`). See `docs/BUGS.md` §1.

## 2. Proposed names

### 2.1 Fade and projectile tables

| Address | Current | Proposed | Size | Consumer | Confidence |
|---------|---------|----------|------|----------|------------|
| `3B:E406` | `D3B_E406` | `FadeOutMaxTbl` | 10 | `3B:E483` | HIGH |
| `3B:E410` | `D3B_E410` | `FadeOutMinTbl` | 10 | `3B:E488` | HIGH |
| `3B:E41A` | `D3B_E41A` | `FadeInMaxTbl` | 6 | `3B:E569` | HIGH |
| `3B:E420` | `D3B_E420` | `FadeInMinTbl` | 6 | `3B:E564` | HIGH |
| `3B:E57D` | `D3B_E57D` | `ProjectileFrameTbl` | 4 words + 16 pad | `3B:F2C6` | HIGH |
| `3B:E595` | `D3B_E595` | `ProjectileClashFrameTbl` | 4 words | `3B:F2A8` | HIGH |

### 2.2 HUD

| Address | Current | Proposed | Size | Consumer | Confidence |
|---------|---------|----------|------|----------|------------|
| `3B:E808` | `D3B_E808` | `PressStartScrollText` | 20 (base) | `3B:E6A0`, `3B:E6CF` | HIGH |
| `3B:E809` | `D3B_E809` | `PressStartScrollTextOfs1` | window +1 | `3B:E6A6`, `3B:E6D5` | HIGH |
| `3B:E80A` | `D3B_E80A` | `PressStartScrollTextOfs2` | window +2 | `3B:E6AC`, `3B:E6DB` | HIGH |
| `3B:E80B` | `D3B_E80B` | `PressStartScrollTextOfs3` | window +3 | `3B:E6B2`, `3B:E6E1` | HIGH |
| `3B:E80C` | `D3B_E80C` | `PressStartScrollTextOfs4` | window +4 | `3B:E6B8`, `3B:E6E7` | HIGH |
| `3B:E81C` | `D3B_E81C` | `HudWinsP1Col0Tbl` | 1 (col base) | `3B:E6F9` | HIGH |
| `3B:E81D` | `D3B_E81D` | `HudWinsP1Col1Tbl` | 1 (col base) | `3B:E704` | HIGH |
| `3B:E81E` | `D3B_E81E` | `HudWinsP1Col2Tbl` | 7 (rest of table) | `3B:E70F` | HIGH |
| `3B:E825` | `D3B_E825` | `HudWinsP2Col0Tbl` | 1 (col base) | `3B:E720` | HIGH |
| `3B:E826` | `D3B_E826` | `HudWinsP2Col1Tbl` | 1 (col base) | `3B:E72B` | HIGH |
| `3B:E827` | `D3B_E827` | `HudWinsP2Col2Tbl` | 7 (rest of table) | `3B:E736` | HIGH |
| `3B:E82E` | `D3B_E82E` | `HudHpBarP1Tbl` | 9 (8 used) | `3B:E776` | HIGH |
| `3B:E837` | `D3B_E837` | `HudHpBarP2Tbl` | 9 (8 used) | `3B:E799` | HIGH |
| `3B:E840` | `D3B_E840` | `HudLowHpWarnLeftTbl` | 2 | `3B:E7C9` | HIGH |
| `3B:E842` | `D3B_E842` | `HudLowHpWarnRightTbl` | 2 | `3B:E7D5` | HIGH |

### 2.3 VS / win quote

| Address | Current | Proposed | Size | Consumer | Confidence |
|---------|---------|----------|------|----------|------------|
| `3B:EA8E` | `D3B_EA8E` | `VersusBgPalette` | 6 (2 palettes) | `3B:EB08` (6-byte copy) | HIGH |
| `3B:EA91` | `D3B_EA91` | `VersusBgPal3Color0` | 1 | `3B:EC45` | HIGH |
| `3B:EA92` | `D3B_EA92` | `VersusBgPal3Color1` | 1 | `3B:EC4B` | HIGH |
| `3B:EA93` | `D3B_EA93` | `VersusBgPal3Color2` | 1 | `3B:EC51` | HIGH |
| `3B:EA94` | `D3B_EA94` | `VersusBgRle` | 94 → 1,024 | `3B:EAFC` | HIGH |

### 2.4 Select screen

| Address | Current | Proposed | Size | Consumer | Confidence |
|---------|---------|----------|------|----------|------------|
| `3B:F3AB` | `D3B_F3AB` | `SelectBgTopRle` | 270 → 480 (rows 0–14) | `3B:F396` | HIGH |
| `3B:F4B9` | `D3B_F4B9` | `SelectBgBottomRle` | 127 → 480 (rows 15–29) | `3B:F39D` | HIGH |
| `3B:F538` | `D3B_F538` | `SelectBgAttrRle` | 13 → 64 (attributes) | `3B:F3A4` | HIGH |
| `3B:F545` | `D3B_F545` | `SelectBgPalette` | 6 | `3B:F37D` | HIGH |
| `3B:F54B` | `D3B_F54B` | `SelectSpritePalette` | 6 | `3B:F383` | HIGH |

### 2.5 Round intro, stage and reset

| Address | Current | Proposed | Size | Consumer | Confidence |
|---------|---------|----------|------|----------|------------|
| `3B:F799` | `D3B_F799` | `RoundIntroMetaspriteTbl` | 32 words | `3B:F727` | HIGH |
| `3B:F7D9` | `D3B_F7D9` | `RoundIntroStepDelayTbl` | 8 | `3B:F6F2` | HIGH |
| `3B:F8FE` | `D3B_F8FE` | `StageBankTbl` | 10 | `3B:E298`, `3B:E383` | HIGH |
| `3B:FF9F` | `D3B_FF9F` | `ResetVectorFill` | 91 | reset vector `3B:FFFC` | HIGH |

## 3. Conventions and notes

- Names in English, CamelCase, without `D3B_`.
- `Tbl` = indexed table; `Rle` = compressed stream; `Palette` = the 6-color block copied to `PaletteBuf` (2 palettes × 3) in this batch; `PalN` = NES BG palette N; `ColorN` = Nth color of a palette.
- `Hud` prefix for fight-HUD data; `Select` for the character-select screen; `Versus` for the VS/win-quote screens; `RoundIntro` for the round-intro animation.
- `Top`/`Bottom` in the select screen mean rows 0–14 and 15–29 (two equal 480-byte halves), not the three bands of the stage background.
- **Sliding-window labels:** `PressStartScrollTextOfs1..4` and `HudWinsP*Col0..2Tbl` are consecutive addresses read with the same index; in the generated source each may own only 1 byte before the next label. Comments must state the real span.
- **Do not "fix" the fade quirk** (`FadeIn` step 6 is a no-op) nor the projectile speed-2 padding read. They are original behavior.
- `HudHpBarP1Tbl`/`P2Tbl` have 9 bytes, but the only loop uses indices 0–7; byte 8 (`$70`) is the full-bar tile written at round start.

## 4. Risks and validation

- **Risk:** low. Only `label 3B:XXXX <Name>` and `comment` lines enter `annotations/sf2ne.ann`; no `.byte`/`.word`/`.res` directive is touched.
- **Actual side effect:** `src/bank_3B.s` cites the new names; the cross-reference comments in `src/kernel.inc` (`tabela ResetVectorFill`) and the three literal `comment 20:...` lines in `annotations/sf2ne.ann` were updated too. Addresses in comments did not change.
- **Validation (all performed):**
  1. `make gen` without error (its translation-only diff is not committed — see §5.1);
  2. `make` without error;
  3. SHA-1 of `build/sf2ne.nes` = `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`;
  4. `git diff -U0 -- src` without any `.byte`/`.word`/`.res` operand changed;
  5. `src/bank_05.s` (Ken, manual source) without references to `D3B_*`;
  6. `grep -c '^D3B_' src/bank_3B.s` = 0.
- **Documentation (done):** the RLE repeat semantics are recorded in `docs/lessons.md` §10, together with the generator/translation desynchronization found while applying this batch.
- **Expected metric:** 35 labels leave `autoD` (1,108 → **1,073**); `semantic unique` rises from 1,033 to **1,068**; per-bank semantic sum 1,037 → **1,072**. Bank `$3B` goes from 228 semantic + 35 autoD to 263 semantic + 0 autoD.

## 5. Application result

Applied on 2026-11-17, with the user's approval.

### 5.1 What changed

| File | Change |
|------|--------|
| `annotations/sf2ne.ann` | 35 `label 3B:XXXX <Name>` plus `comment` lines in a new `# --- data ---` block at the end of the bank `$3B` section; the three literal `comment 20:...` lines now cite `RoundIntroMetaspriteTbl`, `ProjectileFrameTbl` and `ProjectileClashFrameTbl`. |
| `src/bank_3B.s` | 35 label definitions renamed and every reference updated (83 lines). |
| `src/bank_20.s` | 3 comment lines updated (the `$3B` names they cross-reference). |
| `src/kernel.inc` | 2 comment lines updated (`tabela ResetVectorFill`). |

No byte-producing directive changed: `src/bank_05.s` (Ken, hand-written) was not touched, and the only `.word` operand that changed is `.word D3B_FF9F` → `.word ResetVectorFill`.

**Generator note:** `make gen` currently produces a ~1,000-line comment diff because `annotations/sf2ne.ann` is in English while the committed `src/*.s` still carry the pre-translation Portuguese comments (see `docs/lessons.md` §10). To keep this batch reviewable, the 35 renames were applied mechanically to `src/*.s` and comment columns were re-aligned to the generator's canonical column (48). The new `comment` bodies exist in the annotations and will reach `src` on the next dedicated regeneration commit.

### 5.2 Validation

| Check | Result |
|-------|--------|
| `make` | OK |
| ROM SHA-1 | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to the pre-batch build |
| `.byte`/`.word`/`.res` operands | no numeric operand changed (verified with `git diff -U0` filtering out lines that only carry a renamed symbol) |
| `grep -c '^D3B_' src/bank_3B.s` | 0 |
| `grep -rn 'D3B_' src/` | 0 |
| `src/bank_05.s` | not modified |

### 5.3 Metrics after the batch

| Metric | Before | After |
|--------|--------|-------|
| Label definitions | 2,145 | **2,145** |
| Unique names | 2,141 | **2,141** |
| Automatic data (`D`) | 1,108 | **1,073** |
| Automatic code (`L`) | 0 | **0** |
| Unique semantic | 1,033 | **1,068** |
| Per-bank semantic sum | 1,037 | **1,072** |
| Bank `$3B` | 228 semantic + 35 autoD | **263 semantic + 0 autoD** |

The 1,072 vs 1,068 difference remains explained by `ResetStub` (3×), `RoundStart` (2×) and `InputButtons` (2× in `$3F`); including the three same-line-comment labels gives 1,071 unique semantic and 1,075 per-bank sum.
