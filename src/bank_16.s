; PRG bank $16 — DPCM samples (voices), mapped at $C000-$DFFF via $5116.
; See docs/AUDIO.md for the list of samples (address/size) inside the bank.
.segment "BANK16"
    .incbin "assets/dpcm/bank_16.dmc"
