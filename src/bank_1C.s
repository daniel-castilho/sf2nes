; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; Banco de PRG $1C (dados) — janela $8000-$9FFF — offset no arquivo $038010
;
.include "defs.inc"
.segment "BANK1C"
D1C_8000:
    .byte $2E,$00,$02,$00,$AF,$2C,$2E,$02,$00,$BF,$30,$32,$02,$00,$DF,$34; 8000
    .byte $36,$02,$00,$EF,$38,$3A,$80,$00,$04,$10,$AF,$00,$02,$04,$06,$04; 8010
    .byte $10,$BF,$08,$0A,$0C,$0E,$06,$00,$CF,$10,$12,$14,$16,$18,$1A,$04; 8020
    .byte $10,$DF,$1C,$1E,$20,$22,$04,$10,$EF,$24,$26,$28,$2A,$80; 8030
    .res 8130, $FF                              ; 803E
