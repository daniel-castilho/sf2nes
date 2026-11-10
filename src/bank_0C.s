; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; Banco de PRG $0C (dados) — janela $8000-$9FFF — offset no arquivo $018010
;
.include "defs.inc"
.segment "BANK0C"
D0C_8000:
    .byte $0C,$00,$06,$00,$AF,$64,$66,$68,$6A,$6C,$6E,$02,$00,$BF,$70,$72; 8000
    .byte $02,$20,$BF,$74,$76,$80,$00,$02,$10,$BF,$3C,$3E,$06,$00,$CF,$40; 8010
    .byte $42,$44,$46,$48,$4A,$06,$00,$DF,$4C,$4E,$50,$52,$54,$56,$06,$00; 8020
    .byte $EF,$58,$5A,$5C,$5E,$60,$62,$80       ; 8030
    .res 8136, $FF                              ; 8038
