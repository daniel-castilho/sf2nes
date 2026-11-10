; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; Banco de PRG $10 (dados) — janela $8000-$9FFF — offset no arquivo $020010
;
.include "defs.inc"
.segment "BANK10"
D10_8000:
    .byte $0B,$00,$06,$00,$AF,$42,$44,$46,$48,$4A,$4C,$06,$00,$BF,$4E,$50; 8000
    .byte $52,$54,$56,$58,$02,$00,$CF,$5A,$5C,$02,$20,$CF,$5E,$60,$80,$00; 8010
    .byte $02,$10,$CF,$26,$28,$06,$00,$DF,$2A,$2C,$2E,$30,$32,$34,$06,$00; 8020
    .byte $EF,$36,$38,$3A,$3C,$3E,$40,$80       ; 8030
    .res 8136, $FF                              ; 8038
