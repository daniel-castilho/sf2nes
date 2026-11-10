; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; Banco de PRG $08 (dados) — janela $8000-$9FFF — offset no arquivo $010010
;
.include "defs.inc"
.segment "BANK08"
D08_8000:
    .byte $0C,$00,$06,$00,$AF,$24,$26,$28,$2A,$2C,$2E,$06,$00,$BF,$30,$32; 8000
    .byte $34,$36,$38,$3A,$80,$00,$06,$00,$CF,$00,$02,$04,$06,$08,$0A,$06; 8010
    .byte $00,$DF,$0C,$0E,$10,$12,$14,$16,$06,$00,$EF,$18,$1A,$1C,$1E,$20; 8020
    .byte $22,$80                               ; 8030
    .res 8142, $FF                              ; 8032
