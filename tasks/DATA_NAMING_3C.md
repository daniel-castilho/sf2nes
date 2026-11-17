# Data naming — batch 1: bank `$3C` (character sheets, palettes, and portraits)

- **Status:** **APPLIED** in `annotations/sf2ne.ann`; build and SHA-1 validated.  
- **Scope:** the 33 automatic `D3C_*` labels of `src/bank_3C.s`.  
- **Source of truth:** `annotations/sf2ne.ann` (labels/comments) + reading of consumers in `src/bank_3B.s` and `src/bank_3F.s`.  
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

| Flow | Where | What it proves |
|------|-------|----------------|
| `FighterLoadChar` | `3B:E000-E097` | loads 23 tables of 10 bytes (one column per character) from `$3C` |
| `InputDispatch` / `TransViaTbl` | `3F:F695-F703` | consumes transition tables by direction, attack, and special |
| `GuardRedirect` | `3F:F704-F74B` | consumes guard reaction table by `HitReactClass` |
| `HitDamageReact` / `AnimUpdate_EE78` | `3F:EE4E-EEB5` | consumes damage reaction tables by phase (`FighterState & 3`) |
| `PortraitLoadPalettes` | `3B:E181-E1F5` | sums `FighterChar*12` and reads 3 palettes (9 colors) from 3 tables |
| `PortraitSetupP1/P2` | `3B:EE38-EF60` | chooses victory/defeat palette/layout/tiles tables |
| `RoundIntro_DrawNames` | `3B:E63E-E684` | uses name length to center/clear name on screen |

Proposed conventions: prefix `Char` for tables indexed by character; suffix `Tbl`; `Lo`/`Hi` for the two halves of a pointer; `Portrait*` for portrait-exclusive data.

## 2. Character sheet — 20 pointer tables (10 bytes each)

Each row is a sheet field: 1 byte per character (10 characters). The `Lo`/`Hi` pair forms a 16-bit pointer.

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `3C:8000` | 10 | `FighterLoadChar` → `ram_031E`; `InputDispatch` | `CharDirTransLoTbl` | HIGH |
| `3C:800A` | 10 | `FighterLoadChar` → `ram_0320` | `CharDirTransHiTbl` | HIGH |
| `3C:8014` | 10 | `FighterLoadChar` → `ram_0322`; `InputDispatch` | `CharAttackTransLoTbl` | HIGH |
| `3C:801E` | 10 | `FighterLoadChar` → `ram_0324` | `CharAttackTransHiTbl` | HIGH |
| `3C:8028` | 10 | `FighterLoadChar` → `ram_0326`; `InputDispatch` | `CharSpecialTransLoTbl` | HIGH |
| `3C:8032` | 10 | `FighterLoadChar` → `ram_0328` | `CharSpecialTransHiTbl` | HIGH |
| `3C:803C` | 10 | `FighterLoadChar` → `ram_032A`; `GuardRedirect` | `CharGuardReactLoTbl` | HIGH |
| `3C:8046` | 10 | `FighterLoadChar` → `ram_032C` | `CharGuardReactHiTbl` | HIGH |
| `3C:8050` | 10 | `FighterLoadChar` → `ram_032E`; damage phase 1 | `CharHitReact1LoTbl` | MEDIUM |
| `3C:805A` | 10 | `FighterLoadChar` → `ram_0330` | `CharHitReact1HiTbl` | MEDIUM |
| `3C:8064` | 10 | `FighterLoadChar` → `ram_0336`; damage phase 2 | `CharHitReact2LoTbl` | MEDIUM |
| `3C:806E` | 10 | `FighterLoadChar` → `ram_0338` | `CharHitReact2HiTbl` | MEDIUM |
| `3C:8078` | 10 | `FighterLoadChar` → `ram_0332`; damage phase 0 | `CharHitReact0LoTbl` | MEDIUM |
| `3C:8082` | 10 | `FighterLoadChar` → `ram_0334` | `CharHitReact0HiTbl` | MEDIUM |
| `3C:808C` | 10 | `FighterLoadChar` → `ram_033A`; `HitReactClass=$0C` | `CharHitReact12LoTbl` | MEDIUM |
| `3C:8096` | 10 | `FighterLoadChar` → `ram_033C` | `CharHitReact12HiTbl` | MEDIUM |
| `3C:80A0` | 10 | `FighterLoadChar` → `ram_033E`; command recognizer `3F:EA24` | `CharCmdListLoTbl` | HIGH |
| `3C:80AA` | 10 | `FighterLoadChar` → `ram_0340` | `CharCmdListHiTbl` | HIGH |
| `3C:80B4` | 10 | `FighterLoadChar` → `ram_0342`; character AI | `CharAiScriptLoTbl` | HIGH |
| `3C:80BE` | 10 | `FighterLoadChar` → `ram_0344` | `CharAiScriptHiTbl` | HIGH |

> `CharHitReact0/1/2/12` come from `FighterState & 3` in `3F:EE94-EEB5` and from `HitReactClass=$0C` in `3F:EE51`. Order 0/1/2 is the order of phases read in code, not the physical order in the file.

## 3. Character sheet — auxiliary tables

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `3C:80DC` | 10 | `FighterLoadChar` → `zp_1C`; `LoadHitBoxes` | `CharHitBoxBankTbl` | HIGH |

## 4. Palettes (12 bytes per character: 3 colors + 3 step colors)

`PortraitLoadPalettes` sums `FighterChar*12` and reads 3 bytes from each of the 3 tables. Tables 0/1/2 feed `ram_0300/0303/0306`.

| Address | Bytes | Use in code | Proposed name | Confidence |
|---------|-------|-------------|---------------|------------|
| `3C:80E6` | 120 | `FighterRoundInit` → fight palette 0 | `CharPal0FightTbl` | MEDIUM |
| `3C:815E` | 120 | `FighterRoundInit` → fight palette 1 | `CharPal1FightTbl` | MEDIUM |
| `3C:83B6` | 120 | 3rd shared palette (fight/victory/defeat) | `CharPal2Tbl` | HIGH |
| `3C:81D6` | 120 | `PortraitP1WinSet`/`P2WinSet` → victory palette 0 | `CharPal0WinTbl` | MEDIUM |
| `3C:824E` | 120 | `PortraitP1WinSet`/`P2WinSet` → victory palette 1 | `CharPal1WinTbl` | MEDIUM |
| `3C:82C6` | 120 | `PortraitP1LoseSet`/`P2LoseSet` → defeat palette 0 | `CharPal0LoseTbl` | MEDIUM |
| `3C:833E` | 120 | `PortraitP1LoseSet`/`P2LoseSet` → defeat palette 1 | `CharPal1LoseTbl` | MEDIUM |

## 5. Portraits — tiles, layouts, and names

| Address | Bytes | Consumer | Proposed name | Confidence |
|---------|-------|----------|---------------|------------|
| `3C:842E` | 60 | `PortraitTilesP1/P2` (victory), 6 bytes per character | `PortraitWinTilesTbl` | HIGH |
| `3C:846A` | 60 | `PortraitP1LoseTiles`/`P2LoseTiles`, 6 bytes per character | `PortraitLoseTilesTbl` | HIGH |
| `3C:84A6` | 20 | `PortraitP1WinSet`/`P2WinSet`, 1 word per character | `PortraitWinLayoutTbl` | HIGH |
| `3C:84BA` | 20 | `PortraitP1LoseLayout`/`P2LoseLayout`, 1 word per character | `PortraitLoseLayoutTbl` | HIGH |
| `3C:851E` | 10 | `RoundIntro_DrawNames` and `PortraitNameDestCalc` | `CharNameLenTbl` | HIGH |

## 6. Risks and validation

- **Risk:** low. No `.byte`/`.word`/`.patch` directive is touched; only `label 3C:XXXX <Name>` lines enter `annotations/sf2ne.ann`.
- **Expected side effect:** `src/bank_3C.s`, `src/globals.inc`, and generated comments start using the new names; `src/bank_05.s` does not reference `D3C_*`.
- **Mandatory validation:**
  1. `make gen` without error;
  2. `make` without error;
  3. SHA-1 of `build/sf2ne.nes` = `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`;
  4. `annotations/sf2ne.ann` diff containing only `label` lines;
  5. `git diff --stat` showing changes only in `annotations/`, `src/bank_3C.s`, `src/globals.inc`, and correlating comments.

## 7. Application result

The 33 names were applied in `annotations/sf2ne.ann`. Validation performed:

- `make gen`: OK; `src/bank_3C.s`, `src/bank_3B.s`, and `src/globals.inc` regenerated only with new names.
- `make`: OK.
- SHA-1 of `build/sf2ne.nes`: `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` (identical).
- Data diff: **0** `.byte`/`.word` lines changed; 33 labels swapped.
- `src/bank_05.s` (Ken, hand-written) does not reference `D3C_*`, so it was not touched.
- Canonical metric after batch: `autoD=1180`, `semantic=961` (before: 1,213 / 928).
