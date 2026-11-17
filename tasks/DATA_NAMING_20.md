# Data naming — batch 3: bank `$20` (HUD, effects, and portrait)

- **Status:** **PROPOSED** — awaiting approval to apply in `annotations/sf2ne.ann`.  
- **Scope:** the 30 automatic `D20_*` labels of `src/bank_20.s`.  
- **Source of truth:** `annotations/sf2ne.ann`, `docs/FORMATS.md`, consumers in `src/bank_3B.s` / `src/bank_37.s` / `src/bank_3C.s`, and direct CHR decoding of `build/sf2ne.nes`.  
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

### 1.1 How sprites were read

Bank `$20` stores metasprites in the format used by `DrawMetasprite` (`3B:F2EA`):

```
[chrPage] [$FF] [attr] [count] [dx] [dy] [tiles...]  ...  $80
```

- `byte[0]` = 2 KB CHR page (read by caller and written to `MMC5_CHR_SPR5`);
- the next byte is the OAM attribute. In intro, round-end, and flag metasprites the caller already enters with `y=1`, so the `$FF` appearing there is **skipped** (separator); in projectiles and cursor the caller enters with `y=0` and the next byte is already the attribute;
- `count` = sprite count; `dx`/`dy` = offset relative to base;
- group terminator = `count` with bit 7 set (`$80`).

Each sprite is **8x16**: tile `t` draws `(t, t+1)` on the PPU. To read content, CHR was decoded from `build/sf2ne.nes` (2 bits per pixel) and rendered in ASCII. Relevant pages:

| Page | CHR offset | Content |
|------|------------|---------|
| `$00` | `$0000` | country flags |
| `$01` | `$0800` | intro round font (`BATTLE`, `ROUND`, `FIGHT`, digits) |
| `$02` | `$1000` | projectile and projectile clash |
| `$03` | `$1800` | round end (`PERFECT`, `TIME OVER`, `YOU LOSE`, `YOU WIN`, `DRAW GAME`) |

### 1.2 Consumers

| Flow | Where | What it proves |
|------|-------|----------------|
| `RoundIntroDraw` | `3B:F71C-F796` | `8469` = "BATTLE"; `D3B_F799` chooses intro step text |
| `D3B_F799` | `3B:F799-F7D7` | `84C6`/`84B9`/`84AC` = "FIGHT!" in 3 sizes; `8574` = "FIGHT"; `8580` = flash text; `858E`/`859E`/`85AE`/`85BE` = "ROUND 1..4" |
| `SelectDrawCursor` | `37:EFFA-F031` | `8476` = selection cursor (drawn by `SelectDrawBlink`) |
| `D37_F29B` + `D37_F293` | `37:F293-F2A2` | cursor→character and cursor→flag map (see §2.3) |
| `RoundEnd_DrawTie` | `3B:F887-F89F` | `84A1` = "DRAW GAME" (clock at zero tie) |
| `RoundEnd_DrawTieAlt` | `3B:F8A2-F8B2` | `848B` = tie variant (clock still running) |
| `RoundEnd_DrawPerfect` | `3B:F858-F85A` | `852B` = "PERFECT!" |
| `RoundEnd_TimeUpCheck` | `3B:F7F0-F816` | `85CE` = "TIME OVER" |
| `RoundEnd_DrawYouWin` | `3B:F846-F84A` | `85EA` = "YOU WIN" |
| `RoundEnd_DrawYouLose` | `3B:F874-F884` | `85D9` = "YOU LOSE" |
| `DrawProjectile` / `DrawProjectileSprite` | `3B:F27A-F2CE` | `8509`/`851A` = 2 frames of normal projectile (`D3B_E57D`) |
| `ProjClash` + `D3B_E595` | `3F:E8BB-E8EC` / `3B:E595` | `853A`/`8549`/`8556`/`8565` = 4 frames of projectile clash |
| `PortraitWinLayoutTbl` | `3C:84A6` (`3C:84B6`) | index 8 = M.BISON → `D20_8391` (victory portrait) |

> Bit 7 of `ProjFlags` is set by `ProjClash` when both projectiles are less than `$18` px apart; it is what selects `D3B_E595` (clash) instead of `D3B_E57D` (normal flight).

## 2. Proposed names

### 2.1 Portrait

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `20:8391` | 216 | `PortraitWinLayoutTbl[8]` (`3C:84B6`) | `PortraitWinMBison` | HIGH |

> `docs/ARCHITECTURE.md` §4.1 confirms `8 = M.BISON` and `CharFrameBankTbl[8] = $20`. Index 8 of `PortraitWinLayoutTbl` points to `D20_8391`, so it is M.Bison's victory portrait. Bank `$20` also stores the HUD; this is the only portrait in it.

### 2.2 Round intro

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `20:8469` | 13 | `RoundIntroDraw` (`3B:F78C`) | `RoundIntroBattleText` | HIGH |
| `20:84AC` | 13 | `D3B_F799` (`3B:F79D`) | `FightTextZoomSmall` | HIGH |
| `20:84B9` | 13 | `D3B_F799` (`3B:F79B`) | `FightTextZoomMedium` | HIGH |
| `20:84C6` | 13 | `D3B_F799` (`3B:F799`) | `FightTextZoomLarge` | HIGH |
| `20:8574` | 12 | `D3B_F799` (`3B:F79F`) | `FightText` | HIGH |
| `20:8580` | 14 | `D3B_F799` (`3B:F7A1`, `3B:F7D1`) | `RoundTextFlash` | MEDIUM |
| `20:858E` | 16 | `D3B_F799` (`3B:F7A3`) | `RoundText1` | HIGH |
| `20:859E` | 16 | `D3B_F799` (`3B:F7B3`) | `RoundText2` | HIGH |
| `20:85AE` | 16 | `D3B_F799` (`3B:F7C3`) | `RoundText3` | HIGH |
| `20:85BE` | 16 | `D3B_F799` (`3B:F7D3`) | `RoundText4` | HIGH |

Sprite reading:

- `8469` = **BATTLE** (B,A,T,T,L,E).
- `84AC` / `84B9` / `84C6` = **FIGHT!** in three increasing sizes (same text, art with more fill each step).
- `8574` = **FIGHT**.
- `858E` / `859E` / `85AE` = **ROUND 1 / 2 / 3** ("ROUND" at `dx=0`, digit at `dx=$30`).
- `8580` = compact **ROUND** text used as flash (appears at steps 6 and 4 of the sequence, 2 frames each). Exact glyph segmentation is hard, but consumer and position in the sequence confirm it is the flash variant of round text — hence MEDIUM.

> **Particularity of `85BE`:** digit `$46` ("4") is at `dx=0` and "ROUND" at `dx=$10`, i.e. drawing order is **"4" + "ROUND"**, inverted relative to `858E`/`859E`/`85AE`. Name `RoundText4` describes content (round 4), not visual order. Worth recording as curiosity/possible original bug; do not fix in this batch.

### 2.3 Character selection

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `20:8476` | 21 | `SelectDrawCursor` (`37:F001`) → `SelectDrawBlink` | `SelectCursorMetasprite` | HIGH |
| `20:84D3` | 9 | `D37_F29B` (`37:F29C`) | `FlagBrazil` | HIGH |
| `20:84DC` | 9 | `D37_F29B` (`37:F2A0`) | `FlagChina` | HIGH |
| `20:84E5` | 9 | `D37_F29B` (`37:F29B`) | `FlagJapan` | HIGH |
| `20:84EE` | 9 | `D37_F29B` (`37:F29E`, `37:F2A2`) | `FlagThailand` | HIGH |
| `20:84F7` | 9 | `D37_F29B` (`37:F29D`, `37:F29F`) | `FlagUsa` | HIGH |
| `20:8500` | 9 | `D37_F29B` (`37:F2A1`) | `FlagUssr` | HIGH |

**Flag map** (`D37_F293` = cursor→character; `D37_F29B` = cursor→flag):

| Cursor | Character (`D37_F293`) | Flag | Name |
|--------|------------------------|------|------|
| 0 | 0 RYU | `84E5` | Japan |
| 1 | 4 BLANKA | `84D3` | Brazil |
| 2 | 3 GUILE | `84F7` | USA |
| 3 | 7 SAGAT | `84EE` | Thailand |
| 4 | 1 KEN | `84F7` | USA |
| 5 | 2 CHUN LI | `84DC` | China |
| 6 | 9 ZANGIEF | `8500` | USSR |
| 7 | 8 M.BISON | `84EE` | Thailand |

> `84F7` and `84EE` are shared by two characters each (USA: Guile/Ken; Thailand: Sagat/M.Bison), consistent with the roster. Character order comes from `CharNameTbl` (`3C:84CE`) and `docs/ARCHITECTURE.md` §4.1.

### 2.4 Round end

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `20:848B` | 22 | `RoundEnd_DrawTieAlt` (`3B:F8A2`) | `RoundEndDrawTieAltMetasprite` | MEDIUM |
| `20:84A1` | 11 | `RoundEnd_DrawTie` (`3B:F88F`) | `DrawGameText` | HIGH |
| `20:852B` | 15 | `RoundEnd_DrawPerfect` (`3B:F858`) | `PerfectText` | HIGH |
| `20:85CE` | 11 | `RoundEnd_TimeUpCheck` (`3B:F806`) | `TimeOverText` | HIGH |
| `20:85D9` | 17 | `RoundEnd_DrawYouLose` (`3B:F874`) | `YouLoseText` | HIGH |
| `20:85EA` | 70¹ | `RoundEnd_DrawYouWin` (`3B:F846`) | `YouWinText` | HIGH |

- `84A1` = **DRAW GAME**: 4 sprites 8x16, each with two 8x8 characters stacked (top line "DRAW", bottom line "GAME").
- `852B` = **PERFECT!** (7 letters + exclamation).
- `85CE` = **TIME OVER**: 4 sprites 8x16, two 8x8 characters per sprite ("TIME" on top, "OVER" below).
- `85D9` = **YOU** (`dx=0`) + **LOSE** (`dx=$20`).
- `85EA` = **YOU** (`dx=0`) + **WIN** (`dx=$20`).
- `848B` = 48x32 image (6x2 sprites of 8x16) used in tie with clock still running. Content is not readable text in rendering; name describes consumer (`RoundEnd_DrawTieAlt`), hence MEDIUM.

> ¹ `85EA` has 70 bytes in the inventory because the label extends to `.res` at `8630`; the metasprite itself ends at `85F9` (16 bytes). Bytes `85FA-862F` are not referenced by any known consumer and are out of scope of the name — we make no claim about them.

### 2.5 Projectiles

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `20:8509` | 17 | `D3B_E57D` (`3B:E57D`) | `ProjectileFrame0` | HIGH |
| `20:851A` | 17 | `D3B_E57D` (`3B:E581`) | `ProjectileFrame1` | HIGH |
| `20:853A` | 15 | `D3B_E595` (`3B:E595`) | `ProjectileClashFrame0` | MEDIUM |
| `20:8549` | 13 | `D3B_E595` (`3B:E597`) | `ProjectileClashFrame1` | MEDIUM |
| `20:8556` | 15 | `D3B_E595` (`3B:E599`) | `ProjectileClashFrame2` | MEDIUM |
| `20:8565` | 15 | `D3B_E595` (`3B:E59B`) | `ProjectileClashFrame3` | MEDIUM |

> The two projectile metasprites are drawn in sequence by `DrawProjectileMetasprite` (`jsr` + `jmp`). `8509`/`851A` are flight frames; `853A`/`8549`/`8556`/`8565` are clash frames (`ProjFlags` bit 7). Numbering `0..3` is just address order, not an asserted animation order.

## 3. Conventions and decisions

- Names in English, CamelCase, without `D20_`.
- `...Text` for text metasprites; `FightTextZoomSmall/Medium/Large` for the three "FIGHT!" sizes.
- `Flag<Country>` for flags; `Projectile*` for projectiles.
- `PortraitWinMBison` follows the prefix already used in `PortraitWinLayoutTbl` / `PortraitBuild`.
- `848B` keeps a consumer-descriptive name because graphic content is not readable; MEDIUM confidence, like other non-textual art cases.

## 4. Risks and validation

- **Risk:** low. No `.byte`/`.word`/`.patch` directive is touched; only `label 20:XXXX <Name>` lines (and comments) enter `annotations/sf2ne.ann`.
- **Expected side effect:** `src/bank_20.s` and `src/globals.inc` start using new names; generated comments citing `D20_*` change (text, not bytes). References in `src/bank_3B.s`, `src/bank_37.s`, and `src/bank_3C.s` start citing new names.
- **Mandatory validation after approval:**
  1. `make gen` without error;
  2. `make` without error;
  3. SHA-1 of `build/sf2ne.nes` = `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`;
  4. `git diff -U0 -- src` without any `.byte`/`.word`/`.patch` line changed;
  5. confirm that `src/bank_05.s` (Ken, manual source) does not reference `D20_*`.
- **Expected metric:** the 30 labels leave `autoD`; `semantic unique` should rise from 976 to 1,006 (if all applied), keeping `autoL=0`.

## 5. Application result

The 30 names were applied in `annotations/sf2ne.ann` (section `# BANCO $20`, between `$3C` and `# RAM`). Validation executed:

- `make gen`: OK; `src/bank_20.s`, `src/bank_37.s`, `src/bank_3B.s`, `src/bank_3C.s`, and `src/globals.inc` regenerated only with new names.
- `make`: OK.
- SHA-1 of `build/sf2ne.nes`: `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` (identical).
- `src/bank_20.s`: **0** `D20_*` labels remaining; the 144 `.byte`/`.word` of the bank keep the same operands (only generated comments changed).
- `src/bank_37.s` / `src/bank_3B.s` / `src/bank_3C.s`: only changes are swapping `D20_*` for new names, with same addresses in comments (`; F29B E5`, `; E57D 09 85`, `; 84B6 91 83`, …).
- `src/bank_05.s` (Ken, manual source): **0** references to `D20_*`.
- Canonical metric after batch: `defs=2145`, `unique=2141`, `autoL=0`, `autoD=1135` (before: 1,165), `semantic unique=1006` (before: 976), `semantic sum=1010` (before: 980).
