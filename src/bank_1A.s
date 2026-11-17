; PRG bank $1A — DPCM samples (voices), mapped at $C000-$DFFF via $5116.
; See docs/AUDIO.md for the sample list (address/size) within the bank.
.segment "BANK1A"
    .incbin "assets/dpcm/bank_1A.dmc"
