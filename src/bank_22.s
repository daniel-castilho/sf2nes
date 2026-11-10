; Banco de PRG $22 — amostras DPCM (vozes), mapeado em $C000-$DFFF via $5116.
; Veja docs/AUDIO.md para a lista de amostras (endereco/tamanho) dentro do banco.
.segment "BANK22"
    .incbin "assets/dpcm/bank_22.dmc"
