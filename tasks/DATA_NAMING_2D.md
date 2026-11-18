# Data naming — batch 8: bank `$2D` (Fight music module)

- **Status:** **APPLIED** — 14 structural names applied; 56 labels deferred (P3); ROM SHA-1 unchanged. Pending commit authorization.
- **Scope:** the 70 automatic `D2D_*` labels of `src/bank_2D.s`.
- **Source of truth:** `annotations/sf2ne.ann`, `src/bank_2D.s`, `src/bank_37.s` (FamiTone2 engine),
  `src/bank_3B.s` (call site), and the public FamiTone2 sources for comparison only.
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

### 1.1 Module and consumer

`RoundStart` (`3B:F556`) sets `MusicBank = $2D` and passes `$2D:A000` to `SoundLoadSong`
(`3B:F56F-F57C`). `SoundLoadSong` (`37:E3E0`) maps the bank at `$A000`, then calls `FamiToneInit`,
`SoundInitSfx`, `SoundInitVoices` and `FamiToneMusicPlay`.

| Fact | Evidence |
|------|----------|
| Module base | `2D:A000` |
| Header bytes | `01 13 A0 18 A0 21 A0 39 A2 C3 A6 85 A9 00 B2 33 01 00 01` |
| Call site | `3B:F56F-F57C` (`RoundStart`, fight music) |

### 1.2 Header layout

The layout is the same one confirmed for `$29` in `tasks/DATA_NAMING_29.md` §1.2:

| Offset | Size | Content | Reader |
|--------|------|---------|--------|
| `+0` | 1 | song count (`1`) | `37:E550` |
| `+1..+2` | 2 | instrument list pointer (`A013`) | `37:E495-E49D` |
| `+3..+4` | 2 | DPCM list pointer (`A018`, unused; see §1.5) | `37:E4A1-E4A9` |
| `+5..+14` | 10 | five channel pointers | `37:E56D-E575` |
| `+15..+16` | 2 | PAL tempo step (`$0133`) | skipped by this build |
| `+17..+18` | 2 | NTSC tempo step (`$0100`) | `37:E593-E59B` |

### 1.3 Instrument record

`_FT2SetInstrument` (`37:EAA1`) indexes the list with `instrument*8`. The list at `A013` is one
8-byte record:

| Address | Bytes | Pointer |
|---------|-------|---------|
| `A013` | `1E A0` | `A01E` (full volume) |
| `A015` | `1B A0` | `A01B` (zero) |
| `A017` | `1B A0` | `A01B` (zero) |
| `A019` | `1B A0` | `A01B` (zero) |

`A01B` is `C0 00 00` (constant volume 0) and `A01E` is `CF 00 00` (constant volume 15). This is the
game-specific layout already documented for `$29`: no duty byte and up to four envelope pointers.

### 1.4 Channel starts

| Channel | Address | Header offset |
|---------|---------|---------------|
| Pulse 1 | `A021` | `+5` |
| Pulse 2 | `A239` | `+7` |
| Triangle | `A6C3` | `+9` |
| Noise | `A985` | `+11` |
| DPCM | `B200` | `+13` |

### 1.5 Loop points

Each `$FD` command is followed by its target word:

| Target | `$FD` at | Channel | Note |
|--------|----------|---------|------|
| `A048` | `A236` | Pulse 1 | first note after the intro |
| `A25E` | `A6C0` | Pulse 2 | |
| `A6F8` | `A982` | Triangle | |
| `AA23` | `B1FD` | Noise | |
| `B216` | `B309` | DPCM | long rest block, loops on itself |

All five targets are distinct from the channel starts, and each is reached by only one channel. No
loop target is shared through a `$FF` reference in this module.

### 1.6 Reference blocks

`$FF <length> <word>` targets 55 distinct labels. All 55 are valid stream fragments and all are
labels already created by the disassembler. They have no independent musical identity in the static
evidence, so they stay automatic (P3). Sizes are bytes to the next label:

`A100` (146), `A192` (15), `A1A1` (152), `A3F4` (174), `A4A2` (95), `A501` (29), `A51E` (37),
`A543` (72), `A58B` (312), `A704` (9), `A70D` (79), `A75C` (125), `A7D9` (73), `A822` (97),
`A883` (18), `A895` (240), `A99B` (14), `A9A9` (20), `A9BD` (21), `A9D2` (18), `A9E4` (63),
`AA39` (21), `AA4E` (11), `AA59` (17), `AA6A` (16), `AA7A` (14), `AA88` (22), `AA9E` (55),
`AAD5` (21), `AAEA` (30), `AB08` (6), `AB0E` (9), `AB17` (10), `AB21` (17), `AB32` (20),
`AB46` (26), `AB60` (16), `AB70` (87), `ABC7` (42), `ABF1` (95), `AC50` (177), `AD01` (13),
`AD0E` (37), `AD33` (76), `AD7F` (43), `ADAA` (40), `ADD2` (43), `ADFD` (34), `AE1F` (23),
`AE36` (154), `AED0` (21), `AEE5` (76), `AF31` (66), `AF73` (524), `B17F` (129).

The header DPCM pointer is `A018`, i.e. `A017+1`. It points one byte into the instrument record and
is overwritten by `FtSetSampleTable` (`37:E47F`) through `SoundInitVoices` (`37:E41B`); `A017` is
therefore a header artifact, not a real envelope. It stays automatic (P3).

## 2. Proposed names (14)

| Address | Current | Proposed | Role | Evidence | Confidence | Priority |
|---------|---------|----------|------|----------|------------|----------|
| `2D:A000` | `D2D_A000` | `MusicFightHeader` | 19-byte module header | call site `3B:F56F-F57C`; reader `37:E486`/`37:E519` | HIGH | P0 |
| `2D:A013` | `D2D_A013` | `MusicFightInstruments` | instrument list | header `+1/+2`; reader `37:EAA1` | HIGH | P1 |
| `2D:A01B` | `D2D_A01B` | `MusicFightEnvZero` | constant volume 0 envelope | instrument 0 pointers 2-4 | HIGH | P2 |
| `2D:A01E` | `D2D_A01E` | `MusicFightEnvFullVolume` | constant volume 15 envelope | instrument 0 pointer 1 | HIGH | P2 |
| `2D:A021` | `D2D_A021` | `MusicFightPulse1` | channel 1 start | header `+5` | HIGH | P1 |
| `2D:A239` | `D2D_A239` | `MusicFightPulse2` | channel 2 start | header `+7` | HIGH | P1 |
| `2D:A6C3` | `D2D_A6C3` | `MusicFightTriangle` | channel 3 start | header `+9` | HIGH | P1 |
| `2D:A985` | `D2D_A985` | `MusicFightNoise` | channel 4 start | header `+11` | HIGH | P1 |
| `2D:B200` | `D2D_B200` | `MusicFightDpcm` | channel 5 start | header `+13` | HIGH | P1 |
| `2D:A048` | `D2D_A048` | `MusicFightLoopPulse1` | loop target | `$FD` at `A236` | HIGH | P2 |
| `2D:A25E` | `D2D_A25E` | `MusicFightLoopPulse2` | loop target | `$FD` at `A6C0` | HIGH | P2 |
| `2D:A6F8` | `D2D_A6F8` | `MusicFightLoopTriangle` | loop target | `$FD` at `A982` | HIGH | P2 |
| `2D:AA23` | `D2D_AA23` | `MusicFightLoopNoise` | loop target | `$FD` at `B1FD` | HIGH | P2 |
| `2D:B216` | `D2D_B216` | `MusicFightLoopDpcm` | loop target | `$FD` at `B309` | HIGH | P2 |

Suggested comments:

- Header: fight music module header; 1 song, instrument list at `A013`, five channel pointers, tempo `$0100` (NTSC).
- Instruments: 8-byte records read by `_FT2SetInstrument`; instrument 0 uses the two envelopes below.
- `EnvZero` / `EnvFullVolume`: constant volume 0 / 15 envelope (`C0 00 00` / `CF 00 00`).
- Channel starts: pointer at header `+5/+7/+9/+11/+13`.
- Loop labels: target of the `$FD` command at the cited address.

## 3. Deferred (56, P3, keep automatic)

- **55 reference blocks** listed in §1.6. Naming them `Ref0..54` would restate the index and break on
  reuse.
- **1 header artifact:** `A017` (third word of instrument 0; the unused DPCM pointer points at
  `A017+1`).

## 4. Comment and reference updates required

| File | Change |
|------|--------|
| `annotations/sf2ne.ann` | new `# BANK $2D` section with 14 `label`/`comment` pairs |
| `src/bank_2D.s` | regenerated: 14 labels and their `.word` operands |
| `src/bank_3B.s` | label-only references at `F574/F578` |
| `src/globals.inc` | one `.global` name (`D2D_A000` → `MusicFightHeader`) |
| `docs/PROJECT_STATUS.md`, `README.md`, `tasks/DATA_LABEL_CANDIDATES.md`, `tasks/PHASE_3_EXECUTION_REPORT.md`, `docs/lessons.md` | metrics, batch history and the `$2D` result |

No manual edit of `src/` is planned: the canonical flow is `annotations/sf2ne.ann` + `make gen`.
`src/bank_05.s` (Ken) is not touched.

## 5. Validation plan

1. Add the 14 pairs in a new `# BANK $2D` section of `annotations/sf2ne.ann`.
2. Run `make gen`; inspect the diff. Expected files: `src/bank_2D.s`, `src/bank_3B.s`,
   `src/globals.inc`.
3. Run `make`; ROM SHA-1 must remain `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`.
4. Confirm no numeric `.byte`/`.word`/`.res` operand changed.
5. `grep -c '^D2D_' src/bank_2D.s` must be 56; `grep -rn 'D2D_' annotations/sf2ne.ann` must be empty.
6. `src/bank_05.s` must remain untouched.
7. Re-measure with the canonical regex: automatic data `1,010 -> 996`; semantic `1,130 -> 1,144`;
   unique names `2,140` unchanged.
8. Update the docs, then request commit authorization; no push without explicit approval.

## 6. Risks and notes

- **Instrument layout is not upstream FamiTone2.** Keep the 8-byte records and the four envelope
  pointers; do not add a duty byte.
- **The header DPCM field is dead.** Do not move the `A017` label or "fix" the `+1` pointer.
- **Loop names describe reachability.** Each target here is reached by a single channel; this is not
  true for every module.
- **Reference blocks are shared.** Do not trim or reorder them; the automatic address is more stable
  than an index.
- No emulator execution was used; confidence comes from static consumers, the header bytes and the
  public FamiTone2 sources.

## 7. Approval and application

The batch follows the Phase 3 criteria: HIGH confidence for the 14 structural names, P3 for the 56
labels without a definitive identity, and no gameplay/ROM change. The names were applied in
`annotations/sf2ne.ann` after this report; the result is recorded in §8.

## 8. Applied result and verification

| Check | Result |
|-------|--------|
| `annotations/sf2ne.ann` | new `# BANK $2D` section with 14 `label`/`comment` pairs |
| `src/bank_2D.s` | 14 labels and their `.word` operands renamed; 56 `D2D_*` labels remain |
| `src/bank_3B.s` | label-only references at `F574/F578` |
| `src/globals.inc` | one `.global` name moved from `D2D_A000` to `MusicFightHeader` |
| `make gen` | OK; second run idempotent (same diff hash) |
| `make` | OK — canonical build with `DEST_FLAG_BLINK` |
| SHA-1 of `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to baseline |
| Directive operands | 632 `.byte`/`.word`/`.res` directives in `src/bank_2D.s`; 15 differ only by symbol rename; no numeric operand changed |
| `grep -c '^D2D_' src/bank_2D.s` | 56 (55 reference blocks + 1 artifact) |
| `grep -rn 'D2D_' annotations/sf2ne.ann` | 0 |
| `src/bank_05.s` | untouched |
| Metrics | automatic data `1,010 -> 996`; unique semantic `1,130 -> 1,144`; unique names `2,140` unchanged |

Commit is still pending explicit authorization; nothing was pushed.
