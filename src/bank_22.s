; PRG bank $22 — DPCM samples (voices), mapped at $C000-$DFFF via $5116.
; See docs/AUDIO.md for the sample list (address/size) within the bank.
.segment "BANK22"
    .incbin "assets/dpcm/bank_22.dmc"
