; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; Banco de PRG $3C (dados) — janela $8000-$9FFF — offset no arquivo $078010
;
.include "defs.inc"
.segment "BANK3C"

; ------------------------------------------------------------------------------------------------
; FICHAS DOS PERSONAGENS: 23 tabelas de 10 bytes (uma coluna por personagem), lidas por FighterLoadChar.
; Ordem das colunas: 0 RYU, 1 KEN, 2 CHUN LI, 3 GUILE, 4 BLANKA, 5 EHONDA, 6 BALROG, 7 SAGAT, 8 M.BISON, 9 ZANGIEF.
; Colunas 0 (Ryu) e 1 (Ken) preenchidas nas tabelas de ponteiros. A coluna 1 aponta para o banco de
; estados $05 (janela $A000) e para os frames/colisoes do banco $04.
CharDirTransLoTbl:
    .byte <(D01_A000)                           ; 8000  00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00   ; 8001
CharDirTransHiTbl:
    .byte >(D01_A000)                           ; 800A  A0
    .byte $A0,$00,$00,$00,$00,$00,$00,$00,$00   ; 800B              Ken: >D05_A000
CharAttackTransLoTbl:
    .byte <(D01_A012)                           ; 8014  12
    .byte $12,$00,$00,$00,$00,$00,$00,$00,$00   ; 8015              Ken: <D05_A012
CharAttackTransHiTbl:
    .byte >(D01_A012)                           ; 801E  A0
    .byte $A0,$00,$00,$00,$00,$00,$00,$00,$00   ; 801F              Ken: >D05_A012
CharSpecialTransLoTbl:
    .byte <(RyuSpcTrans)                        ; 8028  1A
    .byte $1A,$00,$00,$00,$00,$00,$00,$00,$00   ; 8029              Ken: <KenSpcTrans
CharSpecialTransHiTbl:
    .byte >(RyuSpcTrans)                        ; 8032  A0
    .byte $A0,$00,$00,$00,$00,$00,$00,$00,$00   ; 8033              Ken: >KenSpcTrans
CharGuardReactLoTbl:
    .byte <(D01_A026)                           ; 803C  26
    .byte $26,$00,$00,$00,$00,$00,$00,$00,$00   ; 803D              Ken: <D05_A026
CharGuardReactHiTbl:
    .byte >(D01_A026)                           ; 8046  A0
    .byte $A0,$00,$00,$00,$00,$00,$00,$00,$00   ; 8047              Ken: >D05_A026
CharHitReact1LoTbl:
    .byte <(D01_A03E)                           ; 8050  3E
    .byte $3E,$00,$00,$00,$00,$00,$00,$00,$00   ; 8051              Ken: <D05_A03E
CharHitReact1HiTbl:
    .byte >(D01_A03E)                           ; 805A  A0
    .byte $A0,$00,$00,$00,$00,$00,$00,$00,$00   ; 805B              Ken: >D05_A03E
CharHitReact2LoTbl:
    .byte <(D01_A056)                           ; 8064  56
    .byte $56,$00,$00,$00,$00,$00,$00,$00,$00   ; 8065              Ken: <D05_A056
CharHitReact2HiTbl:
    .byte >(D01_A056)                           ; 806E  A0
    .byte $A0,$00,$00,$00,$00,$00,$00,$00,$00   ; 806F              Ken: >D05_A056
CharHitReact0LoTbl:
    .byte <(D01_A06E)                           ; 8078  6E
    .byte $6E,$00,$00,$00,$00,$00,$00,$00,$00   ; 8079              Ken: <D05_A06E
CharHitReact0HiTbl:
    .byte >(D01_A06E)                           ; 8082  A0
    .byte $A0,$00,$00,$00,$00,$00,$00,$00,$00   ; 8083              Ken: >D05_A06E
CharHitReact12LoTbl:
    .byte <(D01_A086)                           ; 808C  86
    .byte $86,$00,$00,$00,$00,$00,$00,$00,$00   ; 808D              Ken: <D05_A086
CharHitReact12HiTbl:
    .byte >(D01_A086)                           ; 8096  A0
    .byte $A0,$00,$00,$00,$00,$00,$00,$00,$00   ; 8097              Ken: >D05_A086
CharCmdListLoTbl:
    .byte <(CmdKeyListRyu)                      ; 80A0  C0
    .byte $C0,$00,$00,$00,$00,$00,$00,$00,$00   ; 80A1              Ken: <CmdKeyListRyu
CharCmdListHiTbl:
    .byte >(CmdKeyListRyu)                      ; 80AA  E0
    .byte $E0,$00,$00,$00,$00,$00,$00,$00,$00   ; 80AB              Ken: >CmdKeyListRyu
CharAiScriptLoTbl:
    .byte <(D00_8E72)                           ; 80B4  72
    .byte $E0,$00,$00,$00,$00,$00,$00,$00,$00   ; 80B5              Ken: <D04_90E0 (stub de IA)
CharAiScriptHiTbl:
    .byte >(D00_8E72)                           ; 80BE  8E
    .byte $90,$00,$00,$00,$00,$00,$00,$00,$00   ; 80BF              Ken: >D04_90E0 (stub de IA)
CharStateBankTbl:
    .byte $01,$05,$01,$01,$01,$01,$01,$01,$00,$01; 80C8              coluna 1 (Ken) = banco de estados $05
CharFrameBankTbl:
    .byte $00,$04,$08,$0C,$10,$00,$00,$1C,$20,$24; 80D2
CharHitBoxBankTbl:
    .byte $00,$04,$00,$00,$00,$00,$00,$00,$20,$00; 80DC

; Ken: tripla 0 = azul (B) e tripla 1 = vermelho (A). O motor grava em zp_12 o
; botao de confirmacao (A -> 1, B -> 0) e usa esse indice como paleta do P1.
CharPal0FightTbl:
    .byte $0F,$36,$20,$0F,$36,$00,$0F,$36,$2D,$0F,$36,$31,$0F,$36,$02,$0F; 80E6
    .byte $36,$16,$0F,$36,$3D,$0F,$36,$12       ; 80F6
    .res 72, $FF                                ; 80FE
    .byte $16,$0F,$36,$19,$0F,$38,$11,$0F,$38,$10,$0F,$36,$FF,$FF,$FF,$FF; 8146
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF       ; 8156
CharPal1FightTbl:
    .byte $0F,$36,$16,$0F,$36,$11,$0F,$36,$27,$0F,$36,$20,$36,$0F,$27,$36; 815E
    .byte $0F,$27,$36,$0F,$27,$36,$0F,$27       ; 816E
    .res 72, $FF                                ; 8176
    .byte $16,$0F,$36,$19,$0F,$38,$11,$0F,$38,$10,$0F,$36,$FF,$FF,$FF,$FF; 81BE
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF       ; 81CE
CharPal0WinTbl:
    .byte $26,$36,$20,$26,$36,$00,$26,$36,$2D,$26,$36,$31,$26,$01,$27,$26; 81D6
    .byte $16,$27,$26,$3D,$27,$26,$11,$27,$26,$21,$20,$26,$25,$20,$26,$22; 81E6
    .byte $32,$26,$10,$20,$26,$19,$37,$26,$17,$37,$26,$01,$37,$26,$11,$37; 81F6
    .byte $28,$38,$30,$11,$21,$20,$07,$17,$20,$28,$38,$20; 8206
    .res 24, $FF                                ; 8212
    .byte $07,$17,$27,$08,$18,$28,$17,$27,$37,$18,$28,$38,$16,$26,$36,$1A; 822A
    .byte $27,$37,$11,$27,$37,$10,$26,$36,$17,$26,$36,$17,$26,$36,$17,$26; 823A
    .byte $36,$17,$26,$36                       ; 824A
CharPal1WinTbl:
    .byte $26,$17,$16,$26,$17,$11,$26,$17,$27,$26,$17,$20,$26,$36,$27,$26; 824E
    .byte $36,$27,$26,$36,$27,$26,$36,$27,$26,$21,$36,$26,$25,$36,$26,$22; 825E
    .byte $36,$26,$10,$37,$26,$27,$37,$26,$27,$37,$26,$27,$37,$26,$27,$37; 826E
    .byte $16,$38,$30,$28,$21,$20,$2D,$27,$20,$11,$38,$20; 827E
    .res 24, $FF                                ; 828A
    .byte $16,$17,$27,$16,$18,$28,$16,$27,$37,$16,$28,$38,$16,$26,$06,$1A; 82A2
    .byte $27,$0A,$11,$27,$01,$10,$26,$00,$17,$16,$36,$17,$00,$36,$17,$06; 82B2
    .byte $36,$17,$10,$36                       ; 82C2
CharPal0LoseTbl:
    .byte $26,$36,$20,$26,$36,$00,$26,$36,$2D,$26,$36,$31,$26,$01,$27,$26; 82C6
    .byte $16,$27,$26,$3D,$27,$26,$11,$27       ; 82D6
    .res 96, $FF                                ; 82DE
CharPal1LoseTbl:
    .byte $17,$26,$16,$17,$26,$11,$17,$26,$27,$17,$26,$20,$36,$26,$27,$36; 833E
    .byte $26,$27,$36,$26,$27,$36,$26,$27       ; 834E
    .res 96, $FF                                ; 8356
CharPal2Tbl:
    .byte $26,$36,$16,$26,$36,$16,$26,$36,$16,$26,$36,$16,$26,$36,$16,$26; 83B6
    .byte $36,$16,$26,$36,$16,$26,$36,$16       ; 83C6
    .res 96, $FF                                ; 83CE
PortraitWinTilesTbl:
    .byte $00,$CC,$44,$DD,$F5,$FD,$00,$CC,$00,$DC,$F0,$FD,$55,$DD,$00,$CC; 842E
    .byte $F0,$FC,$40,$CC,$55,$DD,$F5,$FD,$00,$CC,$54,$DC,$F5,$FD,$FF,$FF; 843E
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$44,$DD,$45,$DD,$F4,$FD; 844E
    .byte $00,$CC,$55,$CC,$F5,$FC,$55,$DD,$55,$CD,$F5,$FC; 845E
PortraitLoseTilesTbl:
    .byte $00,$CC,$88,$DE,$F5,$FD,$00,$CC,$00,$DC,$F0,$FD; 846A
    .res 48, $FF                                ; 8476
PortraitWinLayoutTbl:
    .word D00_8A9D                              ; 84A6  9D 8A
    .word D04_8A59                              ; 84A8  59 8A
    .word D08_8000                              ; 84AA  00 80
    .word D0C_8000                              ; 84AC  00 80
    .word D10_8000                              ; 84AE  00 80
    .byte $00,$00,$00,$00                       ; 84B0
    .word D1C_8000                              ; 84B4  00 80
    .word PortraitWinMBison                     ; 84B6  91 83
    .word D24_8000                              ; 84B8  00 80
PortraitLoseLayoutTbl:
    .word D00_8144                              ; 84BA  44 81
    .byte $F1,$90,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; 84BC              Ken: layout de derrota em $04:90F1
    .byte $00,$00                               ; 84CC
CharNameTbl:
    .byte $52,$59,$55,$20,$20,$20,$20,$20,$4B,$45,$4E,$20,$20,$20,$20,$20; 84CE              nomes dos 10 personagens, 8 caracteres cada
    .byte $43,$48,$55,$4E,$20,$4C,$49,$20,$47,$55,$49,$4C,$45,$20,$20,$20; 84DE
    .byte $42,$4C,$41,$4E,$4B,$41,$20,$20,$45,$48,$4F,$4E,$44,$41,$20,$20; 84EE
    .byte $42,$41,$4C,$52,$4F,$47,$20,$20,$53,$41,$47,$41,$54,$20,$20,$20; 84FE
    .byte $4D,$2E,$42,$49,$53,$4F,$4E,$20,$5A,$41,$4E,$47,$49,$45,$46,$20; 850E
CharNameLenTbl:
    .byte $03,$03,$07,$05,$06,$06,$06,$05,$07,$07; 851E
WinQuoteLine1:
    .byte $59,$4F,$55,$20,$4D,$55,$53,$54,$20,$44,$45,$46,$45,$41,$54,$20; 8528              frase do vencedor, 1a linha: 22 caracteres por personagem
    .byte $53,$48,$45,$4E,$47,$20,$41,$54,$54,$41,$43,$4B,$20,$4D,$45,$20; 8538
    .byte $49,$46,$20,$59,$4F,$55,$20,$44,$41,$52,$45,$20,$49,$27,$4D,$20; 8548
    .byte $54,$48,$45,$20,$53,$54,$52,$4F,$4E,$47,$45,$53,$54,$20,$20,$20; 8558
    .byte $20,$20,$41,$52,$45,$20,$59,$4F,$55,$20,$4D,$41,$4E,$20,$45,$4E; 8568
    .byte $4F,$55,$47,$48,$20,$20,$20,$20,$53,$45,$45,$49,$4E,$47,$20,$59; 8578
    .byte $4F,$55,$20,$49,$4E,$20,$41,$43,$54,$49,$4F,$4E,$20,$20,$43,$41; 8588
    .byte $4E,$27,$54,$20,$59,$4F,$55,$20,$44,$4F,$20,$20,$20,$20,$20,$20; 8598
    .byte $20,$20,$20,$20,$4D,$59,$20,$46,$49,$53,$54,$53,$20,$48,$41,$56; 85A8
    .byte $45,$20,$59,$4F,$55,$52,$20,$20,$20,$20,$59,$4F,$55,$20,$41,$52; 85B8
    .byte $45,$20,$4E,$4F,$54,$20,$41,$20,$57,$41,$52,$52,$49,$4F,$52,$20; 85C8
    .byte $59,$4F,$55,$20,$43,$41,$4E,$27,$54,$20,$43,$4F,$4D,$50,$41,$52; 85D8
    .byte $45,$20,$20,$20,$20,$20,$4D,$59,$20,$53,$54,$52,$45,$4E,$47,$54; 85E8
    .byte $48,$20,$49,$53,$20,$4D,$55,$43,$48,$20,$20,$20; 85F8
WinQuoteLine2:
    .byte $4C,$4F,$4E,$47,$20,$54,$4F,$20,$53,$54,$41,$4E,$44,$20,$41,$20; 8604              frase do vencedor, 2a linha
    .byte $43,$48,$41,$4E,$43,$45,$49,$20,$57,$49,$4C,$4C,$20,$43,$52,$55; 8614
    .byte $53,$48,$20,$59,$4F,$55,$20,$20,$20,$20,$20,$20,$57,$4F,$4D,$41; 8624
    .byte $4E,$20,$49,$4E,$20,$54,$48,$45,$20,$57,$4F,$52,$4C,$44,$20,$20; 8634
    .byte $20,$20,$54,$4F,$20,$46,$49,$47,$48,$54,$20,$57,$49,$54,$48,$20; 8644
    .byte $4D,$45,$3F,$20,$20,$20,$20,$20,$49,$53,$20,$41,$20,$4A,$4F,$4B; 8654
    .byte $45,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$42,$45; 8664
    .byte $54,$54,$45,$52,$20,$54,$48,$41,$4E,$20,$54,$48,$41,$54,$3F,$20; 8674
    .byte $20,$20,$20,$20,$42,$4C,$4F,$4F,$44,$20,$4F,$46,$20,$54,$48,$45; 8684
    .byte $4D,$20,$20,$20,$20,$20,$20,$20,$20,$20,$59,$4F,$55,$27,$52,$45; 8694
    .byte $20,$41,$20,$42,$45,$47,$49,$4E,$4E,$45,$52,$20,$20,$20,$20,$20; 86A4
    .byte $57,$49,$54,$48,$20,$4D,$59,$20,$50,$4F,$57,$45,$52,$53,$20,$20; 86B4
    .byte $20,$20,$20,$20,$20,$20,$47,$52,$45,$41,$54,$45,$52,$20,$54,$48; 86C4
    .byte $41,$4E,$20,$59,$4F,$55,$52,$53,$20,$20,$20,$20; 86D4
    .res 6432, $FF                              ; 86E0
