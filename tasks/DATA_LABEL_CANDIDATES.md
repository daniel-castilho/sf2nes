# Data label inventory — initial screening

- **Status:** static screening; names applied in batches `$3C`, `$3F`, `$20`, `$36`, `$3B` and `$37`.  
- **Scope:** 1,213 automatic data labels (`D<bb>_<aaaa>`) in `src/bank_*.s`.  
- **Source:** `src/bank_*.s` generated from `annotations/sf2ne.ann`; read-only.  
- **Objective:** classify by bank/subsystem, references, and category to choose the first data naming batch.  
- **Complete inventory:** `tasks/DATA_LABEL_INVENTORY.tsv` (1,213 rows, tab-separated).  
- **Note:** snapshot prior to data batches. After `tasks/DATA_NAMING_3C.md` (33 labels), `tasks/DATA_NAMING_3F.md` (15), `tasks/DATA_NAMING_20.md` (30), `tasks/DATA_NAMING_36.md` (27), `tasks/DATA_NAMING_3B.md` (35) and `tasks/DATA_NAMING_37.md` (17), **1,056** automatic data labels remain.

## 1. Method

- **`data_bytes`:** bytes emitted by `.byte`/`.word` between label and next label.
- **`res_bytes`:** `.res` padding in same interval (not logical data; separated to avoid inflating size).
- **`unknown=yes`:** there is an `.include` in the interval, so actual size is not known from source alone.
- **References:** occurrences of the label in `src/bank_*.s`, separated into code, data (`.byte`/`.word`) and comments.
- **Category:** heuristic from context comment, bank subsystem, and initial directive.
- **Priority:** `P0` = direct code reference; `P1` = 2+ data references; `P2` = 1 data reference; `P3` = no reference.

> Priority is a screening hint, not a naming decision. Names should only be proposed after reading the flow consuming each table.

## 2. Summary by bank/subsystem

| Bank | Subsystem | Labels | P0 | P1 | P2 | P3 |
|------|-----------|--------|----|----|----|----|
| `$00` | Ryu: metasprites/AI/collision | 206 | 28 | 108 | 70 | 0 |
| `$01` | Ryu: states/animations | 304 | 0 | 33 | 271 | 0 |
| `$04` | Ken: frames/metasprites/collision/portrait | 3 | 0 | 2 | 1 | 0 |
| `$05` | Ken: states/animations | 352 | 0 | 33 | 271 | 48 |
| `$08` | Selection portraits | 1 | 0 | 0 | 1 | 0 |
| `$0C` | Selection portraits | 1 | 0 | 0 | 1 | 0 |
| `$10` | Selection portraits | 1 | 0 | 0 | 1 | 0 |
| `$1C` | Selection portraits | 1 | 0 | 0 | 1 | 0 |
| `$20` | HUD/effects (sprites) | 30 | 8 | 13 | 9 | 0 |
| `$24` | Selection portraits | 1 | 0 | 0 | 1 | 0 |
| `$29` | Music (FamiTone2) | 103 | 4 | 40 | 59 | 0 |
| `$2D` | Music (FamiTone2) | 70 | 1 | 30 | 39 | 0 |
| `$36` | RLE screens + tables | 30 | 21 | 0 | 9 | 0 |
| `$37` | Sound/screens (FamiTone2) | 27 | 15 | 1 | 11 | 0 |
| `$3B` | Fight/HUD/VS/video utilities | 35 | 34 | 0 | 1 | 0 |
| `$3C` | Sheets/selection/VS | 33 | 33 | 0 | 0 | 0 |
| `$3F` | Engine/fighting core | 15 | 15 | 0 | 0 | 0 |
| **Total** | — | **1213** | **159** | **260** | **746** | **48** |

| Subsystem | Labels | P0 | P1 | P2 | P3 |
|-----------|--------|----|----|----|----|
| Engine/fighting core | 15 | 15 | 0 | 0 | 0 |
| Ryu: states/animations | 304 | 0 | 33 | 271 | 0 |
| Ken: states/animations | 352 | 0 | 33 | 271 | 48 |
| Ryu: metasprites/AI/collision | 206 | 28 | 108 | 70 | 0 |
| Ken: frames/metasprites/collision/portrait | 3 | 0 | 2 | 1 | 0 |
| Fight/HUD/VS/video utilities | 35 | 34 | 0 | 1 | 0 |
| Sheets/selection/VS | 33 | 33 | 0 | 0 | 0 |
| RLE screens + tables | 30 | 21 | 0 | 9 | 0 |
| HUD/effects (sprites) | 30 | 8 | 13 | 9 | 0 |
| Music (FamiTone2) | 173 | 5 | 70 | 98 | 0 |
| Sound/screens (FamiTone2) | 27 | 15 | 1 | 11 | 0 |
| Selection portraits | 5 | 0 | 0 | 5 | 0 |

| Category | Labels |
|----------|--------|
| Frame | 502 |
| Data | 338 |
| FamiTone2 | 200 |
| State | 140 |
| PointerTable | 30 |
| AI | 1 |
| Selection | 1 |
| Palette | 1 |

## 3. Short list — P0 (direct code reference), up to 5 per subsystem

These are labels with identifiable code consumer — highest chance of receiving a name based on evidence. List shows up to 5 per subsystem to avoid concentrating everything on `$3F`.

| # | Address | Label | Data (B) | `.res` | Xrefs (code/data/com.) | Category | Consumer (first reference) |
|---|---------|-------|----------|--------|------------------------|----------|----------------------------|
| 1 | `3F:F0B1` | `D3F_F0B1` | 6 | 0 | 6 (2/0/4) | Data | `ldy a:MoveMode,x ; F0A5 BC 2E 00 dispatches movement application via MoveMode (table D3F_F0B1)` |
| 2 | `3F:E4CE` | `D3F_E4CE` | 6 | 0 | 4 (1/0/3) | Data | `lda D3F_E4CE,y ; E4C9 B9 CE E4 [idx $00..$05]` |
| 3 | `3F:E05E` | `D3F_E05E` | 6 | 0 | 2 (2/0/0) | Data | `sta ProjSpeed,x ; E837 95 77 A = speed ($00/$01/$02, step in D3F_E05E): born at FighterX +/- $27, direction = Fight` |
| 4 | `3F:E068` | `D3F_E068` | 71 | 0 | 2 (2/0/0) | Data | `lda #$00 ; EB73 A9 00 step done: zeros window, advances step; D3F_E068,y (SAME y) reads NEXT byte — $0 falls already` |
| 5 | `3F:E055` | `D3F_E055` | 6 | 0 | 1 (1/0/0) | Data | `lda D3F_E055,y ; EE8C B9 55 E0 [idx $00..$05]` |
| 6 | `00:8E82` | `D00_8E82` | 9 | 0 | 7 (4/3/0) | Data | `lda #<D00_8E82 ; 8FC8 A9 82 RyuAiProjScriptMid — Ryu AI: projectile at 32-64 px -> script $00:8E82` |
| 7 | `00:8EA6` | `D00_8EA6` | 7 | 0 | 5 (2/3/0) | Data | `lda #<D00_8EA6 ; 90BC A9 A6` |
| 8 | `00:8F03` | `D00_8F03` | 7 | 0 | 4 (4/0/0) | Data | `lda #<D00_8F03 ; 8FBB A9 03` |
| 9 | `00:8F1B` | `D00_8F1B` | 9 | 0 | 4 (2/2/0) | Data | `lda #<D00_8F1B ; 905C A9 1B RyuAiOpponentScript — Ryu AI: opponent near -> script $00:8F1B` |
| 10 | `00:8F24` | `D00_8F24` | 2 | 0 | 4 (4/0/0) | Data | `lda #<D00_8F24 ; 8FB1 A9 24` |
| 11 | `3B:E57D` | `D3B_E57D` | 24 | 0 | 2 (2/0/0) | PointerTable | `lda D3B_E57D,y ; F2C6 B9 7D E5 [idx $00..$06]` |
| 12 | `3B:E595` | `D3B_E595` | 8 | 0 | 2 (2/0/0) | PointerTable | `lda D3B_E595,y ; F2A8 B9 95 E5 [idx $00..$06]` |
| 13 | `3B:E808` | `D3B_E808` | 1 | 0 | 2 (2/0/0) | Data | `lda D3B_E808,x ; E6A0 BD 08 E8 (nt)` |
| 14 | `3B:E809` | `D3B_E809` | 1 | 0 | 2 (2/0/0) | Data | `lda D3B_E809,x ; E6A6 BD 09 E8 (nt)` |
| 15 | `3B:E80A` | `D3B_E80A` | 1 | 0 | 2 (2/0/0) | Data | `lda D3B_E80A,x ; E6AC BD 0A E8 (nt)` |
| 16 | `3C:81D6` | `D3C_81D6` | 96 | 24 | 4 (4/0/0) | Data | `lda #<D3C_81D6 ; EE48 A9 D6` |
| 17 | `3C:824E` | `D3C_824E` | 96 | 24 | 4 (4/0/0) | Data | `lda #<D3C_824E ; EE50 A9 4E` |
| 18 | `3C:82C6` | `D3C_82C6` | 24 | 96 | 4 (4/0/0) | Data | `lda #<D3C_82C6 ; EE5B A9 C6 PortraitP1LoseSet — P1 portrait: P1 lost -> defeat layout` |
| 19 | `3C:833E` | `D3C_833E` | 24 | 96 | 4 (4/0/0) | Data | `lda #<D3C_833E ; EE63 A9 3E` |
| 20 | `3C:83B6` | `D3C_83B6` | 24 | 96 | 4 (4/0/0) | Data | `lda #<D3C_83B6 ; E158 A9 B6` |
| 21 | `36:C03C` | `D36_C03C` | 10 | 0 | 2 (2/0/0) | PointerTable | `lda D36_C03C,y ; E2C9 B9 3C C0 [banks $36 idx $00..$00]` |
| 22 | `36:C046` | `D36_C046` | 10 | 0 | 2 (2/0/0) | PointerTable | `lda D36_C046,y ; E2F4 B9 46 C0 [banks $36 idx $00..$00]` |
| 23 | `36:C050` | `D36_C050` | 10 | 0 | 2 (2/0/0) | PointerTable | `lda D36_C050,y ; E2D4 B9 50 C0 [banks $36 idx $00..$00]` |
| 24 | `36:C05A` | `D36_C05A` | 10 | 0 | 2 (2/0/0) | PointerTable | `lda D36_C05A,y ; E2FF B9 5A C0 [banks $36 idx $00..$00]` |
| 25 | `36:C064` | `D36_C064` | 10 | 0 | 2 (2/0/0) | PointerTable | `lda D36_C064,y ; E2DF B9 64 C0 [banks $36 idx $00..$00]` |
| 26 | `20:8469` | `D20_8469` | 13 | 0 | 2 (2/0/0) | Data | `lda #<D20_8469 ; F78C A9 69` |
| 27 | `20:8476` | `D20_8476` | 21 | 0 | 2 (2/0/0) | Data | `lda #<D20_8476 ; F001 A9 76` |
| 28 | `20:848B` | `D20_848B` | 22 | 0 | 2 (2/0/0) | Data | `lda #<D20_848B ; F8A2 A9 8B RoundEnd_DrawTieAlt — tie with clock in air: sprite variant ($20:848B) (nt)` |
| 29 | `20:84A1` | `D20_84A1` | 11 | 0 | 2 (2/0/0) | Data | `lda #<D20_84A1 ; F88F A9 A1` |
| 30 | `20:852B` | `D20_852B` | 15 | 0 | 2 (2/0/0) | Data | `lda #<D20_852B ; F858 A9 2B RoundEnd_DrawPerfect — draws "PERFECT" sprite ($20:852B)` |
| 31 | `29:A000` | `D29_A000` | 19 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D29_A000 ; F4F3 A9 00` |
| 32 | `29:AAB6` | `D29_AAB6` | 19 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D29_AAB6 ; EF97 A9 B6` |
| 33 | `29:B34A` | `D29_B34A` | 19 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D29_B34A ; EB97 A9 4A` |
| 34 | `29:B4BD` | `D29_B4BD` | 19 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D29_B4BD ; EC5F A9 BD` |
| 35 | `2D:A000` | `D2D_A000` | 19 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D2D_A000 ; F574 A9 00` |
| 36 | `37:F293` | `D37_F293` | 8 | 0 | 4 (4/0/0) | FamiTone2 | `lda D37_F293,x ; F049 BD 93 F2 [idx $00..$07]` |
| 37 | `37:E199` | `D37_E199` | 6 | 0 | 2 (2/0/0) | FamiTone2 | `ldx zp_DC ; E40B A6 DC sound effect by state class: channel in D37_E199[x], sfx in SfxChannelOfs[state]` |
| 38 | `37:E8AD` | `D37_E8AD` | 4 | 0 | 2 (2/0/0) | FamiTone2 | `lda D37_E8AD,x ; E72E BD AD E8 [idx $00..$00]` |
| 39 | `37:EE74` | `D37_EE74` | 3 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D37_EE74 ; E4FF A9 74 _FT2MusicStopEnvelopes — FamiTone2: points all envelopes to mute envelope` |
| 40 | `37:F29B` | `D37_F29B` | 8 | 0 | 2 (2/0/0) | FamiTone2 | `lda D37_F29B,x ; F035 BD 9B F2 [idx $00..$07]` |

## 4. Suggested next step

1. Batches already applied: **Engine/fighting core (`$3F`, 15)**, **Sheets/selection/VS (`$3C`, 33)**, and **HUD/effects (`$20`, 30)** — see `tasks/DATA_NAMING_3F.md`, `tasks/DATA_NAMING_3C.md`, and `tasks/DATA_NAMING_20.md`.
2. Next candidates from section 2 by evidence/effort ratio: **RLE screens + tables (`$36`, 30)** and **Fight/HUD/VS/video utilities (`$3B`, 35)**.
3. Read consumer flow and propose names with evidence/confidence/risk in the format of `tasks/NAMING_CANDIDATES.md`.
4. Apply only after explicit authorization; validate with `make gen`, `make` and identical SHA-1.

> Applied batches did not change bytes. Canonical ROM: `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`.
