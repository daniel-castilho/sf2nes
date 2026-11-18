# Data naming — batch 4: bank `$36` (stages)

- **Status:** **APPLIED** — 27 names applied in `annotations/sf2ne.ann`; 3 write-only labels kept automatic.  
- **Scope:** the 30 automatic `D36_*` labels of `src/bank_36.s`.  
- **Source of truth:** `annotations/sf2ne.ann`, `src/bank_3B.s` (`VersusLoadStage`, `RoundInitLoadStage`), `src/kernel.inc` (screen-split IRQ), `docs/RAM.md` and direct RLE stream decoding of `src/bank_36.s`.  
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

### 1.1 Stage flow

| Flow | Where | What it proves |
|------|-------|----------------|
| `ScreenVersus` | `3B:EA61-EA8D` | chooses stage and calls `VersusDraw` + `VersusLoadStage` |
| `VersusLoadStage` | `3B:E28A-E376` | reads `ram_03B5` (country/stage), builds background at `$2800`/`$2C00`, writes IRQ parameters and floor |
| `RoundInitLoadStage` | `3B:E377-E3BB` | reads `ram_03B5`, copies 12 bytes of stage palette to `PaletteBuf` |
| `StageSplitSetup` | `3B:F908-F92D` | arms first fight IRQ at line `ram_0403` (fixed to `$3F` = 63) |
| `Irq_FightFirst` | `kernel.inc` (`FD1C`) | line 63: switches CHR to BG1/BG3 and arms line `ram_0404` |
| `Irq_FightNext` | `kernel.inc` (`FC8E`) | lines `ram_0404`/`ram_0405`: next CHR switches; then enters floor line by line |

Stage index is `ram_03B5` (0 = Japan). `cmp #$05; bcc; sbc #$05` maps 10 countries to 5 layouts; `asl` generates `y = layout*2` for pointer tables and `y = layout` for byte tables. `D3B_F8FE` maps countries 0–4 to bank `$36` and 5–9 to bank `$3A`.

> In this ROM only layout 0 has data: entries 1–4 of `$36` tables are `$00`/`$FF`, and bank `$3A` is practically a stub. `ram_03B5` is always 0 in the demo (fixed opponent Ryu). This does not change names: tables have 5 entries even if only the first is filled.

### 1.2 Background: `$2800` and `$2C00`

`MMC5_NT_MAP = $44` (`3F:F7B3`, vertical mirroring): `$2800` is left nametable (alias of `$2000`) and `$2C00` is right nametable (alias of `$2400`). `VersusLoadStage` writes, in sequence:

| Destination | Streams | Uncompressed bytes | Lines |
|-------------|---------|--------------------|-------|
| `$2800` | `C0DF` → `C2A8` → `C387` | 640 + 192 + 128 = 960 | 0–19 / 20–25 / 26–29 |
| `$2C00` | `C1B6` → `C327` → `C3F5` | 640 + 192 + 128 = 960 | 0–19 / 20–25 / 26–29 |

The three blocks cover the whole nametable (32×30). The first includes the 8 HUD lines (blank tiles `$00`) and stage top band; the second is the middle band; the third is the floor.

Then come 64 raw bytes at `$2BC0` (attributes of `$2800`) and `$2FC0` (attributes of `$2C00`), and a 12-byte palette copied to `PaletteBuf`.

### 1.3 CHR bands and split lines

| RAM | Table | Role in IRQ |
|-----|-------|-------------|
| `ram_0406` / `ram_0409` | `C014` / `C023` | CHR BG1 / BG3 of top band (lines 8–19) |
| `ram_0407` / `ram_040A` | `C019` / `C028` | CHR BG1 / BG3 of middle band (lines 20–25) |
| `ram_0408` / `ram_040B` | `C01E` / `C02D` | CHR BG1 / BG3 of floor (lines 26–29) |
| `ram_0404` | `C032` | split line that starts middle band (`$9F` = 159) |
| `ram_0405` | `C037` | split line that starts floor (`$CF` = 207); also floor scroll initial value |
| `FloorLines` | `C000` | number of parallax floor lines (`$18` = 24) |

## 2. Proposed names

### 2.1 Scalar tables (5 bytes, index = layout)

| Address | Current name | Proposed name | Evidence | Confidence |
|---------|--------------|---------------|----------|------------|
| `36:C000` | `D36_C000` | `StageFloorLinesTbl` | `lda ...; sta FloorLines` (`3B:E2A5`) | HIGH |
| `36:C014` | `D36_C014` | `StageBg1ChrTopTbl` | `sta ram_0406` → `MMC5_CHR_BG1` on 1st band | HIGH |
| `36:C019` | `D36_C019` | `StageBg1ChrMidTbl` | `sta ram_0407` → `MMC5_CHR_BG1` on 2nd band | HIGH |
| `36:C01E` | `D36_C01E` | `StageBg1ChrFloorTbl` | `sta ram_0408` → `MMC5_CHR_BG1` on floor | HIGH |
| `36:C023` | `D36_C023` | `StageBg3ChrTopTbl` | `sta ram_0409` → `MMC5_CHR_BG3` on 1st band | HIGH |
| `36:C028` | `D36_C028` | `StageBg3ChrMidTbl` | `sta ram_040A` → `MMC5_CHR_BG3` on 2nd band | HIGH |
| `36:C02D` | `D36_C02D` | `StageBg3ChrFloorTbl` | `sta ram_040B` → `MMC5_CHR_BG3` on floor | HIGH |
| `36:C032` | `D36_C032` | `StageSplitMidTbl` | `sta ram_0404`; `Irq_FightFirst` arms this line and switches to 2nd band | HIGH |
| `36:C037` | `D36_C037` | `StageSplitFloorTbl` | `sta ram_0405`; `Irq_FightNext` uses as floor line and initial scroll | HIGH |

### 2.2 Pointer tables (5 entries of 2 bytes)

| Address | Current name | Proposed name | Destination | Confidence |
|---------|--------------|---------------|-------------|------------|
| `36:C03C` | `D36_C03C` | `StageBgLeftTopRleTbl` | RLE → `$2800`, lines 0–19 | HIGH |
| `36:C046` | `D36_C046` | `StageBgRightTopRleTbl` | RLE → `$2C00`, lines 0–19 | HIGH |
| `36:C050` | `D36_C050` | `StageBgLeftMidRleTbl` | RLE → `$2800`, lines 20–25 | HIGH |
| `36:C05A` | `D36_C05A` | `StageBgRightMidRleTbl` | RLE → `$2C00`, lines 20–25 | HIGH |
| `36:C064` | `D36_C064` | `StageBgLeftFloorRleTbl` | RLE → `$2800`, lines 26–29 | HIGH |
| `36:C06E` | `D36_C06E` | `StageBgRightFloorRleTbl` | RLE → `$2C00`, lines 26–29 | HIGH |
| `36:C078` | `D36_C078` | `StageBgLeftAttrTbl` | 64 bytes → `$2BC0` (attributes of `$2800`) | HIGH |
| `36:C082` | `D36_C082` | `StageBgRightAttrTbl` | 64 bytes → `$2FC0` (attributes of `$2C00`) | HIGH |
| `36:C08C` | `D36_C08C` | `StagePaletteTbl` | pointer to 12-byte palette copied in `RoundInitLoadStage` | HIGH |

### 2.3 Data blobs

| Address | Current name | Proposed name | Content | Confidence |
|---------|--------------|---------------|---------|------------|
| `36:C0DF` | `D36_C0DF` | `StageBgLeftTopRle` | left background RLE, lines 0–19 (640 bytes) | HIGH |
| `36:C1B6` | `D36_C1B6` | `StageBgRightTopRle` | right background RLE, lines 0–19 (640 bytes) | HIGH |
| `36:C2A8` | `D36_C2A8` | `StageBgLeftMidRle` | left background RLE, lines 20–25 (192 bytes) | HIGH |
| `36:C327` | `D36_C327` | `StageBgRightMidRle` | right background RLE, lines 20–25 (192 bytes) | HIGH |
| `36:C387` | `D36_C387` | `StageBgLeftFloorRle` | left background RLE, lines 26–29 (128 bytes) | HIGH |
| `36:C3F5` | `D36_C3F5` | `StageBgRightFloorRle` | right background RLE, lines 26–29 (128 bytes) | HIGH |
| `36:C460` | `D36_C460` | `StageBgLeftAttr` | 64 bytes of `$2800` attributes | HIGH |
| `36:C4A0` | `D36_C4A0` | `StageBgRightAttr` | 64 bytes of `$2C00` attributes | HIGH |
| `36:C4E0` | `D36_C4E0` | `StagePalette` | 12 bytes of stage palette (4 palettes × 3 colors) | HIGH |

### 2.4 Kept automatic (P3/LOW)

| Address | Current name | Reason |
|---------|--------------|--------|
| `36:C005` | `D36_C005` | written to `ram_03BC`; **no static consumer**. The 29 "reads" from trace come from reset loop `sta ram_0300,x` at `3F:FFC9` (fictitious read of `sta abs,x`), not real use. Values `$17/$27/$37` suggest CHR pages (BG2?) or offsets, but without evidence. |
| `36:C00A` | `D36_C00A` | idem, for `ram_03BD` |
| `36:C00F` | `D36_C00F` | idem, for `ram_03BE` |

> `MMC5_CHR_BG2` is not used anywhere in the ROM; `ram_03BC`–`ram_03BE` are write-only. Renaming would be speculation, so the three labels remain automatic.

## 3. Conventions and notes

- Names in English, CamelCase, without `D36_`.
- Prefix `Stage` for everything stage-related; suffixes `Tbl` (indexed table), `RleTbl` (RLE pointer table), `Rle` (compressed stream), `Attr` (attributes), and `Palette`.
- `Top`/`Mid`/`Floor` describe the three nametable bands (lines 0–19, 20–25, 26–29), which are also the three CHR bands switched by the IRQ.
- **Curiosity (do not fix):** `C000`–`C00F` are read with `y = layout*2`, but each table has 5 bytes; for layouts 3–4 this would read `$FF`. Since only layout 0 is used, observed behavior is the first byte. `C014`–`C037` use `y = layout`. Registered in `docs/lessons.md`.
- **Region without label:** `C096`–`C0DE` (73 bytes) contains a text script with "START"/"RYU" and has no automatic label; it is inside region `C08C`, but is not the palette table. Stays out of this batch (not one of the 30 labels).
- Only layout 0 has data; others are `$00`/`$FF`. Do not infer semantics for other layouts.

## 4. Risks and validation

- **Risk:** low. Only `label 36:XXXX <Name>` lines (and comments) enter `annotations/sf2ne.ann`; no `.byte`/`.word`/`.res` directive is touched.
- **Expected side effect:** `src/bank_36.s`, `src/bank_3B.s`, and `src/globals.inc` start citing new names; addresses in comments do not change.
- **Mandatory validation after approval:**
  1. `make gen` without error;
  2. `make` without error;
  3. SHA-1 of `build/sf2ne.nes` = `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`;
  4. `git diff -U0 -- src` without any `.byte`/`.word`/`.res` line changed;
  5. `src/bank_05.s` (Ken, manual source) without references to `D36_*`.
- **Expected metric:** 27 labels leave `autoD` (1,135 → 1,108); `semantic unique` rises from 1,006 to 1,033. The 3 write-only labels remain automatic.

## 5. Application result

- **Applied on:** 2026-11-17, in `annotations/sf2ne.ann` (section `# BANCO $36`).
- **Committed in:** `fa7c215` (the batch was already applied when that commit bundled the English translation; it has no separate commit).
- **Names applied:** 27 — 9 scalar tables, 9 pointer tables, 9 data blobs.
- **Kept automatic:** 3 — `D36_C005`, `D36_C00A`, `D36_C00F` (write-only in `ram_03BC`–`ram_03BE`, no static consumer).
- **Consumers updated:** `src/bank_36.s` (27 labels, 3 `D36_*` left), `src/bank_3B.s` (`VersusLoadStage`, `RoundInitLoadStage`), `src/globals.inc` (exports).

### 5.1 Validation

| Verification | Result |
|--------------|--------|
| `make gen` | OK |
| `make` | OK — canonical build with `DEST_FLAG_BLINK` |
| SHA-1 of `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to baseline |
| `.byte`/`.word`/`.res` in `src/bank_36.s` | operands unchanged; only labels and comments |
| `src/bank_05.s` (Ken, manual source) | 0 references to `D36_*` |
| `make fixed` | OK — expected divergence (`-D FIX_SOFT_RESET`) |

> `make gen` after `fa7c215` also rewrites the generated file headers back to Portuguese, because `tools/disasm.py` still carries the pre-translation strings. The ROM bytes and labels are unaffected; those header-only diffs were discarded, not committed.

### 5.2 Metrics after the batch

Canonical method: `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s`, with the caveat of the three same-line-comment labels (`EdgeARel`, `EdgeBRel`, `EdgeBBtn`).

| Metric | Before `$36` | After `$36` |
|--------|--------------|-------------|
| Label definitions | 2,145 | **2,145** |
| Unique names | 2,141 | **2,141** |
| Automatic data (`D`) | 1,135 | **1,108** |
| Unique semantic | 1,006 | **1,033** |
| Per-bank semantic sum | 1,010 | **1,037** |

The 1,037 vs 1,033 difference keeps the same explanation as Phase 3: `ResetStub` (3×), `RoundStart` (2×) and `InputButtons` (2× in `$3F`).
