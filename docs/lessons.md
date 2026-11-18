# Lessons learned — Ken's freeze on special moves

This document records, from start to finish, a bug that **only appeared with Ken**: the game froze
as soon as Ken used a special move near Ryu (CPU). The cause was not in Ken's data, nor in the
animation frames, nor in the character fiche: it was an `RTS` dispatch that only worked for
**one** fighter. The symptom, diagnosis, root cause, fix, verification and discarded alternative
are recorded here — so the same mistake is not repeated in other dispatches of the same type.

---

## 1. Symptom

In Mesen (the emulator where the user saw the problem), choosing Ken and fighting against the
CPU-controlled Ryu:

* Ken walked, jumped, punched and kicked normally;
* when a special move came out (Hadouken, Shoryuken or Tatsumaki), the game **froze**;
* the frame stopped, with no sound and no controller response;
* the freeze happened above all when Ken was **in the air** — Shoryuken, jump or the end of a
  Tatsumaki — because that's when Ryu's AI entered the anti-air branch.

It was not a random freeze: with the same input sequence, the freeze always occurred at the same
point. In the reproducible test, Ken entered state `$C4` (Shoryuken) on frame 1091 and the OAM
(the sprites, `$0200-$02FF`) stopped changing on the next frame.

---

## 2. How the diagnosis was made

The project already had a headless Mesen harness (`tools/mesen/`, `--testrunner` mode). Three
instruments were used, all in Lua:

1. **OAM freeze detector** — the main loop redraws the sprite buffer every frame. If the hash of
   `$0200-$02FF` does not change for 150 frames during the fight, the game is no longer running.
2. **PC ring** — an `addMemoryCallback` execution logger records the last thousands of
   `(PC, mapped bank)` pairs. When the PC repeats the same address 20 times in a row, the CPU has
   stopped (`JAM` instruction).
3. **Instruction counter per frame** — in normal play the loop spends ~9,400 "ops" per frame (the
   vblank wait). On the freeze the number jumped to ~29,780 and OAM froze: it was not a wait, it
   was a dead loop.

With the PC ring, the freeze instant showed the sequence:

```
pc=$8F46 ... pc=$8FE8 bank=00
pc=$A492 bank=01
pc=$A492 bank=01
pc=$A492 bank=01   (repeating forever)
```

The byte at `$A492` (bank `$01`) is `$02`, which on the 6502 is **`JAM`**: the CPU halts and only
exits on reset. `$8FE8` is the `RTS` of Ryu's AI anti-air dispatch. That is: the `RTS` was
returning to `$A492` instead of to an AI routine.

---

## 3. Root cause

Ryu's AI has an "RTS trick" dispatch: it pushes an address and executes `RTS`; the processor
"returns" to the chosen routine. At `$00:8FDC`:

```asm
L00_8FCF:
    lda a:FighterState,y      ; opponent state
    and #$F8
    cmp #$B0
    bcc L00_8FE9
    cmp #$E1
    bcs L00_8FE9
    lda a:FighterChar,y       ; opponent character
    tay                       ; Y = 0 (Ryu), 1 (Ken), ...
    lda D00_9148+1,y          ; high byte of entry
    pha
    lda D00_9148,y            ; low byte of entry
    pha
    rts                       ; "returns" to the pushed address
```

The table has **a single entry**, stored as `address-1` (the `RTS` adds 1):

```asm
D00_9148:
    .word RyuAiAntiAir-1      ; $9148: 49 91  -> target $9149 -> RTS goes to $914A
```

The problem is the indexing. `D00_9148+1,y` and `D00_9148,y` advance **1 at a time** with `Y`, but each
entry occupies **2 bytes**. This only works because, with `Y=0`, both accesses land exactly on the two
bytes of the entry. With `Y=1` (Ken), they land **one byte off** and read the start of the next routine:

| `Y` | `D00_9148+1,y` reads | `D00_9148,y` reads | address pushed | `RTS` goes to |
|---|---|---|---|---|
| `0` (Ryu) | `$9149 = $91` | `$9148 = $49` | `$9149` | `$914A` = `RyuAiAntiAir` ✅ |
| `1` (Ken) | `$914A = $A4` | `$9149 = $91` | `$A491` | `$A492` = `$02` = `JAM` ❌ |

The `$A4` comes from the first byte of `RyuAiAntiAir` (`ldy OtherFighter` = opcode `A4`). The `$91`
is the entry's own high byte. The combination `$A4:$91` forms `$A491`; the `RTS` adds 1 and lands on
`$A492`, which in bank `$01` is garbage (`$02` = `JAM`).

**Why only Ken?** Because `Y` is the **opponent's** character. While the opponent was Ryu
(character 0), the table was indexed with 0 and worked. With Ken (character 1), the same table was
indexed with 1 and the `RTS` trick pointed outside it. The table never had a second entry — the code
had simply never been exercised with another index.

The [NESdev Wiki](https://www.nesdev.org/wiki/RTS_Trick) describes the pattern and the pitfall: in
the *RTS Trick* each entry stores `target-1` (the `RTS` adds 1), and in a 16-bit address table the
index must be multiplied by 2 (`ASL A`) before indexing. The anti-air table is a single `.word`
table; the `ASL` doesn't exist because, with one entry only, index 0 works without scaling. It was
that economy that broke when index 1 came into existence.

---

## 4. The fix

Since the AI in this delivery is **always Ryu's** (the CPU remains Ryu; there is no Ken AI), the
correct anti-air routine is always Ryu's. Instead of indexing the table by the opponent's character,
the code now uses entry 0 **without index**:

```asm
    lda D00_9148+1            ; was: lda D00_9148+1,y   (B9 49 91)
    pha
    lda D00_9148              ; was: lda D00_9148,y     (B9 48 91)
    pha
    rts
```

**Two bytes** changed at `$00:8FE0` and `$00:8FE4`: `B9` (`LDA abs,Y`) becomes `AD` (`LDA abs`). The
`tay` at `$8FDF` remains there and is harmless. Nothing is shifted; the rest of the bank does not change.

The fix enters the canonical build via the `patch` directive of the annotations (the mechanism used for
all Ken changes), in `annotations/sf2ne.ann`:

```
# Ken playable: ... (explanation)
patch 00:8FE0 AD
patch 00:8FE4 AD
```

Effect: any opponent (Ryu, Ken or another) uses `RyuAiAntiAir`, exactly as in Ryu-vs-Ryu. For Ryu the
semantics are **identical** to before, because with `Y=0` the old code already fell on entry 0.

---

## 5. Why not a two-entry table

The "obvious" alternative would be to give Ken his own entry in `D00_9148` and keep indexing by
character. It was discarded for two reasons:

1. **The table is interleaved, not a 16-bit vector.** The low and high bytes are read by two
   separate instructions (`D00_9148` and `D00_9148+1`), with step 1. To accommodate two entries it would
   be necessary to multiply the index by 2 (`ASL A`) before `TAY`. NESdev calls the alternative format
   *split table*: two 1-byte tables (lows and highs) indexed by the same `X`; it is the format of the
   other AI tables in the game (`D00_913C`/`D00_9140` etc.), but not of this one.
2. **It does not fit the `patch` mechanism.** `patch` overwrites bytes in place; inserting an `ASL A`
   (or any byte) would shift all subsequent code by 1 byte. That would require rebuilding/relocating the
   bank, much riskier than a two-byte change — and with no gain, since only Ryu AI exists.

If Ken AI ever exists, the right approach is to redo the dispatch with scaled index (`ASL A`) and a
two-entry table in free space (there are 2,960 `$FF` bytes from `$00:9470`), not to squeeze the second
entry into step 1.

---

## 6. Verification

### 6.1 Build invariants

Comparing `build/sf2ne.nes` with `rom/sf2ne_demo.nes` bank by bank (8 KB per bank). SHA-1 of the final
build: `85610a00f43c06de482f969d8df9764ee5379991`.

| Bank | Differences | What it is |
|---|---|---|
| `$00` | **2 bytes**: `$8FE0`, `$8FE4` | this fix (`B9` → `AD`) |
| `$01` | 0 | Ryu state bank — untouched |
| `$02` | 0 | Ryu data — untouched |
| `$06` | 0 | Ryu data — untouched |
| `$3B` | 0 | kernel/Ryu code copy — untouched |
| `$04` | 16 bytes (`$90E0-$90EF`) | Ken AI stub |
| `$05` | entire bank | Ken state bank (was `$FF`) |
| `$37` | 2 bytes (`$F06C-$F06D`) | selection accepts Ken |
| `$3C` | 22 bytes | Ken fiche/palette in column 1 |
| `$3F` | 18 bytes (`$F828-$F839`) | Disclaimer/QR screens skipped (temporary NOPs) |

Bank `$00` has exactly the two fix bytes; column 0 (Ryu) remains byte-for-byte untouched.

### 6.2 Freeze reproduction (before × after)

The same script that froze the previous ROM — Ken selected, Ryu CPU active, repeated Hadouken:

| ROM | Result |
|---|---|
| before fix | `CRASH OAM_FROZEN` on frame **1271**; Ken stuck at `$C4`; PC at `$A492` (`JAM`) |
| after fix | runs the **5,000** frames to the end, no freeze |

The only functional difference between the two ROMs is the byte pair `$8FE0`/`$8FE4`; the warning
screen was already skipped in both.

### 6.3 Full battery (all specials)

Mesen script with the eight moves — weak/strong Hadouken, weak/strong Shoryuken, weak/strong
Tatsumaki, jump and jump with attack — in cycle, against CPU Ryu:

```
9,000 total frames, 5,907 fight frames
antiAir=559  dispatch=297  rts=297      (the anti-air path ran 297 times)
CRASH: 0
```

Each move was attempted 21–22 times. The `antiAir` counter confirms that the branch that previously
led to `JAM` was executed hundreds of times **without** freezing. The bytes in the assembled ROM are:

```
$8FDC: B9 00 00 A8 AD 49 91 48 AD 48 91 48 60
                           ^^          ^^
                        $8FE0       $8FE4
```

### 6.4 How to repeat

```sh
make gen && make
MESEN_DIR=$PWD/mesen OUT=/tmp/ken-test
# BATTERY = diagnostic Lua script used in this investigation (stays outside the repository)
env -u DISPLAY HOME="$MESEN_DIR/home" LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
    SF2_OUT="$OUT" SF2_FRAMES=9000 \
    "$MESEN_DIR/Mesen" --testrunner --timeout=480 \
    build/sf2ne.nes "$BATTERY"
grep -E "CRASH|COUNTERS|STATS" "$OUT/battery.log"
```

The test scripts are diagnostic tools and stay **outside** the repository (project acceptance is
manual).

---

## 7. General lessons

* **"Works for the only case that exists" is not "is correct."** The dispatch was written when only
  Ryu existed; index 0 hid the stride error. When adding the second character, the first test must be
  precisely index 1.
* **`RTS` trick with a step-1 table supports only one entry.** If the table stores `address-1` and the
  index advances 1 byte, two entries require `ASL A` (index × 2) and a real table. Do not stack the
  second entry "in the middle" of the first.
* **`JAM` (`$02`) is a signature of diversion into the void.** PC repeating the same address, OAM
  frozen, and instruction count far above normal point to an `RTS`/`JMP` that fell outside code.
* **A `(PC, bank)` ring is worth more than a `breakpoint`.** It showed `$8FE8` (the `RTS`) and
  `$A492` (the `JAM`) in exact order, without guessing where to stop.
* **Sibling dispatches deserve the same audit.** There is another `RTS` trick at `$3F:E6E6`
  (`AiCharRoutine`), with **one** entry (`RyuAiThink-1`) indexed by `FighterChar,x` (the IA's own
  character). Today it is safe because the only AI is Ryu's (`x` always 0). If Ken AI ever exists,
  this is the first place to fix — for the same reason.

---

## 8. Files touched by this fix

| File | Change |
|---|---|
| `annotations/sf2ne.ann` | comment + `patch 00:8FE0 AD` and `patch 00:8FE4 AD` (fix) and `patch 3F:F828` (warning/QR skipped, temporary) |
| `src/bank_00.s` | generated: `lda D00_9148+1` / `lda D00_9148` (without `,y`) |
| `src/bank_3F.s` | generated: 18 `nop` in place of `farcall ScreenDisclaimer` |
| `docs/lessons.md` | this document |
| `README.md` | reference to this document |
| `build/sf2ne.nes` | canonical ROM with the fix |

Bank `$00` is the only Ryu code bank modified, and only in those two bytes.

---

## 9. References

* NESdev Wiki — [RTS Trick](https://www.nesdev.org/wiki/RTS_Trick): `target-1` entries, the `RTS` adds 1,
  and the launcher must be called by `JSR` (or be a tail-call) so the return is not lost.
* NESdev Wiki — [Jump table](https://www.nesdev.org/wiki/Jump_table): index × 2 for 16-bit address tables;
  *split tables* (lows/highs) indexed by the same `X`.
* NESdev Wiki — [6502 assembly optimisations](https://www.nesdev.org/wiki/6502_assembly_optimisations):
  section "Use Jump tables with RTS instruction instead of JMP indirect".

---

## 10. Appendix — what the `$3C`/`$3F`/`$20`/`$36`/`$3B`/`$37`/`$29`/`$2D`/`$01`/`$05`/`$00`/`$04` data naming batches taught

The data batches (33 labels from `$3C`, 15 from `$3F`, 30 from `$20`, 27 from `$36`, 35 from `$3B`,
17 from `$37`, 46 from `$29`, 14 from `$2D`, 38 from `$01`, 38 from `$05`, 31 from `$00` and 3 from
`$04`, see `tasks/DATA_NAMING_3C.md`, `tasks/DATA_NAMING_3F.md`, `tasks/DATA_NAMING_20.md`,
`tasks/DATA_NAMING_36.md`, `tasks/DATA_NAMING_3B.md`, `tasks/DATA_NAMING_37.md`,
`tasks/DATA_NAMING_29.md`, `tasks/DATA_NAMING_2D.md`, `tasks/DATA_NAMING_01.md`,
`tasks/DATA_NAMING_05.md`, `tasks/DATA_NAMING_00.md` and `tasks/DATA_NAMING_04.md`) did not change
bytes, but exposed these reading pitfalls:

* **Do not classify a bank by its address.** Initial triage treated `$29`/`$2D` as "AI" because they are
  near the engine; generated headers show they are **FamiTone2 music** (173 labels). Reading the header
  and the consumer before proposing a category costs less than redoing the inventory.
* **The canonical label metric is blind to comments on the same line.** The regex
  `^[A-Za-z_][A-Za-z0-9_]*:$` does not count `EdgeARel`, `EdgeBRel` and `EdgeBBtn` (in `$3F`), which have
  a comment after the colon. That is why the per-bank sum (1,037 semantic after `$36`) differs from the
  unique total published (1,033). When comparing metrics, always use the same command and record the
  difference.
* **"Per-character" tables have a fixed stride — confirm the stride in the consumer.** In `$3C`, fiches
  use 1 byte per character (10 bytes per table), while palettes use 12 bytes per character
  (`FighterChar*12`) and portrait tiles, 6. A `*Tbl` name is only safe after finding the multiplication
  in the code that reads the table; and `Lo`/`Hi` pairs should be named as a pair, because one of them
  may be read without `,y` (case of `CharDirTransHiTbl` at `3B:E025`).
* **Look for documentation before inferring from code.** In the `$3F` batch, `docs/FORMATS.md` §11/§15
  already described the knockback, fall/KO reaction, impact sfx and projectile tables with the same
  addresses. Reading the document first avoided guessing the semantics of `EF06`/`EF20` (knockback X/Y)
  and incidentally revealed several wrong sizes in the table index.
* **The generator appends the comment to the `.byte` line.** That is why a "per-line" diff accuses dozens
  of changes in data even when operands are identical. Correct verification compares the `.byte`/`.word`
  directives with the comment removed (or, simpler, trusts the ROM SHA-1).
* **Metasprite is not text: read the drawing sequence, not the graphic.** In `$20`, `85BE` draws digit
  "4" at `dx=0` and then "ROUND" at `dx=$10`, producing "4ROUND" instead of "ROUND 4" — a possible bug
  preserved as a curiosity. And `848B` is a 48×32 graphic block without readable text (MEDIUM confidence).
  When the metasprite does not form a phrase, the name should describe the **consumer routine**
  (`RoundEndDrawTieAltMetasprite`), not invent a caption.
* **A trace "read" can be fictitious.** In `$36`, `ram_03BC`–`ram_03BE` seemed to have 29 reads, but all
  of them came from the reset loop's `sta ram_0300,x` at `3F:FFC9`, which the tracer reports as a read of
  the absolute address. With no real consumer, `C005`/`C00A`/`C00F` stayed automatic: write-only is not
  evidence of meaning.
* **Decode the stream to find the band boundaries.** The `$36` RLE blocks only make sense after
  decompressing: 640/192/128 bytes map exactly to lines 0–19/20–25/26–29 of a 32×30 nametable. The three
  CHR switches in the screen-split IRQ line up with the same bands, which is what justifies
  `Top`/`Mid`/`Floor` in the names.
* **Check the nametable mirroring before naming "left/right".** `MMC5_NT_MAP = $44` gives vertical
  mirroring: `$2800` is the left nametable and `$2C00` the right one. Without reading the mapper value,
  the two identical 960-byte streams look like duplicates.
* **Do not "fix" a table quirk that the only used entry hides.** `C000`–`C00F` are indexed with
  `y = layout*2` although each table has 5 bytes; for layouts 3–4 that would read `$FF`. Only layout 0 has
  data, so behavior is the first byte. Naming documents the observed use; it does not repair the indexing.
* **The RLE count repeats the last literal — there is no value byte.** `PpuUnRle` (`3B:E3BE`) writes every
  byte that differs from the tag and keeps it as `RleLast`; on `tag,count` it repeats that last byte
  `count` times, and `tag,$00` ends the stream. A first decode pass that consumed an extra byte after the
  count gave 1,011/456/471/61 bytes for the `$3B` streams; the correct decode gives exactly 1,024
  (`VersusBgRle`) and 480+480+64 (`SelectBgTopRle`/`SelectBgBottomRle`/`SelectBgAttrRle`). Sanity-check a
  decoded size against the nametable/attribute geometry before naming the stream.
* **A table at `base+1` is a column, not a second array.** In `$37`, `D37_E0FA` is literally
  `FighterVoiceTbl+1`: `VoicePlayFighter` reads the sample at `FighterVoiceTbl,y` and the continuation at
  `FighterVoiceTbl+1,y`, with `y = FighterChar*16 + offset`. Naming it `FighterVoiceContTbl` is useful
  only if the comment says it is the odd column of the same 16-byte records; otherwise the next reader
  treats it as an independent table and may try to resize it.
* **Match engine tables against the upstream source before inventing names.** The `$37` bytes
  `$30,$70,$B0,$F0`, the 10×11 vibrato table and the three-byte dummy envelope match FamiTone2
  `duty_table`, `Vib_Table` and `_FT2DummyEnvelope` byte-for-byte in the public v1.12/v1.15 sources.
  That gives HIGH confidence without executing the ROM; the project still keeps its `_FT2`/`Table`
  spelling instead of copying the upstream identifiers.
* **A valid pointer does not prove an event name.** The ten sfx streams of `$37` are valid FamiTone2
  command sequences and are reachable from `StateClassSfxTbl`, `HitSfxTbl` and `EffectParam`, but the
  actual sound identity (hit, block, projectile, …) needs audio/runtime confirmation. They stayed
  automatic (P3); naming them `SfxStream0..9` would only restate the index, and naming them by event
  would assert more than the static evidence supports.
* **Read the instrument reader before trusting upstream FamiTone2 layout.** The public FamiTone2
  instruments start with a duty byte and carry three envelope pointers. In `$29` the game's
  `_FT2SetInstrument` (`37:EAA1`) indexes with `instrument*8`, has **no duty byte**, and reads four
  envelope pointers for pulse channels (three for triangle, first/second/fourth for noise). Naming the
  records from the upstream source would have produced wrong offsets. Read the local consumer, then
  compare.
* **A header field can be dead; check who overwrites it.** Each `$29` header has a DPCM list pointer at
  `+3/+4`, and `FamiToneInit` dutifully copies it to `FT_DPCM_LIST`. But `SoundLoadSong` immediately
  calls `SoundInitVoices`, whose `FtSetSampleTable` (`37:E47F`) overwrites `FT_DPCM_LIST` with
  `VoiceSampleTbl`. The field is unused, and because it points at `+1` it even creates four spurious
  labels one byte before the third envelope word (`A017`, `AACD`, `B361`, `B4D4`). Naming those words
  as real envelopes would duplicate `EnvZero`; they stayed automatic (P3).
* **A loop command can skip the channel label.** The Versus pulse 1 stream starts at `B36B` with a
  speed command, and its `$FD` loop targets `B36D` — the first note after the command, with no label of
  its own. Do not assume the loop target equals the channel start; decode the `$FD` word. In the same
  module, pulse 2, triangle, noise and DPCM *are* both start and loop target.
* **Do not generalize loop sharing from one module.** In `$29` Select two channels could reach the same
  `$FD` target through shared blocks, but in `$2D` all five targets are distinct and each is reached by
  exactly one channel. Check the `$FD` table per module instead of copying the previous batch's naming
  pattern.
* **Shared reference blocks are not owned by one channel.** The 53 `$FF <length> <word>` targets in
  `$29` are fragments reused by different channels and can be reached from several streams. Naming them
  `Ref0..52` would restate the index and break on reuse; they stayed automatic (P3). Only the
  structurally distinct anchors (header, instrument list, envelopes, channel starts, loop targets) were
  named.
* **State-table roles come from the fiche, not from the bank order.** The eight pointer tables at
  `$01:A000`–`$A086` are named by the fiche slots that copy them (`CharDirTrans`, `CharAttackTrans`,
  `CharSpecialTrans`, `CharGuardReact`, `CharHitReact1/2/0/12`). Reading the bank alone cannot tell the
  standing reaction from the crouching one; `docs/FORMATS.md` §1 and §2 fix the order.
* **A direction entry is a chain head, not a pose.** `$A0F6` (neutral) starts with `CondRoundLost` and
  `$A3D5` (back) with `CondOpponentAttacks`; naming them by the pose they eventually reach would be wrong.
  They were named `RyuDir*Entry`, with the `InputDir` value in the comment.
* **Verify chain order in ROM, not from the class byte.** The button chains in `$A012` are linked by the
  `+1` alternative pointers; checking them confirmed the order documented in `docs/FORMATS.md` §13
  (airborne → down → default, etc.). A class byte alone does not say whether a node is the first or the
  last test.
* **One direction entry can be shared.** `$A373` is referenced twice in `$A000` (down `$08` and
  down-forward `$0B`), so it receives one name and the comment lists both values.
* **A hand-written bank mirrors names, not generated labels.** `$05` is declared `keepbank 05`, so
  `make gen` never rewrites `src/bank_05.s`; `label` lines in the `.ann` would not apply and the file
  must be edited directly. The mirror is evidence-based only after confirming that the assembled `$01`
  and `$05` tables and state headers are byte-identical; the fiche comments in `$3C` still come from the
  `.ann`, because that file is generated.
* **Weak/strong special names depend on the command list.** `RyuSpcTrans` is indexed by `CmdMoveIdx`, and
  `CmdKeyListRyu` uses kick strength for hadouken/shoryuken and punch strength for tatsumaki. Naming the
  six states without reading `CmdKeyAttackTbl` would invert weak and strong.
* **A label inside a table can be a view, not a second table.** In `$00`, `$90EE`/`$90F2` are entry 1 of
  the 4-entry arrays at `$90ED`/`$90F1`, used by the distance/16 branch with `y = 0–1`. Naming them
  `...MidLoTbl`/`...MidHiTbl` is useful only because the comment says they are the same bytes; otherwise
  the next reader may try to resize or duplicate the array.
* **Decode the index arithmetic before claiming an entry is reachable.** `$913C` has 4 entries but
  `(Random & 7) >> 2` yields only 0–1; `$9144` has 2 entries but the `Now` branch shifts twice after
  testing bit 0, so `y` is always 0. Trace coverage (`[idx $00..$00]`) alone is weak evidence; the shift
  sequence is the proof.
* **Dead bytes after `$FF` are not scripts.** `$8EB4`–`$8EC9` and `$8F43`–`$8F45` look like valid
  bytecode but nothing points at them. They stayed automatic and unlabelled; the `$FF` terminator is not
  a guarantee that the next byte starts a new entry.
* **Byte-identical scripts need the consumer as tie-breaker.** `$8EAD` and `$8F0A` are the same seven
  bytes (`80 09 88 04 80 04 FF`); one is the jump-forward idle script, the other the jump-in branch.
  Naming by bytes alone would merge them.
* **A pre-existing code label can be wrong.** `RyuAiAirAttack` (`$91BA`) starts `$8F24`, which is
  `$83 FF` = defend. Code naming was out of scope, so the label stayed, but the comment now says it starts
  `RyuAiScriptDefend`; do not inherit an old name as evidence.
* **Translation can desynchronize the generator.** After `fa7c215`, `annotations/sf2ne.ann` was in English
  while the committed `src/*.s` still carried the pre-translation Portuguese comments and `tools/disasm.py`
  still emitted Portuguese headers/auto-comments. Running `make gen` mixed translation with naming. This
  was resolved in the regeneration commit: the generator strings were translated to English, `make gen` was
  rerun, and the diff was reviewed as comments/assert messages only plus five condition-label renames
  (`CondEmPe`→`CondStanding`, `CondAgachado`→`CondCrouching`, `CondNoAr`→`CondInAir`,
  `CondInputBaixo`→`CondInputDown`, `CondProjetilLivre`→`CondProjectileFree`). SHA-1 stayed
  `3ad177a0…` and `src/bank_05.s` (hand-written) was untouched.
* **One byte can separate a stub from real data.** In `$04`, the fiche's AI table (`$90E0`) points eight
  times to `$90F0`, a single `$FF` terminator: the stub script for this delivery's Ryu-only CPU. `$90F1`,
  the very next byte, is the **defeat portrait layout** reached from `PortraitLoseLayoutTbl` (`3C:84BC`).
  Naming by proximity would have merged two unrelated structures; the first byte plus the consumer
  (`$90E0` vs `3C:84BC`) is what separates them.
* **A "copy to free space" patch can make the original address ambiguous.** Ken's normal win layout
  `$8A59` is also the source of the `$90F1` defeat copy. The label `KenWinPortraitLayout` documents the
  original role; the `$90F1` comment must say it is a copy with an extra empty group, or the next reader
  will "deduplicate" the two and reintroduce the 255-iteration portrait overflow.

**Practical rule:** for each batch, (1) read the consumer, (2) propose name + confidence, (3) apply only
labels/comments, (4) run `make gen` from the canonical `.ann` (or validate in a scratch copy), then run
`make` and compare the SHA-1, (5) confirm that no `.byte`/`.word` operand changed. The SHA-1 is the proof
that naming is cosmetic.
