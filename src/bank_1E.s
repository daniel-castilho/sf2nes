; Banco de PRG $1E — amostras DPCM (vozes), mapeado em $C000-$DFFF via $5116.
; Veja docs/AUDIO.md para a lista de amostras (endereco/tamanho) dentro do banco.
.segment "BANK1E"
    .incbin "assets/dpcm/bank_1E.dmc"
