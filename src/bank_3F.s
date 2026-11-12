; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; Banco de PRG $3F (CODIGO) — janela $E000-$FFFF — offset no arquivo $07E010
;
.include "defs.inc"
.segment "BANK3F"

; <- jsr L3F_ED64, jsr MoveGrabEscape
; modos: luta
HitFreeze:
    lda a:MoveMode,x                            ; E000  BD 2E 00    congela o lutador atingido: salva movimento/velocidades/timer em ram_0312-031C e para no quadro atual por $0E quadros
    sta ram_0312,x                              ; E003  9D 12 03
    lda a:FighterVelXSub,x                      ; E006  BD 30 00
    sta ram_0314,x                              ; E009  9D 14 03
    lda a:FighterVelX,x                         ; E00C  BD 32 00
    sta ram_0316,x                              ; E00F  9D 16 03
    lda a:FighterVelYSub,x                      ; E012  BD 34 00
    sta ram_0318,x                              ; E015  9D 18 03
    lda a:FighterVelY,x                         ; E018  BD 36 00
    sta ram_031A,x                              ; E01B  9D 1A 03
    lda a:FighterAnimTimer,x                    ; E01E  BD 42 00
    sta ram_031C,x                              ; E021  9D 1C 03
    lda #$0E                                    ; E024  A9 0E
    sta a:FighterAnimTimer,x                    ; E026  9D 42 00
    lda #$01                                    ; E029  A9 01
    sta a:MoveMode,x                            ; E02B  9D 2E 00
    lda #$00                                    ; E02E  A9 00
    sta a:FighterVelXSub,x                      ; E030  9D 30 00
    sta a:FighterVelX,x                         ; E033  9D 32 00
    sta a:FighterVelYSub,x                      ; E036  9D 34 00
    sta a:FighterVelY,x                         ; E039  9D 36 00
    rts                                         ; E03C  60


; <- jsr L00_8F66, jsr L00_8FFC, jsr L00_9028, jsr L00_907B, jsr L00_90CA, jsr RyuAiAntiAir ... (+1)
; modos: luta
DistanceX:
    sec                                         ; E03D  38          A = |x do P2 - x do P1|
    lda FighterX+1                              ; E03E  A5 09
    sbc FighterX                                ; E040  E5 08
    bpl L3F_E048                                ; E042  10 04
    eor #$FF                                    ; E044  49 FF
    adc #$01                                    ; E046  69 01
L3F_E048:
    rts                                         ; E048  60


; <- jsr L00_8F5C, jsr L00_9028
; modos: luta
DistanceY:
    sec                                         ; E049  38
    lda FighterY+1                              ; E04A  A5 0D
    sbc FighterY                                ; E04C  E5 0C
    bpl L3F_E054                                ; E04E  10 04
    eor #$FF                                    ; E050  49 FF
    adc #$01                                    ; E052  69 01
L3F_E054:
    rts                                         ; E054  60

D3F_E055:
    .byte $05,$06,$07,$05,$06,$07               ; E055
D3F_E05B:
    .byte $D9,$D9,$D9                           ; E05B
D3F_E05E:
    .byte $17,$25,$00,$00,$00,$00               ; E05E
D3F_E064:
    .byte $27,$27,$27                           ; E064
CmdMotionTbl:
    .byte $04                                   ; E067              sequencias dos golpes especiais, 4 bytes por chave $00-$11 (bits do controle: 04 baixo, 01 frente, 02 tras, 08 cima, 80 A, 40 B; $00 encerra)
D3F_E068:
    .byte $01,$00,$00,$04,$01,$00,$00,$04,$01,$00,$00,$04,$01,$00,$00,$04; E068              CmdMotionTbl+1: lido em EB73 com o MESMO indice para ver o proximo byte da sequencia sem iny
    .byte $02,$00,$00,$04,$02,$00,$00,$01,$04,$01,$00,$01,$04,$01,$00,$02; E078
    .byte $01,$00,$00,$02,$01,$00,$00,$02,$01,$00,$00,$02,$01,$00,$00,$04; E088
    .byte $08,$00,$00,$04,$08,$00,$00,$80,$80,$80,$00,$40,$40,$40,$00,$01; E098
    .byte $04,$02,$08,$01,$00,$00,$00           ; E0A8
CmdKeyAttackTbl:
    .byte $00,$01,$02,$03,$00,$01,$02,$03,$00,$01,$02,$03,$00,$01,$00,$02; E0AF              botao exigido por chave, 17 bytes ($00-$10): 0 soco fraco, 1 soco forte, 2 chute fraco, 3 chute forte
    .byte $03                                   ; E0BF
CmdKeyListRyu:
    .byte $02,$03,$06,$07,$04,$05,$FF,$0A,$0B,$08,$09,$0C,$0D,$FF; E0C0              lista de especiais do Ryu (chaves, $FF = fim): hadouken ch $02/$03 (chute), shoryuken $06/$07 (chute), tatsumaki $04/$05 (soco); a POSICAO na lista vira CmdMoveIdx

; ------------------------------------------------------------------------------------------------
; MAQUINA DE ESTADOS DO LUTADOR (dirigida por dados; os dados ficam no banco FighterStateBank, em $A000).
; Percorre a lista de transicoes: cada no' E' um cabecalho de estado de 7 bytes — +0 numero da condicao
; (Cond* abaixo; >= $80 = incondicional), +1/+2 proxima alternativa (a lista encadeada), +3/+4 proximo
; estado na cadeia natural, +5 classe, +6 acertos do golpe. A primeira condicao verdadeira aplica O
; PROPRIO NO' como proximo estado (FighterNextPtr = endereco do no'; AnimAdvance entra nele).
; zp_DD marca a origem da busca: $04 = GuardRedirect, $02 = golpe por botao, $01 = golpe especial.
; Com zp_DD = $04 e classe $28/$30: pula o 1o no' quando ele e' o proprio estado atual.
; Com zp_DD = $02 e classe $70-$98 e no' != estado atual: pula o 1o no'. E com o bit 2 da classe zerado
; e CondOponenteLongeCostas: pula o 1o no' tambem (nao reage de costas).
; <- jmp L3F_E0F2, jmp L3F_EEB8, jmp GrabCheck, jmp TransViaTbl, jsr GuardRedirect
; modos: intro do round, luta
StateCheckTransitions:
    lda zp_DD                                   ; E0CE  A5 DD
    cmp #$04                                    ; E0D0  C9 04
    bne L3F_E0F2                                ; E0D2  D0 1E
    lda a:FighterState,x                        ; E0D4  BD 26 00
    and #$F8                                    ; E0D7  29 F8
    cmp #$28                                    ; E0D9  C9 28
    beq L3F_E11D                                ; E0DB  F0 40
    cmp #$30                                    ; E0DD  C9 30
    beq L3F_E11D                                ; E0DF  F0 3C
    lda zp_DC                                   ; E0E1  A5 DC
    cmp a:FighterStatePtrHi,x                   ; E0E3  DD 20 00
    bne L3F_E11D                                ; E0E6  D0 35
    lda zp_DB                                   ; E0E8  A5 DB
    cmp a:FighterStatePtrLo,x                   ; E0EA  DD 1E 00
    bne L3F_E11D                                ; E0ED  D0 2E
    jmp TransNextNode                           ; E0EF  4C 29 E1


L3F_E0F2:
    cmp #$02                                    ; E0F2  C9 02
    bne L3F_E111                                ; E0F4  D0 1B
    lda a:FighterState,x                        ; E0F6  BD 26 00
    and #$F8                                    ; E0F9  29 F8
    cmp #$70                                    ; E0FB  C9 70
    bcc L3F_E111                                ; E0FD  90 12
    cmp #$99                                    ; E0FF  C9 99
    bcs L3F_E111                                ; E101  B0 0E
    lda zp_DC                                   ; E103  A5 DC
    cmp a:FighterStatePtrHi,x                   ; E105  DD 20 00
    bne TransNextNode                           ; E108  D0 1F
    lda zp_DB                                   ; E10A  A5 DB
    cmp a:FighterStatePtrLo,x                   ; E10C  DD 1E 00
    bne TransNextNode                           ; E10F  D0 18
L3F_E111:
    lda a:FighterState,x                        ; E111  BD 26 00
    and #$04                                    ; E114  29 04
    bne L3F_E11D                                ; E116  D0 05
    jsr CondOponenteLongeCostas                 ; E118  20 B1 E1
    bne TransNextNode                           ; E11B  D0 0C
L3F_E11D:
    ldy #$00                                    ; E11D  A0 00
    lda (zp_DB),y                               ; E11F  B1 DB       [le bancos $01]
    bmi TransApply                              ; E121  30 18
    tay                                         ; E123  A8
    jsr StateCondDispatch                       ; E124  20 68 E1
    bne TransApply                              ; E127  D0 12

; <- jmp StateCheckTransitions
; modos: intro do round, luta
TransNextNode:
    ldy #$02                                    ; E129  A0 02       condicao falsa: segue para o no' +1/+2 e repete a busca (ponteiro 0 = fim da lista, nada muda)
    lda (zp_DB),y                               ; E12B  B1 DB       [le bancos $01]
    beq L3F_E167                                ; E12D  F0 38
    pha                                         ; E12F  48
    dey                                         ; E130  88
    lda (zp_DB),y                               ; E131  B1 DB       [le bancos $01]
    sta zp_DB                                   ; E133  85 DB
    pla                                         ; E135  68
    sta zp_DC                                   ; E136  85 DC
    jmp StateCheckTransitions                   ; E138  4C CE E0


; modos: luta
TransApply:
    lda a:FrameFlags,x                          ; E13B  BD 38 00    condicao verdadeira: o no' atual vira o proximo estado; AnimTimer=1 nas classes de golpe/reacao ($28-$40/$B0-$E0) a menos que o quadro tenha a flag bit 3
    and #$08                                    ; E13E  29 08
    bne L3F_E158                                ; E140  D0 16
    ldy #$05                                    ; E142  A0 05
    lda (zp_DB),y                               ; E144  B1 DB       [le bancos $01]
    and #$F8                                    ; E146  29 F8
    cmp #$28                                    ; E148  C9 28
    bcc L3F_E15D                                ; E14A  90 11
    cmp #$41                                    ; E14C  C9 41
    bcc L3F_E158                                ; E14E  90 08
    cmp #$B0                                    ; E150  C9 B0
    bcc L3F_E15D                                ; E152  90 09
    cmp #$E1                                    ; E154  C9 E1
    bcs L3F_E15D                                ; E156  B0 05
L3F_E158:
    lda #$01                                    ; E158  A9 01
    sta a:FighterAnimTimer,x                    ; E15A  9D 42 00
L3F_E15D:
    lda zp_DB                                   ; E15D  A5 DB
    sta a:FighterNextPtrLo,x                    ; E15F  9D 22 00
    lda zp_DC                                   ; E162  A5 DC
    sta a:FighterNextPtrHi,x                    ; E164  9D 24 00
L3F_E167:
    rts                                         ; E167  60


; <- jsr L3F_E0F2
; modos: intro do round, luta
StateCondDispatch:
    lda StateCondHi,y                           ; E168  B9 7D E1    [idx $00..$0B]
    pha                                         ; E16B  48
    lda StateCondLo,y                           ; E16C  B9 71 E1    [idx $00..$0B]
    pha                                         ; E16F  48
    rts                                         ; E170  60

StateCondLo:
    .byte <(CondOponenteAtaca-1)                ; E171  88          12 condicoes; cada entrada guarda endereco-1 (truque do RTS com pha/pha/rts)
    .byte <(CondOponenteLongeCostas-1)          ; E172  B0
    .byte <(CondOponentePerto-1)                ; E173  D5
    .byte <(CondEmPe-1)                         ; E174  EC
    .byte <(CondAgachado-1)                     ; E175  F2
    .byte <(CondNoAr-1)                         ; E176  F8
    .byte <(CondNoChaoOuVelX-1)                 ; E177  03
    .byte <(CondInputBaixo-1)                   ; E178  11
    .byte <(CondProjetilLivre-1)                ; E179  23
    .byte <(CondPodeAgarrar-1)                  ; E17A  2D
    .byte <(CondVitoria-1)                      ; E17B  70
    .byte <(CondRoundPerdido-1)                 ; E17C  95
StateCondHi:
    .byte >(CondOponenteAtaca-1)                ; E17D  E1
    .byte >(CondOponenteLongeCostas-1)          ; E17E  E1
    .byte >(CondOponentePerto-1)                ; E17F  E1
    .byte >(CondEmPe-1)                         ; E180  E1
    .byte >(CondAgachado-1)                     ; E181  E1
    .byte >(CondNoAr-1)                         ; E182  E1
    .byte >(CondNoChaoOuVelX-1)                 ; E183  E2
    .byte >(CondInputBaixo-1)                   ; E184  E2
    .byte >(CondProjetilLivre-1)                ; E185  E2
    .byte >(CondPodeAgarrar-1)                  ; E186  E2
    .byte >(CondVitoria-1)                      ; E187  E2
    .byte >(CondRoundPerdido-1)                 ; E188  E2

; <- tabela StateCondLo
; modos: luta
CondOponenteAtaca:
    lda a:FighterState,x                        ; E189  BD 26 00    verdadeiro se EU estou em pe/agachado (classe & 3) E o oponente esta em classe de reacao ($70-$98), de golpe ($B0-$E0) ou com projetil no ar (dele)
    and #$03                                    ; E18C  29 03
    bne L3F_E191                                ; E18E  D0 01
    rts                                         ; E190  60


L3F_E191:
    txa                                         ; E191  8A
    eor #$01                                    ; E192  49 01
    tay                                         ; E194  A8
    lda a:FighterState,y                        ; E195  B9 26 00
    and #$F8                                    ; E198  29 F8
    cmp #$70                                    ; E19A  C9 70
    bcc L3F_E1AD                                ; E19C  90 0F
    cmp #$99                                    ; E19E  C9 99
    bcc L3F_E1AA                                ; E1A0  90 08
    cmp #$B0                                    ; E1A2  C9 B0
    bcc L3F_E1AD                                ; E1A4  90 07
    cmp #$E1                                    ; E1A6  C9 E1
    bcs L3F_E1AD                                ; E1A8  B0 03
L3F_E1AA:
    lda #$01                                    ; E1AA  A9 01
    rts                                         ; E1AC  60


L3F_E1AD:
    lda a:ProjX,y                               ; E1AD  B9 7B 00
    rts                                         ; E1B0  60


; <- jsr L3F_E0F2, tabela StateCondLo
; modos: intro do round, luta
CondOponenteLongeCostas:
    txa                                         ; E1B1  8A          verdadeiro se o oponente esta a |dx| >= $0F E eu de costas para ele: devolve $40 (e' o bit 6 de FighterFlip) para virar, 0 se esta encarando ou colado
    eor #$01                                    ; E1B2  49 01
    tay                                         ; E1B4  A8
    sec                                         ; E1B5  38
    lda FighterX,x                              ; E1B6  B5 08
    sbc a:FighterX,y                            ; E1B8  F9 08 00
    beq L3F_E1D5                                ; E1BB  F0 18
    bpl L3F_E1C3                                ; E1BD  10 04
    eor #$FF                                    ; E1BF  49 FF
    adc #$01                                    ; E1C1  69 01
L3F_E1C3:
    cmp #$0F                                    ; E1C3  C9 0F
    bcs L3F_E1CA                                ; E1C5  B0 03
    lda #$00                                    ; E1C7  A9 00
    rts                                         ; E1C9  60


L3F_E1CA:
    lda FighterX,x                              ; E1CA  B5 08
    cmp a:FighterX,y                            ; E1CC  D9 08 00
    lda FighterFlip,x                           ; E1CF  B5 04
    bcc L3F_E1D5                                ; E1D1  90 02
    eor #$40                                    ; E1D3  49 40
L3F_E1D5:
    rts                                         ; E1D5  60


; <- tabela StateCondLo
; modos: luta
CondOponentePerto:
    sec                                         ; E1D6  38          verdadeiro se |dx| < $21
    lda FighterX                                ; E1D7  A5 08
    sbc FighterX+1                              ; E1D9  E5 09
    bne L3F_E1E0                                ; E1DB  D0 03
    lda #$01                                    ; E1DD  A9 01       (nt)
    rts                                         ; E1DF  60          (nt)


L3F_E1E0:
    bpl L3F_E1E6                                ; E1E0  10 04
    eor #$FF                                    ; E1E2  49 FF
    adc #$01                                    ; E1E4  69 01
L3F_E1E6:
    cmp #$21                                    ; E1E6  C9 21
    bcc L3F_E1EC                                ; E1E8  90 02
    lda #$00                                    ; E1EA  A9 00
L3F_E1EC:
    rts                                         ; E1EC  60


; <- tabela StateCondLo
; modos: luta
CondEmPe:
    lda a:FighterState,x                        ; E1ED  BD 26 00    bit 0 da classe = postura em pe
    and #$01                                    ; E1F0  29 01
    rts                                         ; E1F2  60


; <- tabela StateCondLo
; modos: luta
CondAgachado:
    lda a:FighterState,x                        ; E1F3  BD 26 00    bit 1 da classe = postura agachado
    and #$02                                    ; E1F6  29 02
    rts                                         ; E1F8  60


; <- tabela StateCondLo
; modos: luta
CondNoAr:
    lda FloorY                                  ; E1F9  AD BA 03    verdadeiro se FighterY < FloorY (acima do chao)
    sec                                         ; E1FC  38
    sbc FighterY,x                              ; E1FD  F5 0C
    bpl L3F_E203                                ; E1FF  10 02
    lda #$00                                    ; E201  A9 00       (nt)
L3F_E203:
    rts                                         ; E203  60


; <- tabela StateCondLo
; modos: luta
CondNoChaoOuVelX:
    lda FloorY                                  ; E204  AD BA 03    verdadeiro se FighterY = FloorY ou VelX/VelXSub != 0 (esta no chao ou deslizando)
    cmp FighterY,x                              ; E207  D5 0C
    beq L3F_E211                                ; E209  F0 06
    lda a:FighterVelX,x                         ; E20B  BD 32 00
    ora a:FighterVelXSub,x                      ; E20E  1D 30 00
L3F_E211:
    rts                                         ; E211  60


; <- tabela StateCondLo
; modos: luta
CondInputBaixo:
    lda InputDir,x                              ; E212  B5 86       verdadeiro se InputDir = $08/$0B/$0C (baixo reto ou diagonal-baixa); devolve o proprio InputDir
    cmp #$08                                    ; E214  C9 08
    beq L3F_E222                                ; E216  F0 0A
    cmp #$0B                                    ; E218  C9 0B
    beq L3F_E222                                ; E21A  F0 06
    cmp #$0C                                    ; E21C  C9 0C
    beq L3F_E222                                ; E21E  F0 02
    lda #$00                                    ; E220  A9 00
L3F_E222:
    tay                                         ; E222  A8
    rts                                         ; E223  60


; <- tabela StateCondLo
; modos: luta
CondProjetilLivre:
    lda ProjX,x                                 ; E224  B5 7B       verdadeiro se a vaga de projetil deste lutador esta livre (zp_7B dele = 0)
    beq L3F_E22B                                ; E226  F0 03
    lda #$00                                    ; E228  A9 00
    rts                                         ; E22A  60


L3F_E22B:
    lda #$01                                    ; E22B  A9 01
    rts                                         ; E22D  60


; <- tabela StateCondLo
; modos: luta
CondPodeAgarrar:
    sec                                         ; E22E  38          |dx| < $18, os dois no chao, InputDir = frente/tras ($05/$06) e classe do oponente < $30 ou $50-$9F (estados de virar $A0-$A9 nao contam, nt)
    lda FighterX                                ; E22F  A5 08
    sbc FighterX+1                              ; E231  E5 09
    bpl L3F_E239                                ; E233  10 04
    eor #$FF                                    ; E235  49 FF
    adc #$01                                    ; E237  69 01
L3F_E239:
    cmp #$18                                    ; E239  C9 18
    bcs L3F_E26E                                ; E23B  B0 31
    lda FloorY                                  ; E23D  AD BA 03
    cmp FighterY                                ; E240  C5 0C
    bne L3F_E26E                                ; E242  D0 2A
    cmp FighterY+1                              ; E244  C5 0D
    bne L3F_E26E                                ; E246  D0 26
    lda InputDir,x                              ; E248  B5 86
    cmp #$05                                    ; E24A  C9 05
    beq L3F_E252                                ; E24C  F0 04
    cmp #$06                                    ; E24E  C9 06
    bne L3F_E26E                                ; E250  D0 1C
L3F_E252:
    txa                                         ; E252  8A
    eor #$01                                    ; E253  49 01
    tay                                         ; E255  A8
    lda a:FighterState,y                        ; E256  B9 26 00
    and #$F8                                    ; E259  29 F8
    cmp #$30                                    ; E25B  C9 30
    bcc L3F_E26B                                ; E25D  90 0C
    cmp #$50                                    ; E25F  C9 50
    bcc L3F_E26E                                ; E261  90 0B
    cmp #$A0                                    ; E263  C9 A0
    bcc L3F_E26B                                ; E265  90 04
    cmp #$A9                                    ; E267  C9 A9       (nt)
    bcc L3F_E26E                                ; E269  90 03       (nt)
L3F_E26B:
    lda #$01                                    ; E26B  A9 01
    rts                                         ; E26D  60


L3F_E26E:
    lda #$00                                    ; E26E  A9 00
    rts                                         ; E270  60


; <- tabela StateCondLo
; modos: intro do round, luta
CondVitoria:
    cpx a:RoundResult                           ; E271  EC B9 00    verdadeiro se RoundResult = este lutador E o oponente esta caido (classe >= $F0) E nao ha projeteis no ar E o canal de voz esta livre
    bne L3F_E293                                ; E274  D0 1D
    txa                                         ; E276  8A
    eor #$01                                    ; E277  49 01
    tay                                         ; E279  A8
    lda a:FighterState,y                        ; E27A  B9 26 00
    cmp #$F0                                    ; E27D  C9 F0
    bcc L3F_E293                                ; E27F  90 12
    lda ProjX                                   ; E281  A5 7B
    bne L3F_E293                                ; E283  D0 0E
    lda ProjX+1                                 ; E285  A5 7C
    bne L3F_E293                                ; E287  D0 0A
    lda SND_CHN                                 ; E289  AD 15 40
    and #$10                                    ; E28C  29 10
    bne L3F_E293                                ; E28E  D0 03
    lda #$01                                    ; E290  A9 01
    rts                                         ; E292  60


L3F_E293:
    lda #$00                                    ; E293  A9 00
    rts                                         ; E295  60


; <- tabela StateCondLo
; modos: intro do round, luta
CondRoundPerdido:
    cpx a:RoundResult                           ; E296  EC B9 00    verdadeiro se RoundResult != este lutador E RoundResult != $FF (round encerrado; vale para empate)
    beq L3F_E2A3                                ; E299  F0 08
    bit a:RoundResult                           ; E29B  2C B9 00
    bmi L3F_E2A3                                ; E29E  30 03
    lda #$01                                    ; E2A0  A9 01
    rts                                         ; E2A2  60


L3F_E2A3:
    lda #$00                                    ; E2A3  A9 00
    rts                                         ; E2A5  60


; ------------------------------------------------------------------------------------------------
; UM PASSO DA ANIMACAO (todo quadro, antes do teste de colisao):
; - efeito $0B do quadro atual -> dispara o projetil (ProjLaunch, parametro = quadro +5)
; - FighterNextPtr != 0 -> entra no novo estado escolhido por TransApply: grava classe (+5) e
; acertos (+6), primeiro quadro = no' + 7. Caso especial: estado $49 com zp_62 != 0 usa a
; alternativa +1/+2 do estado atual. Efeito $20 do quadro -> efeito sonoro (SfxPlay).
; - sem proximo estado e ram_031C != 0 -> restaura o movimento congelado pelo hit-freeze.
; - senao avanca os quadros: +11 (repeticoes do laco) > 0 -> decrementa e desvia para +14/+15;
; zera -> +12/+13 (proximo quadro); +12/+13 = 0 -> StateAdvance (cadeia natural +3/+4;
; classe $30 com HP <= dano pendente usa +1/+2, ou seja corta para o estado de dano).
; - KO no ar (HP <= dano pendente, acima do chao): HitStop = $78 e vozes de KO.
; <- jsr L3F_EFCB
; modos: intro do round, luta, fim do round
AnimAdvance:
    lda a:EffectType,x                          ; E2A6  BD 3C 00
    cmp #$0B                                    ; E2A9  C9 0B
    bne L3F_E2B3                                ; E2AB  D0 06
    lda a:EffectParam,x                         ; E2AD  BD 3A 00
    jsr ProjLaunch                              ; E2B0  20 37 E8
L3F_E2B3:
    lda a:FighterNextPtrHi,x                    ; E2B3  BD 24 00
    beq FreezeRestore                           ; E2B6  F0 49
    ldy a:FighterState,x                        ; E2B8  BC 26 00
    cpy #$49                                    ; E2BB  C0 49
    bne L3F_E2D8                                ; E2BD  D0 19
    ldy a:zp_62,x                               ; E2BF  BC 62 00
    beq L3F_E2D8                                ; E2C2  F0 14
    lda a:FighterStatePtrHi,x                   ; E2C4  BD 20 00
    sta zp_D8                                   ; E2C7  85 D8
    lda a:FighterStatePtrLo,x                   ; E2C9  BD 1E 00
    sta zp_D7                                   ; E2CC  85 D7
    ldy #$01                                    ; E2CE  A0 01
    lda (zp_D7),y                               ; E2D0  B1 D7       [le bancos $01]
    sta a:FighterNextPtrLo,x                    ; E2D2  9D 22 00
    iny                                         ; E2D5  C8
    lda (zp_D7),y                               ; E2D6  B1 D7       [le bancos $01]
L3F_E2D8:
    sta zp_DA                                   ; E2D8  85 DA
    sta zp_D8                                   ; E2DA  85 D8
    sta a:FighterStatePtrHi,x                   ; E2DC  9D 20 00
    lda a:FighterNextPtrLo,x                    ; E2DF  BD 22 00
    sta zp_D7                                   ; E2E2  85 D7
    sta a:FighterStatePtrLo,x                   ; E2E4  9D 1E 00
    clc                                         ; E2E7  18
    adc #$07                                    ; E2E8  69 07
    sta zp_D9                                   ; E2EA  85 D9
    bcc L3F_E2F0                                ; E2EC  90 02
    inc zp_DA                                   ; E2EE  E6 DA
L3F_E2F0:
    ldy #$05                                    ; E2F0  A0 05
    lda (zp_D7),y                               ; E2F2  B1 D7       [le bancos $01]
    jsr StateSetByte                            ; E2F4  20 7F E4
    ldy #$06                                    ; E2F7  A0 06
    lda (zp_D7),y                               ; E2F9  B1 D7       [le bancos $01]
    sta a:AttackHitsLeft,x                      ; E2FB  9D 28 00
    jmp FrameEnter                              ; E2FE  4C B8 E3


; modos: intro do round, luta, fim do round
FreezeRestore:
    lda ram_031C,x                              ; E301  BD 1C 03    devolve as velocidades/timer salvos pelo hit-freeze (ram_0312-031C)
    beq L3F_E33C                                ; E304  F0 36
    sta a:FighterAnimTimer,x                    ; E306  9D 42 00
    lda ram_0312,x                              ; E309  BD 12 03
    sta a:MoveMode,x                            ; E30C  9D 2E 00
    lda ram_0314,x                              ; E30F  BD 14 03
    sta a:FighterVelXSub,x                      ; E312  9D 30 00
    lda ram_0316,x                              ; E315  BD 16 03
    sta a:FighterVelX,x                         ; E318  9D 32 00
    lda ram_0318,x                              ; E31B  BD 18 03
    sta a:FighterVelYSub,x                      ; E31E  9D 34 00
    lda ram_031A,x                              ; E321  BD 1A 03
    sta a:FighterVelY,x                         ; E324  9D 36 00
    lda #$00                                    ; E327  A9 00
    sta ram_031C,x                              ; E329  9D 1C 03
    sta ram_0312,x                              ; E32C  9D 12 03
    sta ram_0314,x                              ; E32F  9D 14 03
    sta ram_0316,x                              ; E332  9D 16 03
    sta ram_0318,x                              ; E335  9D 18 03
    sta ram_031A,x                              ; E338  9D 1A 03
    rts                                         ; E33B  60


L3F_E33C:
    lda a:LoopRepeat,x                          ; E33C  BD 44 00
    beq L3F_E361                                ; E33F  F0 20
    ldy #$0B                                    ; E341  A0 0B
    lda (zp_D5),y                               ; E343  B1 D5       [le bancos $01]
    bne L3F_E34E                                ; E345  D0 07
    ldy #$0C                                    ; E347  A0 0C
    lda (zp_D5),y                               ; E349  B1 D5       [le bancos $01]
    jmp AnimAdvanceEnter                        ; E34B  4C 57 E3


L3F_E34E:
    dec a:LoopRepeat,x                          ; E34E  DE 44 00
    beq L3F_E361                                ; E351  F0 0E
    ldy #$0E                                    ; E353  A0 0E
    lda (zp_D5),y                               ; E355  B1 D5       [le bancos $01]

; <- jmp L3F_E33C
; modos: luta
AnimAdvanceEnter:
    sta zp_D9                                   ; E357  85 D9       entra num quadro cujo ponteiro vem em A (lo) e no byte seguinte (hi), nos desvios do laco de AnimAdvance
    iny                                         ; E359  C8
    lda (zp_D5),y                               ; E35A  B1 D5       [le bancos $01]
    sta zp_DA                                   ; E35C  85 DA
    jmp FrameEnterCommon                        ; E35E  4C BF E3


L3F_E361:
    ldy #$0D                                    ; E361  A0 0D
    lda (zp_D5),y                               ; E363  B1 D5       [le bancos $01]
    beq StateAdvance                            ; E365  F0 0A
    sta zp_DA                                   ; E367  85 DA
    dey                                         ; E369  88
    lda (zp_D5),y                               ; E36A  B1 D5       [le bancos $01]
    sta zp_D9                                   ; E36C  85 D9
    jmp FrameEnter                              ; E36E  4C B8 E3


; modos: luta
StateAdvance:
    lda a:FighterStatePtrLo,x                   ; E371  BD 1E 00    fim da animacao: passa para o estado +3/+4 do cabecalho (cadeia natural); classe $30 com HP <= dano pendente usa a alternativa +1/+2
    sta zp_D7                                   ; E374  85 D7
    lda a:FighterStatePtrHi,x                   ; E376  BD 20 00
    sta zp_D8                                   ; E379  85 D8
    ldy #$03                                    ; E37B  A0 03
    lda a:FighterState,x                        ; E37D  BD 26 00
    cmp #$30                                    ; E380  C9 30
    bne L3F_E38F                                ; E382  D0 0B
    lda FighterHP,x                             ; E384  B5 0E
    bmi L3F_E38D                                ; E386  30 05
    cmp a:FighterDmgPending,x                   ; E388  DD 14 00
    bcs L3F_E38F                                ; E38B  B0 02
L3F_E38D:
    ldy #$01                                    ; E38D  A0 01
L3F_E38F:
    lda (zp_D7),y                               ; E38F  B1 D7       [le bancos $01]
    sta a:FighterStatePtrLo,x                   ; E391  9D 1E 00
    clc                                         ; E394  18
    adc #$07                                    ; E395  69 07
    sta zp_D9                                   ; E397  85 D9
    iny                                         ; E399  C8
    lda (zp_D7),y                               ; E39A  B1 D7       [le bancos $01]
    sta a:FighterStatePtrHi,x                   ; E39C  9D 20 00
    sta zp_D8                                   ; E39F  85 D8
    adc #$00                                    ; E3A1  69 00
    sta zp_DA                                   ; E3A3  85 DA
    lda a:FighterStatePtrLo,x                   ; E3A5  BD 1E 00
    sta zp_D7                                   ; E3A8  85 D7
    ldy #$05                                    ; E3AA  A0 05
    lda (zp_D7),y                               ; E3AC  B1 D7       [le bancos $01]
    jsr StateSetByte                            ; E3AE  20 7F E4
    ldy #$06                                    ; E3B1  A0 06       cabecalho +6 (acertos do golpe)
    lda (zp_D7),y                               ; E3B3  B1 D7       [le bancos $01]
    sta a:AttackHitsLeft,x                      ; E3B5  9D 28 00

; <- jmp AnimAdvance, jmp L3F_E361
; modos: intro do round, luta, fim do round
FrameEnter:
    ldy #$0B                                    ; E3B8  A0 0B       entrada do 1o quadro do novo estado: carrega zp_44 com as repeticoes do laco (quadro +11)
    lda (zp_D9),y                               ; E3BA  B1 D9       [le bancos $01]
    sta a:LoopRepeat,x                          ; E3BC  9D 44 00

; <- jmp L3F_E34E
; modos: intro do round, luta, fim do round
FrameEnterCommon:
    ldy #$08                                    ; E3BF  A0 08       entrada de qualquer quadro: movimento (+8), grava FramePtr, efeito (+5/+6), AnimTimer (+0), flags (+7)
    lda (zp_D9),y                               ; E3C1  B1 D9       [le bancos $01]
    sta a:MoveMode,x                            ; E3C3  9D 2E 00
    jsr MoveVelSetup                            ; E3C6  20 C2 E4
    lda zp_D9                                   ; E3C9  A5 D9
    sta a:FighterFramePtrLo,x                   ; E3CB  9D 2A 00
    sta zp_D5                                   ; E3CE  85 D5
    lda zp_DA                                   ; E3D0  A5 DA
    sta a:FighterFramePtrHi,x                   ; E3D2  9D 2C 00
    sta zp_D6                                   ; E3D5  85 D6
    lda #$00                                    ; E3D7  A9 00
    sta a:HitThisFrame,x                        ; E3D9  9D 3E 00
    sta a:FighterNextPtrLo,x                    ; E3DC  9D 22 00
    sta a:FighterNextPtrHi,x                    ; E3DF  9D 24 00
    ldy #$05                                    ; E3E2  A0 05
    lda (zp_D9),y                               ; E3E4  B1 D9       [le bancos $01]
    sta a:EffectParam,x                         ; E3E6  9D 3A 00
    ldy #$06                                    ; E3E9  A0 06
    lda (zp_D9),y                               ; E3EB  B1 D9       [le bancos $01]
    sta a:EffectType,x                          ; E3ED  9D 3C 00
    ldy #$00                                    ; E3F0  A0 00
    lda (zp_D9),y                               ; E3F2  B1 D9       [le bancos $01]
    sta a:FighterAnimTimer,x                    ; E3F4  9D 42 00
    ldy #$07                                    ; E3F7  A0 07
    lda (zp_D9),y                               ; E3F9  B1 D9       [le bancos $01]
    sta a:FrameFlags,x                          ; E3FB  9D 38 00
    lda a:EffectType,x                          ; E3FE  BD 3C 00
    cmp #$20                                    ; E401  C9 20
    bne L3F_E420                                ; E403  D0 1B
    lda a:EffectParam,x                         ; E405  BD 3A 00
    sta zp_DB                                   ; E408  85 DB
    stx zp_DC                                   ; E40A  86 DC
    farcall SfxPlay                             ; E40C  A9 E4 48 A9 1D 48 A9 3F .. -> 37:E401
    ldx zp_DC                                   ; E41E  A6 DC
L3F_E420:
    lda FighterHP,x                             ; E420  B5 0E
    bmi L3F_E429                                ; E422  30 05
    cmp a:FighterDmgPending,x                   ; E424  DD 14 00
    bcs L3F_E47E                                ; E427  B0 55
L3F_E429:
    lda FighterY,x                              ; E429  B5 0C
    cmp FloorY                                  ; E42B  CD BA 03
    bcs L3F_E47E                                ; E42E  B0 4E
    lda a:MoveMode,x                            ; E430  BD 2E 00
    cmp #$02                                    ; E433  C9 02
    bcc L3F_E47E                                ; E435  90 47
    lda #$78                                    ; E437  A9 78
    sta HitStop                                 ; E439  8D 0C 04
    stx zp_D7                                   ; E43C  86 D7
    ldy #$14                                    ; E43E  A0 14
    lda FighterChar,x                           ; E440  B5 00
    cmp #$02                                    ; E442  C9 02
    bne L3F_E448                                ; E444  D0 02
    ldy #$16                                    ; E446  A0 16       (nt)
L3F_E448:
    sty VoiceQueued                             ; E448  8C 5E 04
    farcall VoicePlay                           ; E44B  A9 E4 48 A9 5C 48 A9 3F .. -> 37:E427
    ldx zp_D7                                   ; E45D  A6 D7
    ldy #$15                                    ; E45F  A0 15
    lda FighterChar,x                           ; E461  B5 00
    cmp #$02                                    ; E463  C9 02
    bne L3F_E469                                ; E465  D0 02
    ldy #$17                                    ; E467  A0 17       (nt)
L3F_E469:
    sty VoiceQueued                             ; E469  8C 5E 04
    txa                                         ; E46C  8A
    eor #$01                                    ; E46D  49 01
    cmp a:RoundResult                           ; E46F  CD B9 00
    beq L3F_E47E                                ; E472  F0 0A
    bit a:RoundResult                           ; E474  2C B9 00
    bmi L3F_E47B                                ; E477  30 02
    lda #$02                                    ; E479  A9 02       (nt)
L3F_E47B:
    sta a:RoundResult                           ; E47B  8D B9 00
L3F_E47E:
    rts                                         ; E47E  60


; Grava o byte de estado (cabecalho +5) em FighterState e dispara o som da classe do estado:
; classes $70-$98 -> efeito sonoro (banco $37), classes $A0-$E0 -> voz do lutador (VoicePlayFighter).
; <- jsr AnimAdvance, jsr StateAdvance
; modos: luta
StateSetByte:
    sta a:FighterState,x                        ; E47F  9D 26 00
    and #$F8                                    ; E482  29 F8
    cmp #$99                                    ; E484  C9 99
    bcs L3F_E4A1                                ; E486  B0 19
    cmp #$70                                    ; E488  C9 70
    bcc L3F_E4C1                                ; E48A  90 35
    sbc #$70                                    ; E48C  E9 70
    lsr a                                       ; E48E  4A
    lsr a                                       ; E48F  4A
    lsr a                                       ; E490  4A
    sta zp_DC                                   ; E491  85 DC
    stx zp_DB                                   ; E493  86 DB
    farjmp SfxPlayByState                       ; E495  A9 3F 48 A9 37 A2 E4 A0 .. -> 37:E40B


L3F_E4A1:
    cmp #$E1                                    ; E4A1  C9 E1
    bcs L3F_E4C1                                ; E4A3  B0 1C
    cmp #$A0                                    ; E4A5  C9 A0
    bcc L3F_E4C1                                ; E4A7  90 18
    sbc #$A0                                    ; E4A9  E9 A0
    beq L3F_E4AF                                ; E4AB  F0 02
    sbc #$08                                    ; E4AD  E9 08
L3F_E4AF:
    lsr a                                       ; E4AF  4A
    lsr a                                       ; E4B0  4A
    sta zp_DC                                   ; E4B1  85 DC
    stx zp_DB                                   ; E4B3  86 DB
    farjmp VoicePlayFighter                     ; E4B5  A9 3F 48 A9 37 A2 E4 A0 .. -> 37:E43C


L3F_E4C1:
    rts                                         ; E4C1  60


; <- jsr StateAdvance
; modos: intro do round, luta, fim do round
MoveVelSetup:
    ldy a:MoveMode,x                            ; E4C2  BC 2E 00    despacha pelo modo de movimento do quadro (+8): 0/1 absoluta, 2/3 aceleracao, 4/5 subpixel
    lda D3F_E4D4,y                              ; E4C5  B9 D4 E4    [idx $00..$05]
    pha                                         ; E4C8  48
    lda D3F_E4CE,y                              ; E4C9  B9 CE E4    [idx $00..$05]
    pha                                         ; E4CC  48
    rts                                         ; E4CD  60

D3F_E4CE:
    .byte <(MoveVelAbs-1)                       ; E4CE  D9
    .byte <(MoveVelAbs-1)                       ; E4CF  D9
    .byte <(MoveVelAccel-1)                     ; E4D0  96
    .byte <(MoveVelAccel-1)                     ; E4D1  96
    .byte <(MoveVelSubpixel-1)                  ; E4D2  F0
    .byte <(MoveVelSubpixel-1)                  ; E4D3  F0
D3F_E4D4:
    .byte >(MoveVelAbs-1)                       ; E4D4  E4
    .byte >(MoveVelAbs-1)                       ; E4D5  E4
    .byte >(MoveVelAccel-1)                     ; E4D6  E5
    .byte >(MoveVelAccel-1)                     ; E4D7  E5
    .byte >(MoveVelSubpixel-1)                  ; E4D8  E4
    .byte >(MoveVelSubpixel-1)                  ; E4D9  E4

; <- tabela D3F_E4CE
; modos: luta
MoveVelAbs:
    lda #$00                                    ; E4DA  A9 00       modos 0/1: VelX/VelY do quadro (+9/+10) sao a velocidade nova, direto
    sta a:FighterVelXSub,x                      ; E4DC  9D 30 00
    sta a:FighterVelYSub,x                      ; E4DF  9D 34 00
    ldy #$09                                    ; E4E2  A0 09
    lda (zp_D9),y                               ; E4E4  B1 D9       [le bancos $01]
    sta a:FighterVelX,x                         ; E4E6  9D 32 00
    ldy #$0A                                    ; E4E9  A0 0A
    lda (zp_D9),y                               ; E4EB  B1 D9       [le bancos $01]
    sta a:FighterVelY,x                         ; E4ED  9D 36 00
    rts                                         ; E4F0  60


; <- jmp L3F_E5A9, tabela D3F_E4CE
; modos: intro do round, luta, fim do round
MoveVelSubpixel:
    lda #$00                                    ; E4F1  A9 00       modos 4/5: velocidade do quadro dividida por 16 — inteiro em VelX e resto<<4 em VelXSub
    sta a:FighterVelXSub,x                      ; E4F3  9D 30 00
    sta a:FighterVelYSub,x                      ; E4F6  9D 34 00
    ldy #$09                                    ; E4F9  A0 09
    lda (zp_D9),y                               ; E4FB  B1 D9       [le bancos $01]
    beq L3F_E517                                ; E4FD  F0 18
    sta zp_DB                                   ; E4FF  85 DB
    lsr a                                       ; E501  4A
    ror a:FighterVelXSub,x                      ; E502  7E 30 00
    lsr a                                       ; E505  4A
    ror a:FighterVelXSub,x                      ; E506  7E 30 00
    lsr a                                       ; E509  4A
    ror a:FighterVelXSub,x                      ; E50A  7E 30 00
    lsr a                                       ; E50D  4A
    ror a:FighterVelXSub,x                      ; E50E  7E 30 00
    bit zp_DB                                   ; E511  24 DB
    bpl L3F_E517                                ; E513  10 02
    ora #$F0                                    ; E515  09 F0
L3F_E517:
    sta a:FighterVelX,x                         ; E517  9D 32 00
    ldy #$0A                                    ; E51A  A0 0A
    lda (zp_D9),y                               ; E51C  B1 D9       [le bancos $01]
    beq L3F_E538                                ; E51E  F0 18
    sta zp_DB                                   ; E520  85 DB
    lsr a                                       ; E522  4A
    ror a:FighterVelYSub,x                      ; E523  7E 34 00
    lsr a                                       ; E526  4A
    ror a:FighterVelYSub,x                      ; E527  7E 34 00
    lsr a                                       ; E52A  4A
    ror a:FighterVelYSub,x                      ; E52B  7E 34 00
    lsr a                                       ; E52E  4A
    ror a:FighterVelYSub,x                      ; E52F  7E 34 00
    bit zp_DB                                   ; E532  24 DB
    bpl L3F_E538                                ; E534  10 02
    ora #$F0                                    ; E536  09 F0
L3F_E538:
    sta a:FighterVelY,x                         ; E538  9D 36 00
    rts                                         ; E53B  60


; <- jmp MoveVelAccel, jmp L3F_E5A2
; modos: luta
MoveVelAdd:
    lda #$00                                    ; E53C  A9 00       soma com sinal vel/16 a velocidade atual (VelX, VelXSub e VelY)
    sta zp_DC                                   ; E53E  85 DC
    sta zp_DE                                   ; E540  85 DE
    ldy #$09                                    ; E542  A0 09
    lda (zp_D9),y                               ; E544  B1 D9       [le bancos $01]
    sta zp_DB                                   ; E546  85 DB
    lsr a                                       ; E548  4A
    ror zp_DC                                   ; E549  66 DC
    lsr a                                       ; E54B  4A
    ror zp_DC                                   ; E54C  66 DC
    lsr a                                       ; E54E  4A
    ror zp_DC                                   ; E54F  66 DC
    lsr a                                       ; E551  4A
    ror zp_DC                                   ; E552  66 DC
    bit zp_DB                                   ; E554  24 DB
    bpl L3F_E55A                                ; E556  10 02
    ora #$F0                                    ; E558  09 F0
L3F_E55A:
    sta zp_DB                                   ; E55A  85 DB
    lda zp_DC                                   ; E55C  A5 DC
    adc a:FighterVelXSub,x                      ; E55E  7D 30 00
    sta a:FighterVelXSub,x                      ; E561  9D 30 00
    lda zp_DB                                   ; E564  A5 DB
    adc a:FighterVelX,x                         ; E566  7D 32 00
    sta a:FighterVelX,x                         ; E569  9D 32 00
    ldy #$0A                                    ; E56C  A0 0A
    lda (zp_D9),y                               ; E56E  B1 D9       [le bancos $01]
    sta zp_DD                                   ; E570  85 DD
    lsr a                                       ; E572  4A
    ror zp_DE                                   ; E573  66 DE
    lsr a                                       ; E575  4A
    ror zp_DE                                   ; E576  66 DE
    lsr a                                       ; E578  4A
    ror zp_DE                                   ; E579  66 DE
    lsr a                                       ; E57B  4A
    ror zp_DE                                   ; E57C  66 DE
    bit zp_DD                                   ; E57E  24 DD
    bpl L3F_E584                                ; E580  10 02
    ora #$F0                                    ; E582  09 F0
L3F_E584:
    sta zp_DD                                   ; E584  85 DD
    lda zp_DE                                   ; E586  A5 DE
    adc a:FighterVelYSub,x                      ; E588  7D 34 00
    sta a:FighterVelYSub,x                      ; E58B  9D 34 00
    lda zp_DD                                   ; E58E  A5 DD
    adc a:FighterVelY,x                         ; E590  7D 36 00
    sta a:FighterVelY,x                         ; E593  9D 36 00
    rts                                         ; E596  60


; <- tabela D3F_E4CE
; modos: luta
MoveVelAccel:
    ldy #$08                                    ; E597  A0 08       modos 2/3: acelera com MoveVelAdd (o bit 0 do modo nao muda o efeito)
    lda (zp_D5),y                               ; E599  B1 D5       [le bancos $01]
    cmp #$02                                    ; E59B  C9 02
    bne L3F_E5A2                                ; E59D  D0 03
    jmp MoveVelAdd                              ; E59F  4C 3C E5


L3F_E5A2:
    cmp #$03                                    ; E5A2  C9 03
    bne L3F_E5A9                                ; E5A4  D0 03
    jmp MoveVelAdd                              ; E5A6  4C 3C E5    (nt)


L3F_E5A9:
    jmp MoveVelSubpixel                         ; E5A9  4C F1 E4


; <- jsr Main
; modos: aviso/QR
RandomSeed:
    lda #$32                                    ; E5AC  A9 32
    sta RngState                                ; E5AE  85 66
    lda #$46                                    ; E5B0  A9 46
    sta RngState+1                              ; E5B2  85 67
    lda #$53                                    ; E5B4  A9 53
    sta RngState+2                              ; E5B6  85 68
    rts                                         ; E5B8  60


; <- jsr L00_903D, jsr L00_90A5, jsr L00_90CA, jsr L00_90F5, jsr L00_9113, jsr AiStartScriptCheck ... (+1)
; modos: luta
Random:
    ldy RngState+1                              ; E5B9  A4 67
    lda RngState+2                              ; E5BB  A5 68
    lsr a                                       ; E5BD  4A
    lsr a                                       ; E5BE  4A
    lsr a                                       ; E5BF  4A
    lsr a                                       ; E5C0  4A
    sta RngState+1                              ; E5C1  85 67
    lsr a                                       ; E5C3  4A
    lsr a                                       ; E5C4  4A
    eor RngState+1                              ; E5C5  45 67
    lsr a                                       ; E5C7  4A
    eor RngState+1                              ; E5C8  45 67
    eor RngState                                ; E5CA  45 66
    sta RngState+1                              ; E5CC  85 67
    lda RngState+2                              ; E5CE  A5 68
    asl a                                       ; E5D0  0A
    eor RngState+2                              ; E5D1  45 68
    asl a                                       ; E5D3  0A
    asl a                                       ; E5D4  0A
    eor RngState+2                              ; E5D5  45 68
    asl a                                       ; E5D7  0A
    eor RngState+2                              ; E5D8  45 68
    sty RngState+2                              ; E5DA  84 68
    sta RngState                                ; E5DC  85 66
    rts                                         ; E5DE  60


; <- tabela AiOpLo
; modos: luta
AiOp00:
    lda zp_6D                                   ; E5DF  A5 6D
    sta InputDir,x                              ; E5E1  95 86
    lda #$FF                                    ; E5E3  A9 FF
    sta InputAttack,x                           ; E5E5  95 88
    sta CmdMoveIdx,x                            ; E5E7  95 8E
    rts                                         ; E5E9  60


; <- tabela AiOpLo
; modos: luta
AiOp01:
    lda zp_6D                                   ; E5EA  A5 6D
    sta InputDir,x                              ; E5EC  95 86
    lda zp_6E                                   ; E5EE  A5 6E
    sta InputAttack,x                           ; E5F0  95 88
    lda #$FF                                    ; E5F2  A9 FF
    sta CmdMoveIdx,x                            ; E5F4  95 8E
    rts                                         ; E5F6  60


; <- tabela AiOpLo
; modos: luta
AiOp02:
    lda #$04                                    ; E5F7  A9 04
    sta InputDir,x                              ; E5F9  95 86
    lda #$FF                                    ; E5FB  A9 FF
    sta InputAttack,x                           ; E5FD  95 88
    lda zp_6D                                   ; E5FF  A5 6D
    sta CmdMoveIdx,x                            ; E601  95 8E
    rts                                         ; E603  60


; <- tabela AiOpLo
; modos: luta
AiOp03:
    lda #$FF                                    ; E604  A9 FF
    sta InputAttack,x                           ; E606  95 88
    sta CmdMoveIdx,x                            ; E608  95 8E
    lda #$06                                    ; E60A  A9 06
    sta InputDir,x                              ; E60C  95 86
    ldy OtherFighter                            ; E60E  A4 65
    lda a:FighterState,y                        ; E610  B9 26 00
    and #$02                                    ; E613  29 02
    beq L3F_E619                                ; E615  F0 02
    asl InputDir,x                              ; E617  16 86
L3F_E619:
    rts                                         ; E619  60


; <- tabela AiOpLo
AiOp04:
    lda zp_6D                                   ; E61A  A5 6D       (nt)
    sta zp_6F,x                                 ; E61C  95 6F       (nt)
    rts                                         ; E61E  60          (nt)


; <- tabela AiOpLo
; modos: luta
AiOp05:
    lda #$00                                    ; E61F  A9 00
    sta zp_6E                                   ; E621  85 6E
    txa                                         ; E623  8A
    tay                                         ; E624  A8
    lda (zp_6D),y                               ; E625  B1 6D
    sta zp_6F,x                                 ; E627  95 6F
    rts                                         ; E629  60


; <- tabela AiOpLo
AiOp06:
    inc zp_6F                                   ; E62A  E6 6F       (nt)
    rts                                         ; E62C  60          (nt)


; <- tabela AiOpLo
; modos: luta
AiOp07:
    lda a:FighterState,x                        ; E62D  BD 26 00
    lsr a                                       ; E630  4A
    lsr a                                       ; E631  4A
    lsr a                                       ; E632  4A
    cmp zp_6D                                   ; E633  C5 6D
    rts                                         ; E635  60


; <- tabela AiOpLo
; modos: luta
AiOp08:
    lda a:FighterState,x                        ; E636  BD 26 00
    and zp_6D                                   ; E639  25 6D
    cmp zp_6D                                   ; E63B  C5 6D
    rts                                         ; E63D  60


; <- tabela AiOpLo
; modos: luta
AiOp09:
    lda a:FighterState,x                        ; E63E  BD 26 00
    and #$58                                    ; E641  29 58
    cmp #$58                                    ; E643  C9 58
    rts                                         ; E645  60


; <- tabela AiOpLo
AiOp0A:
    lda a:FighterState,x                        ; E646  BD 26 00    (nt)
    and #$F8                                    ; E649  29 F8       (nt)
    cmp #$B0                                    ; E64B  C9 B0       (nt)
    bcc L3F_E656                                ; E64D  90 07       (nt)
    cmp #$E1                                    ; E64F  C9 E1       (nt)
    bcs L3F_E656                                ; E651  B0 03       (nt)
    lda #$00                                    ; E653  A9 00       (nt)
    rts                                         ; E655  60          (nt)


L3F_E656:
    lda #$01                                    ; E656  A9 01       (nt)
    rts                                         ; E658  60          (nt)


; <- tabela AiOpLo
; modos: luta
AiOp0B:
    lda ProjX,x                                 ; E659  B5 7B
    rts                                         ; E65B  60


; <- tabela AiOpLo
; modos: luta
AiOp0C:
    lda FighterX,x                              ; E65C  B5 08
    cmp #$E0                                    ; E65E  C9 E0
    bcs L3F_E683                                ; E660  B0 21
    cmp #$21                                    ; E662  C9 21
    bcc L3F_E683                                ; E664  90 1D
    sbc zp_6F,x                                 ; E666  F5 6F
    bpl L3F_E66E                                ; E668  10 04
    eor #$FF                                    ; E66A  49 FF
    adc #$01                                    ; E66C  69 01
L3F_E66E:
    bne L3F_E67E                                ; E66E  D0 0E
    sec                                         ; E670  38
    lda FighterX+1                              ; E671  A5 09
    sbc FighterX                                ; E673  E5 08
    bpl L3F_E67B                                ; E675  10 04
    eor #$FF                                    ; E677  49 FF
    adc #$01                                    ; E679  69 01
L3F_E67B:
    cmp #$10                                    ; E67B  C9 10
    rts                                         ; E67D  60


L3F_E67E:
    cmp zp_6D                                   ; E67E  C5 6D
    bcs L3F_E683                                ; E680  B0 01
    rts                                         ; E682  60


L3F_E683:
    lda #$00                                    ; E683  A9 00
    rts                                         ; E685  60


; <- tabela AiOpLo
; modos: luta
AiOp0E:
    sec                                         ; E686  38
    lda FighterX+1                              ; E687  A5 09
    sbc FighterX                                ; E689  E5 08
    bpl L3F_E691                                ; E68B  10 04
    eor #$FF                                    ; E68D  49 FF
    adc #$01                                    ; E68F  69 01
L3F_E691:
    cmp zp_6D                                   ; E691  C5 6D
    bcs L3F_E698                                ; E693  B0 03
    lda #$00                                    ; E695  A9 00
    rts                                         ; E697  60


L3F_E698:
    lda #$01                                    ; E698  A9 01
    rts                                         ; E69A  60


; <- tabela AiOpLo
; modos: luta
AiOp0F:
    sec                                         ; E69B  38
    lda FighterX+1                              ; E69C  A5 09
    sbc FighterX                                ; E69E  E5 08
    bpl L3F_E6A6                                ; E6A0  10 04
    eor #$FF                                    ; E6A2  49 FF
    adc #$01                                    ; E6A4  69 01
L3F_E6A6:
    cmp zp_6D                                   ; E6A6  C5 6D
    bcc L3F_E6AD                                ; E6A8  90 03
    lda #$00                                    ; E6AA  A9 00
    rts                                         ; E6AC  60


L3F_E6AD:
    lda #$01                                    ; E6AD  A9 01
    rts                                         ; E6AF  60


; <- tabela AiOpLo
AiOp0D:
    dec zp_6F,x                                 ; E6B0  D6 6F       (nt)
    rts                                         ; E6B2  60          (nt)


; <- tabela AiOpLo
; modos: luta
AiOp10:
    ldy OtherFighter                            ; E6B3  A4 65
    lda a:FighterState,y                        ; E6B5  B9 26 00
    lsr a                                       ; E6B8  4A
    lsr a                                       ; E6B9  4A
    lsr a                                       ; E6BA  4A
    cmp zp_6D                                   ; E6BB  C5 6D
    rts                                         ; E6BD  60


; <- tabela AiOpLo
; modos: luta
AiOp11:
    lda a:zp_73,x                               ; E6BE  BD 73 00
    rts                                         ; E6C1  60

AiOpLo:
    .byte <(AiOp00-1)                           ; E6C2  DE
    .byte <(AiOp01-1)                           ; E6C3  E9
    .byte <(AiOp02-1)                           ; E6C4  F6
    .byte <(AiOp03-1)                           ; E6C5  03
    .byte <(AiOp04-1)                           ; E6C6  19
    .byte <(AiOp05-1)                           ; E6C7  1E
    .byte <(AiOp06-1)                           ; E6C8  29
    .byte <(AiOp07-1)                           ; E6C9  2C
    .byte <(AiOp08-1)                           ; E6CA  35
    .byte <(AiOp09-1)                           ; E6CB  3D
    .byte <(AiOp0A-1)                           ; E6CC  45
    .byte <(AiOp0B-1)                           ; E6CD  58
    .byte <(AiOp0C-1)                           ; E6CE  5B
    .byte <(AiOp0D-1)                           ; E6CF  AF
    .byte <(AiOp0E-1)                           ; E6D0  85
    .byte <(AiOp0F-1)                           ; E6D1  9A
    .byte <(AiOp10-1)                           ; E6D2  B2
    .byte <(AiOp11-1)                           ; E6D3  BD
AiOpHi:
    .byte >(AiOp00-1)                           ; E6D4  E5
    .byte >(AiOp01-1)                           ; E6D5  E5
    .byte >(AiOp02-1)                           ; E6D6  E5
    .byte >(AiOp03-1)                           ; E6D7  E6
    .byte >(AiOp04-1)                           ; E6D8  E6
    .byte >(AiOp05-1)                           ; E6D9  E6
    .byte >(AiOp06-1)                           ; E6DA  E6
    .byte >(AiOp07-1)                           ; E6DB  E6
    .byte >(AiOp08-1)                           ; E6DC  E6
    .byte >(AiOp09-1)                           ; E6DD  E6
    .byte >(AiOp0A-1)                           ; E6DE  E6
    .byte >(AiOp0B-1)                           ; E6DF  E6
    .byte >(AiOp0C-1)                           ; E6E0  E6
    .byte >(AiOp0D-1)                           ; E6E1  E6
    .byte >(AiOp0E-1)                           ; E6E2  E6
    .byte >(AiOp0F-1)                           ; E6E3  E6
    .byte >(AiOp10-1)                           ; E6E4  E6
    .byte >(AiOp11-1)                           ; E6E5  E6
AiCharRoutine:
    .word RyuAiThink-1                          ; E6E6  45 8F       uma entrada (endereco-1) por personagem; so o Ryu existe

; <- jmp L00_8FB8, jmp L00_8FFC, jmp L00_9016, jmp L00_90A5, jmp L00_90C3, jmp L00_912B ... (+3)
; modos: luta
AiStartScriptNow:
    sta AiScriptPtrLo,x                         ; E6E8  95 69       A/Y = ponteiro do roteiro; inicia sempre
    sty AiScriptPtrHi,x                         ; E6EA  94 6B
    lda #$40                                    ; E6EC  A9 40
    sta zp_DD                                   ; E6EE  85 DD
    jmp AiStartScriptCheck                      ; E6F0  4C 01 E7


; <- jmp L00_8F7F, jmp L00_8F8F, jmp L00_8F96, jmp L00_8FC8, jmp L00_9028, jmp L00_903D ... (+10)
; modos: luta
AiStartScript:
    sta AiScriptPtrLo,x                         ; E6F3  95 69       A/Y = ponteiro do roteiro; so inicia se Random&7 < AiLevel (senao hesita)
    sty AiScriptPtrHi,x                         ; E6F5  94 6B
    lda #$80                                    ; E6F7  A9 80
    sta zp_DD                                   ; E6F9  85 DD
    jmp AiStartScriptCheck                      ; E6FB  4C 01 E7


; <- jmp RyuAiThink, jmp L00_8F5C, jmp L00_8F66, jmp L00_8F70, jmp L00_8FC2, jmp L00_8FE9 ... (+9)
; modos: luta
AiDoNothing:
    lda #$00                                    ; E6FE  A9 00
    rts                                         ; E700  60


; <- jmp AiStartScriptNow, jmp AiStartScript
; modos: luta
AiStartScriptCheck:
    bit zp_DD                                   ; E701  24 DD       trecho comum de AiStartScript*: bit 6 de zp_DD inicia sempre; senao sorteia Random&7 contra AiLevel
    bvs L3F_E744                                ; E703  70 3F
    jsr Random                                  ; E705  20 B9 E5
    and #$07                                    ; E708  29 07
    cmp a:AiLevel                               ; E70A  CD B4 00    AiLevel = 7 (fixo em MainLoop): a CPU reage em 7 de cada 8 chances — por isso a IA parece "dificil demais"
    bcc L3F_E744                                ; E70D  90 35
    beq L3F_E732                                ; E70F  F0 21
    ldy OtherFighter                            ; E711  A4 65
    lda a:FighterState,y                        ; E713  B9 26 00
    sta a:zp_73,x                               ; E716  9D 73 00
    cmp #$70                                    ; E719  C9 70
    lda #$20                                    ; E71B  A9 20
    sta a:zp_75,x                               ; E71D  9D 75 00
    bcs L3F_E725                                ; E720  B0 03
    jmp AiDoNothing                             ; E722  4C FE E6


L3F_E725:
    lda #$49                                    ; E725  A9 49
    ldy #$E7                                    ; E727  A0 E7
    sta AiScriptPtrLo,x                         ; E729  95 69
    sty AiScriptPtrHi,x                         ; E72B  94 6B
    lda #$40                                    ; E72D  A9 40
    sta zp_71,x                                 ; E72F  95 71
    rts                                         ; E731  60


L3F_E732:
    ldy OtherFighter                            ; E732  A4 65
    lda a:FighterState,y                        ; E734  B9 26 00
    sta a:zp_73,x                               ; E737  9D 73 00
    lda #$20                                    ; E73A  A9 20
    sta a:zp_75,x                               ; E73C  9D 75 00
    lda #$00                                    ; E73F  A9 00
    sta zp_71,x                                 ; E741  95 71
    rts                                         ; E743  60


L3F_E744:
    lda zp_DD                                   ; E744  A5 DD
    sta zp_71,x                                 ; E746  95 71
    rts                                         ; E748  60

    .byte $83,$91,$FF                           ; E749

; <- jsr AiUpdate
; modos: luta
AiDefaultGuard:
    lda a:FighterState,x                        ; E74C  BD 26 00    passo da IA: em estado neutro segura tras (guarda) e sai; senao decide ou continua o roteiro
    cmp #$50                                    ; E74F  C9 50
    bcs L3F_E77A                                ; E751  B0 27
    lda a:FrameFlags,x                          ; E753  BD 38 00
    and #$07                                    ; E756  29 07
    bne L3F_E77A                                ; E758  D0 20
    lda #$FF                                    ; E75A  A9 FF
    sta InputAttack,x                           ; E75C  95 88
    sta CmdMoveIdx,x                            ; E75E  95 8E
    lda #$06                                    ; E760  A9 06
    sta InputDir,x                              ; E762  95 86
    ldy OtherFighter                            ; E764  A4 65
    lda a:FighterState,y                        ; E766  B9 26 00
    and #$02                                    ; E769  29 02
    beq L3F_E771                                ; E76B  F0 04
    asl InputDir,x                              ; E76D  16 86
    lda #$00                                    ; E76F  A9 00
L3F_E771:
    sta a:zp_73,x                               ; E771  9D 73 00
    sta a:zp_75,x                               ; E774  9D 75 00
    sta zp_71,x                                 ; E777  95 71
    rts                                         ; E779  60


L3F_E77A:
    lda a:zp_73,x                               ; E77A  BD 73 00
    beq L3F_E793                                ; E77D  F0 14
    ldy OtherFighter                            ; E77F  A4 65
    cmp a:FighterState,y                        ; E781  D9 26 00
    bne L3F_E78B                                ; E784  D0 05
    dec a:zp_75,x                               ; E786  DE 75 00
    bne L3F_E7AF                                ; E789  D0 24
L3F_E78B:
    lda #$00                                    ; E78B  A9 00
    sta a:zp_73,x                               ; E78D  9D 73 00
    sta a:zp_75,x                               ; E790  9D 75 00
L3F_E793:
    lda zp_71,x                                 ; E793  B5 71
    bmi L3F_E7A3                                ; E795  30 0C
    lda a:FrameFlags,x                          ; E797  BD 38 00
    and #$07                                    ; E79A  29 07
    beq L3F_E7CD                                ; E79C  F0 2F
    jsr AiCallCharRoutine                       ; E79E  20 A4 E7
    bpl L3F_E7AF                                ; E7A1  10 0C
L3F_E7A3:
    rts                                         ; E7A3  60


; <- jsr L3F_E77A
; modos: luta
AiCallCharRoutine:
    ldy FighterChar,x                           ; E7A4  B4 00
    lda AiCharRoutine+1,y                       ; E7A6  B9 E7 E6    [idx $00..$00]
    pha                                         ; E7A9  48
    lda AiCharRoutine,y                         ; E7AA  B9 E6 E6    [idx $00..$00]
    pha                                         ; E7AD  48
    rts                                         ; E7AE  60


L3F_E7AF:
    lda zp_71,x                                 ; E7AF  B5 71
    bne L3F_E7CD                                ; E7B1  D0 1A
    lda ram_0342,x                              ; E7B3  BD 42 03
    sta zp_DA                                   ; E7B6  85 DA
    lda ram_0344,x                              ; E7B8  BD 44 03
    sta zp_DB                                   ; E7BB  85 DB
    jsr Random                                  ; E7BD  20 B9 E5
    and #$07                                    ; E7C0  29 07
    asl a                                       ; E7C2  0A
    tay                                         ; E7C3  A8
    lda (zp_DA),y                               ; E7C4  B1 DA       [le bancos $00]
    sta AiScriptPtrLo,x                         ; E7C6  95 69
    iny                                         ; E7C8  C8
    lda (zp_DA),y                               ; E7C9  B1 DA       [le bancos $00]
    sta AiScriptPtrHi,x                         ; E7CB  95 6B
L3F_E7CD:
    lda #$40                                    ; E7CD  A9 40
    sta zp_71,x                                 ; E7CF  95 71
    rts                                         ; E7D1  60


; ------------------------------------------------------------------------------------------------
; IA DA CPU. Dois niveis: (1) uma rotina "pensar" em codigo nativo, propria de cada personagem
; (AiCharRoutine -> banco do personagem, ex. RyuAiThink em $00:8F46), que escolhe um roteiro;
; (2) um interpretador de roteiros (bytecode, opcodes $80-$91 = AiOp00..AiOp11) que gera os comandos.
; <- jsr L3F_EFC1
; modos: luta
AiUpdate:
    lda a:FighterFrameBank,x                    ; E7D2  BD 18 00
    ora #$80                                    ; E7D5  09 80
    sta MMC5_PRG_8000                           ; E7D7  8D 14 51
    jsr AiDefaultGuard                          ; E7DA  20 4C E7
    beq L3F_E836                                ; E7DD  F0 57
    lda AiScriptPtrLo,x                         ; E7DF  B5 69
    sta zp_D7                                   ; E7E1  85 D7
    lda AiScriptPtrHi,x                         ; E7E3  B5 6B
    sta zp_D8                                   ; E7E5  85 D8

; <- jmp L3F_E809
; modos: luta
AiScriptLoop:
    ldy #$00                                    ; E7E7  A0 00       laco do roteiro: $FF encerra; senao decodifica o opcode e copia os operandos
    lda (zp_D7),y                               ; E7E9  B1 D7       [le bancos $00,$3F]
    cmp #$FF                                    ; E7EB  C9 FF
    bne L3F_E7F4                                ; E7ED  D0 05
    lda #$00                                    ; E7EF  A9 00
    sta zp_71,x                                 ; E7F1  95 71
    rts                                         ; E7F3  60


L3F_E7F4:
    and #$7F                                    ; E7F4  29 7F
    sta zp_D9                                   ; E7F6  85 D9
    inc zp_D7                                   ; E7F8  E6 D7
    bne AiScriptCopyArgs                        ; E7FA  D0 02
    inc zp_D8                                   ; E7FC  E6 D8       (nt)

; <- jmp L3F_E7F4
; modos: luta
AiScriptCopyArgs:
    lda (zp_D7),y                               ; E7FE  B1 D7       [le bancos $00,$3F] copia os operandos positivos para zp_6D.. ate o proximo opcode (negativo)
    bmi L3F_E809                                ; E800  30 07
    sta a:zp_6D,y                               ; E802  99 6D 00
    iny                                         ; E805  C8
    jmp AiScriptCopyArgs                        ; E806  4C FE E7


L3F_E809:
    tya                                         ; E809  98
    beq L3F_E815                                ; E80A  F0 09
    clc                                         ; E80C  18
    adc zp_D7                                   ; E80D  65 D7
    sta zp_D7                                   ; E80F  85 D7
    bcc L3F_E815                                ; E811  90 02
    inc zp_D8                                   ; E813  E6 D8
L3F_E815:
    jsr AiOpRun                                 ; E815  20 2B E8
    beq L3F_E820                                ; E818  F0 06
    lda zp_D9                                   ; E81A  A5 D9
    cmp #$07                                    ; E81C  C9 07
    bcs L3F_E836                                ; E81E  B0 16
L3F_E820:
    lda zp_D7                                   ; E820  A5 D7
    sta AiScriptPtrLo,x                         ; E822  95 69
    lda zp_D8                                   ; E824  A5 D8
    sta AiScriptPtrHi,x                         ; E826  95 6B
    jmp AiScriptLoop                            ; E828  4C E7 E7


; <- jsr L3F_E809
; modos: luta
AiOpRun:
    ldy zp_D9                                   ; E82B  A4 D9       Y = opcode lido; cai no despacho AiOpDispatch
AiOpDispatch:
    lda AiOpHi,y                                ; E82D  B9 D4 E6    [idx $00..$11]
    pha                                         ; E830  48
    lda AiOpLo,y                                ; E831  B9 C2 E6    [idx $00..$11]
    pha                                         ; E834  48
    rts                                         ; E835  60


L3F_E836:
    rts                                         ; E836  60


; <- jsr AnimAdvance
; modos: luta
ProjLaunch:
    sta ProjSpeed,x                             ; E837  95 77       A = velocidade ($00/$01/$02, passo em D3F_E05E): nasce em FighterX +/- $27, direcao = FighterFlip (bit 6 de ProjFlags)
    lsr a                                       ; E839  4A
    tay                                         ; E83A  A8
    lda D3F_E064,y                              ; E83B  B9 64 E0    [idx $00..$00]
    ldy FighterFlip,x                           ; E83E  B4 04
    beq L3F_E846                                ; E840  F0 04
    eor #$FF                                    ; E842  49 FF
    adc #$01                                    ; E844  69 01
L3F_E846:
    sty ProjFlags,x                             ; E846  94 81
    clc                                         ; E848  18
    adc FighterX,x                              ; E849  75 08
    sta ProjX,x                                 ; E84B  95 7B
    lda #$00                                    ; E84D  A9 00
    sta ProjXSub,x                              ; E84F  95 79
    sta ProjStep,x                              ; E851  95 7F
    rts                                         ; E853  60


; <- jsr L3F_EFCB
; modos: intro do round, luta, fim do round
ProjUpdate:
    lda ProjX,x                                 ; E854  B5 7B       anda 1/16 do passo por subquadro; Y = FloorY - $27; morre fora de $0C-$FB
    beq L3F_E8BA                                ; E856  F0 62
    lda ProjFlags,x                             ; E858  B5 81
    sta zp_D9                                   ; E85A  85 D9
    and #$80                                    ; E85C  29 80
    bne L3F_E8B1                                ; E85E  D0 51
    lda ProjSpeed,x                             ; E860  B5 77
    lsr a                                       ; E862  4A
    tay                                         ; E863  A8
    lda D3F_E05B,x                              ; E864  BD 5B E0    [idx $00..$01]
    clc                                         ; E867  18
    adc FloorY                                  ; E868  6D BA 03
    sta ProjY,x                                 ; E86B  95 7D
    lda #$00                                    ; E86D  A9 00
    sta zp_D7                                   ; E86F  85 D7
    ldy ProjSpeed,x                             ; E871  B4 77
    lda D3F_E05E,y                              ; E873  B9 5E E0    [idx $00..$01]
    lsr a                                       ; E876  4A
    ror zp_D7                                   ; E877  66 D7
    lsr a                                       ; E879  4A
    ror zp_D7                                   ; E87A  66 D7
    lsr a                                       ; E87C  4A
    ror zp_D7                                   ; E87D  66 D7
    lsr a                                       ; E87F  4A
    ror zp_D7                                   ; E880  66 D7
    sta zp_D8                                   ; E882  85 D8
    lda ProjXSub,x                              ; E884  B5 79
    bit zp_D9                                   ; E886  24 D9
    bvs L3F_E896                                ; E888  70 0C
    clc                                         ; E88A  18
    adc zp_D7                                   ; E88B  65 D7
    sta ProjXSub,x                              ; E88D  95 79
    lda ProjX,x                                 ; E88F  B5 7B
    adc zp_D8                                   ; E891  65 D8
    jmp ProjUpdateStore                         ; E893  4C 9F E8


L3F_E896:
    sec                                         ; E896  38
    sbc zp_D7                                   ; E897  E5 D7
    sta ProjXSub,x                              ; E899  95 79
    lda ProjX,x                                 ; E89B  B5 7B
    sbc zp_D8                                   ; E89D  E5 D8

; <- jmp ProjUpdate
; modos: luta, fim do round
ProjUpdateStore:
    cmp #$0C                                    ; E89F  C9 0C       grava ProjX se dentro de $0C-$FB e conta o passo; fora disso mata o projetil
    bcc L3F_E8AC                                ; E8A1  90 09
    cmp #$FC                                    ; E8A3  C9 FC
    bcs L3F_E8AC                                ; E8A5  B0 05
    sta ProjX,x                                 ; E8A7  95 7B
    inc ProjStep,x                              ; E8A9  F6 7F
    rts                                         ; E8AB  60


L3F_E8AC:
    lda #$00                                    ; E8AC  A9 00
    sta ProjX,x                                 ; E8AE  95 7B
    rts                                         ; E8B0  60


L3F_E8B1:
    ldy ProjStep,x                              ; E8B1  B4 7F
    iny                                         ; E8B3  C8
    cpy #$10                                    ; E8B4  C0 10
    bcs L3F_E8AC                                ; E8B6  B0 F4
    sty ProjStep,x                              ; E8B8  94 7F
L3F_E8BA:
    rts                                         ; E8BA  60


; <- jsr FightersUpdate
; modos: intro do round, luta, fim do round
ProjClash:
    lda ProjFlags                               ; E8BB  A5 81       dois projeteis a |dx| < $18: os dois ganham bit 7 de ProjFlags e morrem apos 16 passos
    ora ProjFlags+1                             ; E8BD  05 82
    and #$80                                    ; E8BF  29 80
    bne L3F_E8ED                                ; E8C1  D0 2A
    lda ProjX+1                                 ; E8C3  A5 7C
    beq L3F_E8ED                                ; E8C5  F0 26
    lda ProjX                                   ; E8C7  A5 7B
    beq L3F_E8ED                                ; E8C9  F0 22
    sec                                         ; E8CB  38
    sbc ProjX+1                                 ; E8CC  E5 7C
    bpl L3F_E8D4                                ; E8CE  10 04
    eor #$FF                                    ; E8D0  49 FF
    adc #$01                                    ; E8D2  69 01
L3F_E8D4:
    cmp #$18                                    ; E8D4  C9 18
    bcs L3F_E8ED                                ; E8D6  B0 15
    lda ProjFlags                               ; E8D8  A5 81
    ora #$80                                    ; E8DA  09 80
    sta ProjFlags                               ; E8DC  85 81
    lda #$00                                    ; E8DE  A9 00
    sta ProjStep                                ; E8E0  85 7F
    lda ProjFlags+1                             ; E8E2  A5 82
    ora #$80                                    ; E8E4  09 80
    sta ProjFlags+1                             ; E8E6  85 82
    lda #$00                                    ; E8E8  A9 00
    sta ProjStep+1                              ; E8EA  85 80
    rts                                         ; E8EC  60


L3F_E8ED:
    ldx #$01                                    ; E8ED  A2 01
    ldy #$00                                    ; E8EF  A0 00

; <- jmp L3F_E8ED
; modos: intro do round, luta, fim do round
ProjHitTest:
    lda a:ProjX,y                               ; E8F1  B9 7B 00    AABB do projetil (ponto +/- $0C/$0B) contra as caixas de corpo do oponente
    beq L3F_E95A                                ; E8F4  F0 64
    lda a:ProjFlags,y                           ; E8F6  B9 81 00
    bmi L3F_E95A                                ; E8F9  30 5F
    clc                                         ; E8FB  18
    lda a:ProjX,y                               ; E8FC  B9 7B 00
    adc #$0C                                    ; E8FF  69 0C
    cmp a:Body1L,x                              ; E901  DD 46 00
    bcc L3F_E91E                                ; E904  90 18
    sbc #$17                                    ; E906  E9 17
    cmp a:Body1R,x                              ; E908  DD 4A 00
    bcs L3F_E91E                                ; E90B  B0 11
    lda a:ProjY,y                               ; E90D  B9 7D 00
    adc #$0C                                    ; E910  69 0C
    cmp a:Body1T,x                              ; E912  DD 48 00
    bcc L3F_E91E                                ; E915  90 07
    sbc #$17                                    ; E917  E9 17
    cmp a:Body1B,x                              ; E919  DD 4C 00
    bcc ProjHit                                 ; E91C  90 23
L3F_E91E:
    clc                                         ; E91E  18
    lda a:ProjX,y                               ; E91F  B9 7B 00
    adc #$0C                                    ; E922  69 0C
    cmp a:Body2L,x                              ; E924  DD 4E 00
    bcc L3F_E95A                                ; E927  90 31
    sbc #$17                                    ; E929  E9 17
    cmp a:Body2R,x                              ; E92B  DD 52 00
    bcs L3F_E95A                                ; E92E  B0 2A
    lda a:ProjY,y                               ; E930  B9 7D 00
    adc #$0C                                    ; E933  69 0C
    cmp a:Body2T,x                              ; E935  DD 50 00
    bcc L3F_E95A                                ; E938  90 20
    sbc #$17                                    ; E93A  E9 17
    cmp a:Body2B,x                              ; E93C  DD 54 00
    bcs L3F_E95A                                ; E93F  B0 19
ProjHit:
    lda a:ProjFlags,y                           ; E941  B9 81 00    projetil acertou: morre, classe de reacao $CB, dano $6C e chama a rotina de dano
    ora #$80                                    ; E944  09 80
    sta a:ProjFlags,y                           ; E946  99 81 00
    lda #$00                                    ; E949  A9 00
    sta a:ProjStep,y                            ; E94B  99 7F 00
    lda #$CB                                    ; E94E  A9 CB
    sta a:HitReactClass,x                       ; E950  9D 16 00
    lda #$6C                                    ; E953  A9 6C
    sta zp_D8                                   ; E955  85 D8
    jsr HitDamageApply                          ; E957  20 83 ED
L3F_E95A:
    dex                                         ; E95A  CA
    bne L3F_E962                                ; E95B  D0 05
    ldy #$01                                    ; E95D  A0 01
    jmp ProjHitTest                             ; E95F  4C F1 E8


L3F_E962:
    rts                                         ; E962  60

DirCodeTbl:
    .byte $04,$05,$06,$04,$08,$0B,$0C,$04,$07,$09,$0A,$04,$04,$04,$04,$04; E963              bits do controle -> codigo de direcao (bit 0 frente, 1 tras, 2 baixo, 3 cima): $04 neutro, $05 frente, $06 tras, $07 cima, $08 baixo, $09-$0A diagonais de cima, $0B-$0C diagonais de baixo
    .byte $04                                   ; E973

; <- jsr FighterUpdate
; modos: intro do round, luta, fim do round
InputClear:
    lda #$04                                    ; E974  A9 04       zera a entrada do lutador (direcao neutra, sem golpe/hold); roda todo quadro fora da luta ativa (ScreenMode != 5 ou round ja decidido)
    sta InputDir,x                              ; E976  95 86
    lda #$FF                                    ; E978  A9 FF
    sta InputAttack,x                           ; E97A  95 88
    sta CmdMoveIdx,x                            ; E97C  95 8E
    lda #$00                                    ; E97E  A9 00
    sta BtnAHold,x                              ; E980  95 8A
    sta BtnBHold,x                              ; E982  95 8C
    sta CmdMotionStep,x                         ; E984  95 90       zera o passo do comando 0 do reconhecedor (CmdMotionStep,x = entrada 0 da lista)
    sta CmdMotionWin,x                          ; E986  95 9E       zera a janela do comando 0 (CmdMotionWin,x)
    sta CmdMotionStep+1,x                       ; E988  95 91       estouro: CmdMotionStep+1,x NAO e' a entrada 1 (arrays intercalados) — atinge 1 byte do vizinho
    sta CmdMotionWin+1,x                        ; E98A  95 9F       mesmo estouro na janela; entradas 1-5 nunca sao zeradas aqui, so expiram pela janela
    rts                                         ; E98C  60


; ------------------------------------------------------------------------------------------------
; ENTRADA DO JOGADOR HUMANO: le JoyState e alimenta o reconhecedor de comandos (golpes especiais).
; E' aqui (e em CmdStep*) que mora o problema relatado de "hadouken dificil / comando atrasado".
; <- jsr L3F_EFCB
; modos: luta
InputUpdate:
    txa                                         ; E98D  8A
    jsr JoyPollSafe                             ; E98E  20 F1 F8
    jsr InputDirection                          ; E991  20 01 EA
    jsr InputButtons                            ; E994  20 9A E9
    jmp InputCommands                           ; E997  4C 24 EA


.ifdef FIX_EDGE_ATTACK
__alt_3F_E99A:
InputButtons:
    lda JoyState,x                              ; botao A (bit 7): segurado?
    bpl EdgeARel                                ; soltou -> logica de soltura
    ldy BtnAHold,x
    iny
    beq EdgeBBtn                                ; wrap $FF->0 (marcador de forte): ignora
    sty BtnAHold,x
    cpy #$02                                     ; borda de subida: contador==1
    bcc EdgeAWeak                                ; -> soco fraco AGORA
    cpy #$07                                     ; 2..6: zona morta (fraco ja' saiu no aperto)
    bcc EdgeBBtn                                 ; 7..20: forte segue armado enquanto segurar
EdgeAStrong:
    lda #$01                                     ; soco forte
    jmp InputSetAttack
EdgeAWeak:
    lda #$00                                     ; soco fraco na borda de subida
    jmp InputSetAttack
EdgeARel:                                        ; A soltou
    ldy BtnAHold,x
    lda #$00
    sta BtnAHold,x                               ; zera o contador do soco
    cpy #$15                                     ; >=21 (marcador $FF ou segurou demais): nada
    bcs EdgeBBtn
    cpy #$07
    bcc EdgeBBtn                                ; <7: nada (o fraco ja' saiu no aperto)
    bcs EdgeAStrong                              ; 7..20: forte uma ultima vez
EdgeBBtn:                                        ; botao B (bit 6)
    lda JoyState,x
    and #$40
    beq EdgeBRel                                 ; soltou
    ldy BtnBHold,x
    iny
    beq BtnNone                                  ; wrap $FF->0 (marcador de forte): nenhum golpe
    sty BtnBHold,x
    cpy #$02                                     ; borda de subida
    bcc EdgeBWeak                                ; -> chute fraco AGORA
    cpy #$07                                     ; 2..6: zona morta
    bcc BtnNone                                  ; 7..20: forte segue armado
EdgeBStrong:
    lda #$03                                     ; chute forte
    jmp InputSetAttack
EdgeBWeak:
    lda #$02                                     ; chute fraco na borda de subida
    jmp InputSetAttack
EdgeBRel:                                        ; B soltou
    ldy BtnBHold,x
    lda #$00
    sta BtnBHold,x                               ; zera o contador do chute
    cpy #$15
    bcs BtnNone
    cpy #$07
    bcc BtnNone                                  ; <7: nada
    bcs EdgeBStrong                              ; 7..20: forte uma ultima vez
    .assert * - __alt_3F_E99A <= $62, error, "bloco alt FIX_EDGE_ATTACK em $E99A passou do tamanho"
    .res $62 - (* - __alt_3F_E99A), $FF
.else

; Botoes A (soco) e B (chute) com dois niveis de forca num botao so:
; toque curto (soltou antes de 7 quadros)  -> golpe FRACO, emitido so QUANDO SOLTA
; segurou 7 quadros ou mais                -> golpe FORTE, emitido a CADA quadro do 7o ao 20o, e de novo ao soltar
; InputAttack,x recebe: 0 soco fraco, 1 soco forte, 2 chute fraco, 3 chute forte, $FF nada.
; Consequencia: todo golpe sai atrasado (no minimo ate soltar o botao) e o forte se repete — ver docs/BUGS.md.
; Ajuste FIX_EDGE_ATTACK (secao de ajustes no fim do arquivo): fraco na borda de subida + promocao para forte.
; <- jsr InputUpdate
; modos: luta
InputButtons:
    lda JoyState,x                              ; E99A  B5 F2
    and #$80                                    ; E99C  29 80
    beq BtnAReleased                            ; E99E  F0 14
    ldy BtnAHold,x                              ; E9A0  B4 8A
    iny                                         ; E9A2  C8
    beq BtnBCheck                               ; E9A3  F0 26
    sty BtnAHold,x                              ; E9A5  94 8A
    cpy #$15                                    ; E9A7  C0 15       passou de 20 quadros segurando: ignora
    bcs BtnBCheck                               ; E9A9  B0 20
    cpy #$07                                    ; E9AB  C0 07       menos de 7 quadros: ainda nao decide (espera soltar)

.ifdef FIX_HEAVY_ONCE
__alt_3F_E9AD:
    bne BtnBCheck                               ; era bcc: so quando o contador e' exatamente 7
    .assert * - __alt_3F_E9AD <= $2, error, "bloco alt FIX_HEAVY_ONCE em $E9AD passou do tamanho"
    .res $2 - (* - __alt_3F_E9AD), $FF
.else
    bcc BtnBCheck                               ; E9AD  90 1C       contador < 7: segue para o botao B sem emitir nada
.endif

    lda #$01                                    ; E9AF  A9 01       7..20 quadros segurando: soco forte, todo quadro
    jmp InputSetAttack                          ; E9B1  4C FE E9


; modos: luta
BtnAReleased:
    ldy BtnAHold,x                              ; E9B4  B4 8A       A soltou: zera o contador do soco e emite fraco (se segurou <7) ou forte de novo
    beq BtnBCheck                               ; E9B6  F0 13
    lda #$00                                    ; E9B8  A9 00
    sta BtnAHold,x                              ; E9BA  95 8A
    cpy #$15                                    ; E9BC  C0 15
    bcs BtnBCheck                               ; E9BE  B0 0B
EmitWeakPunch:
    lda #$00                                    ; E9C0  A9 00       emissor do soco fraco (A=$00): saida da soltura rapida (<7 quadros)
    cpy #$07                                    ; E9C2  C0 07       soltou: <7 quadros = fraco (0), senao forte (1)
    bcc InputSetAttack                          ; E9C4  90 38

.ifdef FIX_HEAVY_ONCE
__alt_3F_E9C6:
    lda #$FF                                    ; era lda #$01: soltar depois de 7 quadros nao repete o golpe
    .assert * - __alt_3F_E9C6 <= $2, error, "bloco alt FIX_HEAVY_ONCE em $E9C6 passou do tamanho"
    .res $2 - (* - __alt_3F_E9C6), $FF
.else
    lda #$01                                    ; E9C6  A9 01
.endif

    jmp InputSetAttack                          ; E9C8  4C FE E9


; modos: luta
BtnBCheck:
    lda JoyState,x                              ; E9CB  B5 F2       processamento do botao B (chute); os casos "nada a fazer" do A caem aqui
    and #$40                                    ; E9CD  29 40
    beq BtnBReleased                            ; E9CF  F0 14
    ldy BtnBHold,x                              ; E9D1  B4 8C
    iny                                         ; E9D3  C8
    beq BtnNone                                 ; E9D4  F0 26
    sty BtnBHold,x                              ; E9D6  94 8C
    cpy #$15                                    ; E9D8  C0 15
    bcs BtnNone                                 ; E9DA  B0 20
    cpy #$07                                    ; E9DC  C0 07

.ifdef FIX_HEAVY_ONCE
__alt_3F_E9DE:
    bne BtnNone
    .assert * - __alt_3F_E9DE <= $2, error, "bloco alt FIX_HEAVY_ONCE em $E9DE passou do tamanho"
    .res $2 - (* - __alt_3F_E9DE), $FF
.else
    bcc BtnNone                                 ; E9DE  90 1C
.endif

    lda #$03                                    ; E9E0  A9 03
    jmp InputSetAttack                          ; E9E2  4C FE E9


; modos: luta
BtnBReleased:
    ldy BtnBHold,x                              ; E9E5  B4 8C       B soltou: zera o contador do chute e emite fraco/forte
    beq BtnNone                                 ; E9E7  F0 13
    lda #$00                                    ; E9E9  A9 00
    sta BtnBHold,x                              ; E9EB  95 8C
    cpy #$15                                    ; E9ED  C0 15
    bcs BtnNone                                 ; E9EF  B0 0B
EmitWeakKick:
    lda #$02                                    ; E9F1  A9 02       emissor do chute fraco (A=$02): saida da soltura rapida (<7 quadros)
    cpy #$07                                    ; E9F3  C0 07
    bcc InputSetAttack                          ; E9F5  90 07

.ifdef FIX_HEAVY_ONCE
__alt_3F_E9F7:
    lda #$FF
    .assert * - __alt_3F_E9F7 <= $2, error, "bloco alt FIX_HEAVY_ONCE em $E9F7 passou do tamanho"
    .res $2 - (* - __alt_3F_E9F7), $FF
.else
    lda #$03                                    ; E9F7  A9 03
.endif

    jmp InputSetAttack                          ; E9F9  4C FE E9

.endif


; modos: luta
BtnNone:
    lda #$FF                                    ; E9FC  A9 FF       nenhum botao ativo: InputAttack = $FF

; <- jmp InputButtons, jmp BtnAReleased, jmp BtnBCheck, jmp BtnBReleased
; modos: luta
InputSetAttack:
    sta InputAttack,x                           ; E9FE  95 88
    rts                                         ; EA00  60


; <- jsr InputUpdate
; modos: luta
InputDirection:
    ldy OtherFighter                            ; EA01  A4 65       direcional -> codigo de direcao relativo ao lado que o lutador olha (tabela DirCodeTbl)
    lda FighterX,x                              ; EA03  B5 08
    cmp a:FighterX,y                            ; EA05  D9 08 00
    bne L3F_EA0F                                ; EA08  D0 05
    lda FighterFlip,x                           ; EA0A  B5 04
    bne L3F_EA0F                                ; EA0C  D0 01
    clc                                         ; EA0E  18
L3F_EA0F:
    lda JoyState,x                              ; EA0F  B5 F2
    and #$0F                                    ; EA11  29 0F
    bcc L3F_EA1D                                ; EA13  90 08
    tay                                         ; EA15  A8
    and #$03                                    ; EA16  29 03
    beq L3F_EA1E                                ; EA18  F0 04
    tya                                         ; EA1A  98
    eor #$03                                    ; EA1B  49 03
L3F_EA1D:
    tay                                         ; EA1D  A8
L3F_EA1E:
    lda DirCodeTbl,y                            ; EA1E  B9 63 E9    [idx $00..$0F]
    sta InputDir,x                              ; EA21  95 86
    rts                                         ; EA23  60


; <- jmp InputUpdate
; modos: luta
InputCommands:
    lda ram_033E,x                              ; EA24  BD 3E 03    reconhecedor: zp_D7/D8 = lista de especiais do personagem (slot 8 da ficha, ram_033E/0340), zp_DA/zp_DB = JoyState/JoyPrev espelhados por FighterFlip, zp_DC = lutador, zp_D9 = posicao na lista
    sta zp_D7                                   ; EA27  85 D7
    lda ram_0340,x                              ; EA29  BD 40 03
    sta zp_D8                                   ; EA2C  85 D8
    lda JoyState,x                              ; EA2E  B5 F2
    sta zp_DA                                   ; EA30  85 DA
    ldy FighterFlip,x                           ; EA32  B4 04
    beq L3F_EA40                                ; EA34  F0 0A
    and #$03                                    ; EA36  29 03
    beq L3F_EA40                                ; EA38  F0 06
    lda zp_DA                                   ; EA3A  A5 DA
    eor #$03                                    ; EA3C  49 03
    sta zp_DA                                   ; EA3E  85 DA
L3F_EA40:
    lda JoyPrev,x                               ; EA40  B5 F6
    sta zp_DB                                   ; EA42  85 DB
    ldy FighterFlip,x                           ; EA44  B4 04
    beq L3F_EA52                                ; EA46  F0 0A
    and #$03                                    ; EA48  29 03
    beq L3F_EA52                                ; EA4A  F0 06
    lda zp_DB                                   ; EA4C  A5 DB
    eor #$03                                    ; EA4E  49 03
    sta zp_DB                                   ; EA50  85 DB
L3F_EA52:
    stx zp_DC                                   ; EA52  86 DC
    ldy #$00                                    ; EA54  A0 00
    sty zp_D9                                   ; EA56  84 D9

; <- jmp InputCommands
; modos: luta
CmdWalkLoop:
    lda (zp_D7),y                               ; EA58  B1 D7       [le bancos $3F] chave = lista[zp_D9], bit 7 = fim da lista ($FF); despacha CmdStep[chave] com Y = chave
    bmi CmdWalkEnd                              ; EA5A  30 17
    tay                                         ; EA5C  A8
    jsr CmdStepDispatch                         ; EA5D  20 6A EA
    inx                                         ; EA60  E8          x += 2 por entrada da lista: x = lutador + 2*posicao indexa os arrays intercalados CmdMotionStep/CmdMotionWin (par = P1, impar = P2)
    inx                                         ; EA61  E8
    ldy zp_D9                                   ; EA62  A4 D9
    iny                                         ; EA64  C8
    sty zp_D9                                   ; EA65  84 D9
    jmp CmdWalkLoop                             ; EA67  4C 58 EA


; <- jsr InputCommands
; modos: luta
CmdStepDispatch:
    lda CmdStepHi,y                             ; EA6A  B9 89 EA    [idx $02..$07] salta para CmdStep[chave] via CmdStepLo/CmdStepHi (endereco-1 + RTS), Y = chave $00-$12
    pha                                         ; EA6D  48
    lda CmdStepLo,y                             ; EA6E  B9 76 EA    [idx $02..$07]
    pha                                         ; EA71  48
    rts                                         ; EA72  60


; modos: luta
CmdWalkEnd:
    ldx zp_DC                                   ; EA73  A6 DC       fim da lista: recupera x = lutador (zp_DC) e retorna
    rts                                         ; EA75  60

CmdStepLo:
    .byte <(CmdStepMotion-1)                    ; EA76  4A
    .byte <(CmdStepMotion-1)                    ; EA77  4A
    .byte <(CmdStepMotion-1)                    ; EA78  4A
    .byte <(CmdStepMotion-1)                    ; EA79  4A
    .byte <(CmdStepMotion-1)                    ; EA7A  4A
    .byte <(CmdStepMotion-1)                    ; EA7B  4A
    .byte <(CmdStepMotion-1)                    ; EA7C  4A
    .byte <(CmdStepMotion-1)                    ; EA7D  4A
    .byte <(CmdStepCharge-1)                    ; EA7E  9B
    .byte <(CmdStepCharge-1)                    ; EA7F  9B
    .byte <(CmdStepCharge-1)                    ; EA80  9B
    .byte <(CmdStepCharge-1)                    ; EA81  9B
    .byte <(CmdStepCharge-1)                    ; EA82  9B
    .byte <(CmdStepCharge-1)                    ; EA83  9B
    .byte <(CmdStepMash-1)                      ; EA84  FC
    .byte <(CmdStepMash-1)                      ; EA85  FC
    .byte <(CmdStepMotion-1)                    ; EA86  4A
    .byte <(CmdStepBothBtn-1)                   ; EA87  31
    .byte <(CmdStepNone-1)                      ; EA88  49
CmdStepHi:
    .byte >(CmdStepMotion-1)                    ; EA89  EB          19 chaves: $00-$07 e $10 movimento (EB4B), $08-$0D carga (EA9C), $0E/$0F 3x botao (EAFD), $11 A+B juntos (EB32), $12 vazio (EB4A)
    .byte >(CmdStepMotion-1)                    ; EA8A  EB
    .byte >(CmdStepMotion-1)                    ; EA8B  EB
    .byte >(CmdStepMotion-1)                    ; EA8C  EB
    .byte >(CmdStepMotion-1)                    ; EA8D  EB
    .byte >(CmdStepMotion-1)                    ; EA8E  EB
    .byte >(CmdStepMotion-1)                    ; EA8F  EB
    .byte >(CmdStepMotion-1)                    ; EA90  EB
    .byte >(CmdStepCharge-1)                    ; EA91  EA
    .byte >(CmdStepCharge-1)                    ; EA92  EA
    .byte >(CmdStepCharge-1)                    ; EA93  EA
    .byte >(CmdStepCharge-1)                    ; EA94  EA
    .byte >(CmdStepCharge-1)                    ; EA95  EA
    .byte >(CmdStepCharge-1)                    ; EA96  EA
    .byte >(CmdStepMash-1)                      ; EA97  EA
    .byte >(CmdStepMash-1)                      ; EA98  EA
    .byte >(CmdStepMotion-1)                    ; EA99  EB
    .byte >(CmdStepBothBtn-1)                   ; EA9A  EB
    .byte >(CmdStepNone-1)                      ; EA9B  EB

; ------------------------------------------------------------------------------------------------
; CARGA, 3 fases: segurar a direcao por $3C (60) quadros, soltar apertando a direcao de liberacao
; (byte seguinte da sequencia) numa janela de 8 quadros, entao o botao exigido na mesma janela. (nt)
; <- tabela CmdStepLo
CmdStepCharge:
    tya                                         ; EA9C  98          (nt)
    asl a                                       ; EA9D  0A          (nt)
    asl a                                       ; EA9E  0A          (nt)
    adc CmdMotionStep,x                         ; EA9F  75 90       (nt)
    tay                                         ; EAA1  A8          (nt)
    lda CmdMotionStep,x                         ; EAA2  B5 90       (nt)
    beq CmdChargeHold                           ; EAA4  F0 07       (nt)
    cmp #$01                                    ; EAA6  C9 01       (nt)
    beq CmdChargeRelease                        ; EAA8  F0 2A       (nt)
    jmp CmdChargeButton                         ; EAAA  4C E1 EA    (nt)


CmdChargeHold:
    lda CmdMotionTbl,y                          ; EAAD  B9 67 E0    fase 0: direcao de carga apertada -> conta quadros (satura em $3C); soltou antes de 60 -> zera (nt)
    and zp_DA                                   ; EAB0  25 DA       (nt)
    bne CmdChargeTick                           ; EAB2  D0 17       (nt)
    lda CmdMotionWin,x                          ; EAB4  B5 9E       (nt)
    cmp #$3C                                    ; EAB6  C9 3C       (nt)
    bcc CmdChargeReset                          ; EAB8  90 0A       (nt)
    lda #$08                                    ; EABA  A9 08       (nt)
    sta CmdMotionWin,x                          ; EABC  95 9E       (nt)
    inc CmdMotionStep,x                         ; EABE  F6 90       (nt)
    iny                                         ; EAC0  C8          (nt)
    jmp CmdChargeRelease                        ; EAC1  4C D4 EA    (nt)


; <- jmp CmdChargeRelease
CmdChargeReset:
    lda #$00                                    ; EAC4  A9 00       zera o passo e a janela do comando corrente (nt)
    sta CmdMotionStep,x                         ; EAC6  95 90       (nt)
    sta CmdMotionWin,x                          ; EAC8  95 9E       (nt)
    rts                                         ; EACA  60          (nt)


CmdChargeTick:
    inc CmdMotionWin,x                          ; EACB  F6 9E       segurando: contador de quadros, satura em $3C (60) (nt)
    bne L3F_EAD3                                ; EACD  D0 04       (nt)
    lda #$3C                                    ; EACF  A9 3C       (nt)
    sta CmdMotionWin,x                          ; EAD1  95 9E       (nt)
L3F_EAD3:
    rts                                         ; EAD3  60          (nt)


; <- jmp CmdChargeHold
CmdChargeRelease:
    lda CmdMotionTbl,y                          ; EAD4  B9 67 E0    fase 1: direcao de liberacao apertada numa janela de 8 quadros (EAF8 desconta a cada erro) (nt)
    and zp_DA                                   ; EAD7  25 DA       (nt)
    beq CmdChargeWinTick                        ; EAD9  F0 1D       (nt)
    lda #$08                                    ; EADB  A9 08       (nt)
    sta CmdMotionWin,x                          ; EADD  95 9E       (nt)
    inc CmdMotionStep,x                         ; EADF  F6 90       (nt)

; <- jmp CmdStepCharge
CmdChargeButton:
    ldy zp_D9                                   ; EAE1  A4 D9       fase 2: botao exigido (CmdKeyAttackTbl[chave] == InputAttack) -> CmdMoveIdx[lutador] = posicao na lista (nt)
    lda (zp_D7),y                               ; EAE3  B1 D7       (nt)
    tay                                         ; EAE5  A8          (nt)
    lda CmdKeyAttackTbl,y                       ; EAE6  B9 AF E0    (nt)
    ldy zp_DC                                   ; EAE9  A4 DC       (nt)
    cmp a:InputAttack,y                         ; EAEB  D9 88 00    (nt)
    bne CmdChargeWinTick                        ; EAEE  D0 08       (nt)
    lda zp_D9                                   ; EAF0  A5 D9       (nt)
    sta a:CmdMoveIdx,y                          ; EAF2  99 8E 00    (nt)
    jmp CmdChargeReset                          ; EAF5  4C C4 EA    (nt)


CmdChargeWinTick:
    dec CmdMotionWin,x                          ; EAF8  D6 9E       janela expirou (< 0) -> zera o comando (nt)
    bmi CmdChargeReset                          ; EAFA  30 C8       (nt)
    rts                                         ; EAFC  60          (nt)


; <- tabela CmdStepLo
CmdStepMash:
    lda CmdKeyAttackTbl,y                       ; EAFD  B9 AF E0    3x o MESMO botao (CmdKeyAttackTbl[chave] == InputAttack), intervalos de ate 8 quadros. (nt) (nt)
    ldy zp_DC                                   ; EB00  A4 DC       (nt)
    cmp a:InputAttack,y                         ; EB02  D9 88 00    (nt)
    beq CmdMashCount                            ; EB05  F0 05       (nt)
    lda CmdMotionStep,x                         ; EB07  B5 90       (nt)
    bne CmdMashGap                              ; EB09  D0 1D       (nt)
    rts                                         ; EB0B  60          (nt)


CmdMashCount:
    ldy CmdMotionStep,x                         ; EB0C  B4 90       aperto certo: conta (1..2), zera o intervalo (nt)
    iny                                         ; EB0E  C8          (nt)
    cpy #$03                                    ; EB0F  C0 03       (nt)
    bcs CmdMashDone                             ; EB11  B0 07       (nt)
    sty CmdMotionStep,x                         ; EB13  94 90       (nt)
    lda #$00                                    ; EB15  A9 00       (nt)
    sta CmdMotionWin,x                          ; EB17  95 9E       (nt)
    rts                                         ; EB19  60          (nt)


CmdMashDone:
    lda zp_D9                                   ; EB1A  A5 D9       3o aperto -> CmdMoveIdx[lutador] = posicao na lista (nt)
    ldy zp_DC                                   ; EB1C  A4 DC       (nt)
    sta a:CmdMoveIdx,y                          ; EB1E  99 8E 00    (nt)
CmdMashReset:
    lda #$00                                    ; EB21  A9 00       (nt)
    sta CmdMotionStep,x                         ; EB23  95 90       (nt)
    sta CmdMotionWin,x                          ; EB25  95 9E       (nt)
    rts                                         ; EB27  60          (nt)


CmdMashGap:
    ldy CmdMotionWin,x                          ; EB28  B4 9E       intervalo entre apertos passou de 8 -> zera (nt)
    iny                                         ; EB2A  C8          (nt)
    cpy #$08                                    ; EB2B  C0 08       (nt)
    bcs CmdMashReset                            ; EB2D  B0 F2       (nt)
    sty CmdMotionWin,x                          ; EB2F  94 9E       (nt)
    rts                                         ; EB31  60          (nt)


; <- tabela CmdStepLo
CmdStepBothBtn:
    lda zp_DA                                   ; EB32  A5 DA       A+B apertados juntos na borda de subida (agora $C0, antes nao) -> CmdMoveIdx[lutador] = posicao na lista. (nt) (nt)
    and #$C0                                    ; EB34  29 C0       (nt)
    cmp #$C0                                    ; EB36  C9 C0       (nt)
    bne L3F_EB49                                ; EB38  D0 0F       (nt)
    lda zp_DB                                   ; EB3A  A5 DB       (nt)
    and #$C0                                    ; EB3C  29 C0       (nt)
    cmp #$C0                                    ; EB3E  C9 C0       (nt)
    beq L3F_EB49                                ; EB40  F0 07       (nt)
    ldy zp_DC                                   ; EB42  A4 DC       (nt)
    lda zp_D9                                   ; EB44  A5 D9       (nt)
    sta a:CmdMoveIdx,y                          ; EB46  99 8E 00    (nt)
L3F_EB49:
    rts                                         ; EB49  60          (nt)


; <- tabela CmdStepLo
CmdStepNone:
    rts                                         ; EB4A  60          chave $12: lugar vago; seus 4 bytes de sequencia (E0AF-E0B2) sao a CmdKeyAttackTbl — inofensivo (nt)


; ------------------------------------------------------------------------------------------------
; SEQUENCIA DE DIRECOES: Y = chave*4 + passo. Um passo vale quando o bit exigido esta apertado E
; alguma direcao e' NOVA (apertada agora, ausente no quadro anterior) — segurando parado nao avanca.
; Janela de $0C (12) quadros entre passos; byte $00 encerra a sequencia -> fase do botao (outras 12).
; <- tabela CmdStepLo
; modos: luta
CmdStepMotion:
    tya                                         ; EB4B  98
    asl a                                       ; EB4C  0A
    asl a                                       ; EB4D  0A
    adc CmdMotionStep,x                         ; EB4E  75 90
    tay                                         ; EB50  A8
    lda CmdMotionTbl,y                          ; EB51  B9 67 E0    [idx $08..$1F]
    beq CmdMotionBtnWin                         ; EB54  F0 29
    lda zp_DA                                   ; EB56  A5 DA
    and #$0F                                    ; EB58  29 0F
    sta zp_DA                                   ; EB5A  85 DA
    and zp_DB                                   ; EB5C  25 DB
    cmp zp_DA                                   ; EB5E  C5 DA
    beq CmdMotionWinTick                        ; EB60  F0 07
    lda zp_DA                                   ; EB62  A5 DA
    and CmdMotionTbl,y                          ; EB64  39 67 E0    [idx $08..$1E]
    bne CmdMotionAdvance                        ; EB67  D0 0A
CmdMotionWinTick:
    ldy CmdMotionWin,x                          ; EB69  B4 9E       nenhuma direcao nova / bit exigido solto: conta a janela; passou de 12 -> zera o comando
    iny                                         ; EB6B  C8
    cpy #$0C                                    ; EB6C  C0 0C
    bcs CmdMotionReset                          ; EB6E  B0 2C
    sty CmdMotionWin,x                          ; EB70  94 9E
    rts                                         ; EB72  60


; modos: luta
CmdMotionAdvance:
    lda #$00                                    ; EB73  A9 00       passo cumprido: zera a janela, avanca o passo; D3F_E068,y (MESMO y) le o byte SEGUINTE — $0 cai ja na fase do botao
    sta CmdMotionWin,x                          ; EB75  95 9E
    inc CmdMotionStep,x                         ; EB77  F6 90
    lda D3F_E068,y                              ; EB79  B9 68 E0    [idx $08..$1E]
    beq CmdMotionButton                         ; EB7C  F0 0A
    rts                                         ; EB7E  60


; modos: luta
CmdMotionBtnWin:
    ldy CmdMotionWin,x                          ; EB7F  B4 9E       fase do botao: mesma janela de 12 quadros
    iny                                         ; EB81  C8
    cpy #$0C                                    ; EB82  C0 0C
    bcs CmdMotionReset                          ; EB84  B0 16
    sty CmdMotionWin,x                          ; EB86  94 9E
CmdMotionButton:
    ldy zp_D9                                   ; EB88  A4 D9       botao exigido (CmdKeyAttackTbl[chave] == InputAttack) -> CmdMoveIdx[lutador] = posicao na lista; zera o comando
    lda (zp_D7),y                               ; EB8A  B1 D7       [le bancos $3F]
    tay                                         ; EB8C  A8
    lda CmdKeyAttackTbl,y                       ; EB8D  B9 AF E0    [idx $02..$07]
    ldy zp_DC                                   ; EB90  A4 DC
    cmp a:InputAttack,y                         ; EB92  D9 88 00
    bne L3F_EBA2                                ; EB95  D0 0B
    lda zp_D9                                   ; EB97  A5 D9
    sta a:CmdMoveIdx,y                          ; EB99  99 8E 00
CmdMotionReset:
    lda #$00                                    ; EB9C  A9 00
    sta CmdMotionStep,x                         ; EB9E  95 90
    sta CmdMotionWin,x                          ; EBA0  95 9E
L3F_EBA2:
    rts                                         ; EBA2  60


; <- jsr FightersUpdate
; modos: intro do round, luta, fim do round
LoadHitBoxesBoth:
    ldx #$01                                    ; EBA3  A2 01       processa o lutador 1 e depois o 0 (chamado por FightersUpdate)

; <- jmp L3F_ECD4
; modos: intro do round, luta, fim do round
LoadHitBoxes:
    lda a:zp_1C,x                               ; EBA5  BD 1C 00    mapeia o banco de colisao em $8000; registro do quadro +3/+4: caixas de corpo 1/2 e de ataque (h = 0 ausenta), espelhadas por FighterFlip, ataque clampado em $20/$E0
    ora #$80                                    ; EBA8  09 80
    sta MMC5_PRG_8000                           ; EBAA  8D 14 51
    lda a:FighterStateBank,x                    ; EBAD  BD 1A 00
    ora #$80                                    ; EBB0  09 80
    sta MMC5_PRG_A000                           ; EBB2  8D 15 51
    lda a:FighterFramePtrHi,x                   ; EBB5  BD 2C 00
    sta zp_D8                                   ; EBB8  85 D8
    lda a:FighterFramePtrLo,x                   ; EBBA  BD 2A 00
    sta zp_D7                                   ; EBBD  85 D7
    ldy #$04                                    ; EBBF  A0 04
    lda (zp_D7),y                               ; EBC1  B1 D7       [le bancos $01]
    bne L3F_EBEC                                ; EBC3  D0 27
    sta a:Body1L,x                              ; EBC5  9D 46 00
    sta a:Body1R,x                              ; EBC8  9D 4A 00
    sta a:Body1T,x                              ; EBCB  9D 48 00
    sta a:Body1B,x                              ; EBCE  9D 4C 00
    sta a:Body2L,x                              ; EBD1  9D 4E 00
    sta a:Body2R,x                              ; EBD4  9D 52 00
    sta a:Body2T,x                              ; EBD7  9D 50 00
    sta a:Body2B,x                              ; EBDA  9D 54 00
    sta a:AtkL,x                                ; EBDD  9D 56 00
    sta a:AtkR,x                                ; EBE0  9D 5A 00
    sta a:AtkT,x                                ; EBE3  9D 58 00
    sta a:AtkB,x                                ; EBE6  9D 5C 00
    jmp LoadBoxesNext                           ; EBE9  4C E7 EC


L3F_EBEC:
    sta zp_D9                                   ; EBEC  85 D9
    dey                                         ; EBEE  88
    lda (zp_D7),y                               ; EBEF  B1 D7       [le bancos $01]
    sta zp_D7                                   ; EBF1  85 D7
    lda zp_D9                                   ; EBF3  A5 D9
    sta zp_D8                                   ; EBF5  85 D8
    ldy #$00                                    ; EBF7  A0 00
    lda (zp_D7),y                               ; EBF9  B1 D7       [le bancos $00]
    bne L3F_EC0C                                ; EBFB  D0 0F
    sta a:Body1L,x                              ; EBFD  9D 46 00
    sta a:Body1R,x                              ; EC00  9D 4A 00
    sta a:Body1T,x                              ; EC03  9D 48 00
    sta a:Body1B,x                              ; EC06  9D 4C 00
    jmp LoadBoxBody2                            ; EC09  4C 45 EC


L3F_EC0C:
    sta a:Body1B,x                              ; EC0C  9D 4C 00
    iny                                         ; EC0F  C8
    clc                                         ; EC10  18
    lda FighterY,x                              ; EC11  B5 0C
    adc (zp_D7),y                               ; EC13  71 D7       [le bancos $00]
    sta a:Body1T,x                              ; EC15  9D 48 00
    clc                                         ; EC18  18
    adc a:Body1B,x                              ; EC19  7D 4C 00
    sta a:Body1B,x                              ; EC1C  9D 4C 00
    iny                                         ; EC1F  C8
    lda FighterFlip,x                           ; EC20  B5 04
    bne L3F_EC36                                ; EC22  D0 12
    clc                                         ; EC24  18
    lda FighterX,x                              ; EC25  B5 08
    adc (zp_D7),y                               ; EC27  71 D7       [le bancos $00]
    sta a:Body1L,x                              ; EC29  9D 46 00
    iny                                         ; EC2C  C8
    clc                                         ; EC2D  18
    adc (zp_D7),y                               ; EC2E  71 D7       [le bancos $00]
    sta a:Body1R,x                              ; EC30  9D 4A 00
    jmp LoadBoxBody2                            ; EC33  4C 45 EC


L3F_EC36:
    sec                                         ; EC36  38
    lda FighterX,x                              ; EC37  B5 08
    sbc (zp_D7),y                               ; EC39  F1 D7       [le bancos $00]
    sta a:Body1R,x                              ; EC3B  9D 4A 00
    iny                                         ; EC3E  C8
    sec                                         ; EC3F  38
    sbc (zp_D7),y                               ; EC40  F1 D7       [le bancos $00]
    sta a:Body1L,x                              ; EC42  9D 46 00

; <- jmp L3F_EBEC, jmp L3F_EC0C
; modos: intro do round, luta
LoadBoxBody2:
    iny                                         ; EC45  C8          le a caixa de corpo 2 (altura 0 = ausente), espelhada por FighterFlip
    lda (zp_D7),y                               ; EC46  B1 D7       [le bancos $00]
    bne L3F_EC59                                ; EC48  D0 0F
    sta a:Body2L,x                              ; EC4A  9D 4E 00
    sta a:Body2R,x                              ; EC4D  9D 52 00
    sta a:Body2T,x                              ; EC50  9D 50 00
    sta a:Body2B,x                              ; EC53  9D 54 00
    jmp LoadBoxAttack                           ; EC56  4C 92 EC


L3F_EC59:
    sta a:Body2B,x                              ; EC59  9D 54 00
    iny                                         ; EC5C  C8
    clc                                         ; EC5D  18
    lda FighterY,x                              ; EC5E  B5 0C
    adc (zp_D7),y                               ; EC60  71 D7       [le bancos $00]
    sta a:Body2T,x                              ; EC62  9D 50 00
    clc                                         ; EC65  18
    adc a:Body2B,x                              ; EC66  7D 54 00
    sta a:Body2B,x                              ; EC69  9D 54 00
    iny                                         ; EC6C  C8
    lda FighterFlip,x                           ; EC6D  B5 04
    bne L3F_EC83                                ; EC6F  D0 12
    clc                                         ; EC71  18
    lda FighterX,x                              ; EC72  B5 08
    adc (zp_D7),y                               ; EC74  71 D7       [le bancos $00]
    sta a:Body2L,x                              ; EC76  9D 4E 00
    iny                                         ; EC79  C8
    clc                                         ; EC7A  18
    adc (zp_D7),y                               ; EC7B  71 D7       [le bancos $00]
    sta a:Body2R,x                              ; EC7D  9D 52 00
    jmp LoadBoxAttack                           ; EC80  4C 92 EC


L3F_EC83:
    sec                                         ; EC83  38
    lda FighterX,x                              ; EC84  B5 08
    sbc (zp_D7),y                               ; EC86  F1 D7       [le bancos $00]
    sta a:Body2R,x                              ; EC88  9D 52 00
    iny                                         ; EC8B  C8
    sec                                         ; EC8C  38
    sbc (zp_D7),y                               ; EC8D  F1 D7       [le bancos $00]
    sta a:Body2L,x                              ; EC8F  9D 4E 00

; <- jmp L3F_EC36, jmp L3F_EC59
; modos: intro do round, luta
LoadBoxAttack:
    iny                                         ; EC92  C8          le a caixa de ataque (altura 0 = ausente), travada em $20-$E0
    lda (zp_D7),y                               ; EC93  B1 D7       [le bancos $00]
    bne L3F_ECA6                                ; EC95  D0 0F
    sta a:AtkL,x                                ; EC97  9D 56 00
    sta a:AtkR,x                                ; EC9A  9D 5A 00
    sta a:AtkT,x                                ; EC9D  9D 58 00
    sta a:AtkB,x                                ; ECA0  9D 5C 00
    jmp LoadBoxesNext                           ; ECA3  4C E7 EC


L3F_ECA6:
    sta a:AtkB,x                                ; ECA6  9D 5C 00
    iny                                         ; ECA9  C8
    clc                                         ; ECAA  18
    lda FighterY,x                              ; ECAB  B5 0C
    adc (zp_D7),y                               ; ECAD  71 D7       [le bancos $00]
    sta a:AtkT,x                                ; ECAF  9D 58 00
    clc                                         ; ECB2  18
    adc a:AtkB,x                                ; ECB3  7D 5C 00
    sta a:AtkB,x                                ; ECB6  9D 5C 00
    iny                                         ; ECB9  C8
    lda FighterFlip,x                           ; ECBA  B5 04
    bne L3F_ECD4                                ; ECBC  D0 16
    clc                                         ; ECBE  18
    lda FighterX,x                              ; ECBF  B5 08
    adc (zp_D7),y                               ; ECC1  71 D7       [le bancos $00]
    sta a:AtkL,x                                ; ECC3  9D 56 00
    iny                                         ; ECC6  C8
    clc                                         ; ECC7  18
    adc (zp_D7),y                               ; ECC8  71 D7       [le bancos $00]
    bcc L3F_ECCE                                ; ECCA  90 02
    lda #$E0                                    ; ECCC  A9 E0
L3F_ECCE:
    sta a:AtkR,x                                ; ECCE  9D 5A 00
    jmp LoadBoxesNext                           ; ECD1  4C E7 EC


L3F_ECD4:
    sec                                         ; ECD4  38
    lda FighterX,x                              ; ECD5  B5 08
    sbc (zp_D7),y                               ; ECD7  F1 D7       [le bancos $00]
    sta a:AtkR,x                                ; ECD9  9D 5A 00
    iny                                         ; ECDC  C8
    sec                                         ; ECDD  38
    sbc (zp_D7),y                               ; ECDE  F1 D7       [le bancos $00]
    bcs L3F_ECE4                                ; ECE0  B0 02
    lda #$20                                    ; ECE2  A9 20
L3F_ECE4:
    sta a:AtkL,x                                ; ECE4  9D 56 00

; <- jmp LoadHitBoxesBoth, jmp L3F_EC83, jmp L3F_ECA6
; modos: intro do round, luta, fim do round
LoadBoxesNext:
    dex                                         ; ECE7  CA          fim das caixas: recarrega para o lutador 0 ou arma o HitTest (x=1 ataca y=0)
    bne L3F_ECED                                ; ECE8  D0 03
    jmp LoadHitBoxes                            ; ECEA  4C A5 EB


L3F_ECED:
    ldx #$01                                    ; ECED  A2 01
    ldy #$00                                    ; ECEF  A0 00

; <- jmp L3F_ED64
; modos: intro do round, luta, fim do round
HitTest:
    lda a:HitThisFrame,x                        ; ECF1  BD 3E 00    caixa de ataque de X contra corpo 1/2 de Y: um acerto por quadro (zp_3E), esgota AttackHitsLeft
    beq L3F_ECF9                                ; ECF4  F0 03
    jmp HitTestNext                             ; ECF6  4C 7A ED


L3F_ECF9:
    lda a:AttackHitsLeft,x                      ; ECF9  BD 28 00
    beq HitTestNext                             ; ECFC  F0 7C
    lda a:AtkR,x                                ; ECFE  BD 5A 00
    beq HitTestNext                             ; ED01  F0 77
    cmp a:Body1L,y                              ; ED03  D9 46 00
    bcc L3F_ED20                                ; ED06  90 18
    lda a:Body1R,y                              ; ED08  B9 4A 00
    cmp a:AtkL,x                                ; ED0B  DD 56 00
    bcc L3F_ED20                                ; ED0E  90 10
    lda a:AtkB,x                                ; ED10  BD 5C 00
    cmp a:Body1T,y                              ; ED13  D9 48 00
    bcc L3F_ED20                                ; ED16  90 08
    lda a:Body1B,y                              ; ED18  B9 4C 00
    cmp a:AtkT,x                                ; ED1B  DD 58 00
    bcs L3F_ED40                                ; ED1E  B0 20
L3F_ED20:
    lda a:AtkR,x                                ; ED20  BD 5A 00
    cmp a:Body2L,y                              ; ED23  D9 4E 00
    bcc HitTestNext                             ; ED26  90 52
    lda a:Body2R,y                              ; ED28  B9 52 00
    cmp a:AtkL,x                                ; ED2B  DD 56 00
    bcc HitTestNext                             ; ED2E  90 4A
    lda a:AtkB,x                                ; ED30  BD 5C 00
    cmp a:Body2T,y                              ; ED33  D9 50 00
    bcc HitTestNext                             ; ED36  90 42
    lda a:Body2B,y                              ; ED38  B9 54 00
    cmp a:AtkT,x                                ; ED3B  DD 58 00
    bcc HitTestNext                             ; ED3E  90 3A
L3F_ED40:
    dec a:AttackHitsLeft,x                      ; ED40  DE 28 00
    inc a:HitThisFrame,x                        ; ED43  FE 3E 00
    lda a:EffectType,x                          ; ED46  BD 3C 00
    sta a:HitReactClass,y                       ; ED49  99 16 00
    lda a:FighterState,x                        ; ED4C  BD 26 00
    and #$F8                                    ; ED4F  29 F8
    cmp #$A0                                    ; ED51  C9 A0
    bne L3F_ED64                                ; ED53  D0 0F
    lda InputDir,x                              ; ED55  B5 86
    cmp #$06                                    ; ED57  C9 06
    bne HitTestApply                            ; ED59  D0 11
    lda FighterFlip,x                           ; ED5B  B5 04       (nt)
    eor #$40                                    ; ED5D  49 40       (nt)
    sta FighterFlip,x                           ; ED5F  95 04       (nt)
    jmp HitTestApply                            ; ED61  4C 6C ED    (nt)


L3F_ED64:
    lda a:FighterNextPtrHi,x                    ; ED64  BD 24 00
    bne HitTestApply                            ; ED67  D0 03
    jsr HitFreeze                               ; ED69  20 00 E0

; <- jmp L3F_ECF9
; modos: luta
HitTestApply:
    lda a:EffectParam,x                         ; ED6C  BD 3A 00    acerto: passa EffectParam e o lutador atingido (Y) para a rotina de dano
    sta zp_D8                                   ; ED6F  85 D8
    stx zp_D7                                   ; ED71  86 D7
    tya                                         ; ED73  98
    tax                                         ; ED74  AA
    jsr HitDamageApply                          ; ED75  20 83 ED
    ldx zp_D7                                   ; ED78  A6 D7

; <- jmp L3F_ECED
; modos: intro do round, luta, fim do round
HitTestNext:
    dex                                         ; ED7A  CA          troca os papeis (0 ataca 1) e repete o HitTest; senao encerra
    bne L3F_ED82                                ; ED7B  D0 05
    ldy #$01                                    ; ED7D  A0 01
    jmp HitTest                                 ; ED7F  4C F1 EC


L3F_ED82:
    rts                                         ; ED82  60


; <- jsr L3F_E8ED, jsr L3F_ED64
; modos: luta
HitDamageApply:
    lda a:FighterState,x                        ; ED83  BD 26 00    aplica o dano: se o alvo esta em guarda compativel, bloqueia; senao soma o dano pendente
    and #$F8                                    ; ED86  29 F8
    cmp #$28                                    ; ED88  C9 28
    bne L3F_EDC2                                ; ED8A  D0 36
    lda a:FighterState,x                        ; ED8C  BD 26 00
    ror a                                       ; ED8F  6A
    ror a                                       ; ED90  6A
    ror a                                       ; ED91  6A
    and #$C0                                    ; ED92  29 C0
    and a:HitReactClass,x                       ; ED94  3D 16 00
    beq L3F_EDC2                                ; ED97  F0 29
    lda #$01                                    ; ED99  A9 01
    sta zp_DB                                   ; ED9B  85 DB
    lda zp_D8                                   ; ED9D  A5 D8
    and #$E0                                    ; ED9F  29 E0
    rol a                                       ; EDA1  2A
    rol a                                       ; EDA2  2A
    rol a                                       ; EDA3  2A
    rol a                                       ; EDA4  2A
    clc                                         ; EDA5  18
    adc a:FighterDmgPending,x                   ; EDA6  7D 14 00
    sta a:FighterDmgPending,x                   ; EDA9  9D 14 00
    cmp FighterHP,x                             ; EDAC  D5 0E
    bcc L3F_EDB5                                ; EDAE  90 05
    beq L3F_EDB5                                ; EDB0  F0 03
    jmp HitDamageKO                             ; EDB2  4C F7 EE


L3F_EDB5:
    lda ram_032A,x                              ; EDB5  BD 2A 03
    sta zp_D9                                   ; EDB8  85 D9
    lda ram_032C,x                              ; EDBA  BD 2C 03
    sta zp_DA                                   ; EDBD  85 DA
    jmp HitDamageSfx                            ; EDBF  4C C2 EE


L3F_EDC2:
    lda zp_D8                                   ; EDC2  A5 D8
    and #$1F                                    ; EDC4  29 1F
    clc                                         ; EDC6  18
    adc a:FighterDmgPending,x                   ; EDC7  7D 14 00
    sta a:FighterDmgPending,x                   ; EDCA  9D 14 00
    cmp FighterHP,x                             ; EDCD  D5 0E
    bcc L3F_EDD6                                ; EDCF  90 05
    beq L3F_EDD6                                ; EDD1  F0 03
    jmp HitDamageKO                             ; EDD3  4C F7 EE


L3F_EDD6:
    lda a:zp_62,x                               ; EDD6  BD 62 00
    beq L3F_EDE9                                ; EDD9  F0 0E
    lda #$00                                    ; EDDB  A9 00
    sta a:zp_5E,x                               ; EDDD  9D 5E 00
    sta a:zp_60,x                               ; EDE0  9D 60 00
    sta a:zp_62,x                               ; EDE3  9D 62 00
    jmp HitDamageReact                          ; EDE6  4C 4E EE


L3F_EDE9:
    lda a:HitReactClass,x                       ; EDE9  BD 16 00
    and #$3F                                    ; EDEC  29 3F
    tay                                         ; EDEE  A8
    cpy #$0B                                    ; EDEF  C0 0B
    bne L3F_EDF8                                ; EDF1  D0 05
    lda #$3C                                    ; EDF3  A9 3C
    sta HitStop                                 ; EDF5  8D 0C 04
L3F_EDF8:
    clc                                         ; EDF8  18
    lda a:FighterState,x                        ; EDF9  BD 26 00
    and #$03                                    ; EDFC  29 03
    beq L3F_EE15                                ; EDFE  F0 15
    lda D3F_EF20,y                              ; EE00  B9 20 EF    [idx $00..$0C]
    adc a:zp_60,x                               ; EE03  7D 60 00
    sta a:zp_60,x                               ; EE06  9D 60 00
    lda D3F_EF06,y                              ; EE09  B9 06 EF    [idx $00..$0C]
    adc a:zp_5E,x                               ; EE0C  7D 5E 00
    sta a:zp_5E,x                               ; EE0F  9D 5E 00
    jmp HitDamageHeavy                          ; EE12  4C 27 EE


L3F_EE15:
    lda D3F_EF2D,y                              ; EE15  B9 2D EF    [idx $00..$0B]
    adc a:zp_60,x                               ; EE18  7D 60 00
    sta a:zp_60,x                               ; EE1B  9D 60 00
    lda D3F_EF13,y                              ; EE1E  B9 13 EF    [idx $00..$0B]
    adc a:zp_5E,x                               ; EE21  7D 5E 00
    sta a:zp_5E,x                               ; EE24  9D 5E 00

; <- jmp L3F_EDE9
; modos: luta
HitDamageHeavy:
    cmp #$20                                    ; EE27  C9 20       dano >= $20: zera o estado, arma HitStop=$78 e escolhe a reacao pesada
    bcc HitDamageReact                          ; EE29  90 23
    lda #$00                                    ; EE2B  A9 00
    sta a:zp_60,x                               ; EE2D  9D 60 00
    sta a:zp_5E,x                               ; EE30  9D 5E 00
    lda #$78                                    ; EE33  A9 78
    sta a:zp_62,x                               ; EE35  9D 62 00
    lda D3F_EF3A,y                              ; EE38  B9 3A EF    [idx $03..$0B]
    cmp #$06                                    ; EE3B  C9 06
    bne L3F_EE4B                                ; EE3D  D0 0C
    sta a:HitReactClass,x                       ; EE3F  9D 16 00    (nt)
    lda a:FighterState,x                        ; EE42  BD 26 00    (nt)
    and #$04                                    ; EE45  29 04       (nt)
    beq HitDamageReact                          ; EE47  F0 05       (nt)
    lda #$07                                    ; EE49  A9 07       (nt)
L3F_EE4B:
    sta a:HitReactClass,x                       ; EE4B  9D 16 00

; <- jmp L3F_EDD6, jmp HitDamageKO
; modos: luta
HitDamageReact:
    lda a:HitReactClass,x                       ; EE4E  BD 16 00    escolhe a reacao de dano (HitReactClass) e o estado correspondente
    cmp #$0C                                    ; EE51  C9 0C
    bne L3F_EE78                                ; EE53  D0 23
    lda ram_033A,x                              ; EE55  BD 3A 03
    sta zp_D9                                   ; EE58  85 D9
    lda ram_033C,x                              ; EE5A  BD 3C 03
    sta zp_DA                                   ; EE5D  85 DA
    lda zp_D8                                   ; EE5F  A5 D8
    and #$E0                                    ; EE61  29 E0
    asl a                                       ; EE63  0A
    rol a                                       ; EE64  2A
    rol a                                       ; EE65  2A
    rol a                                       ; EE66  2A
    sta zp_D8                                   ; EE67  85 D8
    txa                                         ; EE69  8A
    eor #$01                                    ; EE6A  49 01
    tay                                         ; EE6C  A8
    lda a:FighterChar,y                         ; EE6D  B9 00 00
    asl a                                       ; EE70  0A
    asl a                                       ; EE71  0A
    adc zp_D8                                   ; EE72  65 D8
    tay                                         ; EE74  A8
    jmp HitDamageTrans                          ; EE75  4C DF EE


L3F_EE78:
    txa                                         ; EE78  8A
    eor #$01                                    ; EE79  49 01
    tay                                         ; EE7B  A8
    lda a:FighterState,y                        ; EE7C  B9 26 00
    sec                                         ; EE7F  38
    sbc #$70                                    ; EE80  E9 70
    lsr a                                       ; EE82  4A
    lsr a                                       ; EE83  4A
    lsr a                                       ; EE84  4A
    cmp #$06                                    ; EE85  C9 06
    bcc L3F_EE8B                                ; EE87  90 02
    lda #$02                                    ; EE89  A9 02
L3F_EE8B:
    tay                                         ; EE8B  A8
    lda D3F_E055,y                              ; EE8C  B9 55 E0    [idx $00..$05]
    sta zp_DB                                   ; EE8F  85 DB
    lda a:FighterState,x                        ; EE91  BD 26 00
    and #$03                                    ; EE94  29 03
    cmp #$01                                    ; EE96  C9 01
    bne L3F_EEA7                                ; EE98  D0 0D
    lda ram_032E,x                              ; EE9A  BD 2E 03
    sta zp_D9                                   ; EE9D  85 D9
    lda ram_0330,x                              ; EE9F  BD 30 03
    sta zp_DA                                   ; EEA2  85 DA
    jmp HitDamageSfx                            ; EEA4  4C C2 EE


L3F_EEA7:
    cmp #$02                                    ; EEA7  C9 02
    bne L3F_EEB8                                ; EEA9  D0 0D
    lda ram_0336,x                              ; EEAB  BD 36 03
    sta zp_D9                                   ; EEAE  85 D9
    lda ram_0338,x                              ; EEB0  BD 38 03
    sta zp_DA                                   ; EEB3  85 DA
    jmp HitDamageSfx                            ; EEB5  4C C2 EE


L3F_EEB8:
    lda ram_0332,x                              ; EEB8  BD 32 03
    sta zp_D9                                   ; EEBB  85 D9
    lda ram_0334,x                              ; EEBD  BD 34 03
    sta zp_DA                                   ; EEC0  85 DA

; <- jmp L3F_EDB5, jmp L3F_EE78, jmp L3F_EEA7
; modos: luta
HitDamageSfx:
    stx zp_DC                                   ; EEC2  86 DC       toca o efeito sonoro do dano e indexa a tabela de reacao
    farcall SfxPlay                             ; EEC4  A9 EE 48 A9 D5 48 A9 3F .. -> 37:E401
    ldx zp_DC                                   ; EED6  A6 DC
    lda a:HitReactClass,x                       ; EED8  BD 16 00
    and #$3F                                    ; EEDB  29 3F
    asl a                                       ; EEDD  0A
    tay                                         ; EEDE  A8

; <- jmp L3F_EE15
; modos: luta
HitDamageTrans:
    lda a:FighterStateBank,x                    ; EEDF  BD 1A 00    carrega o banco de estados e aplica a transicao de dano (zp_DD=4)
    ora #$80                                    ; EEE2  09 80
    sta MMC5_PRG_A000                           ; EEE4  8D 15 51
    lda (zp_D9),y                               ; EEE7  B1 D9       [le bancos $01]
    sta zp_DB                                   ; EEE9  85 DB
    iny                                         ; EEEB  C8
    lda (zp_D9),y                               ; EEEC  B1 D9       [le bancos $01]
    sta zp_DC                                   ; EEEE  85 DC
    lda #$04                                    ; EEF0  A9 04
    sta zp_DD                                   ; EEF2  85 DD
    jmp StateCheckTransitions                   ; EEF4  4C CE E0


; <- jmp HitDamageApply, jmp L3F_EDC2
; modos: luta
HitDamageKO:
    lda a:HitReactClass,x                       ; EEF7  BD 16 00    dano mata: converte a classe de reacao para o estado de KO
    and #$1F                                    ; EEFA  29 1F
    tay                                         ; EEFC  A8
    lda D3F_EF47,y                              ; EEFD  B9 47 EF    [idx $00..$0C]
    sta a:HitReactClass,x                       ; EF00  9D 16 00
    jmp HitDamageReact                          ; EF03  4C 4E EE

D3F_EF06:
    .byte $07,$0B,$0F,$07,$0B,$0F,$08,$0F,$10,$10,$10,$10,$0B; EF06
D3F_EF13:
    .byte $07,$0A,$0D,$07,$0A,$0D,$08,$0D,$0E,$0E,$0E,$0E,$0A; EF13
D3F_EF20:
    .byte $28,$3C,$50,$28,$3C,$50,$82,$50,$78,$78,$78,$78,$64; EF20
D3F_EF2D:
    .byte $28,$32,$3C,$28,$32,$3C,$82,$3C,$50,$50,$50,$50,$64; EF2D
D3F_EF3A:
    .byte $07,$07,$07,$07,$07,$07,$06,$07,$07,$09,$0A,$07,$0C; EF3A
D3F_EF47:
    .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$09,$0A,$07,$0C,$03,$02,$02; EF47
    .byte $02,$02,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00; EF57
    .byte $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FE,$FE,$FE,$FE,$FD; EF67

; Um quadro de logica da luta: atualiza os dois lutadores (alternando a ordem a cada quadro) e desenha.
; <- farcall L3B_E455, farcall FadeIn, farcall FightFrame
; modos: intro do round, luta, fim do round
FightersUpdate:
    jsr LoadHitBoxesBoth                        ; EF74  20 A3 EB
    jsr ProjClash                               ; EF77  20 BB E8
    jsr GrabCheck                               ; EF7A  20 33 F0
    jsr FighterUpdate                           ; EF7D  20 99 EF
    lda CurFighter                              ; EF80  A5 64
    ldy OtherFighter                            ; EF82  A4 65
    sta OtherFighter                            ; EF84  85 65
    sty CurFighter                              ; EF86  84 64
    jsr FighterUpdate                           ; EF88  20 99 EF
    ldx OtherFighter                            ; EF8B  A6 65
    farjmp DrawFighters                         ; EF8D  A9 3F 48 A9 3B A2 ED A0 .. -> 3B:ED81


; <- jsr FightersUpdate
; modos: intro do round, luta, fim do round
FighterUpdate:
    ldx CurFighter                              ; EF99  A6 64
    lda a:FighterFramePtrLo,x                   ; EF9B  BD 2A 00
    sta zp_D5                                   ; EF9E  85 D5
    lda a:FighterFramePtrHi,x                   ; EFA0  BD 2C 00
    sta zp_D6                                   ; EFA3  85 D6
    lda a:FighterStateBank,x                    ; EFA5  BD 1A 00
    ora #$80                                    ; EFA8  09 80
    sta MMC5_PRG_A000                           ; EFAA  8D 15 51
    jsr HitRecoverTick                          ; EFAD  20 F8 EF
    lda ScreenMode                              ; EFB0  A5 B0
    cmp #$05                                    ; EFB2  C9 05
    bne L3F_EFBB                                ; EFB4  D0 05
    bit a:RoundResult                           ; EFB6  2C B9 00
    bmi L3F_EFC1                                ; EFB9  30 06
L3F_EFBB:
    jsr InputClear                              ; EFBB  20 74 E9
    jmp FighterUpdateExec                       ; EFBE  4C CE EF


L3F_EFC1:
    lda FighterIsCpu,x                          ; EFC1  B5 02       CPU ou humano?
    beq L3F_EFCB                                ; EFC3  F0 06
    jsr AiUpdate                                ; EFC5  20 D2 E7    CPU -> IA
    jmp FighterUpdateExec                       ; EFC8  4C CE EF


L3F_EFCB:
    jsr InputUpdate                             ; EFCB  20 8D E9    humano -> controle

; <- jmp FighterUpdate, jmp L3F_EFC1
; modos: intro do round, luta, fim do round
FighterUpdateExec:
    jsr InputDispatch                           ; EFCE  20 71 F6    executa a entrada e a animacao do lutador X (InputDispatch + AnimAdvance)
    dec a:FighterAnimTimer,x                    ; EFD1  DE 42 00
    bne L3F_EFD9                                ; EFD4  D0 03
    jsr AnimAdvance                             ; EFD6  20 A6 E2
L3F_EFD9:
    jsr MoveDispatch                            ; EFD9  20 A5 F0
    jsr ProjUpdate                              ; EFDC  20 54 E8
    lda a:FrameFlags,x                          ; EFDF  BD 38 00
    and #$10                                    ; EFE2  29 10
    beq L3F_EFF7                                ; EFE4  F0 11
    ldy OtherFighter                            ; EFE6  A4 65
    lda FighterX,x                              ; EFE8  B5 08
    cmp a:FighterX,y                            ; EFEA  D9 08 00
    beq L3F_EFF7                                ; EFED  F0 08
    lda #$40                                    ; EFEF  A9 40
    bcs L3F_EFF5                                ; EFF1  B0 02
    lda #$00                                    ; EFF3  A9 00
L3F_EFF5:
    sta FighterFlip,x                           ; EFF5  95 04
L3F_EFF7:
    rts                                         ; EFF7  60


; <- jsr FighterUpdate
; modos: intro do round, luta, fim do round
HitRecoverTick:
    ldy a:zp_62,x                               ; EFF8  BC 62 00    conta o HitStop e, ao terminar, restaura o proximo estado do lutador
    beq L3F_F026                                ; EFFB  F0 29
    lda a:FighterState,x                        ; EFFD  BD 26 00
    cmp #$51                                    ; F000  C9 51
    bne L3F_F032                                ; F002  D0 2E
    dey                                         ; F004  88
    sty zp_62,x                                 ; F005  94 62
    bne L3F_F032                                ; F007  D0 29
    lda a:FighterStatePtrLo,x                   ; F009  BD 1E 00
    sta zp_D7                                   ; F00C  85 D7
    lda a:FighterStatePtrHi,x                   ; F00E  BD 20 00
    sta zp_D8                                   ; F011  85 D8
    ldy #$03                                    ; F013  A0 03
    lda (zp_D7),y                               ; F015  B1 D7       [le bancos $01]
    sta a:FighterNextPtrLo,x                    ; F017  9D 22 00
    iny                                         ; F01A  C8
    lda (zp_D7),y                               ; F01B  B1 D7       [le bancos $01]
    sta a:FighterNextPtrHi,x                    ; F01D  9D 24 00
    lda #$01                                    ; F020  A9 01
    sta a:FighterAnimTimer,x                    ; F022  9D 42 00
    rts                                         ; F025  60


L3F_F026:
    ldy a:zp_60,x                               ; F026  BC 60 00
    beq L3F_F032                                ; F029  F0 07
    dey                                         ; F02B  88
    sty zp_60,x                                 ; F02C  94 60
    bne L3F_F032                                ; F02E  D0 02
    sty zp_5E,x                                 ; F030  94 5E
L3F_F032:
    rts                                         ; F032  60


; <- jsr FightersUpdate
; modos: intro do round, luta, fim do round
GrabCheck:
    ldx CurFighter                              ; F033  A6 64       verifica agarrao: lutador X agarra Y se estiver no estado $A0-$A8 e alinhado
    ldy OtherFighter                            ; F035  A4 65

; <- jmp L3F_F08F
; modos: intro do round, luta, fim do round
GrabCheckOne:
    lda a:FighterState,x                        ; F037  BD 26 00    testa o agarrao de X em Y e aplica o deslocamento/estado
    and #$F8                                    ; F03A  29 F8
    cmp #$A0                                    ; F03C  C9 A0
    bcc L3F_F08F                                ; F03E  90 4F
    cmp #$A9                                    ; F040  C9 A9
    bcs L3F_F08F                                ; F042  B0 4B
    clc                                         ; F044  18
    lda a:FighterStatePtrLo,x                   ; F045  BD 1E 00
    adc #$07                                    ; F048  69 07
    sta zp_D7                                   ; F04A  85 D7
    lda a:FighterStatePtrHi,x                   ; F04C  BD 20 00
    adc #$00                                    ; F04F  69 00
    cmp a:FighterFramePtrHi,x                   ; F051  DD 2C 00
    bne L3F_F08F                                ; F054  D0 39
    lda zp_D7                                   ; F056  A5 D7
    cmp a:FighterFramePtrLo,x                   ; F058  DD 2A 00
    bne L3F_F08F                                ; F05B  D0 32
    lda a:FighterNextPtrHi,y                    ; F05D  B9 24 00
    beq L3F_F06B                                ; F060  F0 09
    lda a:HitReactClass,y                       ; F062  B9 16 00
    and #$1F                                    ; F065  29 1F
    cmp #$0C                                    ; F067  C9 0C
    beq L3F_F09A                                ; F069  F0 2F
L3F_F06B:
    lda a:FighterStateBank,x                    ; F06B  BD 1A 00    (nt)
    ora #$80                                    ; F06E  09 80       (nt)
    sta MMC5_PRG_A000                           ; F070  8D 15 51    (nt)
    lda a:FighterStatePtrLo,x                   ; F073  BD 1E 00    (nt)
    sta zp_D7                                   ; F076  85 D7       (nt)
    lda a:FighterStatePtrHi,x                   ; F078  BD 20 00    (nt)
    sta zp_D8                                   ; F07B  85 D8       (nt)
    ldy #$01                                    ; F07D  A0 01       (nt)
    lda (zp_D7),y                               ; F07F  B1 D7       (nt)
    sta zp_DB                                   ; F081  85 DB       (nt)
    iny                                         ; F083  C8          (nt)
    lda (zp_D7),y                               ; F084  B1 D7       (nt)
    sta zp_DC                                   ; F086  85 DC       (nt)
    lda #$04                                    ; F088  A9 04       (nt)
    sta zp_DD                                   ; F08A  85 DD       (nt)
    jmp StateCheckTransitions                   ; F08C  4C CE E0    (nt)


L3F_F08F:
    cpx OtherFighter                            ; F08F  E4 65
    beq L3F_F09A                                ; F091  F0 07
    ldx OtherFighter                            ; F093  A6 65
    ldy CurFighter                              ; F095  A4 64
    jmp GrabCheckOne                            ; F097  4C 37 F0


L3F_F09A:
    rts                                         ; F09A  60


; <- farcall SelectReadInput
; modos: selecao
JoyPollBothSel:
    lda #$00                                    ; F09B  A9 00       le os dois controles na selecao (JoyPollSafe 0 e 1)
    jsr JoyPollSafe                             ; F09D  20 F1 F8
    lda #$01                                    ; F0A0  A9 01
    jmp JoyPollSafe                             ; F0A2  4C F1 F8


; <- jsr L3F_EFCB
; modos: intro do round, luta, fim do round
MoveDispatch:
    ldy a:MoveMode,x                            ; F0A5  BC 2E 00    despacha a aplicacao do movimento pelo MoveMode (tabela D3F_F0B1)
    lda D3F_F0B7,y                              ; F0A8  B9 B7 F0    [idx $00..$05]
    pha                                         ; F0AB  48
    lda D3F_F0B1,y                              ; F0AC  B9 B1 F0    [idx $00..$05]
    pha                                         ; F0AF  48
    rts                                         ; F0B0  60

D3F_F0B1:
    .byte <(MoveOpponentRel-1)                  ; F0B1  BC
    .byte <(MoveAbsolute-1)                     ; F0B2  F1
    .byte <(MoveAir-1)                          ; F0B3  35
    .byte <(MoveAir-1)                          ; F0B4  35
    .byte <(MoveHorizontal-1)                   ; F0B5  76
    .byte <(MoveHorizontal-1)                   ; F0B6  76
D3F_F0B7:
    .byte >(MoveOpponentRel-1)                  ; F0B7  F0
    .byte >(MoveAbsolute-1)                     ; F0B8  F0
    .byte >(MoveAir-1)                          ; F0B9  F2
    .byte >(MoveAir-1)                          ; F0BA  F2
    .byte >(MoveHorizontal-1)                   ; F0BB  F3
    .byte >(MoveHorizontal-1)                   ; F0BC  F3

; <- tabela D3F_F0B1
; modos: luta
MoveOpponentRel:
    ldy OtherFighter                            ; F0BD  A4 65       modo $00: posiciona X relativo ao oponente (X = X do oponente +/- VelX)
    clc                                         ; F0BF  18
    lda a:FighterVelY,x                         ; F0C0  BD 36 00
    beq L3F_F0CF                                ; F0C3  F0 0A
    adc a:FighterY,y                            ; F0C5  79 0C 00    (nt)
    sta FighterY,x                              ; F0C8  95 0C       (nt)
    lda #$00                                    ; F0CA  A9 00       (nt)
    sta a:FighterVelY,x                         ; F0CC  9D 36 00    (nt)
L3F_F0CF:
    lda a:FighterFlip,y                         ; F0CF  B9 04 00
    sta zp_D7                                   ; F0D2  85 D7
    lda a:FighterVelX,x                         ; F0D4  BD 32 00
    beq L3F_F0ED                                ; F0D7  F0 14
    bit zp_D7                                   ; F0D9  24 D7
    bvc L3F_F0E2                                ; F0DB  50 05
    clc                                         ; F0DD  18
    eor #$FF                                    ; F0DE  49 FF
    adc #$01                                    ; F0E0  69 01
L3F_F0E2:
    clc                                         ; F0E2  18
    adc a:FighterX,y                            ; F0E3  79 08 00
    sta FighterX,x                              ; F0E6  95 08
    lda #$00                                    ; F0E8  A9 00
    sta a:FighterVelX,x                         ; F0EA  9D 32 00
L3F_F0ED:
    sta zp_E0                                   ; F0ED  85 E0
    jmp MoveClampEdges                          ; F0EF  4C C5 F5


; <- tabela D3F_F0B1
; modos: luta
MoveAbsolute:
    lda a:FighterVelY,x                         ; F0F2  BD 36 00    modo $01: aplica VelY e VelX direto (movimento absoluto)
    beq L3F_F101                                ; F0F5  F0 0A
    clc                                         ; F0F7  18
    adc FighterY,x                              ; F0F8  75 0C
    sta FighterY,x                              ; F0FA  95 0C
    lda #$00                                    ; F0FC  A9 00
    sta a:FighterVelY,x                         ; F0FE  9D 36 00
L3F_F101:
    lda a:FighterVelX,x                         ; F101  BD 32 00
    bne L3F_F10B                                ; F104  D0 05
    sta zp_E0                                   ; F106  85 E0
    jmp MoveClampEdges                          ; F108  4C C5 F5


L3F_F10B:
    sta zp_D7                                   ; F10B  85 D7
    bpl L3F_F112                                ; F10D  10 03
    jmp MoveAbsLeft                             ; F10F  4C 56 F1


L3F_F112:
    ldy OtherFighter                            ; F112  A4 65
    lda FighterFlip,x                           ; F114  B5 04
    bne L3F_F12F                                ; F116  D0 17
    lda #$C0                                    ; F118  A9 C0
    cmp FighterX                                ; F11A  C5 08
    bcc L3F_F125                                ; F11C  90 07
    cmp FighterX+1                              ; F11E  C5 09
    bcc L3F_F125                                ; F120  90 03
    jmp MoveApplyX                              ; F122  4C 25 F2


L3F_F125:
    lda zp_D7                                   ; F125  A5 D7
    lsr a                                       ; F127  4A
    sta zp_D7                                   ; F128  85 D7
    sta zp_D8                                   ; F12A  85 D8
    jmp MoveScrollCamera                        ; F12C  4C C0 F1


L3F_F12F:
    lda #$41                                    ; F12F  A9 41
    cmp FighterX                                ; F131  C5 08
    bcs L3F_F147                                ; F133  B0 12
    cmp FighterX+1                              ; F135  C5 09
    bcs L3F_F147                                ; F137  B0 0E
    lda zp_D7                                   ; F139  A5 D7
    clc                                         ; F13B  18
    eor #$FF                                    ; F13C  49 FF
    adc #$01                                    ; F13E  69 01
    sta zp_D7                                   ; F140  85 D7
    sta zp_D8                                   ; F142  85 D8
    jmp MoveApplyX                              ; F144  4C 25 F2


L3F_F147:
    lda zp_D7                                   ; F147  A5 D7
    lsr a                                       ; F149  4A
    clc                                         ; F14A  18
    eor #$FF                                    ; F14B  49 FF
    adc #$01                                    ; F14D  69 01
    sta zp_D7                                   ; F14F  85 D7
    sta zp_D8                                   ; F151  85 D8
    jmp MoveScrollCamera                        ; F153  4C C0 F1


; <- jmp L3F_F10B
; modos: luta
MoveAbsLeft:
    ldy OtherFighter                            ; F156  A4 65       modo absoluto: aplica o deslocamento para a esquerda
    lda FighterFlip,x                           ; F158  B5 04
    beq L3F_F15F                                ; F15A  F0 03
    jmp MoveAbsLeftFwd                          ; F15C  4C 94 F1


L3F_F15F:
    lda FighterX,x                              ; F15F  B5 08
    cmp #$40                                    ; F161  C9 40
    bcc L3F_F16C                                ; F163  90 07
    lda zp_D7                                   ; F165  A5 D7
    sta zp_D8                                   ; F167  85 D8
    jmp MoveApplyX                              ; F169  4C 25 F2


L3F_F16C:
    lda zp_D7                                   ; F16C  A5 D7
    eor #$FF                                    ; F16E  49 FF
    adc #$01                                    ; F170  69 01
    lsr a                                       ; F172  4A
    sta zp_D8                                   ; F173  85 D8
    sec                                         ; F175  38
    lda #$E0                                    ; F176  A9 E0
    sbc a:FighterX,y                            ; F178  F9 08 00
    cmp zp_D8                                   ; F17B  C5 D8
    bcs L3F_F181                                ; F17D  B0 02
    sta zp_D8                                   ; F17F  85 D8       (nt)
L3F_F181:
    lda zp_D8                                   ; F181  A5 D8
    clc                                         ; F183  18
    eor #$FF                                    ; F184  49 FF
    adc #$01                                    ; F186  69 01
    sta zp_D8                                   ; F188  85 D8
    sec                                         ; F18A  38
    lda zp_D7                                   ; F18B  A5 D7
    sbc zp_D8                                   ; F18D  E5 D8
    sta zp_D7                                   ; F18F  85 D7
    jmp MoveScrollCamera                        ; F191  4C C0 F1


; <- jmp MoveAbsLeft
; modos: luta
MoveAbsLeftFwd:
    lda zp_D7                                   ; F194  A5 D7       modo absoluto para a esquerda com avanco/recuo de camera
    clc                                         ; F196  18
    eor #$FF                                    ; F197  49 FF
    adc #$01                                    ; F199  69 01
    sta zp_D7                                   ; F19B  85 D7
    lda FighterX,x                              ; F19D  B5 08
    cmp #$C1                                    ; F19F  C9 C1
    bcs L3F_F1A6                                ; F1A1  B0 03
    jmp MoveApplyX                              ; F1A3  4C 25 F2


L3F_F1A6:
    lda zp_D7                                   ; F1A6  A5 D7
    lsr a                                       ; F1A8  4A
    sta zp_D8                                   ; F1A9  85 D8
    sec                                         ; F1AB  38
    lda a:FighterX,y                            ; F1AC  B9 08 00
    sbc #$20                                    ; F1AF  E9 20
    cmp zp_D8                                   ; F1B1  C5 D8
    bcs L3F_F1B7                                ; F1B3  B0 02
    sta zp_D8                                   ; F1B5  85 D8       (nt)
L3F_F1B7:
    lda zp_D8                                   ; F1B7  A5 D8
    sec                                         ; F1B9  38
    lda zp_D7                                   ; F1BA  A5 D7
    sbc zp_D8                                   ; F1BC  E5 D8
    sta zp_D7                                   ; F1BE  85 D7

; <- jmp L3F_F125, jmp L3F_F147, jmp L3F_F16C
; modos: luta
MoveScrollCamera:
    clc                                         ; F1C0  18          aplica o deslocamento de camera e o repassa aos outros objetos
    lda CameraX                                 ; F1C1  AD B7 03
    sta zp_DA                                   ; F1C4  85 DA
    adc zp_D8                                   ; F1C6  65 D8
    sta CameraX                                 ; F1C8  8D B7 03
    cmp #$A0                                    ; F1CB  C9 A0
    bcc L3F_F1E8                                ; F1CD  90 19
    lda #$A0                                    ; F1CF  A9 A0
    sta CameraX                                 ; F1D1  8D B7 03
    sbc zp_DA                                   ; F1D4  E5 DA
    sta zp_D9                                   ; F1D6  85 D9
    lda zp_D8                                   ; F1D8  A5 D8
    sbc zp_D9                                   ; F1DA  E5 D9
    sta zp_D8                                   ; F1DC  85 D8
    clc                                         ; F1DE  18
    lda zp_D8                                   ; F1DF  A5 D8
    adc zp_D7                                   ; F1E1  65 D7
    sta zp_D7                                   ; F1E3  85 D7
    jmp MoveScrollOthers                        ; F1E5  4C 04 F2


L3F_F1E8:
    cmp #$58                                    ; F1E8  C9 58
    bcs MoveScrollOthers                        ; F1EA  B0 18
    sec                                         ; F1EC  38
    lda #$58                                    ; F1ED  A9 58
    sta CameraX                                 ; F1EF  8D B7 03
    sbc zp_DA                                   ; F1F2  E5 DA
    sta zp_D9                                   ; F1F4  85 D9
    clc                                         ; F1F6  18
    lda zp_D8                                   ; F1F7  A5 D8
    adc zp_D9                                   ; F1F9  65 D9
    sta zp_D8                                   ; F1FB  85 D8
    clc                                         ; F1FD  18
    lda zp_D7                                   ; F1FE  A5 D7
    adc zp_D8                                   ; F200  65 D8
    sta zp_D7                                   ; F202  85 D7

; <- jmp L3F_F1A6
; modos: luta
MoveScrollOthers:
    sec                                         ; F204  38          move o oponente e o projetil junto com a camera
    lda zp_DA                                   ; F205  A5 DA
    sbc CameraX                                 ; F207  ED B7 03
    sta zp_D9                                   ; F20A  85 D9
    clc                                         ; F20C  18
    adc a:FighterX,y                            ; F20D  79 08 00
    sta a:FighterX,y                            ; F210  99 08 00
    lda ProjX                                   ; F213  A5 7B
    beq L3F_F21C                                ; F215  F0 05
    clc                                         ; F217  18          (nt)
    adc zp_D9                                   ; F218  65 D9       (nt)
    sta ProjX                                   ; F21A  85 7B       (nt)
L3F_F21C:
    lda ProjX+1                                 ; F21C  A5 7C
    beq MoveApplyX                              ; F21E  F0 05
    clc                                         ; F220  18
    adc zp_D9                                   ; F221  65 D9
    sta ProjX+1                                 ; F223  85 7C

; <- jmp L3F_F112, jmp L3F_F12F, jmp L3F_F15F, jmp MoveAbsLeftFwd
; modos: luta
MoveApplyX:
    clc                                         ; F225  18          aplica o deslocamento em FighterX e zera VelX
    lda zp_D7                                   ; F226  A5 D7
    adc FighterX,x                              ; F228  75 08
    sta FighterX,x                              ; F22A  95 08
    lda #$00                                    ; F22C  A9 00
    sta a:FighterVelX,x                         ; F22E  9D 32 00
    sta zp_E0                                   ; F231  85 E0
    jmp MoveClampEdges                          ; F233  4C C5 F5


; <- tabela D3F_F0B1
; modos: luta
MoveAir:
    lda a:FighterVelYSub,x                      ; F236  BD 34 00    modo $02/$03: integra VelY com gravidade e chao
    sta zp_D7                                   ; F239  85 D7
    lda a:FighterVelY,x                         ; F23B  BD 36 00
    sta zp_D8                                   ; F23E  85 D8
    ora zp_D7                                   ; F240  05 D7
    bne L3F_F251                                ; F242  D0 0D
    lda FighterY,x                              ; F244  B5 0C
    cmp FloorY                                  ; F246  CD BA 03
    bcs L3F_F24E                                ; F249  B0 03
    jmp MoveAirGravity                          ; F24B  4C 17 F3


L3F_F24E:
    jmp MoveAirGround                           ; F24E  4C 32 F3


L3F_F251:
    clc                                         ; F251  18
    lda zp_D7                                   ; F252  A5 D7
    adc FighterYSub,x                           ; F254  75 0A
    sta FighterYSub,x                           ; F256  95 0A
    lda zp_D8                                   ; F258  A5 D8
    adc FighterY,x                              ; F25A  75 0C
    sta FighterY,x                              ; F25C  95 0C
    lda ram_03B9                                ; F25E  AD B9 03
    cmp ram_0402                                ; F261  CD 02 04
    bne L3F_F26E                                ; F264  D0 08
    lda ram_03B8                                ; F266  AD B8 03
    cmp ram_0401                                ; F269  CD 01 04
    beq MoveAirScroll                           ; F26C  F0 0B
L3F_F26E:
    bit zp_D8                                   ; F26E  24 D8
    bcs L3F_F277                                ; F270  B0 05
    bmi L3F_F2DA                                ; F272  30 66
    jmp MoveAirScroll                           ; F274  4C 79 F2


L3F_F277:
    bpl L3F_F2DA                                ; F277  10 61

; <- jmp L3F_F251
; modos: luta
MoveAirScroll:
    lda zp_D8                                   ; F279  A5 D8       integra o subpixel de VelY (deslocamento aereo)
    lsr a                                       ; F27B  4A
    ror zp_D7                                   ; F27C  66 D7
    lsr a                                       ; F27E  4A
    ror zp_D7                                   ; F27F  66 D7
    lsr a                                       ; F281  4A
    ror zp_D7                                   ; F282  66 D7
    bit zp_D8                                   ; F284  24 D8
    bpl L3F_F28A                                ; F286  10 02
    ora #$E0                                    ; F288  09 E0
L3F_F28A:
    sta zp_D8                                   ; F28A  85 D8
    clc                                         ; F28C  18
    lda ram_03B8                                ; F28D  AD B8 03
    sta zp_DB                                   ; F290  85 DB
    adc zp_D7                                   ; F292  65 D7
    sta ram_03B8                                ; F294  8D B8 03
    lda ram_03B9                                ; F297  AD B9 03
    sta zp_DC                                   ; F29A  85 DC
    adc zp_D8                                   ; F29C  65 D8
    sta ram_03B9                                ; F29E  8D B9 03
    cmp #$08                                    ; F2A1  C9 08
    bcs L3F_F2B2                                ; F2A3  B0 0D
    lda #$08                                    ; F2A5  A9 08
    sta ram_03B9                                ; F2A7  8D B9 03
    lda #$00                                    ; F2AA  A9 00
    sta ram_03B8                                ; F2AC  8D B8 03
    jmp MoveAirScrollApply                      ; F2AF  4C C0 F2


L3F_F2B2:
    cmp #$10                                    ; F2B2  C9 10
    bcc MoveAirScrollApply                      ; F2B4  90 0A
    lda #$10                                    ; F2B6  A9 10
    sta ram_03B9                                ; F2B8  8D B9 03
    lda #$00                                    ; F2BB  A9 00
    sta ram_03B8                                ; F2BD  8D B8 03

; <- jmp L3F_F277
; modos: luta
MoveAirScrollApply:
    sec                                         ; F2C0  38          aplica o deslocamento aereo e ajusta o chao/oponente
    lda zp_DC                                   ; F2C1  A5 DC
    sbc ram_03B9                                ; F2C3  ED B9 03
    sta zp_D8                                   ; F2C6  85 D8
    clc                                         ; F2C8  18
    adc FloorY                                  ; F2C9  6D BA 03
    sta FloorY                                  ; F2CC  8D BA 03
    ldy OtherFighter                            ; F2CF  A4 65
    clc                                         ; F2D1  18
    lda zp_D8                                   ; F2D2  A5 D8
    adc a:FighterY,y                            ; F2D4  79 0C 00
    sta a:FighterY,y                            ; F2D7  99 0C 00
L3F_F2DA:
    lda a:FighterVelY,x                         ; F2DA  BD 36 00
    bmi MoveAirGravity                          ; F2DD  30 38
    lda FighterY,x                              ; F2DF  B5 0C
    cmp FloorY                                  ; F2E1  CD BA 03
    bcc MoveAirGravity                          ; F2E4  90 31
    lda FloorY                                  ; F2E6  AD BA 03
    sta FighterY,x                              ; F2E9  95 0C
    lda #$00                                    ; F2EB  A9 00
    sta FighterYSub,x                           ; F2ED  95 0A
    sta a:FighterVelY,x                         ; F2EF  9D 36 00
    sta a:FighterVelYSub,x                      ; F2F2  9D 34 00
    sta a:HitReactClass,x                       ; F2F5  9D 16 00
    lda a:FighterStatePtrLo,x                   ; F2F8  BD 1E 00
    sta zp_D9                                   ; F2FB  85 D9
    lda a:FighterStatePtrHi,x                   ; F2FD  BD 20 00
    sta zp_DA                                   ; F300  85 DA
    ldy #$03                                    ; F302  A0 03
    lda (zp_D9),y                               ; F304  B1 D9       [le bancos $01]
    sta a:FighterNextPtrLo,x                    ; F306  9D 22 00
    iny                                         ; F309  C8
    lda (zp_D9),y                               ; F30A  B1 D9       [le bancos $01]
    sta a:FighterNextPtrHi,x                    ; F30C  9D 24 00
    lda #$01                                    ; F30F  A9 01
    sta a:FighterAnimTimer,x                    ; F311  9D 42 00
    jmp MoveAirGround                           ; F314  4C 32 F3


; <- jmp MoveAir
; modos: luta
MoveAirGravity:
    clc                                         ; F317  18          aplica a gravidade ($30 por quadro) e testa o chao
    lda a:FighterVelYSub,x                      ; F318  BD 34 00
    adc #$30                                    ; F31B  69 30
    sta a:FighterVelYSub,x                      ; F31D  9D 34 00
    lda a:FighterVelY,x                         ; F320  BD 36 00
    adc #$00                                    ; F323  69 00
    sta a:FighterVelY,x                         ; F325  9D 36 00
    lda FighterY,x                              ; F328  B5 0C
    cmp FloorY                                  ; F32A  CD BA 03
    bcc MoveAirGround                           ; F32D  90 03
    jmp MovePushApart                           ; F32F  4C 43 F5    (nt)


; <- jmp L3F_F24E, jmp L3F_F2B2
; modos: luta
MoveAirGround:
    jsr MoveHorizontal                          ; F332  20 77 F3    no ar: move horizontalmente e aplica atrito ao pousar
    lda FighterY,x                              ; F335  B5 0C
    cmp FloorY                                  ; F337  CD BA 03
    bcc L3F_F376                                ; F33A  90 3A
    lda a:FighterVelX,x                         ; F33C  BD 32 00
    bmi L3F_F35A                                ; F33F  30 19
    ora a:FighterVelXSub,x                      ; F341  1D 30 00
    beq L3F_F376                                ; F344  F0 30
    sec                                         ; F346  38
    lda a:FighterVelXSub,x                      ; F347  BD 30 00
    sbc #$30                                    ; F34A  E9 30
    sta a:FighterVelXSub,x                      ; F34C  9D 30 00
    lda a:FighterVelX,x                         ; F34F  BD 32 00
    sbc #$00                                    ; F352  E9 00
    bmi L3F_F36E                                ; F354  30 18
    sta a:FighterVelX,x                         ; F356  9D 32 00
    rts                                         ; F359  60


L3F_F35A:
    clc                                         ; F35A  18
    lda a:FighterVelXSub,x                      ; F35B  BD 30 00
    adc #$30                                    ; F35E  69 30
    sta a:FighterVelXSub,x                      ; F360  9D 30 00
    lda a:FighterVelX,x                         ; F363  BD 32 00
    adc #$00                                    ; F366  69 00
    bpl L3F_F36E                                ; F368  10 04
    sta a:FighterVelX,x                         ; F36A  9D 32 00
    rts                                         ; F36D  60


L3F_F36E:
    lda #$00                                    ; F36E  A9 00
    sta a:FighterVelXSub,x                      ; F370  9D 30 00
    sta a:FighterVelX,x                         ; F373  9D 32 00
L3F_F376:
    rts                                         ; F376  60


; <- jsr MoveAirGround, tabela D3F_F0B1
; modos: intro do round, luta, fim do round
MoveHorizontal:
    lda a:FighterVelXSub,x                      ; F377  BD 30 00    modo $04/$05: aplica VelX com regras de canto
    sta zp_D7                                   ; F37A  85 D7
    lda a:FighterVelX,x                         ; F37C  BD 32 00
    sta zp_D8                                   ; F37F  85 D8
    ora zp_D7                                   ; F381  05 D7
    bne L3F_F388                                ; F383  D0 03
    jmp MovePushApart                           ; F385  4C 43 F5


L3F_F388:
    bit zp_D8                                   ; F388  24 D8
    bpl L3F_F38F                                ; F38A  10 03
    jmp MoveHorizLeft                           ; F38C  4C FB F3


L3F_F38F:
    ldy OtherFighter                            ; F38F  A4 65
    lda FighterFlip,x                           ; F391  B5 04
    bne L3F_F3B9                                ; F393  D0 24
    lda a:FrameFlags,x                          ; F395  BD 38 00
    and #$20                                    ; F398  29 20
    bne L3F_F3A6                                ; F39A  D0 0A
    lda #$D0                                    ; F39C  A9 D0
    cmp FighterX                                ; F39E  C5 08
    bcc L3F_F3A9                                ; F3A0  90 07
    cmp FighterX+1                              ; F3A2  C5 09
    bcc L3F_F3A9                                ; F3A4  90 03
L3F_F3A6:
    jmp MoveHorizApply                          ; F3A6  4C 33 F5


L3F_F3A9:
    lda zp_D8                                   ; F3A9  A5 D8
    lsr a                                       ; F3AB  4A
    ror zp_D7                                   ; F3AC  66 D7
    sta zp_D8                                   ; F3AE  85 D8
    sta zp_DA                                   ; F3B0  85 DA
    lda zp_D7                                   ; F3B2  A5 D7
    sta zp_D9                                   ; F3B4  85 D9
    jmp MoveScrollStage                         ; F3B6  4C 9A F4


L3F_F3B9:
    lda a:FrameFlags,x                          ; F3B9  BD 38 00
    and #$20                                    ; F3BC  29 20
    bne L3F_F3CA                                ; F3BE  D0 0A
    lda #$31                                    ; F3C0  A9 31
    cmp FighterX                                ; F3C2  C5 08
    bcs L3F_F3DA                                ; F3C4  B0 14
    cmp FighterX+1                              ; F3C6  C5 09
    bcs L3F_F3DA                                ; F3C8  B0 10
L3F_F3CA:
    sec                                         ; F3CA  38
    lda #$00                                    ; F3CB  A9 00
    sbc zp_D7                                   ; F3CD  E5 D7
    sta zp_D7                                   ; F3CF  85 D7
    lda #$00                                    ; F3D1  A9 00
    sbc zp_D8                                   ; F3D3  E5 D8
    sta zp_D8                                   ; F3D5  85 D8
    jmp MoveHorizApply                          ; F3D7  4C 33 F5


L3F_F3DA:
    lda zp_D8                                   ; F3DA  A5 D8
    lsr a                                       ; F3DC  4A
    ror zp_D7                                   ; F3DD  66 D7
    sta zp_D8                                   ; F3DF  85 D8
    sta zp_DA                                   ; F3E1  85 DA
    lda zp_D7                                   ; F3E3  A5 D7
    sta zp_D9                                   ; F3E5  85 D9
    sec                                         ; F3E7  38
    lda #$00                                    ; F3E8  A9 00
    sbc zp_D7                                   ; F3EA  E5 D7
    sta zp_D7                                   ; F3EC  85 D7
    sta zp_D9                                   ; F3EE  85 D9
    lda #$00                                    ; F3F0  A9 00
    sbc zp_D8                                   ; F3F2  E5 D8
    sta zp_D8                                   ; F3F4  85 D8
    sta zp_DA                                   ; F3F6  85 DA
    jmp MoveScrollStage                         ; F3F8  4C 9A F4


; <- jmp L3F_F388
; modos: luta
MoveHorizLeft:
    ldy OtherFighter                            ; F3FB  A4 65       movimento horizontal para a esquerda (conforme FighterFlip)
    lda FighterFlip,x                           ; F3FD  B5 04
    beq L3F_F404                                ; F3FF  F0 03
    jmp MoveHorizLeftFwd                        ; F401  4C 53 F4


L3F_F404:
    lda a:FrameFlags,x                          ; F404  BD 38 00
    and #$20                                    ; F407  29 20
    bne L3F_F411                                ; F409  D0 06
    lda FighterX,x                              ; F40B  B5 08
    cmp #$30                                    ; F40D  C9 30
    bcc L3F_F414                                ; F40F  90 03
L3F_F411:
    jmp MoveHorizApply                          ; F411  4C 33 F5


L3F_F414:
    sec                                         ; F414  38
    lda #$00                                    ; F415  A9 00
    sbc zp_D7                                   ; F417  E5 D7
    sta zp_D9                                   ; F419  85 D9
    lda #$00                                    ; F41B  A9 00
    sbc zp_D8                                   ; F41D  E5 D8
    lsr a                                       ; F41F  4A
    ror zp_D9                                   ; F420  66 D9
    sta zp_DA                                   ; F422  85 DA
    sec                                         ; F424  38
    lda #$E0                                    ; F425  A9 E0
    sbc a:FighterX,y                            ; F427  F9 08 00
    cmp zp_DA                                   ; F42A  C5 DA
    bcc L3F_F430                                ; F42C  90 02
    bne L3F_F436                                ; F42E  D0 06
L3F_F430:
    sta zp_DA                                   ; F430  85 DA
    lda #$00                                    ; F432  A9 00
    sta zp_D9                                   ; F434  85 D9
L3F_F436:
    sec                                         ; F436  38
    lda #$00                                    ; F437  A9 00
    sbc zp_D9                                   ; F439  E5 D9
    sta zp_D9                                   ; F43B  85 D9
    lda #$00                                    ; F43D  A9 00
    sbc zp_DA                                   ; F43F  E5 DA
    sta zp_DA                                   ; F441  85 DA
    sec                                         ; F443  38
    lda zp_D7                                   ; F444  A5 D7
    sbc zp_D9                                   ; F446  E5 D9
    sta zp_D7                                   ; F448  85 D7
    lda zp_D8                                   ; F44A  A5 D8
    sbc zp_DA                                   ; F44C  E5 DA
    sta zp_D8                                   ; F44E  85 D8
    jmp MoveScrollStage                         ; F450  4C 9A F4


; <- jmp MoveHorizLeft
; modos: luta
MoveHorizLeftFwd:
    sec                                         ; F453  38          movimento horizontal para a esquerda com avanco de camera
    lda #$00                                    ; F454  A9 00
    sbc zp_D7                                   ; F456  E5 D7
    sta zp_D7                                   ; F458  85 D7
    lda #$00                                    ; F45A  A9 00
    sbc zp_D8                                   ; F45C  E5 D8
    sta zp_D8                                   ; F45E  85 D8
    lda a:FrameFlags,x                          ; F460  BD 38 00
    and #$20                                    ; F463  29 20
    bne L3F_F46D                                ; F465  D0 06
    lda FighterX,x                              ; F467  B5 08
    cmp #$D1                                    ; F469  C9 D1
    bcs L3F_F470                                ; F46B  B0 03
L3F_F46D:
    jmp MoveHorizApply                          ; F46D  4C 33 F5


L3F_F470:
    lda zp_D7                                   ; F470  A5 D7
    sta zp_D9                                   ; F472  85 D9
    lda zp_D8                                   ; F474  A5 D8
    lsr a                                       ; F476  4A
    ror zp_D9                                   ; F477  66 D9
    sta zp_DA                                   ; F479  85 DA
    sec                                         ; F47B  38
    lda a:FighterX,y                            ; F47C  B9 08 00
    sbc #$20                                    ; F47F  E9 20
    cmp zp_DA                                   ; F481  C5 DA
    bcc L3F_F487                                ; F483  90 02
    bne L3F_F48D                                ; F485  D0 06
L3F_F487:
    sta zp_DA                                   ; F487  85 DA
    lda #$00                                    ; F489  A9 00
    sta zp_D9                                   ; F48B  85 D9
L3F_F48D:
    sec                                         ; F48D  38
    lda zp_D7                                   ; F48E  A5 D7
    sbc zp_D9                                   ; F490  E5 D9
    sta zp_D7                                   ; F492  85 D7
    lda zp_D8                                   ; F494  A5 D8
    sbc zp_DA                                   ; F496  E5 DA
    sta zp_D8                                   ; F498  85 D8

; <- jmp L3F_F3A9, jmp L3F_F3DA, jmp L3F_F414
; modos: luta
MoveScrollStage:
    clc                                         ; F49A  18          aplica o deslocamento do cenario e move a camera
    lda ram_03B6                                ; F49B  AD B6 03
    sta zp_E5                                   ; F49E  85 E5
    adc zp_D9                                   ; F4A0  65 D9
    sta ram_03B6                                ; F4A2  8D B6 03
    lda CameraX                                 ; F4A5  AD B7 03
    sta zp_E6                                   ; F4A8  85 E6
    adc zp_DA                                   ; F4AA  65 DA
    sta CameraX                                 ; F4AC  8D B7 03
    cmp #$A0                                    ; F4AF  C9 A0
    bcc L3F_F4E1                                ; F4B1  90 2E
    lda #$00                                    ; F4B3  A9 00
    sta ram_03B6                                ; F4B5  8D B6 03
    sbc zp_E5                                   ; F4B8  E5 E5
    sta zp_E7                                   ; F4BA  85 E7
    lda #$A0                                    ; F4BC  A9 A0
    sta CameraX                                 ; F4BE  8D B7 03
    sbc zp_E6                                   ; F4C1  E5 E6
    sta zp_E8                                   ; F4C3  85 E8
    lda zp_D9                                   ; F4C5  A5 D9
    sbc zp_E7                                   ; F4C7  E5 E7
    sta zp_D9                                   ; F4C9  85 D9
    lda zp_DA                                   ; F4CB  A5 DA
    sbc zp_E8                                   ; F4CD  E5 E8
    sta zp_DA                                   ; F4CF  85 DA
    clc                                         ; F4D1  18
    lda zp_D9                                   ; F4D2  A5 D9
    adc zp_D7                                   ; F4D4  65 D7
    sta zp_D7                                   ; F4D6  85 D7
    lda zp_DA                                   ; F4D8  A5 DA
    adc zp_D8                                   ; F4DA  65 D8
    sta zp_D8                                   ; F4DC  85 D8
    jmp MoveScrollStageOthers                   ; F4DE  4C 12 F5


L3F_F4E1:
    cmp #$58                                    ; F4E1  C9 58
    bcs MoveScrollStageOthers                   ; F4E3  B0 2D
    sec                                         ; F4E5  38
    lda #$00                                    ; F4E6  A9 00
    sta ram_03B6                                ; F4E8  8D B6 03
    sbc zp_E5                                   ; F4EB  E5 E5
    sta zp_E7                                   ; F4ED  85 E7
    lda #$58                                    ; F4EF  A9 58
    sta CameraX                                 ; F4F1  8D B7 03
    sbc zp_E6                                   ; F4F4  E5 E6
    sta zp_E8                                   ; F4F6  85 E8
    clc                                         ; F4F8  18
    lda zp_D9                                   ; F4F9  A5 D9
    adc zp_E7                                   ; F4FB  65 E7
    sta zp_D9                                   ; F4FD  85 D9
    lda zp_DA                                   ; F4FF  A5 DA
    adc zp_E8                                   ; F501  65 E8
    sta zp_DA                                   ; F503  85 DA
    clc                                         ; F505  18
    lda zp_D7                                   ; F506  A5 D7
    adc zp_D9                                   ; F508  65 D9
    sta zp_D7                                   ; F50A  85 D7
    lda zp_D8                                   ; F50C  A5 D8
    adc zp_DA                                   ; F50E  65 DA
    sta zp_D8                                   ; F510  85 D8

; <- jmp L3F_F470
; modos: luta
MoveScrollStageOthers:
    sec                                         ; F512  38          move o oponente e o projetil junto com o cenario
    lda zp_E6                                   ; F513  A5 E6
    sbc CameraX                                 ; F515  ED B7 03
    sta zp_E7                                   ; F518  85 E7
    clc                                         ; F51A  18
    adc a:FighterX,y                            ; F51B  79 08 00
    sta a:FighterX,y                            ; F51E  99 08 00
    lda ProjX                                   ; F521  A5 7B
    beq L3F_F52A                                ; F523  F0 05
    clc                                         ; F525  18
    adc zp_E7                                   ; F526  65 E7
    sta ProjX                                   ; F528  85 7B
L3F_F52A:
    lda ProjX+1                                 ; F52A  A5 7C
    beq MoveHorizApply                          ; F52C  F0 05
    clc                                         ; F52E  18
    adc zp_E7                                   ; F52F  65 E7
    sta ProjX+1                                 ; F531  85 7C

; <- jmp L3F_F38F, jmp L3F_F3B9, jmp L3F_F404, jmp MoveHorizLeftFwd
; modos: luta
MoveHorizApply:
    clc                                         ; F533  18          aplica o deslocamento horizontal em FighterXSub/FighterX
    lda zp_D7                                   ; F534  A5 D7
    adc FighterXSub,x                           ; F536  75 06
    sta FighterXSub,x                           ; F538  95 06
    lda zp_D8                                   ; F53A  A5 D8
    adc FighterX,x                              ; F53C  75 08
    sta FighterX,x                              ; F53E  95 08
    jmp MovePushApart                           ; F540  4C 43 F5


; <- jmp MoveAirGravity, jmp MoveHorizontal, jmp L3F_F4E1
; modos: intro do round, luta, fim do round
MovePushApart:
    lda #$01                                    ; F543  A9 01       se os lutadores se sobrepoem, empurra cada um metade da invasao
    sta zp_E0                                   ; F545  85 E0
    ldy OtherFighter                            ; F547  A4 65
    lda a:MoveMode,y                            ; F549  B9 2E 00
    bne L3F_F551                                ; F54C  D0 03
    jmp MoveClampEdges                          ; F54E  4C C5 F5    (nt)


L3F_F551:
    ora a:MoveMode,x                            ; F551  1D 2E 00
    and #$01                                    ; F554  29 01
    beq L3F_F55B                                ; F556  F0 03
    jmp MoveClampEdges                          ; F558  4C C5 F5


L3F_F55B:
    sec                                         ; F55B  38
    lda FighterY+1                              ; F55C  A5 0D
    sbc FighterY                                ; F55E  E5 0C
    bcs L3F_F566                                ; F560  B0 04
    eor #$FF                                    ; F562  49 FF
    adc #$01                                    ; F564  69 01
L3F_F566:
    cmp #$21                                    ; F566  C9 21
    bcc L3F_F56D                                ; F568  90 03
    jmp MoveClampEdges                          ; F56A  4C C5 F5


L3F_F56D:
    jsr MoveClampEdges                          ; F56D  20 C5 F5
    sec                                         ; F570  38
    lda FighterX+1                              ; F571  A5 09
    sbc FighterX                                ; F573  E5 08
    bcc L3F_F5A6                                ; F575  90 2F
    bne L3F_F583                                ; F577  D0 0A
    ldy FighterFlip                             ; F579  A4 04
    beq L3F_F583                                ; F57B  F0 06
    lda #$02                                    ; F57D  A9 02
    clc                                         ; F57F  18
    jmp MovePushApply                           ; F580  4C B5 F5


L3F_F583:
    sbc #$10                                    ; F583  E9 10
    bcc L3F_F58A                                ; F585  90 03
    jmp MoveClampEdges                          ; F587  4C C5 F5


L3F_F58A:
    eor #$FF                                    ; F58A  49 FF
    adc #$01                                    ; F58C  69 01
    lsr a                                       ; F58E  4A
    cmp #$03                                    ; F58F  C9 03
    bcc L3F_F596                                ; F591  90 03
    lda #$02                                    ; F593  A9 02
    clc                                         ; F595  18
L3F_F596:
    sta zp_E3                                   ; F596  85 E3
    adc FighterX+1                              ; F598  65 09
    sta FighterX+1                              ; F59A  85 09
    sec                                         ; F59C  38
    lda FighterX                                ; F59D  A5 08
    sbc zp_E3                                   ; F59F  E5 E3
    sta FighterX                                ; F5A1  85 08
    jmp MoveClampEdges                          ; F5A3  4C C5 F5


L3F_F5A6:
    adc #$10                                    ; F5A6  69 10
    bcs L3F_F5AD                                ; F5A8  B0 03
    jmp MoveClampEdges                          ; F5AA  4C C5 F5


L3F_F5AD:
    lsr a                                       ; F5AD  4A
    cmp #$03                                    ; F5AE  C9 03
    bcc MovePushApply                           ; F5B0  90 03
    lda #$02                                    ; F5B2  A9 02
    clc                                         ; F5B4  18

; <- jmp L3F_F56D
; modos: luta
MovePushApply:
    sta zp_E3                                   ; F5B5  85 E3       aplica o empurrao em FighterX
    adc FighterX                                ; F5B7  65 08
    sta FighterX                                ; F5B9  85 08
    sec                                         ; F5BB  38
    lda FighterX+1                              ; F5BC  A5 09
    sbc zp_E3                                   ; F5BE  E5 E3
    sta FighterX+1                              ; F5C0  85 09
    jmp MoveClampEdges                          ; F5C2  4C C5 F5


; <- jmp MoveOpponentRel, jmp MoveAbsolute, jmp L3F_F1E8, jmp MovePushApart, jmp L3F_F551, jmp L3F_F55B ... (+5)
; modos: intro do round, luta, fim do round
MoveClampEdges:
    lda #$00                                    ; F5C5  A9 00       inicia o clamp de X nas bordas da tela
    sta zp_E1                                   ; F5C7  85 E1
    sta zp_E2                                   ; F5C9  85 E2
    ldy OtherFighter                            ; F5CB  A4 65

; <- jmp L3F_F5FC
; modos: intro do round, luta, fim do round
MoveClampX:
    lda a:FrameFlags,x                          ; F5CD  BD 38 00    trava o X em $20-$E0 e guarda o transbordo
    and #$20                                    ; F5D0  29 20
    bne MoveClampNext                           ; F5D2  D0 4D
    lda #$20                                    ; F5D4  A9 20
    sec                                         ; F5D6  38
    sbc FighterX,x                              ; F5D7  F5 08
    bcc L3F_F5FC                                ; F5D9  90 21
    sta a:zp_E1,y                               ; F5DB  99 E1 00
    lda #$20                                    ; F5DE  A9 20
    sta FighterX,x                              ; F5E0  95 08
    lda zp_E0                                   ; F5E2  A5 E0
    beq MoveClampNext                           ; F5E4  F0 3B
    lda a:HitReactClass,x                       ; F5E6  BD 16 00
    and #$3F                                    ; F5E9  29 3F
    cmp #$0C                                    ; F5EB  C9 0C
    bne MoveClampNext                           ; F5ED  D0 32
    lda CameraX                                 ; F5EF  AD B7 03
    cmp #$58                                    ; F5F2  C9 58
    bne MoveClampNext                           ; F5F4  D0 2B
    jsr MoveGrabEscape                          ; F5F6  20 48 F6
    jmp MoveClampNext                           ; F5F9  4C 21 F6


L3F_F5FC:
    lda #$E0                                    ; F5FC  A9 E0
    sec                                         ; F5FE  38
    sbc FighterX,x                              ; F5FF  F5 08
    bcs MoveClampNext                           ; F601  B0 1E
    sta a:zp_E1,y                               ; F603  99 E1 00
    lda #$E0                                    ; F606  A9 E0
    sta FighterX,x                              ; F608  95 08
    lda zp_E0                                   ; F60A  A5 E0
    beq MoveClampNext                           ; F60C  F0 13
    lda a:HitReactClass,x                       ; F60E  BD 16 00
    and #$3F                                    ; F611  29 3F
    cmp #$0C                                    ; F613  C9 0C
    bne MoveClampNext                           ; F615  D0 0A
    lda CameraX                                 ; F617  AD B7 03
    cmp #$A0                                    ; F61A  C9 A0
    bne MoveClampNext                           ; F61C  D0 03
    jsr MoveGrabEscape                          ; F61E  20 48 F6

; <- jmp MoveClampEdges
; modos: intro do round, luta, fim do round
MoveClampNext:
    cpx OtherFighter                            ; F621  E4 65       passa ao outro lutador para o clamp
    beq MoveClampPush                           ; F623  F0 07
    ldx OtherFighter                            ; F625  A6 65
    ldy CurFighter                              ; F627  A4 64
    jmp MoveClampX                              ; F629  4C CD F5


; <- jmp MoveClampPush
; modos: intro do round, luta, fim do round
MoveClampPush:
    lda a:FrameFlags,y                          ; F62C  B9 38 00    soma o transbordo do clamp ao X do oponente (empurrao atraves da vitima)
    and #$40                                    ; F62F  29 40
    beq L3F_F63C                                ; F631  F0 09
    lda zp_E1,x                                 ; F633  B5 E1
    beq L3F_F63C                                ; F635  F0 05
    clc                                         ; F637  18
    adc FighterX,x                              ; F638  75 08
    sta FighterX,x                              ; F63A  95 08
L3F_F63C:
    cpx CurFighter                              ; F63C  E4 64
    beq L3F_F647                                ; F63E  F0 07
    ldx CurFighter                              ; F640  A6 64
    ldy OtherFighter                            ; F642  A4 65
    jmp MoveClampPush                           ; F644  4C 2C F6


L3F_F647:
    rts                                         ; F647  60


; <- jsr MoveClampEdges, jsr L3F_F5FC
; modos: luta
MoveGrabEscape:
    jsr HitFreeze                               ; F648  20 00 E0    escapa do agarrao: hit-freeze, zera a classe de reacao e toca o som
    lda #$00                                    ; F64B  A9 00
    sta a:HitReactClass,x                       ; F64D  9D 16 00
    stx zp_DE                                   ; F650  86 DE
    sty zp_DF                                   ; F652  84 DF
    lda #$09                                    ; F654  A9 09
    sta zp_DB                                   ; F656  85 DB
    stx zp_DC                                   ; F658  86 DC
    farcall SfxPlay                             ; F65A  A9 F6 48 A9 6B 48 A9 3F .. -> 37:E401
    ldx zp_DE                                   ; F66C  A6 DE
    ldy zp_DF                                   ; F66E  A4 DF
    rts                                         ; F670  60


; <- jsr L3F_EFCB
; modos: intro do round, luta, fim do round
InputDispatch:
    lda a:FighterNextPtrHi,x                    ; F671  BD 24 00    entrada do jogador: vira transicao de estado — direcao (flag de quadro bit 2), botao (bit 1) ou especial (bit 0); a classe do proximo estado ($58-$68 aceita direcao) decide o que passa
    beq L3F_F695                                ; F674  F0 1F
    sta zp_D8                                   ; F676  85 D8
    lda a:FighterNextPtrLo,x                    ; F678  BD 22 00
    sta zp_D7                                   ; F67B  85 D7
    ldy #$05                                    ; F67D  A0 05
    lda (zp_D7),y                               ; F67F  B1 D7       [le bancos $01]
    and #$F8                                    ; F681  29 F8
    cmp #$58                                    ; F683  C9 58
    bcs L3F_F68A                                ; F685  B0 03
    jmp GuardRedirect                           ; F687  4C 04 F7


L3F_F68A:
    cmp #$69                                    ; F68A  C9 69
    bcc L3F_F695                                ; F68C  90 07
    cmp #$99                                    ; F68E  C9 99
    bcc L3F_F6D6                                ; F690  90 44
    jmp GuardRedirect                           ; F692  4C 04 F7    (nt)


L3F_F695:
    lda a:FrameFlags,x                          ; F695  BD 38 00
    and #$04                                    ; F698  29 04
    beq L3F_F6B2                                ; F69A  F0 16
    sta zp_DD                                   ; F69C  85 DD
    lda ram_031E,x                              ; F69E  BD 1E 03
    sta zp_D7                                   ; F6A1  85 D7
    lda ram_0320,x                              ; F6A3  BD 20 03
    sta zp_D8                                   ; F6A6  85 D8
    lda InputDir,x                              ; F6A8  B5 86
    sec                                         ; F6AA  38
    sbc #$04                                    ; F6AB  E9 04
    asl a                                       ; F6AD  0A
    tay                                         ; F6AE  A8
    jsr TransViaTbl                             ; F6AF  20 F5 F6
L3F_F6B2:
    lda a:FrameFlags,x                          ; F6B2  BD 38 00
    and #$02                                    ; F6B5  29 02
    beq L3F_F6D6                                ; F6B7  F0 1D
    sta zp_DD                                   ; F6B9  85 DD
    lda InputAttack,x                           ; F6BB  B5 88
    bmi L3F_F6D6                                ; F6BD  30 17
    lda ram_0322,x                              ; F6BF  BD 22 03
    sta zp_D7                                   ; F6C2  85 D7
    lda ram_0324,x                              ; F6C4  BD 24 03
    sta zp_D8                                   ; F6C7  85 D8

.ifdef FIX_EDGE_ATTACK
__alt_3F_F6C9:
    jsr EdgeMarkHold
    .assert * - __alt_3F_F6C9 <= $6, error, "bloco alt FIX_EDGE_ATTACK em $F6C9 passou do tamanho"
    .res $6 - (* - __alt_3F_F6C9), $FF
.else
    ldy #$15                                    ; F6C9  A0 15
    sty BtnAHold,x                              ; F6CB  94 8A
    sty BtnBHold,x                              ; F6CD  94 8C
.endif

    lda InputAttack,x                           ; F6CF  B5 88
    asl a                                       ; F6D1  0A
    tay                                         ; F6D2  A8
    jsr TransViaTbl                             ; F6D3  20 F5 F6
L3F_F6D6:
    lda a:FrameFlags,x                          ; F6D6  BD 38 00
    and #$01                                    ; F6D9  29 01
    beq GuardRedirect                           ; F6DB  F0 27
    sta zp_DD                                   ; F6DD  85 DD
    lda CmdMoveIdx,x                            ; F6DF  B5 8E
    bmi GuardRedirect                           ; F6E1  30 21
    lda ram_0326,x                              ; F6E3  BD 26 03
    sta zp_D7                                   ; F6E6  85 D7
    lda ram_0328,x                              ; F6E8  BD 28 03
    sta zp_D8                                   ; F6EB  85 D8
    lda CmdMoveIdx,x                            ; F6ED  B5 8E
    ldy #$FF                                    ; F6EF  A0 FF
    sty CmdMoveIdx,x                            ; F6F1  94 8E
    asl a                                       ; F6F3  0A
    tay                                         ; F6F4  A8

; <- jsr L3F_F695
; modos: intro do round, luta
TransViaTbl:
    lda (zp_D7),y                               ; F6F5  B1 D7       [le bancos $01] le o ponteiro da tabela de estados e chama o caminhador de transicoes
    sta zp_DB                                   ; F6F7  85 DB
    iny                                         ; F6F9  C8
    lda (zp_D7),y                               ; F6FA  B1 D7       [le bancos $01]
    beq L3F_F703                                ; F6FC  F0 05
    sta zp_DC                                   ; F6FE  85 DC
    jmp StateCheckTransitions                   ; F700  4C CE E0


L3F_F703:
    rts                                         ; F703  60


; <- jmp InputDispatch, jmp L3F_F68A
; modos: intro do round, luta, fim do round
GuardRedirect:
    lda a:FighterState,x                        ; F704  BD 26 00    em guarda ($28-$2F): troca para a defesa da direcao atual (D3F_F799) e do golpe recebido (tabela ram_032A), preservando o quadro e o timer
    and #$F8                                    ; F707  29 F8
    cmp #$28                                    ; F709  C9 28
    bne L3F_F703                                ; F70B  D0 F6
    lda a:FrameFlags,x                          ; F70D  BD 38 00
    and #$24                                    ; F710  29 24
    bne L3F_F703                                ; F712  D0 EF
    lda a:FighterNextPtrHi,x                    ; F714  BD 24 00
    bne L3F_F703                                ; F717  D0 EA
    lda a:FighterAnimTimer,x                    ; F719  BD 42 00
    sta zp_D9                                   ; F71C  85 D9
    lda InputDir,x                              ; F71E  B5 86
    sec                                         ; F720  38
    sbc #$04                                    ; F721  E9 04
    tay                                         ; F723  A8
    lda GuardClassTbl,y                         ; F724  B9 99 F7    [idx $00..$08]
    sta a:FighterState,x                        ; F727  9D 26 00
    lda ram_032A,x                              ; F72A  BD 2A 03
    sta zp_D7                                   ; F72D  85 D7
    lda ram_032C,x                              ; F72F  BD 2C 03
    sta zp_D8                                   ; F732  85 D8
    lda a:HitReactClass,x                       ; F734  BD 16 00
    and #$3F                                    ; F737  29 3F
    asl a                                       ; F739  0A
    tay                                         ; F73A  A8
    lda (zp_D7),y                               ; F73B  B1 D7       [le bancos $01]
    sta zp_DB                                   ; F73D  85 DB
    iny                                         ; F73F  C8
    lda (zp_D7),y                               ; F740  B1 D7       [le bancos $01]
    sta zp_DC                                   ; F742  85 DC
    lda #$04                                    ; F744  A9 04
    sta zp_DD                                   ; F746  85 DD
    jsr StateCheckTransitions                   ; F748  20 CE E0
    beq L3F_F703                                ; F74B  F0 B6
    sec                                         ; F74D  38
    lda a:FighterFramePtrLo,x                   ; F74E  BD 2A 00
    sbc a:FighterStatePtrLo,x                   ; F751  FD 1E 00
    sta zp_D7                                   ; F754  85 D7
    lda a:FighterFramePtrHi,x                   ; F756  BD 2C 00
    sbc a:FighterStatePtrHi,x                   ; F759  FD 20 00
    sta zp_D8                                   ; F75C  85 D8
    clc                                         ; F75E  18
    lda a:FighterNextPtrLo,x                    ; F75F  BD 22 00
    sta a:FighterStatePtrLo,x                   ; F762  9D 1E 00
    sta zp_DA                                   ; F765  85 DA
    adc zp_D7                                   ; F767  65 D7
    sta a:FighterFramePtrLo,x                   ; F769  9D 2A 00
    sta zp_D5                                   ; F76C  85 D5
    lda a:FighterNextPtrHi,x                    ; F76E  BD 24 00
    sta a:FighterStatePtrHi,x                   ; F771  9D 20 00
    sta zp_DB                                   ; F774  85 DB
    adc zp_D8                                   ; F776  65 D8
    sta a:FighterFramePtrHi,x                   ; F778  9D 2C 00
    sta zp_D6                                   ; F77B  85 D6
    ldy #$07                                    ; F77D  A0 07
    lda (zp_D5),y                               ; F77F  B1 D5       [le bancos $01]
    sta a:FrameFlags,x                          ; F781  9D 38 00
    ldy #$05                                    ; F784  A0 05
    lda (zp_DA),y                               ; F786  B1 DA       [le bancos $01]
    sta a:FighterState,x                        ; F788  9D 26 00
    lda #$00                                    ; F78B  A9 00
    sta a:FighterNextPtrLo,x                    ; F78D  9D 22 00
    sta a:FighterNextPtrHi,x                    ; F790  9D 24 00
    lda zp_D9                                   ; F793  A5 D9
    sta a:FighterAnimTimer,x                    ; F795  9D 42 00
    rts                                         ; F798  60

GuardClassTbl:
    .byte $29,$29,$29,$29,$2A,$29,$29,$2A,$2A   ; F799              byte de classe da guarda pela direcao (indice InputDir-$04): $29 em pe, $2A agachado

; ------------------------------------------------------------------------------------------------
; Inicializacao: configura o MMC5 (PRG modo 3 = 4 bancos de 8K; CHR modo 2 = paginas de 2K;
; ExRAM modo 3; nametables $44), zera rolagem/paleta, instala o trampolim FarCall na RAM e semeia o RNG.
; <- jmp Reset
; modos: aviso/QR
Main:
    lda #$03                                    ; F7A2  A9 03
    sta MMC5_PRG_MODE                           ; F7A4  8D 00 51
    lda #$02                                    ; F7A7  A9 02
    sta MMC5_CHR_MODE                           ; F7A9  8D 01 51
    lda #$03                                    ; F7AC  A9 03
    sta MMC5_EXRAM_MODE                         ; F7AE  8D 04 51
    lda #$44                                    ; F7B1  A9 44
    sta MMC5_NT_MAP                             ; F7B3  8D 05 51
    lda #$00                                    ; F7B6  A9 00
    sta a:ScrollX                               ; F7B8  8D EF 00
    sta a:ScrollY                               ; F7BB  8D F0 00
    lda PpuCtrlShadow                           ; F7BE  A5 ED
    and #$FC                                    ; F7C0  29 FC
    ora #$02                                    ; F7C2  09 02
    sta PpuCtrlShadow                           ; F7C4  85 ED
    lda PpuCtrlShadow                           ; F7C6  A5 ED
    and #$F7                                    ; F7C8  29 F7
    sta PpuCtrlShadow                           ; F7CA  85 ED
    lda PpuCtrlShadow                           ; F7CC  A5 ED
    ora #$10                                    ; F7CE  09 10
    sta PpuCtrlShadow                           ; F7D0  85 ED
    lda PpuMaskShadow                           ; F7D2  A5 EE
    and #$FB                                    ; F7D4  29 FB
    sta PpuMaskShadow                           ; F7D6  85 EE
    lda PpuMaskShadow                           ; F7D8  A5 EE
    and #$FD                                    ; F7DA  29 FD
    sta PpuMaskShadow                           ; F7DC  85 EE
    lda PpuCtrlShadow                           ; F7DE  A5 ED
    ora #$20                                    ; F7E0  09 20
    sta PpuCtrlShadow                           ; F7E2  85 ED
    lda PpuMaskShadow                           ; F7E4  A5 EE
    and #$E7                                    ; F7E6  29 E7
    sta PpuMaskShadow                           ; F7E8  85 EE
    lda PpuCtrlShadow                           ; F7EA  A5 ED
    and #$7F                                    ; F7EC  29 7F
    sta PpuCtrlShadow                           ; F7EE  85 ED
    lda #$00                                    ; F7F0  A9 00
    sta PPUADDR                                 ; F7F2  8D 06 20
    sta PPUADDR                                 ; F7F5  8D 06 20
    lda a:ScrollX                               ; F7F8  AD EF 00
    sta PPUSCROLL                               ; F7FB  8D 05 20
    lda a:ScrollY                               ; F7FE  AD F0 00
    sta PPUSCROLL                               ; F801  8D 05 20
    lda PpuCtrlShadow                           ; F804  A5 ED
    sta PPUCTRL                                 ; F806  8D 00 20
    lda PpuMaskShadow                           ; F809  A5 EE
    sta PPUMASK                                 ; F80B  8D 01 20
    ldy #$0F                                    ; F80E  A0 0F
    ldx #$20                                    ; F810  A2 20
    lda #$3F                                    ; F812  A9 3F
    sta PPUADDR                                 ; F814  8D 06 20
    lda #$00                                    ; F817  A9 00
    sta PPUADDR                                 ; F819  8D 06 20
L3F_F81C:
    sty PPUDATA                                 ; F81C  8C 07 20
    dex                                         ; F81F  CA
    bne L3F_F81C                                ; F820  D0 FA
    jsr InstallFarCall                          ; F822  20 B7 F8
    jsr RandomSeed                              ; F825  20 AC E5

; Laco do jogo: aviso -> titulo -> selecao -> VS -> luta -> frase do vencedor -> volta ao comeco.
; <- jmp Main
; modos: aviso/QR, frase final
MainLoop:
    farcall ScreenDisclaimer                    ; F828  A9 F8 48 A9 39 48 A9 3F .. -> 37:F2CB ScreenDisclaimer
    farcall ScreenTitle                         ; F83A  A9 F8 48 A9 4B 48 A9 3F .. -> 37:F4E5 ScreenTitle
    lda #$07                                    ; F84C  A9 07       nivel da IA (0..7). E' o unico lugar que define a dificuldade
    sta a:AiLevel                               ; F84E  8D B4 00
    lda #$00                                    ; F851  A9 00
    sta a:TimerOff                              ; F853  8D B5 00
    ldx #$00                                    ; F856  A2 00
    stx zp_B3                                   ; F858  86 B3
    stx zp_B2                                   ; F85A  86 B2
    lda #$FF                                    ; F85C  A9 FF
    sta FighterChar                             ; F85E  85 00       nenhum personagem escolhido
    lda #$FF                                    ; F860  A9 FF
    sta FighterChar+1                           ; F862  85 01
    lda #$00                                    ; F864  A9 00
    sta FighterIsCpu                            ; F866  85 02       P1 = humano

.ifdef MODE_VERSUS
__alt_3F_F868:
    lda #$00                                    ; era lda #$01 (P2 = CPU)
    .assert * - __alt_3F_F868 <= $2, error, "bloco alt MODE_VERSUS em $F868 passou do tamanho"
    .res $2 - (* - __alt_3F_F868), $FF
.else
    lda #$01                                    ; F868  A9 01
.endif

    sta FighterIsCpu+1                          ; F86A  85 03       P2 = CPU
    farcall ScreenPlayerSelect                  ; F86C  A9 F8 48 A9 7D 48 A9 3F .. -> 37:EF4C ScreenPlayerSelect
    farcall ScreenVersus                        ; F87E  A9 F8 48 A9 8F 48 A9 3F .. -> 3B:EA61 ScreenVersus
    farcall Match                               ; F890  A9 F8 48 A9 A1 48 A9 3F .. -> 3B:F551 Match
    farcall ScreenWinQuote                      ; F8A2  A9 F8 48 A9 B3 48 A9 3F .. -> 3B:EC1B ScreenWinQuote
    jmp MainLoop                                ; F8B4  4C 28 F8


; <- jsr Main
; modos: aviso/QR
InstallFarCall:
    lda #<FarCallRom                            ; F8B7  A9 35       copia 20 bytes de FarCallRom para $049E
    sta zp_D5                                   ; F8B9  85 D5
    lda #>FarCallRom                            ; F8BB  A9 F9
    sta zp_D6                                   ; F8BD  85 D6
    lda #<FarCall                               ; F8BF  A9 9E
    sta zp_D7                                   ; F8C1  85 D7
    lda #>FarCall                               ; F8C3  A9 04
    sta zp_D8                                   ; F8C5  85 D8
    ldy #$00                                    ; F8C7  A0 00
    ldx #$00                                    ; F8C9  A2 00
    beq L3F_F8DB                                ; F8CB  F0 0E
L3F_F8CD:
    lda (zp_D5),y                               ; F8CD  B1 D5       (nt)
    sta (zp_D7),y                               ; F8CF  91 D7       (nt)
    iny                                         ; F8D1  C8          (nt)
    bne L3F_F8CD                                ; F8D2  D0 F9       (nt)
    inc zp_D6                                   ; F8D4  E6 D6       (nt)
    inc zp_D8                                   ; F8D6  E6 D8       (nt)
    dex                                         ; F8D8  CA          (nt)
    bne L3F_F8CD                                ; F8D9  D0 F2       (nt)
L3F_F8DB:
    cpy #$14                                    ; F8DB  C0 14
    beq L3F_F8E6                                ; F8DD  F0 07
    lda (zp_D5),y                               ; F8DF  B1 D5       [le bancos $3F]
    sta (zp_D7),y                               ; F8E1  91 D7
    iny                                         ; F8E3  C8
    bne L3F_F8DB                                ; F8E4  D0 F5
L3F_F8E6:
    rts                                         ; F8E6  60


; <- farcall ScreenSupport, farcall L37_F616
; modos: aviso/QR, titulo
JoyPollBoth:
    lda #$00                                    ; F8E7  A9 00
    jsr JoyPollSafe                             ; F8E9  20 F1 F8
    lda #$01                                    ; F8EC  A9 01
    jmp JoyPollSafe                             ; F8EE  4C F1 F8


; Le o controle A (0/1) ate duas leituras baterem — protege contra a corrupcao causada pelo canal DMC.
; Resultado em JoyState,x ; JoyPrev,x recebe o estado anterior.  (mesma ideia do joy_poll_safe da familib)
; <- jsr InputUpdate, jsr JoyPollBothSel, jmp JoyPollBothSel, jsr JoyPollBoth, jmp JoyPollBoth
; modos: aviso/QR, titulo, selecao, luta
JoyPollSafe:
    tax                                         ; F8F1  AA
    lda JoyState,x                              ; F8F2  B5 F2
    pha                                         ; F8F4  48
    jsr JoyRead                                 ; F8F5  20 1C F9
    tay                                         ; F8F8  A8
    jsr JoyRead                                 ; F8F9  20 1C F9
    sta JoyPrev,x                               ; F8FC  95 F6
    jsr JoyRead                                 ; F8FE  20 1C F9
    pha                                         ; F901  48
    jsr JoyRead                                 ; F902  20 1C F9
    cmp JoyPrev,x                               ; F905  D5 F6
    beq L3F_F917                                ; F907  F0 0E
    tya                                         ; F909  98
    sta JoyState,x                              ; F90A  95 F2
    cmp JoyPrev,x                               ; F90C  D5 F6
    beq L3F_F917                                ; F90E  F0 07
    pla                                         ; F910  68
    sta JoyState,x                              ; F911  95 F2
    pla                                         ; F913  68
    sta JoyPrev,x                               ; F914  95 F6
    rts                                         ; F916  60


L3F_F917:
    pla                                         ; F917  68
    pla                                         ; F918  68
    sta JoyPrev,x                               ; F919  95 F6
    rts                                         ; F91B  60


; <- jsr JoyPollSafe
; modos: aviso/QR, titulo, selecao, luta
JoyRead:
    lda #$01                                    ; F91C  A9 01
    sta JoyState,x                              ; F91E  95 F2
    sta JOY1                                    ; F920  8D 16 40
    lsr a                                       ; F923  4A
    sta JOY1                                    ; F924  8D 16 40
L3F_F927:
    lda JOY1,x                                  ; F927  BD 16 40
    and #$03                                    ; F92A  29 03
    cmp #$01                                    ; F92C  C9 01
    rol JoyState,x                              ; F92E  36 F2
    bcc L3F_F927                                ; F930  90 F5
    lda JoyState,x                              ; F932  B5 F2
    rts                                         ; F934  60

FarCallRom:
.org $049E
    .assert * = FarCall, error, "o trampolim precisa ficar em FarCall"
    ora #$80                                    ; 049E  09 80
    sta MMC5_PRG_E000                           ; 04A0  8D 17 51
    jsr FarCall_04AD                            ; 04A3  20 AD 04
    pla                                         ; 04A6  68
    ora #$80                                    ; 04A7  09 80
    sta MMC5_PRG_E000                           ; 04A9  8D 17 51
    rts                                         ; 04AC  60
FarCall_04AD:
    txa                                         ; 04AD  8A
    pha                                         ; 04AE  48
    tya                                         ; 04AF  98
    pha                                         ; 04B0  48
    rts                                         ; 04B1  60
.reloc


.ifdef FIX_EDGE_ATTACK
__alt_3F_F949:
EdgeMarkHold:
    lda InputAttack,x                           ; 0/1 soco, 2/3 chute ($FF nao chega: bmi em F6BD)
    cmp #$01
    beq EdgeMarkStrong
    cmp #$03
    beq EdgeMarkStrong
    cmp #$00
    beq EdgeMarkA
    cmp #$02
    beq EdgeMarkB
    rts
EdgeMarkStrong:
    ldy #$FF                                     ; forte despachado: desarma os dois contadores
    sty BtnAHold,x                               ; (segurando: wrap do iny; soltando: cpy #$15)
    sty BtnBHold,x
    rts
EdgeMarkA:
    ldy #$01                                     ; fraco despachado: segue contando (promocao aos 7)
    sty BtnAHold,x
    rts
EdgeMarkB:
    ldy #$01
    sty BtnBHold,x
    rts
    .assert * - __alt_3F_F949 <= $36, error, "bloco alt FIX_EDGE_ATTACK em $F949 passou do tamanho"
    .res $36 - (* - __alt_3F_F949), $FF
.else
    .res 54, $FF                                ; F949
.endif

    .res 750, $FF                               ; F97F

.ifdef FIX_SOFT_RESET
__alt_3F_FC6D:
ResetStub:
    lda #$00
    sta MMC5_IRQ_STATUS
    lda #$BF
    sta MMC5_PRG_E000
    jmp $FF9F
    .assert * - __alt_3F_FC6D <= $F, error, "bloco alt FIX_SOFT_RESET em $FC6D passou do tamanho"
    .res $F - (* - __alt_3F_FC6D), $FF
.else
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; FC6D
.endif


.assert * = $FC7C, error, "o kernel precisa comecar em $FC7C"
.include "kernel.inc"

    .byte $FF,$FF,$FF,$FF                       ; FF9B

; ------------------------------------------------------------------------------------------------
; RESET. Este codigo so existe no banco $3F (ver a correcao FIX_SOFT_RESET no fim de annotations/).
; <- tabela L3F_FFE6
; modos: aviso/QR
Reset:
    sei                                         ; FF9F  78
    cld                                         ; FFA0  D8
    ldx #$FF                                    ; FFA1  A2 FF
    txs                                         ; FFA3  9A
    inx                                         ; FFA4  E8
    stx PPUCTRL                                 ; FFA5  8E 00 20
    stx PPUMASK                                 ; FFA8  8E 01 20
    stx DMC_FREQ                                ; FFAB  8E 10 40
    bit PPUSTATUS                               ; FFAE  2C 02 20
    bit SND_CHN                                 ; FFB1  2C 15 40
    lda #$40                                    ; FFB4  A9 40
    sta JOY2                                    ; FFB6  8D 17 40
    lda #$0F                                    ; FFB9  A9 0F
    sta SND_CHN                                 ; FFBB  8D 15 40
L3F_FFBE:
    bit PPUSTATUS                               ; FFBE  2C 02 20
    bpl L3F_FFBE                                ; FFC1  10 FB
    txa                                         ; FFC3  8A
L3F_FFC4:
    sta FighterChar,x                           ; FFC4  95 00
    sta ram_0100,x                              ; FFC6  9D 00 01
    sta ram_0300,x                              ; FFC9  9D 00 03
    sta ram_0400,x                              ; FFCC  9D 00 04
    sta ram_0500,x                              ; FFCF  9D 00 05
    sta ram_0600,x                              ; FFD2  9D 00 06
    sta ram_0700,x                              ; FFD5  9D 00 07
    inx                                         ; FFD8  E8
    bne L3F_FFC4                                ; FFD9  D0 E9
    lda #$EF                                    ; FFDB  A9 EF
L3F_FFDD:
    sta OamBuf,x                                ; FFDD  9D 00 02
    inx                                         ; FFE0  E8
    inx                                         ; FFE1  E8
    inx                                         ; FFE2  E8
    inx                                         ; FFE3  E8
    bne L3F_FFDD                                ; FFE4  D0 F7
L3F_FFE6:
    bit PPUSTATUS                               ; FFE6  2C 02 20
    bpl L3F_FFE6                                ; FFE9  10 FB
    stx OAMADDR                                 ; FFEB  8E 03 20
    lda #$02                                    ; FFEE  A9 02
    sta OAMDMA                                  ; FFF0  8D 14 40
    lda PPUSTATUS                               ; FFF3  AD 02 20
    jmp Main                                    ; FFF6  4C A2 F7

    .byte $FF                                   ; FFF9
    .word NmiHandler                            ; FFFA  1E FE

.ifdef FIX_SOFT_RESET
__alt_3F_FFFC:
    .word ResetStub
    .assert * - __alt_3F_FFFC <= $2, error, "bloco alt FIX_SOFT_RESET em $FFFC passou do tamanho"
    .res $2 - (* - __alt_3F_FFFC), $FF
.else
    .word Reset                                 ; FFFC  9F FF
.endif

    .word IrqHandler                            ; FFFE  7C FC
