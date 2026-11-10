; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; Banco de PRG $24 (dados) — janela $8000-$9FFF — offset no arquivo $048010
;
.include "defs.inc"
.segment "BANK24"
D24_8000:
    .byte $2E,$00,$02,$20,$DF,$6A,$6C,$02,$20,$EF,$6E,$70,$80,$00,$04,$00; 8000
    .byte $AF,$3C,$3E,$40,$42,$06,$00,$BF,$44,$46,$48,$4A,$4C,$4E,$05,$00; 8010
    .byte $CF,$50,$52,$54,$56,$58,$04,$00,$DF,$5A,$5C,$5E,$60,$04,$00,$EF; 8020
    .byte $62,$64,$66,$68,$80                   ; 8030
    .res 8139, $FF                              ; 8035
