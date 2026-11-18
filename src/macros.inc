; Project macros.

FarCall := $049E        ; far-call trampoline (copied from ROM to RAM at startup)

; ---------------------------------------------------------------------------------------------------------
; farcall <routine>
;   "Far" call: runs a routine that lives in ANOTHER code bank (all run at $E000-$FFFF).
;   Pushes the return address and the current bank, then jumps to the trampoline in RAM (FarCall, $049E),
;   which switches the bank at $5117, calls the routine, restores the bank and returns.
;   A, X and Y are destroyed on entry (parameters go through zero-page variables).
;   The target bank and the current bank are resolved by the linker (.bank), so routines can be moved.
;   Emits exactly the same 18 bytes as the original ROM.
; ---------------------------------------------------------------------------------------------------------
.macro farcall target
    .local ret
    lda #>(ret-1)
    pha
    lda #<(ret-1)
    pha
    lda #<.bank(ret)
    pha
    lda #<.bank(target)
    ldx #>(target-1)
    ldy #<(target-1)
    jmp FarCall
ret:
.endmacro

; ---------------------------------------------------------------------------------------------------------
; farjmp <routine>
;   Far jump (tail-call): like farcall, but without pushing a return address — when the target routine
;   returns, the trampoline restores the current bank and returns to WHOEVER CALLED the current routine.
;   Emits exactly the same 12 bytes as the original ROM.
; ---------------------------------------------------------------------------------------------------------
.macro farjmp target
    .local here
here:
    lda #<.bank(here)
    pha
    lda #<.bank(target)
    ldx #>(target-1)
    ldy #<(target-1)
    jmp FarCall
.endmacro
