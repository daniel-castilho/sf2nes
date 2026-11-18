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

## 10. Appendix — what the `$3C`/`$3F`/`$20`/`$36` data naming batches taught

The data batches (33 labels from `$3C`, 15 from `$3F`, 30 from `$20` and 27 from `$36`, see
`tasks/DATA_NAMING_3C.md`, `tasks/DATA_NAMING_3F.md`, `tasks/DATA_NAMING_20.md` and
`tasks/DATA_NAMING_36.md`) did not change bytes, but exposed these reading pitfalls:

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
* **Translation can desynchronize the generator.** After `fa7c215`, `make gen` rewrites file headers back
  to Portuguese because `tools/disasm.py` still contains the old strings. The label/comment body comes from
  the translated annotations, and ROM bytes do not change; the header-only diff must be discarded instead
  of committed.

**Practical rule:** for each batch, (1) read the consumer, (2) propose name + confidence, (3) apply only
labels/comments, (4) validate with `make gen`, `make` and identical SHA-1, (5) confirm that no `.byte`/
`.word` operand changed. The SHA-1 is the proof that naming is cosmetic.
