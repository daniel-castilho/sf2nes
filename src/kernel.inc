; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; KERNEL — codigo identico no fim dos tres bancos de codigo ($37, $3B, $3F): $FC7C-$FF9A.
; Contem os tratadores de IRQ (efeitos de raster via contador de scanline do MMC5) e de NMI.
; Precisa existir em todo banco que for mapeado em $E000, pois os vetores ficam em $FFFA-$FFFF.
;

; ------------------------------------------------------------------------------------------------
; IRQ = contador de scanlines do MMC5 ($5203/$5204). Faz os efeitos de raster.
; IrqStage ($03FF) = 0      -> primeira divisao da luta: fim do HUD, comeca o cenario
; IrqStage > 0              -> divisoes seguintes da luta; a ultima faz o chao linha a linha (paralaxe)
; IrqStage < 0 (bit 7)      -> telas de menu (selecao / VS / frase): troca de CHR por faixa
; ATENCAO: os lacos de espera (dex/bne, nop) sao contagem de ciclos. Mexer aqui desalinha a imagem.
; <- tabela D37_FF9F, tabela D3B_FF9F, tabela L3F_FFE6
; modos: selecao, intro do round, luta, fim do round
IrqHandler:
    pha                                         ; FC7C  48
    txa                                         ; FC7D  8A
    pha                                         ; FC7E  48
    tya                                         ; FC7F  98
    pha                                         ; FC80  48
    ldy IrqStage                                ; FC81  AC FF 03
    bne K_FC89                                  ; FC84  D0 03
    jmp Irq_FightFirst                          ; FC86  4C 1C FD


K_FC89:
    bpl Irq_FightNext                           ; FC89  10 03
    jmp Irq_Menu                                ; FC8B  4C 62 FD


; modos: intro do round, luta, fim do round
Irq_FightNext:
    ldx #$08                                    ; FC8E  A2 08
K_FC90:
    dex                                         ; FC90  CA
    bne K_FC90                                  ; FC91  D0 FD
    cmp zp_AE,x                                 ; FC93  D5 AE
    lda ram_0406,y                              ; FC95  B9 06 04
    ldx ram_0409,y                              ; FC98  BE 09 04
    sta MMC5_CHR_BG1                            ; FC9B  8D 29 51
    stx MMC5_CHR_BG3                            ; FC9E  8E 2B 51
    lda MMC5_IRQ_STATUS                         ; FCA1  AD 04 52
    iny                                         ; FCA4  C8
    cpy #$03                                    ; FCA5  C0 03
    bcc Irq_FightArmNext                        ; FCA7  90 5B
    nop                                         ; FCA9  EA
    nop                                         ; FCAA  EA
    nop                                         ; FCAB  EA
    lda ram_0405                                ; FCAC  AD 05 04
    sta zp_AF                                   ; FCAF  85 AF
    bit PPUSTATUS                               ; FCB1  2C 02 20
    ldy #$00                                    ; FCB4  A0 00
Irq_FloorLine:
    ldx #$06                                    ; FCB6  A2 06       uma volta por scanline do chao: rolagem horizontal propria (tabela FloorScrollX)
K_FCB8:
    dex                                         ; FCB8  CA
    bne K_FCB8                                  ; FCB9  D0 FD
    lda #$08                                    ; FCBB  A9 08
    sta PPUADDR                                 ; FCBD  8D 06 20
    lda zp_AF                                   ; FCC0  A5 AF
    clc                                         ; FCC2  18
    adc #$01                                    ; FCC3  69 01
    sta zp_AF                                   ; FCC5  85 AF
    sta PPUSCROLL                               ; FCC7  8D 05 20
    and #$F8                                    ; FCCA  29 F8
    asl a                                       ; FCCC  0A
    asl a                                       ; FCCD  0A
    sta zp_AE                                   ; FCCE  85 AE
    ldx FloorScrollX,y                          ; FCD0  BE DF 03
    txa                                         ; FCD3  8A
    lsr a                                       ; FCD4  4A
    lsr a                                       ; FCD5  4A
    lsr a                                       ; FCD6  4A
    ora zp_AE                                   ; FCD7  05 AE
    stx PPUSCROLL                               ; FCD9  8E 05 20
    sta PPUADDR                                 ; FCDC  8D 06 20
    lda SND_CHN                                 ; FCDF  AD 15 40
    and #$10                                    ; FCE2  29 10
    bne K_FCE7                                  ; FCE4  D0 01
    nop                                         ; FCE6  EA
K_FCE7:
    inc zp_AE                                   ; FCE7  E6 AE
    inc zp_AE                                   ; FCE9  E6 AE
    nop                                         ; FCEB  EA
    iny                                         ; FCEC  C8
    cpy FloorLines                              ; FCED  CC BB 03
    bcc Irq_FloorLine                           ; FCF0  90 C4
    ldx #$C8                                    ; FCF2  A2 C8
K_FCF4:
    dex                                         ; FCF4  CA
    bne K_FCF4                                  ; FCF5  D0 FD
    lda #$0E                                    ; FCF7  A9 0E
    sta MMC5_CHR_BG1                            ; FCF9  8D 29 51
    lda #$0D                                    ; FCFC  A9 0D
    sta MMC5_CHR_BG3                            ; FCFE  8D 2B 51
    jmp Irq_Exit                                ; FD01  4C 16 FD


; modos: intro do round, luta, fim do round
Irq_FightArmNext:
    sty IrqStage                                ; FD04  8C FF 03
    lda ram_0403,y                              ; FD07  B9 03 04
    sec                                         ; FD0A  38
    sbc ram_0402                                ; FD0B  ED 02 04

; <- jmp Irq_FightFirst, jmp Irq_Menu
; modos: selecao, intro do round, luta, fim do round
Irq_SetLine:
    sta MMC5_IRQ_LINE                           ; FD0E  8D 03 52
    lda #$80                                    ; FD11  A9 80
    sta MMC5_IRQ_STATUS                         ; FD13  8D 04 52

; <- jmp Irq_FightNext, jmp Irq_MenuLast
; modos: selecao, intro do round, luta, fim do round
Irq_Exit:
    pla                                         ; FD16  68
    tay                                         ; FD17  A8
    pla                                         ; FD18  68
    tax                                         ; FD19  AA
    pla                                         ; FD1A  68
    rti                                         ; FD1B  40


; <- jmp IrqHandler
; modos: intro do round, luta, fim do round
Irq_FightFirst:
    lda SND_CHN                                 ; FD1C  AD 15 40
    and #$10                                    ; FD1F  29 10
    beq K_FD23                                  ; FD21  F0 00
K_FD23:
    lda #$08                                    ; FD23  A9 08
    sta PPUADDR                                 ; FD25  8D 06 20
    lda #$40                                    ; FD28  A9 40
    clc                                         ; FD2A  18
    adc ram_0402                                ; FD2B  6D 02 04
    sta PPUSCROLL                               ; FD2E  8D 05 20
    and #$F8                                    ; FD31  29 F8
    asl a                                       ; FD33  0A
    asl a                                       ; FD34  0A
    sta zp_AE                                   ; FD35  85 AE
    ldx ram_0400                                ; FD37  AE 00 04
    txa                                         ; FD3A  8A
    lsr a                                       ; FD3B  4A
    lsr a                                       ; FD3C  4A
    lsr a                                       ; FD3D  4A
    ora zp_AE                                   ; FD3E  05 AE
    stx PPUSCROLL                               ; FD40  8E 05 20
    sta PPUADDR                                 ; FD43  8D 06 20
    lda ram_0406                                ; FD46  AD 06 04
    ldx ram_0409                                ; FD49  AE 09 04
    sta MMC5_CHR_BG1                            ; FD4C  8D 29 51
    stx MMC5_CHR_BG3                            ; FD4F  8E 2B 51
    lda MMC5_IRQ_STATUS                         ; FD52  AD 04 52
    inc IrqStage                                ; FD55  EE FF 03
    lda ram_0404                                ; FD58  AD 04 04
    sec                                         ; FD5B  38
    sbc ram_0402                                ; FD5C  ED 02 04
    jmp Irq_SetLine                             ; FD5F  4C 0E FD


; <- jmp K_FC89
; modos: selecao
Irq_Menu:
    lda MMC5_IRQ_STATUS                         ; FD62  AD 04 52
    ldx ram_0481                                ; FD65  AE 81 04
    cpx #$03                                    ; FD68  E0 03
    bcs Irq_MenuLast                            ; FD6A  B0 20
    ldy #$06                                    ; FD6C  A0 06
K_FD6E:
    dey                                         ; FD6E  88
    bne K_FD6E                                  ; FD6F  D0 FD
    lda MenuSplitChrA,x                         ; FD71  BD 18 FE
    sta MMC5_CHR_BG1                            ; FD74  8D 29 51
    lda MenuSplitChrB,x                         ; FD77  BD 1B FE
    bne K_FD7F                                  ; FD7A  D0 03
    lda ram_0391                                ; FD7C  AD 91 03
K_FD7F:
    sta MMC5_CHR_BG3                            ; FD7F  8D 2B 51
    inx                                         ; FD82  E8
    stx ram_0481                                ; FD83  8E 81 04
    lda MenuSplitLine,x                         ; FD86  BD 14 FE
    jmp Irq_SetLine                             ; FD89  4C 0E FD


; modos: selecao
Irq_MenuLast:
    lda PpuMaskShadow                           ; FD8C  A5 EE
    and #$E7                                    ; FD8E  29 E7
    sta PPUMASK                                 ; FD90  8D 01 20
    bit FighterChar                             ; FD93  24 00
    bmi K_FDDB                                  ; FD95  30 44
    lda FighterIsCpu                            ; FD97  A5 02       so para jogador humano (FighterIsCpu = 0)
    bne K_FDDB                                  ; FD99  D0 40
    farcall NmiVsPortraitUpload                 ; FD9B  A9 FD 48 A9 AC 48 A9 3F .. -> 3B:F02E
    lda #$29                                    ; FDAD  A9 29
    sta PPUADDR                                 ; FDAF  8D 06 20
    lda #$C0                                    ; FDB2  A9 C0
    sta PPUADDR                                 ; FDB4  8D 06 20
    ldx #$00                                    ; FDB7  A2 00
K_FDB9:
    lda ram_0392,x                              ; FDB9  BD 92 03
    sta PPUDATA                                 ; FDBC  8D 07 20
    inx                                         ; FDBF  E8
    cpx #$07                                    ; FDC0  E0 07
    bcc K_FDB9                                  ; FDC2  90 F5
    lda #$29                                    ; FDC4  A9 29
    sta PPUADDR                                 ; FDC6  8D 06 20
    lda #$E0                                    ; FDC9  A9 E0
    sta PPUADDR                                 ; FDCB  8D 06 20
    ldx #$00                                    ; FDCE  A2 00
K_FDD0:
    lda ram_0399,x                              ; FDD0  BD 99 03
    sta PPUDATA                                 ; FDD3  8D 07 20
    inx                                         ; FDD6  E8
    cpx #$07                                    ; FDD7  E0 07
    bcc K_FDD0                                  ; FDD9  90 F5
K_FDDB:
    bit FighterChar+1                           ; FDDB  24 01
    bmi K_FE11                                  ; FDDD  30 32
    lda FighterIsCpu+1                          ; FDDF  A5 03       idem para o jogador 2 — nunca executado no demo (P2 e' sempre CPU)
    bne K_FE11                                  ; FDE1  D0 2E
    lda #$29                                    ; FDE3  A9 29
    sta PPUADDR                                 ; FDE5  8D 06 20
    lda #$D7                                    ; FDE8  A9 D7
    sta PPUADDR                                 ; FDEA  8D 06 20
    ldx #$00                                    ; FDED  A2 00
K_FDEF:
    lda ram_03A0,x                              ; FDEF  BD A0 03
    sta PPUDATA                                 ; FDF2  8D 07 20
    inx                                         ; FDF5  E8
    cpx #$07                                    ; FDF6  E0 07
    bcc K_FDEF                                  ; FDF8  90 F5
    lda #$29                                    ; FDFA  A9 29
    sta PPUADDR                                 ; FDFC  8D 06 20
    lda #$F7                                    ; FDFF  A9 F7
    sta PPUADDR                                 ; FE01  8D 06 20
    ldx #$00                                    ; FE04  A2 00
K_FE06:
    lda ram_03A7,x                              ; FE06  BD A7 03
    sta PPUDATA                                 ; FE09  8D 07 20
    inx                                         ; FE0C  E8
    cpx #$07                                    ; FE0D  E0 07
    bcc K_FE06                                  ; FE0F  90 F5
K_FE11:
    jmp Irq_Exit                                ; FE11  4C 16 FD

MenuSplitLine:
    .byte $27,$7F,$8F,$E1                       ; FE14
MenuSplitChrA:
    .byte $31,$0D,$0F                           ; FE18
MenuSplitChrB:
    .byte $32,$32,$00                           ; FE1B

; ------------------------------------------------------------------------------------------------
; NMI (vblank): envia a OAM, roda a tarefa do modo de tela atual (ScreenMode), acerta os bancos de CHR
; dos sprites dos dois lutadores, a rolagem e os registradores do PPU, e sinaliza o laco principal.
; <- tabela D37_FF9F, tabela D3B_FF9F, tabela L3F_FFE6
; modos: todos
NmiHandler:
    pha                                         ; FE1E  48
    txa                                         ; FE1F  8A
    pha                                         ; FE20  48
    tya                                         ; FE21  98
    pha                                         ; FE22  48
    lda #$00                                    ; FE23  A9 00
    sta OAMADDR                                 ; FE25  8D 03 20
    lda #$02                                    ; FE28  A9 02
    sta OAMDMA                                  ; FE2A  8D 14 40
    jsr NmiDispatch                             ; FE2D  20 66 FE
    lda a:FighterChrPage                        ; FE30  AD 40 00
    sta MMC5_CHR_SPR1                           ; FE33  8D 21 51
    lda a:FighterChrPage+1                      ; FE36  AD 41 00
    sta MMC5_CHR_SPR3                           ; FE39  8D 23 51
    lda #$00                                    ; FE3C  A9 00
    sta PPUADDR                                 ; FE3E  8D 06 20
    sta PPUADDR                                 ; FE41  8D 06 20
    lda a:ScrollX                               ; FE44  AD EF 00
    sta PPUSCROLL                               ; FE47  8D 05 20
    lda a:ScrollY                               ; FE4A  AD F0 00
    sta PPUSCROLL                               ; FE4D  8D 05 20
    lda PpuCtrlShadow                           ; FE50  A5 ED
    sta PPUCTRL                                 ; FE52  8D 00 20
    lda PpuMaskShadow                           ; FE55  A5 EE
    sta PPUMASK                                 ; FE57  8D 01 20
    inc FrameCounter                            ; FE5A  E6 B1       contador de frames
    lda #$01                                    ; FE5C  A9 01
    sta VBlankFlag                              ; FE5E  85 AC       avisa o laco principal que o vblank passou
    pla                                         ; FE60  68
    tay                                         ; FE61  A8
    pla                                         ; FE62  68
    tax                                         ; FE63  AA
    pla                                         ; FE64  68
    rti                                         ; FE65  40


; <- jsr NmiHandler
; modos: todos
NmiDispatch:
    ldx ScreenMode                              ; FE66  A6 B0
    lda NmiTaskHi,x                             ; FE68  BD 79 FE
    pha                                         ; FE6B  48
    lda NmiTaskLo,x                             ; FE6C  BD 71 FE
    pha                                         ; FE6F  48
    rts                                         ; FE70  60

NmiTaskLo:
    .byte <(NmiTask_Intro-1)                    ; FE71  81
    .byte <(NmiTask_Title-1)                    ; FE72  8A
    .byte <(NmiTask_Select-1)                   ; FE73  9B
    .byte <(NmiTask_VsQuote-1)                  ; FE74  C4
    .byte <(NmiTask_Fight-1)                    ; FE75  B9
    .byte <(NmiTask_Fight-1)                    ; FE76  B9
    .byte <(NmiTask_Fight-1)                    ; FE77  B9
    .byte <(NmiTask_VsQuote-1)                  ; FE78  C4
NmiTaskHi:
    .byte >(NmiTask_Intro-1)                    ; FE79  FE
    .byte >(NmiTask_Title-1)                    ; FE7A  FE
    .byte >(NmiTask_Select-1)                   ; FE7B  FE
    .byte >(NmiTask_VsQuote-1)                  ; FE7C  FE
    .byte >(NmiTask_Fight-1)                    ; FE7D  FE
    .byte >(NmiTask_Fight-1)                    ; FE7E  FE
    .byte >(NmiTask_Fight-1)                    ; FE7F  FE
    .byte >(NmiTask_VsQuote-1)                  ; FE80  FE
    .byte $60                                   ; FE81

; <- tabela NmiTaskLo
; modos: aviso/QR
NmiTask_Intro:
    lda a:PaletteDirty                          ; FE82  AD D4 00
    beq K_FE8A                                  ; FE85  F0 03
    jmp PaletteUpload                           ; FE87  4C D8 FE


K_FE8A:
    rts                                         ; FE8A  60


; <- tabela NmiTaskLo
; modos: titulo
NmiTask_Title:
    lda a:PaletteDirty                          ; FE8B  AD D4 00
    beq K_FE93                                  ; FE8E  F0 03
    jmp PaletteUpload                           ; FE90  4C D8 FE


K_FE93:
    lda FadePalette+10                          ; FE93  AD 8F 04
    beq K_FE9B                                  ; FE96  F0 03
    jmp TitleDrawPushStart                      ; FE98  4C 94 E3


K_FE9B:
    rts                                         ; FE9B  60


; <- tabela NmiTaskLo
; modos: selecao
NmiTask_Select:
    lda a:PaletteDirty                          ; FE9C  AD D4 00
    beq K_FEA4                                  ; FE9F  F0 03
    jsr PaletteUpload                           ; FEA1  20 D8 FE
K_FEA4:
    lda #$0D                                    ; FEA4  A9 0D
    sta MMC5_CHR_BG1                            ; FEA6  8D 29 51
    ldx #$00                                    ; FEA9  A2 00
    stx ram_0481                                ; FEAB  8E 81 04
    lda MenuSplitLine                           ; FEAE  AD 14 FE
    sta MMC5_IRQ_LINE                           ; FEB1  8D 03 52
    lda #$80                                    ; FEB4  A9 80
    sta MMC5_IRQ_STATUS                         ; FEB6  8D 04 52
    rts                                         ; FEB9  60


; <- tabela NmiTaskLo
; modos: intro do round, luta, fim do round
NmiTask_Fight:
    lda a:PaletteDirty                          ; FEBA  AD D4 00
    beq K_FEC2                                  ; FEBD  F0 03
    jmp PaletteUpload                           ; FEBF  4C D8 FE


K_FEC2:
    jmp NmiFightVram                            ; FEC2  4C 44 E8


; <- tabela NmiTaskLo
; modos: VS, frase final
NmiTask_VsQuote:
    lda a:PaletteDirty                          ; FEC5  AD D4 00
    beq K_FECD                                  ; FEC8  F0 03
    jsr PaletteUpload                           ; FECA  20 D8 FE
K_FECD:
    lda ram_03AE                                ; FECD  AD AE 03
    beq K_FED5                                  ; FED0  F0 03
    jmp NmiVsPortraitUpload                     ; FED2  4C 2E F0


K_FED5:
    jmp NmiVsQuoteUpload                        ; FED5  4C 25 F2


; Copia o buffer de paleta (PaletteBuf, 24 cores = 8 paletas x 3; a cor 0 de todas e' $0F) para o PPU.
; <- jmp NmiTask_Intro, jmp NmiTask_Title, jsr NmiTask_Select, jmp NmiTask_Fight, jsr NmiTask_VsQuote
; modos: todos
PaletteUpload:
    lda #$3F                                    ; FED8  A9 3F
    sta PPUADDR                                 ; FEDA  8D 06 20
    lda #$01                                    ; FEDD  A9 01
    sta PPUADDR                                 ; FEDF  8D 06 20
    lda a:PaletteBuf                            ; FEE2  AD BC 00
    sta PPUDATA                                 ; FEE5  8D 07 20
    lda a:PaletteBuf+1                          ; FEE8  AD BD 00
    sta PPUDATA                                 ; FEEB  8D 07 20
    lda a:PaletteBuf+2                          ; FEEE  AD BE 00
    sta PPUDATA                                 ; FEF1  8D 07 20
    lda #$0F                                    ; FEF4  A9 0F
    sta PPUDATA                                 ; FEF6  8D 07 20
    lda a:PaletteBuf+3                          ; FEF9  AD BF 00
    sta PPUDATA                                 ; FEFC  8D 07 20
    lda a:PaletteBuf+4                          ; FEFF  AD C0 00
    sta PPUDATA                                 ; FF02  8D 07 20
    lda a:PaletteBuf+5                          ; FF05  AD C1 00
    sta PPUDATA                                 ; FF08  8D 07 20
    lda #$0F                                    ; FF0B  A9 0F
    sta PPUDATA                                 ; FF0D  8D 07 20
    lda a:PaletteBuf+6                          ; FF10  AD C2 00
    sta PPUDATA                                 ; FF13  8D 07 20
    lda a:PaletteBuf+7                          ; FF16  AD C3 00
    sta PPUDATA                                 ; FF19  8D 07 20
    lda a:PaletteBuf+8                          ; FF1C  AD C4 00
    sta PPUDATA                                 ; FF1F  8D 07 20
    lda #$0F                                    ; FF22  A9 0F
    sta PPUDATA                                 ; FF24  8D 07 20
    lda a:PaletteBuf+9                          ; FF27  AD C5 00
    sta PPUDATA                                 ; FF2A  8D 07 20
    lda a:PaletteBuf+10                         ; FF2D  AD C6 00
    sta PPUDATA                                 ; FF30  8D 07 20
    lda a:PaletteBuf+11                         ; FF33  AD C7 00
    sta PPUDATA                                 ; FF36  8D 07 20
    lda #$0F                                    ; FF39  A9 0F
    sta PPUDATA                                 ; FF3B  8D 07 20
    lda a:PaletteBuf+12                         ; FF3E  AD C8 00
    sta PPUDATA                                 ; FF41  8D 07 20
    lda a:PaletteBuf+13                         ; FF44  AD C9 00
    sta PPUDATA                                 ; FF47  8D 07 20
    lda a:PaletteBuf+14                         ; FF4A  AD CA 00
    sta PPUDATA                                 ; FF4D  8D 07 20
    lda #$0F                                    ; FF50  A9 0F
    sta PPUDATA                                 ; FF52  8D 07 20
    lda a:PaletteBuf+15                         ; FF55  AD CB 00
    sta PPUDATA                                 ; FF58  8D 07 20
    lda a:PaletteBuf+16                         ; FF5B  AD CC 00
    sta PPUDATA                                 ; FF5E  8D 07 20
    lda a:PaletteBuf+17                         ; FF61  AD CD 00
    sta PPUDATA                                 ; FF64  8D 07 20
    lda #$0F                                    ; FF67  A9 0F
    sta PPUDATA                                 ; FF69  8D 07 20
    lda a:PaletteBuf+18                         ; FF6C  AD CE 00
    sta PPUDATA                                 ; FF6F  8D 07 20
    lda a:PaletteBuf+19                         ; FF72  AD CF 00
    sta PPUDATA                                 ; FF75  8D 07 20
    lda a:PaletteBuf+20                         ; FF78  AD D0 00
    sta PPUDATA                                 ; FF7B  8D 07 20
    lda #$0F                                    ; FF7E  A9 0F
    sta PPUDATA                                 ; FF80  8D 07 20
    lda a:PaletteBuf+21                         ; FF83  AD D1 00
    sta PPUDATA                                 ; FF86  8D 07 20
    lda a:PaletteBuf+22                         ; FF89  AD D2 00
    sta PPUDATA                                 ; FF8C  8D 07 20
    lda a:PaletteBuf+23                         ; FF8F  AD D3 00
    sta PPUDATA                                 ; FF92  8D 07 20
    lda #$00                                    ; FF95  A9 00
    sta a:PaletteDirty                          ; FF97  8D D4 00
    rts                                         ; FF9A  60

