# Implementation specification — Ken as second fighter

**Status:** proposal ready for implementation, with secondary arcade parameters still candidates; consult §3.1 and do not declare values as measured on the board.  
**Project:** Street Fighter II NE (`daniel-castilho/sf2nes`)  
**Documentation base consulted:** `main` / `9ba9b88`  
**Behavioral reference:** *Street Fighter II: The World Warrior*, World 910522 (`sf2`); published data below are candidates from secondary sources, not own board measurements.  
**Last documentation revalidation:** 2026-11-10.  
**Scope:** Stage 3 — make Ken playable as human ID `1`; do not implement other characters.

## 1. Objective

Integrate Ken as second human-playable fighter in SF2 NES, ID `1`, reusing common engine and Ken resources already present in the cartridge. Delivery must allow selecting him and completing a normal fight, using Ryu as structural engine reference, but preserving Ken's *World Warrior* behaviors identified in §3.1 (instead of assuming full equivalence of frames, boxes, or move results).

No equality of size, bytes, or hash with original ROM is required. Game content may grow; original ROM remains only as historical reference, not as build oracle or acceptance criterion.

## 2. Sources of truth and limits

Before altering generated sources or character data, consult, in this practical order:

- `docs/ROADMAP.md` — Stage 3 plan and preliminary data;
- `docs/ARCHITECTURE.md` — banks, engine, and roster tables;
- `docs/FORMATS.md` — sheet, states, frames, metasprites, collision, and moves;
- `annotations/sf2ne.ann`, `Makefile`, `sf2ne.cfg` and sources in `src/` — actual generation, assembly, and linking flow.

When documentation diverges from current code/annotations, record the divergence and update relevant documentation in the same change set. Do not copy code or data from other ports. Use external references only to clarify behavior; implementation must follow this project's formats and engine.

### Within scope

- State/transition data necessary for Ken.
- Ken connection to sheet, selection, and fighter loading.
- Reuse of existing Ken graphics already in bank `$04` and existing selection resources.
- Compatibility with common movement, attack, defense, damage, animation, and round engine.
- Build adjustments necessary to produce new ROM without requiring equality with original ROM.
- Architecture/roadmap documentation and build instruction updates.

### Out of scope

- Implementing Chun-Li, Guile, or any other incomplete character.
- Creating a new fighting engine, redesigning selection screen, or redoing command system.
- Implementing Ken-specific AI in this delivery. In one-player scenario, CPU opponent remains Ryu; do not accidentally route a CPU to nonexistent Ken AI data.
- Creating automated tests, regression scripts, test infrastructure, or CI gates. **No automated tests in this milestone.**
- Requiring perfect numerical balance parity with arcade. Use public versioned Ken data as candidates before falling back to Ryu parameters; Ryu reuse is only structural/technical fallback, and every unmeasured value must be marked provisional. Do not simplify Ken differences identified in §3.1 into a palette swap.

## 3. Relevant current facts

- Engine loads a sheet indexed by `FighterChar` in bank `$3C`; column `0` (Ryu) is the only filled fight sheet.
- Column `1` already corresponds to Ken. `CharFrameBankTbl[1]` points to `$04`; bank `$04` contains about 4.3 KB of Ken resources, including frames not connected to engine and portrait.
- `CharStateBankTbl[1]` is still `$00` (placeholder). Documentation proposes bank `$05`, mapped in window `$A000`, for Ken state data.
- `D3C_80DC[1]` already contains `$04`; confirm in code and frame data whether this value is indeed the adequate origin of Ken collision boxes before depending on it.
- Sheet contains 23 tables of 10 positions: 10 pointer pairs (low/high bytes) and 3 bank selection tables. Loader is in `FighterLoadChar` (`3B:E000`). Documented particularity: high byte of first pointer is read without index; this assumes all state banks are mapped at `$A000` and high byte is `$A0`.
- `CharNameTbl`, portrait, country/voice and victory phrases already have Ken entries. Reuse them; do not create duplicate content.
- `AiCharRoutine` only has Ryu implementation. Do not declare Ken AI supported in this delivery.
- `make` currently goes through `verify`, which compares assembled file byte-by-byte with `rom/sf2ne_demo.nes` and requires historical SHA-1. This rule is incompatible with new project direction and must cease to be a main build requirement.

These facts are starting points for implementation, not a substitute for verifying routines, addresses, and assets in working checkout.

### 3.1 World 910522 reference behavioral audit

The repertoire and distinctions below delimit what approximating Ken from arcade means. Table triangulates versioned community sources; does not declare input testing on ROM. Frame/damage numbers remain candidates, not final NES balance values.

| Aspect | Secondary evidence for *World Warrior* | Consequence for requirement |
|--------|----------------------------------------|------------------------------|
| Base specials | Hadouken, Shoryuken, and Tatsumaki Senpukyaku appear in Japanese versioned lists and SuperCombo WW table. | Keep these three as special set; do not add air Tatsumaki, Shoryureppa, or kick techniques from later revisions. |
| Characteristic normals | SuperCombo WW lists Axe Kick as close HK and Drop Knee as air LK. | RF-3 must account for close/far selection and these variants in normal inventory; do not treat them as specials nor assume swapping Ryu sprites produces correct Ken pose/box. Secondary source, confirm link to real Ken asset. |
| Ground throws | Versioned commands: near + forward/back + MP/HP for arm/shoulder throw; near + forward/back + MK/HK for leg throw. Japanese page calls them 背負い投げ (Seoi Nage) and 地獄車 (Jigoku Guruma); SuperCombo uses Seoi Nage and Tomoe Nage; English FAQs use Arm/Shoulder Throw and Back Roll. | Two functional mandatory moves, not just generic "throw". Preserve capture distance, trajectory/fall, unique damage, and displacement differences. For second, register names as divergent aliases and specify by command/result until revision nomenclature resolved. Do not confuse capture range with thrown distance. |
| Kick throw difference | A SuperCombo matchup page describes Ken's kick throw as advantage over Ryu; community source describes it as farther throw. No common displacement measurement in consulted reference. | Do not automatically reuse Ryu's kick throw endpoint/knockback. Qualitative direction "throws farther" is behavior hypothesis to verify; do not fix pixels or frames. |
| Tatsumaki — force and multi-hit | SuperCombo WW lists 1 hit for Short, 2 for Forward, 3 for Roundhouse; also publishes candidate startup/duration/damage. Other general sources say Ryu and Ken were nearly clones in World Warrior and strong multi-hit divergence consolidated in later revisions. | Keep hit count as force-specific difference to verify. NES only exposes weak/strong punch/kick classes: decide/document mapping of two forces to available arcade levels, without inventing medium button; do not declare full three-level equality. Do not copy Ryu's multi-hit profile without justifying adaptation. |
| Shoryuken | SuperCombo WW notes greater horizontal range than Ryu's and publishes candidate counts/damage per force; flaming fist fame is attributed by historical sources to Super Street Fighter II, not World Warrior. | Preserve as hypothesis possible per-force range difference; keep Shoryuken **without fire/target effect** on World 910522 target. Numerical metrics are not mandatory criterion in this stage. |
| Hadouken | Command is same as Ryu/Ken family; SuperCombo WW and 1999 FAQ describe force variants, and FAQ states stronger punches accelerate projectile. | NES commands already have two classes weak/strong; speed per class must be explicitly associated, but not copied from Ryu nor quantified without validation/versioning. |
| Commands and arcade medium | Arcade has LP/MP/HP and LK/MK/HK; NES engine documents four `InputAttack` classes: weak/strong punch and weak/strong kick. | Use existing NES interface and map two forces, preserving relevant result differences. Arcade medium force does not exist as separate class in current scheme; do not alter controls nor declare six forces supported without explicit decision. |
| Later revisions | Brazilian general pages mix air Hurricane Kick, additional specials, and Super; SFII Turbo/CE/Super sources are not proof of World 910522. | Exclude Air Tatsumaki, Shoryureppa, advanced kick techniques, and Shoryuken fire, unless new scope decision and specific version confirmation. |

**Arcade scope conclusion:** Ken resembles Ryu in *World Warrior*, but it is not safe to translate "clone" as "copy all states, boxes, and parameters". Attention points supported by consulted material are the two throws (especially kick throw result), close HK/Axe Kick, air LK/Drop Knee, possible Shoryuken range difference, and per-force Tatsumaki hit counts. Published values may guide later validation, but this specification does not state they were measured on World 910522 board.

### 3.2 Public reference values — candidates, not oracle

| Group | Published value | Permitted use in this specification |
|-------|-----------------|-------------------------------------|
| Normals | SuperCombo WW lists examples: standing LP `6`, MP `16`, HP `26`, LK `8`, MK `16`, HK `22`; close HK appears `24,6` (components presented by wiki). | Illustrates that attacks should not be reduced to a common per-force table nor Ryu damages copied. Do not directly convert to NES HP/frames; consult full wiki data only to plan validation. |
| Throws | SuperCombo WW: damage `32`, duration `130`, stun `7–13`, timer `100`, axial range `48`, range advantage `19`. T.Akiba/NKI: "Ken toss" line for WW `38` normal / `39` when behind, in *Capcom Generations 5* (PlayStation) data. | Values from different sources/platforms not reconciled. Do not choose final number nor convert range to NES pixels. Eventual kick throw launch distance is distinct property from capture range. |
| Hadouken | SuperCombo WW: damage `12`, stun `13–19`, timer `120` across three forces; GameFAQs 1999 says stronger force accelerates projectile. | Numbers and speed differences are secondary candidates; verify relevance to target and NES scale before using. |
| Shoryuken | SuperCombo WW publishes damage sequence `32/32,16` and advantages `-11/-22/-33` per force; summarized format insufficiently explains multi-hit component interpretation. | Keep only as observation clue, without inferring hit count, final damage, or recovery frames. Absence of fire in WW is clearest version restriction. |
| Tatsumaki | SuperCombo WW discriminates `1/2/3` hits for Short/Forward/Roundhouse. Hitbox tables are community data and may vary by reading/revision. | Prioritize per-force qualitative difference as candidate. NES must map available classes and declare medium force not represented; do not assign NES damage based on this count alone. |

Do not replicate extensive tables, images, hitboxes, or assets from sites; record only behavioral requirements and references for verification, respecting licenses. Quantitative validation belongs to implementation stage and was not executed in this documentation revalidation.

## 4. Functional requirements

### RF-1 — Selection and loading

- Ken must be selectable as human fighter in existing flow, using character ID `1`.
- Loader must obtain for Ken all required pointers/tables; no required fight pointer may remain `$0000` or accidentally inherit Ryu's column.
- Must work for P1 slot and P2 slot when configured as human by existing versus mode. In one-player mode, CPU opponent remains Ryu.
- Ken selection must not make other characters without implemented sheet selectable as playable fighters. If current navigation allows reaching them, apply only minimum protection necessary to prevent loading empty data; do not implement other characters.

### RF-2 — Graphics and presentation

- Selection must display Ken's existing name and portrait.
- In fight, each Ken state/frame must point to valid metasprites from existing assets in bank `$04`, using correct CHR pages and palette.
- Do not assume Ken frame order or offsets equal Ryu's. Inventory necessary states/frames and map each reference to Ken resources after inspecting actual registers.
- No incorrect tiles/palettes, corrupted sprites, or out-of-bank reads during animations or mirroring.

### RF-3 — Fight move set

Ken must complete a round using existing rules and controls. Cover base fight set and preserve known reference differences:

- neutral, turn, walk forward/back, crouch, neutral/diagonal jumps, and landing;
- normal attacks in standing/crouching/air button scheme, with close/far selection when applicable; include close HK (Axe Kick, secondary WW source) and air LK (Drop Knee, secondary WW source) in state/animation inventory;
- high/low guard, damage reaction, hit-freeze/knockdown, fall, KO, and return to round flow;
- two ground throws: near + forward/back + strong punch (NES adaptation of arcade MP/HP family) and near + forward/back + strong kick (MK/HK); ensure eligible capture, own exit/fall, single damage application. Do not automatically inherit Ryu's kick throw displacement;
- Hadouken, Shoryuken, and Tatsumaki with commands already supported by engine; associate transitions to Ken's own states. Arcade has three forces and NES two classes per family: map weak/strong without claiming medium variant. Preserve distinct Hadouken speeds as published hypothesis; treat greater Shoryuken range and Tatsumaki hits as differences to verify. World 910522 receives no Shoryuken fire nor air Tatsumaki from later revisions.

Reuse common logic only after verifying command semantics, transition destinations, and Ken effects; using Ryu bank/tables as starting point does not authorize assuming frame/hitbox/result equivalence.

Use `docs/FORMATS.md` as reference for states, frame chaining, classes, effects, attack/body boxes, and hit count. Data must result in collisions compatible with visual frames; it is not enough to swap sprite bank keeping Ryu boxes that clearly don't match Ken's pose.

### RF-4 — Audio and conclusion

- Use Ken's existing entries in `CountryVoiceTbl` and `FighterVoiceTbl` when compatible with engine events. Do not invent DPCM sample indices.
- Name, voice, and final phrase existing entries must remain indexed by Ken. Not required to create new phrase or new samples.
- Fight must be able to advance through victory/defeat and normal transitions without locking or entering unimplemented tables.

## 5. Data and implementation requirements

1. **Audit assets before modeling states.** Generate/consult PNGs exported by `make assets` flow, locate Ken frames in CHR pages, and catalog which poses cover Ryu-inherited states. Register real gaps; do not assume every move has dedicated animation.
2. **Create state data in bank `$05` (`$A000`–`$BFFF`)**, starting from Ryu structure as reference. Bank must be relocatable and labels symbolic; do not copy words/absolute addresses from bank `$01` without remapping.
3. **Reuse engine, do not duplicate common routines.** Ken states must continue using engine contract: 7-byte state header, 14-byte frames (16 in loop cases), transitions/conditions and effects defined in `docs/FORMATS.md`.
4. **Fill column 1 of sheet `$3C`** for loader-required pointers (`$8000`–`$80BE`) and review three bank tables (`CharStateBankTbl`, `CharFrameBankTbl`, `$80DC`). Reuse common command table only after confirming indices and effects match; create Ken-specific transition table when destination states are Ken-specific.
5. **Wire bank configuration**: `CharStateBankTbl[1]` must select `$05`; frames must use `$04`; collision box source must be verified, not assumed.
6. **Annotate structural data** with `statebank` directive of `annotations/sf2ne.ann`, including correct state/frame range, and useful names/labels. Follow project flow for generated sources: edit appropriate annotation/source entries and regenerate `src/`; do not manually edit files marked as generated if annotation is source of truth.
7. **Do not add Ken AI for convenience.** If current flows can assign Ken to CPU, restrict or minimally redirect that selection, documented, keeping CPU on Ryu in this delivery.
8. **Main build:** canonical target must assemble and deliver modified ROM without comparing bytes/hash with demo. A separate historical verification may be kept, explicitly optional and not used as gate for new ROM. Do not delete original ROM nor its historical identification just to make build pass.
9. **Expansion:** do not preserve original byte count or quantity. Reuse free banks when convenient; if ROM needs more space, adjust linker configuration, NES/MMC5 header, bank count, and documentation consistently. Limit must be format/hardware and functional build, not original size parity.

## 6. Work sequence

| Phase | Work | Verifiable output |
|-------|------|-------------------|
| 1. Inventory | Map Ken frames/metasprites, palette, collisions, voices, and gaps vs fight set; register Axe Kick, Drop Knee, close/far, both throws, and candidate Hadouken/Shoryuken/Tatsumaki differences from §3.1. | Implementation note with bank/labels, source behavior, NES mapping, and gaps. |
| 2. Base state | Create relocatable Ken state bank with necessary common states; keep shared engine routines. | Labels and `statebank` directive identified data. |
| 3. Sheet | Fill column 1 tables/pointers and connect state bank, frames, collisions, specials, voice. | Loader resolves Ken sheet without empty pointers. |
| 4. Selection | Ensure human can choose Ken in supported slots; prevent flow from routing CPU to missing AI. | Documented and safe Ken vs Ryu selection path. |
| 5. Build | Adjust main target to produce modified ROM; remove original equality as success condition. | Assembled ROM + linker map/labels, if generated by project. |
| 6. Documentation and delivery | Sync architecture, formats, roadmap, and build instructions. | Current state, limitations, and clear usage instructions. |

## 7. Manual acceptance (no automated tests)

Do not create or execute test suites, regression scripts, automated A/B, or test gates in this milestone. Build/assembler/linker remains necessary to produce ROM — that is not an automated test.

Gameplay acceptance is manual in Mesen and must be reported as **not executed**, **failed**, or **approved**, without inferring approval from compilation. Manual session checklist:

- start new ROM and reach selection; choose Ken;
- confirm name/portrait and start fight against Ryu CPU;
- traverse movement, defense, normal attacks, close HK/Axe Kick, air LK/Drop Knee, and three specials with current commands;
- execute both ground throws and confirm eligibility, orientation, victim animation, fall, and single damage application; observe whether kick throw displaces victim differently than Ryu, without requiring unvalidated numeric distance;
- verify weak/strong variants in specials, speed/results, and document that NES has no medium class; confirm Shoryuken uses no fire effect and that no air Tatsumaki command exists for World 910522;
- confirm visuals, collisions/hits, damage/reaction, and round functioning until conclusion;
- repeat Ken choice in P2 slot if build includes human versus mode;
- confirm no crash, frozen screen, corrupted sprite, or accidental use of empty sheet/AI.

If Engineer does not execute manual acceptance, deliver ROM and instructions for user to validate. As evidence, prefer short video and/or reproducible Mesen `.mmo` film started before problem; use Trace Logger only for a specific execution window when necessary. Record Mesen version, build flags/config, and delivered ROM hash to identify artifact — this hash is metadata, not equality requirement with original.

## 8. Completion criteria

- [ ] Canonical build produces modified ROM without failing due to difference from original demo.
- [ ] Ken is linked to data tables and selectable/controllable in expected human slots.
- [ ] Necessary fight states work with Ken sprites, commands, collisions, and valid transitions; include two ground throws, Axe Kick/Drop Knee, and documented adaptation of arcade force variants to NES.
- [ ] CPU flow remains safe using Ryu; no claim of Ken AI.
- [ ] No other fighter declared implemented.
- [ ] No automated tests added; manual acceptance status explicit.
- [ ] README/roadmap/architecture/format and build instructions describe actual state, limitations, how to assemble, and where to find ROM.
- [ ] Delivery includes touched file paths, build command, configuration used, ROM path, and its hash for identification.

## 9. Risks and implementation decisions to record

| Risk | Expected treatment |
|------|-------------------|
| Ken frame order/layout differs from Ryu. | Make explicit state-to-Ken-resource map; do not use presumed offsets. |
| Ken frames lack boxes equivalent to inherited states. | Reuse/adapt Ken's own bank boxes if they exist; if drawing/replacing data needed, register which poses remain provisional. |
| Internal pointers keep pointing to bank `$01`. | Relocate and review all words/addresses; organize Ken state in labels in bank `$05`. |
| Some character sheet table left without pointer. | Verify 10 pointer tables and 3 bank tables before declaring sheet complete. |
| Build stuck on original hash or fixed ROM layout. | Fix main flow and update header/bank configuration; keep historical comparison separate and optional. |
| Existing voices/assets don't cover a necessary event. | Do not invent samples or data; document gap and request decision before creating out-of-scope content. |
| Full Ryu reuse erases Ken's World Warrior differences. | Use Ryu only as structural reference; review kick throw, Axe Kick, Drop Knee, and §3.1 special candidates. |
| Names/sources disagree on Ken's kick throw. | Prioritize observable behavior of F/B + strong kick command and capture result; document aliases (Jigoku Guruma / Back Roll / Tomoe Nage) without turning editorial divergence into extra moves. |
| Three arcade forces don't fit four NES input classes. | Map weak/strong per family and declare medium force not represented; do not alter control scheme in this delivery without explicit decision. |
| Secondary public data confused with World 910522 measurement. | Keep frame/damage/range numbers as candidates and distinguish them from board evidence; manual acceptance is implementer's future task, not spec prior evidence. |

## 10. Documentary inspiration applied

Five indicated repositories were consulted: [dargent](https://github.com/daniel-castilho/dargent), [spotpobre](https://github.com/daniel-castilho/spotpobre), [timao-flix](https://github.com/daniel-castilho/timao-flix), [tycoma](https://github.com/daniel-castilho/tycoma), and [url-shortener-service](https://github.com/daniel-castilho/url-shortener-service).

Specification adapts useful practices observed in those projects: explicit sources of truth, non-negotiable rules/limits, scope/out-of-scope separation, traceable requirements, phases with verifiable outputs, visible risks/pendencies, documentation synchronization, and completion definition. Discarded Java/Spring/React instructions, web architecture, deploy, service security, and test pipelines, as they don't apply to NES cartridge and current decision of no automated tests.

## 11. Behavioral references consulted in revalidation

- [SuperCombo Wiki — Ken, The World Warrior](https://wiki.supercombo.gg/w/Street_Fighter_2:_The_World_Warrior/Ken): versioned repertoire, move names, damage/frame tables, throws, and per-force variation notes. Community source; its numbers and hitboxes are candidates, not independent confirmed World 910522 board measurement.
- [SuperCombo Wiki — Ryu, The World Warrior](https://wiki.supercombo.gg/w/Street_Fighter_2:_The_World_Warrior/Ryu): secondary comparison of Tatsumaki and matchup; useful to detect when Ken spec inherits Ryu values without justification.
- [GameFAQs — Ryu/Ken Guide (ARC), RCarlos (1999)](https://gamefaqs.gamespot.com/arcade/583626-street-fighter-ii/faqs/848): identifies original arcade versions and describes throws/specials; states Ryu and Ken are equal in all aspects, generalization that must not replace specific throw/range observations. Old community account, without reproducible protocol.
- [homepage3gore — Ken, ストII](https://homepage3gore.game.coocan.jp/st2/ken_1.html): Japan-specific SFII list with Seoi Nage and Jigoku Guruma, commands of both throws, and three base specials. Concise community source; offers no frames/damages.
- [T.Akiba's SF2 Data, NKI translation](https://zachd.com/nki/ST/data.html): includes comparative throw/damage data; its own introduction states WW/CE/HF were tested on *Capcom Generations 5* (PlayStation), not directly on World 910522 board. Use only as candidate, especially where it diverges from SuperCombo.
- [Jogo de Luta — Ken in Street Fighter 2](https://jogodeluta.com.br/street-fighter/street-fighter-2/ken): Brazilian broad title/versioning source; page lists Air Hurricane Kick and Shoryu Reppa without clearly separating World Warrior from later revisions. Do not use these moves to expand 910522 set.
- [Critical Hits — Street Fighter 2 specials](https://criticalhits.com.br/games/street-fighter-2-todos-os-golpes-especiais/): Brazilian unsegmented-by-revision list includes extra/super techniques; useful only for Portuguese context, not as World Warrior proof. Separate Champion Edition page also excluded as target proof.

No reference in this list grants license to incorporate third-party images, data, code, or other assets. This revalidation incorporated only paraphrased requirements and behavioral facts, with indicated limitations; did not alter sources, assets, or ROM.
