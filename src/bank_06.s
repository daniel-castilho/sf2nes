; PRG bank $06 — DPCM samples (voices), mapped at $C000-$DFFF via $5116.
; See docs/AUDIO.md for the list of samples (address/size) inside the bank.
.segment "BANK06"
    .incbin "assets/dpcm/bank_06.dmc"
