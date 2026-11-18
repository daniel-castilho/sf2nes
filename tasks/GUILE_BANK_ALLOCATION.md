# Guile implementation — Phase 2 bank allocation proposal

**Status:** APPROVED BY MAINTAINER (2026-11-18) — see §7. The allocation is authorized; no annotation, source, linker, ROM, or build change has been applied yet.  
**Prepared:** 2026-11-18.  
**Plan:** `tasks/GUILE_IMPLEMENTATION_PLAN.md`, Phase 2.  
**Evidence:** `tasks/GUILE_IMPLEMENTATION_AUDIT.md` (Phase 1), generated `src/`, `annotations/sf2ne.ann`, `sf2ne.cfg`, and read-only byte measurements of `rom/sf2ne_demo.nes`.  
**Gates still open:** D-05 for any `make gen`, `make`, test, or emulator run; P8 for legally usable sprites/palettes/hitboxes/audio, conversion, and numeric values; P9 + P11 for aerial throws. D-04, P10, the Phase 2 allocation, and the Q7 pose/move coverage list are resolved/approved.

This document records the approved addresses and the exact edits still to be applied. It does not change `annotations/`, `src/`, `sf2ne.cfg`, the ROM, or the build system.

---

## 1. Recommendation summary

| Resource | Proposed value | Window / use | Reason |
|---|---|---|---|
| State bank | `$09` | `$A000` — Guile states | First fully empty `$A000`-window bank; not `$05` (Ken), not `$29`/`$2D` (music) |
| Frame bank | `$14` | `$8000` — metasprites | First fully empty `$8000`-window bank; keeps Guile's fighting data separate from portrait PRG `$0C` |
| Hitbox bank | `$14` (shared with frames) | `$8000` — collision records | Follows Ken's precedent (`$04` for both); no demonstrated need for a dedicated bank |
| Fighter CHR pages | `$39`, `$3A` | 2 KB sprite pages | First free pages after the used `$00`–`$38` range; separate from portrait page `$0C` |
| Projectile CHR reserve | `$3B` | 2 KB sprite page | Reserve only if the shared projectile draw path is kept; final use depends on Q5 and D-05 |
| Portrait PRG/CHR | `$0C` unchanged | `D0C_8000`, portrait page `$0C` | Do not disturb existing win/lose portrait layout |
| Code banks | `$3F`, `$3B` unchanged | command recognizer, fight core, drawing | No new code bank is requested; code-space risk is recorded in §6 |

**Explicitly excluded:** bank `$05` (Ken's hand-written state bank, `keepbank 05` in `annotations/sf2ne.ann:2166`).

---

## 2. Read-only verification of the proposed banks and pages

MMC5 PRG mode 3 maps bank `n` to `$8000 + (n & 3) × $2000` (`3F:F7A2`). Therefore `$09` maps to `$A000` and `$14` maps to `$8000`.

Measured directly from `rom/sf2ne_demo.nes` (8 KB PRG banks, 2 KB CHR pages):

| Item | Used bytes | Free bytes | Fully `$FF`? | Annotation references? |
|---|---:|---:|---|---|
| PRG `$09` | 0 | 8192 | yes | none |
| PRG `$14` | 0 | 8192 | yes | none |
| CHR `$39` | 0 | 2048 | yes | n/a |
| CHR `$3A` | 0 | 2048 | yes | n/a |
| CHR `$3B` | 0 | 2048 | yes | n/a |

No fiche column in bank `$3C` selects `$09` or `$14`. The reference image uses CHR pages `$00`–`$38` and `$FF`; `$39`–`$FE` are free. Page `$0C` is Guile's existing portrait page (`D0C_8000` starts with `$0C`).

These facts satisfy the Phase 2 check that every chosen bank is fully `$FF` and unreferenced. They are not an allocation.

---

## 3. Why these choices

### 3.1 State bank `$09`

Bank `$09` is the first free bank with low two bits `01`, so it appears at `$A000` without any window conflict. It is fully empty in the reference ROM and has no annotation labels. It does not collide with Ryu `$01`, Ken `$05`, or music `$29`/`$2D`.

The direction-table quirk (`3B:E025`) means `CharDirTransHiTbl[3]` is never read; the engine uses `CharDirTransHiTbl[0] = $A0`. Placing `GuileDirTransTbl` at **`09:A000`** makes the existing low byte `$00` resolve correctly to `$A000` once `CharStateBankTbl[3]` is changed to `$09`. No code fix is needed for the quirk under this proposal.

Alternative state banks remain valid if the Maintainer prefers a different number: `$0D $11 $15 $19 $1D $21 $25 $31 $35 $39 $3D`. `$05` is not available.

### 3.2 Frame and hitbox bank `$14`

Reusing `$0C` would avoid one fiche byte change, but `$0C` is generated source containing `D0C_8000`, the portrait record. Keeping fighting frames there would either require annotation patch directives inside a generated bank or converting `$0C` to `keepbank` and hand-preserving the portrait record. Both couple unrelated data and increase regression risk.

Bank `$14` is the first fully empty `$8000`-window bank. It gives 8192 bytes for metasprites, collision records, and an optional AI script table. Ryu's comparable data uses 5193 bytes (bank `$00`) and Ken's 4303 bytes (bank `$04`), so the capacity is sufficient for a similar pose set, but no budget is approved until P8 fixes the pose list.

Ken's precedent is to share one bank for `CharFrameBankTbl` and `CharHitBoxBankTbl` (`$04`). This proposal follows that pattern: both Guile selectors become `$14`.

### 3.3 CHR pages `$39` / `$3A` / `$3B`

The engine sets CHR mode 2 = 2 KB pages (`3F:F7A7`). `DrawFighter` writes the frame record's first byte into `FighterChrPage,x`; NMI sends `FighterChrPage` and `FighterChrPage+1` to `$5121` and `$5123`. P1/P2 tile indices differ by `+$80` (`zp_E4`), selecting opposite pattern-table halves. The exact page-pairing rule is still an open question (Q3, D-05), so this proposal **reserves** two contiguous pages for Guile's fighting art rather than asserting that one page is enough.

Page `$3B` is reserved only as a candidate for Sonic Boom art if the projectile draw path keeps reading its CHR page from the metasprite record byte written to `$5125`. It is not needed for the fighter body.

---

## 4. Exact changes required if approved

All changes below are **future work**. Fiche edits must be made through `annotations/sf2ne.ann` patch directives because `src/bank_3C.s` is generated; do not hand-edit generated source.

### 4.1 Annotation / build integration

Add to `annotations/sf2ne.ann`:

```
keepbank 09
keepbank 14
```

with comments stating that bank `$09` is Guile's hand-written state bank and bank `$14` is Guile's hand-written frame/hitbox bank. This mirrors the existing `keepbank 05` model.

After an authorized `make gen`, `sf2ne.cfg` would gain these `SEGMENTS` entries:

```
    BANK09: load = PRG09, type = ro;
    BANK14: load = PRG14, type = ro;
```

`sf2ne.cfg` is generated and must not be hand-edited. The Makefile already includes all `src/*.s`, so new source files will be linked automatically once present.

### 4.2 New hand-written sources

Create `src/bank_09.s`:

```
.include "defs.inc"
.segment "BANK09"
GuileDirTransTbl:                 ; must be at 09:A000
    ; 9 direction entries (docs/FORMATS.md §2)
```

Create `src/bank_14.s`:

```
.include "defs.inc"
.segment "BANK14"
    ; metasprite records: CHR page byte $39/$3A, sub-metasprites, terminators
    ; collision records: 3 boxes [height][dy][dx][width] per frame
    ; optional GuileAiScriptTbl only if Q4 requires CPU support
```

Because both banks are `keepbank`, `make gen` will skip regenerating these files.

### 4.3 Fiche bytes in bank `$3C`

| Address | Table / index | Current | Proposed | Note |
|---|---|---|---|---|
| `3C:80CB` | `CharStateBankTbl[3]` | `$01` | `$09` | Required |
| `3C:80D5` | `CharFrameBankTbl[3]` | `$0C` | `$14` | Required |
| `3C:80DF` | `CharHitBoxBankTbl[3]` | `$00` | `$14` | Required |
| `3C:8003` | `CharDirTransLoTbl[3]` | `$00` | `$00` | Unchanged if `GuileDirTransTbl` is at `$A000` |
| `3C:800D` | `CharDirTransHiTbl[3]` | `$00` | `$00` | Unused by the loader quirk; unchanged |
| `3C:8017` / `3C:8021` | Attack transition lo/hi | `$00` / `$00` | `GuileAttackTransTbl` lo/hi | Phase 5, in `$09` |
| `3C:802B` / `3C:8035` | Special transition lo/hi | `$00` / `$00` | `GuileSpcTrans` lo/hi | Phase 5, in `$09` |
| `3C:803F` / `3C:8049` | Guard reactions lo/hi | `$00` / `$00` | `GuileGuardReactTbl` lo/hi | Phase 5, in `$09` |
| `3C:8053` / `3C:805D` | Standing hit reactions lo/hi | `$00` / `$00` | `GuileHitReactStandTbl` lo/hi | Phase 5, in `$09` |
| `3C:8067` / `3C:8071` | Crouching hit reactions lo/hi | `$00` / `$00` | `GuileHitReactCrouchTbl` lo/hi | Phase 5, in `$09` |
| `3C:807B` / `3C:8085` | Neutral/air hit reactions lo/hi | `$00` / `$00` | `GuileHitReactAirTbl` lo/hi | Phase 5, in `$09` |
| `3C:808F` / `3C:8099` | Throw reactions lo/hi | `$00` / `$00` | `GuileThrowReactTbl` lo/hi | Phase 5, in `$09`; P9/P11 still block aerial throws |
| `3C:80A3` / `3C:80AD` | Command list lo/hi | `$00` / `$00` | `$C7` / `$E0` if the dormant `3F:E0C7` list is reused | Phase 7; depends on Q6 |
| `3C:80B7` / `3C:80C1` | AI script table lo/hi | `$00` / `$00` | leave null, or `GuileAiScriptTbl` lo/hi in `$14` | Depends on Q4 |

`PortraitWinLayoutTbl+6` (`3C:84AC`) must continue to point to `D0C_8000`; this proposal does not change it.

### 4.4 CHR record bytes

When P8 produces art, set the first byte of Guile's metasprite records to `$39` or `$3A` (body pages) and, if the shared projectile path is retained, `$3B` for Sonic Boom. These are data values inside `src/bank_14.s` and projectile data respectively, not fiche bytes. Final assignment waits for Q3/Q5 and D-05 validation.

---

## 5. Non-changes and preserved constraints

* Bank `$05` stays Ken's hand-written state bank. No Guile data goes there.
* Bank `$0C` and portrait CHR page `$0C` stay as they are.
* Banks `$29` and `$2D` stay music.
* Code banks `$3F` and `$3B` keep their current roles. The small free space in `$3F` (867 bytes) and `$3B` (133 bytes) remains a sizing risk for any parameterization of commands/projectiles; see §6.
* No build, `make gen`, script, test, emulator run, ROM edit, or source/annotation edit was performed while producing this proposal.

---

## 6. Decision record

The Maintainer answered the Phase 1 audit questions on 2026-11-18:

| Question | Decision | Consequence |
|---|---|---|
| Q1 — state bank | **Approve `$09`** | `CharStateBankTbl[3]` → `$09`; `GuileDirTransTbl` at `09:A000`; `$05` untouched |
| Q2 — frame/hitbox bank | **Approve `$14` shared** | `CharFrameBankTbl[3]` and `CharHitBoxBankTbl[3]` → `$14`; `$0C` portrait data untouched |
| Q3 — CHR pages | **Reserve `$39`/`$3A`, plus `$3B` for projectile** | Provisional until D-05 confirms the exact page-pairing rule |
| Q4 — CPU scope | **P1/human only** | Leave AI pair 9 null; CPU stays Ryu; selection must not route CPU to Guile |
| Q5 — projectile path | **Parameterize the shared path** | Patch the shared hit/draw path in `$3F`/`$3B` instead of duplicating it |
| Q6 — P10 mechanism | **Global remap of `CmdKeyAttackTbl[0C]/[0D]`** | Set keys `$0C`/`$0D` to LK/HK (`$02`/`$03`); change is limited to those two bytes; broader remaps still require a new decision |
| Q7 — pose coverage | **Approved definitive list (2026-11-18; revised the same date)** | Recorded in `tasks/GUILE_BEHAVIORAL_ENGINEERING_SPEC_EN.md` §5.1; defines coverage only, not numeric values. Knee Pad excluded from NES scope because its published input requires MK, which the NES scheme does not provide. P8 still blocks assets |

P8, P9, P11, and D-05 remain open. This decision record does not resolve them.

---

## 7. Approval record

**APPROVED BY MAINTAINER — 2026-11-18.** The approved allocation is state bank `$09`, shared frame/hitbox bank `$14`, and reserved CHR pages `$39`/`$3A` with `$3B` for the projectile candidate. Guile is human-controlled only; the shared projectile path is parameterized; the P10 Flash Kick mechanism is the audited global remap of keys `$0C`/`$0D`. Q7 pose/move coverage was supplied and recorded in the specification §5.1, with Knee Pad subsequently excluded because the NES scheme has no MK class; P8 still blocks asset provenance, conversion, and numeric values.

**Applied status:** NOT APPLIED. No annotation, source, linker configuration, ROM, build, generator, test, or emulator change has been made under this approval.

**Exit criterion:** Phase 2 is complete at approval. Phase 3+ may be scheduled only against the still-open gates: P8 for asset provenance/conversion/numeric values, D-05 for build/generation/tests/emulator, and P9 + P11 for aerial throws.
