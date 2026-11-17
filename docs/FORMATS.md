# Data formats — Street Fighter II NE (DEMO, Parisoft)

Field-by-field reference of the data driving the fight engine: character fiche, states, animations, sprites, collision, damage, commands and AI. This is Step 1 of the roadmap (`docs/ROADMAP.md`): every table here was read from disassembled code and checked against ROM bytes. Where reading is not guaranteed it is marked **(hypothesis)**; code no trace executed is marked **(nt)**. The overview of how pieces fit together is in `docs/ARCHITECTURE.md` §4.

Conventions:

* `BB:AAAA` = 8 KB PRG bank + CPU address. 16-bit pointers are little-endian (lo first). Signed bytes: `$80`–`$FF` are negative.
* **Frame bank** = the one mapped at `$8000` by `FighterFrameBank` (`$00` for Ryu): metasprites and collision boxes. **State bank** = the one mapped at `$A000` by `FighterStateBank` (`$01` for Ryu): states and animation frames.
* Everything is **per fighter**: X = 0 (P1) or 1 (P2) indexes `Fighter*` variables and table copies in `ram_03xx`.
* Census numbers (71 states / 274 frames for Ryu) come from the generator (`make gen`); per-field statistics come from `tools/frame_census.py`, which only sees the **269 reachable frames** (the 5 orphans of §2 are excluded) — so section totals below give 269.

Summary: §1 fiche · §2 state bank · §3 state header · §4 conditions · §5 transition walker · §6 frame · §7 effects · §8 movement · §9 metasprite · §10 collision · §11 hit and damage · §12 projectile · §13 commands · §14 AI · §15 auxiliary table index.

---------------------------------------------------------------------------------------------------

## 1. Character fiche (bank `$3C`)

`FighterLoadChar` (`3B:E000`) loads column `FighterChar` of each fighter: **10 table pairs** (one lo byte table, one hi byte table, with 10 positions each — one per character) pointing to state bank tables, plus 3 standalone byte tables. Everything becomes per-fighter copies in RAM (`ram_031E`–`ram_0344`), read by the engine without touching bank `$3C` again.

| Pair in bank `$3C` | Copied to | Pointed table | Role |
|--------------------|-----------|---------------|------|
| `$8000`/`$800A` | `ram_031E` | `$A000` | states by **direction** (9 entries) |
| `$8014`/`$801E` | `ram_0322` | `$A012` | states by **button** (4) |
| `$8028`/`$8032` | `ram_0326` | `$A01A` (`RyuSpcTrans`) | **special moves** (6 for Ryu) |
| `$803C`/`$8046` | `ram_032A` | `$A026` | **guards** (12) |
| `$8050`/`$805A` | `ram_032E` | `$A03E` | **standing** damage reaction (12) |
| `$8064`/`$806E` | `ram_0336` | `$A056` | **crouching** damage reaction (12) |
| `$8078`/`$8082` | `ram_0332` | `$A06E` | **neutral** damage reaction (12) |
| `$808C`/`$8096` | `ram_033A` | `$A086` | **throws** (12) |
| `$80A0`/`$80AA` | `ram_033E` | outside state bank | recognizer special list (`CmdKeyListRyu`, `3F:E0C0`) |
| `$80B4`/`$80BE` | `ram_0342` | outside state bank | AI script table (`00:8E72`) |

| Byte table | Copied to | Role |
|------------|-----------|------|
| `$80C8` `CharStateBankTbl` | `FighterStateBank` | state bank (window `$A000`) |
| `$80D2` `CharFrameBankTbl` | `FighterFrameBank` | frame bank (window `$8000`) |
| `$80DC` | `zp_1C` | collision box bank (window `$8000`, same value as frame bank) |

Detail: the hi byte of the 1st pair is read **without index** (`lda $800A`). It works because every state bank is mapped at `$A000`, so the hi byte is always `$A0` — a new character just needs to keep its tables at `$A000`–`$BFFF` of its bank.

Ryu column (id 0): states in bank `$01`, frames/collision in `$00`, special list `3F:E0C0`, AI scripts `00:8E72`. Only column 0 is filled.

`FighterRoundInit` (`3B:E098`) starts the round: P1 spawns at X=`$5A`, P2 at X=`$A6`, both Y=`$CD` (ground), full HP `$58` (88); P2 spawns mirrored (`FighterFlip=$40`). Initial state is the target of the **natural chain** (+3/+4) of the 1st state in the direction table (neutral), with class `$59` hardcoded.

## 2. State bank layout

The state bank is a stack of words followed by a sequence of records. For Ryu (`$01`):

1. **8 pointer tables**, consecutive words (`lo,hi`), entries `$0000` = empty:
   `$A000` (9), `$A012` (4), `$A01A` (6), `$A026` (12), `$A03E` (12), `$A056` (12), `$A06E` (12), `$A086` (12) — role and index of each one in §1 table and §13.
2. padding `$00` until `$A0AF`;
3. **records** from `$A0B0` to `$B1C6`: 7-byte state headers (§3), each followed by its animation frames (§6). The first frame of a state lives at `header + 7`.

Ryu census: **71 states, 274 frames**. Three records have no known pointer pointing at them (generator marks with `[no known pointer points to this]`): states `$A388` (class `$59`) and `$A432` (class `$29`) and frame `$B02D` (skipped by frame chain, which goes directly to `$B03B`) — dead data left by the demo author.

## 3. State header — 7 bytes

| Offset | Field | Content |
|--------|-------|---------|
| +0 | condition | `$00`–`$0B` (§4); `≥ $80` (in practice `$FF`) = unconditional |
| +1, +2 | alternative | pointer to next node to test if this condition fails; `0` = end of list |
| +3, +4 | natural chain | pointer to next state when this one ends (`StateAdvance`) |
| +5 | class | byte written to `FighterState` on entering state (families below) |
| +6 | hits | `AttackHitsLeft`: how many attack boxes this state can still land (0, 1, 2 or 6 in real data; 6 = tatsumaki) |

Class families (+5) — high part chooses sound and behavior, low 3 bits are posture (bit 0 = standing, bit 1 = crouching, bit 2 = airborne **(hypothesis)**; in favor: jumps `$5C`/`$64`/`$6C`, aerial attacks `$74`/`$84`/`$8C`/`$9C` and reaction `$34` have the bit; against: `$9C` also covers strong punch on ground):

| Range | Meaning |
|-------|---------|
| `$29`/`$2A` | standing/crouching guard (`GuardRedirect`, chip test) |
| `$30`–`$39` | damage reaction; `$30`: if HP ≤ pending damage, uses alternative +1/+2 (death) |
| `$49` | special case: with `zp_62≠0` (knocked down) uses alternative +1/+2 (`AnimAdvance`) |
| `$4C`, `$51` | seen 1× each, undeciphered semantics (Phase 2) |
| `$58`–`$6F` | accepts direction input (§13); `$59` = standing (initial state, hardcoded at round init), `$61` = walk, `$5C`/`$64`/`$6C` = jumps |
| `$70`–`$98` | plays sound effect on entry (`StateSetByte`); move in progress |
| `$99`–`$9F` | same, no sound |
| `$A0`–`$E0` | plays fighter voice on entry; `$A0`–`$A9` = turn (back input turns opponent = throw) |
| `$F0`+ | fallen (`CondVitoria` checks `≥ $F0`) |

Ryu special moves (reference): hadouken `$B1`/`$B9` (damage from projectile, 0 hits), shoryuken `$C4`/`$CC` (2 hits), tatsumaki `$D4`/`$DC` (6 hits).

Real census of 39 classes (71 states): `29`×5 `2A`×5 `30`×2 `31`×8 `32`×4 `34`×4 `39`×1 `49`×1 `4C`×1 `51`×1 `59`×5 `5A`×3 `5C`×1 `61`×1 `64`×1 `69`×1 `6C`×1 `71`×2 `72`×1 `74`×1 `81`×2 `82`×1 `84`×1 `89`×1 `8A`×1 `8C`×1 `99`×2 `9A`×1 `9C`×2 `A1`×1 `B1`×1 `B9`×1 `C4`×1 `CC`×1 `D4`×1 `DC`×1 `E9`×1 `F0`×1 `F1`×1. Conditions: 27 nodes with condition, 44 unconditional (`$FF`); hits (+6): 0×50, 1×16, 2×3, 6×2.

Real example (1st state in bank, victory pose):

```
D01_A0B0:   ; cond=$0A CondVitoria | class=$E9 | hits=0
    .byte $0A          ; +0  victory
    .word D01_A10B     ; +1/+2 alternative
    .word D01_A12E     ; +3/+4 natural chain
    .byte $E9          ; +5  class (voice on entry, fallen)
    .byte $00          ; +6  hits
    ; first frame at $A0B7...
```

## 4. The 12 conditions

The +0 header byte dispatches via `StateCondDispatch` (`3F:E168`): table `3F:E171` (directive `statecond 3F:E171 n=12` in `.ann`) has 12 words with **address−1** (RTS trick). Values `≥ $80` never pass dispatch. Values `$0C`–`$7F` do not exist in Ryu data.

| # | Name (`3F:xxxx`) | True when |
|---|------------------|-----------|
| `$00` | CondOponenteAtaca (E189) | me standing/crouching AND opponent in reaction (`$70`–`$98`), attack (`$B0`–`$E0`) or projectile in air |
| `$01` | CondOponenteLongeCostas (E1B1) | `\|ΔX\| ≥ $0F` and my back to opponent; returns `$40` (flip bit) |
| `$02` | CondOponentePerto (E1D6) | `\|ΔX\| < $21` |
| `$03` | CondEmPe (E1ED) | bit 0 of my class |
| `$04` | CondAgachado (E1F3) | bit 1 of my class |
| `$05` | CondNoAr (E1F9) | `FighterY < FloorY` |
| `$06` | CondNoChaoOuVelX (E204) | on ground or sliding (`VelX`/`VelXSub` ≠ 0) |
| `$07` | CondInputBaixo (E212) | `InputDir` = `$08`/`$0B`/`$0C`; returns own `InputDir` |
| `$08` | CondProjetilLivre (E224) | my projectile slot free (`ProjX` = 0) |
| `$09` | CondPodeAgarrar (E22E) | `\|ΔX\| < $18`, both on ground, direction forward/back and opponent class < `$30` or `$50`–`$9F` |
| `$0A` | CondVitoria (E271) | round mine, opponent fallen (`≥ $F0`), no projectiles in air and voice channel free |
| `$0B` | CondRoundPerdido (E296) | round ended not mine (works for draw) |

`CondOponenteLongeCostas` returns full mirror byte (`$00`/`$40`): outside walker (which only tests ≠ 0), this is the value written to `FighterFlip` to turn — see bit 4 flag in §6.

## 5. Transition walker

Per frame, for each fighter (`FighterUpdate` → `3F:EFCE`): input/IA → `InputDispatch` → decrements `AnimTimer` (0 → `AnimAdvance`) → `ProjUpdate` → re-face (bit 4 flag).

**`StateCheckTransitions` (`3F:E0CE`)** receives list in `zp_D7/zp_D8` and origin in `zp_DD` (`$01` special, `$02` button, `$04` guard/damage/reaction). Walks:

1. Pre-filters by origin: with `zp_DD=$04`, a node equal to current state is skipped (unless current class `& $F8` is `$28` — guard `$28`–`$2F` — or `$30` — reaction `$30`–`$37`); with `zp_DD=$02` during a move with sound (class `$70`–`$98`), only current node passes.
2. Outside these cases: if my class doesn't have bit 2 (airborne, §3), test `CondOponenteLongeCostas` — back turned and far, node skipped (doesn't react from behind).
3. Test node: `+0 ≥ $80` = true immediately; otherwise call condition (§4).
4. True → `TransApply` (`3F:E13B`): writes `FighterNextPtr` = node address; for classes `$28`–`$40` and `$B0`–`$E0` forces `AnimTimer=1` (move starts next frame), unless current frame has flag bit 3.
5. False → `TransNextNode` (`3F:E129`): follows +1/+2 and repeats; pointer `0` = end, nothing changes.

`FighterNextPtr` commit happens in `AnimAdvance` (`3F:E2A6`): node becomes `FighterStatePtr`, 1st frame is `node+7`, class passes through `StateSetByte` (writes `FighterState` and triggers sound/voice of family) and +6 goes to `AttackHitsLeft`.

Who feeds the walker:

* `TransViaTbl` (`3F:F6F5`): reads word from input table and calls walker;
* `InputDispatch` (§13) — direction/button/special;
* `GuardRedirect` (§13) — guard;
* damage routine (§11) — reaction;
* `AnimAdvance` — pending transition beats frame advance; class `$49` with `zp_62≠0` diverts to alternative +1/+2 of current state; without transition and without hit freeze, advances frames (loop §6) and at end `StateAdvance` (`3F:E371`) follows natural chain +3/+4 (with exception of dead class `$30`, which uses +1/+2).

## 6. Animation frame — 14 bytes (16 if looped)

| Offset | Field | Content |
|--------|-------|---------|
| +0 | duration | video frames (1–100 in real data) |
| +1, +2 | metasprite | pointer in frame bank (§9) |
| +3, +4 | collision | pointer to boxes (§10); `0` = none |
| +5 | parameter | see §7 |
| +6 | effect type | see §7 |
| +7 | flags | see below |
| +8 | movement mode | 0–5, see §8 |
| +9, +10 | VelX / VelY | signed, interpreted per +8 |
| +11 | repetitions | loop: how many times to repeat branch before continuing |
| +12, +13 | next frame | `0` = end of animation (`StateAdvance`) |
| +14, +15 | loop branch target | **only if +11 ≠ 0**: where to loop back while loop not zero |

Flags (+7 → `FrameFlags`):

| Bit | Effect |
|-----|--------|
| 0 (`$01`) | frame accepts **special move** (table `ram_0326`) |
| 1 (`$02`) | frame accepts **button move** (table `ram_0322`; sets `BtnAHold`/`BtnBHold=$15`) |
| 2 (`$04`) | frame accepts **direction** (table `ram_031E`) |
| 3 (`$08`) | do not force `AnimTimer=1` on transition (§5) |
| 4 (`$10`) | re-face: each frame writes `FighterFlip=$40`/`$00` per opponent side (`3F:EFCE`) |
| 5 (`$20`) | exempt from X edge clamp (`$20`–`$E0`) and speed adjustment near corner (§8); blocks `GuardRedirect` (§13) |
| 6 (`$40`) | clamped at edge, clamp overflow added to X of **opponent** (`F62C`) — shove "through" victim |
| 7 (`$80`) | unused in Ryu data |

Census of flags: bit 5 in 36 frames (fl `$20`×22 + `$30`×14) — all with collision box and no effect, in guard/reaction states: ±2 px tremor preceding slide; bit 6 in 34 (fl `$40`×33 + `$50`×1) — long slides (dur 19–36, mode `$02`).

The loop works (`AnimAdvance`): with `LoopRepeat` (+11) ≠ 0, decrements and, while not zero, jumps to +14/+15; zeroed or +11 = 0 → follows +12/+13.

Real example — 3rd frame of far strong kick (state `$ABE2`: 1st `ABE9`, 2nd `ABF7`) and, below, a guard tremor loop:

```
D01_AC05:  ; dur=6 efe=$12/$C2 fl=$00 mov=$04 vx=0 vy=0 rep=0
    .byte $06           ; +0  6 frames
    .word D00_87E2      ; +1/+2 metasprite
    .word D00_9356      ; +3/+4 collision boxes (example from section 10)
    .byte $12           ; +5  damage 18
    .byte $C2           ; +6  hit: blockable both postures, reaction class 2
    .byte $00,$04,$00,$00,$00   ; +7..+11
    .word D01_AC13      ; +12/+13 next frame

D01_A439:  ; dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0
D01_A447:  ; dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7 br=$A439 (16 bytes)
```

In the example: `AC05` is a typical attack frame — duration 6, damage 18 (`$12`), type `$C2` (blockable in both postures, reaction class 2 — §7), collision box active (§10) and no displacement (mov `$04`, vx=0). `A439`/`A447` are the guard tremor of orphan state `$A432` (§2): ±32 (`±$20`) = ±2 px per frame, loop `A447 → A439` repeated 7×, flag bit 5 (exempt from edge clamp, §8). Real walk is another state — `D01_A16D` (direction table "forward" entry, class `$61`): frames `rep=0` with flags `$17`/`$1F` (accept direction, button and special) and `vx = $17` (23) ≈ 1.4 px per frame, forward only (§8).

## 7. Frame effects (+5 parameter, +6 type)

`+6` is the `EffectType` (the `+5` is the `EffectParam`); applied on frame entry (`FrameEnterCommon`) and on `AnimAdvance`:

| `+6` | Effect | `+5` means |
|------|--------|------------|
| `$00` | none | — |
| `$01` | undeciphered (1 frame in Ryu) | — |
| `$0B` | fires **projectile** (`ProjLaunch`, §12) | speed `$00`/`$01`/`$02` (step in `ProjSpeedStepTbl`) |
| `$0C` | **throw** | damage = `&$1F` (real value `$16` = 22); `>>5` = thrower's throw state index (§11) |
| `$20` | sound effect (index) | sfx index |
| `$43`/`$8x`/`$Cx` | **hit** | decomposition below |

Hit (`$43`, `$83`, `$86`, `$C0`, `$C2`, `$C3`, `$C5`, `$C7`, `$C8` in real data):

* bits 6–7 = **postures blocked by the hit**: `$40` (standing guard only), `$80` (crouching guard only), `$C0` (both). Victim blocking takes chip (§11); victim guarding wrong way takes full damage;
* bits 0–5 = reaction class: copied whole to victim's `HitReactClass` and used with `&$3F` to index reaction, knockback and defense (real values ≤ `$0B`);
* `+5` = damage in `&$1F` (3 to 22 in real data) and **chip** in `>>5` (0–3; only parameters `$6B`/`$6F`/`$72` have chip = 3).

Census of 269 reachable frames (§2): `+6` = `$00`×229, `$01`×1, `$0B`×2, `$0C`×1, `$20`×7, `$43`×6, `$83`×2, `$86`×1, `$C0`×2, `$C2`×4, `$C3`×1, `$C5`×5, `$C7`×7, `$C8`×1.

## 8. Movement (+8 mode, +9/+10 VelX/VelY)

**On entering frame** (`MoveVelSetup`, `3F:E4C2`), mode +8 dispatches via table `MoveVelDispatchLo`/`MoveVelDispatchHi` (6 words, address−1) and interprets +9/+10 as velocity; here bit 0 of mode changes nothing (0≡1, 2≡3, 4≡5):

| Mode | Routine | +9/+10 mean |
|------|---------|-------------|
| 0/1 | `MoveVelAbs` (`3F:E4DA`) | new velocity, direct (zeros subpixel) |
| 2/3 | `MoveVelAccel` (`3F:E597`) → `MoveVelAdd` (`3F:E53C`) | acceleration: adds signed `vel/16` to current velocity (Vel, VelSub) |
| 4/5 | `MoveVelSubpixel` (`3F:E4F1`) | `vel/16`: integer in `Vel`, remainder ×16 in `VelSub` |

Census: mode `$02`×105, `$04`×143, `$01`×12, `$05`×8, `$00`×1. Walk uses `$04` with `+$17` = 23/16 ≈ 1.4 px per frame, **forward only** — holding back is guard (direction table entry 2, §13); ±32 = ±2 px is guard/reaction tremor (§6); jumps use `$02`/`$04` with negative `VelY`.

**Each frame**, application dispatches again by mode (`L3F_F0A5`, table `MoveApplyDispatchLo`/`MoveApplyDispatchHi`): mode `$00` positions **relative to opponent** (`F0BD`: X = opponent X ± `VelX`, consumed — unique throw victim frame in census); others are absolute: `$01` applies direct (`F0F2`), `$02`/`$03` integrate `VelY` with ground and camera (`F236`) and `$04`/`$05` apply `VelX` with corner rules (`F377`). After moving: overlapping fighters (same height, |ΔX| < $10) shove half the invasion (max 2 px) and `L3F_F5CD` clamps each X to `$20`–`$E0`, saving overflow in `zp_E1`/`zp_E2` (crossed: each writes to other's slot). Bit 5 flag exempts frame from clamp; with bit 6, overflow is added to **opponent** X (`F62C`) — corner knockback shoves attacker along. And throw victim (`HitReactClass & $3F = $0C`) that moved and got clamped at edge with camera at limit (`$58`/`$A0`) escapes throw (`F648`: `HitFreeze`, `HitReactClass=0`, sfx `$09`).

## 9. Metasprite (frame bank)

Each frame metasprite pointer (+1/+2) points to a **record**:

```
[CHR page][sub-metasprite 1][sub-metasprite 2]
     1 byte      ??? bytes             ??? bytes
```

* **CHR page** (byte 0): `DrawFighter` (`3B:EDD9`) writes it to fighter's `FighterChrPage`; NMI (`kernel.inc`) sends `FighterChrPage`/`FighterChrPage+1` to `$5121`/`$5123` (MMC5).
  **Projectile** drawing (`3B:F2D0`) reads byte 0 and writes it directly to `$5125`.
* Each **sub-metasprite** = `[attribute][groups…][terminator]`:
  * `attribute` = OAM attribute byte XOR `FighterFlip` OR palette (`zp_E1`); 1st sub-metasprite uses fighter's palette and 2nd uses palette+2 — body split into two halves with two palettes (P1: palettes 0 and 2; P2: 3);
  * each group = `[n][dx][dy][n tiles]`: `n` 8x16 sprites side by side, X = `FighterX+dx` and next tile 8 px to the right, Y = `FighterY+dy`, tile = byte + `zp_E4$ (`$00` fighter 0, `$80` fighter 1 — tiles of each fighter in different page halves);
  * mirrored (`FighterFlip`): dx' = `$F8−dx` and each tile goes −8 (X = `FighterX−8−dx`);
  * X < `$08` (sprite off left edge): rest of group discarded;
  * `terminator` = byte `≥ $80` (`$FF` ends whole record).
* Records are glued together; `DrawMetasprite` (`3B:F2EA`) is called twice in a row to draw a fighter's two sub-metasprites.

Real example (`00:8D81`, standing pose):

```
2B 00 | 02 FA BE 70 72 80 | 00 | 02 F2 BE 58 5A | 03 F2 CE 5C 5E 60 | ... | 80
 ^^    ^^^^^^^^^^^^^^^^^^^    attribute of 2nd sub-MS; groups; terminator >= $80
 |     1st sub-MS: attribute $00, group of 2 tiles at dx=$FA dy=$BE, tiles $70/$72
 CHR page $2B
```

## 10. Collision boxes (frame bank)

Frame pointer +3/+4 → **12 bytes = 3 boxes** `[height][dy][dx][width]`: body 1, body 2 and attack. Height `0` = absent box (attack is `0000`-pointed on frames without hit).

Geometry (with fighter `FighterX`/`FighterY`):

* top = `Y + dy`, bottom = top + height;
* unmirrored: left = `X + dx`, right = left + width;
* mirrored: right = `X − dx`, left = right − width;
* attack box clamped to `$20`–`$E0` (never leaves screen).

Real example (`00:9356`, far strong kick frame — trunk, whole body, stretched leg):

```
0D BD 00 0E | 36 C8 FB 14 | 0A C8 03 25
body1:  h=$0D dy=-67 dx=0    w=14  (trunk)
body2:  h=$36 dy=-56 dx=-5   w=20  (whole body, for projectile/throw hit)
attack: h=$0A dy=-56 dx=3    w=37  (leg up to X+40)
```

## 11. Hit and damage

**`HitTest` (`3F:ECF1`)**, after both fighters move: AABB of attacker's attack box against victim's body 1/2 boxes. One hit per frame (`HitThisFrame`); each hit **consumes 1 of `AttackHitsLeft`** (that's why tatsumaki has 6) and writes victim `HitReactClass = EffectType` of attacker's frame. If victim class is `$A0`–`$A9` (turn) and she presses back, roles invert (throw) `(nt)`.

**`HitFreeze` (`3F:E000`)**: freezes victim for `$0E` frames — saves movement, velocities and timer in `ram_0312`–`$031C` and restores all in `FreezeRestore` (`3F:E301`).

**Damage routine (`3F:ED83`)**, called by `HitTest` and projectile:

1. **Chip**: victim guarding (`class & $F8 = $28`) and blockable hit on victim's posture (bits 6–7 of type AND victim posture ≠ 0): damage = `(param >> 5)`, reaction via defense table (`ram_032A`, index `(class & $3F)×2`), no knockback. Non-blockable hit against her: continues as full damage.
2. **Damage**: `FighterDmgPending += param & $1F`; if ≥ `FighterHP` (full = `$58` = 88) → KO (step 7). Pending damage subtracted from HP once per round-hit (accumulates in hit freeze).
3. Already knocked down (`zp_62 ≠ 0`): zeros knockback and jumps to reaction.
4. `HitReactClass & $3F = $0B` (projectile): `HitStop = $3C` (freezes BOTH fighters).
5. **Knockback** (accumulates between hits): victim standing/crouching (bits 0–1 of class) adds `KnockbackXGroundTbl`/`KnockbackYGroundTbl`; neutral/airborne adds `KnockbackXAirTbl`/`KnockbackYAirTbl` — always indexed by `class & $3F`. Accumulated `$20` in `zp_5E` → **knockdown**: `zp_62=$78` and new class via `KnockdownReactTbl[class & $3F]`.
6. **Reaction**: per victim posture chooses table (`ram_032E` standing, `ram_0336` crouching, `ram_0332` neutral), picks word at `(class & $3F)×2` and calls walker with `zp_DD=$04`. Class `$0C` (throw): uses throw table `ram_033A` indexed by `(param >> 5) + thrower_char × 4` (who chooses state is thrower). Impact sound: `HitSfxTbl` (`05 06 07 05 06 07`) indexed by **attacker** class.
7. **KO**: new class via `KOReactTbl[class & $1F]` and follows step 6 (defeat reaction).

## 12. Projectile

RAM per fighter: `ProjSpeed $77`, `ProjXSub $79`, `ProjX $7B`, `ProjY $7D`, `ProjStep $7F`, `ProjFlags $81` (bit 6 = right, bit 7 = clash). `ProjX = 0` = free slot.

* **Born** (`ProjLaunch`, `3F:E837`, on `AnimAdvance` of frame with effect `$0B`): X = `FighterX ± $27` (`ProjSpawnXOffsetTbl`), Y = `FloorY − $27` (`ProjSpawnYOffsetTbl`), direction = bit 6 of `FighterFlip` (per fighter flip).
* **Moves** (`ProjUpdate`, `3F:E854`): step per speed (`ProjSpeedStepTbl` = `$17`/`$25` for speed 0/1), 1/16 per frame with subpixel (`ProjStep` counts substeps). Dies outside `$0C`–`$FB`.
* **Clash** (`ProjClash`, `3F:E8BB`): two projectiles at `|ΔX| < $18` → both get bit 7 and die after 16 steps (clash animation in `D3B_E595`).
* **Hit** (`ProjHitTest`, `3F:E8F1`): AABB of projectile (point ± `$0C`/`$0B`) against body boxes; hit → `ProjHit` (`3F:E941`): dies, `HitReactClass=$CB`, damage `$6C` (12 + chip 3) and calls damage routine.
* **Drawing** (`3B:F27F`): metasprites in bank `$20` (HUD/effects), table `D3B_E57D` indexed by speed+step; byte 0 → MMC5 `$5125` directly.

## 13. Commands

**Input** (`InputUpdate`, `3F:E98D`): reads controller, builds `InputDir` (already relative to fighter facing side) and `InputAttack`, and runs special move recognizer (`InputCommands`, `3F:EA24`).

`InputDir` (`DirCodeTbl`): `$04` neutral, `$05` forward, `$06` back, `$07` up, `$08` down, `$09`/`$0A` up diagonals, `$0B`/`$0C` down diagonals. `InputAttack`: 0 weak punch, 1 strong punch, 2 weak kick, 3 strong kick, `$FF` nothing — strength comes from **button hold time** (origin of delay, `docs/BUGS.md`).

**`InputDispatch` (`3F:F671`)** — current frame flags (§6) decide which table to consult, always as words indexed `(key)×2`:

| Flag bit | Table | Index | Marks `zp_DD` |
|----------|-------|-------|---------------|
| 2 | `ram_031E` (directions) | `InputDir − $04` | `$04` |
| 1 | `ram_0322` (buttons) | `InputAttack` (sets `BtnAHold`/`BtnBHold=$15`) | `$02` |
| 0 | `ram_0326` (specials) | `CmdMoveIdx` | `$01` |

Pending node's class (masked `& $F8`) decides what passes: no pending node, everything. `< $58` (guard/reaction/intro) or `≥ $A0` (turn/throw `$A1`, specials, round end) → only `GuardRedirect`; `$58`–`$6F` → full dispatch; `$70`–`$9F` (moves) → **only special** (`F6D6`) — in buffer window you can queue a special behind a move, button cannot. The three dispatches run in sequence (direction → button → special), each jumping to next when frame flag or key missing; button requires `InputAttack ≠ $FF`; special consumes `CmdMoveIdx` (back to `$FF`) and, without flag or command, falls to `GuardRedirect`.

**Button chains** (table `ram_0322`/`$A012`, 4 entries per `InputAttack`; walker follows +1/+2 alternative of each node — §5; state class in parentheses):

| `InputAttack` | chain nodes (condition §4 → state) |
|---------------|------------------------------------|
| 0 weak punch | airborne (`$05`) → `$AD86` (`$8C`) · down (`$07`) → `$AD55` (`$8A`) · always → `$AD08` (`$89`) |
| 1 strong punch | ground/sliding (`$06`) → `$AF07` (`$9C`) · airborne (`$05`) → `$AEAC` (`$9C`) · down (`$07`) → `$AE51` (`$9A`) · near (`$02`) → `$ADF6` (`$99`, 2 hits) · always → `$ADA9` (`$99`) |
| 2 weak kick | airborne (`$05`) → `$ABBF` (`$74`) · down (`$07`) → `$AB8E` (`$72`) · near (`$02`) → `$AB5D` (`$71`) · always → `$AB2C` (`$71`) |
| 3 strong kick | can throw (`$09`) → `$AADF` (`$A1`) · airborne (`$05`) → `$ACC9` (`$84`) · down (`$07`) → `$AC7C` (`$82`) · near (`$02`) → `$AC2F` (`$81`) · always → `$ABE2` (`$81`) |

Chain is **data**; which variant fires per posture is behavior (e.g., strong crouch `$AE51` is behind "ground or sliding" test `$06`, which already covers ground — practically unreachable).

**`GuardRedirect` (`3F:F704`)** — only acts on guard (`FighterState & $F8 = $28`), with frame without bits 2 and 5 (`FrameFlags & $24 = 0`) and no pending transition; otherwise just returns. Saves `AnimTimer`; writes guard class by direction (`GuardClassTbl`, `3F:F799`, 9 entries `29 29 29 29 2A 29 29 2A 2A` per `InputDir−$04`) and applies received hit defense (`ram_032A[(HitReactClass & $3F)×2]`, `zp_DD=$04`). If walker committed, node becomes current state **preserving animation point**: `FramePtr = NextPtr + (FramePtr − StatePtr)`, re-reads flags (+7) and class (+5) of node, zeros pending and restores timer — guard enters same frame as animation.

**Special recognizer** (`InputCommands`, `3F:EA24`) — bridge "controller input → move index". Each fight frame, for each human fighter:

1. **Walk** (`CmdWalkLoop`): walks character's special list (fiche slot 8, copied to `ram_033E`/`ram_0340`); each byte is a **key** (`$00`–`$12`), bit 7 (`$FF`) ends. `JoyState`/`JoyPrev` mirrored by `FighterFlip` (forward/back bits swapped) and key dispatches `CmdStep[key]` via split table `CmdStepLo`/`CmdStepHi` (RTS trick), with `Y = key`. `inx; inx` per entry makes `x = fighter + 2×position`.
2. **State per entry**: each list entry has its own step and window, in interleaved arrays `CmdMotionStep` (`$90`–`$9B`) and `CmdMotionWin` (`$9E`–`$A9`), indexed by `fighter + 2×position` (P1 uses even bytes, P2 odd). 12 bytes: max **6 specials per character** — a larger list would step on other fighter's state.
3. **Recognized**: completing handler writes `CmdMoveIdx[fighter] = list position`; `InputDispatch` (flag bit 0 of frame, above) turns into state transition via `RyuSpcTrans` (`01:A01A`, pointed by `ram_0326`) and **consumes** index.

Five handler styles (`(nt)` = read from code; trace only executed movement one):

| Keys | Handler | Rule |
|------|---------|------|
| `$00`–`$07`, `$10` | `CmdStepMotion` (`EB4B`) | direction sequence (`CmdMotionTbl[key×4+step]`); a step counts when required bit is pressed **and** some direction is new (not in previous frame) — holding still doesn't advance; 12-frame window between steps; byte `$00` ends and starts button phase (another 12), requiring `InputAttack == CmdKeyAttackTbl[key]` |
| `$08`–`$0D` | `CmdStepCharge` (`EA9C`) | charge: hold direction ≥ 60 frames (counter saturates at `$3C`), release pressing release direction (next sequence byte) within 8 frames, then button within same window |
| `$0E`/`$0F` | `CmdStepMash` (`EAFD`) | press same button (`CmdKeyAttackTbl[key] == InputAttack`) 3×, intervals ≤ 8 frames |
| `$11` | `CmdStepBothBtn` (`EB32`) | A+B pressed together on rising edge |
| `$12` | `CmdStepNone` (`EB4A`) | empty — vacant table entry |

* `CmdMotionTbl` (`3F:E067`): 19 keys (`$00`–`$12`) × 4 bytes — bits `$04` down, `$01` forward, `$02` back, `$08` up, `$80` A, `$40` B; `$00` ends. Sequences: `04 01` ×4 (↓→), `04 02` ×2 (↓←), `01 04 01` ×2 (→↓→), `02 01` ×4 (charge ← … →), `04 08` ×2 (charge ↓ … ↑), `80 80 80` (3×A), `40 40 40` (3×B), `01 04 02 08` (→↓←↑). `CmdMotionAdvance` (`EB73`) reads `CmdMotionTbl+1` with same index to see next byte without `iny`. 4 bytes "of key `$12`" are actually `CmdKeyAttackTbl` itself — harmless, handler is just `rts`.
* `CmdKeyAttackTbl` (`3F:E0AF`, **17 bytes** = keys `$00`–`$10`): **required button** — `00 01 02 03` ×3 (keys $00–$0B; 0/1 punch, 2/3 kick) and `00 01 00 02 03` (keys `$0C`–`$10`; 3×A sequence requires weak punch, 3×B weak kick and 4-direction spin strong kick).
* Special lists: `CmdKeyListRyu` (`3F:E0C0`): `02 03 06 07 04 05 FF` — each byte is a key and **list position** becomes `CmdMoveIdx` (hadouken 0/1 with kick, shoryuken 2/3 with kick, tatsumaki 4/5 with punch). Second list at `$E0C7` (`0A 0B 08 09 0C 0D FF`, charge keys only), ready for another character — no fiche pointer points to it today.

Reading notes: (a) `InputClear` (`3F:E974`), which runs outside active fight, only zeros recognizer entry 0 — and `sta CmdMotionStep+1,x` / `CmdMotionWin+1,x` at `E988`/`E98A` is not fighter 1 entry 1, it's a neighbor byte (layout is interleaved); entries 1–5 are never zeroed there, only expire by window. (b) In trace, reads of `$90` appear ~8× real usage: it's 6502 phantom read (every `(zp),X` instruction reads base byte without index in prior cycle), not a bug. (c) CPU doesn't pass through recognizer: `AiOp00`–`AiOp03` operators write `InputDir`/`InputAttack`/`CmdMoveIdx` directly.

## 14. AI (scripts)

Two levels: `RyuAiThink` (`00:8F46`) chooses script (table `00:8E72`, 8 pointers, scripts in `00:8E82`–`$8F45`); `AiUpdate` (`3F:E7D2`) executes bytecode. `AiLevel` fixed at 7 (`3F:F84C`); `AiStartScript` hesitates if `Random & 7 ≥ AiLevel`.

Outside move (class < `$50`, flags & 7 = 0), `L3F_E74C` holds back by default (`$06`, or `$0C` down-diagonal if opponent crouching) — that's why CPU retreats.

**Bytecode**: each byte `≥ $80` is an opcode (`$80`–`$91` → `AiOp00`–`AiOp11` via `AiOpLo/Hi` table), with 0–2 operands `< $80`; `$FF` ends (zp_71=0 → calls thinker again). Actions (`$80`–`$86`) chain in same frame; **tests (`≥ $07`) that fail pause script and re-test every frame**; `$8D` decrements `zp_6F` and waits for zero (delay: `$84 $78` + `$8D` ≈ 120 frames).

| Opcode | Action |
|--------|--------|
| `$80` | direction (1 op) |
| `$81` | direction + button (2 ops) |
| `$82` | special move by index (writes `CmdMoveIdx` directly) |
| `$83` | defend (back / down-diagonal if opponent crouching) |
| `$84` | `zp_6F` = operand |
| `$85` | `zp_6F` = zeropage byte given by op0+x `(nt)` |
| `$86` | `zp_6F`++ |
| `$87` | my state >> 3 = op0? |
| `$88` | my state & op0 = op0? |
| `$89` | my state = `$58` family (e.g. wait for initial state `$59`) |
| `$8A` | in move `$B0`–`$E0`? `(nt)` |
| `$8B` | no my projectile in air? |
| `$8C` | distance test `(nt)` |
| `$8D` | decrements `zp_6F` and waits for zero |
| `$8E` | waits `\|ΔX\| < op0` |
| `$8F` | waits `\|ΔX\| ≥ op0` |
| `$90` | opponent state >> 3 = op0? |
| `$91` | `zp_73` = 0? `(nt)` |

Real decoded example (`00:8E82`):

```
80 04  89  8B  82 00  82 89  FF
stand  wait neutral ($59)  wait projectile free  hadouken (idx 0)  again  wait neutral  end
```

## 15. Auxiliary table index

| Address | Size | Content |
|---------|------|---------|
| `3F:E055` | 6 (3 used) | `HitSfxTbl` — impact sfx by attacker class (`05 06 07 05 06 07`) |
| `3F:E05B` | 3 (2 used) | `ProjSpawnYOffsetTbl` — projectile birth Y (`−$27`) |
| `3F:E05E` | 6 (2 used) | `ProjSpeedStepTbl` — projectile step per speed (`$17`/`$25`) |
| `3F:E064` | 3 (2 used) | `ProjSpawnXOffsetTbl` — projectile birth ΔX (`$27`) |
| `3F:E067` | 72 | `CmdMotionTbl` — 18 moves × 4 bytes (§13) |
| `3F:E068` | — | `CmdMotionTblNext` — alias of `CmdMotionTbl+1`, read at `EB73` |
| `3F:E0AF` | 17 | `CmdKeyAttackTbl` — required button per move (§13) |
| `3F:E0C0` | 7 | Ryu special list (§13) |
| `3F:E171` | 24 | dispatch of 12 conditions (address−1) |
| `3F:E4CE`/`$E4D4` | 6+6 | `MoveVelDispatchLo`/`Hi` — movement mode dispatch (address−1) |
| `3F:EF06`/`$EF13` | 13+13 | `KnockbackXGroundTbl`/`KnockbackXAirTbl` — X knockback by class (standing/crouching · neutral) |
| `3F:EF20`/`$EF2D` | 13+13 | `KnockbackYGroundTbl`/`KnockbackYAirTbl` — Y knockback by class (standing/crouching · neutral) |
| `3F:EF3A` | 13 | `KnockdownReactTbl` — reaction class on knockdown |
| `3F:EF47` | 45 (13 used) | `KOReactTbl` — reaction class on KO |
| `3F:F0B1`/`$F0B7` | 6+6 | `MoveApplyDispatchLo`/`Hi` — movement application dispatch (address−1) |
| `3F:F799` | 9 | `GuardClassTbl` — guard by direction |
| `00:8E72` | 16 | AI script table (8 pointers) |
| `00:8E82`–`$8F45` | — | Ryu AI scripts |
| `3B:E57D` | 16 | projectile metasprites (per speed+step) |
| `3B:E595` | 16 | projectile clash metasprites |
| `3C:8000`–`$80BE` | 180 | fiche: 10 pairs of table pointers (§1) |
| `3C:80C8`/`$80D2`/`$80DC` | 10+10+10 | state/frame/collision banks per character |
