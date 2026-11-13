;GERADO para teste
.include "defs.inc"
.segment "BANK05"

; Labels definidos para que .word consiga referenciar
D05_A10B:
    .byte $00
    .word D05_A16D
D05_A16D:
    .byte $01
    .word D05_A220
D05_A220:
    .byte $02

; Tabela de defesa
D05_D00:
    .byte $00
    .word D05_D02
D05_D02:
    .byte $01
