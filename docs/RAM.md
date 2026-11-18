# RAM map (what is known so far)

The full list of used addresses, with read/write counts, is in `src/ram.inc` (generated) and, with **which instructions** touch each address, in `trace/ram.txt`. Here only identified variables are listed.

**Counts (CONFIRMED — STATIC, Phase 4):** `src/ram.inc` declares 484 symbols, 41 of them automatic `zp_*` placeholders. The earlier README figure “78 named variables” has no documented method and is **not revalidated**; this map lists identified variables only. See `docs/PROJECT_STATUS.md` §7 (IN-02).

How they were found: RAM dump every frame during full matches (`SF2_RAMDUMP=1`), cross-referenced with screenshots, plus reading code that uses them. To confirm a hypothesis, force the value in the emulator (`SF2_HOLD="address:value:from:to"`) and see what changes.

## Fighters — 2-position vectors (`,x` with X = 0 for P1, 1 for P2)

| Address | Name | Meaning |
|---------|------|---------|
| `$00` | `FighterChar` | character (0 = Ryu; `$FF` = none) |
| `$02` | `FighterIsCpu` | 0 = human, 1 = CPU. `MainLoop` fixes P1 = 0, P2 = 1 |
| `$04` | `FighterFlip` | `$40` = mirrored (facing left) |
| `$06` / `$08` | `FighterXSub` / `FighterX` | X position (fraction / pixel). Round start: `$5A` and `$A6` |
| `$0A` / `$0C` | `FighterYSub` / `FighterY` | Y position. Ground = `$CD` |
| `$0E` | `FighterHP` | energy. Full = `$58` (88); negative = knocked out |
| `$10` | `FighterWins` | rounds won |
| `$14` | `FighterDmgPending` | damage not yet deducted (bar goes down gradually) |
| `$18` | `FighterFrameBank` | frame bank (window `$8000`) |
| `$1A` | `FighterStateBank` | state bank (window `$A000`) |
| `$1E` / `$20` | `FighterStatePtrLo/Hi` | current state (header in state bank) |
| `$22` / `$24` | `FighterNextPtrLo/Hi` | next state chosen by `StateCheckTransitions` |
| `$26` | `FighterState` | state byte: 5 high bits = class, 3 low bits = flags |
| `$2A` / `$2C` | `FighterFramePtrLo/Hi` | current animation frame |
| `$30` / `$32` | `FighterVelXSub` / `FighterVelX` | X velocity (signed) |
| `$34` / `$36` | `FighterVelYSub` / `FighterVelY` | Y velocity |
| `$40` | `FighterChrPage` | CHR page of fighter sprites (goes to `$5121` / `$5123`) |
| `$42` | `FighterAnimTimer` | frames remaining in current animation frame |
| `$69` / `$6B` | `AiScriptPtrLo/Hi` | AI script being executed |

Still unnamed, but clearly per fighter (pairs): `$12`, `$16`, `$1C`, `$28`, `$2E`, `$38`, `$3A`–`$3F`, `$44`–`$63`, `$6D`–`$A9` (includes command recognizer state: `CmdMotionStep` `$90`–`$9B` and `CmdMotionWin` `$9E`–`$A9`, 6 entries × 2 fighters interleaved — §13 of `docs/FORMATS.md`), and `$0300`–`$0345` (fiche loaded from bank `$3C`).

## System

| Address | Name | Meaning |
|---------|------|---------|
| `$64` / `$65` | `CurFighter` / `OtherFighter` | indexes of fighter being processed and opponent |
| `$66`–`$68` | `RngState` | pseudo-random generator (`RandomSeed` sets `"2FS"`) |
| `$AC` | `VBlankFlag` | NMI sets 1; screen loops wait for it |
| `$AD` | `OamIndex` | next free OAM byte this frame |
| `$B0` | `ScreenMode` | 0 warning, 1 title, 2 selection, 3 VS, 4 round intro, 5 fight, 6 end of round, 7 quote |
| `$B1` | `FrameCounter` | incremented in NMI |
| `$B4` | `AiLevel` | AI level (0–7). `MainLoop` fixes 7 |
| `$B5` | `TimerOff` | ≠ 0 disables clock (**hypothesis**; always 0 in demo) |
| `$B6` / `$B7` | `RoundStep` / `RoundStepTimer` | step and counter of intro and end-of-round sequences |
| `$B8` | `RoundNumber` | 0 = first round |
| `$B9` | `RoundResult` | `$FF` in progress, 0 = P1 won, 1 = P2 won, 2 = draw |
| `$BA` / `$BB` | `TimerOnes` / `TimerTens` | clock digits |
| `$BC`–`$D3` | `PaletteBuf` | 24 colors (8 palettes × 3) |
| `$D4` | `PaletteDirty` | ≠ 0: NMI sends palette |
| `$D5`–`$E4` | — | general-purpose temporaries (pointers, coordinates, arguments) |
| `$ED` / `$EE` | `PpuCtrlShadow` / `PpuMaskShadow` | copies of `$2000` / `$2001` |
| `$EF` / `$F0` | `ScrollX` / `ScrollY` | scrolling |
| `$F2` | `JoyState` (×2) | buttons pressed now |
| `$F6` | `JoyPrev` (×2) | buttons from previous frame |
| `$FA`–`$FD` | `RlePtr`, `RleTag`, `RleLast` | RLE decompressor |

Controller bits: A `$80`, B `$40`, Select `$20`, Start `$10`, Up `$08`, Down `$04`, Left `$02`, Right `$01`.

## Pages `$01`–`$07`

| Range | Use |
|-------|-----|
| `$0100`–`$018B` | FamiTone2 variables (`FT_BASE_ADR = $0100`); stack uses page top |
| `$0200`–`$02FF` | `OamBuf` — OAM copy |
| `$0300`–`$0345` | fighter fiche (basic state pointers), P1/P2 pairs |
| `$034E`–`$0389` | portrait buffer |
| `$0392`–`$03AD` | HUD texts written by menu IRQ |
| `$03B6` / `$03B7` | `CameraX` (fraction / pixel) |
| `$03BB` | `FloorLines` — parallax ground lines |
| `$03BF`… / `$03DF`… | `FloorScrollX` — scroll of each ground line |
| `$03FF` | `IrqStage` — current IRQ step |
| `$0400`–`$040B` | split-screen parameters |
| `$040C` | `HitStop` — freeze after a hit |
| `$0426`–`$043A` | energy bar tiles |
| `$045E` | `VoiceQueued` — voice to play / continuation (`$FF` = none) |
| `$045F` | `MusicBank` |
| `$046B`–`$047E` | FamiTone2 extensions (slides) |
| `$0485`–`$049C` | `FadePalette` — fade target palette |
| `$049E`–`$04B1` | `FarCall` — inter-bank call trampoline (code in RAM) |