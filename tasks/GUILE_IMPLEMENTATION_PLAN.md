# Guile Implementation — Execution Plan

**Project:** `daniel-castilho/sf2nes` (Street Fighter II NE, MMC5, 6502 assembly).
**Plan date:** 2026-11-18.
**Status:** execution plan for future implementation. Decisions recorded in §0 are Maintainer approvals; this document itself does not authorize generation, builds, tests, or emulator runs, which remain gated by D-05.
**Baseline:** public `main` at `50d937680b17aecaac028be4e2aada5b83a991ed`; reconciliation and Phase 1/2 documents are committed locally and not pushed.
**Language rule:** all source code, comments, documentation, and plan files are written in English.

---

## 0. Decision record

| ID | Decision | Status | Source |
|---|---|---|---|
| D-04 | Criteria and explicit decision to reopen character/feature implementation | **RESOLVED** by the Maintainer on 2026-11-18; recorded in `tasks/STABILIZATION_BACKLOG.md` and `docs/PROJECT_STATUS.md` | Maintainer instruction in the 2026-11-18 planning session |
| D-05 | Which future validations are authorized, by whom, and in what scope | `PENDING` | Blocks every build, generation, test, and emulator run |
| P8 | Provenance/license of sprites, palettes, audio, and hitboxes | `PENDING` | Blocks asset work |
| P9 | Exact directions/buttons accepted by aerial throws in World 910522 | `PENDING` | Blocks aerial-throw acceptance |
| P10 | Mapping of three arcade strengths to NES controls | **APPROVED (2026-11-18)**: Sonic Boom LP/HP, Flash Kick LK/HK, two strengths per special, no medium variant | Implementation validation only; the control decision is closed |
| P11 | Traceability of the decision making aerial throws mandatory | `PENDING` | Blocks aerial-throw implementation claim |
| Bank allocation | Guile state/frame/hitbox banks and CHR pages | **APPROVED (2026-11-18)**: state `$09`, frame/hitbox `$14`, CHR `$39`/`$3A` plus `$3B` reserve | `tasks/GUILE_BANK_ALLOCATION.md` §7; Maintainer answers Q1–Q3 |
| CPU scope | Whether Guile must work as CPU | **APPROVED (2026-11-18)**: P1/human only; AI pointer stays null; CPU stays Ryu | Maintainer answer Q4 |
| Projectile path | How Sonic Boom uses the shared projectile engine | **APPROVED (2026-11-18)**: parameterize the shared hit/draw path | Maintainer answer Q5 |
| P10 mechanism | How Flash Kick LK/HK is implemented | **APPROVED (2026-11-18)**: audited global remap of `CmdKeyAttackTbl[0C]/[0D]`; no wider remap | Maintainer answer Q6; Phase 1 consumer audit |
| Pose/move coverage | Definitive Guile animation/state coverage (Q7) | **APPROVED (2026-11-18)**: full list recorded in `tasks/GUILE_BEHAVIORAL_ENGINEERING_SPEC_EN.md` §5.1 | Defines coverage only; no frame counts, damage, hitboxes, or NES binding for Knee Pad |

D-04, P10, the Phase 2 allocation, CPU scope, projectile path, the P10 mechanism, and the pose/move coverage list are resolved. P8 (legal provenance, conversion, numeric values), P9, P11 and D-05 stay open and are treated as gates below. Resolving them later does not require rewriting this plan; it only opens the corresponding gate.

### Non-negotiable constraints

1. Do not allocate bank `$05` to Guile; it holds Ken's hand-written partial states (`src/bank_05.s`, `docs/ARCHITECTURE.md`).
2. The only approved global `CmdKeyAttackTbl` change is the remap of keys `$0C`/`$0D` to LK/HK; no wider remap is allowed without a new decision. Do not connect `$3F:E0C7` to Guile without demonstrated semantics.
3. Do not copy Ryu's fiche pointers, state order, frame counts, or offsets by assumption.
4. Do not add Guile AI; the AI pointer stays null and CPU must not be routed to Guile (approved Q4).
5. Preserve the existing portrait path `PortraitWinLayoutTbl+6` (`3C:84AC`) → `D0C_8000` unless a documented replacement is proven.
6. `sf2ne.cfg` is **generated** by `tools/disasm.py`; allocation changes go through `annotations/sf2ne.ann` (`keepbank BB`) plus `make gen`, never by hand-editing the cfg.

---

## 1. Verified baseline

All values below were read from the source tree at `50d9376` during this planning pass.

### 1.1 Fiche and bank selectors (column 3 = Guile)

| Item | Location | Current value |
|---|---|---|
| Direction transition, low byte | `CharDirTransLoTbl+3` (`3C:8003`) | `$00` |
| Direction transition, high byte | `CharDirTransHiTbl` (`3C:800A`), read without `,y` | `$A0` for every character |
| Effective direction pointer | — | `$A000` (Ryu's first table in bank `$01`) |
| State bank | `CharStateBankTbl+3` (`3C:80C8`) | `$01` |
| Frame bank | `CharFrameBankTbl+3` (`3C:80D2`) | `$0C` |
| Hitbox bank | `CharHitBoxBankTbl+3` (`3C:80DC`) | `$00` |
| Other 9 fiche pointer pairs | `3C:8000–80BE` | `$0000` |
| Portrait layout | `PortraitWinLayoutTbl+6` (`3C:84AC`) | `D0C_8000` |
| Name | `CharNameTbl` (`3C:84CE`), index 3 | `GUILE` |
| Selection cursor | `SelectCursorFighterTbl` (`37:F293`) | cursor 2 → fighter ID 3 |
| Country voice | `CountryVoiceTbl+3` (`37:E0EF`) | `$0C` |
| Fighting voice | `FighterVoiceTbl` record at `$E129` | 16 bytes, all `$FF` |

`FighterLoadChar` (`3B:E000`) copies the three bank selectors and the direction pointer into `FighterFrameBank`, `FighterStateBank`, `zp_1C`, and `ram_031E/0320`. The high-byte read at `3B:E025` (`lda CharDirTransHiTbl`) has no `,y`, so every character receives high byte `$A0`.

### 1.2 Engine integration points

| Area | Labels / addresses |
|---|---|
| Round init | `FighterRoundInit` (`3B:E098`); reads state header at `(state ptr)+0/+1`, then state/frame pointers at `+3/+4` |
| Draw | `DrawFighter` (`3B:EDD9`), `DrawMetasprite` (`3B:F2EA`); metasprite byte 0 → `FighterChrPage,x` |
| NMI CHR | `NmiHandler` (`kernel.inc`), `FighterChrPage` → `$5121`, `FighterChrPage+1` → `$5123` |
| Command parser | `CmdStepCharge` (`3F:EA9C`, marked `(nt)`), `CmdMotionTbl`, `CmdKeyAttackTbl`, `CmdKeyListRyu` (`3F:E0C0`), unused artifact `3F:E0C7` |
| Projectile | `ProjLaunch` (`3F:E837`), `ProjUpdate` (`3F:E854`), `ProjClash` (`3F:E8BB`), `ProjHitTest` (`3F:E8F1`), `ProjHit` (`3F:E941`) |
| Projectile draw | `3B:F27F`, table `D3B_E57D`, bank `$20`, byte 0 → `$5125` |
| Throws | `GrabCheck`/`GrabCheckOne` (`3F:F033/F03C`), `CondCanGrab` `$09` (`3F:E22E`), `StateCondLo` (`3F:E171`) / `StateCondHi` (`3F:E17D`) with 12 entries `$00–$0B` |
| AI | `AiCharRoutine` has Ryu only; Guile's fiche AI pointer is null |

`ProjHit` hardcodes `HitReactClass = $CB` and damage `$6C` (12 + chip 3). A Guile projectile reusing it would inherit Ryu's reaction class and damage.

### 1.3 Space budget (reference ROM, 64 × 8 KB PRG, 256 × 2 KB CHR)

| Metric | Value |
|---|---|
| PRG banks fully `$FF` | 36 of 64 |
| CHR pages fully `$FF` | 198 of 256 |
| Ryu frame bank `$00` | 5193 bytes used, 2999 free |
| Ken frame bank `$04` | 4303 bytes used, 3889 free |
| Guile portrait bank `$0C` | 56 bytes used, 8136 free (`$8038–$9FFF`) |
| Bank `$3B` (kernel/common) | 133 bytes free |
| Bank `$3F` (commands/throws) | 867 bytes free |
| Free `$A000`-window banks (n mod 4 = 1) | `$09`, `$0D`, `$11`, `$15`, `$19`, `$1D`, `$21`, `$25`, `$31`, `$35`, `$39`, `$3D` |
| Free `$8000`-window banks (n mod 4 = 0) | `$14`, `$18`, `$28`, `$2C`, `$30`, `$34`, `$38` |

A Guile frame set comparable to Ken's needs roughly 3–5 KB, so bank `$0C` (8136 free) or a fresh `$8000`-window bank both fit.

### 1.4 Source-generation model

- `make gen` runs `tools/disasm.py`, rewrites every `src/bank_*.s` **except** banks declared `keepbank BB`, and rewrites `sf2ne.cfg` from the set (non-empty banks ∪ keepbanks).
- `src/bank_05.s` is hand-written and protected by `keepbank 05` (`annotations/sf2ne.ann:2166`).
- `tools/state_data_gen.py` + `data/estados/*.toml` + `make gen-states` is an existing, non-destructive alternative path for state/frame assembly.
- `make` is the canonical build; `make verify` is an optional historical comparison against the original ROM.

---

## 2. Gates and authorization matrix

| Action | Gate |
|---|---|
| Read sources, measure ROM bytes, write English documentation | None (allowed) |
| Edit `tasks/`, `docs/`, `annotations/` text | None, subject to English-only rule |
| Add a hand-written bank (`src/bank_XX.s` + `keepbank`) | Bank allocation approved by Maintainer (§3 Phase 2) |
| Run `make gen` / `make gen-states` | D-05 |
| Run `make` / `ld65` / inspect fresh map | D-05 |
| Produce sprites, palettes, hitboxes, audio | P8 |
| Apply the approved `CmdKeyAttackTbl[0C]/[0D]` remap | Approved (Q6); Phase 1 consumer audit complete. Any wider remap needs a new decision |
| Implement aerial throws | P9 + P11 |
| Run Mesen/MAME validation | D-05 |

---

## 3. Phases

Each phase lists its objective, work, deliverable, exit criterion, and gate.

### Phase 0 — Documentation reconciliation (no code)

**Objective:** make the written baseline match `50d9376` and record D-04.

**Work:**
1. In `tasks/GUILE_BEHAVIORAL_ENGINEERING_SPEC_EN.md`, keep the committed content of `50d9376`. Accept from the uncommitted draft only additions that are verifiable in source.
2. Remove from the draft: the false "no configured Git remote" claim, the `refs/remotes/external/main` reference, the Portuguese companion line, `CountryVoiceTbl` at `3F:E0EF`, bare addresses replacing table labels, the "aerial throws — approved requirement" heading, and the unsupported MAME paragraph.
3. Remove the §2.3 "Later controlled-input attempt (MAME 0.276)" paragraph and the matching §10 sentence: no Lua script, log, `.mmo`, or binary artifact exists in the workspace, and emulator execution is not authorized.
4. Record P10 as an approved decision (LP/HP Sonic Boom, LK/HK Flash Kick) and keep P9, P11, and P8 as open items.
5. Update `Last reviewed` to the real review date.
6. Record D-04 as resolved (date, source) in `tasks/STABILIZATION_BACKLOG.md` and `docs/PROJECT_STATUS.md`.

**Deliverable:** one documentation commit.
**Exit:** no false remote/PT/address claims remain; D-04 shows resolved; P10 shows approved; P8/P9/P11/D-05 still open.

### Phase 1 — Static audit and data map (documentation only)

**Objective:** turn every implementation step into a label-and-address fact before writing data.

**Status: COMPLETE.** Delivered as `tasks/GUILE_IMPLEMENTATION_AUDIT.md` (commit `de011b9`). All seven audit questions were answered by the Maintainer on 2026-11-18; the Q7 pose/move coverage list is recorded in `tasks/GUILE_BEHAVIORAL_ENGINEERING_SPEC_EN.md` §5.1.

**Work — produce `tasks/GUILE_IMPLEMENTATION_AUDIT.md` (English) covering:**
1. Fiche column 3, byte by byte, for all 10 pointer pairs (`3C:8000–80BE`), with the effective value and the target label.
2. The direction-pointer quirk (`3B:E025`) and what it implies for the low byte.
3. State-bank candidates in the `$A000` window, with measured free bytes and confirmation that the bank is unreferenced.
4. Frame-bank options: reuse `$0C` (keeps `CharFrameBankTbl[3]` unchanged, shares the bank with `D0C_8000`) versus a fresh `$8000`-window bank (requires a one-byte fiche change and leaves the portrait untouched). Include a size estimate.
5. Hitbox-bank option: share the frame bank (as Ken does with `$04`) versus a dedicated bank.
6. CHR inventory: free pages, portrait page `$0C`, and the exact rule that couples `FighterChrPage`, `FighterChrPage+1`, tile bit 0, and `zp_E4`. Record it as an explicit open question if the engine requires a shared page pair per match.
7. Palette record layout (`CharPal0FightTbl` `3C:80E6`, `CharPal1FightTbl` `3C:815E`, win/lose tables) and Guile's columns.
8. Voice slots: `CountryVoiceTbl` (present) and `FighterVoiceTbl` `$E129` (all `$FF`).
9. Selection, VS, and quote flow, plus every place that routes a fighter to CPU.
10. Command recognizer: `CmdMotionTbl` entries, `CmdKeyAttackTbl` consumers, `CmdKeyListRyu`, and the `3F:E0C7` artifact.
11. Projectile parameterization points, including the hardcoded `$CB`/`$6C` in `ProjHit` and the drawing table `D3B_E57D`.
12. Throw condition/dispatcher limits: 12 condition slots, `GrabCheck` state family `$A0–$A8`, reaction class `$0C`.

**Deliverable:** `tasks/GUILE_IMPLEMENTATION_AUDIT.md`.
**Exit:** no implementation step remains without a label and an address; every unknown is listed as an explicit question.

### Phase 2 — Allocation proposal

**Objective:** choose banks and pages before writing data.

**Status: COMPLETE — APPROVED (2026-11-18).** Delivered as `tasks/GUILE_BANK_ALLOCATION.md` (commit `ed461fd`). Approved allocation: state `$09`, shared frame/hitbox `$14`, CHR `$39`/`$3A` plus `$3B` reserve. The approval is recorded in §0 and in the allocation document §7.

**Work:**
1. Recommend a state bank from the free `$A000`-window set, excluding `$05`, `$29`, `$2D`.
2. Recommend a frame bank and a hitbox bank, with the trade-offs from Phase 1.
3. Recommend CHR page(s) for fighting sprites, separate from portrait page `$0C`.
4. State the exact changes required: `keepbank BB` in `annotations/sf2ne.ann`, the `SEGMENTS` entry that `make gen` will emit, and the fiche bytes to change.
5. Verify by reading the reference ROM that every chosen bank is fully `$FF` and unreferenced.

**Deliverable:** `tasks/GUILE_BANK_ALLOCATION.md`.
**Exit:** Maintainer approval of the allocation — granted 2026-11-18. **Gate:** bank allocation — resolved; no source/annotation/build change has yet been applied.

### Phase 3 — Asset production (P8 gate)

**Objective:** obtain legally usable art and audio.

**Work:**
1. Use the Maintainer-approved pose/move coverage in `tasks/GUILE_BEHAVIORAL_ENGINEERING_SPEC_EN.md` §5.1. Do not derive the set from Ryu's 94 poses by default, and do not invent frame counts, damage, or hitboxes.
2. Produce or license-verify sprites, palettes, per-frame hitboxes, and audio.
3. Document origin, license, conversion steps, tile budget, and CHR page assignment.
4. Register any gap explicitly; do not invent samples or data.

**Deliverable:** asset provenance record plus converted data.
**Exit:** P8 resolved and every asset traceable. **Gate:** P8.

### Phase 4 — Frame and hitbox bank data

**Objective:** build the metasprite and collision records.

**Work:**
1. Write metasprite records: CHR page byte, sub-metasprites, groups `[n][dx][dy][tiles]`, terminator `≥ $80`.
2. Write collision records: three boxes `[height][dy][dx][width]`; `height = 0` consumes only the height byte.
3. Use symbolic labels only; no copied absolute cross-bank addresses.
4. Verify signed offsets and total size against the chosen bank.

**Deliverable:** frame/hitbox data in the allocated bank.
**Exit:** every record resolves by label and fits.

### Phase 5 — Fiche wiring

**Objective:** make the loader resolve Guile to Guile-owned data.

**Work:**
1. Fill column 3: direction low byte, button, special, guard, standing/crouch/neutral reactions, throws, command list. Leave the AI pair null.
2. Set `CharStateBankTbl[3]`, `CharFrameBankTbl[3]`, `CharHitBoxBankTbl[3]`.
3. Preserve `PortraitWinLayoutTbl+6` → `D0C_8000`.
4. Verify that no pointer required by the human-controlled flow is zero.

**Deliverable:** fiche changes.
**Exit:** `FighterLoadChar` copies only Guile-owned pointers.

### Phase 6 — State bank

**Objective:** author the state set.

**Work:**
1. Cover at minimum: idle, walk forward/back, crouch, jump, guard, standing/crouch/neutral hit reactions, knockdown, get-up, win, lose, plus the normal attacks in scope.
2. Follow the 7-byte state header and 14-byte frame record (16 in loop cases) from `docs/FORMATS.md`.
3. Use Ryu as a structural reference only; relabel every internal pointer.
4. Choose the authoring path decided in Phase 2: hand-written bank with `keepbank`, or TOML + `make gen-states`.

**Deliverable:** state bank source.
**Exit:** `FighterRoundInit` loads a valid state and frame pointer for Guile.

### Phase 7 — Specials

**Objective:** implement Sonic Boom and Flash Kick.

**Work:**
1. Sonic Boom: frame with effect `$0B` triggers `ProjLaunch`; verify spawn offsets and direction bit.
2. Parameterize the shared `ProjHit`/draw path so Guile does not inherit `$CB`/`$6C`; use table-driven values (Q5 approved).
3. Flash Kick: charge down → up; anti-air collision boxes; coherent landing.
4. Command list `[08,09,0C,0D,FF]`; apply the approved global remap of `CmdKeyAttackTbl[0C]/[0D]` to LK/HK (`$02`/`$03`). No other key changes.
5. Do not connect `3F:E0C7` without demonstrated semantics; the approved remap does not by itself prove list order.

**Deliverable:** special states, command list, projectile parameterization.
**Exit:** both specials reachable and distinguishable by strength. **Gate:** P10 and its mechanism are approved; implementation validation still requires D-05.

### Phase 8 — Throws

**Objective:** implement ground throws and prepare aerial throws.

**Work:**
1. Ground throws: dedicated throw tables, `GrabCheck` integration, reaction class `$0C`, single damage application.
2. Aerial throws: new condition code, extension of `StateCondLo/Hi` and `StateCondDispatch` beyond the 12 existing entries, both-airborne eligibility.
3. Do not weaken `$09` so that ground throws become aerial.

**Deliverable:** throw tables and, if gated open, the dispatcher extension.
**Exit:** ground throws accepted; aerial throws either implemented under P9+P11 or explicitly reported as gated.

### Phase 9 — Presentation

**Objective:** complete the selection and presentation path.

**Work:**
1. Name and portrait already exist; verify they still render after the fiche change.
2. Assign the fight palette and the country voice; fill the fighting voice slot only if P8 supplies audio.
3. Verify selection in both slots and that CPU never receives Guile.

**Deliverable:** presentation wiring.
**Exit:** Guile selectable and presented; CPU stays on Ryu.

### Phase 10 — Build and link (D-05 gate)

**Objective:** produce the ROM and prove the layout.

**Work:**
1. Apply the annotation/cfg changes, run `make gen`, then `make`.
2. Review `build/sf2ne.map` and `build/sf2ne.labels`.
3. Confirm only the intended banks changed; keep `make verify` as an optional historical check.

**Deliverable:** built ROM, map, labels.
**Exit:** assembles cleanly and the map places Guile data in the allocated banks. **Gate:** D-05.

### Phase 11 — Manual validation (D-05 gate)

**Objective:** validate behavior in an emulator.

**Work:**
1. Run the Mesen checklist adapted from `tasks/KEN_IMPLEMENTATION_SPEC.md` §7.
2. Record status as not executed, failed, or approved; never infer approval from compilation.
3. Capture evidence: short video or `.mmo` film, emulator version, build flags, ROM hash.

**Deliverable:** acceptance report in `tasks/`.
**Exit:** explicit status per checklist item. **Gate:** D-05.

### Phase 12 — Documentation closeout

**Objective:** make the documentation describe the delivered state.

**Work:** update `docs/ARCHITECTURE.md` (bank map, roster, free space), `docs/FORMATS.md` if a format was extended, `docs/ROADMAP.md`, `docs/PROJECT_STATUS.md`, `tasks/STABILIZATION_BACKLOG.md`, and the Guile spec status. English only.

**Deliverable:** documentation commit.
**Exit:** no document claims more than the delivered state.

---

## 4. File impact map

| File | Phase | Change |
|---|---|---|
| `tasks/GUILE_BEHAVIORAL_ENGINEERING_SPEC_EN.md` | 0, 12 | Reconcile with `50d9376`; update status at closeout |
| `tasks/STABILIZATION_BACKLOG.md` | 0, 12 | D-04 resolved; later status updates |
| `docs/PROJECT_STATUS.md` | 0, 12 | D-04 resolved; delivered state |
| `tasks/GUILE_IMPLEMENTATION_AUDIT.md` | 1 | New |
| `tasks/GUILE_BANK_ALLOCATION.md` | 2 | New |
| `annotations/sf2ne.ann` | 2, 5, 6 | `keepbank` for new banks; labels/comments for new data |
| `src/bank_3C.s` (generated) | 5 | Fiche column 3 and bank selectors, via annotations |
| `src/bank_XX.s` (new) | 4, 6, 7 | Guile frame/hitbox/state data |
| `src/bank_3F.s` (generated) | 7, 8 | Only if `ProjHit` or the condition tables are parameterized, via annotations |
| `sf2ne.cfg` (generated) | 2 | Emitted by `make gen`; never hand-edited |
| `docs/ARCHITECTURE.md`, `docs/FORMATS.md`, `docs/ROADMAP.md` | 12 | Bank map, roster, formats, status |
| `tasks/GUILE_ACCEPTANCE_REPORT.md` | 11 | New |

Do not touch `src/bank_05.s`.

---

## 5. Open decisions register

| # | Question | Status / blocks | Owner |
|---|---|---|---|
| 1 | State bank, frame bank, hitbox bank, CHR pages | **RESOLVED (2026-11-18)**: `$09`, `$14`, `$39`/`$3A` + `$3B` | Maintainer |
| 2 | Reuse bank `$0C` for frames or allocate a new bank | **RESOLVED**: new bank `$14`; `$0C` unchanged | Maintainer |
| 3 | Exact `FighterChrPage` pairing rule for two fighters | Open; D-05 validation; CHR pages reserved provisionally | Engineer + D-05 |
| 4 | `ProjHit` parameterization: table or per-fighter branch | **RESOLVED**: parameterize shared path | Maintainer (Q5) |
| 5 | `CmdKeyAttackTbl`: per-character mapping or audited global remap | **RESOLVED**: audited global remap of `$0C`/`$0D` only | Maintainer (Q6) |
| 6 | Aerial-throw directions and acceptance rule | Open; blocks Phase 8 | Maintainer (P9, P11) |
| 7 | Approved Guile pose/move coverage | **RESOLVED (2026-11-18)**: spec §5.1 | Maintainer (Q7) |
| 7a | Legally usable assets, conversion, and numeric values | Open; blocks Phase 3/4 | Maintainer (P8) |
| 8 | Build/test/emulator authorization | Open; blocks Phases 10–11 | Maintainer (D-05) |

---

## 6. Risks

| Risk | Treatment |
|---|---|
| Fiche pointer left null in a required pair | Enumerate all 10 pairs in Phase 1 and verify each in Phase 5 |
| State bank chosen because "no source file exists" | Measure the reference ROM and prove the bank is `$FF` and unreferenced |
| `make gen` overwrites hand-written data | Declare `keepbank BB` before the first generation |
| `sf2ne.cfg` hand-edited and later regenerated | Treat the cfg as generated output; change the annotation instead |
| Guile inherits Ryu's projectile damage/reaction | Parameterize `ProjHit` before wiring Sonic Boom |
| Approved `CmdKeyAttackTbl` remap breaks Ryu/Ken | Phase 1 audit found no active Ryu/Ken use of keys `$0C`/`$0D`; change only those two bytes; any wider remap needs a new decision |
| Aerial throws forced into `$09` | Extend the dispatcher with a new condition code |
| CPU routed to Guile with a null AI pointer | **Resolved by Q4**: human-controlled only; selection must block CPU routing |
| Asset provenance or numeric values unclear | Pose coverage is fixed; keep P8 closed until provenance, conversion, and numeric values are recorded |
| Portraits/frames share bank `$0C` and collide | **Resolved by Q2**: frames/hitboxes use `$14`; `$0C` unchanged |
| Validation inferred from a successful build | Report manual status explicitly; never infer |

---

## 7. Completion criteria

- [x] Phase 0 committed: spec reconciled with `50d9376`, D-04 recorded as resolved.
- [x] Phase 1 audit exists and every step maps to a label and an address.
- [x] Allocation approved (state `$09`, frame/hitbox `$14`, CHR `$39`/`$3A` + `$3B`); bank `$05` untouched.
- [x] Pose/move coverage approved and recorded in the specification §5.1; aerial throws remain P9/P11-gated.
- [ ] Guile fiche has no null pointer in the human-controlled flow.
- [ ] `FighterRoundInit` loads Guile's own state and frame pointers.
- [ ] Normal moves, Sonic Boom, and Flash Kick work with Guile data.
- [ ] Ground throws work; aerial throws either implemented under P9+P11 or reported as gated.
- [ ] Guile selectable in the supported slots; CPU stays on Ryu.
- [ ] No Guile AI; only the recorded `CmdKeyAttackTbl[0C]/[0D]` remap; no other table remap.
- [ ] Build and manual validation executed only under D-05, with explicit status.
- [ ] Documentation describes the delivered state in English.
