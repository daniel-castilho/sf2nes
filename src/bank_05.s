; Ken state bank (PRG $05, window $A000-$BFFF).
;
; Structural copy of Ryu's bank ($01): same 71 states and 274 frames,
; with metasprite and collision pointers remapped to the frame bank
; of Ken ($04). Internal pointers ($A000-$BFFF) still point to the
; same addresses, because this bank occupies the same window as bank $01.
;
; Ryu->Ken mapping (in order of appearance in bank):
;   metasprites: 94 poses of Ryu -> 94 poses of Ken (Ken's selection pose $8A59
;               is left out, between poses 70 and 71)
;   collision:   all records shifted by -$0391
; Ver docs/FORMATS.md §2, §3, §6, §9, §10.

.include "defs.inc"
.segment "BANK05"

; ------------------------------------------------------------------------------------------------
; 8 tabelas de ponteiros (words consecutivas; $0000 = vaga)
KenDirTransTbl:
    .word KenDirNeutralEntry
    .word KenDirForwardEntry
    .word KenDirBackEntry
    .word KenDirUpEntry
    .word KenDirDownEntry
    .word KenDirUpForwardEntry
    .word KenDirUpBackEntry
    .word KenDirDownEntry
    .word KenDirDownBackEntry
KenAttackTransTbl:
    .word KenWeakPunchAir
    .word KenStrongPunchGround
    .word KenWeakKickAir
    .word KenThrowStart
KenSpcTrans:
    .word KenHadoukenWeak
    .word KenHadoukenStrong
    .word KenShoryukenWeak
    .word KenShoryukenStrong
    .word KenTatsumakiWeak
    .word KenTatsumakiStrong
KenGuardReactTbl:
    .word D05_A4CB
    .word D05_A4FE
    .word D05_A531
    .word D05_A4CB
    .word D05_A4FE
    .word D05_A531
    .word D05_A531
    .word D05_A531
    .word D05_A531
    .word D05_A531
    .word D05_A531
    .word D05_A564
KenHitReactStandTbl:
    .word D05_A597
    .word D05_A5CA
    .word D05_A60B
    .word D05_A668
    .word D05_A69B
    .word D05_A6DC
    .word D05_A973
    .word D05_A8F5
    .word D05_A60B
    .word $0000
    .word $0000
    .word D05_A80A
KenHitReactCrouchTbl:
    .word D05_A739
    .word D05_A76C
    .word D05_A7AD
    .word D05_A739
    .word D05_A76C
    .word D05_A7AD
    .word D05_A973
    .word D05_A8F5
    .word D05_A7AD
    .word $0000
    .word $0000
    .word D05_A867
KenHitReactNeutralTbl:
    .word D05_AA06
    .word D05_AA06
    .word D05_AA06
    .word D05_AA06
    .word D05_AA06
    .word D05_AA06
    .word D05_AA06
    .word D05_A8F5
    .word D05_A8F5
    .word $0000
    .word $0000
    .word D05_A8C4
KenThrowTbl:
    .word D05_AA92
    .word $0000
    .word D05_AA92
    .word $0000
    .word $0000
    .word $0000
    .word $0000
    .word $0000
    .word $0000
    .word $0000
    .word $0000
    .word $0000
    .res 18, $00                                ; A09E..A0AF (padding ate o primeiro estado)

; ------------------------------------------------------------------------------------------------
; Estados (cabecalho de 7 bytes) e quadros de animacao (14/16 bytes)

; -- estado (7 bytes)  [cond=$0A classe=$E9 acertos=0]
D05_A0B0:
    .byte $0A
    .word D05_A10B
    .word D05_A12E
    .byte $E9,$00

; -- quadro (14 bytes)  [dur=8 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_A0B7:
    .byte $08
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $0000                         ; sem colisao
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_A0C5

; -- quadro (14 bytes)  [dur=8 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_A0C5:
    .byte $08
    .word $8A91                         ; metasprite do Ken (Ryu $8AD5)
    .word $0000                         ; sem colisao
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_A0D3

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_A0D3:
    .byte $64
    .word $8E07                         ; metasprite do Ken (Ryu $8E49)
    .word $0000                         ; sem colisao
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_A0D3

; -- estado (7 bytes)  [cond=$FF classe=$F0 acertos=0]
D05_A0E1:
    .byte $FF
    .word $0000
    .word $0000
    .byte $F0,$00

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_A0E8:
    .byte $64
    .word $8106                         ; metasprite do Ken (Ryu $8106)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_A0E8

; -- estado (7 bytes)  [cond=$0B classe=$F1 acertos=0]
KenDirNeutralEntry:
    .byte $0B
    .word D05_A0B0
    .word D05_A12E
    .byte $F1,$00

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_A0FD:
    .byte $64
    .word $8A91                         ; metasprite do Ken (Ryu $8AD5)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_A0FD

; -- estado (7 bytes)  [cond=$01 classe=$59 acertos=0]
D05_A10B:
    .byte $01
    .word D05_A12E
    .word D05_A12E
    .byte $59,$00

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_A112:
    .byte $03
    .word $8A91                         ; metasprite do Ken (Ryu $8AD5)
    .word $904F                         ; colisao do Ken (Ryu $93E0)
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_A120

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$07 mov=$04 vx=0 vy=0 rep=0]
D05_A120:
    .byte $01
    .word $8A91                         ; metasprite do Ken (Ryu $8AD5)
    .word $904F                         ; colisao do Ken (Ryu $93E0)
    .byte $00,$00,$07,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$59 acertos=0]
D05_A12E:
    .byte $FF
    .word $0000
    .word $0000
    .byte $59,$00

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$0F mov=$04 vx=0 vy=0 rep=0]
D05_A135:
    .byte $07
    .word $89DC                         ; metasprite do Ken (Ryu $8A20)
    .word $904F                         ; colisao do Ken (Ryu $93E0)
    .byte $00,$00,$0F,$04,$00,$00,$00
    .word D05_A143

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$0F mov=$04 vx=0 vy=0 rep=0]
D05_A143:
    .byte $07
    .word $8A05                         ; metasprite do Ken (Ryu $8A49)
    .word $9058                         ; colisao do Ken (Ryu $93E9)
    .byte $00,$00,$0F,$04,$00,$00,$00
    .word D05_A151

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$0F mov=$04 vx=0 vy=0 rep=0]
D05_A151:
    .byte $07
    .word $8A2F                         ; metasprite do Ken (Ryu $8A73)
    .word $9061                         ; colisao do Ken (Ryu $93F2)
    .byte $00,$00,$0F,$04,$00,$00,$00
    .word D05_A15F

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$0F mov=$04 vx=0 vy=0 rep=0]
D05_A15F:
    .byte $07
    .word $8A05                         ; metasprite do Ken (Ryu $8A49)
    .word $9058                         ; colisao do Ken (Ryu $93E9)
    .byte $00,$00,$0F,$04,$00,$00,$00
    .word D05_A135

; -- estado (7 bytes)  [cond=$FF classe=$61 acertos=0]
KenDirForwardEntry:
    .byte $FF
    .word $0000
    .word $0000
    .byte $61,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$17 mov=$04 vx=0 vy=0 rep=0]
D05_A174:
    .byte $01
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90B2                         ; colisao do Ken (Ryu $9443)
    .byte $00,$00,$17,$04,$00,$00,$00
    .word D05_A190

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$1F mov=$04 vx=23 vy=0 rep=0]
D05_A182:
    .byte $04
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90BB                         ; colisao do Ken (Ryu $944C)
    .byte $00,$00,$1F,$04,$17,$00,$00
    .word D05_A190

; -- quadro (14 bytes)  [dur=8 efe=$00/$00 fl=$1F mov=$04 vx=23 vy=0 rep=0]
D05_A190:
    .byte $08
    .word $8D61                         ; metasprite do Ken (Ryu $8DA3)
    .word $90BB                         ; colisao do Ken (Ryu $944C)
    .byte $00,$00,$1F,$04,$17,$00,$00
    .word D05_A19E

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$1F mov=$04 vx=23 vy=0 rep=0]
D05_A19E:
    .byte $06
    .word $8D8B                         ; metasprite do Ken (Ryu $8DCD)
    .word $90C4                         ; colisao do Ken (Ryu $9455)
    .byte $00,$00,$1F,$04,$17,$00,$00
    .word D05_A1AC

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$1F mov=$04 vx=23 vy=0 rep=0]
D05_A1AC:
    .byte $07
    .word $8DB5                         ; metasprite do Ken (Ryu $8DF7)
    .word $90CD                         ; colisao do Ken (Ryu $945E)
    .byte $00,$00,$1F,$04,$17,$00,$00
    .word D05_A1BA

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$1F mov=$04 vx=23 vy=0 rep=0]
D05_A1BA:
    .byte $07
    .word $8DDD                         ; metasprite do Ken (Ryu $8E1F)
    .word $90D6                         ; colisao do Ken (Ryu $9467)
    .byte $00,$00,$1F,$04,$17,$00,$00
    .word D05_A182

; -- estado (7 bytes)  [cond=$FF classe=$69 acertos=0]
D05_A1C8:
    .byte $FF
    .word $0000
    .word $0000
    .byte $69,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$17 mov=$04 vx=0 vy=0 rep=0]
D05_A1CF:
    .byte $01
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90B2                         ; colisao do Ken (Ryu $9443)
    .byte $00,$00,$17,$04,$00,$00,$00
    .word D05_A1EB

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$1F mov=$04 vx=-16 vy=0 rep=0]
D05_A1DD:
    .byte $04
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90B2                         ; colisao do Ken (Ryu $9443)
    .byte $00,$00,$1F,$04,$F0,$00,$00
    .word D05_A1EB

; -- quadro (14 bytes)  [dur=8 efe=$00/$00 fl=$1F mov=$04 vx=-16 vy=0 rep=0]
D05_A1EB:
    .byte $08
    .word $8D61                         ; metasprite do Ken (Ryu $8DA3)
    .word $90BB                         ; colisao do Ken (Ryu $944C)
    .byte $00,$00,$1F,$04,$F0,$00,$00
    .word D05_A1F9

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$1F mov=$04 vx=-16 vy=0 rep=0]
D05_A1F9:
    .byte $06
    .word $8D8B                         ; metasprite do Ken (Ryu $8DCD)
    .word $90C4                         ; colisao do Ken (Ryu $9455)
    .byte $00,$00,$1F,$04,$F0,$00,$00
    .word D05_A207

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$1F mov=$04 vx=-16 vy=0 rep=0]
D05_A207:
    .byte $07
    .word $8DB5                         ; metasprite do Ken (Ryu $8DF7)
    .word $90CD                         ; colisao do Ken (Ryu $945E)
    .byte $00,$00,$1F,$04,$F0,$00,$00
    .word D05_A215

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$1F mov=$04 vx=-16 vy=0 rep=0]
D05_A215:
    .byte $07
    .word $8DDD                         ; metasprite do Ken (Ryu $8E1F)
    .word $90D6                         ; colisao do Ken (Ryu $9467)
    .byte $00,$00,$1F,$04,$F0,$00,$00
    .word D05_A1DD

; -- estado (7 bytes)  [cond=$FF classe=$5C acertos=0]
KenDirUpEntry:
    .byte $FF
    .word $0000
    .word D05_A35E
    .byte $5C,$00

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_A22A:
    .byte $03
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90B2                         ; colisao do Ken (Ryu $9443)
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_A238

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=-76 rep=0]
D05_A238:
    .byte $01
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$00,$02,$00,$B4,$00
    .word D05_A246

; -- quadro (14 bytes)  [dur=13 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A246:
    .byte $0D
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A254

; -- quadro (14 bytes)  [dur=22 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A254:
    .byte $16
    .word $87E9                         ; metasprite do Ken (Ryu $882C)
    .word $8FD7                         ; colisao do Ken (Ryu $9368)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A262

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A262:
    .byte $64
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$64 acertos=0]
KenDirUpForwardEntry:
    .byte $FF
    .word $0000
    .word D05_A35E
    .byte $64,$00

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_A277:
    .byte $03
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90B2                         ; colisao do Ken (Ryu $9443)
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_A285

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$00 mov=$02 vx=20 vy=-76 rep=0]
D05_A285:
    .byte $01
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$00,$02,$14,$B4,$00
    .word D05_A293

; -- quadro (14 bytes)  [dur=15 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A293:
    .byte $0F
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A2A1

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A2A1:
    .byte $06
    .word $8805                         ; metasprite do Ken (Ryu $8849)
    .word $8FDD                         ; colisao do Ken (Ryu $936E)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A2AF

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A2AF:
    .byte $05
    .word $8825                         ; metasprite do Ken (Ryu $8868)
    .word $8FE6                         ; colisao do Ken (Ryu $9377)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A2BD

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A2BD:
    .byte $05
    .word $8841                         ; metasprite do Ken (Ryu $8885)
    .word $8FEF                         ; colisao do Ken (Ryu $9380)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A2CB

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A2CB:
    .byte $06
    .word $8861                         ; metasprite do Ken (Ryu $88A4)
    .word $8FF8                         ; colisao do Ken (Ryu $9389)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A2D9

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A2D9:
    .byte $64
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$6C acertos=0]
KenDirUpBackEntry:
    .byte $FF
    .word $0000
    .word D05_A35E
    .byte $6C,$00

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_A2EE:
    .byte $03
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90B2                         ; colisao do Ken (Ryu $9443)
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_A2FC

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$00 mov=$02 vx=-25 vy=-76 rep=0]
D05_A2FC:
    .byte $01
    .word $8861                         ; metasprite do Ken (Ryu $88A4)
    .word $8FF8                         ; colisao do Ken (Ryu $9389)
    .byte $00,$00,$00,$02,$E7,$B4,$00
    .word D05_A30A

; -- quadro (14 bytes)  [dur=15 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A30A:
    .byte $0F
    .word $8861                         ; metasprite do Ken (Ryu $88A4)
    .word $8FF8                         ; colisao do Ken (Ryu $9389)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A318

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A318:
    .byte $06
    .word $8841                         ; metasprite do Ken (Ryu $8885)
    .word $8FEF                         ; colisao do Ken (Ryu $9380)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A326

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A326:
    .byte $05
    .word $8825                         ; metasprite do Ken (Ryu $8868)
    .word $8FE6                         ; colisao do Ken (Ryu $9377)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A334

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A334:
    .byte $05
    .word $8805                         ; metasprite do Ken (Ryu $8849)
    .word $8FDD                         ; colisao do Ken (Ryu $936E)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A342

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A342:
    .byte $06
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word D05_A350

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$0A mov=$02 vx=0 vy=0 rep=0]
D05_A350:
    .byte $64
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$0A,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$59 acertos=0]
D05_A35E:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $59,$00

; -- quadro (14 bytes)  [dur=3 efe=$00/$20 fl=$0E mov=$04 vx=0 vy=0 rep=0]
D05_A365:
    .byte $03
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90B2                         ; colisao do Ken (Ryu $9443)
    .byte $00,$20,$0E,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$03 classe=$5A acertos=0]
KenDirDownEntry:
    .byte $03
    .word D05_A39D
    .word D05_A3C0
    .byte $5A,$00

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$07 mov=$04 vx=0 vy=0 rep=0]
D05_A37A:
    .byte $02
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90B2                         ; colisao do Ken (Ryu $9443)
    .byte $00,$00,$07,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$04 classe=$59 acertos=0]
D05_A388:
    .byte $04
    .word D05_A10B
    .word D05_A12E
    .byte $59,$00

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$07 mov=$04 vx=0 vy=0 rep=0]
D05_A38F:
    .byte $02
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90B2                         ; colisao do Ken (Ryu $9443)
    .byte $00,$00,$07,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$01 classe=$5A acertos=0]
D05_A39D:
    .byte $01
    .word D05_A3C0
    .word D05_A3C0
    .byte $5A,$00

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_A3A4:
    .byte $03
    .word $806A                         ; metasprite do Ken (Ryu $806A)
    .word $8E42                         ; colisao do Ken (Ryu $91D3)
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_A3B2

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$07 mov=$04 vx=0 vy=0 rep=0]
D05_A3B2:
    .byte $01
    .word $806A                         ; metasprite do Ken (Ryu $806A)
    .word $8E42                         ; colisao do Ken (Ryu $91D3)
    .byte $00,$00,$07,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$5A acertos=0]  corrigido: cadeia natural apontava p/ $0000 (trava)
D05_A3C0:
    .byte $FF
    .word $0000
    .word D05_A12E        ; cadeia natural -> estado neutro do Ken (era $0000)
    .byte $5A,$00

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$0F mov=$04 vx=0 vy=0 rep=0]  corrigido: next apontava p/ si mesmo (loop infinito)
D05_A3C7:
    .byte $64
    .word $8046                         ; metasprite do Ken (Ryu $8046)
    .word $8E42                         ; colisao do Ken (Ryu $91D3)
    .byte $00,$00,$0F,$04,$00,$00,$00
    .word $0000                         ; fim da animacao -> segue cadeia natural D05_A12E (era D05_A3C7)

; -- estado (7 bytes)  [cond=$00 classe=$29 acertos=0]
KenDirBackEntry:
    .byte $00
    .word D05_A1C8
    .word D05_A12E
    .byte $29,$00

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$1F mov=$04 vx=0 vy=0 rep=0]
D05_A3DC:
    .byte $64
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$1F,$04,$00,$00,$00
    .word D05_A3DC

; -- estado (7 bytes)  [cond=$00 classe=$2A acertos=0]
KenDirDownBackEntry:
    .byte $00
    .word KenDirDownEntry
    .word D05_A3C0
    .byte $2A,$00

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$1F mov=$04 vx=0 vy=0 rep=0]
D05_A3F1:
    .byte $64
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$1F,$04,$00,$00,$00
    .word D05_A3F1

; -- estado (7 bytes)  [cond=$FF classe=$29 acertos=0]
D05_A3FF:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $29,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D05_A406:
    .byte $01
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$30,$04,$E0,$00,$00
    .word D05_A414

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7]
D05_A414:
    .byte $01
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$30,$04,$20,$00,$07
    .word D05_A424
    .word D05_A406

; -- quadro (14 bytes)  [dur=26 efe=$00/$00 fl=$40 mov=$02 vx=-32 vy=0 rep=0]
D05_A424:
    .byte $1A
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$40,$02,$E0,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$29 acertos=0]
D05_A432:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $29,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D05_A439:
    .byte $01
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$30,$04,$E0,$00,$00
    .word D05_A447

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7]
D05_A447:
    .byte $01
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$30,$04,$20,$00,$07
    .word D05_A457
    .word D05_A439

; -- quadro (14 bytes)  [dur=36 efe=$00/$00 fl=$40 mov=$02 vx=-45 vy=0 rep=0]
D05_A457:
    .byte $24
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$40,$02,$D3,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$29 acertos=0]
D05_A465:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $29,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D05_A46C:
    .byte $01
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$30,$04,$E0,$00,$00
    .word D05_A47A

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7]
D05_A47A:
    .byte $01
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$30,$04,$20,$00,$07
    .word D05_A48A
    .word D05_A46C

; -- quadro (14 bytes)  [dur=36 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D05_A48A:
    .byte $24
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$40,$02,$C9,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$29 acertos=0]
D05_A498:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $29,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D05_A49F:
    .byte $01
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$30,$04,$E0,$00,$00
    .word D05_A4AD

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7]
D05_A4AD:
    .byte $01
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$30,$04,$20,$00,$07
    .word D05_A4BD
    .word D05_A49F

; -- quadro (14 bytes)  [dur=36 efe=$00/$00 fl=$00 mov=$02 vx=-55 vy=0 rep=0]
D05_A4BD:
    .byte $24
    .word $8020                         ; metasprite do Ken (Ryu $8020)
    .word $8E39                         ; colisao do Ken (Ryu $91CA)
    .byte $00,$00,$00,$02,$C9,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$04 classe=$2A acertos=0]
D05_A4CB:
    .byte $04
    .word D05_A3FF
    .word D05_A3C0
    .byte $2A,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D05_A4D2:
    .byte $01
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$30,$04,$E0,$00,$00
    .word D05_A4E0

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7]
D05_A4E0:
    .byte $01
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$30,$04,$20,$00,$07
    .word D05_A4F0
    .word D05_A4D2

; -- quadro (14 bytes)  [dur=19 efe=$00/$00 fl=$40 mov=$02 vx=-32 vy=0 rep=0]
D05_A4F0:
    .byte $13
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$40,$02,$E0,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$04 classe=$2A acertos=0]
D05_A4FE:
    .byte $04
    .word D05_A465
    .word D05_A3C0
    .byte $2A,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D05_A505:
    .byte $01
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$30,$04,$E0,$00,$00
    .word D05_A513

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7]
D05_A513:
    .byte $01
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$30,$04,$20,$00,$07
    .word D05_A523
    .word D05_A505

; -- quadro (14 bytes)  [dur=36 efe=$00/$00 fl=$40 mov=$02 vx=-45 vy=0 rep=0]
D05_A523:
    .byte $24
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$40,$02,$D3,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$04 classe=$2A acertos=0]
D05_A531:
    .byte $04
    .word D05_A465
    .word D05_A3C0
    .byte $2A,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D05_A538:
    .byte $01
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$30,$04,$E0,$00,$00
    .word D05_A546

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7]
D05_A546:
    .byte $01
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$30,$04,$20,$00,$07
    .word D05_A556
    .word D05_A538

; -- quadro (14 bytes)  [dur=36 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D05_A556:
    .byte $24
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$40,$02,$C9,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$04 classe=$2A acertos=0]
D05_A564:
    .byte $04
    .word D05_A498
    .word D05_A3C0
    .byte $2A,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0]
D05_A56B:
    .byte $01
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$30,$04,$E0,$00,$00
    .word D05_A579

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7]
D05_A579:
    .byte $01
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$30,$04,$20,$00,$07
    .word D05_A589
    .word D05_A56B

; -- quadro (14 bytes)  [dur=36 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D05_A589:
    .byte $24
    .word $8000                         ; metasprite do Ken (Ryu $8000)
    .word $8E30                         ; colisao do Ken (Ryu $91C1)
    .byte $00,$00,$40,$02,$C9,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$31 acertos=0]
D05_A597:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $31,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A59E:
    .byte $01
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A5AC

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A5AC:
    .byte $01
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A5BC
    .word D05_A59E

; -- quadro (14 bytes)  [dur=11 efe=$00/$00 fl=$40 mov=$02 vx=-32 vy=0 rep=0]
D05_A5BC:
    .byte $0B
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$40,$02,$E0,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$31 acertos=0]
D05_A5CA:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $31,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A5D1:
    .byte $01
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A5DF

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A5DF:
    .byte $01
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A5EF
    .word D05_A5D1

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$40 mov=$02 vx=-45 vy=0 rep=0]
D05_A5EF:
    .byte $03
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$40,$02,$D3,$00,$00
    .word D05_A5FD

; -- quadro (14 bytes)  [dur=13 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A5FD:
    .byte $0D
    .word $8336                         ; metasprite do Ken (Ryu $8375)
    .word $8EB1                         ; colisao do Ken (Ryu $9242)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$31 acertos=0]
D05_A60B:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $31,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A612:
    .byte $01
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A620

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A620:
    .byte $01
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A630
    .word D05_A612

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D05_A630:
    .byte $03
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$40,$02,$C9,$00,$00
    .word D05_A63E

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A63E:
    .byte $04
    .word $8336                         ; metasprite do Ken (Ryu $8375)
    .word $8EB1                         ; colisao do Ken (Ryu $9242)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word D05_A64C

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A64C:
    .byte $04
    .word $835D                         ; metasprite do Ken (Ryu $839C)
    .word $8EBA                         ; colisao do Ken (Ryu $924B)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word D05_A65A

; -- quadro (14 bytes)  [dur=9 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A65A:
    .byte $09
    .word $80B6                         ; metasprite do Ken (Ryu $80B6)
    .word $8E54                         ; colisao do Ken (Ryu $91E5)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$31 acertos=0]
D05_A668:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $31,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A66F:
    .byte $01
    .word $823F                         ; metasprite do Ken (Ryu $827C)
    .word $8E78                         ; colisao do Ken (Ryu $9209)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A67D

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A67D:
    .byte $01
    .word $823F                         ; metasprite do Ken (Ryu $827C)
    .word $8E78                         ; colisao do Ken (Ryu $9209)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A68D
    .word D05_A66F

; -- quadro (14 bytes)  [dur=11 efe=$00/$00 fl=$40 mov=$02 vx=-32 vy=0 rep=0]
D05_A68D:
    .byte $0B
    .word $823F                         ; metasprite do Ken (Ryu $827C)
    .word $8E78                         ; colisao do Ken (Ryu $9209)
    .byte $00,$00,$40,$02,$E0,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$31 acertos=0]
D05_A69B:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $31,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A6A2:
    .byte $01
    .word $823F                         ; metasprite do Ken (Ryu $827C)
    .word $8E78                         ; colisao do Ken (Ryu $9209)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A6B0

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A6B0:
    .byte $01
    .word $823F                         ; metasprite do Ken (Ryu $827C)
    .word $8E78                         ; colisao do Ken (Ryu $9209)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A6C0
    .word D05_A6A2

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$40 mov=$02 vx=-45 vy=0 rep=0]
D05_A6C0:
    .byte $07
    .word $823F                         ; metasprite do Ken (Ryu $827C)
    .word $8E78                         ; colisao do Ken (Ryu $9209)
    .byte $00,$00,$40,$02,$D3,$00,$00
    .word D05_A6CE

; -- quadro (14 bytes)  [dur=9 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A6CE:
    .byte $09
    .word $8264                         ; metasprite do Ken (Ryu $82A1)
    .word $8E7E                         ; colisao do Ken (Ryu $920F)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$31 acertos=0]
D05_A6DC:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $31,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A6E3:
    .byte $01
    .word $823F                         ; metasprite do Ken (Ryu $827C)
    .word $8E78                         ; colisao do Ken (Ryu $9209)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A6F1

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A6F1:
    .byte $01
    .word $823F                         ; metasprite do Ken (Ryu $827C)
    .word $8E78                         ; colisao do Ken (Ryu $9209)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A701
    .word D05_A6E3

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D05_A701:
    .byte $03
    .word $823F                         ; metasprite do Ken (Ryu $827C)
    .word $8E78                         ; colisao do Ken (Ryu $9209)
    .byte $00,$00,$40,$02,$C9,$00,$00
    .word D05_A70F

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A70F:
    .byte $04
    .word $8264                         ; metasprite do Ken (Ryu $82A1)
    .word $8E7E                         ; colisao do Ken (Ryu $920F)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word D05_A71D

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A71D:
    .byte $04
    .word $8288                         ; metasprite do Ken (Ryu $82C5)
    .word $8E87                         ; colisao do Ken (Ryu $9218)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word D05_A72B

; -- quadro (14 bytes)  [dur=9 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A72B:
    .byte $09
    .word $80B6                         ; metasprite do Ken (Ryu $80B6)
    .word $8E54                         ; colisao do Ken (Ryu $91E5)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$32 acertos=0]
D05_A739:
    .byte $FF
    .word $0000
    .word D05_A3C0
    .byte $32,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A740:
    .byte $01
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A74E

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A74E:
    .byte $01
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A75E
    .word D05_A740

; -- quadro (14 bytes)  [dur=11 efe=$00/$00 fl=$40 mov=$02 vx=-32 vy=0 rep=0]
D05_A75E:
    .byte $0B
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$40,$02,$E0,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$32 acertos=0]
D05_A76C:
    .byte $FF
    .word $0000
    .word D05_A3C0
    .byte $32,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A773:
    .byte $01
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A781

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A781:
    .byte $01
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A791
    .word D05_A773

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$40 mov=$02 vx=-45 vy=0 rep=0]
D05_A791:
    .byte $07
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$40,$02,$D3,$00,$00
    .word D05_A79F

; -- quadro (14 bytes)  [dur=9 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A79F:
    .byte $09
    .word $82D0                         ; metasprite do Ken (Ryu $830D)
    .word $8E99                         ; colisao do Ken (Ryu $922A)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$32 acertos=0]
D05_A7AD:
    .byte $FF
    .word $0000
    .word D05_A3C0
    .byte $32,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A7B4:
    .byte $01
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A7C2

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A7C2:
    .byte $01
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A7D2
    .word D05_A7B4

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$40 mov=$02 vx=-55 vy=0 rep=0]
D05_A7D2:
    .byte $05
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$40,$02,$C9,$00,$00
    .word D05_A7E0

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A7E0:
    .byte $06
    .word $82D0                         ; metasprite do Ken (Ryu $830D)
    .word $8E99                         ; colisao do Ken (Ryu $922A)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word D05_A7EE

; -- quadro (14 bytes)  [dur=9 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A7EE:
    .byte $09
    .word $82F1                         ; metasprite do Ken (Ryu $8330)
    .word $8EA2                         ; colisao do Ken (Ryu $9233)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word D05_A7FC

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$40 mov=$02 vx=0 vy=0 rep=0]
D05_A7FC:
    .byte $03
    .word $8046                         ; metasprite do Ken (Ryu $8046)
    .word $8E42                         ; colisao do Ken (Ryu $91D3)
    .byte $00,$00,$40,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$31 acertos=0]
D05_A80A:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $31,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A811:
    .byte $01
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A81F

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A81F:
    .byte $01
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A82F
    .word D05_A811

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$00 mov=$02 vx=-55 vy=0 rep=0]
D05_A82F:
    .byte $03
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $8EAB                         ; colisao do Ken (Ryu $923C)
    .byte $00,$00,$00,$02,$C9,$00,$00
    .word D05_A83D

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_A83D:
    .byte $04
    .word $8336                         ; metasprite do Ken (Ryu $8375)
    .word $8EB1                         ; colisao do Ken (Ryu $9242)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_A84B

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_A84B:
    .byte $04
    .word $835D                         ; metasprite do Ken (Ryu $839C)
    .word $8EBA                         ; colisao do Ken (Ryu $924B)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_A859

; -- quadro (14 bytes)  [dur=9 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_A859:
    .byte $09
    .word $80B6                         ; metasprite do Ken (Ryu $80B6)
    .word $8E54                         ; colisao do Ken (Ryu $91E5)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$32 acertos=0]
D05_A867:
    .byte $FF
    .word $0000
    .word D05_A3C0
    .byte $32,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=-32 vy=0 rep=0]
D05_A86E:
    .byte $01
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$20,$04,$E0,$00,$00
    .word D05_A87C

; -- quadro (16 bytes)  [dur=1 efe=$00/$00 fl=$20 mov=$04 vx=32 vy=0 rep=7]
D05_A87C:
    .byte $01
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$20,$04,$20,$00,$07
    .word D05_A88C
    .word D05_A86E

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=-55 vy=0 rep=0]
D05_A88C:
    .byte $05
    .word $82B0                         ; metasprite do Ken (Ryu $82ED)
    .word $8E90                         ; colisao do Ken (Ryu $9221)
    .byte $00,$00,$00,$02,$C9,$00,$00
    .word D05_A89A

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_A89A:
    .byte $06
    .word $82D0                         ; metasprite do Ken (Ryu $830D)
    .word $8E99                         ; colisao do Ken (Ryu $922A)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_A8A8

; -- quadro (14 bytes)  [dur=9 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_A8A8:
    .byte $09
    .word $82F1                         ; metasprite do Ken (Ryu $8330)
    .word $8EA2                         ; colisao do Ken (Ryu $9233)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_A8B6

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_A8B6:
    .byte $03
    .word $8046                         ; metasprite do Ken (Ryu $8046)
    .word $8E42                         ; colisao do Ken (Ryu $91D3)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$34 acertos=0]
D05_A8C4:
    .byte $FF
    .word $0000
    .word D05_A926
    .byte $34,$00

; -- quadro (14 bytes)  [dur=14 efe=$00/$00 fl=$10 mov=$01 vx=0 vy=0 rep=0]
D05_A8CB:
    .byte $0E
    .word $8288                         ; metasprite do Ken (Ryu $82C5)
    .word $0000                         ; sem colisao
    .byte $00,$00,$10,$01,$00,$00,$00
    .word D05_A8D9

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$00 mov=$02 vx=-20 vy=-48 rep=0]
D05_A8D9:
    .byte $07
    .word $8288                         ; metasprite do Ken (Ryu $82C5)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$EC,$D0,$00
    .word D05_A8E7

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_A8E7:
    .byte $64
    .word $80E3                         ; metasprite do Ken (Ryu $80E3)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$34 acertos=0]
D05_A8F5:
    .byte $FF
    .word $0000
    .word D05_A926
    .byte $34,$00

; -- quadro (14 bytes)  [dur=14 efe=$00/$00 fl=$10 mov=$01 vx=0 vy=0 rep=0]
D05_A8FC:
    .byte $0E
    .word $8288                         ; metasprite do Ken (Ryu $82C5)
    .word $0000                         ; sem colisao
    .byte $00,$00,$10,$01,$00,$00,$00
    .word D05_A90A

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$40 mov=$02 vx=-20 vy=-48 rep=0]
D05_A90A:
    .byte $07
    .word $8288                         ; metasprite do Ken (Ryu $82C5)
    .word $0000                         ; sem colisao
    .byte $00,$00,$40,$02,$EC,$D0,$00
    .word D05_A918

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_A918:
    .byte $64
    .word $80E3                         ; metasprite do Ken (Ryu $80E3)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$34 acertos=0]
D05_A926:
    .byte $FF
    .word $0000
    .word D05_A949
    .byte $34,$00

; -- quadro (14 bytes)  [dur=4 efe=$09/$20 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_A92D:
    .byte $04
    .word $8106                         ; metasprite do Ken (Ryu $8106)
    .word $0000                         ; sem colisao
    .byte $09,$20,$00,$02,$00,$00,$00
    .word D05_A93B

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=-24 rep=0]
D05_A93B:
    .byte $64
    .word $80E3                         ; metasprite do Ken (Ryu $80E3)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$00,$E8,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$30 acertos=0]
D05_A949:
    .byte $FF
    .word D05_A0E1
    .word D05_A9A4
    .byte $30,$00

; -- quadro (14 bytes)  [dur=11 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_A950:
    .byte $0B
    .word $8106                         ; metasprite do Ken (Ryu $8106)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$30 acertos=0]
D05_A95E:
    .byte $FF
    .word $0000
    .word D05_A949
    .byte $30,$00

; -- quadro (14 bytes)  [dur=1 efe=$09/$20 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_A965:
    .byte $01
    .word $8106                         ; metasprite do Ken (Ryu $8106)
    .word $0000                         ; sem colisao
    .byte $09,$20,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$31 acertos=0]
D05_A973:
    .byte $FF
    .word $0000
    .word D05_A95E
    .byte $31,$00

; -- quadro (14 bytes)  [dur=16 efe=$00/$00 fl=$10 mov=$01 vx=0 vy=0 rep=0]
D05_A97A:
    .byte $10
    .word $8BAF                         ; metasprite do Ken (Ryu $8BF3)
    .word $0000                         ; sem colisao
    .byte $00,$00,$10,$01,$00,$00,$00
    .word D05_A988

; -- quadro (14 bytes)  [dur=7 efe=$00/$00 fl=$40 mov=$02 vx=-23 vy=-56 rep=0]
D05_A988:
    .byte $07
    .word $8BAF                         ; metasprite do Ken (Ryu $8BF3)
    .word $0000                         ; sem colisao
    .byte $00,$00,$40,$02,$E9,$C8,$00
    .word D05_A996

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_A996:
    .byte $64
    .word $8BD7                         ; metasprite do Ken (Ryu $8C1B)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$49 acertos=0]
D05_A9A4:
    .byte $FF
    .word D05_A9E3
    .word D05_A12E
    .byte $49,$00

; -- quadro (14 bytes)  [dur=8 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_A9AB:
    .byte $08
    .word $8144                         ; metasprite do Ken (Ryu $8181)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_A9B9

; -- quadro (14 bytes)  [dur=11 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_A9B9:
    .byte $0B
    .word $816C                         ; metasprite do Ken (Ryu $81A9)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_A9C7

; -- quadro (14 bytes)  [dur=8 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_A9C7:
    .byte $08
    .word $87E9                         ; metasprite do Ken (Ryu $882C)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_A9D5

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$07 mov=$04 vx=0 vy=0 rep=0]
D05_A9D5:
    .byte $01
    .word $89DC                         ; metasprite do Ken (Ryu $8A20)
    .word $0000                         ; sem colisao
    .byte $00,$00,$07,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$51 acertos=0]
D05_A9E3:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $51,$00

; -- quadro (14 bytes)  [dur=26 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_A9EA:
    .byte $1A
    .word $8089                         ; metasprite do Ken (Ryu $8089)
    .word $904F                         ; colisao do Ken (Ryu $93E0)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_A9F8

; -- quadro (14 bytes)  [dur=19 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_A9F8:
    .byte $13
    .word $80B6                         ; metasprite do Ken (Ryu $80B6)
    .word $904F                         ; colisao do Ken (Ryu $93E0)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_A9EA

; -- estado (7 bytes)  [cond=$FF classe=$34 acertos=0]
D05_AA06:
    .byte $FF
    .word $0000
    .word D05_AA6F
    .byte $34,$00

; -- quadro (14 bytes)  [dur=15 efe=$00/$00 fl=$10 mov=$01 vx=0 vy=0 rep=0]
D05_AA0D:
    .byte $0F
    .word $80E3                         ; metasprite do Ken (Ryu $80E3)
    .word $0000                         ; sem colisao
    .byte $00,$00,$10,$01,$00,$00,$00
    .word D05_AA1B

; -- quadro (14 bytes)  [dur=14 efe=$00/$00 fl=$40 mov=$02 vx=-20 vy=-64 rep=0]
D05_AA1B:
    .byte $0E
    .word $80E3                         ; metasprite do Ken (Ryu $80E3)
    .word $0000                         ; sem colisao
    .byte $00,$00,$40,$02,$EC,$C0,$00
    .word D05_AA29

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AA29:
    .byte $02
    .word $8841                         ; metasprite do Ken (Ryu $8885)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AA37

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AA37:
    .byte $02
    .word $8825                         ; metasprite do Ken (Ryu $8868)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AA45

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AA45:
    .byte $02
    .word $8805                         ; metasprite do Ken (Ryu $8849)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AA53

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AA53:
    .byte $02
    .word $87E9                         ; metasprite do Ken (Ryu $882C)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AA61

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AA61:
    .byte $64
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$4C acertos=0]
D05_AA6F:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $4C,$00

; -- quadro (14 bytes)  [dur=1 efe=$00/$20 fl=$17 mov=$04 vx=0 vy=0 rep=0]
D05_AA76:
    .byte $01
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $0000                         ; sem colisao
    .byte $00,$20,$17,$04,$00,$00,$00
    .word D05_AA84

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$17 mov=$04 vx=0 vy=0 rep=0]
D05_AA84:
    .byte $03
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90B2                         ; colisao do Ken (Ryu $9443)
    .byte $00,$00,$17,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$39 acertos=0]
D05_AA92:
    .byte $FF
    .word $0000
    .word D05_A926
    .byte $39,$00

; -- quadro (14 bytes)  [dur=15 efe=$00/$00 fl=$50 mov=$00 vx=-16 vy=0 rep=0]
D05_AA99:
    .byte $0F
    .word $8311                         ; metasprite do Ken (Ryu $8350)
    .word $0000                         ; sem colisao
    .byte $00,$00,$50,$00,$F0,$00,$00
    .word D05_AAA7

; -- quadro (14 bytes)  [dur=10 efe=$00/$00 fl=$40 mov=$01 vx=-3 vy=-16 rep=0]
D05_AAA7:
    .byte $0A
    .word $823F                         ; metasprite do Ken (Ryu $827C)
    .word $0000                         ; sem colisao
    .byte $00,$00,$40,$01,$FD,$F0,$00
    .word D05_AAB5

; -- quadro (14 bytes)  [dur=10 efe=$00/$00 fl=$40 mov=$01 vx=20 vy=-12 rep=0]
D05_AAB5:
    .byte $0A
    .word $8121                         ; metasprite do Ken (Ryu $8121)
    .word $0000                         ; sem colisao
    .byte $00,$00,$40,$01,$14,$F4,$00
    .word D05_AAC3

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$40 mov=$01 vx=26 vy=8 rep=0]
D05_AAC3:
    .byte $05
    .word $8386                         ; metasprite do Ken (Ryu $83C5)
    .word $0000                         ; sem colisao
    .byte $00,$00,$40,$01,$1A,$08,$00
    .word D05_AAD1

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=39 vy=-32 rep=0]
D05_AAD1:
    .byte $64
    .word $80E3                         ; metasprite do Ken (Ryu $80E3)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$27,$E0,$00
    .word $0000

; -- estado (7 bytes)  [cond=$09 classe=$A1 acertos=1]
KenThrowStart:
    .byte $09
    .word KenStrongKickAir
    .word D05_A12E
    .byte $A1,$01

; -- quadro (14 bytes)  [dur=1 efe=$16/$0C fl=$00 mov=$01 vx=0 vy=0 rep=0]
D05_AAE6:
    .byte $01
    .word $8D3F                         ; metasprite do Ken (Ryu $8D81)
    .word $90AC                         ; colisao do Ken (Ryu $943D)
    .byte $16,$0C,$00,$01,$00,$00,$00
    .word D05_AAF4

; -- quadro (14 bytes)  [dur=15 efe=$00/$00 fl=$00 mov=$01 vx=0 vy=0 rep=0]
D05_AAF4:
    .byte $0F
    .word $8C8D                         ; metasprite do Ken (Ryu $8CCF)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$01,$00,$00,$00
    .word D05_AB02

; -- quadro (14 bytes)  [dur=10 efe=$00/$00 fl=$00 mov=$01 vx=0 vy=0 rep=0]
D05_AB02:
    .byte $0A
    .word $8CBF                         ; metasprite do Ken (Ryu $8D01)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$01,$00,$00,$00
    .word D05_AB10

; -- quadro (14 bytes)  [dur=10 efe=$00/$00 fl=$00 mov=$01 vx=0 vy=0 rep=0]
D05_AB10:
    .byte $0A
    .word $8CF2                         ; metasprite do Ken (Ryu $8D34)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$01,$00,$00,$00
    .word D05_AB1E

; -- quadro (14 bytes)  [dur=36 efe=$00/$00 fl=$00 mov=$01 vx=0 vy=0 rep=0]
D05_AB1E:
    .byte $24
    .word $8D21                         ; metasprite do Ken (Ryu $8D63)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$01,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$71 acertos=1]
KenWeakKick:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $71,$01

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_AB33:
    .byte $03
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_AB41

; -- quadro (14 bytes)  [dur=4 efe=$03/$C0 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D05_AB41:
    .byte $04
    .word $89AF                         ; metasprite do Ken (Ryu $89F3)
    .word $9043                         ; colisao do Ken (Ryu $93D4)
    .byte $03,$C0,$03,$04,$00,$00,$00
    .word D05_AB4F

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D05_AB4F:
    .byte $04
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$03,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$02 classe=$71 acertos=1]
KenWeakKickNear:
    .byte $02
    .word KenWeakKick
    .word D05_A12E
    .byte $71,$01

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_AB64:
    .byte $03
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_AB72

; -- quadro (14 bytes)  [dur=4 efe=$03/$C0 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D05_AB72:
    .byte $04
    .word $8915                         ; metasprite do Ken (Ryu $8959)
    .word $9022                         ; colisao do Ken (Ryu $93B3)
    .byte $03,$C0,$03,$04,$00,$00,$00
    .word D05_AB80

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D05_AB80:
    .byte $04
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$03,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$07 classe=$72 acertos=1]
KenWeakKickCrouch:
    .byte $07
    .word KenWeakKickNear
    .word D05_A3C0
    .byte $72,$01

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_AB95:
    .byte $03
    .word $8943                         ; metasprite do Ken (Ryu $8987)
    .word $902B                         ; colisao do Ken (Ryu $93BC)
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_ABA3

; -- quadro (14 bytes)  [dur=4 efe=$03/$C3 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D05_ABA3:
    .byte $04
    .word $8961                         ; metasprite do Ken (Ryu $89A5)
    .word $9031                         ; colisao do Ken (Ryu $93C2)
    .byte $03,$C3,$03,$04,$00,$00,$00
    .word D05_ABB1

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D05_ABB1:
    .byte $04
    .word $8943                         ; metasprite do Ken (Ryu $8987)
    .word $902B                         ; colisao do Ken (Ryu $93BC)
    .byte $00,$00,$03,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$05 classe=$74 acertos=1]
KenWeakKickAir:
    .byte $05
    .word KenWeakKickCrouch
    .word D05_A35E
    .byte $74,$01

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_ABC6:
    .byte $02
    .word $8726                         ; metasprite do Ken (Ryu $876A)
    .word $8FAD                         ; colisao do Ken (Ryu $933E)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_ABD4

; -- quadro (14 bytes)  [dur=100 efe=$08/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_ABD4:
    .byte $64
    .word $874A                         ; metasprite do Ken (Ryu $878D)
    .word $8FB3                         ; colisao do Ken (Ryu $9344)
    .byte $08,$43,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$81 acertos=1]
KenStrongKick:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $81,$01

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_ABE9:
    .byte $04
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_ABF7

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_ABF7:
    .byte $02
    .word $8775                         ; metasprite do Ken (Ryu $87B8)
    .word $8FBC                         ; colisao do Ken (Ryu $934D)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AC05

; -- quadro (14 bytes)  [dur=6 efe=$12/$C2 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AC05:
    .byte $06
    .word $879F                         ; metasprite do Ken (Ryu $87E2)
    .word $8FC5                         ; colisao do Ken (Ryu $9356)
    .byte $12,$C2,$00,$04,$00,$00,$00
    .word D05_AC13

; -- quadro (14 bytes)  [dur=10 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AC13:
    .byte $0A
    .word $8775                         ; metasprite do Ken (Ryu $87B8)
    .word $8FBC                         ; colisao do Ken (Ryu $934D)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AC21

; -- quadro (14 bytes)  [dur=12 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AC21:
    .byte $0C
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$02 classe=$81 acertos=1]
KenStrongKickNear:
    .byte $02
    .word KenStrongKick
    .word D05_A12E
    .byte $81,$01

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AC36:
    .byte $04
    .word $8636                         ; metasprite do Ken (Ryu $867A)
    .word $8F65                         ; colisao do Ken (Ryu $92F6)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AC44

; -- quadro (14 bytes)  [dur=2 efe=$12/$C5 fl=$01 mov=$04 vx=0 vy=0 rep=0]
D05_AC44:
    .byte $02
    .word $865D                         ; metasprite do Ken (Ryu $86A1)
    .word $8F6E                         ; colisao do Ken (Ryu $92FF)
    .byte $12,$C5,$01,$04,$00,$00,$00
    .word D05_AC52

; -- quadro (14 bytes)  [dur=6 efe=$12/$C5 fl=$01 mov=$04 vx=0 vy=0 rep=0]
D05_AC52:
    .byte $06
    .word $8684                         ; metasprite do Ken (Ryu $86C8)
    .word $8F7A                         ; colisao do Ken (Ryu $930B)
    .byte $12,$C5,$01,$04,$00,$00,$00
    .word D05_AC60

; -- quadro (14 bytes)  [dur=10 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AC60:
    .byte $0A
    .word $865D                         ; metasprite do Ken (Ryu $86A1)
    .word $8F65                         ; colisao do Ken (Ryu $92F6)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AC6E

; -- quadro (14 bytes)  [dur=12 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AC6E:
    .byte $0C
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$07 classe=$82 acertos=1]
KenStrongKickCrouch:
    .byte $07
    .word KenStrongKickNear
    .word D05_A3C0
    .byte $82,$01

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AC83:
    .byte $04
    .word $86AF                         ; metasprite do Ken (Ryu $86F3)
    .word $8F8F                         ; colisao do Ken (Ryu $9320)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AC91

; -- quadro (14 bytes)  [dur=3 efe=$12/$C5 fl=$01 mov=$04 vx=0 vy=0 rep=0]
D05_AC91:
    .byte $03
    .word $86CF                         ; metasprite do Ken (Ryu $8713)
    .word $8F95                         ; colisao do Ken (Ryu $9326)
    .byte $12,$C5,$01,$04,$00,$00,$00
    .word D05_AC9F

; -- quadro (14 bytes)  [dur=8 efe=$12/$C5 fl=$01 mov=$04 vx=0 vy=0 rep=0]
D05_AC9F:
    .byte $08
    .word $86F9                         ; metasprite do Ken (Ryu $873D)
    .word $8FA1                         ; colisao do Ken (Ryu $9332)
    .byte $12,$C5,$01,$04,$00,$00,$00
    .word D05_ACAD

; -- quadro (14 bytes)  [dur=24 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_ACAD:
    .byte $18
    .word $86AF                         ; metasprite do Ken (Ryu $86F3)
    .word $8F8F                         ; colisao do Ken (Ryu $9320)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_ACBB

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_ACBB:
    .byte $03
    .word $8046                         ; metasprite do Ken (Ryu $8046)
    .word $8E42                         ; colisao do Ken (Ryu $91D3)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$05 classe=$84 acertos=1]
KenStrongKickAir:
    .byte $05
    .word KenStrongKickCrouch
    .word D05_A35E
    .byte $84,$01

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_ACD0:
    .byte $02
    .word $8726                         ; metasprite do Ken (Ryu $876A)
    .word $8FAD                         ; colisao do Ken (Ryu $933E)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_ACDE

; -- quadro (14 bytes)  [dur=8 efe=$11/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_ACDE:
    .byte $08
    .word $874A                         ; metasprite do Ken (Ryu $878D)
    .word $8FB3                         ; colisao do Ken (Ryu $9344)
    .byte $11,$43,$00,$02,$00,$00,$00
    .word D05_ACEC

; -- quadro (14 bytes)  [dur=12 efe=$00/$01 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_ACEC:
    .byte $0C
    .word $8726                         ; metasprite do Ken (Ryu $876A)
    .word $8FAD                         ; colisao do Ken (Ryu $933E)
    .byte $00,$01,$00,$02,$00,$00,$00
    .word D05_ACFA

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_ACFA:
    .byte $64
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$89 acertos=1]
KenWeakPunch:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $89,$01

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_AD0F:
    .byte $02
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_AD1D

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AD1D:
    .byte $03
    .word $83AB                         ; metasprite do Ken (Ryu $83EA)
    .word $8EC3                         ; colisao do Ken (Ryu $9254)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AD2B

; -- quadro (14 bytes)  [dur=6 efe=$08/$83 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AD2B:
    .byte $06
    .word $88F0                         ; metasprite do Ken (Ryu $8934)
    .word $9019                         ; colisao do Ken (Ryu $93AA)
    .byte $08,$83,$00,$04,$00,$00,$00
    .word D05_AD39

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AD39:
    .byte $03
    .word $83AB                         ; metasprite do Ken (Ryu $83EA)
    .word $8EC3                         ; colisao do Ken (Ryu $9254)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AD47

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AD47:
    .byte $01
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$07 classe=$8A acertos=1]
KenWeakPunchCrouch:
    .byte $07
    .word KenWeakPunch
    .word D05_A3C0
    .byte $8A,$01

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$10 mov=$04 vx=0 vy=0 rep=0]
D05_AD5C:
    .byte $03
    .word $8886                         ; metasprite do Ken (Ryu $88C9)
    .word $9001                         ; colisao do Ken (Ryu $9392)
    .byte $00,$00,$10,$04,$00,$00,$00
    .word D05_AD6A

; -- quadro (14 bytes)  [dur=4 efe=$03/$83 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D05_AD6A:
    .byte $04
    .word $88AA                         ; metasprite do Ken (Ryu $88ED)
    .word $9007                         ; colisao do Ken (Ryu $9398)
    .byte $03,$83,$03,$04,$00,$00,$00
    .word D05_AD78

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$03 mov=$04 vx=0 vy=0 rep=0]
D05_AD78:
    .byte $04
    .word $8886                         ; metasprite do Ken (Ryu $88C9)
    .word $9001                         ; colisao do Ken (Ryu $9392)
    .byte $00,$00,$03,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$05 classe=$8C acertos=1]
KenWeakPunchAir:
    .byte $05
    .word KenWeakPunchCrouch
    .word D05_A35E
    .byte $8C,$01

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AD8D:
    .byte $05
    .word $87E9                         ; metasprite do Ken (Ryu $882C)
    .word $8FD7                         ; colisao do Ken (Ryu $9368)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AD9B

; -- quadro (14 bytes)  [dur=100 efe=$08/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AD9B:
    .byte $64
    .word $88D4                         ; metasprite do Ken (Ryu $8918)
    .word $9010                         ; colisao do Ken (Ryu $93A1)
    .byte $08,$43,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$99 acertos=1]
KenStrongPunch:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $99,$01

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_ADB0:
    .byte $03
    .word $8572                         ; metasprite do Ken (Ryu $85B2)
    .word $8F32                         ; colisao do Ken (Ryu $92C3)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_ADBE

; -- quadro (14 bytes)  [dur=4 efe=$13/$C2 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_ADBE:
    .byte $04
    .word $8593                         ; metasprite do Ken (Ryu $85D3)
    .word $8F3B                         ; colisao do Ken (Ryu $92CC)
    .byte $13,$C2,$00,$04,$00,$00,$00
    .word D05_ADCC

; -- quadro (14 bytes)  [dur=8 efe=$13/$C2 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_ADCC:
    .byte $08
    .word $85C0                         ; metasprite do Ken (Ryu $8604)
    .word $8F47                         ; colisao do Ken (Ryu $92D8)
    .byte $13,$C2,$00,$04,$00,$00,$00
    .word D05_ADDA

; -- quadro (14 bytes)  [dur=10 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_ADDA:
    .byte $0A
    .word $85EE                         ; metasprite do Ken (Ryu $8632)
    .word $8F53                         ; colisao do Ken (Ryu $92E4)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_ADE8

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_ADE8:
    .byte $06
    .word $8612                         ; metasprite do Ken (Ryu $8656)
    .word $8F5C                         ; colisao do Ken (Ryu $92ED)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$02 classe=$99 acertos=2]
KenStrongPunchNear:
    .byte $02
    .word KenStrongPunch
    .word D05_A12E
    .byte $99,$02

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_ADFD:
    .byte $03
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AE0B

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AE0B:
    .byte $04
    .word $83AB                         ; metasprite do Ken (Ryu $83EA)
    .word $8EC3                         ; colisao do Ken (Ryu $9254)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AE19

; -- quadro (14 bytes)  [dur=8 efe=$13/$C2 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AE19:
    .byte $08
    .word $83F8                         ; metasprite do Ken (Ryu $8437)
    .word $8ED5                         ; colisao do Ken (Ryu $9266)
    .byte $13,$C2,$00,$04,$00,$00,$00
    .word D05_AE27

; -- quadro (14 bytes)  [dur=4 efe=$03/$C5 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AE27:
    .byte $04
    .word $83CE                         ; metasprite do Ken (Ryu $840D)
    .word $8EC9                         ; colisao do Ken (Ryu $925A)
    .byte $03,$C5,$00,$04,$00,$00,$00
    .word D05_AE35

; -- quadro (14 bytes)  [dur=10 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AE35:
    .byte $0A
    .word $83AB                         ; metasprite do Ken (Ryu $83EA)
    .word $8EC3                         ; colisao do Ken (Ryu $9254)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AE43

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AE43:
    .byte $01
    .word $8981                         ; metasprite do Ken (Ryu $89C5)
    .word $903A                         ; colisao do Ken (Ryu $93CB)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$07 classe=$9A acertos=1]
KenStrongPunchCrouch:
    .byte $07
    .word KenStrongPunchNear
    .word D05_A3C0
    .byte $9A,$01

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AE58:
    .byte $04
    .word $8422                         ; metasprite do Ken (Ryu $8461)
    .word $8EE1                         ; colisao do Ken (Ryu $9272)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AE66

; -- quadro (14 bytes)  [dur=6 efe=$11/$86 fl=$01 mov=$04 vx=0 vy=0 rep=0]
D05_AE66:
    .byte $06
    .word $843F                         ; metasprite do Ken (Ryu $847E)
    .word $8EEA                         ; colisao do Ken (Ryu $927B)
    .byte $11,$86,$01,$04,$00,$00,$00
    .word D05_AE74

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AE74:
    .byte $06
    .word $845B                         ; metasprite do Ken (Ryu $849A)
    .word $8EF6                         ; colisao do Ken (Ryu $9287)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AE82

; -- quadro (14 bytes)  [dur=8 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AE82:
    .byte $08
    .word $8478                         ; metasprite do Ken (Ryu $84B7)
    .word $8EFF                         ; colisao do Ken (Ryu $9290)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AE90

; -- quadro (14 bytes)  [dur=10 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AE90:
    .byte $0A
    .word $806A                         ; metasprite do Ken (Ryu $806A)
    .word $8E42                         ; colisao do Ken (Ryu $91D3)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AE9E

; -- quadro (14 bytes)  [dur=3 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AE9E:
    .byte $03
    .word $8046                         ; metasprite do Ken (Ryu $8046)
    .word $8E42                         ; colisao do Ken (Ryu $91D3)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$05 classe=$9C acertos=1]
KenStrongPunchAir:
    .byte $05
    .word KenStrongPunchCrouch
    .word D05_A35E
    .byte $9C,$01

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AEB3:
    .byte $02
    .word $8497                         ; metasprite do Ken (Ryu $84D6)
    .word $8F05                         ; colisao do Ken (Ryu $9296)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AEC1

; -- quadro (14 bytes)  [dur=4 efe=$12/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AEC1:
    .byte $04
    .word $84BE                         ; metasprite do Ken (Ryu $84FD)
    .word $8F0B                         ; colisao do Ken (Ryu $929C)
    .byte $12,$43,$00,$02,$00,$00,$00
    .word D05_AECF

; -- quadro (14 bytes)  [dur=6 efe=$12/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AECF:
    .byte $06
    .word $84E5                         ; metasprite do Ken (Ryu $8524)
    .word $8F14                         ; colisao do Ken (Ryu $92A5)
    .byte $12,$43,$00,$02,$00,$00,$00
    .word D05_AEDD

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AEDD:
    .byte $05
    .word $850C                         ; metasprite do Ken (Ryu $854B)
    .word $8F1D                         ; colisao do Ken (Ryu $92AE)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AEEB

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AEEB:
    .byte $05
    .word $87E9                         ; metasprite do Ken (Ryu $882C)
    .word $8FD7                         ; colisao do Ken (Ryu $9368)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AEF9

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AEF9:
    .byte $64
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AEF9

; -- estado (7 bytes)  [cond=$06 classe=$9C acertos=1]
KenStrongPunchGround:
    .byte $06
    .word KenStrongPunchAir
    .word D05_A35E
    .byte $9C,$01

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AF0E:
    .byte $05
    .word $8530                         ; metasprite do Ken (Ryu $8570)
    .word $8F23                         ; colisao do Ken (Ryu $92B4)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AF1C

; -- quadro (14 bytes)  [dur=7 efe=$11/$43 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AF1C:
    .byte $07
    .word $8551                         ; metasprite do Ken (Ryu $8591)
    .word $8F29                         ; colisao do Ken (Ryu $92BA)
    .byte $11,$43,$00,$02,$00,$00,$00
    .word D05_AF2A

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AF2A:
    .byte $05
    .word $8530                         ; metasprite do Ken (Ryu $8570)
    .word $8F23                         ; colisao do Ken (Ryu $92B4)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AF38

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AF38:
    .byte $04
    .word $87E9                         ; metasprite do Ken (Ryu $882C)
    .word $8FD7                         ; colisao do Ken (Ryu $9368)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_AF46

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_AF46:
    .byte $64
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$08 classe=$B1 acertos=0]
KenHadoukenWeak:
    .byte $08
    .word $0000
    .word D05_A12E
    .byte $B1,$00

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AF5B:
    .byte $02
    .word $8190                         ; metasprite do Ken (Ryu $81CD)
    .word $8E5D                         ; colisao do Ken (Ryu $91EE)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AF69

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AF69:
    .byte $06
    .word $81B9                         ; metasprite do Ken (Ryu $81F6)
    .word $8E63                         ; colisao do Ken (Ryu $91F4)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AF77

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AF77:
    .byte $01
    .word $81E8                         ; metasprite do Ken (Ryu $8225)
    .word $8E69                         ; colisao do Ken (Ryu $91FA)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AF85

; -- quadro (14 bytes)  [dur=1 efe=$00/$0B fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AF85:
    .byte $01
    .word $820D                         ; metasprite do Ken (Ryu $824A)
    .word $8E6F                         ; colisao do Ken (Ryu $9200)
    .byte $00,$0B,$00,$04,$00,$00,$00
    .word D05_AF93

; -- quadro (14 bytes)  [dur=40 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AF93:
    .byte $28
    .word $820D                         ; metasprite do Ken (Ryu $824A)
    .word $8E6F                         ; colisao do Ken (Ryu $9200)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$08 classe=$B9 acertos=0]
KenHadoukenStrong:
    .byte $08
    .word $0000
    .word D05_A12E
    .byte $B9,$00

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AFA8:
    .byte $02
    .word $8190                         ; metasprite do Ken (Ryu $81CD)
    .word $8E5D                         ; colisao do Ken (Ryu $91EE)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AFB6

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AFB6:
    .byte $06
    .word $81B9                         ; metasprite do Ken (Ryu $81F6)
    .word $8E63                         ; colisao do Ken (Ryu $91F4)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AFC4

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AFC4:
    .byte $01
    .word $81E8                         ; metasprite do Ken (Ryu $8225)
    .word $8E69                         ; colisao do Ken (Ryu $91FA)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_AFD2

; -- quadro (14 bytes)  [dur=1 efe=$01/$0B fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AFD2:
    .byte $01
    .word $820D                         ; metasprite do Ken (Ryu $824A)
    .word $8E6F                         ; colisao do Ken (Ryu $9200)
    .byte $01,$0B,$00,$04,$00,$00,$00
    .word D05_AFE0

; -- quadro (14 bytes)  [dur=40 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AFE0:
    .byte $28
    .word $820D                         ; metasprite do Ken (Ryu $824A)
    .word $8E6F                         ; colisao do Ken (Ryu $9200)
    .byte $00,$00,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$C4 acertos=2]
KenShoryukenWeak:
    .byte $FF
    .word $0000
    .word D05_B0A4
    .byte $C4,$02

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_AFF5:
    .byte $04
    .word $8AB7                         ; metasprite do Ken (Ryu $8AFB)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_B003

; -- quadro (14 bytes)  [dur=4 efe=$72/$C7 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_B003:
    .byte $04
    .word $8ADC                         ; metasprite do Ken (Ryu $8B20)
    .word $906A                         ; colisao do Ken (Ryu $93FB)
    .byte $72,$C7,$00,$04,$00,$00,$00
    .word D05_B011

; -- quadro (14 bytes)  [dur=14 efe=$6B/$C7 fl=$00 mov=$02 vx=10 vy=-45 rep=0]
D05_B011:
    .byte $0E
    .word $8B06                         ; metasprite do Ken (Ryu $8B4A)
    .word $9070                         ; colisao do Ken (Ryu $9401)
    .byte $6B,$C7,$00,$02,$0A,$D3,$00
    .word D05_B01F

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$00 mov=$02 vx=-10 vy=0 rep=0]
D05_B01F:
    .byte $01
    .word $8B32                         ; metasprite do Ken (Ryu $8B76)
    .word $9076                         ; colisao do Ken (Ryu $9407)
    .byte $00,$00,$00,$02,$F6,$00,$00
    .word D05_B03B

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_B02D:
    .byte $05
    .word $8B32                         ; metasprite do Ken (Ryu $8B76)
    .word $9076                         ; colisao do Ken (Ryu $9407)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_B03B

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_B03B:
    .byte $64
    .word $8B5B                         ; metasprite do Ken (Ryu $8B9F)
    .word $907C                         ; colisao do Ken (Ryu $940D)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$CC acertos=2]
KenShoryukenStrong:
    .byte $FF
    .word $0000
    .word D05_B0A4
    .byte $CC,$02

; -- quadro (14 bytes)  [dur=4 efe=$00/$00 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_B050:
    .byte $04
    .word $8AB7                         ; metasprite do Ken (Ryu $8AFB)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$04,$00,$00,$00
    .word D05_B05E

; -- quadro (14 bytes)  [dur=4 efe=$72/$C8 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_B05E:
    .byte $04
    .word $8ADC                         ; metasprite do Ken (Ryu $8B20)
    .word $906A                         ; colisao do Ken (Ryu $93FB)
    .byte $72,$C8,$00,$04,$00,$00,$00
    .word D05_B06C

; -- quadro (14 bytes)  [dur=26 efe=$6B/$C7 fl=$00 mov=$02 vx=10 vy=-73 rep=0]
D05_B06C:
    .byte $1A
    .word $8B06                         ; metasprite do Ken (Ryu $8B4A)
    .word $9070                         ; colisao do Ken (Ryu $9401)
    .byte $6B,$C7,$00,$02,$0A,$B7,$00
    .word D05_B07A

; -- quadro (14 bytes)  [dur=1 efe=$00/$00 fl=$00 mov=$02 vx=-10 vy=0 rep=0]
D05_B07A:
    .byte $01
    .word $8B32                         ; metasprite do Ken (Ryu $8B76)
    .word $9076                         ; colisao do Ken (Ryu $9407)
    .byte $00,$00,$00,$02,$F6,$00,$00
    .word D05_B088

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_B088:
    .byte $05
    .word $8B32                         ; metasprite do Ken (Ryu $8B76)
    .word $9076                         ; colisao do Ken (Ryu $9407)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_B096

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_B096:
    .byte $64
    .word $8B5B                         ; metasprite do Ken (Ryu $8B9F)
    .word $907C                         ; colisao do Ken (Ryu $940D)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$59 acertos=0]
D05_B0A4:
    .byte $FF
    .word $0000
    .word D05_A12E
    .byte $59,$00

; -- quadro (14 bytes)  [dur=6 efe=$00/$20 fl=$00 mov=$04 vx=0 vy=0 rep=0]
D05_B0AB:
    .byte $06
    .word $8B85                         ; metasprite do Ken (Ryu $8BC9)
    .word $9082                         ; colisao do Ken (Ryu $9413)
    .byte $00,$20,$00,$04,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$D4 acertos=6]
KenTatsumakiWeak:
    .byte $FF
    .word $0000
    .word D05_A35E
    .byte $D4,$06

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$00 mov=$02 vx=14 vy=-48 rep=0]
D05_B0C0:
    .byte $06
    .word $8497                         ; metasprite do Ken (Ryu $84D6)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$0E,$D0,$00
    .word D05_B0CE

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_B0CE:
    .byte $05
    .word $84BE                         ; metasprite do Ken (Ryu $84FD)
    .word $9088                         ; colisao do Ken (Ryu $9419)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_B0DC

; -- quadro (14 bytes)  [dur=3 efe=$6F/$C7 fl=$00 mov=$05 vx=16 vy=0 rep=0]
D05_B0DC:
    .byte $03
    .word $8BF6                         ; metasprite do Ken (Ryu $8C3A)
    .word $908E                         ; colisao do Ken (Ryu $941F)
    .byte $6F,$C7,$00,$05,$10,$00,$00
    .word D05_B0EA

; -- quadro (14 bytes)  [dur=3 efe=$04/$20 fl=$00 mov=$05 vx=16 vy=0 rep=0]
D05_B0EA:
    .byte $03
    .word $8C1E                         ; metasprite do Ken (Ryu $8C61)
    .word $9097                         ; colisao do Ken (Ryu $9428)
    .byte $04,$20,$00,$05,$10,$00,$00
    .word D05_B0F8

; -- quadro (14 bytes)  [dur=3 efe=$6F/$C7 fl=$00 mov=$05 vx=16 vy=0 rep=0]
D05_B0F8:
    .byte $03
    .word $8C44                         ; metasprite do Ken (Ryu $8C87)
    .word $909D                         ; colisao do Ken (Ryu $942E)
    .byte $6F,$C7,$00,$05,$10,$00,$00
    .word D05_B106

; -- quadro (16 bytes)  [dur=3 efe=$00/$00 fl=$00 mov=$05 vx=16 vy=0 rep=3]
D05_B106:
    .byte $03
    .word $8C68                         ; metasprite do Ken (Ryu $8CAA)
    .word $90A6                         ; colisao do Ken (Ryu $9437)
    .byte $00,$00,$00,$05,$10,$00,$03
    .word D05_B116
    .word D05_B0DC

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=16 vy=0 rep=0]
D05_B116:
    .byte $02
    .word $850C                         ; metasprite do Ken (Ryu $854B)
    .word $8F1D                         ; colisao do Ken (Ryu $92AE)
    .byte $00,$00,$00,$02,$10,$00,$00
    .word D05_B124

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_B124:
    .byte $06
    .word $87E9                         ; metasprite do Ken (Ryu $882C)
    .word $8FD7                         ; colisao do Ken (Ryu $9368)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_B132

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_B132:
    .byte $64
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000

; -- estado (7 bytes)  [cond=$FF classe=$DC acertos=6]
KenTatsumakiStrong:
    .byte $FF
    .word $0000
    .word D05_A35E
    .byte $DC,$06

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$00 mov=$02 vx=24 vy=-48 rep=0]
D05_B147:
    .byte $06
    .word $8497                         ; metasprite do Ken (Ryu $84D6)
    .word $0000                         ; sem colisao
    .byte $00,$00,$00,$02,$18,$D0,$00
    .word D05_B155

; -- quadro (14 bytes)  [dur=5 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_B155:
    .byte $05
    .word $84BE                         ; metasprite do Ken (Ryu $84FD)
    .word $9088                         ; colisao do Ken (Ryu $9419)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_B163

; -- quadro (14 bytes)  [dur=3 efe=$6F/$C7 fl=$00 mov=$05 vx=27 vy=0 rep=0]
D05_B163:
    .byte $03
    .word $8BF6                         ; metasprite do Ken (Ryu $8C3A)
    .word $908E                         ; colisao do Ken (Ryu $941F)
    .byte $6F,$C7,$00,$05,$1B,$00,$00
    .word D05_B171

; -- quadro (14 bytes)  [dur=3 efe=$04/$20 fl=$00 mov=$05 vx=27 vy=0 rep=0]
D05_B171:
    .byte $03
    .word $8C1E                         ; metasprite do Ken (Ryu $8C61)
    .word $9097                         ; colisao do Ken (Ryu $9428)
    .byte $04,$20,$00,$05,$1B,$00,$00
    .word D05_B17F

; -- quadro (14 bytes)  [dur=3 efe=$6F/$C7 fl=$00 mov=$05 vx=27 vy=0 rep=0]
D05_B17F:
    .byte $03
    .word $8C44                         ; metasprite do Ken (Ryu $8C87)
    .word $909D                         ; colisao do Ken (Ryu $942E)
    .byte $6F,$C7,$00,$05,$1B,$00,$00
    .word D05_B18D

; -- quadro (16 bytes)  [dur=3 efe=$00/$00 fl=$00 mov=$05 vx=27 vy=0 rep=5]
D05_B18D:
    .byte $03
    .word $8C68                         ; metasprite do Ken (Ryu $8CAA)
    .word $90A6                         ; colisao do Ken (Ryu $9437)
    .byte $00,$00,$00,$05,$1B,$00,$05
    .word D05_B19D
    .word D05_B163

; -- quadro (14 bytes)  [dur=2 efe=$00/$00 fl=$00 mov=$02 vx=27 vy=0 rep=0]
D05_B19D:
    .byte $02
    .word $850C                         ; metasprite do Ken (Ryu $854B)
    .word $8F1D                         ; colisao do Ken (Ryu $92AE)
    .byte $00,$00,$00,$02,$1B,$00,$00
    .word D05_B1AB

; -- quadro (14 bytes)  [dur=6 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_B1AB:
    .byte $06
    .word $87E9                         ; metasprite do Ken (Ryu $882C)
    .word $8FD7                         ; colisao do Ken (Ryu $9368)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word D05_B1B9

; -- quadro (14 bytes)  [dur=100 efe=$00/$00 fl=$00 mov=$02 vx=0 vy=0 rep=0]
D05_B1B9:
    .byte $64
    .word $87C6                         ; metasprite do Ken (Ryu $8809)
    .word $8FD1                         ; colisao do Ken (Ryu $9362)
    .byte $00,$00,$00,$02,$00,$00,$00
    .word $0000
