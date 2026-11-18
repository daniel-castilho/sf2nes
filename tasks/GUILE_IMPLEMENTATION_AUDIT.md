# Guile implementation — Phase 1 static audit and data map

**Status:** documentation only. This file records static evidence; it does not authorize code, asset, tool, build, generator, ROM, test, or emulator work.  
**Prepared:** 2026-11-18.  
**Plan:** `tasks/GUILE_IMPLEMENTATION_PLAN.md`, Phase 1.  
**Evidence base:** generated `src/bank_*.s`, `src/kernel.inc`, `src/ram.inc`, `annotations/sf2ne.ann`, `docs/FORMATS.md`, `docs/ARCHITECTURE.md`, and read-only byte measurements of `rom/sf2ne_demo.nes`. No `make`, `make gen`, script, test, or emulator was run.  
**Gates still open:** D-05 (all builds/generation/tests/emulator runs), P8 (asset provenance, conversion, and numeric values; the pose list is approved), P9 + P11 (aerial throws). D-04, P10, the Phase 2 bank allocation, and Q7 pose/move coverage are resolved/approved; see `tasks/GUILE_BANK_ALLOCATION.md` §7 and the specification §5.1.

---

## 1. Character fiche, column 3 (Guile)

`FighterLoadChar` (`3B:E000`) reads 23 tables of 10 bytes in bank `$3C`. Ten are low/high pointer pairs (20 tables); three are standalone bank selectors. Column order is `0 RYU, 1 KEN, 2 CHUN LI, 3 GUILE, …`. All byte values below were read from `rom/sf2ne_demo.nes` and match the generated source.

| # | Pointer pair (labels) | Guile low byte | Guile high byte | Effective pointer (indexed) | Intended target / where it lives | Current state |
|---|---|---|---|---|---|---|
| 0 | `CharDirTransLoTbl` `3C:8000` / `CharDirTransHiTbl` `3C:800A` | `3C:8003 = $00` | `3C:800D = $00` | `$0000` (but see §2) | Guile states by direction, in his state bank at `$A000` | Absent; engine actually sees Ryu's table (§2) |
| 1 | `CharAttackTransLoTbl` `3C:8014` / `CharAttackTransHiTbl` `3C:801E` | `3C:8017 = $00` | `3C:8021 = $00` | `$0000` | Guile states by button, state bank | Absent |
| 2 | `CharSpecialTransLoTbl` `3C:8028` / `CharSpecialTransHiTbl` `3C:8032` | `3C:802B = $00` | `3C:8035 = $00` | `$0000` | Guile special-move transition table, state bank | Absent |
| 3 | `CharGuardReactLoTbl` `3C:803C` / `CharGuardReactHiTbl` `3C:8046` | `3C:803F = $00` | `3C:8049 = $00` | `$0000` | Guard reactions (12 words), state bank | Absent |
| 4 | `CharHitReact1LoTbl` `3C:8050` / `CharHitReact1HiTbl` `3C:805A` | `3C:8053 = $00` | `3C:805D = $00` | `$0000` | Standing damage reactions (12 words), state bank | Absent |
| 5 | `CharHitReact2LoTbl` `3C:8064` / `CharHitReact2HiTbl` `3C:806E` | `3C:8067 = $00` | `3C:8071 = $00` | `$0000` | Crouching damage reactions (12 words), state bank | Absent |
| 6 | `CharHitReact0LoTbl` `3C:8078` / `CharHitReact0HiTbl` `3C:8082` | `3C:807B = $00` | `3C:8085 = $00` | `$0000` | Neutral/airborne damage reactions (12 words), state bank | Absent |
| 7 | `CharHitReact12LoTbl` `3C:808C` / `CharHitReact12HiTbl` `3C:8096` | `3C:808F = $00` | `3C:8099 = $00` | `$0000` | Throw reactions (12 words), state bank | Absent |
| 8 | `CharCmdListLoTbl` `3C:80A0` / `CharCmdListHiTbl` `3C:80AA` | `3C:80A3 = $00` | `3C:80AD = $00` | `$0000` | Special recognizer key list, code bank `$3F` | Absent |
| 9 | `CharAiScriptLoTbl` `3C:80B4` / `CharAiScriptHiTbl` `3C:80BE` | `3C:80B7 = $00` | `3C:80C1 = $00` | `$0000` | AI script pointer table, frame bank | Absent (intentional for a non-CPU-only character, but see §9) |

Standalone selectors, Guile column:

| Selector | Address, offset +3 | Value | Meaning |
|---|---|---|---|
| `CharStateBankTbl` | `3C:80CB` | `$01` | States currently resolve to Ryu's bank |
| `CharFrameBankTbl` | `3C:80D5` | `$0C` | Frames currently resolve to Guile's portrait PRG bank |
| `CharHitBoxBankTbl` | `3C:80DF` | `$00` | Collision boxes currently resolve to Ryu's frame bank |

**Result:** no Guile-owned gameplay pointer exists today. The only non-null effective value is the direction pointer quirk in §2. Every pointer-to-be needs a label in the chosen state/frame/code bank before Phase 3 can write data.

## 2. Direction-pointer quirk (`3B:E025`)

`FighterLoadChar` loads the low byte of every pointer pair **with** `,y`, but loads the high byte of pair 0 **without** index:

```
3B:E01F  lda CharDirTransLoTbl,y   ; selected character
3B:E025  lda CharDirTransHiTbl     ; always entry 0 = $A0
```

Consequences for Guile:

* `CharDirTransLoTbl[3] = $00` and `CharDirTransHiTbl[3] = $00` would nominally give `$0000`.
* The engine uses `CharDirTransHiTbl[0] = $A0`, so the effective pointer is **`$A000`** in whichever state bank `FighterStateBank` selects (currently `$01`). That is `RyuDirTransTbl` (`01:A000`).
* Therefore setting Guile's direction low byte is sufficient **only if** his direction table is placed at `$A000` of his own state bank and `CharStateBankTbl[3]` is changed to that bank. `CharDirTransHiTbl[3]` may remain `$00`; it is not read for this pair. All other pairs are indexed normally and need both halves.

`FighterRoundInit` (`3B:E0AC`–`E0D7`) maps `FighterStateBank` at `$A000`, dereferences the direction pointer, takes word 0 and derives `FighterFramePtr = StatePtr + $07`, then seeds `FighterState = $59`. Guile's first state therefore must be the neutral entry of his direction table, with its first frame immediately after the 7-byte state header (`docs/FORMATS.md` §2–§3).

## 3. State bank options ($A000 window)

MMC5 PRG mode 3 is four 8 KB banks (`3F:F7A2`); a bank appears in window `$8000 + (bank & 3) × $2000`. `$A000` requires a bank whose low two bits are `01`.

Measured from `rom/sf2ne_demo.nes` (all values are full 8 KB banks):

| Bank | Used bytes | Free bytes | Note |
|---|---:|---:|---|
| `$01` | 4505 | 3687 | Ryu states; in use |
| `$05` | 0 | 8192 | **Ken's hand-written state bank — excluded, must not be reused** |
| `$29` | 5352 | 2840 | Music; in use |
| `$2D` | 4698 | 3494 | Music; in use |
| `$09 $0D $11 $15 $19 $1D $21 $25 $31 $35 $39 $3D` | 0 | 8192 each | Fully `$FF` in the reference ROM |

Unreferenced check: none of the 10 fiche columns selects any of the `$FF` banks, and `annotations/sf2ne.ann` contains no `label`, `data`, `table`, or `statebank` directive with any of those bank prefixes. They are unallocated in the reference image and in the annotation source. `$05` is excluded because it is reserved by `keepbank 05` (`annotations/sf2ne.ann:2166`) for Ken.

**Open question Q1:** which candidate bank the Maintainer approves (Phase 2 gate). No allocation is made by this audit.

## 4. Frame bank options ($8000 window)

| Option | Addresses / bytes | Trade-off |
|---|---|---|
| Reuse `$0C` | `CharFrameBankTbl[3]` stays `$0C`; `D0C_8000` occupies `0C:8000–8037`, leaving **8136 free bytes** | No fiche byte change; Guile's fighting frames share a PRG bank with his portrait metasprite record; portrait CHR page `$0C` is independent of PRG bank choice |
| Fresh bank, low two bits `00` | Empty candidates: `$14 $18 $28 $2C $30 $34 $38` (8192 free bytes each); change `CharFrameBankTbl[3]` (`3C:80D5`) from `$0C` to the chosen bank | Byte-change in fiche required; keeps fighting frames and portrait data separate; leaves `D0C_8000` untouched |

Size estimate: Ryu's frame/collision bank `$00` uses 5193 bytes and Ken's `$04` uses 4303 bytes, including metasprites, collision records and AI scripts. Guile's pose set is not yet fixed (it depends on P8 and the required state set), so a 4–6 KB working estimate is reasonable but **not an approved budget**. Both options have enough room for a comparable set; `$0C` also has room but couples the two data sets in one bank.

## 5. Hitbox bank option

`CharHitBoxBankTbl` is read at `3B:E019` into `zp_1C,x`; `LoadHitBoxesBoth` (`3F:EBA3`) uses it to map the collision bank at `$8000` and reads frame record bytes `+3/+4` (body boxes and attack box; `docs/FORMATS.md` §10).

* Ken's precedent: `CharFrameBankTbl[1] = $04` and `CharHitBoxBankTbl[1] = $04` — frame and collision data share one PRG bank.
* Guile today: frame `$0C`, hitbox `$00` (Ryu). After choosing a frame bank, the simplest option is to set `CharHitBoxBankTbl[3]` (`3C:80DF`) to the same value as the frame bank and store collision records there. A dedicated collision bank is possible but consumes another full 8 KB bank without a demonstrated need.

**Open question Q2:** share frame bank (recommended by precedent) or dedicate a bank. P8 blocks producing the actual boxes either way.

## 6. CHR inventory and the sprite-page rule

Measured CHR-ROM: 256 pages of 2 KB; 198 pages are fully `$FF`. Used pages are `$00`–`$38` and `$FF`; free pages are `$39`–`$FE`. Page `$0C` is Guile's portrait page: `D0C_8000` starts with `$0C`, and `DrawFighter` (`3B:EE20`) copies that byte into `FighterChrPage,x`.

Observed coupling (all addresses verified):

1. `Main` sets MMC5 CHR mode 2 = 2 KB pages (`3F:F7A7`).
2. `DrawFighter` (`3B:EDD9`) puts `$00` in `zp_E4` for fighter 0 and `$80` for fighter 1 (`3B:EDDE`); `DrawMetaspriteWriteOAM` adds `zp_E4` to every tile byte (`3B:F347`).
3. NMI writes `FighterChrPage` → `MMC5_CHR_SPR1` (`$5121`) and `FighterChrPage+1` → `MMC5_CHR_SPR3` (`$5123`) (`kernel.inc:272–275`).
4. `PortraitBuildP2` (`3B:EF96–EFA2`) writes the first byte of `D0C_8000` into `FighterChrPage+1`, so the portrait page is also part of the pair used during VS/quote screens.
5. `DrawProjectileMetasprite` (`3B:F2D0–F2D4`) bypasses `FighterChrPage` and writes the record's first byte directly to `MMC5_CHR_SPR5` (`$5125`).

8×16 sprite tile indices carry a pattern-table bit, and the `+$80` offset selects the opposite half of the page for P2. The exact split between `$5121` and `$5123` for a given fighter and the question of both fighters needing a matched page pair in one match are **not fully resolved statically**.

**Open question Q3:** confirm with authorized validation (D-05) whether a fighter's art must occupy a paired page set and how P1/P2 share `$5121`/`$5123`. Until then, reserve two free pages (e.g. from `$39` upward) for Guile's fighting art rather than assuming one page is enough.

## 7. Palettes

`PortraitLoadPalettes` (`3B:E181–E1F5`) indexes six tables in bank `$3C` with `FighterChar × 12` and then `zp_12 × 3`, i.e. **10 records of 12 bytes per table**, four 3-colour palettes per fighter. Guile is column 3, record offset 36 (`$24`):

| Table | Base | Guile record | Bytes in reference ROM |
|---|---|---|---|
| `CharPal0FightTbl` | `3C:80E6` | `3C:810A` | all `$FF` |
| `CharPal1FightTbl` | `3C:815E` | `3C:8182` | all `$FF` |
| `CharPal0WinTbl` | `3C:81D6` | `3C:81FA` | `26 19 37 / 26 17 37 / 26 01 37 / 26 11 37` |
| `CharPal1WinTbl` | `3C:824E` | `3C:8272` | `26 27 37` repeated four times |
| `CharPal0LoseTbl` | `3C:82C6` | `3C:82EA` | all `$FF` |
| `CharPal1LoseTbl` | `3C:833E` | `3C:8362` | all `$FF` |
| `CharPal2Tbl` | `3C:83B6` | `3C:83DA` | all `$FF` |

The two Win entries are non-`$FF`, but they are not proof of Guile-specific palette art; they may be shared decorative colours. Fight/lose/P2 records are empty. P8 gates all palette work.

## 8. Voice slots

`CountryVoiceTbl` (`37:E0EF`, 10 bytes) has `CountryVoiceTbl[3] = $0C` at `37:E0F2` — the selection-screen country voice exists.

`FighterVoiceTbl` is stored as 16-byte records beginning at `37:E0F9`. Guile's record is `37:E129`–`E138`: all `$FF`. The parallel continuation table `FighterVoiceContTbl` begins at `37:E0FA`, one byte later, so Guile's record is `37:E12A`–`E139`: all `$FF`. The next record (`37:E13A`–`E149`, Blanka) ends with `$18` at `E149`. Fighter voice state routines read this table at `37:E447`. Guile therefore has country voice but no fighting voice.

## 9. Selection, VS, quote, and CPU routing

| Stage | Label / address | Guile-relevant fact |
|---|---|---|
| Cursor → fighter | `SelectCursorFighterTbl` `37:F293` = `00 04 03 07 01 02 09 08` | Cursor 2 maps to fighter ID 3 (Guile) |
| Confirm gate | `37:F06B`: `cmp #$02 ; bcc SelectConfirmVoice` | Only IDs 0–1 can be confirmed; ID 3 is rejected and `zp_D7` set to `$FF`. This gate must change for Guile to be selectable |
| Fighter write | `37:F069`: `sta FighterChar` (with `DEST_FLAG_BLINK`, `jsr DestFlagOam` at `F066` returns the same index in A) | Selection still writes ID 3 into `FighterChar` |
| Country voice | `37:F147` reads `CountryVoiceTbl,x` | Guile's `$0C` entry is present |
| VS load | `ScreenVersus` → `FighterLoadChar` (`3B:E000`, called at `3B:EA7D`/`EA84`) | Fiche column 3 is loaded as described in §1–§2 |
| CPU assignment | `3F:F864`–`F86A` | P1 = human (`FighterIsCpu=0`), P2 = CPU (`FighterIsCpu+1=1`); `MODE_VERSUS` alt changes this |
| AI script init | `3B:F63A`/`F643` → `AiScriptInit` (`3B:F24A`) | Only CPU fighters start the AI script; it reads `ram_0342/0344` (fiche pair 9) in the **frame bank** |
| CPU per-frame | `3F:EFC1` → `AiUpdate` (`3F:E7D2`) | CPU fighters bypass `InputUpdate` and write `InputDir`/`InputAttack`/`CmdMoveIdx` directly from script opcodes |
| Character thinker | `AiCallCharRoutine` (`3F:E7A4`), `AiCharRoutine` (`3F:E6E6`) | Table has **one** entry (`RyuAiThink`); Guile's slot would read code bytes, so a Guile thinker or a shared stub is required if he is CPU |
| Win quote / portraits | `CharNameTbl` `3C:84CE`, `CharNameLenTbl` `3C:851E`, `WinQuoteLine1/2` `3C:8528`/`8604`, `PortraitWinLayoutTbl` `3C:84A6`, `PortraitLoseLayoutTbl` `3C:84BA` | Name `GUILE` and quote slot 3 already exist; `PortraitWinLayoutTbl+6` (`3C:84AC`) → `D0C_8000`, the Guile portrait record |

**Open question Q4:** whether Guile must be usable as CPU (a thinker/stub) or only as a playable fighter. The current flow always makes P2 CPU.

## 10. Command recognizer and P10

Key/address facts:

* `CmdMotionTbl` `3F:E067` (19 keys × 4 bytes; byte `$12` overlaps `CmdKeyAttackTbl`), `CmdMotionTblNext` = `CmdMotionTbl+1`, read at `3F:EB79`.
* `CmdKeyAttackTbl` `3F:E0AF` (17 bytes, keys `$00`–`$10`), read at `3F:EAE6`, `EAFD`, `EB8D`.
* Dispatchers `CmdStepLo`/`CmdStepHi` `3F:EA76`/`EA89`: keys `$00`–`$07` and `$10` motion; `$08`–`$0D` charge (`CmdStepCharge`, `3F:EA9C`); `$0E`/`$0F` mash; `$11` A+B; `$12` empty.
* `CmdKeyListRyu` `3F:E0C0` (7 bytes) is the only list referenced by a fiche (`3C:80A0/80AA` → `ram_033E/0340`).
* The second list at `3F:E0C7` is `0A 0B 08 09 0C 0D FF`, a charge-only list with **no fiche pointer today**.
* `InputCommands` (`3F:EA24`) walks the list; `CmdMoveIdx[fighter]` is the list position; `InputDispatch` (`3F:F6DF`–`F6F6`) indexes `ram_0326` (fiche pair 2) by `CmdMoveIdx × 2`. Max 6 specials because `CmdMotionStep`/`CmdMotionWin` are interleaved arrays of 12 bytes each (`3F:EA76` notes, `ram.inc:141–164`).
* Charge timing: hold `≥ $3C` (60) frames, release direction in 8-frame window, button in same window (`3F:EAA8`–`EAF8`). This is the static parser contract, not a measurement of the arcade revision (P5 remains open).

Measured key definitions relevant to P10:

| Key | Motion bytes | Required button (`CmdKeyAttackTbl`) | Meaning |
|---|---|---|---|
| `$08` | `02 01 00 00` | `$00` | charge back → forward, LP |
| `$09` | `02 01 00 00` | `$01` | charge back → forward, HP |
| `$0A` | `02 01 00 00` | `$02` | charge back → forward, LK |
| `$0B` | `02 01 00 00` | `$03` | charge back → forward, HK |
| `$0C` | `04 08 00 00` | `$00` | charge down → up, LP |
| `$0D` | `04 08 00 00` | `$01` | charge down → up, HP |

**P10 conflict found by the audit:** approved P10 requires Sonic Boom = LP/HP (keys `$08`/`$09` already match) and Flash Kick = LK/HK (needs charge down→up with buttons `$02`/`$03`). The dormant list at `3F:E0C7` uses keys `$0C`/`$0D`, which are down→up with **punch**, not kick. Implementing P10 therefore requires one of:

1. Change `CmdKeyAttackTbl[0C]`/`[0D]` (`3F:E0BB`/`E0BC`) from `$00/$01` to `$02/$03` — a global-table remap;
2. Add new charge keys in free space of bank `$3F` and extend/rehome `CmdMotionTbl` + `CmdKeyAttackTbl` (their current adjacency at `E067`–`E0BF` leaves no room in place); or
3. Add a per-character attack table and patch the button comparison in `CmdChargeButton` (`3F:EAE6`) and `CmdMotionButton` (`3F:EB8D`).

Consumer audit for option 1: in the reference ROM, only the dormant `3F:E0C7` list references keys `$0C`/`$0D`; Ryu's active list (`3F:E0C0`) uses only `$02 $03 $04 $05 $06 $07`, and Ken reuses Ryu's list. No other code path reads those two table bytes. The change is therefore semantically contained **in the current image**, but it is still a global edit and must not be made until the implementation gate is authorized. P9/P11 are unaffected.

## 11. Projectile parameterization

Facts and exact labels:

* Spawn: `ProjLaunch` `3F:E837`; speed from `A` (`$00`/`$01`), spawn ΔX `ProjSpawnXOffsetTbl` `3F:E064`, Y `ProjSpawnYOffsetTbl` `3F:E05B`, step `ProjSpeedStepTbl` `3F:E05E`.
* Update/clash: `ProjUpdate` `3F:E854`, `ProjClash` `3F:E8BB` (|ΔX| < `$18`, bit 7 of `ProjFlags`, 16 steps).
* Hit: `ProjHitTest` `3F:E8F1`; `ProjHit` `3F:E941` hardcodes `HitReactClass = $CB` (`3F:E94E`) and damage parameter `$6C` (`3F:E953`) before `HitDamageApply`.
* Drawing: `DrawProjectile` `3B:F27F`, tables `D3B_E57D` (`3B:E57D`, normal) and `D3B_E595` (`3B:E595`, clash); metasprite byte 0 goes directly to `$5125` (`3B:F2D4`). Bank `$20` is hardwired at `3B:F293`–`F297`.

Guile's Sonic Boom must use the same two-slot projectile engine. Because `ProjHit` is shared, per-character damage/reaction requires either parameterization of `ProjHit` or a Guile-specific duplicate; drawing requires either new frames in bank `$20` (which also holds HUD/effects) or a parameterizable draw bank. Both are code work in bank `$3F`/`$3B`, whose measured free space is 867 and 133 bytes respectively.

**Open question Q5:** whether to parameterize the shared projectile path or add a parallel path, given the small free space in `$3F` and `$3B`. This feeds Phase 2/3 sizing.

## 12. Throws and conditions

* Condition dispatcher `StateCondDispatch` `3F:E168` with `StateCondLo`/`Hi` `3F:E171`/`E17D`: exactly **12 slots** (`$00`–`$0B`). `CondCanGrab` is slot 9, address `3F:E22E`.
* `CondCanGrab` requires |ΔX| < `$18`, both fighters at `FloorY`, `InputDir` = `$05`/`$06` (forward/back), and opponent class outside `$30`–`$4F` and `$A0`–`$A8`. Ground-only; no aerial branch.
* `GrabCheck` `3F:F033` only acts when a fighter's state class is `$A0`–`$A8`, the state pointer has advanced +7 to the current frame, and the victim's `HitReactClass & $1F` is `$0C`; otherwise it re-tests the other fighter.
* Throw damage reaction: `HitDamageReact` `3F:EE4E` uses `ram_033A/033C` (fiche pair 7), index `(damage >> 5) + thrower_char × 4` (`3F:EE5F`–`EE74`); thrower is `FighterChar` of the *other* fighter.
* Escape: `MoveGrabEscape` `3F:F648` calls `HitFreeze`, clears `HitReactClass`, plays SFX.
* No new condition slot is available without replacing an existing one. P9 (exact aerial directions/buttons) and P11 (approval traceability) remain open, so no aerial-throw implementation step is defined here.

---

## 13. Open questions to resolve before implementation

| # | Question | Blocking gate |
|---|---|---|
| Q1 | Which `$A000`-window bank is allocated for Guile states? | Bank approval |
| Q2 | Frame bank: reuse `$0C` or a fresh `$8000`-window bank; hitbox bank shared or dedicated? | Bank approval / P8 |
| Q3 | Exact CHR page pairing and P1/P2 page-sharing rule; how many free pages to reserve? | D-05 for confirmation |
| Q4 | Must Guile work as CPU (thinker/stub), or only as P1? | Maintainer scope |
| Q5 | Parameterize shared projectile draw/hit code, or duplicate it? | Bank approval / sizing |
| Q6 | Which of the three P10 mechanisms (§10) is accepted for Flash Kick buttons? | P10 is approved; mechanism needs implementation authorization |
| Q7 | Which normals/pose set is required before asset work can be sized? | P8 |

P8, P9, P11, D-05 and bank allocation are **not** resolved by this audit. D-04 and P10 remain resolved/approved as recorded in `tasks/STABILIZATION_BACKLOG.md` and `docs/PROJECT_STATUS.md` §13.

## 14. Step → label/address index

| Future implementation step | Labels / addresses from this audit |
|---|---|
| Make Guile selectable | `SelectCursorFighterTbl` `37:F293`; confirm gate `37:F06B`; `FighterChar` `37:F069` |
| Load Guile's fiche | `FighterLoadChar` `3B:E000`; fiche `3C:8000`–`80DF` (§1) |
| Give Guile his own states | `CharStateBankTbl[3]` `3C:80CB`; pairs 0–7 `3C:8003`–`8099`; bank candidates §3 |
| Give Guile frames / boxes | `CharFrameBankTbl[3]` `3C:80D5`; `CharHitBoxBankTbl[3]` `3C:80DF`; `D0C_8000` `0C:8000`; `DrawFighter` `3B:EDD9`; `LoadHitBoxesBoth` `3F:EBA3` |
| Give Guile CHR pages | `FighterChrPage` `ram $40`; NMI `kernel.inc:272–275`; `DrawMetasprite` `3B:F2EA` |
| Give Guile palettes | `PortraitLoadPalettes` `3B:E181`; seven tables §7 |
| Give Guile voices | `CountryVoiceTbl` `37:E0EF` (present); `FighterVoiceTbl` `37:E129`; `FighterVoiceContTbl` `37:E12A` |
| Give Guile specials | `CharCmdList[3]` `3C:80A3/80AD`; `CharSpecialTrans[3]` `3C:802B/8035`; `CmdKeyListRyu` `3F:E0C0` model; `3F:E0C7` dormant list; `CmdMotionTbl` `3F:E067`; `CmdKeyAttackTbl` `3F:E0AF`; `InputDispatch` `3F:F6DF` |
| Give Guile a projectile | `ProjLaunch` `3F:E837`; `ProjHit` `3F:E941` (`$CB`/`$6C`); `D3B_E57D` `3B:E57D`; `D3B_E595` `3B:E595` |
| Give Guile throws | `CondCanGrab` `3F:E22E`; `GrabCheck` `3F:F033`; fiche pair 7 `3C:808F/8099`; reaction class `$0C`; P9/P11 gate |
| CPU behaviour | `AiScriptInit` `3B:F24A`; fiche pair 9 `3C:80B7/80C1`; `AiUpdate` `3F:E7D2`; `AiCharRoutine` `3F:E6E6`; Q4 |

**Exit criterion:** every implementation step above has a label and an address, and every unknown is an explicit question. Phase 2 (bank allocation proposal) may now be prepared; it remains gated by Maintainer approval.
