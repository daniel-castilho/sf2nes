# Guile Behavioral and Engineering Specification

**Status:** technical proposal for future implementation; not authorization to modify or execute the project.  
**Selected reference revision:** *Street Fighter II: The World Warrior*, World 910522 (`sf2`).  
**Command notation:** movements are relative to the fighter's facing direction (forward/back), not fixed screen directions.  
**Last reviewed:** 2026-11-18 (documentation consistency review and P10 decision record).  
**P10 decision:** approved — due to the NES button limit, Sonic Boom uses LP/HP and Flash Kick uses LK/HK. The mechanism is also approved: the audited global remap of `CmdKeyAttackTbl[0C]/[0D]` to LK/HK. This is the project's control decision, not a pending proposal. Implementation validation remains pending under D-05. P9 (aerial-throw directions) and P11 (approval record) remain open.  
**Remote baseline checked:** public `refs/heads/main` from `https://github.com/daniel-castilho/sf2nes.git`, fetched into the isolated local ref `refs/review/public-main` at `e9baf3711e05f40d0b9551be7c945c763cb8f36e`. Remote configuration was verified before naming it: in the workspace where this pass was performed, `origin` points to that URL. The commit timestamp is 2026-11-17 23:15:59 -05:00, later than the review date below; this chronology discrepancy is unresolved.  

## 1. Objective and boundaries

Define the observable behavior and integration requirements for adding Guile to the NES game. This specification separates (a) what was found in the local project, (b) what secondary sources describe about *World Warrior*, (c) requirements approved for the adaptation, and (d) questions that remain insufficiently validated.

D-04 (resumption of character implementation) was resolved by the Maintainer on 2026-11-18; character work may resume. This specification still does not authorize source generation, builds, or tests/emulator runs; those activities require separate authorization, including D-05 and the scope of each validation.

It does not include extracting, copying, or incorporating sprites, audio, gameplay data, source code, or tables from the arcade ROM into the project. The ZIP was used to identify the revision by checksums; the game is a behavioral reference, and resources for the NES version must be created or obtained with verified rights. No changes were made to the ROM or source files.

**Out of scope for now:** Guile-specific AI, copying known glitches from the arcade revision, implementing numerical balance without validation, and any claim that the current portrait proves the fighter is loadable or playable.

## 2. Evidence base and confidence level

### 2.1 Static audit of the NES project

Files directly examined in the original audit: `src/bank_3C.s`, `src/bank_3B.s`, `src/bank_0C.s`, `src/bank_37.s`, `src/bank_3F.s`, architecture and format documentation, `sf2ne.cfg`, and `annotations/sf2ne.ann`. The assembly sources are generated from the annotations; they were not edited. In this review, I checked document names and relevant integration points against the fetched public `main` at `e9baf3711e05f40d0b9551be7c945c763cb8f36e`; this is not a complete revalidation of all behaviors or values in the original audit. The branch was fetched directly from `https://github.com/daniel-castilho/sf2nes.git` into the isolated local ref `refs/review/public-main`; the remote configuration was verified first (`origin` points to that URL in the workspace where this pass was performed). Its commit timestamp is 2026-11-17, later than this review date (2026-11-10); the timestamp discrepancy remains unresolved. The canonical paths in the current remote are `docs/ARCHITECTURE.md`, `docs/FORMATS.md`, and `docs/CHARACTER_STRATEGY_AND_REFERENCES.md`.

**Selection: Guile can be selected/displayed, but that does not make him playable.** `SelectCursorFighterTbl` (`src/bank_37.s`, `37:F293`) maps the eight cursor positions to IDs `[0,4,3,7,1,2,9,8]`; position 2 selects ID `3`. The loop stores that ID in `FighterChar` before calling `SelectDrawCurrent`. The name table at `3C:84CE` contains `GUILE`. `PortraitWinLayoutTbl` begins at `3C:84A6`; its column-3 entry is at offset `+6` (`3C:84AC`) and points to `D0C_8000`. `PortraitSetupP1`/`PortraitBuild` use this path to construct the portrait. Therefore, the name/portrait and selection-confirmation path are demonstrable in the code.

**The current `$0C` bank is a portrait resource, not an identified set of fighting assets.** `CharFrameBankTbl[3]=$0C`; the portrait pointer in column 3 is `3C:84AC -> 0C:8000`. `src/bank_0C.s` contains a short portrait stream at `$8000–$8037` (56 bytes) and fills the rest of the window through `$9FFF` with `$FF`. `PortraitBuild` reads this stream; its first byte, `$0C`, is used as the CHR page for the portrait. The matching numeric values of PRG bank `$0C` and CHR page `$0C` are incidental: PRG contains data/descriptors and CHR contains pixels. The CHR PNG is a tile sheet with no proven association to states; no fighting-move names are assigned to silhouettes. No Guile fighting metasprite, collision box, or state linked to this bank was found.

**What `FighterLoadChar` actually loads for ID 3 (do not infer from isolated values):**

| Fiche field | Loader source/destination | Effective value for Guile | Safe interpretation |
|---|---|---:|---|
| frame bank | `CharFrameBankTbl` (`3C:80D2`) → `FighterFrameBank` | `$0C` | Selects PRG `$0C` at `$8000`; does not prove valid fighting metasprites exist. |
| state bank | `CharStateBankTbl` (`3C:80C8`) → `FighterStateBank` | `$01` | Points to Ryu's state bank; it is not Guile-specific state data. |
| hitbox bank | `CharHitBoxBankTbl` (`3C:80DC`) → `zp_1C` | `$00` | Selects bank `$00` for reads using this selector; does not validate Ryu's hitboxes for Guile. |
| states by direction | low byte at `CharDirTransLoTbl+3` (`3C:8003`); high byte read without an index from `CharDirTransHiTbl` (`3C:800A`) | `$A000` | Important exception: Guile's low byte is zero, but the loader supplies high byte `$A0`; the effective pointer is not `$0000` and lands on the first table in bank `$01` (Ryu). |
| other 9 pointer tables | low/high pairs at `3C:8014–80BE`, column 3 | `$0000` | Buttons, special transitions, guard, reactions, throws, command list, and AI have no Guile-specific pointers. |

The direction-pointer exception comes from `src/bank_3B.s:FighterLoadChar`: the instruction `lda CharDirTransHiTbl` at `3C:800A` reads the high byte without `,y`. The other columns in the ten pairs are zero in `src/bank_3C.s`. Thus, loading ID 3 may read a valid directional table from Ryu's bank, while several other accesses have no pointed-to table and the renderer selects `$0C`; gameplay symptoms were not run and are not asserted here.

**Palettes, name, and audio:** `CharNameTbl`, victory quotes, and character-indexed tables have slots for Guile. `CountryVoiceTbl[3]=$0C` (`37:E0EF`) is the country-voice event used during presentation; it is not equivalent to fighting voice lines. Guile's `FighterVoiceTbl` slot starts at `$E129` (base `$E0F9 + 3×16`) and contains `$FF` throughout its 16-byte range, so no fighting voice samples are assigned to Guile in that table. Character-indexed palette tables exist, but their presence does not validate a final fighting palette or fighting art.

**Selection versus combat loading:** the cursor and portrait path allow Guile to be selected. `FighterLoadChar`, called by the versus flow, does not find a complete combat fiche. The audit must report Guile as **selectable and portrait-equipped, but not demonstrated to be loadable/playable**.

### 2.2 Command recognizer and engine extension points

The fiche has 10 pointer pairs: eight state/transition lists (direction, button, specials, guards, standing/crouching/neutral reactions, and throws), plus the command list and AI table. Guile has no character-specific pointers in any of them, except for the direction-pointer case described above.

The command recognizer (`src/bank_3F.s`, `CmdStepCharge`, `$EA9C`) has static charge codes `$08–$0D`, although this path is marked `(nt)` and has no dynamic validation in the project. The table currently encodes `$08–$0B` as back-to-forward with attacks `0,1,2,3`, and `$0C–$0D` as down-to-up with attacks `0,1`; the key table maps these values to LP, HP, LK, HK, respectively. The code implements 60 frames of charge, an 8-frame window for the release direction, and another 8 frames for the button (do not treat this as observed gameplay while the path remains `(nt)`). Each character's list can hold at most six entries, and `CmdMoveIdx` is the position in that list. The arcade reference accepts three punch strengths for Sonic Boom and three kick strengths for Flash Kick. The documented NES interface exposes four `InputAttack` classes (weak/strong punch and weak/strong kick), not six; do not invent a medium strength or claim parity across all six. The approved adaptation to the existing scheme is two strengths per special: `$08/$09` for Boom (LP/HP) and `$0C/$0D` for Flash Kick (LK/HK), remapping the last two punch keys to kicks or implementing equivalent per-character mapping. Check all consumers before changing the global table. Do not point Guile to Ryu's list or to candidate `$3F:E0C7` without demonstrating its semantics and association. The contiguous bytes beginning at `$3F:E0C0` contain Ryu's logical list through the first `$FF`; a second sequence at `$3F:E0C7` is `$0A,$0B,$08,$09,$0C,$0D,$FF`, documented as charge keys for another character, but no fiche currently points to it. It is a relevant existing artifact, not proof that its contents/order are correct for Guile.

For throws, the code already has shared synchronization infrastructure: `GrabCheck`/`GrabCheckOne` (`3F:F033–F09A`) recognize initiating states in the `$A0–$A8` family, align the victim, transfer the throw reaction (`HitReactClass & $1F = $0C`), and prevent duplicate capture through the fighter-swap flow. This is a potential integration foundation, not evidence that it works in the air. Condition `CondCanGrab` `$09` (`3F:E22E`) requires both fighters on the ground, proximity `<$18`, forward/back direction, and an eligible victim class. For aerial throws, this condition cannot simply be reused: the `StateCondLo/Hi` dispatcher (`3F:E171–E188`) has exactly 12 entries `$00–$0B`, all occupied; a new condition needs a code and a compatible dispatcher extension, or an equivalently proven solution. Do not change `$09` in a way that allows aerial throws on the ground.

`docs/FORMATS.md` defines the state/frame format, hitboxes, movement, damage, and projectiles. Guile's states, animations, hitboxes, and metasprites still need to be created/integrated and individually checked. Ryu's stats are not a quantitative target for Guile.

**Consequence:** ID 3 appears in the selector with a name/portrait, but that does not mean the character can be used in a match. A future delivery must demonstrate a complete fiche, graphics resources, commands, collisions, and in-match transitions.

### 2.3 Identification of the arcade reference ROM

`/home/user/google_drive/sf2.zip` was located (31 members; 7,669,944 bytes uncompressed). ZIP SHA-256: `4abbfccd30caf163f18064bf8c27b2780f370d67d34ee802999dcbb7e6436a30`. I compared **all members** against the `sf2` entry from `mame -listxml` (MAME 0.276): all 31/31 names, sizes, CRC-32 values, and SHA-1 values match; there are no missing, extra, or differing members; all 31 are marked `good`. `mame -verifyroms sf2` also returned `romset sf2 is good`. The official catalog description is *Street Fighter II: The World Warrior (World 910522)*, consistent with the [MAME machine record](https://data.spludlow.co.uk/mame/machine/sf2) and the [MAME CPS1 driver](https://github.com/mamedev/mame/blob/mame0289/src/mame/capcom/cps1.cpp). Representative checks: `sf2e_30g.11e` SHA-1 `22558eb15e035b09b80935a32b8425d91cd79669`, `sf2e_28g.9e` `bbcef63f35e5bff3f373968ba1278dd6bd86b593`, `sf2-7m.6a` `3759b851ac0904ec79cbb67a2264d384b6f2f9f9`, and `sf2_18.11c` `346bf42992b4c36c593e21901e22c87ae4a7d86d`. The validation read members directly from the ZIP; nothing was extracted or copied into the project or incorporated.

The target revision is therefore **confirmed by full hash comparison and the MAME validator**. I also ran the set headlessly in MAME 0.276 for approximately nine seconds in benchmark mode (`-bench 10`, with video/audio not observed); the process exited normally. This confirms that the emulator started the machine/set, but **does not** demonstrate entering a game, reaching a fight, Guile functionality, or any gameplay measurement. Object Test, commands, frames, and behavior remain unvalidated by observation.

### 2.4 Secondary references consulted

- [SuperCombo Wiki — Guile, The World Warrior](https://wiki.supercombo.gg/w/Street_Fighter_2:_The_World_Warrior/Guile): moveset, descriptions, frames/damage, and throw tables for the variant identified as WW. It is a community wiki, not an independent inspection of World 910522; metrics are not accepted as final values without validation.
- [T.Akiba’s SF2 Data, translated by NKI](https://zachd.com/nki/ST/data.html): compiles measurements from different versions. Its introduction says WW/CE/HF were tested in training mode in *Capcom Generations 5* for PlayStation, not directly on the World 910522 board. The table includes charge and throw-damage estimates that differ from SuperCombo; it is a triangulation reference, not the sole authority for fixing board values.
- [GameFAQs — Guile Guide (ARC), ColdShadow86 (1999)](https://gamefaqs.gamespot.com/arcade/583626-street-fighter-ii/faqs/846): states that it focuses on the original arcade game and lists basic attacks, close distinctions, crouching/aerial moves, all four throws, specials with any strength button, and the claim that Knee Attack only works in Champion Edition. The author says they named moves after seeing them in slow motion “by general appearance”; use the names/mappings only as candidates for checking, not as certified primary nomenclature or measurements.
- **Japan:** [PS4で格ゲー — ガイル(スト2)](https://pskakuge.com/game/capcom/sf2/guile_sf2/) and [コマンド表(スト2)](https://pskakuge.com/game/capcom/sf2/command_sf2/) explicitly distinguish the original version from Dash: they describe **ニーパット / Knee Pad** (near + F/B+MK), Reverse Spin Kick, and both air-throw inputs as “in the air, any direction except up”; they state that the original version's air throws have a broad range and that the original Somersault Kick has no landing recovery. These are community guides, useful because they identify versions, not official documentation or auditable measurements.
- **Japan:** [Retro Game Raiders — World Warrior command list](https://retrogameraiders.com/archives/street_fughter2_comand/) agrees on Knee Pad (F/B+MK), Reverse Spin Kick, and throw commands; [homepage3gore — Guile SFII](https://homepage3gore.game.coocan.jp/st2/guile_1.html) also lists Knee Pad and Reverse Spin Kick as near + direction + button, but says Knee Pad is near and does not resolve whether direction alone qualifies for air throws. Two accounts do not replace the ROM.
- **Japan:** [Ameblo — Sonic Boom test](https://ameblo.jp/oyajizangief/entry-12542298153.html) reports a 60-frame charge in early SFII and 61 frames in Turbo, but is a personal post without a fully reproducible protocol; record it only as weak corroboration, not a conclusive measurement.
- **Brazil:** [Jogo de Luta — Guile in Street Fighter 2](https://jogodeluta.com.br/street-fighter/street-fighter-2/guile) lists Knee Bazooka/Reverse Spin Kick and the specials, but does not identify a revision or cover throws/frames; [Critical Hits — Champion Edition move list](https://criticalhits.com.br/games/street-fighter-2-champion-edition-todos-os-golpes-especiais/) is explicitly CE and therefore cannot prove World 910522 behavior. [Memória BIT — World Warrior history](https://www.memoriabit.com.br/street-fighter-ii-the-world-warrior-arcade/) provides Brazilian context about revisions, not move data. No Brazilian source found independently closes the target's numerical parameters.
- [Street Fighter Sprites Wiki — throws](https://street-fighter-sprites.fandom.com/wiki/Street_Fighter_II:_The_World_Warrior/Moves/Guile/Throws) and [standard attacks](https://street-fighter-sprites.fandom.com/wiki/Street_Fighter_II:_The_World_Warrior/Moves/Guile/Standard): corroborate names, but contain incomplete tables, generic Ryu GIFs, and divergent entries; do not use their data as validation.
- [TCRF — Street Fighter II](https://tcrf.net/Street_Fighter_II): a secondary reference for tools/glitches; it does not prove behavior specific to this specification.

Sources may differ by game, revision, platform, command interpretation, or editorial error. No timing, damage, range, hitbox, or glitch detail here should be treated as directly measured data from World 910522.

Arcade research mentions Knee Pad as an MK command normal. It remains background only: the approved NES control scheme has no MK class, so Knee Pad is not part of the approved NES implementation scope (§5.1).

### 2.5 Web research — published values that narrow gaps (still candidates)

Consulting the Guile page specifically marked **The World Warrior** on SuperCombo, the T.Akiba/NKI compilation, and an independent arcade community FAQ resolves part of the moveset and provides reference numbers. These are values **transcribed from secondary sources**, not measurements made in this audit. Preserve each source's units/labels; do not convert the numbers into NES pixels or mix published “damage” values from different sources as if they used the same scale.

| Subject | Published data found | Confidence / treatment in this specification |
|---|---|---|
| Aerial throws — eligibility and input | SuperCombo: Guile and opponent airborne, close, horizontal/diagonal directions (`↖/↙/←/→/↘/↗`) + MP/HP (Mare) or MK/HK (Buster). 1999 arcade FAQ: both airborne, close, forward/back + the same button families. Two version-specific Japanese lists say “in the air, any direction except up” + those buttons. | Both airborne + close + buttons are strongly corroborated. **Direction is unresolved:** forward/back is the minimum common input; Japanese sources include down, while SuperCombo explicitly excludes down and the FAQ only confirms F/B. The product/World 910522 direction rule remains pending testing. Fandom says down + button, but its page has placeholders/errors and does not resolve the disagreement. |
| Flying Mare / Flying Buster Drop | SuperCombo WW: for each, damage `40`, duration `130`, stun `7–13`, timer `100`, “range (from axis)” `54`, “range advantage” `24`. T.Akiba/NKI lists WW damage `46` normally / `48` when behind for **each** air throw in its damage table. | Range `54` and advantage `24` are candidates from one source, with no confirmed portable geometric unit. Damage conflicts (`40` versus `46/48`); definitions/scales or methodology likely differ, and T.Akiba was measured in a PlayStation compilation. Do not choose a final value without the arcade revision. The approved requirement is to include both throws, not to use a specific damage value. |
| Judo Throw / Dragon Suplex | SuperCombo WW groups the two: damage `32`, duration `130`, stun `7–13`, timer `100`, “range (from axis)” `48`, advantage `18`. T.Akiba/NKI for Guile in WW: `38` normally and `40` in the round when behind. | F/B+MP (Judo) and F/B+HP (Suplex) are corroborated by SuperCombo and the arcade FAQ. Damage values are unreconciled; `48` is the source table's unit, not NES pixels. |
| Grounded normals | SuperCombo WW publishes these as base values: light attacks generally damage `6`, stun `1–7`/timer `40`; medium `16`, stun `5–11`/`60`; heavy `22`, stun `11–17`/`80`. Frame count/advantage differs between moves and between close/far versions; for example, standing jab is listed at `+6`, standing MP `+6`, standing HP `+1`, crouching MP `+8`, and sweep as `KD/+7,-24`. | Useful as an initial balancing envelope and confirms that covering six buttons does not mean identical data. Final damage depends on SFII's randomness/scaling system; do not transfer it directly to NES hit points. Detailed data for each animation/hitbox still requires licensed visual material or controlled observation. |
| Sonic Boom | SuperCombo WW publishes charge `60f`, animation startup `8f`, base damage `12` for LP/MP/HP, stun `13–19`/timer `120`, with animation/speed differences by strength. T.Akiba/NKI: `54f` at a `1/2` success rate, measured in *Capcom Generations 5* (PlayStation). An independent Japanese post says `60F` in early SFII and `61F` in Turbo, without a complete protocol. | Charge values in secondary sources range from 54 to 60; `61F` refers to Turbo, not the target. The local `60+8+8` contract remains a parser/engineering decision, not confirmation of 910522. No new source provides portable projectile speed, size, persistence/clash behavior, or simultaneous-projectile limit. |
| Flash Kick / Somersault Kick | SuperCombo WW: charge `60f`; displayed damage `24 / 26 / 16+14` (HK appears to have two components), stun `13–19`/timer `120`, advantage `-24/-24/-33` by strength. T.Akiba/NKI includes the move in the `54f`/`1/2` success charge group. The Japanese PSKakuge guide says the original SFII has no extra landing recovery; later versions add/change that property. | Damage/frame values are candidates in the source's scale; charge remains conflicting. The Japanese landing observation is version-specific but was not measured from the 910522 image; treat it as a strong behavioral hypothesis and validate before translating it to NES frames. Do not infer hitboxes from wiki images. |
| Command normals in the original version | SuperCombo WW lists Reverse Spin Kick near + F/B+HK (damage `22`, stun `11–17`/`80`, advantage `?`). Japanese sources PSKakuge and Retro Game Raiders also identify **Knee Pad / ニーパット**, F/B+MK; PSKakuge and a personal Japanese page say it is close-range, does not knock down, and is exclusive to original SFII. PSKakuge says Dash replaces it with Knee Bazooka, with no range restriction. Rolling Sobat does not appear in the WW-specific lists reviewed; generic/later lists associate it with subsequent versions. | Historical research only for Knee Pad: it is excluded from the approved NES scope because its published input requires MK, which the NES control scheme does not provide. Do not assign an NES button by inference and do not call it Knee Bazooka without qualification. The old American FAQ note “Knee Attack only in CE” conflicts with two Japanese lists that name Knee Pad in the original; record this as a background naming/description conflict, not as a reason to reopen NES scope. Do not include Knee Bazooka as a WW-specific name/mechanic or Rolling Sobat without further direct evidence. |

The technical pages provide extensive “Frame Count” tables for each normal, but do not document a single methodology comparable to the NES engine's durations/states; close/far frames and multi-hit components also vary. Use these tables as **references for planning observations**, not for automatically filling offsets, hitboxes, or state durations. Guile glitches reported by SuperCombo itself remain outside the approved scope.

## 3. Gameplay profile the implementation should convey

Guile is a charge character with a predominantly defensive style: he controls approach and space with long-range normals and Sonic Boom, and protects the airspace with Flash Kick and anti-air normals. The essential mechanic is holding a charge direction before executing the command; it is not a projectile triggered by an instantaneous directional sequence.

This describes gameplay intent, not AI. Do not add special CPU behavior or strategic heuristics as a dependency of human-controlled fighter functionality.

## 4. Functional moveset

### 4.1 Normals

The arcade reference has six attack inputs per stance. For the approved NES scope (Q7/P8), the available classes are LP, HP, LK and HK; MP/MK remain arcade-reference labels only and do not create a NES medium-kick class. Respect close/far versions where the game's general rules distinguish them:

| Stance | Arcade inputs (reference) | NES classes in scope | Behavioral role to preserve |
|---|---|---|---|
| Standing | LP, MP, HP, LK, MK, HK | LP, HP, LK, HK | distinct hand/leg attacks; normals with varying range and recovery; close/far versions where required by reference data/art |
| Crouching | LP, MP, HP, LK, MK, HK | LP, HP, LK, HK | low defense and low/anti-air attacks; each attack must have its own hit and recovery behavior |
| Neutral jump | LP, MP, HP, LK, MK, HK | LP, HP, LK, HK | aerial attacks appropriate to a vertical jump |
| Diagonal jump | LP, MP, HP, LK, MK, HK | LP, HP, LK, HK | aerial attacks appropriate to forward/backward movement and jump direction |

The table is an input-coverage contract, **not** a claim that all combinations have unique animations, frames, or hitboxes in the project. The 1999 arcade FAQ describes close/far distinctions and names for crouching/aerial attacks, but its author admits the names are visual impressions from slow motion; treat them as an observation checklist, not an authoritative table. Range, damage, hit count, priority, cancels, and duration must be determined by observing the reference revision or marked as provisional parameters. Do not infer hitboxes from silhouettes or grayscale previews.

### 4.2 Command normals

| Move | Input published specifically for WW | Scope rule |
|---|---|---|
| Reverse Spin Kick (Upside-down Kick) | close + forward/back + HK | Treat as a distinct move, not a normal HK. The wiki-described Sonic Boom cancel peculiarity is a glitch and remains out of scope. |
| Knee Pad (arcade reference only) | close + forward/back + MK | Excluded from the approved NES scope: the published command requires MK, and the NES control scheme has no MK class. Do not infer an LP/HP/LK/HK binding and do not rename it Knee Bazooka. |

The approved pose list includes art for Reverse Spin Kick only. Knee Pad remains arcade research background; it is excluded because its published command depends on MK, which the approved NES scheme does not provide. Do not assign it to an NES button by inference.

**Version/name distinction (background only):** the 1999 arcade FAQ says “Knee Attack” only works in Champion Edition, while PSKakuge and Retro Game Raiders list Knee Pad in the original. Treat this as a terminology/editorial conflict in the arcade research, not as a reason to reopen the NES scope decision. Knee Bazooka and Rolling Sobat are not World 910522 requirements based on current evidence; Rolling Sobat does not appear in the WW-specific lists reviewed. Do not claim these moves never existed in SFII; limit the claim to the selected target.

Do not include **Spinning Back Knuckle** as a base-version requirement: consulted references associate it with other iterations of the character, without sufficient evidence for World 910522.

### 4.3 Special moves

| Move | Essential input | Required observable result |
|---|---|---|
| Sonic Boom | arcade: charge back; forward + any punch. Approved NES adaptation (P10): weak and strong punch classes (LP/HP) | startup/execution animation and creation of a projectile that travels forward. Arcade has three strengths; the current NES scheme exposes only weak/strong, so do not claim a medium variant or full parity. Speed/animation differences are candidates, not yet portably measured for NES. |
| Flash Kick (Somersault Kick) | arcade: charge down; up + any kick. Approved NES adaptation (P10): weak and strong kick classes (LK/HK) | anti-air attack in an arc/backflip, with coherent return and landing. Arcade has three strengths; the current NES scheme exposes only weak/strong. Movement/effect differences still need validation for 910522. PSKakuge says the original has no extra post-landing recovery; do not impose a post-landing lock without confirming it on the ROM. |

#### Charge recognition — approved mapping for NES input

The arcade reference accepts any punch strength for Sonic Boom and any kick strength for Flash Kick. The project's NES controls do not reproduce six strength buttons: `InputAttack` provides four classes (weak/strong punch and weak/strong kick), and the general scheme derives strength from button hold duration. To preserve current controls without redesigning the interface, the decision approved under P10 is **two variants per special**: LP/HP for Boom and LK/HK for Flash Kick. Medium strength is not an implicit NES requirement; adding a third level would require an explicit control/scope change.

The current assembly (`CmdStepCharge`, marked `(nt)`, with no dynamic validation) has these codes and associations:

| Keys | Sequence stored in `CmdMotionTbl` | Current `CmdKeyAttackTbl` attack | Approved mapping (P10) |
|---|---|---|---|
| `$08–$0B` | back → forward | LP, HP, LK, HK | `$08/$09`: weak/strong Sonic Boom. |
| `$0C–$0D` | down → up | LP, HP | **Approved remap:** set `CmdKeyAttackTbl[0C]/[0D]` to LK/HK (`$02`/`$03`) for weak/strong Flash Kick. |

The Guile list defined by the approved mapping is `[08,09,0C,0D,FF]`, with four transitions in the same order (weak/strong Boom, weak/strong Flash Kick). The Phase 1 audit found that only the dormant `$3F:E0C7` list references keys `$0C`/`$0D`; Ryu's active list uses `$02,$03,$06,$07,$04,$05,$FF` and Ken reuses it. The approved global change is therefore limited to `CmdKeyAttackTbl[0C]` (`3F:E0BB`) and `CmdKeyAttackTbl[0D]` (`3F:E0BC`). Any wider remap requires a new decision. The adjacent second sequence at `$3F:E0C7` is `$0A,$0B,$08,$09,$0C,$0D,$FF`, annotated as charge keys for another character, but no fiche points to it today. Treat it as a candidate artifact only; it does not establish Guile's required order or mapping.

The static routine counts charge up to `$3C` (60) frames; after that, it allows eight frames for the release direction and eight frames for the button. The recognizer mirrors directions using `FighterFlip`. This is a static parser contract, not observed gameplay. SuperCombo publishes 60f; T.Akiba/NKI reports 54f at a `1/2` success rate in WW/CE/HF tests in *Capcom Generations 5* training mode for PlayStation; a Japanese post reports 60F for early SFII. The effective value for 910522 remains a candidate until measured directly.

Do not assume a charge buffer after release, stored charge, command priority, canceling, or tolerance for switching sides. Manually validate charging, release/button windows, blocking, hit-stun, landing, and interruption. Do not depend on `FIX_SELECT_VERSUS`, `FIX_SELECT_DIFFICULTY`, or other selection macros to implement the recognizer.

#### Sonic Boom projectile

The projectile is a combat object, not merely an animation attached to Guile. It must spawn on the facing side, respect orientation, move frame by frame, test collision with body/guard, and end when it leaves the bounds or collides according to a defined rule. Strengths must be distinguishable without allowing more simultaneous projectiles than the engine supports. Reusing generic projectile infrastructure is an engineering decision; it does not imply copying Ryu's geometry, speed, or data.

Damage, chip, speed, height, width, duration, interaction with another projectile, simultaneous-projectile count, and recovery are open parameters until the World 910522 reference is validated.

### 4.4 Ground throws

- **Judo Throw:** close + forward/back + MP.
- **Dragon Suplex:** close + forward/back + HP.

The engine must resolve throw contention, check target distance/position/state, start coordinated animations for thrower and victim, and apply damage/knockdown exactly once at the impact point. The names and inputs are corroborated by SuperCombo WW and the arcade FAQ. Published values are candidates, not final values: SuperCombo lists 32 damage, duration 130, stun `7–13`, timer 100, axial range 48, and range advantage 18; T.Akiba/NKI lists Guile WW damage as 38 normally / 40 when behind. The scale/methodology discrepancy must be reconciled before fixing NES damage or range.

### 4.5 Aerial throws — requirement preserved; approval record pending

Both moves below are mandatory; do not remove them because of source disagreement:

| Move | Published reference input (not input-tested in this audit) | Required eligibility |
|---|---|---|
| **Flying Mare** | close + forward/back + MP or HP; SuperCombo expands direction to horizontally oriented diagonals | Guile and opponent are both airborne and close enough according to a validated parameter; neither is in an incompatible state (KO, grabbed, invulnerable, according to the approved rule). |
| **Flying Buster Drop** | close + forward/back + MK or HK; SuperCombo expands direction to horizontally oriented diagonals | Same airborne and proximity conditions. |

The relative forward/back + button-family input is corroborated by the SuperCombo WW page and the 1999 arcade FAQ, and matches the button requirement treated here as approved. The precondition “both airborne + close” is a **strong reference candidate**, although it was not exercised by input in this environment. The full direction rule remains open: forward/back is the common minimum; SuperCombo includes diagonals and excludes down, while PSKakuge says any direction except up (including down), and the older FAQ confirms only forward/back. Fandom says down + button, but its page has generic placeholders/editorial errors and does not resolve the disagreement. The input window, proximity metric/threshold, knockback, and direct validation on the 910522 set also remain open. Candidate damage and axial range values are listed in §2.5; none is selected as final. The decision that made both throws mandatory has no decision-record/date reference in this file; preserve the requirement, but link the decision in the scope record before implementation. Until direction and threshold are resolved, do not claim full equivalence with the arcade reference.

Required safe integration:

1. The engine already has a generic route that may be reused: `GrabCheck`/`GrabCheckOne` examines `$A0–$A8` classes, aligns fighters at throw startup, recognizes the victim's `$0C` reaction class, and switches the initiator to prevent duplicate capture. The exact aerial-flow connection must be proven; the existing code does not check that both fighters are airborne.
2. Add a condition that checks `Y < FloorY` simultaneously for Guile and the opponent, a proximity threshold defined before implementation/acceptance, and an eligible victim state. The new predicate must reject KO/knocked-down states, an already-grabbed victim, and states that cannot be grabbed. The current dispatcher has all codes `$00–$0B` occupied; explicitly plan an extension to `StateCondLo/Hi` for a new code (for example, `$0C`) and update the `statecond` documentation, or propose an equivalently supported mechanism. Do not turn ground condition `$09` into a mixed predicate.
3. Test range in relative coordinates using a measured parameter; if boxes are used, signed offsets and mirroring rules must follow `docs/FORMATS.md`.
4. Connect thrower start/continuation states to a victim reaction class `$0C` that Guile's throw table can resolve. The engine's capture/alignment appears to depend on the first frame of the initiating state and `FighterNextPtr`; keep the eligibility check in the same tick before commit to avoid a race with landing/transition.
5. Apply damage exactly once and define coherent positions/fall/return to ground. Block conflicting input during capture and ensure both natural animations finish without looping, endless falling, or actors stuck in the air.
6. Cover both sides, different jump heights, meeting at apex/ascent/descent, simultaneous commands, landing on the same frame, contact near the corner, and interruption by damage/round end.

Do not invent or assign final values to the aerial moves. SuperCombo reports damage 40 and axial range 54 for each; T.Akiba/NKI's table lists WW damage 46 (normal) / 48 (when behind) for both. These remain **conflicting candidates** only. The minimum F/B + button-family input and both-fighters-airborne eligibility have convergent WW/arcade sources. This does not settle whether diagonals/down are accepted or define a proximity threshold; the full direction rule and range remain subject to validation on the 910522 ROM or an explicit Maintainer decision.

## 5. Required states, animations, and collisions

Future implementation must provide Guile-specific states and data, with identifiers/pointers consistent with the existing format. The minimum functional set includes:

- neutral/idle, turn, walk forward/back, crouch, vertical/diagonal jump, landing;
- the four NES attack classes (LP/HP/LK/HK) per applicable stance/variant, with appropriate startup, active frames, recovery, and return (§5.1);
- Reverse Spin Kick as a World Warrior command normal included in the approved art coverage; Knee Pad is excluded from NES scope because its published input requires MK, which the NES scheme does not provide; Knee Bazooka/Rolling Sobat enter the minimum set only if World 910522 confirms their presence and nomenclature;
- Sonic Boom startup/execution/recovery and projectile states; Flash Kick ascent/attack/fall/recovery;
- two ground throws and compatible victim states; two aerial throws remain a requirement but are excluded from the approved pose list until P9/P11 are resolved (§4.5);
- high/low guard, standing/crouching/neutral/aerial hit reactions, knockdown, get-up, victory, defeat/KO;
- natural chains and alternative transitions with no unexpected null pointers, unreachable states, or unintended loops.

For every combat frame, data must specify duration, metasprite, body/attack hitboxes, effect/damage, movement, velocity, and input/cancel flags according to `docs/FORMATS.md`. Body, attack, and throw boxes must be measured/drawn per frame. Use signed offsets; audit the parser before accepting any dimension above 256 px. Do not copy Ryu hitboxes or assume equivalence, even for similar poses.

Every animation needs documented sprite origin, pivot, orientation/mirroring, palette mapping, and NES parameters. A selection portrait does not replace a fighting sprite sheet; community frame pages do not grant a license to incorporate their assets.

### 5.1 Approved pose/move coverage (Q7/P8, 2026-11-18)

The Maintainer supplied the definitive coverage list. It defines **which animations and states must exist**, not exact frame counts, damage, hitboxes, or numeric properties. Those values must not be invented from the ROM without validation.

**Locomotion and postures**

- standing neutral;
- walk forward and backward;
- turn to each side, mirrored when visually correct;
- crouch transition, crouch neutral, and return to neutral;
- vertical and diagonal jump: startup, ascent, airborne pose, descent, and landing.

**Normals**

- four attack classes per posture — standing, crouching, neutral jump, and diagonal jump: LP, HP, LK, HK;
- each attack requires startup, active frame(s), recovery, and return; drawings may be shared only when the pose is genuinely identical;
- if the engine distinguishes close/far variants, cover the necessary visual variants; do not assume every combination needs unique art.

**Guard and damage**

- standing guard and crouching guard;
- block reaction while standing and crouching;
- damage reaction while standing, crouching, and airborne;
- knockdown and get-up;
- KO/defeat.

**Special moves**

- **Sonic Boom LP and HP:** charge/preparation, execution, and recovery; include the projectile animation and its disappearance. The charge may reuse the crouch neutral pose if the art does not require a distinct pose.
- **Flash Kick LK and HK:** startup, ascent/attack, descent, and landing/recovery. Keep the two P10 inputs; do not invent a medium variant.

**Ground throws**

- **Judo Throw:** Guile's capture, execution, and release phases, with the matching victim reaction/fall.
- **Dragon Suplex:** the same phases with its own sequence and victim reaction.

**Victory and defeat**

- victory pose/loop;
- defeat pose beyond KO if visually distinct.

**Command normals in approved NES scope**

- Reverse Spin Kick.

Its art is included in the coverage list.

**Excluded from the approved pose list**

- Knee Pad: excluded because its published input is close + forward/back + MK, and the approved NES scheme has no MK class. It remains arcade research background only; do not assign an NES button by inference.
- Flying Mare and Flying Buster Drop remain out until P9/P11 resolve eligibility and commands. This list does not assert arcade parity for them.

D-05 still blocks builds, tests, and emulator runs. P8 still requires legally usable sprites, palettes, audio, per-frame hitboxes, and numeric validation.

## 6. Fiche, banks, and routing — Guile-specific instructions

### 6.1 Combat fiche

- Keep `Guile = ID 3`; selection and portrait flows already reference that index.
- Create a dedicated fiche in column 3 of `3C:8000–80BE`. Populate the pointers needed for the eight state/transition tables and command list; verify by address what the loader copies to RAM. The tenth pair (AI-script pointer) must intentionally remain null while Guile AI is out of scope; no pointer required by the human-controlled flow may be zero. For the direction table, explicitly account for `FighterLoadChar` reading the low byte per character but using fixed high byte `$A0` for all characters. Guile's low byte must therefore point to his table in the selected state bank mapped at `$A000`; leaving the low byte zero points to `$A000`, not `$0000`. Change the loader only if a real requirement exists for a state bank outside this window.
- Set `CharStateBankTbl[3]` to the approved state bank `$09` (Phase 2); do not use the current `$01`. Bank `$05` is assigned to Ken's partial states and remains excluded. Do not infer additional allocations merely because a bank has no source file.
- Preserve the portrait pointer: `PortraitWinLayoutTbl+6` (`3C:84AC`) → `D0C_8000`. The approved frame/hitbox bank is `$14`; do not place Guile fighting data in PRG bank `$0C`. This keeps the generated portrait record untouched.
- Only after creating/validating dedicated collision data, point selector `CharHitBoxBankTbl[3]` (`3C:80DF`) to the approved shared bank `$14`. Current value `$00` does not validate Ryu hitboxes for Guile. `CharFrameBankTbl[3]` (`3C:80D5`) also becomes `$14`. Confirm that every reader uses the correct selector.
- Do not confuse PRG bank `$0C` (stream/descriptors in CPU `$8000–9FFF`) with CHR page `$0C` (pixels). The approved fighting-art reserve is CHR pages `$39`/`$3A`, with `$3B` as the projectile candidate; final page pairing still needs D-05 validation. Each metasprite must select a valid CHR page; extracted pages are tile sheets without proven animation associations. Fighting art, palette, and pivots need explicit provenance/license and NES validation.

### 6.2 Pointers and behavior

- Populate dedicated direction, button, special-move, guard, standing/crouching/neutral damage-reaction, and throw tables (`docs/FORMATS.md` §1). The command list in §4.3, as defined by the approved mapping, covers two NES strengths per special (Boom LP/HP; Flash Kick LK/HK). Apply the approved global remap of `CmdKeyAttackTbl[0C]/[0D]` to weak/strong kick; no wider remap is authorized. Do not claim that this reproduces all three arcade strengths; medium is outside the NES mapping unless the controls are explicitly changed.
- Define Guile's command list for the four approved NES combinations (two strengths per special), explicitly documenting that the two arcade medium-strength variants are not represented. Do not describe six variants as a requirement of the NES parser. Ryu's list `$3F:E0C0` is not reusable by assumption; `$3F:E0C7` has no confirmed association with Guile.
- Provide dedicated paths for ground and aerial throws. Ground throws follow the existing ground condition once validated; aerial throws require both-airborne eligibility and a dispatcher extension, as well as synchronized states compatible with `GrabCheck`/class `$0C`.
- Do not build Guile tables/offsets by copying Ryu's order/count. Resolve every state, metasprite, and hitbox pointer through labels and check it against the final map. Bounding-box offsets are signed; dimensions above 256 px require a parser audit.
- Guile-specific AI is out of scope. `AiCharRoutine` currently has only Ryu; Guile's fiche AI pointer is null. In supported modes, keep Guile human-controlled; do not send the CPU to an empty AI script or claim AI functionality.
- `CountryVoiceTbl[3]=$0C` selects the country voice during presentation; Guile's `FighterVoiceTbl` slot (16 bytes at `$E129–$E138`) is empty (`$FF`). Inventory samples by event and rights before reuse; do not invent a DPCM index.

### 6.3 Data workflow (do not execute now)

1. Map bank slots and preserve bank `$05`, currently assigned to Ken's partial states; confirm occupancy/capacity in the map/linker output before selecting a bank for Guile.
2. Inventory sprite metadata and usable PRG/CHR space; record that the CHR sheet does not associate poses with Guile.
3. Plan and populate a dedicated state bank; include a precise `statebank` annotation, command list, and pointers for required gameplay tables. Keep the AI pointer intentionally null while Guile AI remains excluded.
4. Produce independent graphics/collision data and link metasprites to CHR pages; preserve the current portrait.
5. Review the condition dispatcher for aerial throws and validate the four-command charge list adapted to NES weak/strong classes; respect the six-command/character limit and interleaved arrays.
6. Check compilation/relocation and the address map as build steps, without creating or running automated tests. Gameplay acceptance requires later manual validation.

## 7. Acceptance criteria for a future delivery

Future implementation must not be declared functional until, at minimum:

1. Guile loads under ID `3` with his own tables and without corrupting Ryu, Ken, the opponent, or HUD.
2. Portrait/selection and in-match presence are checked separately; the fighter appears with coherent combat animation and a valid NES palette.
3. All four input stances (standing, crouching, neutral jump, diagonal jump) respond to all four approved NES attack classes (LP/HP/LK/HK) with correct transitions and collisions.
4. Reverse Spin Kick, Sonic Boom, and Flash Kick work for P1 and P2, facing both directions. Knee Pad stays outside the approved NES scope because no MK class exists; do not include Knee Bazooka or Rolling Sobat without specific evidence. Test the weak/strong classes of each special available on NES and record the mapping/charge; explicitly state that the arcade medium variant is not represented by the current scheme.
5. Judo Throw and Dragon Suplex work against an eligible target, with correct side/orientation and exactly one damage event.
6. Flying Mare and Flying Buster Drop capture only when both fighters are airborne and within a proximity threshold documented and validated for the NES implementation; do not convert published arcade range directly into NES pixels. Verify synchronization, landing/knockdown, and absence of lockups or duplicate damage. The final command-direction rule must be decided before claiming full acceptance.
7. Guard, damage, hit-freeze, interruption, KO, victory, defeat, next round, and reset leave no pending states or stuck characters.
8. Attack and body hitboxes are visually audited in gameplay (not only in an image preview) and are not based on silhouettes, the portrait sprite, or Ryu.
9. Keep two independent evidence tracks: (a) characterize the arcade reference using the identified World 910522 set to confirm which behaviors/values are attributed to the arcade; and (b) accept the implementation using the identified NES ROM/build, commit, configuration, and hash in an NES emulator/hardware. An arcade result does not prove the NES implementation works, and an NES test does not prove exact equivalence with the arcade board. Do not treat Ryu's 71 states/274 frames as a target for Guile.
10. Licenses and provenance for all added resources are recorded. Parser/compilation acceptance does not replace gameplay acceptance.

## 8. Open issues — do not fill by inference

| ID | Issue | How to resolve before fixing |
|---|---|---|
| P1 | Arcade ROM-set identity and integrity | **Fully resolved:** all 31/31 members of `/home/user/google_drive/sf2.zip` match `mame -listxml sf2` by name, size, CRC-32, and SHA-1 (0 missing, 0 extra, 0 differing); `mame -verifyroms sf2` reported `romset sf2 is good`; ZIP SHA-256 is `4abbfccd30caf163f18064bf8c27b2780f370d67d34ee802999dcbb7e6436a30`. MAME identifies it as World 910522. **Limited execution:** ~9-second headless benchmark, with no input or screen observation; this does not validate gameplay. |
| P2 | Exact Flying Mare/Buster Drop values | **Partially narrowed by research:** the most likely command is close + F/B + MP/HP (Mare) or MK/HK (Buster), with both fighters airborne, corroborated by two WW/arcade sources. SuperCombo: damage 40, range from axis 54, advantage 24; T.Akiba/NKI: 46/48 WW depending on round situation. Still measure input, range, and damage on the 910522 ROM and define metric/unit. |
| P3 | Exact ground-throw values | **Published candidates:** F/B+MP/HP commands are corroborated; SuperCombo lists damage 32/duration 130/axial range 48; T.Akiba/NKI lists 38 normally/40 when behind in WW. Reconcile scales and measure on the arcade revision before converting to NES. |
| P4 | Final normal frames/damage and numeric properties by strength | **Candidates published in §2.5:** damage/stun envelope by normal class; SuperCombo lists Sonic Boom at 12 per strength and Flash Kick at 24/26/16+14, with some frame counts. Methodology/version, detailed properties for each phase, and measurement of hit-stun/knockback/chip on the target ROM remain unresolved. |
| P5 | Actual World 910522 charge time | Sources conflict: SuperCombo WW says 60f; T.Akiba/NKI measured 54f at 1/2 success in *Capcom Generations 5* for PlayStation; the arcade FAQ says about two seconds without an exact count. Exact board/revision measurement remains necessary; `60 + 8 + 8` remains only a static NES parser contract. |
| P6 | Projectile count, clash interaction, corner behavior, and defense reaction | Verify on the target ROM and compare with NES engine capacity. |
| P7 | Guile World Warrior quirks/glitches | Outside base acceptance; propose only with explicit authorization/decision and specific validation. Do not import a quirk from World 911101 into 910522. |
| P8 | Legally usable sprites, palettes, audio, and per-frame hitboxes | Produce original assets or verify license/provenance; document conversion and PPU/CHR limits. |
| P9 | Exact buttons/directions accepted by aerial throws in revision 910522 | Test F/B, diagonals, and down separately; sources disagree about down and the old FAQ only confirms F/B. Record side, height, proximity, and both fighters airborne; do not infer. If the reference cannot be observed, the Maintainer must explicitly choose and record the NES rule without claiming unverified arcade parity. Until then, direction and full acceptance remain blocked. |
| P10 | Mapping arcade strengths to NES controls | Approved decision: the NES scheme uses LP/HP for Sonic Boom and LK/HK for Flash Kick (two strengths per special; `$08/$09` and `$0C/$0D`, with the latter associated with kicks). Approved mechanism: audited global remap of `CmdKeyAttackTbl[0C]/[0D]` only. Arcade has three strengths per family; medium is not represented and full parity must not be claimed. Validate the implementation of this mapping without reopening the control decision. |
| P11 | Traceability of the decision making aerial throws mandatory | This specification preserves the requirement as approved but contains no decision reference/date/record. Link the scope decision before implementation; do not change the requirement without a new explicit decision. |

## 9. Internal project references

- `docs/ARCHITECTURE.md`, §4 — character fiche and current roster inventory in the remote `main`.
- `docs/FORMATS.md`, §§1–13 — fiche, state, frame, movement, metasprite, collision, damage, projectile, and command structures.
- `docs/CHARACTER_STRATEGY_AND_REFERENCES.md` — integration and clean-room principles.
- `tasks/PROJECT_VALIDATION_PLAN.md` — proposed validation plan; it does not authorize creating/running tests, builds, or emulators.
- `tasks/GUILE_IMPLEMENTATION_PLAN.md` — phased execution plan, gates, and decision record.
- `tasks/GUILE_IMPLEMENTATION_AUDIT.md` — Phase 1 static audit and label/address map.
- `tasks/GUILE_BANK_ALLOCATION.md` — Phase 2 Maintainer-approved bank/page allocation.

## 10. Specification execution record

The original audit checked project sources/annotations, compared all 31 arcade ZIP members with the MAME 0.276 manifest, and confirmed the World 910522 set; `-verifyroms` approved it. A headless benchmark startup was run for about nine seconds, without input or visual inspection. Web research narrowed move-command gaps and recorded candidate metrics, provenance, disagreements, and platform caveats in §§2.4–2.5. The previous technical review reconciled contradictory Knee Pad notes, distinguished it from Knee Bazooka, and made the aerial-throw direction disagreement explicit. A later Maintainer decision removed Knee Pad from the approved NES scope because the NES scheme has no MK class; those notes remain arcade research background only. It also recorded that the arcade reference accepts three strengths, while the documented NES input only provides weak/strong punch/kick classes; the approved decision is four charge inputs (Boom LP/HP and Flash Kick LK/HK), with no medium variant. The GameFAQs source describes close/far, crouching/aerial normals, and throws, but admits naming moves by appearance in slow motion; use it as an observation guide, not naming authority. The ZIP was read directly without extracting files into the project; no code or third-party resource was incorporated.

The consistency review was performed on 2026-11-10. I fetched public `refs/heads/main` from `https://github.com/daniel-castilho/sf2nes.git` into the isolated local ref `refs/review/public-main` at `e9baf3711e05f40d0b9551be7c945c763cb8f36e` (remote configuration verified first; `origin` points to that URL in the workspace where this pass was performed). Its recorded Git commit timestamp is 2026-11-17 23:15:59 -05:00, later than the review date and the supplied current date; this chronology anomaly is recorded rather than silently changing the review date or choosing an older baseline. I updated documentation paths, corrected the contradiction between required gameplay pointers and the intentionally null AI pointer, separated arcade evidence from NES-ROM acceptance, recorded bank `$05` as assigned to Ken's partial states, made explicit the blockers for aerial throws whose direction/threshold remain undecided, and noted the missing formal reference for approval of that requirement. The 2026-11-18 reconciliation started from public `main` at `50d937680b17aecaac028be4e2aada5b83a991ed`, kept the corrections from that revision, and recorded P10 as an approved decision: four NES combinations (Boom LP/HP and Flash Kick LK/HK), with no medium variant. Claims not supported by workspace evidence were removed. No code, ROM, assets, or tools were modified, and no tests, builds, or emulators were run. This specification remains a proposal for implementation; D-04, P10, and the Phase 2 bank allocation were approved separately, and the Maintainer supplied the definitive pose/move coverage list recorded in §5.1. That list was subsequently revised to exclude Knee Pad because the NES scheme has no MK class. Generation, builds, tests, and emulator runs still require D-05.
