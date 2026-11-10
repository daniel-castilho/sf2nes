; Banco de PRG $0A — amostras DPCM (vozes), mapeado em $C000-$DFFF via $5116.
; Veja docs/AUDIO.md para a lista de amostras (endereco/tamanho) dentro do banco.
.segment "BANK0A"
    .incbin "assets/dpcm/bank_0A.dmc"
