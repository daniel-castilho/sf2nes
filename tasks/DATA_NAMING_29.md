# Data naming — batch 7: bank `$29` (music modules)

- **Status:** **APPLIED** — 46 structural names applied; 57 labels deferred (P3); ROM SHA-1 unchanged. Pending commit authorization.
- **Scope:** the 103 automatic `D29_*` labels of `src/bank_29.s`.
- **Source of truth:** `annotations/sf2ne.ann`, `src/bank_29.s`, `src/bank_37.s` (FamiTone2 engine),
  `src/bank_3B.s` (call sites), and the public FamiTone2 sources (v1.12 and the v1.15-derived
  `famitone5`) for comparison only.
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

### 1.1 Module map and consumers

`SoundLoadSong` (`37:E3E0`) maps `MusicBank` at `$A000`, passes `zp_D5/zp_D6` to `FamiToneInit`,
`SoundInitSfx`, `SoundInitVoices` and finally `FamiToneMusicPlay`. The four modules in `$29` are
loaded by name from four call sites:

| Module | Base | Header bytes | Call site |
|--------|------|--------------|-----------|
| Title | `29:A000` | `01 13 A0 18 A0 21 A0 ED A2 5D A5 33 A6 18 AA 33 01 00 01` | `37:F4EE-F4FB` (`ScreenTitle`) |
| Select | `29:AAB6` | `01 C9 AA CE AA D7 AA DE AC EF AE 5F B0 C6 B2 33 01 00 01` | `37:EF92-EF9F` (`SelectInit`) |
| Versus | `29:B34A` | `01 5D B3 62 B3 6B B3 AE B3 10 B4 1D B4 B2 B4 33 01 00 01` | `3B:EB92-EB9F` (versus screen) |
| WinQuote | `29:B4BD` | `01 D0 B4 D5 B4 DE B4 24 B5 60 B5 70 B5 54 B6 33 01 00 01` | `3B:EC5A-EC67` (win quote) |

The Fight module `$2D:A000` is loaded at `3B:F56F-F57C`; it is the next batch, not this one.

### 1.2 Header layout

`FamiToneInit` (`37:E486`) and `FamiToneMusicPlay` (`37:E519`) fix the layout:

| Offset | Size | Content | Reader |
|--------|------|---------|--------|
| `+0` | 1 | song count (always `1` here) | `E550` |
| `+1..+2` | 2 | instrument list pointer | `E495-E49D` |
| `+3..+4` | 2 | DPCM list pointer (unused; see §1.3) | `E4A1-E4A9` |
| `+5..+14` | 10 | five channel pointers (pulse 1, pulse 2, triangle, noise, DPCM) | `E56D-E575` |
| `+15..+16` | 2 | PAL tempo step (`$0133` in all four) | skipped by this build |
| `+17..+18` | 2 | NTSC tempo step (`$0100` in all four) | `E593-E59B` |

`FamiToneMusicPlay` reads the five pointers at `y = 5 + 14*song` and then skips two bytes before
reading the NTSC tempo at `+17/+18`; there is no PAL adjustment in this build. All four modules have
the same tempo pair `33 01 00 01`.

### 1.3 Instrument records and the two envelopes

`_FT2SetInstrument` (`37:EAA1`) indexes the list with `instrument*8`: the channel command stores
`instrument*4` (`_FT2ChannelUpdate`) and the routine shifts it once more. Each record is therefore
8 bytes. For the pulse channels it reads four envelope pointers; the triangle reads three; the noise
reads the first, second and fourth; the DPCM channel does not use instrument records.

Instrument 0 in all four modules is the same shape:

| Module | Instrument 0 bytes | Pointers |
|--------|--------------------|----------|
| Title | `1E A0 1B A0 1B A0 1B A0` | `A01E`, `A01B`, `A01B`, `A01B` |
| Select | `D4 AA D1 AA D1 AA D1 AA` | `AAD4`, `AAD1`, `AAD1`, `AAD1` |
| Versus | `68 B3 65 B3 65 B3 65 B3` | `B368`, `B365`, `B365`, `B365` |
| WinQuote | `DB B4 D8 B4 D8 B4 D8 B4` | `B4DB`, `B4D8`, `B4D8`, `B4D8` |

The first pointer is the full-volume envelope (`CF 00 00`); the other three are the zero envelope
(`C0 00 00`). The envelope reader (`_FT2EnvRead`, `37:E6E9`) treats `$80-$FF` as a volume value
(`$C0` → 0, `$CF` → 15) and `$00` as "jump to offset"; the trailing `00 00` makes both three-byte
sequences constant.

This is a **game-specific variant** of FamiTone2: upstream instruments start with a duty byte and
carry three pointers, while this engine has no duty byte and reads up to four pointers. The names
below follow the game's reader, not the upstream layout.

### 1.4 Channel starts

Each header points at five independent channel streams. `FamiToneMusicPlay` installs them as the
initial channel pointers; the engine then follows `$FF` reference commands and `$FD` loop commands
inside those streams.

| Module | Pulse 1 | Pulse 2 | Triangle | Noise | DPCM |
|--------|---------|---------|----------|-------|------|
| Title | `A021` | `A2ED` | `A55D` | `A633` | `AA18` |
| Select | `AAD7` | `ACDE` | `AEEF` | `B05F` | `B2C6` |
| Versus | `B36B` | `B3AE` | `B410` | `B41D` | `B4B2` |
| WinQuote | `B4DE` | `B524` | `B560` | `B570` | `B654` |

### 1.5 Loop points

A `$FD` command is followed by the target word. The 14 targets in `$29` are:

| Target | Command | Reached from | Note |
|--------|---------|--------------|------|
| `AB29` | `ACDB` | Pulse 1 / Pulse 2 | shared block |
| `AD29` | `AEEC` | Pulse 2 / Noise | shared block |
| `AF4B` | `B05C` | Triangle | |
| `B11C` | `B2C3` | Noise | |
| `B2E6` | `B347` | DPCM | |
| `B3AE` | `B40D` | Pulse 2 | also the channel start |
| `B410` | `B41A` | Triangle | also the channel start |
| `B41D` | `B4AF` | Noise | also the channel start |
| `B4B2` | `B4BA` | DPCM | also the channel start |
| `B520` | `B521` | Pulse 1 | |
| `B55C` | `B55D` | Pulse 2 | |
| `B56C` | `B56D` | Triangle | |
| `B650` | `B651` | Noise | |
| `B659` | `B65A` | DPCM | |

The Versus Pulse 1 loop is the exception: its `$FD` at `B3AB` targets `B36D`, the first note after
the `$FB,$01` speed command, so it has no label of its own and is not renamed.

"Reached from" is the set of channel walks that arrive at the `$FD` command, including through `$FF`
shared blocks. It is not exclusive ownership: a shared block can make two channels loop at the same
target.

### 1.6 Reference blocks

`$FF <length> <word>` is a reference command: the engine continues at the target for the given
number of rows and then returns. The 53 targets in `$29` are pattern fragments shared by the
channels. They are valid stream data but have no independent musical identity in the static
evidence; naming them `Ref0..52` would only restate the index and would break when a shared block is
reused. They stay automatic (P3).

## 2. Proposed names (46)

### Title (9)

| Address | Current | Proposed | Role | Evidence | Confidence | Priority |
|---------|---------|----------|------|----------|------------|----------|
| `29:A000` | `D29_A000` | `MusicTitleHeader` | 19-byte module header | call site `37:F4EE-F4FB`; reader `37:E486`/`37:E519` | HIGH | P0 |
| `29:A013` | `D29_A013` | `MusicTitleInstruments` | instrument list | header `+1/+2`; `FamiToneInit` `37:E497`; reader `37:EAA1` | HIGH | P1 |
| `29:A01B` | `D29_A01B` | `MusicTitleEnvZero` | constant volume 0 envelope | instrument 0 pointers 2-4 | HIGH | P2 |
| `29:A01E` | `D29_A01E` | `MusicTitleEnvFullVolume` | constant volume 15 envelope | instrument 0 pointer 1 | HIGH | P2 |
| `29:A021` | `D29_A021` | `MusicTitlePulse1` | channel 1 start | header `+5`; `FamiToneMusicPlay` `37:E56D` | HIGH | P1 |
| `29:A2ED` | `D29_A2ED` | `MusicTitlePulse2` | channel 2 start | header `+7` | HIGH | P1 |
| `29:A55D` | `D29_A55D` | `MusicTitleTriangle` | channel 3 start | header `+9` | HIGH | P1 |
| `29:A633` | `D29_A633` | `MusicTitleNoise` | channel 4 start | header `+11` | HIGH | P1 |
| `29:AA18` | `D29_AA18` | `MusicTitleDpcm` | channel 5 start | header `+13` | HIGH | P1 |

### Select (14)

| Address | Current | Proposed | Role | Evidence | Confidence | Priority |
|---------|---------|----------|------|----------|------------|----------|
| `29:AAB6` | `D29_AAB6` | `MusicSelectHeader` | 19-byte module header | call site `37:EF92-EF9F` | HIGH | P0 |
| `29:AAC9` | `D29_AAC9` | `MusicSelectInstruments` | instrument list | header `+1/+2` | HIGH | P1 |
| `29:AAD1` | `D29_AAD1` | `MusicSelectEnvZero` | constant volume 0 envelope | instrument 0 pointers 2-4 | HIGH | P2 |
| `29:AAD4` | `D29_AAD4` | `MusicSelectEnvFullVolume` | constant volume 15 envelope | instrument 0 pointer 1 | HIGH | P2 |
| `29:AAD7` | `D29_AAD7` | `MusicSelectPulse1` | channel 1 start | header `+5` | HIGH | P1 |
| `29:ACDE` | `D29_ACDE` | `MusicSelectPulse2` | channel 2 start | header `+7` | HIGH | P1 |
| `29:AEEF` | `D29_AEEF` | `MusicSelectTriangle` | channel 3 start | header `+9` | HIGH | P1 |
| `29:B05F` | `D29_B05F` | `MusicSelectNoise` | channel 4 start | header `+11` | HIGH | P1 |
| `29:B2C6` | `D29_B2C6` | `MusicSelectDpcm` | channel 5 start | header `+13` | HIGH | P1 |
| `29:AB29` | `D29_AB29` | `MusicSelectLoopPulse1Pulse2` | loop target | `$FD` at `ACDB`; reached from Pulse 1/Pulse 2 | HIGH | P2 |
| `29:AD29` | `D29_AD29` | `MusicSelectLoopPulse2Noise` | loop target | `$FD` at `AEEC`; reached from Pulse 2/Noise | HIGH | P2 |
| `29:AF4B` | `D29_AF4B` | `MusicSelectLoopTriangle` | loop target | `$FD` at `B05C` | HIGH | P2 |
| `29:B11C` | `D29_B11C` | `MusicSelectLoopNoise` | loop target | `$FD` at `B2C3` | HIGH | P2 |
| `29:B2E6` | `D29_B2E6` | `MusicSelectLoopDpcm` | loop target | `$FD` at `B347` | HIGH | P2 |

### Versus (9)

| Address | Current | Proposed | Role | Evidence | Confidence | Priority |
|---------|---------|----------|------|----------|------------|----------|
| `29:B34A` | `D29_B34A` | `MusicVersusHeader` | 19-byte module header | call site `3B:EB92-EB9F` | HIGH | P0 |
| `29:B35D` | `D29_B35D` | `MusicVersusInstruments` | instrument list | header `+1/+2` | HIGH | P1 |
| `29:B365` | `D29_B365` | `MusicVersusEnvZero` | constant volume 0 envelope | instrument 0 pointers 2-4 | HIGH | P2 |
| `29:B368` | `D29_B368` | `MusicVersusEnvFullVolume` | constant volume 15 envelope | instrument 0 pointer 1 | HIGH | P2 |
| `29:B36B` | `D29_B36B` | `MusicVersusPulse1` | channel 1 start | header `+5` | HIGH | P1 |
| `29:B3AE` | `D29_B3AE` | `MusicVersusPulse2` | channel 2 start + loop target | header `+7`; `$FD` at `B40D` | HIGH | P1 |
| `29:B410` | `D29_B410` | `MusicVersusTriangle` | channel 3 start + loop target | header `+9`; `$FD` at `B41A` | HIGH | P1 |
| `29:B41D` | `D29_B41D` | `MusicVersusNoise` | channel 4 start + loop target | header `+11`; `$FD` at `B4AF` | HIGH | P1 |
| `29:B4B2` | `D29_B4B2` | `MusicVersusDpcm` | channel 5 start + loop target | header `+13`; `$FD` at `B4BA` | HIGH | P1 |

### WinQuote (14)

| Address | Current | Proposed | Role | Evidence | Confidence | Priority |
|---------|---------|----------|------|----------|------------|----------|
| `29:B4BD` | `D29_B4BD` | `MusicWinQuoteHeader` | 19-byte module header | call site `3B:EC5A-EC67` | HIGH | P0 |
| `29:B4D0` | `D29_B4D0` | `MusicWinQuoteInstruments` | instrument list | header `+1/+2` | HIGH | P1 |
| `29:B4D8` | `D29_B4D8` | `MusicWinQuoteEnvZero` | constant volume 0 envelope | instrument 0 pointers 2-4 | HIGH | P2 |
| `29:B4DB` | `D29_B4DB` | `MusicWinQuoteEnvFullVolume` | constant volume 15 envelope | instrument 0 pointer 1 | HIGH | P2 |
| `29:B4DE` | `D29_B4DE` | `MusicWinQuotePulse1` | channel 1 start | header `+5` | HIGH | P1 |
| `29:B524` | `D29_B524` | `MusicWinQuotePulse2` | channel 2 start | header `+7` | HIGH | P1 |
| `29:B560` | `D29_B560` | `MusicWinQuoteTriangle` | channel 3 start | header `+9` | HIGH | P1 |
| `29:B570` | `D29_B570` | `MusicWinQuoteNoise` | channel 4 start | header `+11` | HIGH | P1 |
| `29:B654` | `D29_B654` | `MusicWinQuoteDpcm` | channel 5 start | header `+13` | HIGH | P1 |
| `29:B520` | `D29_B520` | `MusicWinQuoteLoopPulse1` | loop target | `$FD` at `B521` | HIGH | P2 |
| `29:B55C` | `D29_B55C` | `MusicWinQuoteLoopPulse2` | loop target | `$FD` at `B55D` | HIGH | P2 |
| `29:B56C` | `D29_B56C` | `MusicWinQuoteLoopTriangle` | loop target | `$FD` at `B56D` | HIGH | P2 |
| `29:B650` | `D29_B650` | `MusicWinQuoteLoopNoise` | loop target | `$FD` at `B651` | HIGH | P2 |
| `29:B659` | `D29_B659` | `MusicWinQuoteLoopDpcm` | loop target | `$FD` at `B65A` | HIGH | P2 |

Suggested comments (short, one fact each):

- Headers: module header read by `SoundLoadSong`; 1 song, 5 channel pointers, tempo `$0100` (NTSC).
- Instruments: 8-byte records read by `_FT2SetInstrument`; instrument 0 uses the two envelopes below.
- `EnvZero` / `EnvFullVolume`: constant volume 0 / 15 envelope (`C0 00 00` / `CF 00 00`).
- Channel starts: pointer at header `+5/+7/+9/+11/+13` for pulse 1, pulse 2, triangle, noise, DPCM.
- Loop labels: target of the `$FD` loop command at the cited address; shared loops name the channels
  that reach them.

## 3. Deferred (57, P3, keep automatic)

### 3.1 Reference blocks (53)

Targets of `$FF <length> <word>` commands. They are valid stream fragments but their musical identity
is not proven statically; several are shared by more than one channel. Sizes are bytes to the next
label.

| Module | Addresses (size) |
|--------|------------------|
| Title (5) | `A0D7` (15), `A0E6` (18), `A0F8` (501), `A66A` (16), `A67A` (926) |
| Select (47) | `AAD9` (35), `AAFC` (8), `AB04` (9), `AB0D` (6), `AB13` (7), `AB1A` (9), `AB23` (6), `AB32` (8), `AB3A` (6), `AB40` (35), `AB63` (6), `AB69` (8), `AB71` (5), `AB76` (6), `AB7C` (111), `ABEB` (8), `ABF3` (9), `ABFC` (10), `AC06` (17), `AC17` (199), `ACFD` (5), `AD02` (9), `AD0B` (5), `AD10` (9), `AD19` (5), `AD1E` (11), `AD37` (12), `AD43` (22), `AD59` (25), `AD72` (10), `AD7C` (46), `ADAA` (325), `B06A` (16), `B07A` (43), `B0A5` (21), `B0BA` (32), `B0DA` (17), `B0EB` (13), `B0F8` (6), `B0FE` (16), `B10E` (14), `B132` (31), `B151` (12), `B15D` (12), `B169` (50), `B19B` (65), `B1DC` (234) |
| Versus (1) | `B3A5` (9) |
| WinQuote (0) | — |

`B3A5` is a shared tail for Versus Pulse 2/Noise and contains the Pulse 1 loop to `B36D`; it still has
no independent name, so it stays automatic.

### 3.2 Header artifacts (4)

These are the third word (envelope pointer 3) of instrument 0 in each module. They are not independent
tables:

| Address | Bytes | Why the label exists |
|---------|-------|----------------------|
| `A017` | `1B A0` | header `+3/+4` is `A018` (`A017+1`); the unused DPCM pointer created a label one byte before the word |
| `AACD` | `D1 AA` | header DPCM pointer `AACE` (`AACD+1`) |
| `B361` | `65 B3` | header DPCM pointer `B362` (`B361+1`) |
| `B4D4` | `D8 B4` | header DPCM pointer `B4D5` (`B4D4+1`) |

`FamiToneInit` copies the header DPCM pointer into `FT_DPCM_LIST`, but `SoundInitVoices`
(`37:E41B`) immediately calls `FtSetSampleTable` (`37:E47F`), which overwrites `FT_DPCM_LIST` with
`VoiceSampleTbl`. The header field is therefore unused, and the pointer points one byte into the
instrument record. Naming these words as envelopes would duplicate `EnvZero`; naming them
`Instrument0Env3` would document a field that the DPCM reader never uses. Keep them automatic (P3).

## 4. Comment and reference updates required

| File | Change |
|------|--------|
| `annotations/sf2ne.ann` | new `# BANK $29` section with 46 `label 29:...` / `comment 29:...` pairs |
| `src/bank_29.s` | regenerated: 46 labels and their `.word` operands |
| `src/bank_37.s` | label-only references at `EF97/EF9B`, `F4F3/F4F7` |
| `src/bank_3B.s` | label-only references at `EB97/EB9B`, `EC5F/EC63` |
| `src/globals.inc` | four `.global` names (`D29_A000`, `D29_AAB6`, `D29_B34A`, `D29_B4BD`) |
| `docs/PROJECT_STATUS.md`, `README.md`, `tasks/DATA_LABEL_CANDIDATES.md`, `tasks/PHASE_3_EXECUTION_REPORT.md`, `docs/lessons.md` | metrics, batch history and the instrument-layout lesson |

No manual edit of `src/` is planned: the canonical flow is `annotations/sf2ne.ann` + `make gen`.
`src/bank_05.s` (Ken) is not touched.

## 5. Validation plan

1. Add the 46 pairs in a new `# BANK $29` section of `annotations/sf2ne.ann`.
2. Run `make gen`; inspect the diff. Expected files: `src/bank_29.s`, `src/bank_37.s`,
   `src/bank_3B.s`, `src/globals.inc`. Only labels, comments and `.global` directives may change.
3. Run `make`; ROM SHA-1 must remain `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`.
4. Confirm no numeric `.byte`/`.word`/`.res` operand changed. Expected label-only operand changes are
   the header/channel `.word`s, the loop `.word`s and the code immediates in `$37`/`$3B`.
5. `grep -c '^D29_' src/bank_29.s` must be 57; `grep -rn 'D29_' annotations/sf2ne.ann` must be empty.
6. `src/bank_05.s` must remain untouched.
7. Re-measure with the canonical regex: automatic data `1,056 -> 1,010`; semantic `1,084 -> 1,130`;
   unique names `2,140` unchanged.
8. Update the docs, then request commit authorization; no push without explicit approval.

## 6. Risks and notes

- **Instrument layout is not upstream FamiTone2.** Do not add a duty byte or trim the 8-byte records;
  the game's `_FT2SetInstrument` reads four envelope pointers for pulse channels.
- **The header DPCM field is dead.** Do not "fix" the `+1` pointers or move the labels; the field is
  overwritten by `FtSetSampleTable`.
- **Loop names describe reachability, not exclusive ownership.** Shared `$FF` blocks can make two
  channels reach the same `$FD` target; the comment says which channels were observed.
- **The Versus Pulse 1 loop targets `B36D`, not `B36B`.** It skips the `$FB,$01` speed command, so the
  channel label is not the loop target.
- **Reference blocks are shared and may be reused.** Do not trim or reorder them; naming them by index
  would be less stable than the automatic address.
- No emulator execution was used; confidence comes from static consumers, the header bytes and the
  public FamiTone2 sources.

## 7. Approval and application

The batch follows the Phase 3 criteria: HIGH confidence for the 46 structural names, P3 for the 57
labels without a definitive identity, and no gameplay/ROM change. The names were applied in
`annotations/sf2ne.ann` after this report; the result is recorded in §8.

## 8. Applied result and verification

| Check | Result |
|-------|--------|
| `annotations/sf2ne.ann` | new `# BANK $29` section with 46 `label`/`comment` pairs |
| `src/bank_29.s` | 46 labels and their `.word` operands renamed; 57 `D29_*` labels remain |
| `src/bank_37.s` | label-only references at `EF97/EF9B` and `F4F3/F4F7` |
| `src/bank_3B.s` | label-only references at `EB97/EB9B` and `EC5F/EC63` |
| `src/globals.inc` | four `.global` names moved from `D29_*` to `Music*Header` |
| `make gen` | OK; second run idempotent (same diff hash) |
| `make` | OK — canonical build with `DEST_FLAG_BLINK` |
| SHA-1 of `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to baseline |
| Directive operands | 824 `.byte`/`.word`/`.res` directives in `src/bank_29.s`; 50 differ only by symbol rename; no numeric operand changed |
| `grep -c '^D29_' src/bank_29.s` | 57 (53 reference blocks + 4 artifacts) |
| `grep -rn 'D29_' annotations/sf2ne.ann` | 0 |
| `src/bank_05.s` | untouched |
| Metrics | automatic data `1,056 -> 1,010`; unique semantic `1,084 -> 1,130`; unique names `2,140` unchanged |

Commit is still pending explicit authorization; nothing was pushed.
