# Data naming — batch 12: bank `$04` (Ken fiche-referenced data)

- **Status:** **APPLIED** — 3 names applied; 0 labels deferred; ROM SHA-1 unchanged. Pending commit authorization.
- **Scope:** the 3 automatic `D04_*` labels of `src/bank_04.s`: the win/normal portrait layout, the AI
  stub table and the stub script.
- **Source of truth:** `src/bank_04.s`, `src/bank_3C.s` (`PortraitWinLayoutTbl`, `PortraitLoseLayoutTbl`,
  `CharAiScriptLoTbl`/`HiTbl`), `annotations/sf2ne.ann` and `docs/FORMATS.md` §14.
- **Rule:** only labels and comments change; no Ken AI is implemented and no byte changes.

## 1. Evidence used

| Address | Current | Consumer | Evidence |
|---------|---------|----------|----------|
| `04:8A59` | `D04_8A59` | `PortraitWinLayoutTbl` entry 1 (`3C:84A8`) | table entry 0 is Ryu's win layout (`D00_8A9D`); entries 2–7 are the other characters; the bytes at `$8A59` are a metasprite sequence |
| `04:90E0` | `D04_90E0` | `CharAiScriptLoTbl`/`HiTbl` column 1 (`3C:80B5`/`80BF`) | 8 words, all pointing to `$90F0`; same 8-entry shape as Ryu's `RyuAiIdleScriptTbl` |
| `04:90F0` | `D04_90F0` | 8 pointers from `$90E0`; `PortraitLoseLayoutTbl` uses `$90F1` | first byte is `$FF`, so the script ends immediately; `$90F1` is the defeat portrait layout already documented in the `.ann` |

The AI table is the fiche's script table for column 1 (Ken). Because this delivery keeps the CPU as Ryu,
the entries are a stub: eight identical pointers to a one-byte `$FF` script. Naming the stub does not add
or change AI behaviour.

The portrait label follows the existing `PortraitWinLayoutTbl`/`PortraitLoseLayoutTbl` vocabulary:
`KenWinPortraitLayout` is the normal/win layout, also reused (from `$90F1`) by the defeat patch.

## 2. Applied names (3)

| Address | Current | Applied | Role | Confidence | Priority |
|---------|---------|---------|------|------------|----------|
| `04:8A59` | `D04_8A59` | `KenWinPortraitLayout` | win/normal portrait layout, entry 1 of `PortraitWinLayoutTbl` | HIGH | P2 |
| `04:90E0` | `D04_90E0` | `KenAiStubScriptTbl` | 8-entry AI script table from the fiche (all stubs) | HIGH | P1 |
| `04:90F0` | `D04_90F0` | `KenAiStubScript` | one-byte `$FF` script; `$90F1` starts the defeat layout | HIGH | P2 |

## 3. Comment and reference updates

| File | Change |
|------|--------|
| `annotations/sf2ne.ann` | 3 labels/comments in the `$04` section; fiche comments `3C:80B5`/`80BF` cite `KenAiStubScriptTbl`; defeat-portrait comment cites `KenWinPortraitLayout` |
| `src/bank_04.s` | regenerated: 3 labels + 8 `.word` operands |
| `src/bank_3C.s` | `PortraitWinLayoutTbl` entry 1 now cites `KenWinPortraitLayout`; operands unchanged |
| `src/globals.inc` | `D04_8A59` → `.global KenWinPortraitLayout` |

`src/bank_01.s` and `src/bank_05.s` are untouched.

## 4. Validation

| Check | Result |
|-------|--------|
| `make gen` | OK; second run produced no further diff |
| `make` | OK — canonical build with `DEST_FLAG_BLINK` |
| SHA-1 of `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — identical to baseline |
| Directive operands | `src/bank_04.s` 286 and `src/bank_3C.s` 133 directives before/after; normalized to the same addresses; no numeric operand changed |
| `grep -c '^D04_' src/bank_04.s` | 0 |
| Renamed `D04_*` tokens left | 0 in sources, `.ann` and `globals.inc` |
| Metrics | automatic data `889 -> 886`; unique semantic `1,251 -> 1,254`; definitions `2,145` and unique names `2,140` unchanged; bank `$04` now 0 automatic / 3 semantic |

Commit is still pending explicit authorization; nothing was pushed.
