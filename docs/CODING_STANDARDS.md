# Coding Standards — sf2nes (6502 / ca65 / MMC5)

Practical reference for reverse-engineering and extending the Street Fighter II NE demo.
Goal: **consistency, predictability and long-term editability**. Living document.

**Relationship to other docs:**

| Doc                    | Wins when                                              |
|------------------------|--------------------------------------------------------|
| `docs/ARCHITECTURE.md`  | Hardware facts, bank map, MMC5 configuration           |
| `docs/FORMATS.md`     | Data structure definitions (states, frames, AI, etc.)  |
| **This file**          | Day-to-day coding conventions and architectural rules  |
| `docs/lessons.md`      | Hard-won knowledge from debugging sessions             |

Where this file conflicts with `docs/ARCHITECTURE.md`, the architecture document wins.

---

## 1. Core Principles

1. **The source of truth is `annotations/sf2ne.ann`.**  
   Never edit generated files in `src/` by hand unless the bank is explicitly marked `keepbank`.

2. **Code must remain relocatable.**  
   Any change that breaks the ability to shift banks and still run identically is a regression.

3. **Prefer data over code.**  
   The original engine is data-driven. New behaviour should be expressed as tables + small interpreters whenever possible.

4. **One bank, one responsibility (as much as practical).**  
   Do not keep growing `$3B` just because it is convenient.

5. **Every inter-bank call must be intentional and visible.**  
   Hidden or ad-hoc bank switches are technical debt.

---

## 2. Naming Conventions

| Element                  | Convention                          | Example                          |
|--------------------------|-------------------------------------|----------------------------------|
| Code labels              | `PascalCase` or descriptive verbs   | `UpdateFighter`, `DrawHUD`       |
| Data labels              | `D` + bank + address (auto) or semantic | `D3B_E4A0`, `RyuStateTable`   |
| Bank files               | `bank_XX.s`                         | `bank_3B.s`, `bank_05.s`         |
| Macros                   | `UPPER_SNAKE` or descriptive        | `FAR_CALL`, `SWITCH_BANK`        |
| Constants                | `UPPER_SNAKE_CASE`                  | `BANK_FIGHT`, `STATE_IDLE`       |
| RAM variables            | Short, clear, documented in `RAM.md`| `p1_state`, `frame_counter`      |
| Trampolines              | `Call_` + target name               | `Call_UpdateHitboxes`            |
| Entry points (modules)   | `Module_` or clear verb             | `Module_FightExtended`           |

- Prefer names that describe **intent**, not address.
- Automatic labels (`L3F_xxxx`, `D3B_xxxx`) are temporary. Replace them with semantic names as soon as the purpose is understood.
- Do not invent parallel naming schemes.

---

## 3. Bank Architecture & Switching

This is the most important section of this document.

### 3.1 Current Reality

- Code banks live in the `$E000–$FFFF` window.
- Every code bank must contain a copy of the kernel (vectors + common routines).
- Bank `$3B` (main fight logic) is nearly full (~120 bytes free).
- Growing `$3B` further is forbidden without explicit justification.

### 3.2 Rules for Bank Usage

| Situation                        | Correct approach                              | Forbidden                          |
|----------------------------------|-----------------------------------------------|------------------------------------|
| Small bugfix in existing code  | Edit in place                                 | —                                  |
| New fight-related logic          | New code bank + trampoline / dispatcher       | Stuffing into `$3B`                |
| New character data               | Data banks (`$00`, `$04`, `$05`…)             | Putting character logic in `$3B`   |
| One-off experiment               | `alt` / `FIXDEFS` blocks                      | Permanent pollution of core banks  |

### 3.3 Inter-Bank Calls (Required Pattern)

All calls from one code bank to another **must** go through a trampoline or a central dispatcher.

**Preferred style (trampoline):**

```asm
; In the calling bank (e.g. $3B)
.proc Call_NewSystem
    lda #BANK_NEW
    sta $5117               ; MMC5 PRG bank register for $E000
    jsr NewSystem_Entry
    lda #BANK_3B
    sta $5117
    rts
.endproc
```

**Better long-term style (central dispatcher):**

- Keep a small, stable set of entry points.
- One dispatcher routine that receives a module ID + function ID.
- Reduces scattered bank-switch code.

### 3.4 Creating a New Code Bank

When `$3B` (or any code bank) is full:

- Choose a free bank (e.g. `$33`, `$2F`…).
- Create `src/bank_XX.s`.
- Include the kernel at the correct address.
- Export only the necessary entry points.
- Add trampolines in the calling banks.
- Document the new bank's responsibility in `docs/ARCHITECTURE.md`.
- Never create a code bank without a clear ownership statement.

### 3.5 Kernel Policy

The kernel is duplicated by design.
Do not “optimize” by removing kernel code from individual banks.
Any change to the kernel must be applied consistently to all code banks that contain it.

---

## 4. Code vs Data Separation

| Kind of change                      | Where it belongs                 | Notes                        |
|-------------------------------------|----------------------------------|------------------------------|
| New fighter states/frames           | Data banks                       | Preferred                    |
| New AI scripts                      | Data                             | Preferred                    |
| New collision boxes                 | Data                             | Preferred                    |
| Core engine loop changes            | Code banks                       | Rare, expensive              |
| New systems (combo counter, etc.)   | Prefer data-driven interpreter   | Avoid large new code         |

**Rule of thumb:**  
If you can express the behaviour as a table that an existing or small new interpreter can read, do that instead of writing new imperative code in a full bank.

---

## 5. File & Project Organization

- `annotations/sf2ne.ann` ← Source of truth (labels, comments, patches)
- `src/` ← Generated (or keepbank) assembly
  - `bank_XX.s`
  - `kernel.inc`
  - `globals.inc`
  - `ram.inc`
- `docs/`
  - `ARCHITECTURE.md`
  - `FORMATS.md`
  - `RAM.md`
  - `BUGS.md`
  - `lessons.md`
- `tools/` ← Generators, tracers, validators

Generated files are not the source of truth.
Manual edits to generated banks require keepbank and clear justification.
Patches that must survive regeneration are declared in the `.ann` file.

---

## 6. Comments & Documentation Style

Comments explain why, not what the instruction does.
Use the annotation system (label, comment, block, patch) instead of scattering free-form comments that the generator may ignore.

Public entry points of a bank must have a short contract comment:

- What it expects (registers, RAM)
- What it clobbers
- What it returns

Example:

```asm
; Entry: A = fighter index
; Clobbers: A, X, Y, tmp0-tmp3
; Returns: nothing (updates RAM state)
.proc UpdateFighterState
```

---

## 7. Verification & Safety

Before considering a change done:

- `make gen && make` must succeed.
- Behaviour that should not change must still match the reference (use existing regression tools when available).
- New inter-bank calls must be tested under real timing (NMI/IRQ pressure).
- Relocatability should not be silently broken.
- Never claim a feature is complete without at least manual acceptance of the new path.

---

## 8. What We Explicitly Reject

- Growing `$3B` “just a little more”.
- Ad-hoc `sta $5117` without a named trampoline or dispatcher.
- Putting new character logic into fight-code banks.
- Editing generated `src/` files without keepbank.
- Magic numbers for banks and entry points (use named constants).
- Assuming a routine is safe to call from any bank without documenting bank requirements.

---

## 9. Recommended Evolution Path

**Short term**
- Use clean trampolines + new code banks when `$3B` is full.

**Medium term**
- Introduce a small central dispatcher for inter-module calls.

**Long term**
- Push as much new behaviour as possible into data tables and interpreters. The original engine already points in this direction — follow it.

---

### Quick Checklist (before committing)

- Change declared in `annotations/sf2ne.ann` (or justified keepbank)
- No unnecessary growth of `$3B`
- New inter-bank calls use trampoline or dispatcher
- New code bank has clear ownership and kernel
- Entry points documented (registers / clobbers)
- `make gen && make` succeeds
- Behaviour that must stay identical still does
- Naming follows the conventions above
