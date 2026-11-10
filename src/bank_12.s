; Banco de PRG $12 — amostras DPCM (vozes), mapeado em $C000-$DFFF via $5116.
; Veja docs/AUDIO.md para a lista de amostras (endereco/tamanho) dentro do banco.
.segment "BANK12"
    .incbin "assets/dpcm/bank_12.dmc"
