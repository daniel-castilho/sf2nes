; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; Banco de PRG $01 (dados) — janela $A000-$BFFF — offset no arquivo $002010
;
.include "defs.inc"
.segment "BANK01"
D01_A000:
    .word D01_A0F6                              ; A000  F6 A0
    .word D01_A16D                              ; A002  6D A1
    .word D01_A3D5                              ; A004  D5 A3
    .word D01_A223                              ; A006  23 A2
    .word D01_A373                              ; A008  73 A3
    .word D01_A270                              ; A00A  70 A2
    .word D01_A2E7                              ; A00C  E7 A2
    .word D01_A373                              ; A00E  73 A3
    .word D01_A3EA                              ; A010  EA A3
D01_A012:
    .word D01_AD86                              ; A012  86 AD
    .word D01_AF07                              ; A014  07 AF
    .word D01_ABBF                              ; A016  BF AB
    .word D01_AADF                              ; A018  DF AA
RyuSpcTrans:
    .word D01_AF54                              ; A01A  54 AF       6 ponteiros de transicao dos especiais do Ryu (ram_0326 aponta para ca): indexados por CmdMoveIdx*2, consumidos pelo InputDispatch
    .word D01_AFA1                              ; A01C  A1 AF
    .word D01_AFEE                              ; A01E  EE AF
    .word D01_B049                              ; A020  49 B0
    .word D01_B0B9                              ; A022  B9 B0
    .word D01_B140                              ; A024  40 B1
D01_A026:
    .word D01_A4CB                              ; A026  CB A4
    .word D01_A4FE                              ; A028  FE A4       (inferido)
    .word D01_A531                              ; A02A  31 A5       (inferido)
    .word D01_A4CB                              ; A02C  CB A4
    .word D01_A4FE                              ; A02E  FE A4       (inferido)
    .word D01_A531                              ; A030  31 A5       (inferido)
    .word D01_A531                              ; A032  31 A5
    .word D01_A531                              ; A034  31 A5
    .word D01_A531                              ; A036  31 A5       (inferido)
    .word D01_A531                              ; A038  31 A5       (inferido)
    .word D01_A531                              ; A03A  31 A5       (inferido)
    .word D01_A564                              ; A03C  64 A5
D01_A03E:
    .word D01_A597                              ; A03E  97 A5       (inferido)
    .word D01_A5CA                              ; A040  CA A5       (inferido)
    .word D01_A60B                              ; A042  0B A6       (inferido)
    .word D01_A668                              ; A044  68 A6
    .word D01_A69B                              ; A046  9B A6       (inferido)
    .word D01_A6DC                              ; A048  DC A6
    .word D01_A973                              ; A04A  73 A9
    .word D01_A8F5                              ; A04C  F5 A8
    .word D01_A60B                              ; A04E  0B A6       (inferido)
    .byte $00,$00,$00,$00                       ; A050
    .word D01_A80A                              ; A054  0A A8
D01_A056:
    .word D01_A739                              ; A056  39 A7       (inferido)
    .word D01_A76C                              ; A058  6C A7       (inferido)
    .word D01_A7AD                              ; A05A  AD A7       (inferido)
    .word D01_A739                              ; A05C  39 A7
    .word D01_A76C                              ; A05E  6C A7       (inferido)
    .word D01_A7AD                              ; A060  AD A7       (inferido)
    .word D01_A973                              ; A062  73 A9
    .word D01_A8F5                              ; A064  F5 A8
    .word D01_A7AD                              ; A066  AD A7       (inferido)
    .byte $00,$00,$00,$00                       ; A068
    .word D01_A867                              ; A06C  67 A8
D01_A06E:
    .word D01_AA06                              ; A06E  06 AA
    .word D01_AA06                              ; A070  06 AA       (inferido)
    .word D01_AA06                              ; A072  06 AA
    .word D01_AA06                              ; A074  06 AA
    .word D01_AA06                              ; A076  06 AA       (inferido)
    .word D01_AA06                              ; A078  06 AA
    .word D01_AA06                              ; A07A  06 AA       (inferido)
    .word D01_A8F5                              ; A07C  F5 A8
    .word D01_A8F5                              ; A07E  F5 A8       (inferido)
    .byte $00,$00,$00,$00                       ; A080
    .word D01_A8C4                              ; A084  C4 A8
D01_A086:
    .word D01_AA92                              ; A086  92 AA
    .byte $00,$00,$92,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; A088
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; A098
    .byte $00,$00,$00,$00,$00,$00,$00,$00       ; A0A8

; -- ESTADO (cabecalho, 7 bytes)   [cond=$0A CondVitoria | classe=$E9 | acertos=0]
D01_A0B0:
    .byte $0A                                   ; A0B0
    .word D01_A10B                              ; A0B1  0B A1
    .word D01_A12E                              ; A0B3  2E A1       (inferido)
    .byte $E9,$00                               ; A0B5

; -- quadro (14 bytes)   [dur=8 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $08                                   ; A0B7
    .word D00_8D81                              ; A0B8  81 8D
    .byte $00,$00,$00,$00,$10,$04,$00,$00,$00   ; A0BA
    .word D01_A0C5                              ; A0C3  C5 A0

; -- quadro (14 bytes)   [dur=8 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D01_A0C5:
    .byte $08                                   ; A0C5
    .word D00_8AD5                              ; A0C6  D5 8A
    .byte $00,$00,$00,$00,$10,$04,$00,$00,$00   ; A0C8
    .word D01_A0D3                              ; A0D1  D3 A0

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D01_A0D3:
    .byte $64                                   ; A0D3
    .word D00_8E49                              ; A0D4  49 8E
    .byte $00,$00,$00,$00,$10,$04,$00,$00,$00   ; A0D6
    .word D01_A0D3                              ; A0DF  D3 A0

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$F0 | acertos=0]
D01_A0E1:
    .byte $FF,$00,$00,$00,$00,$F0,$00           ; A0E1

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_A0E8:
    .byte $64                                   ; A0E8
    .word D00_8106                              ; A0E9  06 81
    .byte $00,$00,$00,$00,$00,$04,$00,$00,$00   ; A0EB
    .word D01_A0E8                              ; A0F4  E8 A0

; -- ESTADO (cabecalho, 7 bytes)   [cond=$0B CondRoundPerdido | classe=$F1 | acertos=0]
D01_A0F6:
    .byte $0B                                   ; A0F6
    .word D01_A0B0                              ; A0F7  B0 A0
    .word D01_A12E                              ; A0F9  2E A1
    .byte $F1,$00                               ; A0FB

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_A0FD:
    .byte $64                                   ; A0FD
    .word D00_8AD5                              ; A0FE  D5 8A
    .byte $00,$00,$00,$00,$00,$04,$00,$00,$00   ; A100
    .word D01_A0FD                              ; A109  FD A0

; -- ESTADO (cabecalho, 7 bytes)   [cond=$01 CondOponenteLongeCostas | classe=$59 | acertos=0]
D01_A10B:
    .byte $01                                   ; A10B
    .word D01_A12E                              ; A10C  2E A1
    .word D01_A12E                              ; A10E  2E A1       (inferido)
    .byte $59,$00                               ; A110

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; A112
    .word D00_8AD5                              ; A113  D5 8A
    .word D00_93E0                              ; A115  E0 93
    .byte $00,$00,$10,$04,$00,$00,$00           ; A117
    .word D01_A120                              ; A11E  20 A1

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$07 mov=$04 vx=0 vy=0 rep=0]
D01_A120:
    .byte $01                                   ; A120
    .word D00_8AD5                              ; A121  D5 8A
    .word D00_93E0                              ; A123  E0 93
    .byte $00,$00,$07,$04,$00,$00,$00,$00,$00   ; A125

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$59 | acertos=0]
D01_A12E:
    .byte $FF,$00,$00,$00,$00,$59,$00           ; A12E

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$0F mov=$04 vx=0 vy=0 rep=0]
D01_A135:
    .byte $07                                   ; A135
    .word D00_8A20                              ; A136  20 8A
    .word D00_93E0                              ; A138  E0 93
    .byte $00,$00,$0F,$04,$00,$00,$00           ; A13A
    .word D01_A143                              ; A141  43 A1

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$0F mov=$04 vx=0 vy=0 rep=0]
D01_A143:
    .byte $07                                   ; A143
    .word D00_8A49                              ; A144  49 8A
    .word D00_93E9                              ; A146  E9 93
    .byte $00,$00,$0F,$04,$00,$00,$00           ; A148
    .word D01_A151                              ; A14F  51 A1

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$0F mov=$04 vx=0 vy=0 rep=0]
D01_A151:
    .byte $07                                   ; A151
    .word D00_8A73                              ; A152  73 8A
    .word D00_93F2                              ; A154  F2 93
    .byte $00,$00,$0F,$04,$00,$00,$00           ; A156
    .word D01_A15F                              ; A15D  5F A1

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$0F mov=$04 vx=0 vy=0 rep=0]
D01_A15F:
    .byte $07                                   ; A15F
    .word D00_8A49                              ; A160  49 8A
    .word D00_93E9                              ; A162  E9 93
    .byte $00,$00,$0F,$04,$00,$00,$00           ; A164
    .word D01_A135                              ; A16B  35 A1

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$61 | acertos=0]
D01_A16D:
    .byte $FF,$00,$00,$00,$00,$61,$00           ; A16D

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$17 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $01                                   ; A174
    .word D00_8D81                              ; A175  81 8D
    .word D00_9443                              ; A177  43 94
    .byte $00,$00,$17,$04,$00,$00,$00           ; A179
    .word D01_A190                              ; A180  90 A1

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$1F mov=$04 vx=23 vy=0 rep=0]
D01_A182:
    .byte $04                                   ; A182
    .word D00_8D81                              ; A183  81 8D
    .word D00_944C                              ; A185  4C 94
    .byte $00,$00,$1F,$04,$17,$00,$00           ; A187
    .word D01_A190                              ; A18E  90 A1

; -- quadro (14 bytes)   [dur=8 efe=$00/$00 fl=$1F mov=$04 vx=23 vy=0 rep=0]
D01_A190:
    .byte $08                                   ; A190
    .word D00_8DA3                              ; A191  A3 8D
    .word D00_944C                              ; A193  4C 94
    .byte $00,$00,$1F,$04,$17,$00,$00           ; A195
    .word D01_A19E                              ; A19C  9E A1

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$1F mov=$04 vx=23 vy=0 rep=0]
D01_A19E:
    .byte $06                                   ; A19E
    .word D00_8DCD                              ; A19F  CD 8D
    .word D00_9455                              ; A1A1  55 94
    .byte $00,$00,$1F,$04,$17,$00,$00           ; A1A3
    .word D01_A1AC                              ; A1AA  AC A1

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$1F mov=$04 vx=23 vy=0 rep=0]
D01_A1AC:
    .byte $07                                   ; A1AC
    .word D00_8DF7                              ; A1AD  F7 8D
    .word D00_945E                              ; A1AF  5E 94
    .byte $00,$00,$1F,$04,$17,$00,$00           ; A1B1
    .word D01_A1BA                              ; A1B8  BA A1

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$1F mov=$04 vx=23 vy=0 rep=0]
D01_A1BA:
    .byte $07                                   ; A1BA
    .word D00_8E1F                              ; A1BB  1F 8E
    .word D00_9467                              ; A1BD  67 94
    .byte $00,$00,$1F,$04,$17,$00,$00           ; A1BF
    .word D01_A182                              ; A1C6  82 A1

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$69 | acertos=0]
D01_A1C8:
    .byte $FF,$00,$00,$00,$00,$69,$00           ; A1C8

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$17 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $01                                   ; A1CF
    .word D00_8D81                              ; A1D0  81 8D
    .word D00_9443                              ; A1D2  43 94
    .byte $00,$00,$17,$04,$00,$00,$00           ; A1D4
    .word D01_A1EB                              ; A1DB  EB A1

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$1F mov=$04 vx=-16 vy=0 rep=0]
D01_A1DD:
    .byte $04                                   ; A1DD
    .word D00_8D81                              ; A1DE  81 8D
    .word D00_9443                              ; A1E0  43 94
    .byte $00,$00,$1F,$04,$F0,$00,$00           ; A1E2
    .word D01_A1EB                              ; A1E9  EB A1

; -- quadro (14 bytes)   [dur=8 efe=$00/$00 fl=$1F mov=$04 vx=-16 vy=0 rep=0]
D01_A1EB:
    .byte $08                                   ; A1EB
    .word D00_8DA3                              ; A1EC  A3 8D
    .word D00_944C                              ; A1EE  4C 94
    .byte $00,$00,$1F,$04,$F0,$00,$00           ; A1F0
    .word D01_A1F9                              ; A1F7  F9 A1

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$1F mov=$04 vx=-16 vy=0 rep=0]
D01_A1F9:
    .byte $06                                   ; A1F9
    .word D00_8DCD                              ; A1FA  CD 8D
    .word D00_9455                              ; A1FC  55 94
    .byte $00,$00,$1F,$04,$F0,$00,$00           ; A1FE
    .word D01_A207                              ; A205  07 A2

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$1F mov=$04 vx=-16 vy=0 rep=0]
D01_A207:
    .byte $07                                   ; A207
    .word D00_8DF7                              ; A208  F7 8D
    .word D00_945E                              ; A20A  5E 94
    .byte $00,$00,$1F,$04,$F0,$00,$00           ; A20C
    .word D01_A215                              ; A213  15 A2

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$1F mov=$04 vx=-16 vy=0 rep=0]
D01_A215:
    .byte $07                                   ; A215
    .word D00_8E1F                              ; A216  1F 8E
    .word D00_9467                              ; A218  67 94
    .byte $00,$00,$1F,$04,$F0,$00,$00           ; A21A
    .word D01_A1DD                              ; A221  DD A1

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$5C | acertos=0]
D01_A223:
    .byte $FF,$00,$00                           ; A223
    .word D01_A35E                              ; A226  5E A3
    .byte $5C,$00                               ; A228

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; A22A
    .word D00_8D81                              ; A22B  81 8D
    .word D00_9443                              ; A22D  43 94
    .byte $00,$00,$10,$04,$00,$00,$00           ; A22F
    .word D01_A238                              ; A236  38 A2

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=-76 rep=0]
D01_A238:
    .byte $01                                   ; A238
    .word D00_8809                              ; A239  09 88
    .word D00_9362                              ; A23B  62 93
    .byte $00,$00,$00,$02,$00,$B4,$00           ; A23D
    .word D01_A246                              ; A244  46 A2

; -- quadro (14 bytes)   [dur=13 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A246:
    .byte $0D                                   ; A246
    .word D00_8809                              ; A247  09 88
    .word D00_9362                              ; A249  62 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A24B
    .word D01_A254                              ; A252  54 A2

; -- quadro (14 bytes)   [dur=22 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A254:
    .byte $16                                   ; A254
    .word D00_882C                              ; A255  2C 88
    .word D00_9368                              ; A257  68 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A259
    .word D01_A262                              ; A260  62 A2

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A262:
    .byte $64                                   ; A262
    .word D00_8809                              ; A263  09 88
    .word D00_9362                              ; A265  62 93
    .byte $00,$00,$0A,$02,$00,$00,$00,$00,$00   ; A267

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$64 | acertos=0]
D01_A270:
    .byte $FF,$00,$00                           ; A270
    .word D01_A35E                              ; A273  5E A3
    .byte $64,$00                               ; A275

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; A277
    .word D00_8D81                              ; A278  81 8D
    .word D00_9443                              ; A27A  43 94
    .byte $00,$00,$10,$04,$00,$00,$00           ; A27C
    .word D01_A285                              ; A283  85 A2

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$00 mov=$02 vx=20 vy=-76 rep=0]
D01_A285:
    .byte $01                                   ; A285
    .word D00_8809                              ; A286  09 88
    .word D00_9362                              ; A288  62 93
    .byte $00,$00,$00,$02,$14,$B4,$00           ; A28A
    .word D01_A293                              ; A291  93 A2

; -- quadro (14 bytes)   [dur=15 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A293:
    .byte $0F                                   ; A293
    .word D00_8809                              ; A294  09 88
    .word D00_9362                              ; A296  62 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A298
    .word D01_A2A1                              ; A29F  A1 A2

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A2A1:
    .byte $06                                   ; A2A1
    .word D00_8849                              ; A2A2  49 88
    .word D00_936E                              ; A2A4  6E 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A2A6
    .word D01_A2AF                              ; A2AD  AF A2

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A2AF:
    .byte $05                                   ; A2AF
    .word D00_8868                              ; A2B0  68 88
    .word D00_9377                              ; A2B2  77 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A2B4
    .word D01_A2BD                              ; A2BB  BD A2

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A2BD:
    .byte $05                                   ; A2BD
    .word D00_8885                              ; A2BE  85 88
    .word D00_9380                              ; A2C0  80 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A2C2
    .word D01_A2CB                              ; A2C9  CB A2

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A2CB:
    .byte $06                                   ; A2CB
    .word D00_88A4                              ; A2CC  A4 88
    .word D00_9389                              ; A2CE  89 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A2D0
    .word D01_A2D9                              ; A2D7  D9 A2

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A2D9:
    .byte $64                                   ; A2D9
    .word D00_8809                              ; A2DA  09 88
    .word D00_9362                              ; A2DC  62 93
    .byte $00,$00,$0A,$02,$00,$00,$00,$00,$00   ; A2DE

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$6C | acertos=0]
D01_A2E7:
    .byte $FF,$00,$00                           ; A2E7
    .word D01_A35E                              ; A2EA  5E A3
    .byte $6C,$00                               ; A2EC

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; A2EE
    .word D00_8D81                              ; A2EF  81 8D
    .word D00_9443                              ; A2F1  43 94
    .byte $00,$00,$10,$04,$00,$00,$00           ; A2F3
    .word D01_A2FC                              ; A2FA  FC A2

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$00 mov=$02 vx=-25 vy=-76 rep=0]
D01_A2FC:
    .byte $01                                   ; A2FC
    .word D00_88A4                              ; A2FD  A4 88
    .word D00_9389                              ; A2FF  89 93
    .byte $00,$00,$00,$02,$E7,$B4,$00           ; A301
    .word D01_A30A                              ; A308  0A A3

; -- quadro (14 bytes)   [dur=15 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A30A:
    .byte $0F                                   ; A30A
    .word D00_88A4                              ; A30B  A4 88
    .word D00_9389                              ; A30D  89 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A30F
    .word D01_A318                              ; A316  18 A3

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A318:
    .byte $06                                   ; A318
    .word D00_8885                              ; A319  85 88
    .word D00_9380                              ; A31B  80 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A31D
    .word D01_A326                              ; A324  26 A3

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A326:
    .byte $05                                   ; A326
    .word D00_8868                              ; A327  68 88
    .word D00_9377                              ; A329  77 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A32B
    .word D01_A334                              ; A332  34 A3

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A334:
    .byte $05                                   ; A334
    .word D00_8849                              ; A335  49 88
    .word D00_936E                              ; A337  6E 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A339
    .word D01_A342                              ; A340  42 A3

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A342:
    .byte $06                                   ; A342
    .word D00_8809                              ; A343  09 88
    .word D00_9362                              ; A345  62 93
    .byte $00,$00,$0A,$02,$00,$00,$00           ; A347
    .word D01_A350                              ; A34E  50 A3

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D01_A350:
    .byte $64                                   ; A350
    .word D00_8809                              ; A351  09 88
    .word D00_9362                              ; A353  62 93
    .byte $00,$00,$0A,$02,$00,$00,$00,$00,$00   ; A355

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$59 | acertos=0]
D01_A35E:
    .byte $FF,$00,$00                           ; A35E
    .word D01_A12E                              ; A361  2E A1       (inferido)
    .byte $59,$00                               ; A363

; -- quadro (14 bytes)   [dur=3 efe=$00/$20 fl=$0E mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; A365
    .word D00_8D81                              ; A366  81 8D
    .word D00_9443                              ; A368  43 94
    .byte $00,$20,$0E,$04,$00,$00,$00,$00,$00   ; A36A

; -- ESTADO (cabecalho, 7 bytes)   [cond=$03 CondEmPe | classe=$5A | acertos=0]
D01_A373:
    .byte $03                                   ; A373
    .word D01_A39D                              ; A374  9D A3
    .word D01_A3C0                              ; A376  C0 A3       (inferido)
    .byte $5A,$00                               ; A378

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$07 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $02                                   ; A37A
    .word D00_8D81                              ; A37B  81 8D
    .word D00_9443                              ; A37D  43 94
    .byte $00,$00,$07,$04,$00,$00,$00,$00,$00   ; A37F

; -- ESTADO (cabecalho, 7 bytes)   [cond=$04 CondAgachado | classe=$59 | acertos=0]   [$A388, nenhum ponteiro conhecido aponta para ca]
    .byte $04                                   ; A388
    .word D01_A10B                              ; A389  0B A1       (inferido)
    .word D01_A12E                              ; A38B  2E A1       (inferido)
    .byte $59,$00                               ; A38D

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$07 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $02                                   ; A38F
    .word D00_8D81                              ; A390  81 8D       (inferido)
    .word D00_9443                              ; A392  43 94       (inferido)
    .byte $00,$00,$07,$04,$00,$00,$00,$00,$00   ; A394

; -- ESTADO (cabecalho, 7 bytes)   [cond=$01 CondOponenteLongeCostas | classe=$5A | acertos=0]
D01_A39D:
    .byte $01                                   ; A39D
    .word D01_A3C0                              ; A39E  C0 A3
    .word D01_A3C0                              ; A3A0  C0 A3       (inferido)
    .byte $5A,$00                               ; A3A2

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; A3A4
    .word D00_806A                              ; A3A5  6A 80
    .word D00_91D3                              ; A3A7  D3 91
    .byte $00,$00,$10,$04,$00,$00,$00           ; A3A9
    .word D01_A3B2                              ; A3B0  B2 A3

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$07 mov=$04 vx=0 vy=0 rep=0]
D01_A3B2:
    .byte $01                                   ; A3B2
    .word D00_806A                              ; A3B3  6A 80
    .word D00_91D3                              ; A3B5  D3 91
    .byte $00,$00,$07,$04,$00,$00,$00,$00,$00   ; A3B7

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$5A | acertos=0]
D01_A3C0:
    .byte $FF,$00,$00,$00,$00,$5A,$00           ; A3C0

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$0F mov=$04 vx=0 vy=0 rep=0]
D01_A3C7:
    .byte $64                                   ; A3C7
    .word D00_8046                              ; A3C8  46 80
    .word D00_91D3                              ; A3CA  D3 91
    .byte $00,$00,$0F,$04,$00,$00,$00           ; A3CC
    .word D01_A3C7                              ; A3D3  C7 A3       (inferido)

; -- ESTADO (cabecalho, 7 bytes)   [cond=$00 CondOponenteAtaca | classe=$29 | acertos=0]
D01_A3D5:
    .byte $00                                   ; A3D5
    .word D01_A1C8                              ; A3D6  C8 A1
    .word D01_A12E                              ; A3D8  2E A1       (inferido)
    .byte $29,$00                               ; A3DA

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$1F mov=$04 vx=0 vy=0 rep=0]
D01_A3DC:
    .byte $64                                   ; A3DC
    .word D00_8020                              ; A3DD  20 80
    .word D00_91CA                              ; A3DF  CA 91
    .byte $00,$00,$1F,$04,$00,$00,$00           ; A3E1
    .word D01_A3DC                              ; A3E8  DC A3       (inferido)

; -- ESTADO (cabecalho, 7 bytes)   [cond=$00 CondOponenteAtaca | classe=$2A | acertos=0]
D01_A3EA:
    .byte $00                                   ; A3EA
    .word D01_A373                              ; A3EB  73 A3
    .word D01_A3C0                              ; A3ED  C0 A3       (inferido)
    .byte $2A,$00                               ; A3EF

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$1F mov=$04 vx=0 vy=0 rep=0]
D01_A3F1:
    .byte $64                                   ; A3F1
    .word D00_8000                              ; A3F2  00 80
    .word D00_91C1                              ; A3F4  C1 91
    .byte $00,$00,$1F,$04,$00,$00,$00           ; A3F6
    .word D01_A3F1                              ; A3FD  F1 A3       (inferido)

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$29 | acertos=0]
D01_A3FF:
    .byte $FF,$00,$00                           ; A3FF
    .word D01_A12E                              ; A402  2E A1
    .byte $29,$00                               ; A404

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D01_A406:
    .byte $01                                   ; A406
    .word D00_8020                              ; A407  20 80
    .word D00_91CA                              ; A409  CA 91
    .byte $00,$00,$30,$04,$E0,$00,$00           ; A40B
    .word D01_A414                              ; A412  14 A4

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7 br=$A406]
D01_A414:
    .byte $01                                   ; A414
    .word D00_8020                              ; A415  20 80
    .word D00_91CA                              ; A417  CA 91
    .byte $00,$00,$30,$04,$20,$00,$07           ; A419
    .word D01_A424                              ; A420  24 A4
    .word D01_A406                              ; A422  06 A4

; -- quadro (14 bytes)   [dur=26 efe=$00/$00 fl=$40 mov=$02 vx=-32 vy=0 rep=0]
D01_A424:
    .byte $1A                                   ; A424
    .word D00_8020                              ; A425  20 80
    .word D00_91CA                              ; A427  CA 91
    .byte $00,$00,$40,$02,$E0,$00,$00,$00,$00   ; A429

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$29 | acertos=0]   [$A432, nenhum ponteiro conhecido aponta para ca]
    .byte $FF,$00,$00                           ; A432
    .word D01_A12E                              ; A435  2E A1       (inferido)
    .byte $29,$00                               ; A437

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D01_A439:
    .byte $01                                   ; A439
    .word D00_8020                              ; A43A  20 80       (inferido)
    .word D00_91CA                              ; A43C  CA 91       (inferido)
    .byte $00,$00,$30,$04,$E0,$00,$00           ; A43E
    .word D01_A447                              ; A445  47 A4       (inferido)

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7 br=$A439]
D01_A447:
    .byte $01                                   ; A447
    .word D00_8020                              ; A448  20 80       (inferido)
    .word D00_91CA                              ; A44A  CA 91       (inferido)
    .byte $00,$00,$30,$04,$20,$00,$07           ; A44C
    .word D01_A457                              ; A453  57 A4       (inferido)
    .word D01_A439                              ; A455  39 A4       (inferido)

; -- quadro (14 bytes)   [dur=36 efe=$00/$00 fl=$40 mov=$02 vx=-45 vy=0 rep=0]
D01_A457:
    .byte $24                                   ; A457
    .word D00_8020                              ; A458  20 80       (inferido)
    .word D00_91CA                              ; A45A  CA 91       (inferido)
    .byte $00,$00,$40,$02,$D3,$00,$00,$00,$00   ; A45C

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$29 | acertos=0]
D01_A465:
    .byte $FF,$00,$00                           ; A465
    .word D01_A12E                              ; A468  2E A1
    .byte $29,$00                               ; A46A

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D01_A46C:
    .byte $01                                   ; A46C
    .word D00_8020                              ; A46D  20 80
    .word D00_91CA                              ; A46F  CA 91
    .byte $00,$00,$30,$04,$E0,$00,$00           ; A471
    .word D01_A47A                              ; A478  7A A4

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7 br=$A46C]
D01_A47A:
    .byte $01                                   ; A47A
    .word D00_8020                              ; A47B  20 80
    .word D00_91CA                              ; A47D  CA 91
    .byte $00,$00,$30,$04,$20,$00,$07           ; A47F
    .word D01_A48A                              ; A486  8A A4
    .word D01_A46C                              ; A488  6C A4

; -- quadro (14 bytes)   [dur=36 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D01_A48A:
    .byte $24                                   ; A48A
    .word D00_8020                              ; A48B  20 80
    .word D00_91CA                              ; A48D  CA 91
    .byte $00,$00,$40,$02,$C9,$00,$00,$00,$00   ; A48F

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$29 | acertos=0]
D01_A498:
    .byte $FF,$00,$00                           ; A498
    .word D01_A12E                              ; A49B  2E A1
    .byte $29,$00                               ; A49D

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D01_A49F:
    .byte $01                                   ; A49F
    .word D00_8020                              ; A4A0  20 80
    .word D00_91CA                              ; A4A2  CA 91
    .byte $00,$00,$30,$04,$E0,$00,$00           ; A4A4
    .word D01_A4AD                              ; A4AB  AD A4

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7 br=$A49F]
D01_A4AD:
    .byte $01                                   ; A4AD
    .word D00_8020                              ; A4AE  20 80
    .word D00_91CA                              ; A4B0  CA 91
    .byte $00,$00,$30,$04,$20,$00,$07           ; A4B2
    .word D01_A4BD                              ; A4B9  BD A4
    .word D01_A49F                              ; A4BB  9F A4

; -- quadro (14 bytes)   [dur=36 efe=$00/$00 fl=$00 mov=$02 vx=-55 vy=0 rep=0]
D01_A4BD:
    .byte $24                                   ; A4BD
    .word D00_8020                              ; A4BE  20 80
    .word D00_91CA                              ; A4C0  CA 91
    .byte $00,$00,$00,$02,$C9,$00,$00,$00,$00   ; A4C2

; -- ESTADO (cabecalho, 7 bytes)   [cond=$04 CondAgachado | classe=$2A | acertos=0]
D01_A4CB:
    .byte $04                                   ; A4CB
    .word D01_A3FF                              ; A4CC  FF A3
    .word D01_A3C0                              ; A4CE  C0 A3       (inferido)
    .byte $2A,$00                               ; A4D0

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D01_A4D2:
    .byte $01                                   ; A4D2
    .word D00_8000                              ; A4D3  00 80       (inferido)
    .word D00_91C1                              ; A4D5  C1 91       (inferido)
    .byte $00,$00,$30,$04,$E0,$00,$00           ; A4D7
    .word D01_A4E0                              ; A4DE  E0 A4       (inferido)

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7 br=$A4D2]
D01_A4E0:
    .byte $01                                   ; A4E0
    .word D00_8000                              ; A4E1  00 80       (inferido)
    .word D00_91C1                              ; A4E3  C1 91       (inferido)
    .byte $00,$00,$30,$04,$20,$00,$07           ; A4E5
    .word D01_A4F0                              ; A4EC  F0 A4       (inferido)
    .word D01_A4D2                              ; A4EE  D2 A4       (inferido)

; -- quadro (14 bytes)   [dur=19 efe=$00/$00 fl=$40 mov=$02 vx=-32 vy=0 rep=0]
D01_A4F0:
    .byte $13                                   ; A4F0
    .word D00_8000                              ; A4F1  00 80
    .word D00_91C1                              ; A4F3  C1 91
    .byte $00,$00,$40,$02,$E0,$00,$00,$00,$00   ; A4F5

; -- ESTADO (cabecalho, 7 bytes)   [cond=$04 CondAgachado | classe=$2A | acertos=0]
D01_A4FE:
    .byte $04                                   ; A4FE
    .word D01_A465                              ; A4FF  65 A4       (inferido)
    .word D01_A3C0                              ; A501  C0 A3       (inferido)
    .byte $2A,$00                               ; A503

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D01_A505:
    .byte $01                                   ; A505
    .word D00_8000                              ; A506  00 80       (inferido)
    .word D00_91C1                              ; A508  C1 91       (inferido)
    .byte $00,$00,$30,$04,$E0,$00,$00           ; A50A
    .word D01_A513                              ; A511  13 A5       (inferido)

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7 br=$A505]
D01_A513:
    .byte $01                                   ; A513
    .word D00_8000                              ; A514  00 80       (inferido)
    .word D00_91C1                              ; A516  C1 91       (inferido)
    .byte $00,$00,$30,$04,$20,$00,$07           ; A518
    .word D01_A523                              ; A51F  23 A5       (inferido)
    .word D01_A505                              ; A521  05 A5       (inferido)

; -- quadro (14 bytes)   [dur=36 efe=$00/$00 fl=$40 mov=$02 vx=-45 vy=0 rep=0]
D01_A523:
    .byte $24                                   ; A523
    .word D00_8000                              ; A524  00 80       (inferido)
    .word D00_91C1                              ; A526  C1 91       (inferido)
    .byte $00,$00,$40,$02,$D3,$00,$00,$00,$00   ; A528

; -- ESTADO (cabecalho, 7 bytes)   [cond=$04 CondAgachado | classe=$2A | acertos=0]
D01_A531:
    .byte $04                                   ; A531
    .word D01_A465                              ; A532  65 A4
    .word D01_A3C0                              ; A534  C0 A3       (inferido)
    .byte $2A,$00                               ; A536

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D01_A538:
    .byte $01                                   ; A538
    .word D00_8000                              ; A539  00 80
    .word D00_91C1                              ; A53B  C1 91
    .byte $00,$00,$30,$04,$E0,$00,$00           ; A53D
    .word D01_A546                              ; A544  46 A5

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7 br=$A538]
D01_A546:
    .byte $01                                   ; A546
    .word D00_8000                              ; A547  00 80
    .word D00_91C1                              ; A549  C1 91
    .byte $00,$00,$30,$04,$20,$00,$07           ; A54B
    .word D01_A556                              ; A552  56 A5
    .word D01_A538                              ; A554  38 A5

; -- quadro (14 bytes)   [dur=36 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D01_A556:
    .byte $24                                   ; A556
    .word D00_8000                              ; A557  00 80
    .word D00_91C1                              ; A559  C1 91
    .byte $00,$00,$40,$02,$C9,$00,$00,$00,$00   ; A55B

; -- ESTADO (cabecalho, 7 bytes)   [cond=$04 CondAgachado | classe=$2A | acertos=0]
D01_A564:
    .byte $04                                   ; A564
    .word D01_A498                              ; A565  98 A4
    .word D01_A3C0                              ; A567  C0 A3
    .byte $2A,$00                               ; A569

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D01_A56B:
    .byte $01                                   ; A56B
    .word D00_8000                              ; A56C  00 80
    .word D00_91C1                              ; A56E  C1 91
    .byte $00,$00,$30,$04,$E0,$00,$00           ; A570
    .word D01_A579                              ; A577  79 A5

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7 br=$A56B]
D01_A579:
    .byte $01                                   ; A579
    .word D00_8000                              ; A57A  00 80
    .word D00_91C1                              ; A57C  C1 91
    .byte $00,$00,$30,$04,$20,$00,$07           ; A57E
    .word D01_A589                              ; A585  89 A5
    .word D01_A56B                              ; A587  6B A5

; -- quadro (14 bytes)   [dur=36 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D01_A589:
    .byte $24                                   ; A589
    .word D00_8000                              ; A58A  00 80
    .word D00_91C1                              ; A58C  C1 91
    .byte $00,$00,$40,$02,$C9,$00,$00,$00,$00   ; A58E

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$31 | acertos=0]
D01_A597:
    .byte $FF,$00,$00                           ; A597
    .word D01_A12E                              ; A59A  2E A1       (inferido)
    .byte $31,$00                               ; A59C

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A59E:
    .byte $01                                   ; A59E
    .word D00_8350                              ; A59F  50 83       (inferido)
    .word D00_923C                              ; A5A1  3C 92       (inferido)
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A5A3
    .word D01_A5AC                              ; A5AA  AC A5       (inferido)

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A59E]
D01_A5AC:
    .byte $01                                   ; A5AC
    .word D00_8350                              ; A5AD  50 83       (inferido)
    .word D00_923C                              ; A5AF  3C 92       (inferido)
    .byte $00,$00,$20,$04,$20,$00,$07           ; A5B1
    .word D01_A5BC                              ; A5B8  BC A5       (inferido)
    .word D01_A59E                              ; A5BA  9E A5       (inferido)

; -- quadro (14 bytes)   [dur=11 efe=$00/$00 fl=$40 mov=$02 vx=-32 vy=0 rep=0]
D01_A5BC:
    .byte $0B                                   ; A5BC
    .word D00_8350                              ; A5BD  50 83       (inferido)
    .word D00_923C                              ; A5BF  3C 92       (inferido)
    .byte $00,$00,$40,$02,$E0,$00,$00,$00,$00   ; A5C1

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$31 | acertos=0]
D01_A5CA:
    .byte $FF,$00,$00                           ; A5CA
    .word D01_A12E                              ; A5CD  2E A1       (inferido)
    .byte $31,$00                               ; A5CF

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A5D1:
    .byte $01                                   ; A5D1
    .word D00_8350                              ; A5D2  50 83       (inferido)
    .word D00_923C                              ; A5D4  3C 92       (inferido)
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A5D6
    .word D01_A5DF                              ; A5DD  DF A5       (inferido)

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A5D1]
D01_A5DF:
    .byte $01                                   ; A5DF
    .word D00_8350                              ; A5E0  50 83       (inferido)
    .word D00_923C                              ; A5E2  3C 92       (inferido)
    .byte $00,$00,$20,$04,$20,$00,$07           ; A5E4
    .word D01_A5EF                              ; A5EB  EF A5       (inferido)
    .word D01_A5D1                              ; A5ED  D1 A5       (inferido)

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$40 mov=$02 vx=-45 vy=0 rep=0]
D01_A5EF:
    .byte $03                                   ; A5EF
    .word D00_8350                              ; A5F0  50 83       (inferido)
    .word D00_923C                              ; A5F2  3C 92       (inferido)
    .byte $00,$00,$40,$02,$D3,$00,$00           ; A5F4
    .word D01_A5FD                              ; A5FB  FD A5       (inferido)

; -- quadro (14 bytes)   [dur=13 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A5FD:
    .byte $0D                                   ; A5FD
    .word D00_8375                              ; A5FE  75 83       (inferido)
    .word D00_9242                              ; A600  42 92       (inferido)
    .byte $00,$00,$40,$02,$00,$00,$00,$00,$00   ; A602

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$31 | acertos=0]
D01_A60B:
    .byte $FF,$00,$00                           ; A60B
    .word D01_A12E                              ; A60E  2E A1       (inferido)
    .byte $31,$00                               ; A610

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A612:
    .byte $01                                   ; A612
    .word D00_8350                              ; A613  50 83       (inferido)
    .word D00_923C                              ; A615  3C 92       (inferido)
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A617
    .word D01_A620                              ; A61E  20 A6       (inferido)

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A612]
D01_A620:
    .byte $01                                   ; A620
    .word D00_8350                              ; A621  50 83       (inferido)
    .word D00_923C                              ; A623  3C 92       (inferido)
    .byte $00,$00,$20,$04,$20,$00,$07           ; A625
    .word D01_A630                              ; A62C  30 A6       (inferido)
    .word D01_A612                              ; A62E  12 A6       (inferido)

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D01_A630:
    .byte $03                                   ; A630
    .word D00_8350                              ; A631  50 83       (inferido)
    .word D00_923C                              ; A633  3C 92       (inferido)
    .byte $00,$00,$40,$02,$C9,$00,$00           ; A635
    .word D01_A63E                              ; A63C  3E A6       (inferido)

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A63E:
    .byte $04                                   ; A63E
    .word D00_8375                              ; A63F  75 83       (inferido)
    .word D00_9242                              ; A641  42 92       (inferido)
    .byte $00,$00,$40,$02,$00,$00,$00           ; A643
    .word D01_A64C                              ; A64A  4C A6       (inferido)

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A64C:
    .byte $04                                   ; A64C
    .word D00_839C                              ; A64D  9C 83       (inferido)
    .word D00_924B                              ; A64F  4B 92       (inferido)
    .byte $00,$00,$40,$02,$00,$00,$00           ; A651
    .word D01_A65A                              ; A658  5A A6       (inferido)

; -- quadro (14 bytes)   [dur=9 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A65A:
    .byte $09                                   ; A65A
    .word D00_80B6                              ; A65B  B6 80       (inferido)
    .word D00_91E5                              ; A65D  E5 91       (inferido)
    .byte $00,$00,$40,$02,$00,$00,$00,$00,$00   ; A65F

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$31 | acertos=0]
D01_A668:
    .byte $FF,$00,$00                           ; A668
    .word D01_A12E                              ; A66B  2E A1
    .byte $31,$00                               ; A66D

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A66F:
    .byte $01                                   ; A66F
    .word D00_827C                              ; A670  7C 82
    .word D00_9209                              ; A672  09 92
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A674
    .word D01_A67D                              ; A67B  7D A6

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A66F]
D01_A67D:
    .byte $01                                   ; A67D
    .word D00_827C                              ; A67E  7C 82
    .word D00_9209                              ; A680  09 92
    .byte $00,$00,$20,$04,$20,$00,$07           ; A682
    .word D01_A68D                              ; A689  8D A6
    .word D01_A66F                              ; A68B  6F A6

; -- quadro (14 bytes)   [dur=11 efe=$00/$00 fl=$40 mov=$02 vx=-32 vy=0 rep=0]
D01_A68D:
    .byte $0B                                   ; A68D
    .word D00_827C                              ; A68E  7C 82
    .word D00_9209                              ; A690  09 92
    .byte $00,$00,$40,$02,$E0,$00,$00,$00,$00   ; A692

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$31 | acertos=0]
D01_A69B:
    .byte $FF,$00,$00                           ; A69B
    .word D01_A12E                              ; A69E  2E A1       (inferido)
    .byte $31,$00                               ; A6A0

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A6A2:
    .byte $01                                   ; A6A2
    .word D00_827C                              ; A6A3  7C 82       (inferido)
    .word D00_9209                              ; A6A5  09 92       (inferido)
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A6A7
    .word D01_A6B0                              ; A6AE  B0 A6       (inferido)

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A6A2]
D01_A6B0:
    .byte $01                                   ; A6B0
    .word D00_827C                              ; A6B1  7C 82       (inferido)
    .word D00_9209                              ; A6B3  09 92       (inferido)
    .byte $00,$00,$20,$04,$20,$00,$07           ; A6B5
    .word D01_A6C0                              ; A6BC  C0 A6       (inferido)
    .word D01_A6A2                              ; A6BE  A2 A6       (inferido)

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$40 mov=$02 vx=-45 vy=0 rep=0]
D01_A6C0:
    .byte $07                                   ; A6C0
    .word D00_827C                              ; A6C1  7C 82       (inferido)
    .word D00_9209                              ; A6C3  09 92       (inferido)
    .byte $00,$00,$40,$02,$D3,$00,$00           ; A6C5
    .word D01_A6CE                              ; A6CC  CE A6       (inferido)

; -- quadro (14 bytes)   [dur=9 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A6CE:
    .byte $09                                   ; A6CE
    .word D00_82A1                              ; A6CF  A1 82       (inferido)
    .word D00_920F                              ; A6D1  0F 92       (inferido)
    .byte $00,$00,$40,$02,$00,$00,$00,$00,$00   ; A6D3

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$31 | acertos=0]
D01_A6DC:
    .byte $FF,$00,$00                           ; A6DC
    .word D01_A12E                              ; A6DF  2E A1
    .byte $31,$00                               ; A6E1

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A6E3:
    .byte $01                                   ; A6E3
    .word D00_827C                              ; A6E4  7C 82
    .word D00_9209                              ; A6E6  09 92
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A6E8
    .word D01_A6F1                              ; A6EF  F1 A6

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A6E3]
D01_A6F1:
    .byte $01                                   ; A6F1
    .word D00_827C                              ; A6F2  7C 82
    .word D00_9209                              ; A6F4  09 92
    .byte $00,$00,$20,$04,$20,$00,$07           ; A6F6
    .word D01_A701                              ; A6FD  01 A7
    .word D01_A6E3                              ; A6FF  E3 A6

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D01_A701:
    .byte $03                                   ; A701
    .word D00_827C                              ; A702  7C 82
    .word D00_9209                              ; A704  09 92
    .byte $00,$00,$40,$02,$C9,$00,$00           ; A706
    .word D01_A70F                              ; A70D  0F A7

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A70F:
    .byte $04                                   ; A70F
    .word D00_82A1                              ; A710  A1 82
    .word D00_920F                              ; A712  0F 92
    .byte $00,$00,$40,$02,$00,$00,$00           ; A714
    .word D01_A71D                              ; A71B  1D A7

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A71D:
    .byte $04                                   ; A71D
    .word D00_82C5                              ; A71E  C5 82
    .word D00_9218                              ; A720  18 92
    .byte $00,$00,$40,$02,$00,$00,$00           ; A722
    .word D01_A72B                              ; A729  2B A7

; -- quadro (14 bytes)   [dur=9 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A72B:
    .byte $09                                   ; A72B
    .word D00_80B6                              ; A72C  B6 80
    .word D00_91E5                              ; A72E  E5 91
    .byte $00,$00,$40,$02,$00,$00,$00,$00,$00   ; A730

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$32 | acertos=0]
D01_A739:
    .byte $FF,$00,$00                           ; A739
    .word D01_A3C0                              ; A73C  C0 A3
    .byte $32,$00                               ; A73E

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A740:
    .byte $01                                   ; A740
    .word D00_82ED                              ; A741  ED 82
    .word D00_9221                              ; A743  21 92
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A745
    .word D01_A74E                              ; A74C  4E A7

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A740]
D01_A74E:
    .byte $01                                   ; A74E
    .word D00_82ED                              ; A74F  ED 82
    .word D00_9221                              ; A751  21 92
    .byte $00,$00,$20,$04,$20,$00,$07           ; A753
    .word D01_A75E                              ; A75A  5E A7
    .word D01_A740                              ; A75C  40 A7

; -- quadro (14 bytes)   [dur=11 efe=$00/$00 fl=$40 mov=$02 vx=-32 vy=0 rep=0]
D01_A75E:
    .byte $0B                                   ; A75E
    .word D00_82ED                              ; A75F  ED 82
    .word D00_9221                              ; A761  21 92
    .byte $00,$00,$40,$02,$E0,$00,$00,$00,$00   ; A763

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$32 | acertos=0]
D01_A76C:
    .byte $FF,$00,$00                           ; A76C
    .word D01_A3C0                              ; A76F  C0 A3       (inferido)
    .byte $32,$00                               ; A771

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A773:
    .byte $01                                   ; A773
    .word D00_82ED                              ; A774  ED 82       (inferido)
    .word D00_9221                              ; A776  21 92       (inferido)
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A778
    .word D01_A781                              ; A77F  81 A7       (inferido)

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A773]
D01_A781:
    .byte $01                                   ; A781
    .word D00_82ED                              ; A782  ED 82       (inferido)
    .word D00_9221                              ; A784  21 92       (inferido)
    .byte $00,$00,$20,$04,$20,$00,$07           ; A786
    .word D01_A791                              ; A78D  91 A7       (inferido)
    .word D01_A773                              ; A78F  73 A7       (inferido)

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$40 mov=$02 vx=-45 vy=0 rep=0]
D01_A791:
    .byte $07                                   ; A791
    .word D00_82ED                              ; A792  ED 82       (inferido)
    .word D00_9221                              ; A794  21 92       (inferido)
    .byte $00,$00,$40,$02,$D3,$00,$00           ; A796
    .word D01_A79F                              ; A79D  9F A7       (inferido)

; -- quadro (14 bytes)   [dur=9 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A79F:
    .byte $09                                   ; A79F
    .word D00_830D                              ; A7A0  0D 83       (inferido)
    .word D00_922A                              ; A7A2  2A 92       (inferido)
    .byte $00,$00,$40,$02,$00,$00,$00,$00,$00   ; A7A4

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$32 | acertos=0]
D01_A7AD:
    .byte $FF,$00,$00                           ; A7AD
    .word D01_A3C0                              ; A7B0  C0 A3       (inferido)
    .byte $32,$00                               ; A7B2

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A7B4:
    .byte $01                                   ; A7B4
    .word D00_82ED                              ; A7B5  ED 82       (inferido)
    .word D00_9221                              ; A7B7  21 92       (inferido)
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A7B9
    .word D01_A7C2                              ; A7C0  C2 A7       (inferido)

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A7B4]
D01_A7C2:
    .byte $01                                   ; A7C2
    .word D00_82ED                              ; A7C3  ED 82       (inferido)
    .word D00_9221                              ; A7C5  21 92       (inferido)
    .byte $00,$00,$20,$04,$20,$00,$07           ; A7C7
    .word D01_A7D2                              ; A7CE  D2 A7       (inferido)
    .word D01_A7B4                              ; A7D0  B4 A7       (inferido)

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D01_A7D2:
    .byte $05                                   ; A7D2
    .word D00_82ED                              ; A7D3  ED 82       (inferido)
    .word D00_9221                              ; A7D5  21 92       (inferido)
    .byte $00,$00,$40,$02,$C9,$00,$00           ; A7D7
    .word D01_A7E0                              ; A7DE  E0 A7       (inferido)

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A7E0:
    .byte $06                                   ; A7E0
    .word D00_830D                              ; A7E1  0D 83       (inferido)
    .word D00_922A                              ; A7E3  2A 92       (inferido)
    .byte $00,$00,$40,$02,$00,$00,$00           ; A7E5
    .word D01_A7EE                              ; A7EC  EE A7       (inferido)

; -- quadro (14 bytes)   [dur=9 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A7EE:
    .byte $09                                   ; A7EE
    .word D00_8330                              ; A7EF  30 83       (inferido)
    .word D00_9233                              ; A7F1  33 92       (inferido)
    .byte $00,$00,$40,$02,$00,$00,$00           ; A7F3
    .word D01_A7FC                              ; A7FA  FC A7       (inferido)

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D01_A7FC:
    .byte $03                                   ; A7FC
    .word D00_8046                              ; A7FD  46 80       (inferido)
    .word D00_91D3                              ; A7FF  D3 91       (inferido)
    .byte $00,$00,$40,$02,$00,$00,$00,$00,$00   ; A801

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$31 | acertos=0]
D01_A80A:
    .byte $FF,$00,$00                           ; A80A
    .word D01_A12E                              ; A80D  2E A1
    .byte $31,$00                               ; A80F

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A811:
    .byte $01                                   ; A811
    .word D00_8350                              ; A812  50 83
    .word D00_923C                              ; A814  3C 92
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A816
    .word D01_A81F                              ; A81D  1F A8

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A811]
D01_A81F:
    .byte $01                                   ; A81F
    .word D00_8350                              ; A820  50 83
    .word D00_923C                              ; A822  3C 92
    .byte $00,$00,$20,$04,$20,$00,$07           ; A824
    .word D01_A82F                              ; A82B  2F A8
    .word D01_A811                              ; A82D  11 A8

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$00 mov=$02 vx=-55 vy=0 rep=0]
D01_A82F:
    .byte $03                                   ; A82F
    .word D00_8350                              ; A830  50 83
    .word D00_923C                              ; A832  3C 92
    .byte $00,$00,$00,$02,$C9,$00,$00           ; A834
    .word D01_A83D                              ; A83B  3D A8

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_A83D:
    .byte $04                                   ; A83D
    .word D00_8375                              ; A83E  75 83
    .word D00_9242                              ; A840  42 92
    .byte $00,$00,$00,$02,$00,$00,$00           ; A842
    .word D01_A84B                              ; A849  4B A8

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_A84B:
    .byte $04                                   ; A84B
    .word D00_839C                              ; A84C  9C 83
    .word D00_924B                              ; A84E  4B 92
    .byte $00,$00,$00,$02,$00,$00,$00           ; A850
    .word D01_A859                              ; A857  59 A8

; -- quadro (14 bytes)   [dur=9 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_A859:
    .byte $09                                   ; A859
    .word D00_80B6                              ; A85A  B6 80
    .word D00_91E5                              ; A85C  E5 91
    .byte $00,$00,$00,$02,$00,$00,$00,$00,$00   ; A85E

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$32 | acertos=0]
D01_A867:
    .byte $FF,$00,$00                           ; A867
    .word D01_A3C0                              ; A86A  C0 A3
    .byte $32,$00                               ; A86C

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D01_A86E:
    .byte $01                                   ; A86E
    .word D00_82ED                              ; A86F  ED 82
    .word D00_9221                              ; A871  21 92
    .byte $00,$00,$20,$04,$E0,$00,$00           ; A873
    .word D01_A87C                              ; A87A  7C A8

; -- quadro (16 bytes)   [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7 br=$A86E]
D01_A87C:
    .byte $01                                   ; A87C
    .word D00_82ED                              ; A87D  ED 82
    .word D00_9221                              ; A87F  21 92
    .byte $00,$00,$20,$04,$20,$00,$07           ; A881
    .word D01_A88C                              ; A888  8C A8
    .word D01_A86E                              ; A88A  6E A8

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=-55 vy=0 rep=0]
D01_A88C:
    .byte $05                                   ; A88C
    .word D00_82ED                              ; A88D  ED 82
    .word D00_9221                              ; A88F  21 92
    .byte $00,$00,$00,$02,$C9,$00,$00           ; A891
    .word D01_A89A                              ; A898  9A A8

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_A89A:
    .byte $06                                   ; A89A
    .word D00_830D                              ; A89B  0D 83
    .word D00_922A                              ; A89D  2A 92
    .byte $00,$00,$00,$02,$00,$00,$00           ; A89F
    .word D01_A8A8                              ; A8A6  A8 A8

; -- quadro (14 bytes)   [dur=9 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_A8A8:
    .byte $09                                   ; A8A8
    .word D00_8330                              ; A8A9  30 83
    .word D00_9233                              ; A8AB  33 92
    .byte $00,$00,$00,$02,$00,$00,$00           ; A8AD
    .word D01_A8B6                              ; A8B4  B6 A8

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_A8B6:
    .byte $03                                   ; A8B6
    .word D00_8046                              ; A8B7  46 80
    .word D00_91D3                              ; A8B9  D3 91
    .byte $00,$00,$00,$02,$00,$00,$00,$00,$00   ; A8BB

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$34 | acertos=0]
D01_A8C4:
    .byte $FF,$00,$00                           ; A8C4
    .word D01_A926                              ; A8C7  26 A9
    .byte $34,$00                               ; A8C9

; -- quadro (14 bytes)   [dur=14 efe=$00/$00 fl=$10 mov=$01 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $0E                                   ; A8CB
    .word D00_82C5                              ; A8CC  C5 82
    .byte $00,$00,$00,$00,$10,$01,$00,$00,$00   ; A8CE
    .word D01_A8D9                              ; A8D7  D9 A8

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$00 mov=$02 vx=-20 vy=-48 rep=0]
D01_A8D9:
    .byte $07                                   ; A8D9
    .word D00_82C5                              ; A8DA  C5 82
    .byte $00,$00,$00,$00,$00,$02,$EC,$D0,$00   ; A8DC
    .word D01_A8E7                              ; A8E5  E7 A8

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_A8E7:
    .byte $64                                   ; A8E7
    .word D00_80E3                              ; A8E8  E3 80
    .byte $00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00; A8EA

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$34 | acertos=0]
D01_A8F5:
    .byte $FF,$00,$00                           ; A8F5
    .word D01_A926                              ; A8F8  26 A9
    .byte $34,$00                               ; A8FA

; -- quadro (14 bytes)   [dur=14 efe=$00/$00 fl=$10 mov=$01 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $0E                                   ; A8FC
    .word D00_82C5                              ; A8FD  C5 82
    .byte $00,$00,$00,$00,$10,$01,$00,$00,$00   ; A8FF
    .word D01_A90A                              ; A908  0A A9

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$40 mov=$02 vx=-20 vy=-48 rep=0]
D01_A90A:
    .byte $07                                   ; A90A
    .word D00_82C5                              ; A90B  C5 82
    .byte $00,$00,$00,$00,$40,$02,$EC,$D0,$00   ; A90D
    .word D01_A918                              ; A916  18 A9

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_A918:
    .byte $64                                   ; A918
    .word D00_80E3                              ; A919  E3 80
    .byte $00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00; A91B

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$34 | acertos=0]
D01_A926:
    .byte $FF,$00,$00                           ; A926
    .word D01_A949                              ; A929  49 A9
    .byte $34,$00                               ; A92B

; -- quadro (14 bytes)   [dur=4 efe=$09/$20 fl=$00 mov=$02 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $04                                   ; A92D
    .word D00_8106                              ; A92E  06 81
    .byte $00,$00,$09,$20,$00,$02,$00,$00,$00   ; A930
    .word D01_A93B                              ; A939  3B A9

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=-24 rep=0]
D01_A93B:
    .byte $64                                   ; A93B
    .word D00_80E3                              ; A93C  E3 80
    .byte $00,$00,$00,$00,$00,$02,$00,$E8,$00,$00,$00; A93E

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$30 | acertos=0]
D01_A949:
    .byte $FF                                   ; A949
    .word D01_A0E1                              ; A94A  E1 A0
    .word D01_A9A4                              ; A94C  A4 A9
    .byte $30,$00                               ; A94E

; -- quadro (14 bytes)   [dur=11 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $0B                                   ; A950
    .word D00_8106                              ; A951  06 81
    .byte $00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00; A953

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$30 | acertos=0]
D01_A95E:
    .byte $FF,$00,$00                           ; A95E
    .word D01_A949                              ; A961  49 A9
    .byte $30,$00                               ; A963

; -- quadro (14 bytes)   [dur=1 efe=$09/$20 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $01                                   ; A965
    .word D00_8106                              ; A966  06 81
    .byte $00,$00,$09,$20,$00,$04,$00,$00,$00,$00,$00; A968

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$31 | acertos=0]
D01_A973:
    .byte $FF,$00,$00                           ; A973
    .word D01_A95E                              ; A976  5E A9
    .byte $31,$00                               ; A978

; -- quadro (14 bytes)   [dur=16 efe=$00/$00 fl=$10 mov=$01 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $10                                   ; A97A
    .word D00_8BF3                              ; A97B  F3 8B
    .byte $00,$00,$00,$00,$10,$01,$00,$00,$00   ; A97D
    .word D01_A988                              ; A986  88 A9

; -- quadro (14 bytes)   [dur=7 efe=$00/$00 fl=$40 mov=$02 vx=-23 vy=-56 rep=0]
D01_A988:
    .byte $07                                   ; A988
    .word D00_8BF3                              ; A989  F3 8B
    .byte $00,$00,$00,$00,$40,$02,$E9,$C8,$00   ; A98B
    .word D01_A996                              ; A994  96 A9

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_A996:
    .byte $64                                   ; A996
    .word D00_8C1B                              ; A997  1B 8C
    .byte $00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00; A999

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$49 | acertos=0]
D01_A9A4:
    .byte $FF                                   ; A9A4
    .word D01_A9E3                              ; A9A5  E3 A9
    .word D01_A12E                              ; A9A7  2E A1       (inferido)
    .byte $49,$00                               ; A9A9

; -- quadro (14 bytes)   [dur=8 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $08                                   ; A9AB
    .word D00_8181                              ; A9AC  81 81
    .byte $00,$00,$00,$00,$00,$04,$00,$00,$00   ; A9AE
    .word D01_A9B9                              ; A9B7  B9 A9

; -- quadro (14 bytes)   [dur=11 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_A9B9:
    .byte $0B                                   ; A9B9
    .word D00_81A9                              ; A9BA  A9 81
    .byte $00,$00,$00,$00,$00,$04,$00,$00,$00   ; A9BC
    .word D01_A9C7                              ; A9C5  C7 A9

; -- quadro (14 bytes)   [dur=8 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_A9C7:
    .byte $08                                   ; A9C7
    .word D00_882C                              ; A9C8  2C 88
    .byte $00,$00,$00,$00,$00,$04,$00,$00,$00   ; A9CA
    .word D01_A9D5                              ; A9D3  D5 A9

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$07 mov=$04 vx=0 vy=0 rep=0]
D01_A9D5:
    .byte $01                                   ; A9D5
    .word D00_8A20                              ; A9D6  20 8A
    .byte $00,$00,$00,$00,$07,$04,$00,$00,$00,$00,$00; A9D8

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$51 | acertos=0]
D01_A9E3:
    .byte $FF,$00,$00                           ; A9E3
    .word D01_A12E                              ; A9E6  2E A1       (inferido)
    .byte $51,$00                               ; A9E8

; -- quadro (14 bytes)   [dur=26 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_A9EA:
    .byte $1A                                   ; A9EA
    .word D00_8089                              ; A9EB  89 80
    .word D00_93E0                              ; A9ED  E0 93
    .byte $00,$00,$00,$04,$00,$00,$00           ; A9EF
    .word D01_A9F8                              ; A9F6  F8 A9

; -- quadro (14 bytes)   [dur=19 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_A9F8:
    .byte $13                                   ; A9F8
    .word D00_80B6                              ; A9F9  B6 80
    .word D00_93E0                              ; A9FB  E0 93
    .byte $00,$00,$00,$04,$00,$00,$00           ; A9FD
    .word D01_A9EA                              ; AA04  EA A9

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$34 | acertos=0]
D01_AA06:
    .byte $FF,$00,$00                           ; AA06
    .word D01_AA6F                              ; AA09  6F AA
    .byte $34,$00                               ; AA0B

; -- quadro (14 bytes)   [dur=15 efe=$00/$00 fl=$10 mov=$01 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $0F                                   ; AA0D
    .word D00_80E3                              ; AA0E  E3 80
    .byte $00,$00,$00,$00,$10,$01,$00,$00,$00   ; AA10
    .word D01_AA1B                              ; AA19  1B AA

; -- quadro (14 bytes)   [dur=14 efe=$00/$00 fl=$40 mov=$02 vx=-20 vy=-64 rep=0]
D01_AA1B:
    .byte $0E                                   ; AA1B
    .word D00_80E3                              ; AA1C  E3 80
    .byte $00,$00,$00,$00,$40,$02,$EC,$C0,$00   ; AA1E
    .word D01_AA29                              ; AA27  29 AA

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AA29:
    .byte $02                                   ; AA29
    .word D00_8885                              ; AA2A  85 88
    .byte $00,$00,$00,$00,$00,$02,$00,$00,$00   ; AA2C
    .word D01_AA37                              ; AA35  37 AA

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AA37:
    .byte $02                                   ; AA37
    .word D00_8868                              ; AA38  68 88
    .byte $00,$00,$00,$00,$00,$02,$00,$00,$00   ; AA3A
    .word D01_AA45                              ; AA43  45 AA

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AA45:
    .byte $02                                   ; AA45
    .word D00_8849                              ; AA46  49 88
    .byte $00,$00,$00,$00,$00,$02,$00,$00,$00   ; AA48
    .word D01_AA53                              ; AA51  53 AA

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AA53:
    .byte $02                                   ; AA53
    .word D00_882C                              ; AA54  2C 88
    .byte $00,$00,$00,$00,$00,$02,$00,$00,$00   ; AA56
    .word D01_AA61                              ; AA5F  61 AA

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AA61:
    .byte $64                                   ; AA61
    .word D00_8809                              ; AA62  09 88
    .byte $00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00; AA64

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$4C | acertos=0]
D01_AA6F:
    .byte $FF,$00,$00                           ; AA6F
    .word D01_A12E                              ; AA72  2E A1       (inferido)
    .byte $4C,$00                               ; AA74

; -- quadro (14 bytes)   [dur=1 efe=$00/$20 fl=$17 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $01                                   ; AA76
    .word D00_8D81                              ; AA77  81 8D
    .byte $00,$00,$00,$20,$17,$04,$00,$00,$00   ; AA79
    .word D01_AA84                              ; AA82  84 AA       (inferido)

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$17 mov=$04 vx=0 vy=0 rep=0]
D01_AA84:
    .byte $03                                   ; AA84
    .word D00_8D81                              ; AA85  81 8D       (inferido)
    .word D00_9443                              ; AA87  43 94       (inferido)
    .byte $00,$00,$17,$04,$00,$00,$00,$00,$00   ; AA89

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$39 | acertos=0]
D01_AA92:
    .byte $FF,$00,$00                           ; AA92
    .word D01_A926                              ; AA95  26 A9
    .byte $39,$00                               ; AA97

; -- quadro (14 bytes)   [dur=15 efe=$00/$00 fl=$50 mov=$00 vx=-16 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $0F                                   ; AA99
    .word D00_8350                              ; AA9A  50 83
    .byte $00,$00,$00,$00,$50,$00,$F0,$00,$00   ; AA9C
    .word D01_AAA7                              ; AAA5  A7 AA

; -- quadro (14 bytes)   [dur=10 efe=$00/$00 fl=$40 mov=$01 vx=-3 vy=-16 rep=0]
D01_AAA7:
    .byte $0A                                   ; AAA7
    .word D00_827C                              ; AAA8  7C 82
    .byte $00,$00,$00,$00,$40,$01,$FD,$F0,$00   ; AAAA
    .word D01_AAB5                              ; AAB3  B5 AA

; -- quadro (14 bytes)   [dur=10 efe=$00/$00 fl=$40 mov=$01 vx=20 vy=-12 rep=0]
D01_AAB5:
    .byte $0A                                   ; AAB5
    .word D00_8121                              ; AAB6  21 81
    .byte $00,$00,$00,$00,$40,$01,$14,$F4,$00   ; AAB8
    .word D01_AAC3                              ; AAC1  C3 AA

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$40 mov=$01 vx=26 vy=8 rep=0]
D01_AAC3:
    .byte $05                                   ; AAC3
    .word D00_83C5                              ; AAC4  C5 83
    .byte $00,$00,$00,$00,$40,$01,$1A,$08,$00   ; AAC6
    .word D01_AAD1                              ; AACF  D1 AA

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=39 vy=-32 rep=0]
D01_AAD1:
    .byte $64                                   ; AAD1
    .word D00_80E3                              ; AAD2  E3 80
    .byte $00,$00,$00,$00,$00,$02,$27,$E0,$00,$00,$00; AAD4

; -- ESTADO (cabecalho, 7 bytes)   [cond=$09 CondPodeAgarrar | classe=$A1 | acertos=1]
D01_AADF:
    .byte $09                                   ; AADF
    .word D01_ACC9                              ; AAE0  C9 AC
    .word D01_A12E                              ; AAE2  2E A1
    .byte $A1,$01                               ; AAE4

; -- quadro (14 bytes)   [dur=1 efe=$16/$0C fl=$00 mov=$01 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $01                                   ; AAE6
    .word D00_8D81                              ; AAE7  81 8D
    .word D00_943D                              ; AAE9  3D 94
    .byte $16,$0C,$00,$01,$00,$00,$00           ; AAEB
    .word D01_AAF4                              ; AAF2  F4 AA

; -- quadro (14 bytes)   [dur=15 efe=$00/$00 fl=$00 mov=$01 vx=0 vy=0 rep=0]
D01_AAF4:
    .byte $0F                                   ; AAF4
    .word D00_8CCF                              ; AAF5  CF 8C
    .byte $00,$00,$00,$00,$00,$01,$00,$00,$00   ; AAF7
    .word D01_AB02                              ; AB00  02 AB

; -- quadro (14 bytes)   [dur=10 efe=$00/$00 fl=$00 mov=$01 vx=0 vy=0 rep=0]
D01_AB02:
    .byte $0A                                   ; AB02
    .word D00_8D01                              ; AB03  01 8D
    .byte $00,$00,$00,$00,$00,$01,$00,$00,$00   ; AB05
    .word D01_AB10                              ; AB0E  10 AB

; -- quadro (14 bytes)   [dur=10 efe=$00/$00 fl=$00 mov=$01 vx=0 vy=0 rep=0]
D01_AB10:
    .byte $0A                                   ; AB10
    .word D00_8D34                              ; AB11  34 8D
    .byte $00,$00,$00,$00,$00,$01,$00,$00,$00   ; AB13
    .word D01_AB1E                              ; AB1C  1E AB

; -- quadro (14 bytes)   [dur=36 efe=$00/$00 fl=$00 mov=$01 vx=0 vy=0 rep=0]
D01_AB1E:
    .byte $24                                   ; AB1E
    .word D00_8D63                              ; AB1F  63 8D
    .byte $00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00; AB21

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$71 | acertos=1]
D01_AB2C:
    .byte $FF,$00,$00                           ; AB2C
    .word D01_A12E                              ; AB2F  2E A1
    .byte $71,$01                               ; AB31

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; AB33
    .word D00_89C5                              ; AB34  C5 89
    .word D00_93CB                              ; AB36  CB 93
    .byte $00,$00,$10,$04,$00,$00,$00           ; AB38
    .word D01_AB41                              ; AB3F  41 AB

; -- quadro (14 bytes)   [dur=4 efe=$03/$C0 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D01_AB41:
    .byte $04                                   ; AB41
    .word D00_89F3                              ; AB42  F3 89
    .word D00_93D4                              ; AB44  D4 93
    .byte $03,$C0,$03,$04,$00,$00,$00           ; AB46
    .word D01_AB4F                              ; AB4D  4F AB

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D01_AB4F:
    .byte $04                                   ; AB4F
    .word D00_89C5                              ; AB50  C5 89
    .word D00_93CB                              ; AB52  CB 93
    .byte $00,$00,$03,$04,$00,$00,$00,$00,$00   ; AB54

; -- ESTADO (cabecalho, 7 bytes)   [cond=$02 CondOponentePerto | classe=$71 | acertos=1]
D01_AB5D:
    .byte $02                                   ; AB5D
    .word D01_AB2C                              ; AB5E  2C AB
    .word D01_A12E                              ; AB60  2E A1
    .byte $71,$01                               ; AB62

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; AB64
    .word D00_89C5                              ; AB65  C5 89
    .word D00_93CB                              ; AB67  CB 93
    .byte $00,$00,$10,$04,$00,$00,$00           ; AB69
    .word D01_AB72                              ; AB70  72 AB

; -- quadro (14 bytes)   [dur=4 efe=$03/$C0 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D01_AB72:
    .byte $04                                   ; AB72
    .word D00_8959                              ; AB73  59 89
    .word D00_93B3                              ; AB75  B3 93
    .byte $03,$C0,$03,$04,$00,$00,$00           ; AB77
    .word D01_AB80                              ; AB7E  80 AB

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D01_AB80:
    .byte $04                                   ; AB80
    .word D00_89C5                              ; AB81  C5 89
    .word D00_93CB                              ; AB83  CB 93
    .byte $00,$00,$03,$04,$00,$00,$00,$00,$00   ; AB85

; -- ESTADO (cabecalho, 7 bytes)   [cond=$07 CondInputBaixo | classe=$72 | acertos=1]
D01_AB8E:
    .byte $07                                   ; AB8E
    .word D01_AB5D                              ; AB8F  5D AB
    .word D01_A3C0                              ; AB91  C0 A3
    .byte $72,$01                               ; AB93

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; AB95
    .word D00_8987                              ; AB96  87 89
    .word D00_93BC                              ; AB98  BC 93
    .byte $00,$00,$10,$04,$00,$00,$00           ; AB9A
    .word D01_ABA3                              ; ABA1  A3 AB

; -- quadro (14 bytes)   [dur=4 efe=$03/$C3 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D01_ABA3:
    .byte $04                                   ; ABA3
    .word D00_89A5                              ; ABA4  A5 89
    .word D00_93C2                              ; ABA6  C2 93
    .byte $03,$C3,$03,$04,$00,$00,$00           ; ABA8
    .word D01_ABB1                              ; ABAF  B1 AB

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D01_ABB1:
    .byte $04                                   ; ABB1
    .word D00_8987                              ; ABB2  87 89
    .word D00_93BC                              ; ABB4  BC 93
    .byte $00,$00,$03,$04,$00,$00,$00,$00,$00   ; ABB6

; -- ESTADO (cabecalho, 7 bytes)   [cond=$05 CondNoAr | classe=$74 | acertos=1]
D01_ABBF:
    .byte $05                                   ; ABBF
    .word D01_AB8E                              ; ABC0  8E AB
    .word D01_A35E                              ; ABC2  5E A3
    .byte $74,$01                               ; ABC4

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $02                                   ; ABC6
    .word D00_876A                              ; ABC7  6A 87
    .word D00_933E                              ; ABC9  3E 93
    .byte $00,$00,$00,$02,$00,$00,$00           ; ABCB
    .word D01_ABD4                              ; ABD2  D4 AB

; -- quadro (14 bytes)   [dur=100 efe=$08/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_ABD4:
    .byte $64                                   ; ABD4
    .word D00_878D                              ; ABD5  8D 87
    .word D00_9344                              ; ABD7  44 93
    .byte $08,$43,$00,$02,$00,$00,$00,$00,$00   ; ABD9

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$81 | acertos=1]
D01_ABE2:
    .byte $FF,$00,$00                           ; ABE2
    .word D01_A12E                              ; ABE5  2E A1
    .byte $81,$01                               ; ABE7

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $04                                   ; ABE9
    .word D00_89C5                              ; ABEA  C5 89
    .word D00_93CB                              ; ABEC  CB 93
    .byte $00,$00,$00,$04,$00,$00,$00           ; ABEE
    .word D01_ABF7                              ; ABF5  F7 AB

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_ABF7:
    .byte $02                                   ; ABF7
    .word D00_87B8                              ; ABF8  B8 87
    .word D00_934D                              ; ABFA  4D 93
    .byte $00,$00,$00,$04,$00,$00,$00           ; ABFC
    .word D01_AC05                              ; AC03  05 AC

; -- quadro (14 bytes)   [dur=6 efe=$12/$C2 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AC05:
    .byte $06                                   ; AC05
    .word D00_87E2                              ; AC06  E2 87
    .word D00_9356                              ; AC08  56 93
    .byte $12,$C2,$00,$04,$00,$00,$00           ; AC0A
    .word D01_AC13                              ; AC11  13 AC

; -- quadro (14 bytes)   [dur=10 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AC13:
    .byte $0A                                   ; AC13
    .word D00_87B8                              ; AC14  B8 87
    .word D00_934D                              ; AC16  4D 93
    .byte $00,$00,$00,$04,$00,$00,$00           ; AC18
    .word D01_AC21                              ; AC1F  21 AC

; -- quadro (14 bytes)   [dur=12 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AC21:
    .byte $0C                                   ; AC21
    .word D00_89C5                              ; AC22  C5 89
    .word D00_93CB                              ; AC24  CB 93
    .byte $00,$00,$00,$04,$00,$00,$00,$00,$00   ; AC26

; -- ESTADO (cabecalho, 7 bytes)   [cond=$02 CondOponentePerto | classe=$81 | acertos=1]
D01_AC2F:
    .byte $02                                   ; AC2F
    .word D01_ABE2                              ; AC30  E2 AB
    .word D01_A12E                              ; AC32  2E A1
    .byte $81,$01                               ; AC34

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $04                                   ; AC36
    .word D00_867A                              ; AC37  7A 86
    .word D00_92F6                              ; AC39  F6 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; AC3B
    .word D01_AC44                              ; AC42  44 AC

; -- quadro (14 bytes)   [dur=2 efe=$12/$C5 fl=$01 mov=$04 vx=0 vy=0 rep=0]
D01_AC44:
    .byte $02                                   ; AC44
    .word D00_86A1                              ; AC45  A1 86
    .word D00_92FF                              ; AC47  FF 92
    .byte $12,$C5,$01,$04,$00,$00,$00           ; AC49
    .word D01_AC52                              ; AC50  52 AC

; -- quadro (14 bytes)   [dur=6 efe=$12/$C5 fl=$01 mov=$04 vx=0 vy=0 rep=0]
D01_AC52:
    .byte $06                                   ; AC52
    .word D00_86C8                              ; AC53  C8 86
    .word D00_930B                              ; AC55  0B 93
    .byte $12,$C5,$01,$04,$00,$00,$00           ; AC57
    .word D01_AC60                              ; AC5E  60 AC

; -- quadro (14 bytes)   [dur=10 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AC60:
    .byte $0A                                   ; AC60
    .word D00_86A1                              ; AC61  A1 86
    .word D00_92F6                              ; AC63  F6 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; AC65
    .word D01_AC6E                              ; AC6C  6E AC

; -- quadro (14 bytes)   [dur=12 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AC6E:
    .byte $0C                                   ; AC6E
    .word D00_89C5                              ; AC6F  C5 89
    .word D00_93CB                              ; AC71  CB 93
    .byte $00,$00,$00,$04,$00,$00,$00,$00,$00   ; AC73

; -- ESTADO (cabecalho, 7 bytes)   [cond=$07 CondInputBaixo | classe=$82 | acertos=1]
D01_AC7C:
    .byte $07                                   ; AC7C
    .word D01_AC2F                              ; AC7D  2F AC
    .word D01_A3C0                              ; AC7F  C0 A3
    .byte $82,$01                               ; AC81

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $04                                   ; AC83
    .word D00_86F3                              ; AC84  F3 86
    .word D00_9320                              ; AC86  20 93
    .byte $00,$00,$00,$04,$00,$00,$00           ; AC88
    .word D01_AC91                              ; AC8F  91 AC

; -- quadro (14 bytes)   [dur=3 efe=$12/$C5 fl=$01 mov=$04 vx=0 vy=0 rep=0]
D01_AC91:
    .byte $03                                   ; AC91
    .word D00_8713                              ; AC92  13 87
    .word D00_9326                              ; AC94  26 93
    .byte $12,$C5,$01,$04,$00,$00,$00           ; AC96
    .word D01_AC9F                              ; AC9D  9F AC

; -- quadro (14 bytes)   [dur=8 efe=$12/$C5 fl=$01 mov=$04 vx=0 vy=0 rep=0]
D01_AC9F:
    .byte $08                                   ; AC9F
    .word D00_873D                              ; ACA0  3D 87
    .word D00_9332                              ; ACA2  32 93
    .byte $12,$C5,$01,$04,$00,$00,$00           ; ACA4
    .word D01_ACAD                              ; ACAB  AD AC

; -- quadro (14 bytes)   [dur=24 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_ACAD:
    .byte $18                                   ; ACAD
    .word D00_86F3                              ; ACAE  F3 86
    .word D00_9320                              ; ACB0  20 93
    .byte $00,$00,$00,$04,$00,$00,$00           ; ACB2
    .word D01_ACBB                              ; ACB9  BB AC

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_ACBB:
    .byte $03                                   ; ACBB
    .word D00_8046                              ; ACBC  46 80
    .word D00_91D3                              ; ACBE  D3 91
    .byte $00,$00,$00,$04,$00,$00,$00,$00,$00   ; ACC0

; -- ESTADO (cabecalho, 7 bytes)   [cond=$05 CondNoAr | classe=$84 | acertos=1]
D01_ACC9:
    .byte $05                                   ; ACC9
    .word D01_AC7C                              ; ACCA  7C AC
    .word D01_A35E                              ; ACCC  5E A3       (inferido)
    .byte $84,$01                               ; ACCE

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $02                                   ; ACD0
    .word D00_876A                              ; ACD1  6A 87       (inferido)
    .word D00_933E                              ; ACD3  3E 93       (inferido)
    .byte $00,$00,$00,$02,$00,$00,$00           ; ACD5
    .word D01_ACDE                              ; ACDC  DE AC       (inferido)

; -- quadro (14 bytes)   [dur=8 efe=$11/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_ACDE:
    .byte $08                                   ; ACDE
    .word D00_878D                              ; ACDF  8D 87       (inferido)
    .word D00_9344                              ; ACE1  44 93       (inferido)
    .byte $11,$43,$00,$02,$00,$00,$00           ; ACE3
    .word D01_ACEC                              ; ACEA  EC AC       (inferido)

; -- quadro (14 bytes)   [dur=12 efe=$00/$01 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_ACEC:
    .byte $0C                                   ; ACEC
    .word D00_876A                              ; ACED  6A 87       (inferido)
    .word D00_933E                              ; ACEF  3E 93       (inferido)
    .byte $00,$01,$00,$02,$00,$00,$00           ; ACF1
    .word D01_ACFA                              ; ACF8  FA AC       (inferido)

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_ACFA:
    .byte $64                                   ; ACFA
    .word D00_8809                              ; ACFB  09 88       (inferido)
    .word D00_9362                              ; ACFD  62 93       (inferido)
    .byte $00,$00,$00,$02,$00,$00,$00,$00,$00   ; ACFF

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$89 | acertos=1]
D01_AD08:
    .byte $FF,$00,$00                           ; AD08
    .word D01_A12E                              ; AD0B  2E A1
    .byte $89,$01                               ; AD0D

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $02                                   ; AD0F
    .word D00_89C5                              ; AD10  C5 89
    .word D00_93CB                              ; AD12  CB 93
    .byte $00,$00,$10,$04,$00,$00,$00           ; AD14
    .word D01_AD1D                              ; AD1B  1D AD

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AD1D:
    .byte $03                                   ; AD1D
    .word D00_83EA                              ; AD1E  EA 83
    .word D00_9254                              ; AD20  54 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; AD22
    .word D01_AD2B                              ; AD29  2B AD

; -- quadro (14 bytes)   [dur=6 efe=$08/$83 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AD2B:
    .byte $06                                   ; AD2B
    .word D00_8934                              ; AD2C  34 89
    .word D00_93AA                              ; AD2E  AA 93
    .byte $08,$83,$00,$04,$00,$00,$00           ; AD30
    .word D01_AD39                              ; AD37  39 AD

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AD39:
    .byte $03                                   ; AD39
    .word D00_83EA                              ; AD3A  EA 83
    .word D00_9254                              ; AD3C  54 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; AD3E
    .word D01_AD47                              ; AD45  47 AD

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AD47:
    .byte $01                                   ; AD47
    .word D00_89C5                              ; AD48  C5 89
    .word D00_93CB                              ; AD4A  CB 93
    .byte $00,$00,$00,$04,$00,$00,$00,$00,$00   ; AD4C

; -- ESTADO (cabecalho, 7 bytes)   [cond=$07 CondInputBaixo | classe=$8A | acertos=1]
D01_AD55:
    .byte $07                                   ; AD55
    .word D01_AD08                              ; AD56  08 AD
    .word D01_A3C0                              ; AD58  C0 A3
    .byte $8A,$01                               ; AD5A

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; AD5C
    .word D00_88C9                              ; AD5D  C9 88
    .word D00_9392                              ; AD5F  92 93
    .byte $00,$00,$10,$04,$00,$00,$00           ; AD61
    .word D01_AD6A                              ; AD68  6A AD

; -- quadro (14 bytes)   [dur=4 efe=$03/$83 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D01_AD6A:
    .byte $04                                   ; AD6A
    .word D00_88ED                              ; AD6B  ED 88
    .word D00_9398                              ; AD6D  98 93
    .byte $03,$83,$03,$04,$00,$00,$00           ; AD6F
    .word D01_AD78                              ; AD76  78 AD

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D01_AD78:
    .byte $04                                   ; AD78
    .word D00_88C9                              ; AD79  C9 88
    .word D00_9392                              ; AD7B  92 93
    .byte $00,$00,$03,$04,$00,$00,$00,$00,$00   ; AD7D

; -- ESTADO (cabecalho, 7 bytes)   [cond=$05 CondNoAr | classe=$8C | acertos=1]
D01_AD86:
    .byte $05                                   ; AD86
    .word D01_AD55                              ; AD87  55 AD
    .word D01_A35E                              ; AD89  5E A3
    .byte $8C,$01                               ; AD8B

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $05                                   ; AD8D
    .word D00_882C                              ; AD8E  2C 88
    .word D00_9368                              ; AD90  68 93
    .byte $00,$00,$00,$02,$00,$00,$00           ; AD92
    .word D01_AD9B                              ; AD99  9B AD

; -- quadro (14 bytes)   [dur=100 efe=$08/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AD9B:
    .byte $64                                   ; AD9B
    .word D00_8918                              ; AD9C  18 89
    .word D00_93A1                              ; AD9E  A1 93
    .byte $08,$43,$00,$02,$00,$00,$00,$00,$00   ; ADA0

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$99 | acertos=1]
D01_ADA9:
    .byte $FF,$00,$00                           ; ADA9
    .word D01_A12E                              ; ADAC  2E A1
    .byte $99,$01                               ; ADAE

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; ADB0
    .word D00_85B2                              ; ADB1  B2 85
    .word D00_92C3                              ; ADB3  C3 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; ADB5
    .word D01_ADBE                              ; ADBC  BE AD

; -- quadro (14 bytes)   [dur=4 efe=$13/$C2 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_ADBE:
    .byte $04                                   ; ADBE
    .word D00_85D3                              ; ADBF  D3 85
    .word D00_92CC                              ; ADC1  CC 92
    .byte $13,$C2,$00,$04,$00,$00,$00           ; ADC3
    .word D01_ADCC                              ; ADCA  CC AD

; -- quadro (14 bytes)   [dur=8 efe=$13/$C2 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_ADCC:
    .byte $08                                   ; ADCC
    .word D00_8604                              ; ADCD  04 86
    .word D00_92D8                              ; ADCF  D8 92
    .byte $13,$C2,$00,$04,$00,$00,$00           ; ADD1
    .word D01_ADDA                              ; ADD8  DA AD

; -- quadro (14 bytes)   [dur=10 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_ADDA:
    .byte $0A                                   ; ADDA
    .word D00_8632                              ; ADDB  32 86
    .word D00_92E4                              ; ADDD  E4 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; ADDF
    .word D01_ADE8                              ; ADE6  E8 AD

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_ADE8:
    .byte $06                                   ; ADE8
    .word D00_8656                              ; ADE9  56 86
    .word D00_92ED                              ; ADEB  ED 92
    .byte $00,$00,$00,$04,$00,$00,$00,$00,$00   ; ADED

; -- ESTADO (cabecalho, 7 bytes)   [cond=$02 CondOponentePerto | classe=$99 | acertos=2]
D01_ADF6:
    .byte $02                                   ; ADF6
    .word D01_ADA9                              ; ADF7  A9 AD
    .word D01_A12E                              ; ADF9  2E A1
    .byte $99,$02                               ; ADFB

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $03                                   ; ADFD
    .word D00_89C5                              ; ADFE  C5 89
    .word D00_93CB                              ; AE00  CB 93
    .byte $00,$00,$00,$04,$00,$00,$00           ; AE02
    .word D01_AE0B                              ; AE09  0B AE

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AE0B:
    .byte $04                                   ; AE0B
    .word D00_83EA                              ; AE0C  EA 83
    .word D00_9254                              ; AE0E  54 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; AE10
    .word D01_AE19                              ; AE17  19 AE

; -- quadro (14 bytes)   [dur=8 efe=$13/$C2 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AE19:
    .byte $08                                   ; AE19
    .word D00_8437                              ; AE1A  37 84
    .word D00_9266                              ; AE1C  66 92
    .byte $13,$C2,$00,$04,$00,$00,$00           ; AE1E
    .word D01_AE27                              ; AE25  27 AE

; -- quadro (14 bytes)   [dur=4 efe=$03/$C5 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AE27:
    .byte $04                                   ; AE27
    .word D00_840D                              ; AE28  0D 84
    .word D00_925A                              ; AE2A  5A 92
    .byte $03,$C5,$00,$04,$00,$00,$00           ; AE2C
    .word D01_AE35                              ; AE33  35 AE

; -- quadro (14 bytes)   [dur=10 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AE35:
    .byte $0A                                   ; AE35
    .word D00_83EA                              ; AE36  EA 83
    .word D00_9254                              ; AE38  54 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; AE3A
    .word D01_AE43                              ; AE41  43 AE

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AE43:
    .byte $01                                   ; AE43
    .word D00_89C5                              ; AE44  C5 89
    .word D00_93CB                              ; AE46  CB 93
    .byte $00,$00,$00,$04,$00,$00,$00,$00,$00   ; AE48

; -- ESTADO (cabecalho, 7 bytes)   [cond=$07 CondInputBaixo | classe=$9A | acertos=1]
D01_AE51:
    .byte $07                                   ; AE51
    .word D01_ADF6                              ; AE52  F6 AD
    .word D01_A3C0                              ; AE54  C0 A3
    .byte $9A,$01                               ; AE56

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $04                                   ; AE58
    .word D00_8461                              ; AE59  61 84
    .word D00_9272                              ; AE5B  72 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; AE5D
    .word D01_AE66                              ; AE64  66 AE

; -- quadro (14 bytes)   [dur=6 efe=$11/$86 fl=$01 mov=$04 vx=0 vy=0 rep=0]
D01_AE66:
    .byte $06                                   ; AE66
    .word D00_847E                              ; AE67  7E 84
    .word D00_927B                              ; AE69  7B 92
    .byte $11,$86,$01,$04,$00,$00,$00           ; AE6B
    .word D01_AE74                              ; AE72  74 AE

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AE74:
    .byte $06                                   ; AE74
    .word D00_849A                              ; AE75  9A 84
    .word D00_9287                              ; AE77  87 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; AE79
    .word D01_AE82                              ; AE80  82 AE

; -- quadro (14 bytes)   [dur=8 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AE82:
    .byte $08                                   ; AE82
    .word D00_84B7                              ; AE83  B7 84
    .word D00_9290                              ; AE85  90 92
    .byte $00,$00,$00,$04,$00,$00,$00           ; AE87
    .word D01_AE90                              ; AE8E  90 AE

; -- quadro (14 bytes)   [dur=10 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AE90:
    .byte $0A                                   ; AE90
    .word D00_806A                              ; AE91  6A 80
    .word D00_91D3                              ; AE93  D3 91
    .byte $00,$00,$00,$04,$00,$00,$00           ; AE95
    .word D01_AE9E                              ; AE9C  9E AE

; -- quadro (14 bytes)   [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AE9E:
    .byte $03                                   ; AE9E
    .word D00_8046                              ; AE9F  46 80
    .word D00_91D3                              ; AEA1  D3 91
    .byte $00,$00,$00,$04,$00,$00,$00,$00,$00   ; AEA3

; -- ESTADO (cabecalho, 7 bytes)   [cond=$05 CondNoAr | classe=$9C | acertos=1]
D01_AEAC:
    .byte $05                                   ; AEAC
    .word D01_AE51                              ; AEAD  51 AE
    .word D01_A35E                              ; AEAF  5E A3
    .byte $9C,$01                               ; AEB1

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $02                                   ; AEB3
    .word D00_84D6                              ; AEB4  D6 84
    .word D00_9296                              ; AEB6  96 92
    .byte $00,$00,$00,$02,$00,$00,$00           ; AEB8
    .word D01_AEC1                              ; AEBF  C1 AE

; -- quadro (14 bytes)   [dur=4 efe=$12/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AEC1:
    .byte $04                                   ; AEC1
    .word D00_84FD                              ; AEC2  FD 84
    .word D00_929C                              ; AEC4  9C 92
    .byte $12,$43,$00,$02,$00,$00,$00           ; AEC6
    .word D01_AECF                              ; AECD  CF AE

; -- quadro (14 bytes)   [dur=6 efe=$12/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AECF:
    .byte $06                                   ; AECF
    .word D00_8524                              ; AED0  24 85
    .word D00_92A5                              ; AED2  A5 92
    .byte $12,$43,$00,$02,$00,$00,$00           ; AED4
    .word D01_AEDD                              ; AEDB  DD AE

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AEDD:
    .byte $05                                   ; AEDD
    .word D00_854B                              ; AEDE  4B 85
    .word D00_92AE                              ; AEE0  AE 92
    .byte $00,$00,$00,$02,$00,$00,$00           ; AEE2
    .word D01_AEEB                              ; AEE9  EB AE

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AEEB:
    .byte $05                                   ; AEEB
    .word D00_882C                              ; AEEC  2C 88
    .word D00_9368                              ; AEEE  68 93
    .byte $00,$00,$00,$02,$00,$00,$00           ; AEF0
    .word D01_AEF9                              ; AEF7  F9 AE

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AEF9:
    .byte $64                                   ; AEF9
    .word D00_8809                              ; AEFA  09 88
    .word D00_9362                              ; AEFC  62 93
    .byte $00,$00,$00,$02,$00,$00,$00           ; AEFE
    .word D01_AEF9                              ; AF05  F9 AE       (inferido)

; -- ESTADO (cabecalho, 7 bytes)   [cond=$06 CondNoChaoOuVelX | classe=$9C | acertos=1]
D01_AF07:
    .byte $06                                   ; AF07
    .word D01_AEAC                              ; AF08  AC AE
    .word D01_A35E                              ; AF0A  5E A3
    .byte $9C,$01                               ; AF0C

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $05                                   ; AF0E
    .word D00_8570                              ; AF0F  70 85
    .word D00_92B4                              ; AF11  B4 92
    .byte $00,$00,$00,$02,$00,$00,$00           ; AF13
    .word D01_AF1C                              ; AF1A  1C AF

; -- quadro (14 bytes)   [dur=7 efe=$11/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AF1C:
    .byte $07                                   ; AF1C
    .word D00_8591                              ; AF1D  91 85
    .word D00_92BA                              ; AF1F  BA 92
    .byte $11,$43,$00,$02,$00,$00,$00           ; AF21
    .word D01_AF2A                              ; AF28  2A AF

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AF2A:
    .byte $05                                   ; AF2A
    .word D00_8570                              ; AF2B  70 85
    .word D00_92B4                              ; AF2D  B4 92
    .byte $00,$00,$00,$02,$00,$00,$00           ; AF2F
    .word D01_AF38                              ; AF36  38 AF

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AF38:
    .byte $04                                   ; AF38
    .word D00_882C                              ; AF39  2C 88
    .word D00_9368                              ; AF3B  68 93
    .byte $00,$00,$00,$02,$00,$00,$00           ; AF3D
    .word D01_AF46                              ; AF44  46 AF

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_AF46:
    .byte $64                                   ; AF46
    .word D00_8809                              ; AF47  09 88
    .word D00_9362                              ; AF49  62 93
    .byte $00,$00,$00,$02,$00,$00,$00,$00,$00   ; AF4B

; -- ESTADO (cabecalho, 7 bytes)   [cond=$08 CondProjetilLivre | classe=$B1 | acertos=0]
D01_AF54:
    .byte $08,$00,$00                           ; AF54
    .word D01_A12E                              ; AF57  2E A1
    .byte $B1,$00                               ; AF59

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $02                                   ; AF5B
    .word D00_81CD                              ; AF5C  CD 81
    .word D00_91EE                              ; AF5E  EE 91
    .byte $00,$00,$00,$04,$00,$00,$00           ; AF60
    .word D01_AF69                              ; AF67  69 AF

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AF69:
    .byte $06                                   ; AF69
    .word D00_81F6                              ; AF6A  F6 81
    .word D00_91F4                              ; AF6C  F4 91
    .byte $00,$00,$00,$04,$00,$00,$00           ; AF6E
    .word D01_AF77                              ; AF75  77 AF

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AF77:
    .byte $01                                   ; AF77
    .word D00_8225                              ; AF78  25 82
    .word D00_91FA                              ; AF7A  FA 91
    .byte $00,$00,$00,$04,$00,$00,$00           ; AF7C
    .word D01_AF85                              ; AF83  85 AF

; -- quadro (14 bytes)   [dur=1 efe=$00/$0B fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AF85:
    .byte $01                                   ; AF85
    .word D00_824A                              ; AF86  4A 82
    .word D00_9200                              ; AF88  00 92
    .byte $00,$0B,$00,$04,$00,$00,$00           ; AF8A
    .word D01_AF93                              ; AF91  93 AF

; -- quadro (14 bytes)   [dur=40 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AF93:
    .byte $28                                   ; AF93
    .word D00_824A                              ; AF94  4A 82
    .word D00_9200                              ; AF96  00 92
    .byte $00,$00,$00,$04,$00,$00,$00,$00,$00   ; AF98

; -- ESTADO (cabecalho, 7 bytes)   [cond=$08 CondProjetilLivre | classe=$B9 | acertos=0]
D01_AFA1:
    .byte $08,$00,$00                           ; AFA1
    .word D01_A12E                              ; AFA4  2E A1
    .byte $B9,$00                               ; AFA6

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $02                                   ; AFA8
    .word D00_81CD                              ; AFA9  CD 81
    .word D00_91EE                              ; AFAB  EE 91
    .byte $00,$00,$00,$04,$00,$00,$00           ; AFAD
    .word D01_AFB6                              ; AFB4  B6 AF

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AFB6:
    .byte $06                                   ; AFB6
    .word D00_81F6                              ; AFB7  F6 81
    .word D00_91F4                              ; AFB9  F4 91
    .byte $00,$00,$00,$04,$00,$00,$00           ; AFBB
    .word D01_AFC4                              ; AFC2  C4 AF

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AFC4:
    .byte $01                                   ; AFC4
    .word D00_8225                              ; AFC5  25 82
    .word D00_91FA                              ; AFC7  FA 91
    .byte $00,$00,$00,$04,$00,$00,$00           ; AFC9
    .word D01_AFD2                              ; AFD0  D2 AF

; -- quadro (14 bytes)   [dur=1 efe=$01/$0B fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AFD2:
    .byte $01                                   ; AFD2
    .word D00_824A                              ; AFD3  4A 82
    .word D00_9200                              ; AFD5  00 92
    .byte $01,$0B,$00,$04,$00,$00,$00           ; AFD7
    .word D01_AFE0                              ; AFDE  E0 AF

; -- quadro (14 bytes)   [dur=40 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_AFE0:
    .byte $28                                   ; AFE0
    .word D00_824A                              ; AFE1  4A 82
    .word D00_9200                              ; AFE3  00 92
    .byte $00,$00,$00,$04,$00,$00,$00,$00,$00   ; AFE5

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$C4 | acertos=2]
D01_AFEE:
    .byte $FF,$00,$00                           ; AFEE
    .word D01_B0A4                              ; AFF1  A4 B0
    .byte $C4,$02                               ; AFF3

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $04                                   ; AFF5
    .word D00_8AFB                              ; AFF6  FB 8A
    .byte $00,$00,$00,$00,$00,$04,$00,$00,$00   ; AFF8
    .word D01_B003                              ; B001  03 B0

; -- quadro (14 bytes)   [dur=4 efe=$72/$C7 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_B003:
    .byte $04                                   ; B003
    .word D00_8B20                              ; B004  20 8B
    .word D00_93FB                              ; B006  FB 93
    .byte $72,$C7,$00,$04,$00,$00,$00           ; B008
    .word D01_B011                              ; B00F  11 B0

; -- quadro (14 bytes)   [dur=14 efe=$6B/$C7 fl=$00 mov=$02 vx=10 vy=-45 rep=0]
D01_B011:
    .byte $0E                                   ; B011
    .word D00_8B4A                              ; B012  4A 8B
    .word D00_9401                              ; B014  01 94
    .byte $6B,$C7,$00,$02,$0A,$D3,$00           ; B016
    .word D01_B01F                              ; B01D  1F B0

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$00 mov=$02 vx=-10 vy=0 rep=0]
D01_B01F:
    .byte $01                                   ; B01F
    .word D00_8B76                              ; B020  76 8B
    .word D00_9407                              ; B022  07 94
    .byte $00,$00,$00,$02,$F6,$00,$00           ; B024
    .word D01_B03B                              ; B02B  3B B0

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]   [$B02D, nenhum ponteiro conhecido aponta para ca]
    .byte $05                                   ; B02D
    .word D00_8B76                              ; B02E  76 8B       (inferido)
    .word D00_9407                              ; B030  07 94       (inferido)
    .byte $00,$00,$00,$02,$00,$00,$00           ; B032
    .word D01_B03B                              ; B039  3B B0       (inferido)

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_B03B:
    .byte $64                                   ; B03B
    .word D00_8B9F                              ; B03C  9F 8B
    .word D00_940D                              ; B03E  0D 94
    .byte $00,$00,$00,$02,$00,$00,$00,$00,$00   ; B040

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$CC | acertos=2]
D01_B049:
    .byte $FF,$00,$00                           ; B049
    .word D01_B0A4                              ; B04C  A4 B0
    .byte $CC,$02                               ; B04E

; -- quadro (14 bytes)   [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $04                                   ; B050
    .word D00_8AFB                              ; B051  FB 8A
    .byte $00,$00,$00,$00,$00,$04,$00,$00,$00   ; B053
    .word D01_B05E                              ; B05C  5E B0

; -- quadro (14 bytes)   [dur=4 efe=$72/$C8 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D01_B05E:
    .byte $04                                   ; B05E
    .word D00_8B20                              ; B05F  20 8B
    .word D00_93FB                              ; B061  FB 93
    .byte $72,$C8,$00,$04,$00,$00,$00           ; B063
    .word D01_B06C                              ; B06A  6C B0

; -- quadro (14 bytes)   [dur=26 efe=$6B/$C7 fl=$00 mov=$02 vx=10 vy=-73 rep=0]
D01_B06C:
    .byte $1A                                   ; B06C
    .word D00_8B4A                              ; B06D  4A 8B
    .word D00_9401                              ; B06F  01 94
    .byte $6B,$C7,$00,$02,$0A,$B7,$00           ; B071
    .word D01_B07A                              ; B078  7A B0

; -- quadro (14 bytes)   [dur=1 efe=$00/$00 fl=$00 mov=$02 vx=-10 vy=0 rep=0]
D01_B07A:
    .byte $01                                   ; B07A
    .word D00_8B76                              ; B07B  76 8B
    .word D00_9407                              ; B07D  07 94
    .byte $00,$00,$00,$02,$F6,$00,$00           ; B07F
    .word D01_B088                              ; B086  88 B0

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_B088:
    .byte $05                                   ; B088
    .word D00_8B76                              ; B089  76 8B
    .word D00_9407                              ; B08B  07 94
    .byte $00,$00,$00,$02,$00,$00,$00           ; B08D
    .word D01_B096                              ; B094  96 B0

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_B096:
    .byte $64                                   ; B096
    .word D00_8B9F                              ; B097  9F 8B
    .word D00_940D                              ; B099  0D 94
    .byte $00,$00,$00,$02,$00,$00,$00,$00,$00   ; B09B

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$59 | acertos=0]
D01_B0A4:
    .byte $FF,$00,$00                           ; B0A4
    .word D01_A12E                              ; B0A7  2E A1
    .byte $59,$00                               ; B0A9

; -- quadro (14 bytes)   [dur=6 efe=$00/$20 fl=$00 mov=$04 vx=0 vy=0 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $06                                   ; B0AB
    .word D00_8BC9                              ; B0AC  C9 8B
    .word D00_9413                              ; B0AE  13 94
    .byte $00,$20,$00,$04,$00,$00,$00,$00,$00   ; B0B0

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$D4 | acertos=6]
D01_B0B9:
    .byte $FF,$00,$00                           ; B0B9
    .word D01_A35E                              ; B0BC  5E A3
    .byte $D4,$06                               ; B0BE

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$00 mov=$02 vx=14 vy=-48 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $06                                   ; B0C0
    .word D00_84D6                              ; B0C1  D6 84
    .byte $00,$00,$00,$00,$00,$02,$0E,$D0,$00   ; B0C3
    .word D01_B0CE                              ; B0CC  CE B0

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_B0CE:
    .byte $05                                   ; B0CE
    .word D00_84FD                              ; B0CF  FD 84
    .word D00_9419                              ; B0D1  19 94
    .byte $00,$00,$00,$02,$00,$00,$00           ; B0D3
    .word D01_B0DC                              ; B0DA  DC B0

; -- quadro (14 bytes)   [dur=3 efe=$6F/$C7 fl=$00 mov=$05 vx=16 vy=0 rep=0]
D01_B0DC:
    .byte $03                                   ; B0DC
    .word D00_8C3A                              ; B0DD  3A 8C
    .word D00_941F                              ; B0DF  1F 94
    .byte $6F,$C7,$00,$05,$10,$00,$00           ; B0E1
    .word D01_B0EA                              ; B0E8  EA B0

; -- quadro (14 bytes)   [dur=3 efe=$04/$20 fl=$00 mov=$05 vx=16 vy=0 rep=0]
D01_B0EA:
    .byte $03                                   ; B0EA
    .word D00_8C61                              ; B0EB  61 8C
    .word D00_9428                              ; B0ED  28 94
    .byte $04,$20,$00,$05,$10,$00,$00           ; B0EF
    .word D01_B0F8                              ; B0F6  F8 B0

; -- quadro (14 bytes)   [dur=3 efe=$6F/$C7 fl=$00 mov=$05 vx=16 vy=0 rep=0]
D01_B0F8:
    .byte $03                                   ; B0F8
    .word D00_8C87                              ; B0F9  87 8C
    .word D00_942E                              ; B0FB  2E 94
    .byte $6F,$C7,$00,$05,$10,$00,$00           ; B0FD
    .word D01_B106                              ; B104  06 B1

; -- quadro (16 bytes)   [dur=3 efe=$00/$00 fl=$00 mov=$05 vx=16 vy=0 rep=3 br=$B0DC]
D01_B106:
    .byte $03                                   ; B106
    .word D00_8CAA                              ; B107  AA 8C
    .word D00_9437                              ; B109  37 94
    .byte $00,$00,$00,$05,$10,$00,$03           ; B10B
    .word D01_B116                              ; B112  16 B1
    .word D01_B0DC                              ; B114  DC B0

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=16 vy=0 rep=0]
D01_B116:
    .byte $02                                   ; B116
    .word D00_854B                              ; B117  4B 85
    .word D00_92AE                              ; B119  AE 92
    .byte $00,$00,$00,$02,$10,$00,$00           ; B11B
    .word D01_B124                              ; B122  24 B1

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_B124:
    .byte $06                                   ; B124
    .word D00_882C                              ; B125  2C 88
    .word D00_9368                              ; B127  68 93
    .byte $00,$00,$00,$02,$00,$00,$00           ; B129
    .word D01_B132                              ; B130  32 B1

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_B132:
    .byte $64                                   ; B132
    .word D00_8809                              ; B133  09 88
    .word D00_9362                              ; B135  62 93
    .byte $00,$00,$00,$02,$00,$00,$00,$00,$00   ; B137

; -- ESTADO (cabecalho, 7 bytes)   [cond=$FF sempre | classe=$DC | acertos=6]
D01_B140:
    .byte $FF,$00,$00                           ; B140
    .word D01_A35E                              ; B143  5E A3
    .byte $DC,$06                               ; B145

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$00 mov=$02 vx=24 vy=-48 rep=0]   [1o quadro do estado acima: cabecalho+7]
    .byte $06                                   ; B147
    .word D00_84D6                              ; B148  D6 84
    .byte $00,$00,$00,$00,$00,$02,$18,$D0,$00   ; B14A
    .word D01_B155                              ; B153  55 B1

; -- quadro (14 bytes)   [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_B155:
    .byte $05                                   ; B155
    .word D00_84FD                              ; B156  FD 84
    .word D00_9419                              ; B158  19 94
    .byte $00,$00,$00,$02,$00,$00,$00           ; B15A
    .word D01_B163                              ; B161  63 B1

; -- quadro (14 bytes)   [dur=3 efe=$6F/$C7 fl=$00 mov=$05 vx=27 vy=0 rep=0]
D01_B163:
    .byte $03                                   ; B163
    .word D00_8C3A                              ; B164  3A 8C
    .word D00_941F                              ; B166  1F 94
    .byte $6F,$C7,$00,$05,$1B,$00,$00           ; B168
    .word D01_B171                              ; B16F  71 B1

; -- quadro (14 bytes)   [dur=3 efe=$04/$20 fl=$00 mov=$05 vx=27 vy=0 rep=0]
D01_B171:
    .byte $03                                   ; B171
    .word D00_8C61                              ; B172  61 8C
    .word D00_9428                              ; B174  28 94
    .byte $04,$20,$00,$05,$1B,$00,$00           ; B176
    .word D01_B17F                              ; B17D  7F B1

; -- quadro (14 bytes)   [dur=3 efe=$6F/$C7 fl=$00 mov=$05 vx=27 vy=0 rep=0]
D01_B17F:
    .byte $03                                   ; B17F
    .word D00_8C87                              ; B180  87 8C
    .word D00_942E                              ; B182  2E 94
    .byte $6F,$C7,$00,$05,$1B,$00,$00           ; B184
    .word D01_B18D                              ; B18B  8D B1

; -- quadro (16 bytes)   [dur=3 efe=$00/$00 fl=$00 mov=$05 vx=27 vy=0 rep=5 br=$B163]
D01_B18D:
    .byte $03                                   ; B18D
    .word D00_8CAA                              ; B18E  AA 8C
    .word D00_9437                              ; B190  37 94
    .byte $00,$00,$00,$05,$1B,$00,$05           ; B192
    .word D01_B19D                              ; B199  9D B1
    .word D01_B163                              ; B19B  63 B1

; -- quadro (14 bytes)   [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=27 vy=0 rep=0]
D01_B19D:
    .byte $02                                   ; B19D
    .word D00_854B                              ; B19E  4B 85
    .word D00_92AE                              ; B1A0  AE 92
    .byte $00,$00,$00,$02,$1B,$00,$00           ; B1A2
    .word D01_B1AB                              ; B1A9  AB B1

; -- quadro (14 bytes)   [dur=6 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_B1AB:
    .byte $06                                   ; B1AB
    .word D00_882C                              ; B1AC  2C 88
    .word D00_9368                              ; B1AE  68 93
    .byte $00,$00,$00,$02,$00,$00,$00           ; B1B0
    .word D01_B1B9                              ; B1B7  B9 B1

; -- quadro (14 bytes)   [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D01_B1B9:
    .byte $64                                   ; B1B9
    .word D00_8809                              ; B1BA  09 88
    .word D00_9362                              ; B1BC  62 93
    .byte $00,$00,$00,$02,$00,$00,$00,$00,$00   ; B1BE
    .res 3641, $FF                              ; B1C7
