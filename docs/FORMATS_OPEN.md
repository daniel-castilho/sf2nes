# Open format notes — collision boxes, AI bytecode, transition conditions

**Status:** static analysis of the generated sources and the ROM bytes; **no emulator execution**. This
document complements `docs/FORMATS.md` §4, §5, §10 and §14 and records the details that were still
implicit there. `(nt)` marks a path the trace never executed; it is read from code only.

Addresses are `BB:AAAA` (bank + CPU address). `FighterX`, `FighterY`, `FighterState`, `ProjX`, `ProjFlags`
and `AiScriptPtr*` are **two-byte arrays indexed by fighter**, not 16-bit words: `FighterX+1` is the
opponent's X, not the high byte of X.

---

## 1. Collision boxes (collision bank)

### 1.1 Where the record lives

The animation frame stores a word at **+3/+4** (`LoadHitBoxes`, `3F:EBA5`). The frame itself lives in the
**state bank**; the loader maps the **collision bank** (`zp_1C,x`, loaded from `CharHitBoxBankTbl`) at
`$8000` and the state bank at `$A000`, then reads the record through the frame's +3/+4 pointer. For the two
current characters the collision bank equals the frame bank (`$00` Ryu, `$04` Ken), but it is a separate
fiche field.

* The word is treated as a pointer only when its **high byte is nonzero**. If the high byte is `0`, all 12
  box bounds are zeroed and no record is read. This is why frames without collision use `00 00` rather
  than a pointer to a zero record.
* Body boxes are never clamped. Only the **far edge of the attack box** is clamped (§1.3).

### 1.2 Variable-length record (three boxes, not always 12 bytes)

The record is a sequence of three boxes — **body 1, body 2, attack** — each `[height][dy][dx][width]`.
A box with `height = 0` is absent and consumes **only its height byte**. A present box consumes 4 bytes.
The sequence is therefore 3–12 bytes; Ryu's 269 reachable frames use only 6, 9 and 12 bytes.

| body 1 | body 2 | attack | length | Ryu frames |
|--------|--------|--------|--------|------------|
| present | present | absent | 9 | 118 |
| present | absent | absent | 6 | 76 |
| present | absent | present | 9 | 14 |
| absent | absent | present | 6 | 5 |
| absent | present | absent | 6 | 2 |
| present | present | present | 12 | 11 |
| *(no pointer: high byte 0)* | — | — | — | 43 |

Consequences for readers:

* An absent box is **one byte**, not four. A fixed 12-byte reading shifts every later box and invents
  huge heights (e.g. `$FE`).
* Body 2 can exist without body 1 (2 frames) and body 1 without body 2 (90 frames). Both are body boxes;
  body 2 is not a projectile-only box.
* The `attack` box is present in only **30** of the 269 reachable frames; 43 frames have no record at all.

Example — `D00_93FB` (`00 00 21 CF 03 1A`, 6 bytes): body 1 and body 2 absent, attack `h=$21` (33),
`dy=$CF` (−49), `dx=$03`, `w=$1A` (26). The 12-byte example in `docs/FORMATS.md` §10 (`D00_9356`) is the
all-present case.

### 1.3 Geometry

With `FighterX` / `FighterY` (the fighter's own byte) and signed `dy`/`dx`:

| Edge | Unflipped (`FighterFlip = 0`) | Mirrored (`FighterFlip ≠ 0`) |
|------|-------------------------------|------------------------------|
| top | `Y + dy` | `Y + dy` |
| bottom | `top + height` | `top + height` |
| left | `X + dx` | `right − width` |
| right | `left + width` | `X − dx` |

Attack-box clamp:

* unflipped: `right` is capped at `$E0` when `left + width` overflows 8 bits;
* mirrored: `left` is floored at `$20` when `right − width` borrows.

The **near edge is not clamped** and the body boxes are not clamped at all. "Never leaves the screen" in
`docs/FORMATS.md` is stronger than the code.

### 1.4 Consumers

* **Melee** (`HitTest`, `3F:ECF1`): requires `HitThisFrame = 0`, `AttackHitsLeft > 0` and `AtkR ≠ 0`;
  tests the attack AABB against body 1, then against body 2. A hit consumes one `AttackHitsLeft`, sets
  `HitThisFrame`, copies the attacker's full `EffectType` to the victim's `HitReactClass`, and calls the
  damage routine.
* **Projectile** (`ProjHitTest`, `3F:E8F1`): requires `ProjX ≠ 0` and `ProjFlags` bit 7 clear; tests the
  projectile box `X−$0B…X+$0C` / `Y−$0B…Y+$0C` against body 1, then body 2. On hit it kills the projectile
  and applies reaction `$CB` with damage `$6C`.
* **Shove/overlap** does not use these boxes: it uses `|ΔX| < $10` and `|ΔY| < $21` (with both movement
  modes even), then clamps X to `$20`–`$E0` (`3F:F543`, `3F:F5CD`).

### 1.5 Census (Ryu, 269 reachable frames)

| Box | Present | Height | `dy` | `dx` | Width |
|-----|---------|--------|------|------|-------|
| body 1 | 219 | 10–68 | −72…−29 | −24…11 | 12–27 |
| body 2 | 131 | 15–54 | −73…−16 | −20…14 | 16–38 |
| attack | 30 | 10–60 | −86…−16 | −32…15 | 15–52 |

### 1.6 Open points

* The **intent** of body 1 vs body 2 is not proven. Both are tested identically; the data suggests a main
  body plus an alternate/extended box, but no consumer distinguishes them.
* No record with all three boxes absent (3 bytes) was observed; the game uses the null pointer instead.
* The clamp is static-only; no runtime test checked corner behaviour of the attack box.

---

## 2. AI bytecode

### 2.1 Two levels and the bank window

* `AiUpdate` (`3F:E7D2`) maps `FighterFrameBank,x` at `$8000` and calls the character thinker through
  `AiCharRoutine` (`3F:E6E6`, one word per character — only Ryu exists). For Ryu the thinker is
  `RyuAiThink` (`00:8F46`), so **AI code and scripts live in the frame bank**.
* The thinker chooses a script pointer and stores it in `AiScriptPtrLo/Hi` (`$69/$6B`, per fighter).
* `AiDefaultGuard` (`3F:E74C`) runs before the interpreter: in neutral (class `< $50`, frame flags `& 7 = 0`)
  it holds back/down-back and skips the script for that frame.
* When a script ends (`$FF`), `zp_71 = 0`. On the next **neutral** frame (`FrameFlags & 7 = 0`), `SoundEffect`
  (`3F:E7AF`) draws a new script from the character's AI table (fiche slot 9, `ram_0342/0344`) with
  `Random & 7`; on a non-neutral frame `Defend` calls the character thinker instead.

### 2.2 Interpreter loop

`AiScriptLoop` (`3F:E7E7`):

1. Read the byte at the script pointer.
2. `$FF` → end the script (`zp_71 = 0`) and return.
3. Otherwise mask `& $7F` → opcode index `0–$7F`, stored in `zp_D9`. Ryu data only uses `$80`–`$91`
   (index `0–$11`); values `$92`–`$FE` would index past the 18-entry dispatch table.
4. **Copy every following byte `< $80`** to `zp_6D`, `zp_6E`, … (`AiScriptCopyArgs`, `3F:E7FE`). The first
   byte `≥ $80` is the next opcode.
5. Advance the script pointer by the number of operand bytes and dispatch through `AiOpLo/Hi`
   (`3F:E6C2`/`$E6D4`, address−1).
6. The interpreter tests the **Z flag**, not `A`: Z set (usually `A = 0`, but also a `cmp` equality) passes.
   On a pass, continue with the next opcode in the same frame. On a failure (Z clear) with opcode index
   `≥ 7` (a test, `$87`–`$91`), return and retry the same opcode next frame. Actions (`$80`–`$86`) always
   continue.

Two consequences:

* **Tests pass when the Z flag is set** — normally `A = 0`, the opposite of state conditions (§3), which
  pass when nonzero. `$8C` is the exception: it can return `A = $10` with Z set.
* **There is no per-opcode operand count.** Operands are delimited by the next opcode. The operand
  registers persist, so an opcode with no operand silently reuses the previous value. Ryu's data relies
  on this: `82 00 82 89` means "special 0, special 0 again, wait idle", and `82 01 82 8B 82 01 82 89`
  reuses `$01` in the middle. A missing operand is not an error in the format.

### 2.3 Opcode reference

`AiOpLo/Hi` has 18 entries (`$80`–`$91`). Operands below are `op0`, `op1`; `A` is the return value.

| Opcode | Routine | Operands | Effect / test |
|--------|---------|----------|---------------|
| `$80` | `AiOp00` | dir | `InputDir = dir`; `InputAttack = $FF`; `CmdMoveIdx = $FF` |
| `$81` | `AiOp01` | dir, atk | `InputDir = dir`; `InputAttack = atk`; `CmdMoveIdx = $FF` |
| `$82` | `AiOp02` | move | `InputDir = $04`; `InputAttack = $FF`; `CmdMoveIdx = move` |
| `$83` | `AiOp03` | — | `InputAttack = $FF`; `CmdMoveIdx = $FF`; `InputDir = $06`, or `$0C` if opponent class bit 1 (crouching) is set |
| `$84` | `AiOp04` | n | `zp_6F,x = n` (delay/counter setup) |
| `$85` | `AiOp05` | zpaddr | `zp_6E = 0`; `zp_6F,x = byte at $00:zpaddr + x`. Ryu uses `85 08` to snapshot `FighterX,x`. |
| `$86` | `AiOp06` | — | `inc zp_6F` — **global**, not `zp_6F,x`; unused in Ryu scripts, probably a bug `(nt)` |
| `$87` | `AiOp07` | n | `A = (FighterState >> 3) − n`; pass when `state >> 3 = n` |
| `$88` | `AiOp08` | mask | `A = (FighterState & mask) − mask`; pass when all mask bits are set |
| `$89` | `AiOp09` | — | `A = (FighterState & $58) − $58`; pass in the `$58` family |
| `$8A` | `AiOp0A` | — | `A = 0` if `class & $F8` is `$B0`–`$E0`, else `1`; pass while in a move `(nt)` |
| `$8B` | `AiOp0B` | — | `A = ProjX,x`; pass when no projectile is in the air |
| `$8C` | `AiOp0C` | n | pass at screen edge (`FighterX < $21` or `≥ $E0`), or when `\|FighterX − zp_6F,x\| ≥ n`; see §2.4 `(nt)` |
| `$8D` | `AiOp0D` | — | `zp_6F,x--`; pass when it becomes zero `(nt)` |
| `$8E` | `AiOp0E` | n | `A = 1` if `\|ΔX\| ≥ n`, else `0`; pass when `\|ΔX\| < n` |
| `$8F` | `AiOp0F` | n | `A = 1` if `\|ΔX\| < n`, else `0`; pass when `\|ΔX\| ≥ n` |
| `$90` | `AiOp10` | n | `A = (opponent state >> 3) − n`; pass when equal |
| `$91` | `AiOp11` | — | `A = zp_73,x`; pass when zero `(nt)` |

Ryu opcode census (**19 reachable scripts**, `00:8E82`–`$8F45`): 82 opcodes total — `$80`×26, `$81`×10,
`$82`×10, `$83`×1, `$85`×2, `$87`×10, `$88`×4, `$89`×11, `$8B`×3, `$8C`×2, `$8E`×1, `$8F`×1, `$90`×1.
`$84`, `$86`, `$8A`, `$8D` and `$91` do not appear in Ryu's reachable data. The script at `$8EAD` ends at
`$8EB3` (7 bytes, first `$FF`); the same `.byte` line in `src/bank_00.s` continues with 22 more bytes at
`$8EB4` that look like two scripts (`84 78 8D` delays), but no table or immediate points there. The
`$84`/`$8D` delay in `docs/FORMATS.md` §14 therefore describes the format, not data the CPU executes.

### 2.4 `$8C` in detail

`AiOp0C` (`3F:E65C`) implements "walked far enough from a stored X, or reached the edge":

```
if FighterX < $21 or FighterX >= $E0: return 0 (pass)
d = |FighterX - zp_6F,x|
if d != 0:
    return 0 if d >= op0, else d (fail)
else:
    return |opponentX - FighterX| after cmp #$10
```

The zero-displacement branch returns the **zero flag of a comparison with `$10`**, so it passes only when
the opponent is exactly 16 px away. In practice the first frame after `85 08` hits this branch, then the
fighter moves and the normal `d >= op0` path takes over. Treat the exact-16 rule as an observed quirk,
not as intended semantics.

### 2.5 Variables

| Variable | Role |
|----------|------|
| `AiScriptPtrLo/Hi` (`$69/$6B`, indexed `x`) | current script pointer per fighter |
| `zp_6D`, `zp_6E` | operand registers; shared and persistent |
| `zp_6F,x` | per-fighter scratch: stored X (`$85`/`$8C`) or delay counter (`$84`/`$8D`, unused in Ryu data) |
| `zp_71,x` | script phase: `0` = no script (thinker picks one); `$40`/`$80` = script active (copied from `zp_DD` by `AttackStart`); bit 7 (`$80`) suppresses the character routine in `Defend` |
| `zp_73,x` | opponent state snapshot used by the defend routine |
| `zp_75,x` | defend countdown |
| `zp_D7/D8` | script read pointer |
| `zp_D9` | current opcode index (`0–$11`) |
| `zp_DA/DB` | AI table pointer |
| `zp_DD` | start mode: `$40` = always start (`AiStartScriptNow`), `$80` = hesitate (`AiStartScript`) |
| `AiLevel` | fixed at 7; `AiStartScriptCheck` compares `Random & 7` with it (7/8 chance to start) |

### 2.6 Open points

* `$8C`'s exact-16 branch looks like a latent bug; no runtime test confirmed its role.
* `$86` increments the global `zp_6F` instead of `zp_6F,x`; it is unused in Ryu data.
* `$84`/`$8D` are defined but unused in Ryu's reachable scripts; the `84 78 8D` block at `$8EB4` is
  unreferenced.
* Opcode bytes `$92`–`$FE` would index past the 18-entry table; Ryu data only uses `$80`–`$91`.
* Operand persistence is inferred from the interpreter and from scripts that reuse values; no script was
  observed deliberately reusing a stale operand across a new script boundary.
* Only Ryu has a thinker entry in `AiCharRoutine`; the format is ready for another character but no
  second entry exists.

---

## 3. Transition conditions

### 3.1 Return convention

`StateCondDispatch` (`3F:E168`) indexes `StateCondLo/Hi` (`3F:E171`/`$E17D`, 12 entries, address−1) with
the header condition byte. The walker (`StateCheckTransitions`, `3F:E0CE`) treats **nonzero as true**:

```
lda (node),y        ; +0
bmi TransApply      ; $80–$FF = unconditional
tay
jsr StateCondDispatch
bne TransApply      ; nonzero = true
jmp TransNextNode   ; zero = false
```

This is the **opposite** of AI tests (§2.2). Conditions are not required to return `1`: any nonzero value
is true, and some return their argument (e.g. `CondInputDown` returns `InputDir`).

Values `$0C`–`$7F` have no table entry and the walker performs **no range check**; they would index past
the 12-word table. Ryu data only uses `$00`–`$0B` and `≥ $80`.

### 3.2 Condition table

| # | Routine | Returns (true when nonzero) | Notes |
|---|---------|-----------------------------|-------|
| `$00` | `CondOpponentAttacks` (`E189`) | `1` if opponent class `& $F8` is `$70`–`$98` or `$B0`–`$E0`; otherwise opponent `ProjX` | Own class `& 3` must be nonzero (standing/crouching); a projectile makes it true even without an attack state |
| `$01` | `CondOpponentFarBack` (`E1B1`) | `0` if `ΔX = 0` or `\|ΔX\| < $0F`; else `FighterFlip` (own X < opponent X) or `FighterFlip ^ $40` | Nonzero means "back turned and far"; the walker uses it to skip nodes, the re-face logic uses the value as the turn bit |
| `$02` | `CondOpponentNear` (`E1D6`) | `1` if `ΔX = 0`; else `\|ΔX\|` if `< $21`, else `0` | Special case for exactly equal X |
| `$03` | `CondStanding` (`E1ED`) | `FighterState & $01` | Posture bit 0 |
| `$04` | `CondCrouching` (`E1F3`) | `FighterState & $02` | Posture bit 1 |
| `$05` | `CondInAir` (`E1F9`) | `FloorY − FighterY` if non-negative, else `0` | True when `FighterY < FloorY`; exactly on the floor is false |
| `$06` | `CondOnGroundOrVelX` (`E204`) | `FloorY` if `FloorY = FighterY`; else `VelX \| VelXSub` | True on the ground (returns nonzero `FloorY`) or while sliding |
| `$07` | `CondInputDown` (`E212`) | `InputDir` if `$08`/`$0B`/`$0C`, else `0` | Sets `Y = InputDir` as a side effect |
| `$08` | `CondProjectileFree` (`E224`) | `1` if `ProjX,x = 0`, else `0` | Own slot |
| `$09` | `CondCanGrab` (`E22E`) | `1`/`0` | `\|ΔX\| < $18`; `FloorY = FighterY` and `FloorY = FighterY+1` (both on ground); `InputDir` `$05`/`$06`; opponent class `& $F8` `< $30`, `$50`–`$9F`, or `≥ $A9` |
| `$0A` | `CondVictory` (`E271`) | `1`/`0` | `RoundResult = x`; opponent class `≥ $F0`; `ProjX` and `ProjX+1` zero; `SND_CHN` bit 4 clear |
| `$0B` | `CondRoundLost` (`E296`) | `1`/`0` | `RoundResult ≠ x` and `RoundResult` not negative (`$FF` is false for both fighters) |

Quirks worth keeping in mind:

* `CondCanGrab` returns **true for opponent class `≥ $A9`** (the `$A9` compare is marked `(nt)`), not just
  `< $30` or `$50`–`$9F`. The excluded blocks are `$30`–`$4F` (reaction) and `$A0`–`$A8` (turn).
* `CondVictory` depends on the hardware `SND_CHN` bit 4 (voice channel busy), so it is not purely game-state.
* `CondOpponentAttacks` reads the **opponent's** `ProjX`, not its own.
* `CondOnGroundOrVelX` returns `FloorY` (usually nonzero) when grounded; do not test for `1`.

### 3.3 Walker pre-filters

`StateCheckTransitions` receives the node in `zp_DB/DC` and the origin in `zp_DD`:

1. **Guard/damage origin (`zp_DD = $04`)**: if current class `& $F8` is `$28` or `$30`, test the node even
   if it is the current state; otherwise a node equal to the current state pointer is skipped via
   `+1/+2`.
2. **Button origin (`zp_DD = $02`)**: during a move (class `& $F8` in `$70`–`$98`), only the current state
   node passes; any other node is skipped.
3. **Behind check**: if the current class does **not** have bit 2 (airborne), `CondOpponentFarBack` is
   evaluated; a nonzero result skips the node (the fighter does not react from behind).
4. Test the node: `+0 ≥ $80` applies immediately; otherwise dispatch the condition; true applies, false
   follows `+1/+2`.
5. `+1/+2 = 0` ends the list and changes nothing.

`TransApply` (`3F:E13B`) writes `FighterNextPtr` and may force `AnimTimer = 1`:

* if the current frame has **flag bit 3 (`$08`)**, always force `AnimTimer = 1`;
* otherwise force it only for node classes `$28`–`$40` and `$B0`–`$E0`.

> **Correction to `docs/FORMATS.md` §5/§6.** Bit 3 does **not** mean "do not force". The code branches
> to `TransAnimTimerSet` when the bit is set, so bit 3 means **force an immediate transition**. The data
> confirms it: 33 frames carry the bit (`fl=$0A`×15, `$0E`×1, `$0F`×5, `$1F`×12), all in guard
> (`$29`/`$2A`), standing (`$59`/`$5A`), walk (`$61`/`$69`) and jump (`$5C`/`$64`/`$6C`) states, with
> durations from 3 to 100. In those states an accepted attack is not delayed by the rest of the frame.

### 3.4 Commit in `AnimAdvance`

`AnimAdvance` (`3F:E2A6`):

1. If `EffectType = $0B`, fire the projectile.
2. If `FighterNextPtrHi ≠ 0`:
   * if the current class is `$49` and `zp_62 ≠ 0` (knocked down), replace the next pointer with the
     current state's `+1/+2` alternative;
   * set `FighterStatePtr`, first frame `state + 7`, class through `StateSetByte`, `AttackHitsLeft = +6`,
     then enter the frame.
3. Otherwise restore hit-freeze and advance the animation.
4. At the end of the animation, `StateAdvance` (`3F:E371`) follows the natural chain `+3/+4`; class `$30`
   with `HP < 0` (signed) or `HP < DmgPending` follows the alternative `+1/+2` instead (death branch).

### 3.5 Open points

* No runtime test checked the exact `zp_DD = $02` pre-filter on a move that accepts both a button and a
  special.
* `CondCanGrab`'s `≥ $A9` branch and the `$A9` compare are marked `(nt)`; the static reading is clear but
  not exercised.
* Conditions have no documented contract for clobbering `A`, `X` or `Y`; the walker only relies on the
  final zero flag, and `CondInputDown` intentionally leaves `Y = InputDir`.

---

## 4. Remaining gaps

| Area | What is still missing | Evidence needed |
|------|-----------------------|-----------------|
| Collision | intent of body 1 vs body 2; all-absent record; corner clamp | runtime trace of `HitTest`/`ProjHitTest` |
| AI | `$8C` exact-16 branch; `$86` global increment; stale-operand reuse across scripts | runtime trace of a walk script and a jump/delay script |
| AI | no second `AiCharRoutine` entry | data for another character |
| Conditions | `$0C`–`$7F` are unchecked; `CondCanGrab ≥ $A9`; `CondVictory` hardware bit | trace of guard/grab/victory paths |
| Conditions | side-effect contract (`A`/`X`/`Y`) | code audit of every condition caller |
