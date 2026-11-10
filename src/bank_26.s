; Banco de PRG $26 — amostras DPCM (vozes), mapeado em $C000-$DFFF via $5116.
; Veja docs/AUDIO.md para a lista de amostras (endereco/tamanho) dentro do banco.
.segment "BANK26"
    .incbin "assets/dpcm/bank_26.dmc"
