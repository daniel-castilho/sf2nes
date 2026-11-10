; Banco de PRG $02 — amostras DPCM (vozes), mapeado em $C000-$DFFF via $5116.
; Veja docs/AUDIO.md para a lista de amostras (endereco/tamanho) dentro do banco.
.segment "BANK02"
    .incbin "assets/dpcm/bank_02.dmc"
