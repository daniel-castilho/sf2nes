# Roadmap: from demo to finished game

## Short answer to the original question

> "Is it possible to reverse-engineer, obtain the source code, and finish the project using AI?"

**Yes, and the first half is already done.** This repository is the reconstructed source code: it assembles identically to the ROM, is relocatable (you can insert code and data), and the game architecture is mapped. In NES games there is no "decompile to C": the original was written in 6502 assembly, so the reconstructed source **is** assembly — what is recovered with work are names and comments, not a higher-level language.

What changes is the size of "finishing":

* **the engine is ready and data-driven** — states, animations, AI, commands and voices of one fighter are tables, not code. That's the best possible news for whoever wants to add characters;
* **but only Ryu has content.** Of the other nine in the planned roster there are name, quote, country voice and (for seven) the portrait. Ken has 4.3 KB of frames ready and never used. Each new fighter is mostly **art and data work**: sprites, states, collision boxes, AI scripts, voices.

For reference, Ryu alone has 71 states and 274 animation frames.
Programming: weeks. Content for a full roster: much more than that. Plan per fighter.

## Current phase — stabilization and maintainability

**Objective:** make understanding, authoring and maintenance of what already exists easier, without expanding game content.

**Pause declaration:** new characters and game features are not active work in this phase. The pause is a postponement, not a cancellation — the old backlog remains documented and will be resumed after the Phase 1 documentary audit.

**Planning documents:** `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` (global plan) and `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md` (specification of this phase). The next active tasks will be chosen after the documentary audit, not assumed from the old order of this roadmap.

Future steps related to characters, content tools, scenarios/music/endings and other features are labeled `PAUSED — outside current phase` within this same file.

---------------------------------------------------------------------------------------------------

## Steps

### Step 0 — base (done)

- [x] source that assembles identically (`make`)
- [x] code × data and pointers taken from real execution
- [x] relocatable source, with automatic test (`shift_test.sh` + `regress.sh`)
- [x] architecture, RAM map, state bank format
- [x] graphics and voice extraction
- [x] soft reset freeze fixed
- [x] cause of command delay/repetition found and measured
- [x] versus mode (2 players) unlocked as build option

### Step 1 — understand the engine (done — result is in `docs/FORMATS.md`)

- [x] **The 12 transition conditions** (`StateCond00`–`0B`, `3F:E189`–`E296`) — §4
- [x] **The frame bytes** (+5…+11): effect, damage, hit type, flags, movement — §6–§8
- [x] **Collision boxes** (`00:91C1`…) and hit/damage routines — §10/§11
- [x] **The command recognizer** and `InputDispatch`/`GuardRedirect` — §13 (closed in phase 2.0 of Step 2: the 5 `CmdStep*` handlers decoded; charge/3×button/A+B remain `(nt)` in trace)
- [x] **The 18 opcodes of AI scripts** and `RyuAiThink` logic — §14
- [x] The eight tables at start of state bank (`$A000`–`$A0AF`) — §1/§13
- [x] The rest: projectile (hadouken) — §12 — and jump physics (§8, `VelY` integration); HUD and character selection were out of scope
- [x] all `L3F_*` labels named — 242 added in this phase + 173 pre-existing in `.ann` (`F0A5`–`F648`, described in `docs/FORMATS.md` §8), 194 spread in auxiliary routines; rename each one when touching it in Step 2

Step goal — a `docs/FORMATS.md` document with each data structure described field by field, read from code and checked against ROM: **done** (with `(hypothesis)` and `(nt)` marked where reading isn't guaranteed). The "no `L3F_xxxx` labels" part didn't close: ~276 remain above.

### Step 2 — fix and unlock what already exists

Decided: the 4 decisions below, all in `alt`/`FIXDEFS` blocks (opt-in) — the default path remains byte-by-byte identical; Ken and character content remain for Step 3; **no tests in this phase** (validation is left for later, registered as pending, not as criterion).

- [x] **2.0** document the command recognizer in full — §13: the 5 `CmdStep*` handlers, `CmdMotionTbl`/`CmdKeyAttackTbl`/key lists, interleaved `CmdMotionStep`/`CmdMotionWin` state, consumption in `InputDispatch`
- [x] **2.1** commands: hit on button rising edge + weak→strong promotion (see `docs/BUGS.md` §2.1) — done as `FIX_EDGE_ATTACK`: `InputButtons` (`3F:E99A–E9FB`) rewritten in a single block + selective marker `EdgeMarkHold` (`$F949`) instead of blind `$15` write; `-D FIX_HEAVY_ONCE` remains independent and is subsumed when `FIX_EDGE_ATTACK` is on; gameplay validation pending
- [x] **2.2** difficulty: SELECT on selection alternates Easy/Normal/Hard (`AiLevel` 2/4/7, default 4) + read/document AI — depends on 2.0
- [x] 2.3 versus: START on selection enters versus mode (`FIX_SELECT_VERSUS` alt; P2 human blocked in Ryu) (`-D MODE_VERSUS`, tested; see `docs/BUGS.md`)
- [x] 2.4 end of match: winner quote already fades and returns to title (`FadeOut 3B:E426`)

Outside scope of this step (left for later): less mechanical AI beyond difficulty selector, next opponent/continue screen, per-character winner quote.

### Step 3 — second fighter (Ken) `PAUSED — outside current phase`

It's the cheapest case: frames are already in bank `$04` and it's almost a Ryu.

**Current state:** state bank `$05`, column 1 of fiche, selection, palette (A = red, B = blue) and AI stub already connected; Ryu (column 0) remains untouched. Complete moveset and manual acceptance still pending.

1. check graphics: `make assets` and locate Ken tiles in CHR pages;
2. Ken state bank: copy Ryu's to a free bank in window `$A000` (`$05`), swapping metasprite pointers to bank `$04` — with relocatable source it's copy and rename labels, no address recalculation;
3. fill **column 1** of fiche tables (`3C:8000`–`80E5`) and `CharStateBankTbl`;
4. AI: CPU for this delivery remains Ryu; Ken's fiche points to a stub (`$04:90E0`) ending in `$FF`, so it never falls into collision data. Ken's own AI is out of scope;
5. voices: column 1 of `FighterVoiceTbl`; palette; release selection cursor;
6. since bank `$05` is hand-written source (original is all `$FF`), use `keepbank 05` in annotations instead of `statebank`; fiche/palette/selection/stub edits enter as `patch` and survive `make gen`.

When Ken works, the path for others is proven; what remains is art.

### Step 4 — content tools `PAUSED — outside current phase`

Editing states in `.byte` doesn't scale. Before third fighter it's worth building:

- [ ] **PNG → CHR + metasprites** converter (author has `yanct` in `ref/`; check if it works);
- [ ] a text format for states/frames (ca65 macros or a script) instead of loose bytes;
- [ ] WAV → DPCM converter aligned to 64 bytes, updating voice directory.

### Step 5 — scenarios, music, endings `PAUSED — outside current phase`

There are 36 empty PRG banks and 198 free CHR pages: space is not the problem. Bank `$3B` (fight code) is full — new code goes to a new bank in window `$E000` (`$33`, `$2F`…), which needs its own kernel copy: just a `bank_33.s` file with `.include "kernel.inc"` at the same address and vectors at the end.

---------------------------------------------------------------------------------------------------

## How to use AI in this project without fooling yourself

AI is very good at reading 40 lines of 6502 and saying what they do. It is bad at knowing if it's right. The project was set up so that **every claim can be verified by machine**:

| What AI proposes | How to verify |
|------------------|---------------|
| a name or comment | `make gen && make` → continues identical (a name never changes a byte) |
| "this variable is P2's energy" | `SF2_HOLD="0F:01:2200:99999"` and watch the match; or per-frame dump (`SF2_RAMDUMP=1`) |
| "this routine only runs on selection" | the `; modes:` line above the routine already says where it ran |
| "this is a pointer" | `trace/pointers.txt`; if not there, run `ptrtrace.lua` on a scenario that passes through it |
| a change that shouldn't alter anything | `tools/mesen/regress.sh build/…nes` |
| a fix | a test script that fails before and passes after (model: `reset_test.lua`) |

### Work cycle (used in Step 1; valid for next ones)

1. Pick an unnamed routine: `python3 tools/show.py 3F:E189 60`.
2. Give AI **together**: the routine, routines it calls, relevant parts of `docs/RAM.md` and `docs/ARCHITECTURE.md`. Lines `; <-` (who calls) and `; modes:` already come in `show.py` output.
3. Ask for a **hypothesis with test**: "what does this routine do, what name would you give it, and what emulator experiment would confirm or refute that?".
4. Run the experiment. Only then record in `annotations/sf2ne.ann` (`label`, `ram`, `comment`, `block`).
5. `make gen && make`. Commit.

The annotations file is the project's memory: each new AI session starts by reading `docs/` and `annotations/` and continues from where the previous one left off, without depending on conversation history.

### Known traps

* **Plausible name, wrong.** Don't accept a name without evidence. Mark guesses as guesses (`comment … (hypothesis)`).
* **Cycle-counted code.** `IrqHandler` and controller reading cannot change duration. Don't let AI "clean up" those parts.
* **Bank `$3B` full.** Any addition there overflows the bank; assembler warns (kernel `.assert`).
* **Unofficial opcode.** `axs #imm` (`$CB`) is used on purpose; some old emulators don't support it.
* **Never-executed code** (`(nt)` in source): disassembled by static analysis. Treat as less reliable until a test passes through it.
* **Test coverage.** `regress.sh` covers what the demo allows playing with Ryu. When there is new content, add scenarios.

### If you've never programmed in 6502

You can start with data. Changing a frame duration, a move's damage, or an AI script is editing numbers in a table and seeing the result — and that's exactly how Step 1 formats were discovered. Assembly comes little by little, reading short routines with AI by your side. Quick 6502 reference: <https://www.nesdev.org/obelisk-6502-guide/reference.html>; about MMC5: <https://www.nesdev.org/wiki/MMC5>.