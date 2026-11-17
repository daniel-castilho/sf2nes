; PRG bank $0E — DPCM samples (voices), mapped at $C000-$DFFF via $5116.
; See docs/AUDIO.md for the sample list (address/size) within the bank.
.segment "BANK0E"
    .incbin "assets/dpcm/bank_0E.dmc"
