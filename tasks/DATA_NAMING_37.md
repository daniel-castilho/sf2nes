# Data naming — batch 6: bank `$37` (sound engine data, select and title tables)

- **Status:** **APPLIED** — 17 names applied in `annotations/sf2ne.ann` and `src/*.s`; ROM SHA-1 unchanged; 10 FamiTone2 sfx streams kept automatic (P3). Pending commit authorization.
- **Scope:** the 27 automatic `D37_*` labels of `src/bank_37.s`.
- **Source of truth:** `annotations/sf2ne.ann`, `src/bank_37.s` (consumers), `src/bank_3F.s` (callers), `docs/RAM.md`, `docs/BUGS.md`, and the public FamiTone2 sources (v1.12 and the v1.15-derived famitone5 source).
- **Rule:** only labels and comments change; ROM bytes and SHA-1 must remain identical.

## 1. Evidence used

### 1.1 Fighter voice table and its continuation column

`VoicePlayFighter` (`37:E43C`) computes `y = FighterChar * 16 + zp_DC`, reads the first sample with
`lda FighterVoiceTbl,y` (`E447`) and the continuation sample with `lda D37_E0FA,y` (`E458`).

| Fact | Evidence |
|------|----------|
| Table base | `FighterVoiceTbl` = `37:E0F9` |
| Record size | 16 bytes per fighter; 10 fighters → `E0F9-E198` (160 bytes) |
| Next label | `D37_E199` starts at `E199`, exactly after the 160 bytes |
| `E0FA` role | literal `FighterVoiceTbl + 1`: the continuation byte of each `(sample, continuation)` pair |
| Sentinel | `$FF` = no voice (`bmi VoicePlayFighterEnd` at `E44A`) |

`D37_E0FA` is therefore not an independent table; it is the odd-offset column of the same
16-byte records. The proposed name must be read together with that comment.

### 1.2 Sfx dispatch: state class and stream pointer list

`SfxPlayByState` (`37:E40B`):

```
ldx zp_DC              ; state class 0..5
lda D37_E199,x         ; A = sfx number
ldy zp_DB              ; fighter slot
ldx SfxChannelOfs,y    ; X = FamiTone2 stream offset (0/15/30/45)
jsr FamiToneSfxPlay
```

`zp_DC` is produced by `StateSetByte` (`3F:E47F-E495`): `(state & $F8 - $70) >> 3`, i.e. six
classes (`$70-$9F`). `SfxChannelOfs` (`37:E19F`) is already named and holds the four
`FT_SFX_STRUCT_SIZE = 15` stream offsets.

| Address | Bytes | Meaning |
|---------|-------|---------|
| `E199` | `$02,$03,$04,$02,$03,$04` (6) | state class 0–5 → sfx number |
| `E1A3` (`SfxData`) | `.word E1A7`, `.word E1A7` | FamiTone2 sfx data header; `FamiToneSfxInit` reads only the first word |
| `E1A7` | 22 bytes = 11 words | sfx number → stream pointer |

`E1A7` entries 0–9 are the ten explicit streams; entry 10 (`E1BB`) is `$E375`, inside the last
stream. `$E375` starts with `$86,$81,$87,...`, valid FamiTone2 register-write commands, so it is
a legitimate shared-tail entry, not stray padding. The batch names the pointer list only; it
does not claim which sound each index is.

Sfx numbers observed in code: `2,3,4` (`E199`), `5,6,7` (`HitSfxTbl`, `3F:E055`), `9`
(`3F:F654`), plus the frame-effect parameter (`EffectParam`, `3F:E405-E40C`) which can index
other entries.

> The existing comment at `37:E40B` is reversed: `D37_E199` holds the **sfx number**, and
> `SfxChannelOfs` holds the **stream offset**. The batch corrects this comment.

### 1.3 FamiTone2 internal tables

| Address | Bytes | Content | Upstream match |
|---------|-------|---------|----------------|
| `E8AD` | 4 | `$30,$70,$B0,$F0` | `duty_table` (pulse duty) |
| `E8B1` | 4 | `$00,$80,$00,$80` | `duty_table_nz` (noise duty) |
| `EA27` | 12 | `0,0,11,22,33,44,55,66,77,88,99,110` | `Vib_Offset` |
| `EA33` | 110 (10×11) | signed vibrato offsets | `Vib_Table` |
| `EE74` | 3 | `$C0,$00,$00` | `_FT2DummyEnvelope` |

Consumers: `E72E` and `E785` read `E8AD,x`; `E819` reads `E8B1,x`; `E9FE` reads `EA27,x`;
`EA06` reads `EA33,x`; `E4FF`/`E504` point the envelopes at `EE74`.

The `EA27`/`EA33` values match the public FamiTone2 `Vib_Offset`/`Vib_Table` byte-for-byte, and
`EE74` matches `_FT2DummyEnvelope` exactly. Naming keeps the project `_FT2` prefix and the
`Table` spelling already used by `_FT2NoteTableLSB`/`_FT2NoteTableMSB`.

### 1.4 Select-screen tables

`SelectDrawCursor` (`37:EFFA`), `SelectFighterIntro` (`37:F0CF`) and the `DEST_FLAG_BLINK`
block use `zp_E9` (cursor 0–7):

| Address | Bytes | Role | Consumers |
|---------|-------|------|-----------|
| `F293` | 8 | cursor → fighter index (`0,4,3,7,1,2,9,8`) | `F049`, `F066` (alt), `F105`, `DestFlagDraw` |
| `F29B` | 8 | flag metasprite pointer, low half | `F035`, `F0F1` |
| `F2A3` | 8 | flag metasprite pointer, high half | `F03A`, `F0F6` |
| `F2AB` | 8 | flag sprite X position | `F03F`, `F0FB` |
| `F2B3` | 8 | flag sprite Y position | `F044`, `F100` |
| `F2BB` | 8 | cursor X columns (`$50,$68,$80,$98` ×2) | `F00B` |
| `F2C3` | 8 | cursor Y rows (`$B8` ×4, `$D8` ×4) | `F010` |

`F29B`/`F2A3` point at the six `Flag*` metasprites in `$20` (`FlagJapan`, `FlagBrazil`,
`FlagUsa`, `FlagThailand`, `FlagChina`, `FlagUssr`), already named in batch `$20`.

### 1.5 Title palette

`ScreenTitle` (`37:F4E5`) copies 12 bytes from `D37_F699` (`F524`) to `PaletteBuf,x` and
`PaletteBuf+12,x`. `PaletteBuf` is 24 colors: `0-11` BG, `12-23` sprite (`docs/RAM.md`). The
12-byte block is the title palette used for both halves.

### 1.6 Reset-vector filler

`D37_FF9F` is `.res 91, $FF` (`FF9F-FFF9`); the reset vector at `37:FFFC` points to it in the
canonical build. This is the same role already named `ResetVectorFill` at `3B:FF9F`
(`docs/BUGS.md` §1, `FIX_SOFT_RESET`).

## 2. Proposed names (17)

| Address | Current | Proposed | Size | Consumer(s) | Confidence | Priority |
|---------|---------|----------|------|-------------|------------|----------|
| `37:E0FA` | `D37_E0FA` | `FighterVoiceContTbl` | 159 (offset +1 of the 160-byte `FighterVoiceTbl`) | `E458` | HIGH | P2 |
| `37:E199` | `D37_E199` | `StateClassSfxTbl` | 6 | `E40D` | HIGH | P1 |
| `37:E1A7` | `D37_E1A7` | `SfxStreamPtrTbl` | 22 (11 words) | `E1A3`, `E1A5` | HIGH | P1 |
| `37:E8AD` | `D37_E8AD` | `_FT2DutyTable` | 4 | `E72E`, `E785` | HIGH | P2 |
| `37:E8B1` | `D37_E8B1` | `_FT2NoiseDutyTable` | 4 | `E819` | HIGH | P2 |
| `37:EA27` | `D37_EA27` | `_FT2VibratoOffsetTable` | 12 | `E9FE` | HIGH | P2 |
| `37:EA33` | `D37_EA33` | `_FT2VibratoTable` | 110 | `EA06` | HIGH | P2 |
| `37:EE74` | `D37_EE74` | `_FT2DummyEnvelope` | 3 | `E4FF`, `E504` | HIGH | P2 |
| `37:F293` | `D37_F293` | `SelectCursorFighterTbl` | 8 | `F049`, `F105`, `DestFlagDraw` (canonical); `F066` in the non-alt path | HIGH | P1 |
| `37:F29B` | `D37_F29B` | `SelectFlagPtrLoTbl` | 8 | `F035`, `F0F1` | HIGH | P1 |
| `37:F2A3` | `D37_F2A3` | `SelectFlagPtrHiTbl` | 8 | `F03A`, `F0F6` | HIGH | P1 |
| `37:F2AB` | `D37_F2AB` | `SelectFlagXTbl` | 8 | `F03F`, `F0FB` | HIGH | P1 |
| `37:F2B3` | `D37_F2B3` | `SelectFlagYTbl` | 8 | `F044`, `F100` | HIGH | P1 |
| `37:F2BB` | `D37_F2BB` | `SelectCursorXTbl` | 8 | `F00B` | HIGH | P1 |
| `37:F2C3` | `D37_F2C3` | `SelectCursorYTbl` | 8 | `F010` | HIGH | P1 |
| `37:F699` | `D37_F699` | `TitlePalette` | 12 | `F524` | HIGH | P2 |
| `37:FF9F` | `D37_FF9F` | `ResetVectorFill` | 91 | `FFFC`, kernel comments | HIGH | P2 |

Suggested comments (short, one fact each):

- `FighterVoiceContTbl`: continuation byte of each `(sample, continuation)` pair; offset +1 of `FighterVoiceTbl` (same 16-byte records).
- `StateClassSfxTbl`: state class 0–5 → sfx number for `FamiToneSfxPlay`; stream offset comes from `SfxChannelOfs`.
- `SfxStreamPtrTbl`: sfx number → stream pointer (11 words); entry 10 shares the tail at `E375`.
- `_FT2DutyTable` / `_FT2NoiseDutyTable`: pulse/noise duty values (FamiTone2 `duty_table` / `duty_table_nz`).
- `_FT2VibratoOffsetTable` / `_FT2VibratoTable`: depth → row offset and the 10×11 signed vibrato table (FamiTone2 `Vib_Offset` / `Vib_Table`).
- `_FT2DummyEnvelope`: silent envelope used when music stops (FamiTone2 `_FT2DummyEnvelope`).
- `SelectCursorFighterTbl`: cursor 0–7 → fighter index used by `FighterChar`.
- `SelectFlagPtrLoTbl` / `SelectFlagPtrHiTbl`: cursor → flag metasprite pointer (low/high).
- `SelectFlagXTbl` / `SelectFlagYTbl`: cursor → flag sprite base position.
- `SelectCursorXTbl` / `SelectCursorYTbl`: cursor → cursor sprite position.
- `TitlePalette`: title 12-byte palette, copied to `PaletteBuf` and `PaletteBuf+12`.
- `ResetVectorFill`: 91 bytes of `$FF`; reset vector points here when bank `$37` is mapped.

## 3. Deferred (P3, keep automatic)

The ten stream labels are the targets of `SfxStreamPtrTbl`. Their bytes are valid FamiTone2
commands, but the sound identity (hit, block, projectile, etc.) is not proven statically.

| Address | Current | Raw bytes | Notes |
|---------|---------|-----------|-------|
| `37:E1BD` | `D37_E1BD` | 47 | stream 0 |
| `37:E1EC` | `D37_E1EC` | 32 | stream 1 |
| `37:E20C` | `D37_E20C` | 6 | stream 2, used by `StateClassSfxTbl[0]` |
| `37:E212` | `D37_E212` | 50 | stream 3, used by `StateClassSfxTbl[1]` |
| `37:E244` | `D37_E244` | 69 | stream 4, used by `StateClassSfxTbl[2]` |
| `37:E289` | `D37_E289` | 26 | stream 5, used by `HitSfxTbl[0]` |
| `37:E2A3` | `D37_E2A3` | 14 | stream 6, used by `HitSfxTbl[1]` |
| `37:E2B1` | `D37_E2B1` | 75 | stream 7, used by `HitSfxTbl[2]` |
| `37:E2FC` | `D37_E2FC` | 44 | stream 8 |
| `37:E328` | `D37_E328` | 108 | stream 9, used by `MoveGrabEscape` (`3F:F654`); tail at `E375` is entry 10 |

Reason: naming them `SfxStreamN` would only restate the index; naming them by event would
assert an identity that needs runtime/audio confirmation. Even stream 9, whose direct caller is
`MoveGrabEscape`, can also be reached through `EffectParam`, so an event name would overclaim
exclusivity. They remain automatic, as the music banks `$29`/`$2D` still keep `D29_*`/`D2D_*`.

## 4. Comment and reference updates required

| File | Location | Change |
|------|----------|--------|
| `annotations/sf2ne.ann` | `37:E40B` comment (line 1816) | fix reversed roles: sfx number from `StateClassSfxTbl[x]`, stream offset from `SfxChannelOfs[slot]` |
| `annotations/sf2ne.ann` | `1891-1893` | `D37_F2BB` → `SelectCursorXTbl`, `D37_F2C3` → `SelectCursorYTbl`, `D37_F2AB/F2B3` → `SelectFlagXTbl/SelectFlagYTbl`; keep `$F2C7` as `SelectCursorYTbl+4` |
| `annotations/sf2ne.ann` | `20:84D3` comment | `D37_F29B` → `SelectFlagPtrLoTbl` |
| `annotations/sf2ne.ann` | alt-block comment `2668` and code `2721` | `D37_F293` → `SelectCursorFighterTbl` |
| `src/bank_37.s` | `E40B` comment and alt-block `DestFlagDraw` | same text updates as the `.ann` source |
| `src/bank_20.s` | line 98 | `D37_F29B` → `SelectFlagPtrLoTbl` |
| `src/kernel.inc` | lines 15 and 259 | dedupe `tabela D37_FF9F, tabela ResetVectorFill` → `tabela ResetVectorFill` |
| `docs/PROJECT_STATUS.md` | line 57 | replace the `D37_F2BB` example with a still-automatic label (e.g. `D37_E1BD`) |

Historical reports (`tasks/DATA_NAMING_20.md`, `tasks/DATA_LABEL_*`) keep the old names as
inventory and are not rewritten.

## 5. Validation plan

1. Add the 17 `label 37:...` / `comment 37:...` pairs in a new data subsection of the bank `$37`
   section of `annotations/sf2ne.ann`, then apply the same names mechanically in `src/*.s`
   (no `make gen` commit; see `docs/lessons.md` §10).
2. `make` must succeed.
3. ROM SHA-1 must remain `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`.
4. Confirm no numeric `.byte`/`.word`/`.res` operand changed. Expected operand changes are
   label-only: two `.word D37_E1A7` → `.word SfxStreamPtrTbl` and `.word D37_FF9F` →
   `.word ResetVectorFill`; the deferred stream `.word` operands stay untouched.
5. `grep -c '^D37_' src/bank_37.s` must be 10 (the deferred stream definitions).
   `grep -rn 'D37_' annotations/sf2ne.ann` must be empty; in `src/` only those 10
   definitions and the 10 `.word` operands of `SfxStreamPtrTbl` may remain.
6. `src/bank_05.s` must remain untouched.
7. Re-measure: `defs` unchanged; `autoD` −17; semantic unique +17. Update
   `docs/PROJECT_STATUS.md`, `tasks/PHASE_3_EXECUTION_REPORT.md`,
   `tasks/DATA_LABEL_CANDIDATES.md` and this report to `APPLIED`.
8. Request commit authorization; no push without explicit approval.

## 6. Risks and notes

- `FighterVoiceContTbl` is an alias at `FighterVoiceTbl+1`, not an independent table; the
  comment must say so to avoid a future reader treating the two as separate arrays.
- `SfxStreamPtrTbl` has 11 entries, but only 0–9 start explicit streams; entry 10 shares the
  tail at `E375`. Do not trim the table.
- `SfxData` has two identical words; only the first is read by `FamiToneSfxInit`. Do not remove
  the second word: that would change addresses and bytes.
- `ResetVectorFill` repeats the `3B:FF9F` name in a different bank/segment (local symbols), which
  is consistent with the existing convention.
- No emulator execution was used; confidence comes from static consumers and the public
  FamiTone2 sources.

## 7. Approval and application

The user approved all 17 names on 2026-11-17. The batch was applied to `annotations/sf2ne.ann`
and mechanically to `src/bank_37.s`, with the comment/reference updates of §4.

## 8. Applied result and verification

| Check | Result |
|-------|--------|
| `annotations/sf2ne.ann` | 17 `label`/`comment` pairs added; all `D37_*` references removed |
| `src/bank_37.s` | 17 labels and references renamed; 10 deferred `D37_*` streams remain |
| Comment/reference updates | `src/bank_37.s` E40B and `DestFlagDraw`; `src/bank_20.s` line 98; `src/kernel.inc` lines 15/259; `docs/PROJECT_STATUS.md` example |
| `make` | OK — canonical build with `DEST_FLAG_BLINK` |
| SHA-1 of `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to baseline |
| Directive operands | unchanged except label-only `SfxStreamPtrTbl` (2×) and `ResetVectorFill` (1×) |
| `grep -c '^D37_' src/bank_37.s` | 10 (deferred streams) |
| `grep -rn 'D37_' annotations/sf2ne.ann` | 0 |
| `src/bank_05.s` | untouched |
| Metrics | automatic data 1,073 → 1,056; unique semantic 1,068 → 1,084 |

Commit is still pending explicit authorization; nothing was pushed.
