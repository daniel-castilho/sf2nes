; Project macros.

FarCall := $049E        ; far call trampoline (copied from ROM to RAM at initialization)

; ---------------------------------------------------------------------------------------------------------
; farcall <routine>
;   "Far" call: executes a routine that is in ANOTHER code bank (all run at $E000-$FFFF).
;   Pushes the return address and current bank and jumps to the trampoline in RAM (FarCall, $049E),
;   which switches bank at $5117, calls the routine, restores the bank and returns.
;   A, X and Y are destroyed on the way (parameters go via zero-page variables).
;   The destination bank and current bank are resolved by the linker (.bank), so routines can be moved.
;   Generates exactly the same 18 bytes of the original ROM.
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
;   Far jump (tail-call): same as farcall, but without pushing the return address — when the destination
;   routine returns, the trampoline restores the current bank and goes back to WHO CALLED the current routine.
;   Generates exactly the same 12 bytes of the original ROM.
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
