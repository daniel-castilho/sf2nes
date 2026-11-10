; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; Banco de PRG $3B (CODIGO) — janela $E000-$FFFF — offset no arquivo $076010
;
.include "defs.inc"
.segment "BANK3B"

; ------------------------------------------------------------------------------------------------
; Carrega a "ficha" do personagem FighterChar,x a partir das tabelas do banco $3C (10 personagens por tabela):
; bancos de dados (frames em $8000, estados em $A000) e ponteiros para os estados basicos.
; Hoje so a coluna 0 (Ryu) esta preenchida. Para um personagem novo, este e' o ponto de partida.
; <- jsr ScreenVersus
; modos: VS
FighterLoadChar:
    ldy FighterChar,x                           ; E000  B4 00
    lda #$00                                    ; E002  A9 00
    sta FighterWins,x                           ; E004  95 10
    lda #$3C                                    ; E006  A9 3C
    ora #$80                                    ; E008  09 80
    sta MMC5_PRG_8000                           ; E00A  8D 14 51
    lda CharFrameBankTbl,y                      ; E00D  B9 D2 80    [bancos $3C idx $00..$00]
    sta a:FighterFrameBank,x                    ; E010  9D 18 00
    lda CharStateBankTbl,y                      ; E013  B9 C8 80    [bancos $3C idx $00..$00]
    sta a:FighterStateBank,x                    ; E016  9D 1A 00
    lda D3C_80DC,y                              ; E019  B9 DC 80    [bancos $3C idx $00..$00]
    sta a:zp_1C,x                               ; E01C  9D 1C 00
    lda D3C_8000,y                              ; E01F  B9 00 80    [bancos $3C idx $00..$00]
    sta ram_031E,x                              ; E022  9D 1E 03
    lda D3C_800A                                ; E025  AD 0A 80    [bancos $3C]
    sta ram_0320,x                              ; E028  9D 20 03
    lda D3C_8014,y                              ; E02B  B9 14 80    [bancos $3C idx $00..$00]
    sta ram_0322,x                              ; E02E  9D 22 03
    lda D3C_801E,y                              ; E031  B9 1E 80    [bancos $3C idx $00..$00]
    sta ram_0324,x                              ; E034  9D 24 03
    lda D3C_8028,y                              ; E037  B9 28 80    [bancos $3C idx $00..$00]
    sta ram_0326,x                              ; E03A  9D 26 03
    lda D3C_8032,y                              ; E03D  B9 32 80    [bancos $3C idx $00..$00]
    sta ram_0328,x                              ; E040  9D 28 03
    lda D3C_803C,y                              ; E043  B9 3C 80    [bancos $3C idx $00..$00]
    sta ram_032A,x                              ; E046  9D 2A 03
    lda D3C_8046,y                              ; E049  B9 46 80    [bancos $3C idx $00..$00]
    sta ram_032C,x                              ; E04C  9D 2C 03
    lda D3C_8050,y                              ; E04F  B9 50 80    [bancos $3C idx $00..$00]
    sta ram_032E,x                              ; E052  9D 2E 03
    lda D3C_805A,y                              ; E055  B9 5A 80    [bancos $3C idx $00..$00]
    sta ram_0330,x                              ; E058  9D 30 03
    lda D3C_8078,y                              ; E05B  B9 78 80    [bancos $3C idx $00..$00]
    sta ram_0332,x                              ; E05E  9D 32 03
    lda D3C_8082,y                              ; E061  B9 82 80    [bancos $3C idx $00..$00]
    sta ram_0334,x                              ; E064  9D 34 03
    lda D3C_8064,y                              ; E067  B9 64 80    [bancos $3C idx $00..$00]
    sta ram_0336,x                              ; E06A  9D 36 03
    lda D3C_806E,y                              ; E06D  B9 6E 80    [bancos $3C idx $00..$00]
    sta ram_0338,x                              ; E070  9D 38 03
    lda D3C_808C,y                              ; E073  B9 8C 80    [bancos $3C idx $00..$00]
    sta ram_033A,x                              ; E076  9D 3A 03
    lda D3C_8096,y                              ; E079  B9 96 80    [bancos $3C idx $00..$00]
    sta ram_033C,x                              ; E07C  9D 3C 03
    lda D3C_80A0,y                              ; E07F  B9 A0 80    [bancos $3C idx $00..$00]
    sta ram_033E,x                              ; E082  9D 3E 03
    lda D3C_80AA,y                              ; E085  B9 AA 80    [bancos $3C idx $00..$00]
    sta ram_0340,x                              ; E088  9D 40 03
    lda D3C_80B4,y                              ; E08B  B9 B4 80    [bancos $3C idx $00..$00]
    sta ram_0342,x                              ; E08E  9D 42 03
    lda D3C_80BE,y                              ; E091  B9 BE 80    [bancos $3C idx $00..$00]
    sta ram_0344,x                              ; E094  9D 44 03
    rts                                         ; E097  60


; <- jsr RoundInit
; modos: intro do round
FighterRoundInit:
    lda #$5A                                    ; E098  A9 5A       posicao inicial: P1 x=$5A, P2 x=$A6, y=$CD (chao)
    cpx #$00                                    ; E09A  E0 00
    beq L3B_E0A0                                ; E09C  F0 02
    lda #$A6                                    ; E09E  A9 A6
L3B_E0A0:
    sta FighterX,x                              ; E0A0  95 08
    lda #$CD                                    ; E0A2  A9 CD
    sta FighterY,x                              ; E0A4  95 0C
    lda #$00                                    ; E0A6  A9 00
    sta FighterXSub,x                           ; E0A8  95 06
    sta FighterYSub,x                           ; E0AA  95 0A
    lda a:FighterStateBank,x                    ; E0AC  BD 1A 00
    ora #$80                                    ; E0AF  09 80
    sta MMC5_PRG_A000                           ; E0B1  8D 15 51
    lda ram_031E,x                              ; E0B4  BD 1E 03
    sta zp_D7                                   ; E0B7  85 D7
    lda ram_0320,x                              ; E0B9  BD 20 03
    sta zp_D8                                   ; E0BC  85 D8
    ldy #$00                                    ; E0BE  A0 00
    lda (zp_D7),y                               ; E0C0  B1 D7       [le bancos $01]
    sta zp_D5                                   ; E0C2  85 D5
    iny                                         ; E0C4  C8
    lda (zp_D7),y                               ; E0C5  B1 D7       [le bancos $01]
    sta zp_D8                                   ; E0C7  85 D8
    lda zp_D5                                   ; E0C9  A5 D5
    sta zp_D7                                   ; E0CB  85 D7
    ldy #$03                                    ; E0CD  A0 03
    lda (zp_D7),y                               ; E0CF  B1 D7       [le bancos $01]
    sta a:FighterStatePtrLo,x                   ; E0D1  9D 1E 00
    clc                                         ; E0D4  18
    adc #$07                                    ; E0D5  69 07
    sta a:FighterFramePtrLo,x                   ; E0D7  9D 2A 00
    sta zp_D5                                   ; E0DA  85 D5
    iny                                         ; E0DC  C8
    lda (zp_D7),y                               ; E0DD  B1 D7       [le bancos $01]
    sta a:FighterStatePtrHi,x                   ; E0DF  9D 20 00
    adc #$00                                    ; E0E2  69 00
    sta a:FighterFramePtrHi,x                   ; E0E4  9D 2C 00
    sta zp_D6                                   ; E0E7  85 D6
    lda #$59                                    ; E0E9  A9 59
    sta a:FighterState,x                        ; E0EB  9D 26 00
    lda #$00                                    ; E0EE  A9 00
    sta a:zp_28,x                               ; E0F0  9D 28 00
    sta a:FighterNextPtrLo,x                    ; E0F3  9D 22 00
    sta a:FighterNextPtrHi,x                    ; E0F6  9D 24 00
    ldy #$00                                    ; E0F9  A0 00
    lda (zp_D5),y                               ; E0FB  B1 D5       [le bancos $01]
    sta a:FighterAnimTimer,x                    ; E0FD  9D 42 00
    ldy #$0B                                    ; E100  A0 0B
    lda (zp_D5),y                               ; E102  B1 D5       [le bancos $01]
    sta a:zp_44,x                               ; E104  9D 44 00
    ldy #$07                                    ; E107  A0 07
    lda (zp_D5),y                               ; E109  B1 D5       [le bancos $01]
    sta a:zp_38,x                               ; E10B  9D 38 00
    ldy #$08                                    ; E10E  A0 08
    lda (zp_D5),y                               ; E110  B1 D5       [le bancos $01]
    sta a:zp_2E,x                               ; E112  9D 2E 00
    lda #$00                                    ; E115  A9 00
    sta a:FighterVelXSub,x                      ; E117  9D 30 00
    sta a:FighterVelX,x                         ; E11A  9D 32 00
    sta a:FighterVelYSub,x                      ; E11D  9D 34 00
    sta a:FighterVelY,x                         ; E120  9D 36 00
    sta a:zp_3A,x                               ; E123  9D 3A 00
    sta a:zp_3C,x                               ; E126  9D 3C 00
    sta a:zp_3E,x                               ; E129  9D 3E 00
    txa                                         ; E12C  8A
    beq L3B_E131                                ; E12D  F0 02
    lda #$40                                    ; E12F  A9 40
L3B_E131:
    sta FighterFlip,x                           ; E131  95 04
    lda #$00                                    ; E133  A9 00
    sta a:zp_5E,x                               ; E135  9D 5E 00
    sta a:zp_60,x                               ; E138  9D 60 00
    sta a:zp_62,x                               ; E13B  9D 62 00
    sta a:FighterDmgPending,x                   ; E13E  9D 14 00
    sta a:zp_16,x                               ; E141  9D 16 00
    lda #$58                                    ; E144  A9 58
    sta FighterHP,x                             ; E146  95 0E
    lda #<D3C_80E6                              ; E148  A9 E6
    sta zp_DB                                   ; E14A  85 DB
    lda #>D3C_80E6                              ; E14C  A9 80
    sta zp_DC                                   ; E14E  85 DC
    lda #<D3C_815E                              ; E150  A9 5E
    sta zp_DD                                   ; E152  85 DD
    lda #>D3C_815E                              ; E154  A9 81
    sta zp_DE                                   ; E156  85 DE
    lda #<D3C_83B6                              ; E158  A9 B6
    sta zp_DF                                   ; E15A  85 DF
    lda #>D3C_83B6                              ; E15C  A9 83
    sta zp_E0                                   ; E15E  85 E0
    jsr L3B_E181                                ; E160  20 81 E1
    ldx #$02                                    ; E163  A2 02
L3B_E165:
    lda ram_0303,x                              ; E165  BD 03 03
    sta a:PaletteBuf+12,x                       ; E168  9D C8 00
    lda ram_030C,x                              ; E16B  BD 0C 03
    sta a:PaletteBuf+15,x                       ; E16E  9D CB 00
    lda ram_0300,x                              ; E171  BD 00 03
    sta a:PaletteBuf+18,x                       ; E174  9D CE 00
    lda ram_0309,x                              ; E177  BD 09 03
    sta a:PaletteBuf+21,x                       ; E17A  9D D1 00
    dex                                         ; E17D  CA
    bpl L3B_E165                                ; E17E  10 E5
    rts                                         ; E180  60


; <- jsr FighterRoundInit, jsr L3B_EE5B, jsr L3B_EF47
; modos: selecao, VS, intro do round, frase final
L3B_E181:
    lda #$3C                                    ; E181  A9 3C
    ora #$80                                    ; E183  09 80
    sta MMC5_PRG_8000                           ; E185  8D 14 51
    lda #<D3C_83B6                              ; E188  A9 B6
    sta zp_DF                                   ; E18A  85 DF
    lda #>D3C_83B6                              ; E18C  A9 83
    sta zp_E0                                   ; E18E  85 E0
    lda FighterChar,x                           ; E190  B5 00
    asl a                                       ; E192  0A
    asl a                                       ; E193  0A
    sta zp_E1                                   ; E194  85 E1
    asl a                                       ; E196  0A
    adc zp_E1                                   ; E197  65 E1
    sta zp_E1                                   ; E199  85 E1
    lda zp_DB                                   ; E19B  A5 DB
    adc zp_E1                                   ; E19D  65 E1
    sta zp_DB                                   ; E19F  85 DB
    bcc L3B_E1A6                                ; E1A1  90 03
    inc zp_DC                                   ; E1A3  E6 DC
    clc                                         ; E1A5  18
L3B_E1A6:
    lda zp_DD                                   ; E1A6  A5 DD
    adc zp_E1                                   ; E1A8  65 E1
    sta zp_DD                                   ; E1AA  85 DD
    bcc L3B_E1B1                                ; E1AC  90 03
    inc zp_DE                                   ; E1AE  E6 DE       (nt)
    clc                                         ; E1B0  18          (nt)
L3B_E1B1:
    lda zp_DF                                   ; E1B1  A5 DF
    adc zp_E1                                   ; E1B3  65 E1
    sta zp_DF                                   ; E1B5  85 DF
    bcc L3B_E1BB                                ; E1B7  90 02
    inc zp_E0                                   ; E1B9  E6 E0
L3B_E1BB:
    lda zp_12,x                                 ; E1BB  B5 12
    asl a                                       ; E1BD  0A
    adc zp_12,x                                 ; E1BE  75 12
    tay                                         ; E1C0  A8
    txa                                         ; E1C1  8A
    beq L3B_E1C6                                ; E1C2  F0 02
    ldx #$09                                    ; E1C4  A2 09
L3B_E1C6:
    lda (zp_DB),y                               ; E1C6  B1 DB       [le bancos $3C]
    sta ram_0300,x                              ; E1C8  9D 00 03
    lda (zp_DD),y                               ; E1CB  B1 DD       [le bancos $3C]
    sta ram_0303,x                              ; E1CD  9D 03 03
    lda (zp_DF),y                               ; E1D0  B1 DF       [le bancos $3C]
    sta ram_0306,x                              ; E1D2  9D 06 03
    iny                                         ; E1D5  C8
    lda (zp_DB),y                               ; E1D6  B1 DB       [le bancos $3C]
    sta ram_0301,x                              ; E1D8  9D 01 03
    lda (zp_DD),y                               ; E1DB  B1 DD       [le bancos $3C]
    sta ram_0304,x                              ; E1DD  9D 04 03
    lda (zp_DF),y                               ; E1E0  B1 DF       [le bancos $3C]
    sta ram_0307,x                              ; E1E2  9D 07 03
    iny                                         ; E1E5  C8
    lda (zp_DB),y                               ; E1E6  B1 DB       [le bancos $3C]
    sta ram_0302,x                              ; E1E8  9D 02 03
    lda (zp_DD),y                               ; E1EB  B1 DD       [le bancos $3C]
    sta ram_0305,x                              ; E1ED  9D 05 03
    lda (zp_DF),y                               ; E1F0  B1 DF       [le bancos $3C]
    sta ram_0308,x                              ; E1F2  9D 08 03
    rts                                         ; E1F5  60


; <- jsr L3B_EEAE
; modos: selecao, VS, frase final
PortraitBuild:
    lda zp_DD                                   ; E1F6  A5 DD
    ora #$80                                    ; E1F8  09 80
    sta MMC5_PRG_8000                           ; E1FA  8D 14 51
    ldx #$3B                                    ; E1FD  A2 3B
    lda #$00                                    ; E1FF  A9 00
L3B_E201:
    sta ram_034E,x                              ; E201  9D 4E 03
    dex                                         ; E204  CA
    bpl L3B_E201                                ; E205  10 FA
    ldy #$00                                    ; E207  A0 00
    lda (zp_DB),y                               ; E209  B1 DB       [le bancos $00,$04,$08,$0C,$10,$1C,$20,$24]
    sta ram_0390                                ; E20B  8D 90 03
L3B_E20E:
    iny                                         ; E20E  C8

; <- jmp PortraitBuild
; modos: selecao, VS, frase final
L3B_E20F:
    iny                                         ; E20F  C8
    lda (zp_DB),y                               ; E210  B1 DB       [le bancos $00,$04,$08,$0C,$10,$1C,$20,$24]
    bmi L3B_E241                                ; E212  30 2D
    sta zp_DF                                   ; E214  85 DF
    iny                                         ; E216  C8
    lda (zp_DB),y                               ; E217  B1 DB       [le bancos $00,$04,$08,$0C,$10,$1C,$20,$24]
    lsr a                                       ; E219  4A
    lsr a                                       ; E21A  4A
    lsr a                                       ; E21B  4A
    sta zp_E0                                   ; E21C  85 E0
    iny                                         ; E21E  C8
    lda (zp_DB),y                               ; E21F  B1 DB       [le bancos $00,$04,$08,$0C,$10,$1C,$20,$24]
    clc                                         ; E221  18
    adc #$51                                    ; E222  69 51
    lsr a                                       ; E224  4A
    lsr a                                       ; E225  4A
    lsr a                                       ; E226  4A
    asl a                                       ; E227  0A
    sta zp_E1                                   ; E228  85 E1
    asl a                                       ; E22A  0A
    adc zp_E1                                   ; E22B  65 E1
    adc zp_E0                                   ; E22D  65 E0
    tax                                         ; E22F  AA
L3B_E230:
    iny                                         ; E230  C8
    lda (zp_DB),y                               ; E231  B1 DB       [le bancos $00,$04,$08,$0C,$10,$1C,$20,$24]
    clc                                         ; E233  18
    adc #$80                                    ; E234  69 80
    sta ram_034E,x                              ; E236  9D 4E 03
    inx                                         ; E239  E8
    dec zp_DF                                   ; E23A  C6 DF
    bne L3B_E230                                ; E23C  D0 F2
    jmp L3B_E20F                                ; E23E  4C 0F E2


L3B_E241:
    dec zp_DE                                   ; E241  C6 DE
    bne L3B_E20E                                ; E243  D0 C9
    ldx #$30                                    ; E245  A2 30
L3B_E247:
    clc                                         ; E247  18
    lda ram_034E,x                              ; E248  BD 4E 03
    beq L3B_E252                                ; E24B  F0 05
    adc #$01                                    ; E24D  69 01
    sta ram_0354,x                              ; E24F  9D 54 03
L3B_E252:
    lda ram_034F,x                              ; E252  BD 4F 03
    beq L3B_E25C                                ; E255  F0 05
    adc #$01                                    ; E257  69 01
    sta ram_0355,x                              ; E259  9D 55 03
L3B_E25C:
    lda ram_0350,x                              ; E25C  BD 50 03
    beq L3B_E266                                ; E25F  F0 05
    adc #$01                                    ; E261  69 01
    sta ram_0356,x                              ; E263  9D 56 03
L3B_E266:
    lda ram_0351,x                              ; E266  BD 51 03
    beq L3B_E270                                ; E269  F0 05
    adc #$01                                    ; E26B  69 01
    sta ram_0357,x                              ; E26D  9D 57 03
L3B_E270:
    lda ram_0352,x                              ; E270  BD 52 03
    beq L3B_E27A                                ; E273  F0 05
    adc #$01                                    ; E275  69 01
    sta ram_0358,x                              ; E277  9D 58 03
L3B_E27A:
    lda ram_0353,x                              ; E27A  BD 53 03
    beq L3B_E284                                ; E27D  F0 05
    adc #$01                                    ; E27F  69 01
    sta ram_0359,x                              ; E281  9D 59 03
L3B_E284:
    txa                                         ; E284  8A
    axs #$0C                                    ; E285  CB 0C
    bpl L3B_E247                                ; E287  10 BE
    rts                                         ; E289  60


; <- jsr ScreenVersus
; modos: VS
L3B_E28A:
    ldx ram_03B5                                ; E28A  AE B5 03
    txa                                         ; E28D  8A
    cmp #$05                                    ; E28E  C9 05
    bcc L3B_E294                                ; E290  90 02
    sbc #$05                                    ; E292  E9 05       (nt)
L3B_E294:
    asl a                                       ; E294  0A
    sta zp_D5                                   ; E295  85 D5
    tay                                         ; E297  A8
    lda D3B_F8FE,x                              ; E298  BD FE F8    [idx $00..$00]
    ora #$80                                    ; E29B  09 80
    sta MMC5_PRG_C000                           ; E29D  8D 16 51
    lda #$CD                                    ; E2A0  A9 CD
    sta ram_03BA                                ; E2A2  8D BA 03
    lda D36_C000,y                              ; E2A5  B9 00 C0    [bancos $36 idx $00..$00]
    sta FloorLines                              ; E2A8  8D BB 03
    lda D36_C005,y                              ; E2AB  B9 05 C0    [bancos $36 idx $00..$00]
    sta ram_03BC                                ; E2AE  8D BC 03
    lda D36_C00A,y                              ; E2B1  B9 0A C0    [bancos $36 idx $00..$00]
    sta ram_03BD                                ; E2B4  8D BD 03
    lda D36_C00F,y                              ; E2B7  B9 0F C0    [bancos $36 idx $00..$00]
    sta ram_03BE                                ; E2BA  8D BE 03
    lda #$28                                    ; E2BD  A9 28
    sta PPUADDR                                 ; E2BF  8D 06 20
    lda #$00                                    ; E2C2  A9 00
    sta PPUADDR                                 ; E2C4  8D 06 20
    ldy zp_D5                                   ; E2C7  A4 D5
    lda D36_C03C,y                              ; E2C9  B9 3C C0    [bancos $36 idx $00..$00]
    ldx D36_C03C+1,y                            ; E2CC  BE 3D C0    [bancos $36 idx $00..$00]
    jsr PpuUnRle                                ; E2CF  20 BE E3
    ldy zp_D5                                   ; E2D2  A4 D5
    lda D36_C050,y                              ; E2D4  B9 50 C0    [bancos $36 idx $00..$00]
    ldx D36_C050+1,y                            ; E2D7  BE 51 C0    [bancos $36 idx $00..$00]
    jsr PpuUnRle                                ; E2DA  20 BE E3
    ldy zp_D5                                   ; E2DD  A4 D5
    lda D36_C064,y                              ; E2DF  B9 64 C0    [bancos $36 idx $00..$00]
    ldx D36_C064+1,y                            ; E2E2  BE 65 C0    [bancos $36 idx $00..$00]
    jsr PpuUnRle                                ; E2E5  20 BE E3
    lda #$2C                                    ; E2E8  A9 2C
    sta PPUADDR                                 ; E2EA  8D 06 20
    lda #$00                                    ; E2ED  A9 00
    sta PPUADDR                                 ; E2EF  8D 06 20
    ldy zp_D5                                   ; E2F2  A4 D5
    lda D36_C046,y                              ; E2F4  B9 46 C0    [bancos $36 idx $00..$00]
    ldx D36_C046+1,y                            ; E2F7  BE 47 C0    [bancos $36 idx $00..$00]
    jsr PpuUnRle                                ; E2FA  20 BE E3
    ldy zp_D5                                   ; E2FD  A4 D5
    lda D36_C05A,y                              ; E2FF  B9 5A C0    [bancos $36 idx $00..$00]
    ldx D36_C05A+1,y                            ; E302  BE 5B C0    [bancos $36 idx $00..$00]
    jsr PpuUnRle                                ; E305  20 BE E3
    ldy zp_D5                                   ; E308  A4 D5
    lda D36_C06E,y                              ; E30A  B9 6E C0    [bancos $36 idx $00..$00]
    ldx D36_C06E+1,y                            ; E30D  BE 6F C0    [bancos $36 idx $00..$00]
    jsr PpuUnRle                                ; E310  20 BE E3
    lda #$2B                                    ; E313  A9 2B
    sta PPUADDR                                 ; E315  8D 06 20
    lda #$C0                                    ; E318  A9 C0
    sta PPUADDR                                 ; E31A  8D 06 20
    ldy zp_D5                                   ; E31D  A4 D5
    lda D36_C078,y                              ; E31F  B9 78 C0    [bancos $36 idx $00..$00]
    ldx D36_C078+1,y                            ; E322  BE 79 C0    [bancos $36 idx $00..$00]
    jsr L3B_E3F5                                ; E325  20 F5 E3
    lda #$2F                                    ; E328  A9 2F
    sta PPUADDR                                 ; E32A  8D 06 20
    lda #$C0                                    ; E32D  A9 C0
    sta PPUADDR                                 ; E32F  8D 06 20
    ldy zp_D5                                   ; E332  A4 D5
    lda D36_C082,y                              ; E334  B9 82 C0    [bancos $36 idx $00..$00]
    ldx D36_C082+1,y                            ; E337  BE 83 C0    [bancos $36 idx $00..$00]
    jsr L3B_E3F5                                ; E33A  20 F5 E3
    lda zp_D5                                   ; E33D  A5 D5
    lsr a                                       ; E33F  4A
    tay                                         ; E340  A8
    lda D36_C014,y                              ; E341  B9 14 C0    [bancos $36 idx $00..$00]
    sta ram_0406                                ; E344  8D 06 04
    lda D36_C019,y                              ; E347  B9 19 C0    [bancos $36 idx $00..$00]
    sta ram_0407                                ; E34A  8D 07 04
    lda D36_C01E,y                              ; E34D  B9 1E C0    [bancos $36 idx $00..$00]
    sta ram_0408                                ; E350  8D 08 04
    lda D36_C023,y                              ; E353  B9 23 C0    [bancos $36 idx $00..$00]
    sta ram_0409                                ; E356  8D 09 04
    lda D36_C028,y                              ; E359  B9 28 C0    [bancos $36 idx $00..$00]
    sta ram_040A                                ; E35C  8D 0A 04
    lda D36_C02D,y                              ; E35F  B9 2D C0    [bancos $36 idx $00..$00]
    sta ram_040B                                ; E362  8D 0B 04
    lda #$3F                                    ; E365  A9 3F
    sta ram_0403                                ; E367  8D 03 04
    lda D36_C032,y                              ; E36A  B9 32 C0    [bancos $36 idx $00..$00]
    sta ram_0404                                ; E36D  8D 04 04
    lda D36_C037,y                              ; E370  B9 37 C0    [bancos $36 idx $00..$00]
    sta ram_0405                                ; E373  8D 05 04
    rts                                         ; E376  60


; <- jsr RoundInit
; modos: intro do round
L3B_E377:
    ldx ram_03B5                                ; E377  AE B5 03
    txa                                         ; E37A  8A
    cmp #$05                                    ; E37B  C9 05
    bcc L3B_E381                                ; E37D  90 02
    sbc #$05                                    ; E37F  E9 05       (nt)
L3B_E381:
    asl a                                       ; E381  0A
    tay                                         ; E382  A8
    lda D3B_F8FE,x                              ; E383  BD FE F8    [idx $00..$00]
    ora #$80                                    ; E386  09 80
    sta MMC5_PRG_C000                           ; E388  8D 16 51
    lda D36_C08C,y                              ; E38B  B9 8C C0    [bancos $36 idx $00..$00]
    sta zp_D5                                   ; E38E  85 D5
    lda D36_C08C+1,y                            ; E390  B9 8D C0    [bancos $36 idx $00..$00]
    sta zp_D6                                   ; E393  85 D6
    ldy #$0B                                    ; E395  A0 0B
L3B_E397:
    lda (zp_D5),y                               ; E397  B1 D5       [le bancos $36]
    sta a:PaletteBuf,y                          ; E399  99 BC 00
    dey                                         ; E39C  88
    bpl L3B_E397                                ; E39D  10 F8
    lda #$00                                    ; E39F  A9 00
    sta HitStop                                 ; E3A1  8D 0C 04
    lda #$CD                                    ; E3A4  A9 CD
    sta ram_03BA                                ; E3A6  8D BA 03
    lda #$80                                    ; E3A9  A9 80
    sta CameraX                                 ; E3AB  8D B7 03
    lda #$00                                    ; E3AE  A9 00
    sta ram_03B6                                ; E3B0  8D B6 03
    sta ram_03B8                                ; E3B3  8D B8 03
    lda #$10                                    ; E3B6  A9 10
    sta ram_03B9                                ; E3B8  8D B9 03
    jmp L3B_E59D                                ; E3BB  4C 9D E5


; Descompacta RLE (formato do NESlib/Shiru: 1o byte = marcador; marcador,n = repete o ultimo byte n vezes;
; marcador,0 = fim) direto em PPUDATA. Entrada: A = byte baixo, X = byte alto do endereco dos dados.
; <- jsr L3B_E28A, jsr L3B_EAF2, jsr L3B_F376, jmp L3B_F376, jmp DrawSupportScreen, jmp DrawTitleScreen
; modos: aviso/QR, titulo, selecao, VS
PpuUnRle:
    tay                                         ; E3BE  A8
    stx RlePtr+1                                ; E3BF  86 FB
    lda #$00                                    ; E3C1  A9 00
    sta RlePtr                                  ; E3C3  85 FA
    lda (RlePtr),y                              ; E3C5  B1 FA       [le bancos $36,$3B]
    sta RleTag                                  ; E3C7  85 FC
    iny                                         ; E3C9  C8
    bne L3B_E3CE                                ; E3CA  D0 02
    inc RlePtr+1                                ; E3CC  E6 FB       (nt)
L3B_E3CE:
    lda (RlePtr),y                              ; E3CE  B1 FA       [le bancos $36,$3B]
    iny                                         ; E3D0  C8
    bne L3B_E3D5                                ; E3D1  D0 02
    inc RlePtr+1                                ; E3D3  E6 FB
L3B_E3D5:
    cmp RleTag                                  ; E3D5  C5 FC
    beq L3B_E3E0                                ; E3D7  F0 07
    sta PPUDATA                                 ; E3D9  8D 07 20
    sta RleLast                                 ; E3DC  85 FD
    bne L3B_E3CE                                ; E3DE  D0 EE
L3B_E3E0:
    lda (RlePtr),y                              ; E3E0  B1 FA       [le bancos $36,$3B]
    beq L3B_E3F4                                ; E3E2  F0 10
    iny                                         ; E3E4  C8
    bne L3B_E3E9                                ; E3E5  D0 02
    inc RlePtr+1                                ; E3E7  E6 FB       (nt)
L3B_E3E9:
    tax                                         ; E3E9  AA
    lda RleLast                                 ; E3EA  A5 FD
L3B_E3EC:
    sta PPUDATA                                 ; E3EC  8D 07 20
    dex                                         ; E3EF  CA
    bne L3B_E3EC                                ; E3F0  D0 FA
    beq L3B_E3CE                                ; E3F2  F0 DA
L3B_E3F4:
    rts                                         ; E3F4  60


; <- jsr L3B_E28A
; modos: VS
L3B_E3F5:
    sta RlePtr                                  ; E3F5  85 FA
    stx RlePtr+1                                ; E3F7  86 FB
    ldy #$00                                    ; E3F9  A0 00
L3B_E3FB:
    lda (RlePtr),y                              ; E3FB  B1 FA       [le bancos $36]
    sta PPUDATA                                 ; E3FD  8D 07 20
    iny                                         ; E400  C8
    cpy #$40                                    ; E401  C0 40
    bne L3B_E3FB                                ; E403  D0 F6
    rts                                         ; E405  60

D3B_E406:
    .byte $10,$20,$10,$30,$20,$10,$40,$30,$20,$10; E406
D3B_E410:
    .byte $00,$10,$00,$20,$10,$00,$30,$20,$10,$00; E410
D3B_E41A:
    .byte $40,$40,$30,$40,$30,$20               ; E41A
D3B_E420:
    .byte $30,$30,$20,$30,$20,$10               ; E420

; <- farjmp L37_F19E, farcall ScreenDisclaimer, farjmp ScreenSupport, farjmp L37_F652, jmp L3B_EAF2, jmp L3B_EC83 ... (+1)
; modos: aviso/QR, titulo, selecao, VS, fim do round, frase final
FadeOut:
    ldx #$09                                    ; E426  A2 09
L3B_E428:
    lda #$00                                    ; E428  A9 00
    sta VBlankFlag                              ; E42A  85 AC
L3B_E42C:
    lda VBlankFlag                              ; E42C  A5 AC
    beq L3B_E42C                                ; E42E  F0 FC
    sta a:PaletteDirty                          ; E430  8D D4 00
    lda ScreenMode                              ; E433  A5 B0
    cmp #$01                                    ; E435  C9 01
    bne L3B_E455                                ; E437  D0 1C
    lda #$2F                                    ; E439  A9 2F
    sta MMC5_CHR_BG1                            ; E43B  8D 29 51
    lda #$30                                    ; E43E  A9 30
    sta MMC5_CHR_BG3                            ; E440  8D 2B 51
L3B_E443:
    bit PPUSTATUS                               ; E443  2C 02 20
    bvs L3B_E443                                ; E446  70 FB
L3B_E448:
    bit PPUSTATUS                               ; E448  2C 02 20
    bvc L3B_E448                                ; E44B  50 FB
    lda #$0D                                    ; E44D  A9 0D
    sta MMC5_CHR_BG1                            ; E44F  8D 29 51
    jmp L3B_E47E                                ; E452  4C 7E E4


L3B_E455:
    cmp #$06                                    ; E455  C9 06
    bne L3B_E47E                                ; E457  D0 25
    stx FadePalette                             ; E459  8E 85 04
    lda #$00                                    ; E45C  A9 00
    sta OamIndex                                ; E45E  85 AD
    jsr StageSplitSetup                         ; E460  20 08 F9
    farcall FightersUpdate                      ; E463  A9 E4 48 A9 74 48 A9 3B .. -> 3F:EF74
    jsr StageParallaxCalc                       ; E475  20 40 F9
    jsr OamHideRest                             ; E478  20 DF F2
    ldx FadePalette                             ; E47B  AE 85 04

; <- jmp FadeOut
; modos: aviso/QR, titulo, selecao, VS, fim do round, frase final
L3B_E47E:
    ldy #$17                                    ; E47E  A0 17
L3B_E480:
    lda a:PaletteBuf,y                          ; E480  B9 BC 00
    cmp D3B_E406,x                              ; E483  DD 06 E4    [idx $00..$80]
    bcs L3B_E496                                ; E486  B0 0E
    cmp D3B_E410,x                              ; E488  DD 10 E4    [idx $00..$7B]
    bcc L3B_E496                                ; E48B  90 09
    sbc #$10                                    ; E48D  E9 10
    bpl L3B_E493                                ; E48F  10 02
    lda #$0F                                    ; E491  A9 0F
L3B_E493:
    sta a:PaletteBuf,y                          ; E493  99 BC 00
L3B_E496:
    dey                                         ; E496  88
    bpl L3B_E480                                ; E497  10 E7
    dex                                         ; E499  CA
    bpl L3B_E428                                ; E49A  10 8C
    lda #$00                                    ; E49C  A9 00
    sta FrameCounter                            ; E49E  85 B1
    lda PpuMaskShadow                           ; E4A0  A5 EE
    and #$E7                                    ; E4A2  29 E7
    sta PpuMaskShadow                           ; E4A4  85 EE
L3B_E4A6:
    lda #$00                                    ; E4A6  A9 00
    sta VBlankFlag                              ; E4A8  85 AC
L3B_E4AA:
    lda VBlankFlag                              ; E4AA  A5 AC
    beq L3B_E4AA                                ; E4AC  F0 FC
    lda FrameCounter                            ; E4AE  A5 B1
    and #$1F                                    ; E4B0  29 1F
    bne L3B_E4A6                                ; E4B2  D0 F2
    lda PpuCtrlShadow                           ; E4B4  A5 ED
    and #$FC                                    ; E4B6  29 FC
    ora #$02                                    ; E4B8  09 02
    sta PpuCtrlShadow                           ; E4BA  85 ED
    lda PpuCtrlShadow                           ; E4BC  A5 ED
    and #$7F                                    ; E4BE  29 7F
    sta PpuCtrlShadow                           ; E4C0  85 ED
    sta PPUCTRL                                 ; E4C2  8D 00 20
    sei                                         ; E4C5  78
    lda MMC5_IRQ_STATUS                         ; E4C6  AD 04 52
    lda #$00                                    ; E4C9  A9 00
    sta a:ScrollX                               ; E4CB  8D EF 00
    sta a:ScrollY                               ; E4CE  8D F0 00
    sta OamIndex                                ; E4D1  85 AD
    jmp OamHideRest                             ; E4D3  4C DF F2


; <- farcall ScreenPlayerSelect, jsr L3B_EAF2, jsr ScreenWinQuote, farcall Match
; modos: selecao, VS, intro do round, frase final
FadeIn:
    ldx #$17                                    ; E4D6  A2 17
L3B_E4D8:
    lda a:PaletteBuf,x                          ; E4D8  BD BC 00
    sta FadePalette,x                           ; E4DB  9D 85 04
    and #$0F                                    ; E4DE  29 0F
    sta a:PaletteBuf,x                          ; E4E0  9D BC 00
    dex                                         ; E4E3  CA
    bpl L3B_E4D8                                ; E4E4  10 F2
    lda PpuCtrlShadow                           ; E4E6  A5 ED
    ora #$80                                    ; E4E8  09 80
    sta PpuCtrlShadow                           ; E4EA  85 ED
    sta PPUCTRL                                 ; E4EC  8D 00 20
    lda #$00                                    ; E4EF  A9 00
    sta VBlankFlag                              ; E4F1  85 AC
L3B_E4F3:
    lda VBlankFlag                              ; E4F3  A5 AC
    beq L3B_E4F3                                ; E4F5  F0 FC
    sta a:PaletteDirty                          ; E4F7  8D D4 00
    lda ScreenMode                              ; E4FA  A5 B0
    cmp #$04                                    ; E4FC  C9 04
    bne L3B_E521                                ; E4FE  D0 21
    cli                                         ; E500  58
    lda #$1F                                    ; E501  A9 1F
    sta FrameCounter                            ; E503  85 B1
    lda #$00                                    ; E505  A9 00
    sta VBlankFlag                              ; E507  85 AC
L3B_E509:
    lda VBlankFlag                              ; E509  A5 AC
    beq L3B_E509                                ; E50B  F0 FC
    jsr StageSplitSetup                         ; E50D  20 08 F9
    jsr StageParallaxCalc                       ; E510  20 40 F9
    lda #$00                                    ; E513  A9 00
    sta VBlankFlag                              ; E515  85 AC
L3B_E517:
    lda VBlankFlag                              ; E517  A5 AC
    beq L3B_E517                                ; E519  F0 FC
    jsr StageSplitSetup                         ; E51B  20 08 F9
    jsr StageParallaxCalc                       ; E51E  20 40 F9
L3B_E521:
    lda PpuMaskShadow                           ; E521  A5 EE
    ora #$18                                    ; E523  09 18
    sta PpuMaskShadow                           ; E525  85 EE
    ldx #$06                                    ; E527  A2 06
L3B_E529:
    lda #$00                                    ; E529  A9 00
    sta VBlankFlag                              ; E52B  85 AC
L3B_E52D:
    lda VBlankFlag                              ; E52D  A5 AC
    beq L3B_E52D                                ; E52F  F0 FC
    sta a:PaletteDirty                          ; E531  8D D4 00
    lda ScreenMode                              ; E534  A5 B0
    cmp #$04                                    ; E536  C9 04
    bne L3B_E55F                                ; E538  D0 25
    stx ram_049D                                ; E53A  8E 9D 04
    lda #$00                                    ; E53D  A9 00
    sta OamIndex                                ; E53F  85 AD
    jsr StageSplitSetup                         ; E541  20 08 F9
    farcall FightersUpdate                      ; E544  A9 E5 48 A9 55 48 A9 3B .. -> 3F:EF74
    jsr StageParallaxCalc                       ; E556  20 40 F9
    jsr OamHideRest                             ; E559  20 DF F2
    ldx ram_049D                                ; E55C  AE 9D 04
L3B_E55F:
    ldy #$17                                    ; E55F  A0 17
L3B_E561:
    lda FadePalette,y                           ; E561  B9 85 04
    cmp D3B_E420,x                              ; E564  DD 20 E4    [idx $00..$06]
    bcc L3B_E576                                ; E567  90 0D
    cmp D3B_E41A,x                              ; E569  DD 1A E4    [idx $00..$05]
    bcs L3B_E576                                ; E56C  B0 08
    lda a:PaletteBuf,y                          ; E56E  B9 BC 00
    adc #$10                                    ; E571  69 10
    sta a:PaletteBuf,y                          ; E573  99 BC 00
L3B_E576:
    dey                                         ; E576  88
    bpl L3B_E561                                ; E577  10 E8
    dex                                         ; E579  CA
    bpl L3B_E529                                ; E57A  10 AD
    rts                                         ; E57C  60

D3B_E57D:
    .word D20_8509                              ; E57D  09 85
    .word D20_8509                              ; E57F  09 85
    .word D20_851A                              ; E581  1A 85
    .word D20_851A                              ; E583  1A 85
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; E585
D3B_E595:
    .word D20_853A                              ; E595  3A 85
    .word D20_8549                              ; E597  49 85
    .word D20_8556                              ; E599  56 85
    .word D20_8565                              ; E59B  65 85

; <- jmp L3B_E377
; modos: intro do round
L3B_E59D:
    lda FighterIsCpu                            ; E59D  A5 02
    beq L3B_E5A9                                ; E59F  F0 08
    lda #$00                                    ; E5A1  A9 00       (nt)
    sta ram_0412                                ; E5A3  8D 12 04    (nt)
    jmp L3B_E5C3                                ; E5A6  4C C3 E5    (nt)


L3B_E5A9:
    lda #$50                                    ; E5A9  A9 50
    sta ram_040D                                ; E5AB  8D 0D 04
    lda #$31                                    ; E5AE  A9 31
    sta ram_040E                                ; E5B0  8D 0E 04
    lda #$20                                    ; E5B3  A9 20
    sta ram_040F                                ; E5B5  8D 0F 04
    sta ram_0410                                ; E5B8  8D 10 04
    sta ram_0411                                ; E5BB  8D 11 04
    lda #$FF                                    ; E5BE  A9 FF
    sta ram_0412                                ; E5C0  8D 12 04

; <- jmp L3B_E59D
; modos: intro do round
L3B_E5C3:
    lda FighterIsCpu+1                          ; E5C3  A5 03
    bne L3B_E5E4                                ; E5C5  D0 1D
    lda #$20                                    ; E5C7  A9 20
    sta ram_0413                                ; E5C9  8D 13 04
    sta ram_0414                                ; E5CC  8D 14 04
    sta ram_0415                                ; E5CF  8D 15 04
    lda #$50                                    ; E5D2  A9 50
    sta ram_0416                                ; E5D4  8D 16 04
    lda #$32                                    ; E5D7  A9 32
    sta ram_0417                                ; E5D9  8D 17 04
    lda #$FF                                    ; E5DC  A9 FF
    sta ram_0418                                ; E5DE  8D 18 04
    jmp L3B_E5E9                                ; E5E1  4C E9 E5


L3B_E5E4:
    lda #$00                                    ; E5E4  A9 00
    sta ram_0418                                ; E5E6  8D 18 04

; <- jmp L3B_E5A9
; modos: intro do round
L3B_E5E9:
    lda #$08                                    ; E5E9  A9 08
    sta ram_043C                                ; E5EB  8D 3C 04
    sta ram_0454                                ; E5EE  8D 54 04
    lda #$00                                    ; E5F1  A9 00
    sta ram_043B                                ; E5F3  8D 3B 04
    ldx #$0A                                    ; E5F6  A2 0A
    stx ram_0453                                ; E5F8  8E 53 04
    lda #$70                                    ; E5FB  A9 70
L3B_E5FD:
    sta ram_0425,x                              ; E5FD  9D 25 04
    sta ram_043D,x                              ; E600  9D 3D 04
    dex                                         ; E603  CA
    bpl L3B_E5FD                                ; E604  10 F7
    ldx #$0A                                    ; E606  A2 0A
    lda #$78                                    ; E608  A9 78
L3B_E60A:
    sta ram_0430,x                              ; E60A  9D 30 04
    sta ram_0448,x                              ; E60D  9D 48 04
    dex                                         ; E610  CA
    bpl L3B_E60A                                ; E611  10 F7
    lda a:TimerOff                              ; E613  AD B5 00
    beq L3B_E62F                                ; E616  F0 17
    lda #$C4                                    ; E618  A9 C4       (nt)
    sta ram_045A                                ; E61A  8D 5A 04    (nt)
    lda #$C6                                    ; E61D  A9 C6       (nt)
    sta ram_045C                                ; E61F  8D 5C 04    (nt)
    lda #$C5                                    ; E622  A9 C5       (nt)
    sta ram_045B                                ; E624  8D 5B 04    (nt)
    lda #$C7                                    ; E627  A9 C7       (nt)
    sta ram_045D                                ; E629  8D 5D 04    (nt)
    jmp L3B_E63E                                ; E62C  4C 3E E6    (nt)


L3B_E62F:
    ldx #$C2                                    ; E62F  A2 C2
    stx ram_045A                                ; E631  8E 5A 04
    stx ram_045B                                ; E634  8E 5B 04
    inx                                         ; E637  E8
    stx ram_045C                                ; E638  8E 5C 04
    stx ram_045D                                ; E63B  8E 5D 04

; <- jmp L3B_E5E4
; modos: intro do round
L3B_E63E:
    lda #$3C                                    ; E63E  A9 3C
    ora #$80                                    ; E640  09 80
    sta MMC5_PRG_8000                           ; E642  8D 14 51
    lda FighterChar                             ; E645  A5 00
    tax                                         ; E647  AA
    ldy D3C_851E,x                              ; E648  BC 1E 85    [bancos $3C idx $00..$00]
    asl a                                       ; E64B  0A
    asl a                                       ; E64C  0A
    asl a                                       ; E64D  0A
    tax                                         ; E64E  AA
    lda #$28                                    ; E64F  A9 28
    sta PPUADDR                                 ; E651  8D 06 20
    lda #$C4                                    ; E654  A9 C4
    sta PPUADDR                                 ; E656  8D 06 20
L3B_E659:
    lda CharNameTbl,x                           ; E659  BD CE 84    [bancos $3C idx $00..$02]
    sta PPUDATA                                 ; E65C  8D 07 20
    inx                                         ; E65F  E8
    dey                                         ; E660  88
    bne L3B_E659                                ; E661  D0 F6
    lda FighterChar+1                           ; E663  A5 01
    tax                                         ; E665  AA
    ldy D3C_851E,x                              ; E666  BC 1E 85    [bancos $3C idx $00..$00]
    asl a                                       ; E669  0A
    asl a                                       ; E66A  0A
    asl a                                       ; E66B  0A
    tax                                         ; E66C  AA
    lda #$28                                    ; E66D  A9 28
    sta PPUADDR                                 ; E66F  8D 06 20
    sty zp_D5                                   ; E672  84 D5
    lda #$DC                                    ; E674  A9 DC
    sec                                         ; E676  38
    sbc zp_D5                                   ; E677  E5 D5
    sta PPUADDR                                 ; E679  8D 06 20
L3B_E67C:
    lda CharNameTbl,x                           ; E67C  BD CE 84    [bancos $3C idx $00..$02]
    sta PPUDATA                                 ; E67F  8D 07 20
    inx                                         ; E682  E8
    dey                                         ; E683  88
    bne L3B_E67C                                ; E684  D0 F6
    jmp L3B_E689                                ; E686  4C 89 E6


; <- jmp L3B_E62F, jsr StageSplitSetup
; modos: intro do round, luta, fim do round
L3B_E689:
    lda FrameCounter                            ; E689  A5 B1
    and #$1F                                    ; E68B  29 1F
    bne L3B_E6ED                                ; E68D  D0 5E
    ldx ram_0412                                ; E68F  AE 12 04
    bmi L3B_E6BE                                ; E692  30 2A
    txa                                         ; E694  8A          (nt)
    axs #$FB                                    ; E695  CB FB       (nt)
    cpx #$10                                    ; E697  E0 10       (nt)
    bcc L3B_E69D                                ; E699  90 02       (nt)
    ldx #$00                                    ; E69B  A2 00       (nt)
L3B_E69D:
    stx ram_0412                                ; E69D  8E 12 04    (nt)
    lda D3B_E808,x                              ; E6A0  BD 08 E8    (nt)
    sta ram_040D                                ; E6A3  8D 0D 04    (nt)
    lda D3B_E809,x                              ; E6A6  BD 09 E8    (nt)
    sta ram_040E                                ; E6A9  8D 0E 04    (nt)
    lda D3B_E80A,x                              ; E6AC  BD 0A E8    (nt)
    sta ram_040F                                ; E6AF  8D 0F 04    (nt)
    lda D3B_E80B,x                              ; E6B2  BD 0B E8    (nt)
    sta ram_0410                                ; E6B5  8D 10 04    (nt)
    lda D3B_E80C,x                              ; E6B8  BD 0C E8    (nt)
    sta ram_0411                                ; E6BB  8D 11 04    (nt)
L3B_E6BE:
    ldx ram_0418                                ; E6BE  AE 18 04
    bmi L3B_E6ED                                ; E6C1  30 2A
    txa                                         ; E6C3  8A
    axs #$FB                                    ; E6C4  CB FB
    cpx #$10                                    ; E6C6  E0 10
    bcc L3B_E6CC                                ; E6C8  90 02
    ldx #$00                                    ; E6CA  A2 00
L3B_E6CC:
    stx ram_0418                                ; E6CC  8E 18 04
    lda D3B_E808,x                              ; E6CF  BD 08 E8    [idx $00..$0F]
    sta ram_0413                                ; E6D2  8D 13 04
    lda D3B_E809,x                              ; E6D5  BD 09 E8    [idx $00..$0F]
    sta ram_0414                                ; E6D8  8D 14 04
    lda D3B_E80A,x                              ; E6DB  BD 0A E8    [idx $00..$0F]
    sta ram_0415                                ; E6DE  8D 15 04
    lda D3B_E80B,x                              ; E6E1  BD 0B E8    [idx $00..$0F]
    sta ram_0416                                ; E6E4  8D 16 04
    lda D3B_E80C,x                              ; E6E7  BD 0C E8    [idx $00..$0F]
    sta ram_0417                                ; E6EA  8D 17 04
L3B_E6ED:
    lda ScreenMode                              ; E6ED  A5 B0
    cmp #$05                                    ; E6EF  C9 05
    beq L3B_E741                                ; E6F1  F0 4E
    lda FighterWins                             ; E6F3  A5 10
    asl a                                       ; E6F5  0A
    adc FighterWins                             ; E6F6  65 10
    tax                                         ; E6F8  AA
    lda D3B_E81C,x                              ; E6F9  BD 1C E8    [idx $00..$06]
    sta ram_0419                                ; E6FC  8D 19 04
    adc #$10                                    ; E6FF  69 10
    sta ram_041C                                ; E701  8D 1C 04
    lda D3B_E81D,x                              ; E704  BD 1D E8    [idx $00..$06]
    sta ram_041A                                ; E707  8D 1A 04
    adc #$10                                    ; E70A  69 10
    sta ram_041D                                ; E70C  8D 1D 04
    lda D3B_E81E,x                              ; E70F  BD 1E E8    [idx $00..$06]
    sta ram_041B                                ; E712  8D 1B 04
    adc #$10                                    ; E715  69 10
    sta ram_041E                                ; E717  8D 1E 04
    lda FighterWins+1                           ; E71A  A5 11
    asl a                                       ; E71C  0A
    adc FighterWins+1                           ; E71D  65 11
    tax                                         ; E71F  AA
    lda D3B_E825,x                              ; E720  BD 25 E8    [idx $00..$06]
    sta ram_041F                                ; E723  8D 1F 04
    adc #$10                                    ; E726  69 10
    sta ram_0422                                ; E728  8D 22 04
    lda D3B_E826,x                              ; E72B  BD 26 E8    [idx $00..$06]
    sta ram_0420                                ; E72E  8D 20 04
    adc #$10                                    ; E731  69 10
    sta ram_0423                                ; E733  8D 23 04
    lda D3B_E827,x                              ; E736  BD 27 E8    [idx $00..$06]
    sta ram_0421                                ; E739  8D 21 04
    adc #$10                                    ; E73C  69 10
    sta ram_0424                                ; E73E  8D 24 04
L3B_E741:
    lda FrameCounter                            ; E741  A5 B1
    and #$01                                    ; E743  29 01
    tax                                         ; E745  AA
    lda a:zp_16,x                               ; E746  BD 16 00
    cmp #$0C                                    ; E749  C9 0C
    beq L3B_E7A5                                ; E74B  F0 58
    ldy a:FighterDmgPending,x                   ; E74D  BC 14 00
    beq L3B_E7A5                                ; E750  F0 53
    dey                                         ; E752  88
    sty FighterDmgPending,x                     ; E753  94 14
    ldy FighterHP,x                             ; E755  B4 0E
    bmi L3B_E7A5                                ; E757  30 4C
    dey                                         ; E759  88
    sty FighterHP,x                             ; E75A  94 0E
    cpx #$00                                    ; E75C  E0 00
    bne L3B_E785                                ; E75E  D0 25
    ldy ram_043B                                ; E760  AC 3B 04
    ldx ram_043C                                ; E763  AE 3C 04
    dex                                         ; E766  CA
    bpl L3B_E773                                ; E767  10 0A
    iny                                         ; E769  C8
    cpy #$0B                                    ; E76A  C0 0B
    bcs L3B_E7A5                                ; E76C  B0 37
    sty ram_043B                                ; E76E  8C 3B 04
    ldx #$07                                    ; E771  A2 07
L3B_E773:
    stx ram_043C                                ; E773  8E 3C 04
    lda D3B_E82E,x                              ; E776  BD 2E E8    [idx $00..$07]
    sta ram_0425,y                              ; E779  99 25 04
    clc                                         ; E77C  18
    adc #$08                                    ; E77D  69 08
    sta ram_0430,y                              ; E77F  99 30 04
    jmp L3B_E7A5                                ; E782  4C A5 E7


L3B_E785:
    ldy ram_0453                                ; E785  AC 53 04
    ldx ram_0454                                ; E788  AE 54 04
    dex                                         ; E78B  CA
    bpl L3B_E796                                ; E78C  10 08
    dey                                         ; E78E  88
    bmi L3B_E7A5                                ; E78F  30 14
    sty ram_0453                                ; E791  8C 53 04
    ldx #$07                                    ; E794  A2 07
L3B_E796:
    stx ram_0454                                ; E796  8E 54 04
    lda D3B_E837,x                              ; E799  BD 37 E8    [idx $00..$07]
    sta ram_043D,y                              ; E79C  99 3D 04
    clc                                         ; E79F  18
    adc #$08                                    ; E7A0  69 08
    sta ram_0448,y                              ; E7A2  99 48 04

; <- jmp L3B_E689
; modos: intro do round, luta, fim do round
L3B_E7A5:
    lda FrameCounter                            ; E7A5  A5 B1
    and #$07                                    ; E7A7  29 07
    bne L3B_E7E0                                ; E7A9  D0 35
    lda ScreenMode                              ; E7AB  A5 B0
    cmp #$05                                    ; E7AD  C9 05
    bne L3B_E7C4                                ; E7AF  D0 13
    lda #$2C                                    ; E7B1  A9 2C
    cmp FighterHP                               ; E7B3  C5 0E
    bcs L3B_E7BB                                ; E7B5  B0 04
    cmp FighterHP+1                             ; E7B7  C5 0F
    bcc L3B_E7E0                                ; E7B9  90 25
L3B_E7BB:
    lda ram_0459                                ; E7BB  AD 59 04
    eor #$01                                    ; E7BE  49 01
    tax                                         ; E7C0  AA
    jmp L3B_E7C6                                ; E7C1  4C C6 E7


L3B_E7C4:
    ldx #$00                                    ; E7C4  A2 00

; <- jmp L3B_E785
; modos: intro do round, luta, fim do round
L3B_E7C6:
    stx ram_0459                                ; E7C6  8E 59 04
    lda D3B_E840,x                              ; E7C9  BD 40 E8    [idx $00..$01]
    sta ram_0455                                ; E7CC  8D 55 04
    clc                                         ; E7CF  18
    adc #$10                                    ; E7D0  69 10
    sta ram_0457                                ; E7D2  8D 57 04
    lda D3B_E842,x                              ; E7D5  BD 42 E8    [idx $00..$01]
    sta ram_0456                                ; E7D8  8D 56 04
    adc #$10                                    ; E7DB  69 10
    sta ram_0458                                ; E7DD  8D 58 04
L3B_E7E0:
    lda FrameCounter                            ; E7E0  A5 B1
    and #$1F                                    ; E7E2  29 1F
    bne L3B_E807                                ; E7E4  D0 21
    lda a:TimerOff                              ; E7E6  AD B5 00
    bne L3B_E807                                ; E7E9  D0 1C
    lda a:TimerTens                             ; E7EB  AD BB 00
    asl a                                       ; E7EE  0A
    adc #$B0                                    ; E7EF  69 B0
    sta ram_045A                                ; E7F1  8D 5A 04
    adc #$01                                    ; E7F4  69 01
    sta ram_045C                                ; E7F6  8D 5C 04
    lda a:TimerOnes                             ; E7F9  AD BA 00
    asl a                                       ; E7FC  0A
    adc #$B0                                    ; E7FD  69 B0
    sta ram_045B                                ; E7FF  8D 5B 04
    adc #$01                                    ; E802  69 01
    sta ram_045D                                ; E804  8D 5D 04
L3B_E807:
    rts                                         ; E807  60

D3B_E808:
    .byte $20                                   ; E808
D3B_E809:
    .byte $20                                   ; E809
D3B_E80A:
    .byte $20                                   ; E80A
D3B_E80B:
    .byte $20                                   ; E80B
D3B_E80C:
    .byte $20,$50,$52,$45,$53,$53,$20,$20,$20,$20,$20,$53,$54,$41,$52,$54; E80C
D3B_E81C:
    .byte $00                                   ; E81C
D3B_E81D:
    .byte $00                                   ; E81D
D3B_E81E:
    .byte $02,$03,$01,$02,$03,$04,$05           ; E81E
D3B_E825:
    .byte $09                                   ; E825
D3B_E826:
    .byte $00                                   ; E826
D3B_E827:
    .byte $00,$09,$0A,$08,$06,$07,$08           ; E827
D3B_E82E:
    .byte $60,$61,$62,$63,$64,$65,$66,$67,$70   ; E82E
D3B_E837:
    .byte $60,$71,$72,$73,$74,$75,$76,$77,$70   ; E837
D3B_E840:
    .byte $0C,$0E                               ; E840
D3B_E842:
    .byte $0D,$0F                               ; E842

; <- jmp K_FEC2
; modos: intro do round, luta, fim do round
NmiFightVram:
    lda FrameCounter                            ; E844  A5 B1
    and #$1F                                    ; E846  29 1F
    bne L3B_E8C6                                ; E848  D0 7C
    lda #$28                                    ; E84A  A9 28
    sta PPUADDR                                 ; E84C  8D 06 20
    lda #$CF                                    ; E84F  A9 CF
    sta PPUADDR                                 ; E851  8D 06 20
    lda ram_045A                                ; E854  AD 5A 04
    sta PPUDATA                                 ; E857  8D 07 20
    lda ram_045B                                ; E85A  AD 5B 04
    sta PPUDATA                                 ; E85D  8D 07 20
    lda #$28                                    ; E860  A9 28
    sta PPUADDR                                 ; E862  8D 06 20
    lda #$EF                                    ; E865  A9 EF
    sta PPUADDR                                 ; E867  8D 06 20
    lda ram_045C                                ; E86A  AD 5C 04
    sta PPUDATA                                 ; E86D  8D 07 20
    lda ram_045D                                ; E870  AD 5D 04
    sta PPUDATA                                 ; E873  8D 07 20
    lda #$28                                    ; E876  A9 28
    sta PPUADDR                                 ; E878  8D 06 20
    lda #$61                                    ; E87B  A9 61
    sta PPUADDR                                 ; E87D  8D 06 20
    lda ram_040D                                ; E880  AD 0D 04
    sta PPUDATA                                 ; E883  8D 07 20
    lda ram_040E                                ; E886  AD 0E 04
    sta PPUDATA                                 ; E889  8D 07 20
    lda ram_040F                                ; E88C  AD 0F 04
    sta PPUDATA                                 ; E88F  8D 07 20
    lda ram_0410                                ; E892  AD 10 04
    sta PPUDATA                                 ; E895  8D 07 20
    lda ram_0411                                ; E898  AD 11 04
    sta PPUDATA                                 ; E89B  8D 07 20
    lda #$28                                    ; E89E  A9 28
    sta PPUADDR                                 ; E8A0  8D 06 20
    lda #$7A                                    ; E8A3  A9 7A
    sta PPUADDR                                 ; E8A5  8D 06 20
    lda ram_0413                                ; E8A8  AD 13 04
    sta PPUDATA                                 ; E8AB  8D 07 20
    lda ram_0414                                ; E8AE  AD 14 04
    sta PPUDATA                                 ; E8B1  8D 07 20
    lda ram_0415                                ; E8B4  AD 15 04
    sta PPUDATA                                 ; E8B7  8D 07 20
    lda ram_0416                                ; E8BA  AD 16 04
    sta PPUDATA                                 ; E8BD  8D 07 20
    lda ram_0417                                ; E8C0  AD 17 04
    sta PPUDATA                                 ; E8C3  8D 07 20
L3B_E8C6:
    lda FrameCounter                            ; E8C6  A5 B1
    and #$01                                    ; E8C8  29 01
    beq L3B_E8CF                                ; E8CA  F0 03
    jmp L3B_E98C                                ; E8CC  4C 8C E9


L3B_E8CF:
    lda #$28                                    ; E8CF  A9 28
    sta PPUADDR                                 ; E8D1  8D 06 20
    lda #$81                                    ; E8D4  A9 81
    sta PPUADDR                                 ; E8D6  8D 06 20
    lda ram_0419                                ; E8D9  AD 19 04
    sta PPUDATA                                 ; E8DC  8D 07 20
    lda ram_041A                                ; E8DF  AD 1A 04
    sta PPUDATA                                 ; E8E2  8D 07 20
    lda ram_041B                                ; E8E5  AD 1B 04
    sta PPUDATA                                 ; E8E8  8D 07 20
    lda ram_0425                                ; E8EB  AD 25 04
    sta PPUDATA                                 ; E8EE  8D 07 20
    lda ram_0426                                ; E8F1  AD 26 04
    sta PPUDATA                                 ; E8F4  8D 07 20
    lda ram_0427                                ; E8F7  AD 27 04
    sta PPUDATA                                 ; E8FA  8D 07 20
    lda ram_0428                                ; E8FD  AD 28 04
    sta PPUDATA                                 ; E900  8D 07 20
    lda ram_0429                                ; E903  AD 29 04
    sta PPUDATA                                 ; E906  8D 07 20
    lda ram_042A                                ; E909  AD 2A 04
    sta PPUDATA                                 ; E90C  8D 07 20
    lda ram_042B                                ; E90F  AD 2B 04
    sta PPUDATA                                 ; E912  8D 07 20
    lda ram_042C                                ; E915  AD 2C 04
    sta PPUDATA                                 ; E918  8D 07 20
    lda ram_042D                                ; E91B  AD 2D 04
    sta PPUDATA                                 ; E91E  8D 07 20
    lda ram_042E                                ; E921  AD 2E 04
    sta PPUDATA                                 ; E924  8D 07 20
    lda ram_042F                                ; E927  AD 2F 04
    sta PPUDATA                                 ; E92A  8D 07 20
    lda #$28                                    ; E92D  A9 28
    sta PPUADDR                                 ; E92F  8D 06 20
    lda #$A1                                    ; E932  A9 A1
    sta PPUADDR                                 ; E934  8D 06 20
    lda ram_041C                                ; E937  AD 1C 04
    sta PPUDATA                                 ; E93A  8D 07 20
    lda ram_041D                                ; E93D  AD 1D 04
    sta PPUDATA                                 ; E940  8D 07 20
    lda ram_041E                                ; E943  AD 1E 04
    sta PPUDATA                                 ; E946  8D 07 20
    lda ram_0430                                ; E949  AD 30 04
    sta PPUDATA                                 ; E94C  8D 07 20
    lda ram_0431                                ; E94F  AD 31 04
    sta PPUDATA                                 ; E952  8D 07 20
    lda ram_0432                                ; E955  AD 32 04
    sta PPUDATA                                 ; E958  8D 07 20
    lda ram_0433                                ; E95B  AD 33 04
    sta PPUDATA                                 ; E95E  8D 07 20
    lda ram_0434                                ; E961  AD 34 04
    sta PPUDATA                                 ; E964  8D 07 20
    lda ram_0435                                ; E967  AD 35 04
    sta PPUDATA                                 ; E96A  8D 07 20
    lda ram_0436                                ; E96D  AD 36 04
    sta PPUDATA                                 ; E970  8D 07 20
    lda ram_0437                                ; E973  AD 37 04
    sta PPUDATA                                 ; E976  8D 07 20
    lda ram_0438                                ; E979  AD 38 04
    sta PPUDATA                                 ; E97C  8D 07 20
    lda ram_0439                                ; E97F  AD 39 04
    sta PPUDATA                                 ; E982  8D 07 20
    lda ram_043A                                ; E985  AD 3A 04
    sta PPUDATA                                 ; E988  8D 07 20
    rts                                         ; E98B  60


; <- jmp NmiFightVram
; modos: intro do round, luta, fim do round
L3B_E98C:
    lda #$28                                    ; E98C  A9 28
    sta PPUADDR                                 ; E98E  8D 06 20
    lda #$8F                                    ; E991  A9 8F
    sta PPUADDR                                 ; E993  8D 06 20
    lda ram_0455                                ; E996  AD 55 04
    sta PPUDATA                                 ; E999  8D 07 20
    lda ram_0456                                ; E99C  AD 56 04
    sta PPUDATA                                 ; E99F  8D 07 20
    lda ram_043D                                ; E9A2  AD 3D 04
    sta PPUDATA                                 ; E9A5  8D 07 20
    lda ram_043E                                ; E9A8  AD 3E 04
    sta PPUDATA                                 ; E9AB  8D 07 20
    lda ram_043F                                ; E9AE  AD 3F 04
    sta PPUDATA                                 ; E9B1  8D 07 20
    lda ram_0440                                ; E9B4  AD 40 04
    sta PPUDATA                                 ; E9B7  8D 07 20
    lda ram_0441                                ; E9BA  AD 41 04
    sta PPUDATA                                 ; E9BD  8D 07 20
    lda ram_0442                                ; E9C0  AD 42 04
    sta PPUDATA                                 ; E9C3  8D 07 20
    lda ram_0443                                ; E9C6  AD 43 04
    sta PPUDATA                                 ; E9C9  8D 07 20
    lda ram_0444                                ; E9CC  AD 44 04
    sta PPUDATA                                 ; E9CF  8D 07 20
    lda ram_0445                                ; E9D2  AD 45 04
    sta PPUDATA                                 ; E9D5  8D 07 20
    lda ram_0446                                ; E9D8  AD 46 04
    sta PPUDATA                                 ; E9DB  8D 07 20
    lda ram_0447                                ; E9DE  AD 47 04
    sta PPUDATA                                 ; E9E1  8D 07 20
    lda ram_041F                                ; E9E4  AD 1F 04
    sta PPUDATA                                 ; E9E7  8D 07 20
    lda ram_0420                                ; E9EA  AD 20 04
    sta PPUDATA                                 ; E9ED  8D 07 20
    lda ram_0421                                ; E9F0  AD 21 04
    sta PPUDATA                                 ; E9F3  8D 07 20
    lda #$28                                    ; E9F6  A9 28
    sta PPUADDR                                 ; E9F8  8D 06 20
    lda #$AF                                    ; E9FB  A9 AF
    sta PPUADDR                                 ; E9FD  8D 06 20
    lda ram_0457                                ; EA00  AD 57 04
    sta PPUDATA                                 ; EA03  8D 07 20
    lda ram_0458                                ; EA06  AD 58 04
    sta PPUDATA                                 ; EA09  8D 07 20
    lda ram_0448                                ; EA0C  AD 48 04
    sta PPUDATA                                 ; EA0F  8D 07 20
    lda ram_0449                                ; EA12  AD 49 04
    sta PPUDATA                                 ; EA15  8D 07 20
    lda ram_044A                                ; EA18  AD 4A 04
    sta PPUDATA                                 ; EA1B  8D 07 20
    lda ram_044B                                ; EA1E  AD 4B 04
    sta PPUDATA                                 ; EA21  8D 07 20
    lda ram_044C                                ; EA24  AD 4C 04
    sta PPUDATA                                 ; EA27  8D 07 20
    lda ram_044D                                ; EA2A  AD 4D 04
    sta PPUDATA                                 ; EA2D  8D 07 20
    lda ram_044E                                ; EA30  AD 4E 04
    sta PPUDATA                                 ; EA33  8D 07 20
    lda ram_044F                                ; EA36  AD 4F 04
    sta PPUDATA                                 ; EA39  8D 07 20
    lda ram_0450                                ; EA3C  AD 50 04
    sta PPUDATA                                 ; EA3F  8D 07 20
    lda ram_0451                                ; EA42  AD 51 04
    sta PPUDATA                                 ; EA45  8D 07 20
    lda ram_0452                                ; EA48  AD 52 04
    sta PPUDATA                                 ; EA4B  8D 07 20
    lda ram_0422                                ; EA4E  AD 22 04
    sta PPUDATA                                 ; EA51  8D 07 20
    lda ram_0423                                ; EA54  AD 23 04
    sta PPUDATA                                 ; EA57  8D 07 20
    lda ram_0424                                ; EA5A  AD 24 04
    sta PPUDATA                                 ; EA5D  8D 07 20
    rts                                         ; EA60  60


; <- farcall Main
; modos: selecao
ScreenVersus:
    lda #$03                                    ; EA61  A9 03
    sta ScreenMode                              ; EA63  85 B0
    ldx zp_B2                                   ; EA65  A6 B2
    inx                                         ; EA67  E8
    cpx #$0A                                    ; EA68  E0 0A
    bcc L3B_EA77                                ; EA6A  90 0B
    ldx zp_B3                                   ; EA6C  A6 B3       (nt)
    cpx #$09                                    ; EA6E  E0 09       (nt)
    bcs L3B_EA77                                ; EA70  B0 05       (nt)
    inx                                         ; EA72  E8          (nt)
    stx zp_B3                                   ; EA73  86 B3       (nt)
    ldx #$00                                    ; EA75  A2 00       (nt)
L3B_EA77:
    stx zp_B2                                   ; EA77  86 B2
    ldx #$00                                    ; EA79  A2 00
    stx CurFighter                              ; EA7B  86 64
    jsr FighterLoadChar                         ; EA7D  20 00 E0
    ldx #$01                                    ; EA80  A2 01
    stx OtherFighter                            ; EA82  86 65
    jsr FighterLoadChar                         ; EA84  20 00 E0
    jsr L3B_EAF2                                ; EA87  20 F2 EA
    jsr L3B_E28A                                ; EA8A  20 8A E2
    rts                                         ; EA8D  60

D3B_EA8E:
    .byte $16,$27,$37                           ; EA8E
D3B_EA91:
    .byte $16                                   ; EA91
D3B_EA92:
    .byte $27                                   ; EA92
D3B_EA93:
    .byte $01                                   ; EA93
D3B_EA94:
    .byte $30,$00,$30,$FE,$00,$30,$FE,$00,$30,$4E,$01,$02,$03,$04,$05,$06; EA94
    .byte $07,$00,$30,$17,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$00,$30,$17,$10; EAA4
    .byte $11,$12,$13,$14,$15,$16,$17,$00,$30,$17,$18,$19,$1A,$1B,$1C,$1D; EAB4
    .byte $1E,$1F,$00,$30,$17,$20,$21,$22,$23,$24,$25,$26,$27,$00,$30,$17; EAC4
    .byte $28,$29,$2A,$2B,$2C,$2D,$2E,$2F,$00,$30,$CB,$FF,$30,$22,$AA,$AA; EAD4
    .byte $FF,$30,$05,$FA,$FA,$FF,$30,$0A,$0F,$30,$06,$0F,$30,$00; EAE4

; <- jsr ScreenVersus
; modos: VS
L3B_EAF2:
    lda #$28                                    ; EAF2  A9 28
    sta PPUADDR                                 ; EAF4  8D 06 20
    lda #$00                                    ; EAF7  A9 00
    sta PPUADDR                                 ; EAF9  8D 06 20
    lda #<D3B_EA94                              ; EAFC  A9 94
    ldx #>D3B_EA94                              ; EAFE  A2 EA
    jsr PpuUnRle                                ; EB00  20 BE E3
    jsr L3B_EBF2                                ; EB03  20 F2 EB
    ldx #$05                                    ; EB06  A2 05
L3B_EB08:
    lda D3B_EA8E,x                              ; EB08  BD 8E EA    [idx $00..$05]
    sta a:PaletteBuf+6,x                        ; EB0B  9D C2 00
    dex                                         ; EB0E  CA
    bpl L3B_EB08                                ; EB0F  10 F7
    lda #$00                                    ; EB11  A9 00
    sta zp_D5                                   ; EB13  85 D5
    jsr L3B_EFD3                                ; EB15  20 D3 EF
    lda #$2A                                    ; EB18  A9 2A
    sta PPUADDR                                 ; EB1A  8D 06 20
    lda #$64                                    ; EB1D  A9 64
    sta PPUADDR                                 ; EB1F  8D 06 20
    ldx #$00                                    ; EB22  A2 00
L3B_EB24:
    lda ram_0392,x                              ; EB24  BD 92 03
    sta PPUDATA                                 ; EB27  8D 07 20
    inx                                         ; EB2A  E8
    cpx #$07                                    ; EB2B  E0 07
    bcc L3B_EB24                                ; EB2D  90 F5
    lda #$2A                                    ; EB2F  A9 2A
    sta PPUADDR                                 ; EB31  8D 06 20
    lda #$84                                    ; EB34  A9 84
    sta PPUADDR                                 ; EB36  8D 06 20
    ldx #$00                                    ; EB39  A2 00
L3B_EB3B:
    lda ram_0399,x                              ; EB3B  BD 99 03
    sta PPUDATA                                 ; EB3E  8D 07 20
    inx                                         ; EB41  E8
    cpx #$07                                    ; EB42  E0 07
    bcc L3B_EB3B                                ; EB44  90 F5
    lda #$01                                    ; EB46  A9 01
    sta zp_D5                                   ; EB48  85 D5
    jsr L3B_EFD3                                ; EB4A  20 D3 EF
    lda #$2A                                    ; EB4D  A9 2A
    sta PPUADDR                                 ; EB4F  8D 06 20
    lda #$75                                    ; EB52  A9 75
    sta PPUADDR                                 ; EB54  8D 06 20
    ldx #$00                                    ; EB57  A2 00
L3B_EB59:
    lda ram_03A0,x                              ; EB59  BD A0 03
    sta PPUDATA                                 ; EB5C  8D 07 20
    inx                                         ; EB5F  E8
    cpx #$07                                    ; EB60  E0 07
    bcc L3B_EB59                                ; EB62  90 F5
    lda #$2A                                    ; EB64  A9 2A
    sta PPUADDR                                 ; EB66  8D 06 20
    lda #$95                                    ; EB69  A9 95
    sta PPUADDR                                 ; EB6B  8D 06 20
    ldx #$00                                    ; EB6E  A2 00
L3B_EB70:
    lda ram_03A7,x                              ; EB70  BD A7 03
    sta PPUDATA                                 ; EB73  8D 07 20
    inx                                         ; EB76  E8
    cpx #$07                                    ; EB77  E0 07
    bcc L3B_EB70                                ; EB79  90 F5
    lda #$00                                    ; EB7B  A9 00
    sta ram_03AF                                ; EB7D  8D AF 03
    sta ram_03B0                                ; EB80  8D B0 03
    sta ram_03B1                                ; EB83  8D B1 03
    sta ram_03B2                                ; EB86  8D B2 03
    sta ram_03B3                                ; EB89  8D B3 03
    sta ram_03B4                                ; EB8C  8D B4 03
    jsr FadeIn                                  ; EB8F  20 D6 E4
    lda #$29                                    ; EB92  A9 29
    sta MusicBank                               ; EB94  8D 5F 04
    lda #<D29_B34A                              ; EB97  A9 4A
    sta zp_D5                                   ; EB99  85 D5
    lda #>D29_B34A                              ; EB9B  A9 B3
    sta zp_D6                                   ; EB9D  85 D6
    farcall SoundLoadSong                       ; EB9F  A9 EB 48 A9 B0 48 A9 3B .. -> 37:E3E0
    lda #$00                                    ; EBB1  A9 00
    sta FrameCounter                            ; EBB3  85 B1
    ldx #$03                                    ; EBB5  A2 03
    stx zp_E9                                   ; EBB7  86 E9
L3B_EBB9:
    lda #$00                                    ; EBB9  A9 00
    sta VBlankFlag                              ; EBBB  85 AC
L3B_EBBD:
    lda VBlankFlag                              ; EBBD  A5 AC
    beq L3B_EBBD                                ; EBBF  F0 FC
    farcall SoundUpdate                         ; EBC1  A9 EB 48 A9 D2 48 A9 3B .. -> 37:E45F
    lda FrameCounter                            ; EBD3  A5 B1
    and #$3F                                    ; EBD5  29 3F
    bne L3B_EBB9                                ; EBD7  D0 E0
    dec zp_E9                                   ; EBD9  C6 E9
    bne L3B_EBB9                                ; EBDB  D0 DC
    farcall SoundStopMusic                      ; EBDD  A9 EB 48 A9 EE 48 A9 3B .. -> 37:E479
    jmp FadeOut                                 ; EBEF  4C 26 E4


; <- jsr L3B_EAF2, jsr ScreenWinQuote
; modos: VS, frase final
L3B_EBF2:
    lda #$04                                    ; EBF2  A9 04
    sta zp_D5                                   ; EBF4  85 D5
    lda #$29                                    ; EBF6  A9 29
    sta zp_D6                                   ; EBF8  85 D6
    lda #$D1                                    ; EBFA  A9 D1
    sta zp_D9                                   ; EBFC  85 D9
    lda #$2B                                    ; EBFE  A9 2B
    sta zp_DA                                   ; EC00  85 DA
    jsr L3B_EE38                                ; EC02  20 38 EE
    lda #$0D                                    ; EC05  A9 0D
    sta MMC5_CHR_BG1                            ; EC07  8D 29 51
    lda ram_0390                                ; EC0A  AD 90 03
    sta MMC5_CHR_BG3                            ; EC0D  8D 2B 51
    lda #$E0                                    ; EC10  A9 E0
    sta zp_D5                                   ; EC12  85 D5
    lda #$90                                    ; EC14  A9 90
    sta zp_D6                                   ; EC16  85 D6
    jmp L3B_EF24                                ; EC18  4C 24 EF


; <- farcall Main
; modos: fim do round
ScreenWinQuote:
    lda #$07                                    ; EC1B  A9 07
    sta ScreenMode                              ; EC1D  85 B0
    lda #$28                                    ; EC1F  A9 28
    sta PPUADDR                                 ; EC21  8D 06 20
    lda #$00                                    ; EC24  A9 00
    sta PPUADDR                                 ; EC26  8D 06 20
    lda #$00                                    ; EC29  A9 00
    ldx #$20                                    ; EC2B  A2 20
L3B_EC2D:
    ldy #$1E                                    ; EC2D  A0 1E
L3B_EC2F:
    sta PPUDATA                                 ; EC2F  8D 07 20
    dey                                         ; EC32  88
    bne L3B_EC2F                                ; EC33  D0 FA
    dex                                         ; EC35  CA
    bne L3B_EC2D                                ; EC36  D0 F5
    lda #$FF                                    ; EC38  A9 FF
    ldx #$40                                    ; EC3A  A2 40
L3B_EC3C:
    sta PPUDATA                                 ; EC3C  8D 07 20
    dex                                         ; EC3F  CA
    bne L3B_EC3C                                ; EC40  D0 FA
    jsr L3B_EBF2                                ; EC42  20 F2 EB
    lda D3B_EA91                                ; EC45  AD 91 EA
    sta a:PaletteBuf+9                          ; EC48  8D C5 00
    lda D3B_EA92                                ; EC4B  AD 92 EA
    sta a:PaletteBuf+10                         ; EC4E  8D C6 00
    lda D3B_EA93                                ; EC51  AD 93 EA
    sta a:PaletteBuf+11                         ; EC54  8D C7 00
    jsr FadeIn                                  ; EC57  20 D6 E4
    lda #$29                                    ; EC5A  A9 29
    sta MusicBank                               ; EC5C  8D 5F 04
    lda #<D29_B4BD                              ; EC5F  A9 BD
    sta zp_D5                                   ; EC61  85 D5
    lda #>D29_B4BD                              ; EC63  A9 B4
    sta zp_D6                                   ; EC65  85 D6
    farcall SoundLoadSong                       ; EC67  A9 EC 48 A9 78 48 A9 3B .. -> 37:E3E0
    ldx a:RoundResult                           ; EC79  AE B9 00
    cpx #$02                                    ; EC7C  E0 02
    bne L3B_EC83                                ; EC7E  D0 03
    jmp L3B_ECE1                                ; EC80  4C E1 EC


L3B_EC83:
    lda #$3C                                    ; EC83  A9 3C
    ora #$80                                    ; EC85  09 80
    sta MMC5_PRG_8000                           ; EC87  8D 14 51
    lda FighterChar,x                           ; EC8A  B5 00
    asl a                                       ; EC8C  0A
    pha                                         ; EC8D  48
    adc FighterChar,x                           ; EC8E  75 00
    asl a                                       ; EC90  0A
    sta zp_D5                                   ; EC91  85 D5
    pla                                         ; EC93  68
    asl a                                       ; EC94  0A
    asl a                                       ; EC95  0A
    asl a                                       ; EC96  0A
    adc zp_D5                                   ; EC97  65 D5
    sta zp_D5                                   ; EC99  85 D5
    clc                                         ; EC9B  18
    adc #<WinQuoteLine1                         ; EC9C  69 28
    sta zp_D6                                   ; EC9E  85 D6
    lda #$00                                    ; ECA0  A9 00
    adc #>WinQuoteLine1                         ; ECA2  69 85
    sta zp_D7                                   ; ECA4  85 D7
    lda #$84                                    ; ECA6  A9 84
    sta ram_03AF                                ; ECA8  8D AF 03
    lda #$2A                                    ; ECAB  A9 2A
    sta ram_03B0                                ; ECAD  8D B0 03
    lda #$A4                                    ; ECB0  A9 A4
    sta ram_03B1                                ; ECB2  8D B1 03
    lda #$2A                                    ; ECB5  A9 2A
    sta ram_03B2                                ; ECB7  8D B2 03
    jsr L3B_ED24                                ; ECBA  20 24 ED
    clc                                         ; ECBD  18
    lda zp_D5                                   ; ECBE  A5 D5
    adc #<WinQuoteLine2                         ; ECC0  69 04
    sta zp_D6                                   ; ECC2  85 D6
    lda #$00                                    ; ECC4  A9 00
    adc #>WinQuoteLine2                         ; ECC6  69 86
    sta zp_D7                                   ; ECC8  85 D7
    lda #$C4                                    ; ECCA  A9 C4
    sta ram_03AF                                ; ECCC  8D AF 03
    lda #$2A                                    ; ECCF  A9 2A
    sta ram_03B0                                ; ECD1  8D B0 03
    lda #$E4                                    ; ECD4  A9 E4
    sta ram_03B1                                ; ECD6  8D B1 03
    lda #$2A                                    ; ECD9  A9 2A
    sta ram_03B2                                ; ECDB  8D B2 03
    jsr L3B_ED24                                ; ECDE  20 24 ED

; <- jmp ScreenWinQuote
; modos: frase final
L3B_ECE1:
    ldx #$02                                    ; ECE1  A2 02
    cpx a:RoundResult                           ; ECE3  EC B9 00
    beq L3B_ECE9                                ; ECE6  F0 01
    inx                                         ; ECE8  E8
L3B_ECE9:
    stx zp_E9                                   ; ECE9  86 E9
L3B_ECEB:
    lda #$00                                    ; ECEB  A9 00
    sta VBlankFlag                              ; ECED  85 AC
L3B_ECEF:
    lda VBlankFlag                              ; ECEF  A5 AC
    beq L3B_ECEF                                ; ECF1  F0 FC
    farcall SoundUpdate                         ; ECF3  A9 ED 48 A9 04 48 A9 3B .. -> 37:E45F
    lda FrameCounter                            ; ED05  A5 B1
    and #$3F                                    ; ED07  29 3F
    bne L3B_ECEB                                ; ED09  D0 E0
    dec zp_E9                                   ; ED0B  C6 E9
    bne L3B_ECEB                                ; ED0D  D0 DC
    farcall SoundStopMusic                      ; ED0F  A9 ED 48 A9 20 48 A9 3B .. -> 37:E479
    jmp FadeOut                                 ; ED21  4C 26 E4


; <- jsr L3B_EC83
; modos: frase final
L3B_ED24:
    ldy #$00                                    ; ED24  A0 00
L3B_ED26:
    sty zp_D8                                   ; ED26  84 D8
    lda #$00                                    ; ED28  A9 00
    sta VBlankFlag                              ; ED2A  85 AC
L3B_ED2C:
    lda VBlankFlag                              ; ED2C  A5 AC
    beq L3B_ED2C                                ; ED2E  F0 FC
    farcall SoundUpdate                         ; ED30  A9 ED 48 A9 41 48 A9 3B .. -> 37:E45F
    lda #$00                                    ; ED42  A9 00
    sta VBlankFlag                              ; ED44  85 AC
L3B_ED46:
    lda VBlankFlag                              ; ED46  A5 AC
    beq L3B_ED46                                ; ED48  F0 FC
    farcall SoundUpdate                         ; ED4A  A9 ED 48 A9 5B 48 A9 3B .. -> 37:E45F
    ldy zp_D8                                   ; ED5C  A4 D8
    lda (zp_D6),y                               ; ED5E  B1 D6       [le bancos $3C]
    asl a                                       ; ED60  0A
    sec                                         ; ED61  38
    sbc #$3A                                    ; ED62  E9 3A
    cmp #$30                                    ; ED64  C9 30
    bcs L3B_ED6A                                ; ED66  B0 02
    lda #$00                                    ; ED68  A9 00
L3B_ED6A:
    sta ram_03B3                                ; ED6A  8D B3 03
    beq L3B_ED72                                ; ED6D  F0 03
    clc                                         ; ED6F  18
    adc #$01                                    ; ED70  69 01
L3B_ED72:
    sta ram_03B4                                ; ED72  8D B4 03
    inc ram_03AF                                ; ED75  EE AF 03
    inc ram_03B1                                ; ED78  EE B1 03
    iny                                         ; ED7B  C8
    cpy #$16                                    ; ED7C  C0 16
    bcc L3B_ED26                                ; ED7E  90 A6
    rts                                         ; ED80  60


; <- farjmp FightersUpdate
; modos: intro do round, luta, fim do round
DrawFighters:
    ldx OtherFighter                            ; ED81  A6 65
    jsr L3B_F27A                                ; ED83  20 7A F2
    lda #$E9                                    ; ED86  A9 E9
    cmp a:FighterState                          ; ED88  CD 26 00
    beq L3B_EDC5                                ; ED8B  F0 38
    cmp a:FighterState+1                        ; ED8D  CD 27 00
    beq L3B_EDBB                                ; ED90  F0 29
    sec                                         ; ED92  38
    lda FighterX                                ; ED93  A5 08
    sbc FighterX+1                              ; ED95  E5 09
    bpl L3B_ED9D                                ; ED97  10 04
    eor #$FF                                    ; ED99  49 FF
    adc #$01                                    ; ED9B  69 01
L3B_ED9D:
    cmp #$20                                    ; ED9D  C9 20
    bcs L3B_EDCF                                ; ED9F  B0 2E
    lda a:FighterState+1                        ; EDA1  AD 27 00
    and #$F8                                    ; EDA4  29 F8
    cmp #$70                                    ; EDA6  C9 70
    bcc L3B_EDC5                                ; EDA8  90 1B
    cmp #$E1                                    ; EDAA  C9 E1
    bcs L3B_EDC5                                ; EDAC  B0 17
    lda a:FighterState                          ; EDAE  AD 26 00
    and #$F8                                    ; EDB1  29 F8
    cmp #$70                                    ; EDB3  C9 70
    bcc L3B_EDBB                                ; EDB5  90 04
    cmp #$E1                                    ; EDB7  C9 E1
    bcc L3B_EDCF                                ; EDB9  90 14
L3B_EDBB:
    ldx #$01                                    ; EDBB  A2 01
    jsr DrawFighter                             ; EDBD  20 D9 ED
    ldx #$00                                    ; EDC0  A2 00
    jmp DrawFighter                             ; EDC2  4C D9 ED


L3B_EDC5:
    ldx #$00                                    ; EDC5  A2 00
    jsr DrawFighter                             ; EDC7  20 D9 ED
    ldx #$01                                    ; EDCA  A2 01
    jmp DrawFighter                             ; EDCC  4C D9 ED


L3B_EDCF:
    ldx OtherFighter                            ; EDCF  A6 65
    jsr DrawFighter                             ; EDD1  20 D9 ED
    ldx CurFighter                              ; EDD4  A6 64
    jmp DrawFighter                             ; EDD6  4C D9 ED


; <- jsr DrawFighters, jmp DrawFighters, jsr L3B_EDC5, jmp L3B_EDC5, jsr L3B_EDCF, jmp L3B_EDCF
; modos: intro do round, luta, fim do round
DrawFighter:
    txa                                         ; EDD9  8A
    beq L3B_EDDE                                ; EDDA  F0 02
    lda #$80                                    ; EDDC  A9 80
L3B_EDDE:
    sta zp_E4                                   ; EDDE  85 E4
    lda FighterX,x                              ; EDE0  B5 08
    sta zp_DB                                   ; EDE2  85 DB
    lda FighterY,x                              ; EDE4  B5 0C
    sta zp_DC                                   ; EDE6  85 DC
    lda FighterFlip,x                           ; EDE8  B5 04
    sta zp_DD                                   ; EDEA  85 DD
    txa                                         ; EDEC  8A
    beq L3B_EDF7                                ; EDED  F0 08
    ldy ScreenMode                              ; EDEF  A4 B0
    cpy #$05                                    ; EDF1  C0 05
    beq L3B_EDF7                                ; EDF3  F0 02
    lda #$03                                    ; EDF5  A9 03
L3B_EDF7:
    sta zp_E1                                   ; EDF7  85 E1
    lda a:FighterFramePtrLo,x                   ; EDF9  BD 2A 00
    sta zp_D7                                   ; EDFC  85 D7
    lda a:FighterFramePtrHi,x                   ; EDFE  BD 2C 00
    sta zp_D8                                   ; EE01  85 D8
    lda a:FighterFrameBank,x                    ; EE03  BD 18 00
    ora #$80                                    ; EE06  09 80
    sta MMC5_PRG_8000                           ; EE08  8D 14 51
    lda a:FighterStateBank,x                    ; EE0B  BD 1A 00
    ora #$80                                    ; EE0E  09 80
    sta MMC5_PRG_A000                           ; EE10  8D 15 51
    ldy #$01                                    ; EE13  A0 01
    lda (zp_D7),y                               ; EE15  B1 D7       [le bancos $01]
    sta zp_D9                                   ; EE17  85 D9
    iny                                         ; EE19  C8
    lda (zp_D7),y                               ; EE1A  B1 D7       [le bancos $01]
    sta zp_DA                                   ; EE1C  85 DA
    ldy #$00                                    ; EE1E  A0 00
    lda (zp_D9),y                               ; EE20  B1 D9       [le bancos $00]
    sta a:FighterChrPage,x                      ; EE22  9D 40 00
    ldx OamIndex                                ; EE25  A6 AD
    jsr DrawMetasprite                          ; EE27  20 EA F2
    lda zp_E1                                   ; EE2A  A5 E1
    cmp #$03                                    ; EE2C  C9 03
    bcs L3B_EE35                                ; EE2E  B0 05
    clc                                         ; EE30  18
    adc #$02                                    ; EE31  69 02
    sta zp_E1                                   ; EE33  85 E1
L3B_EE35:
    jmp DrawMetasprite                          ; EE35  4C EA F2


; <- farcall L37_F093, jsr L3B_EBF2
; modos: selecao, VS, frase final
L3B_EE38:
    ldx #$00                                    ; EE38  A2 00
    lda ScreenMode                              ; EE3A  A5 B0
    cmp #$07                                    ; EE3C  C9 07
    beq L3B_EE43                                ; EE3E  F0 03
    stx a:RoundResult                           ; EE40  8E B9 00
L3B_EE43:
    cpx a:RoundResult                           ; EE43  EC B9 00
    bne L3B_EE5B                                ; EE46  D0 13
    lda #<D3C_81D6                              ; EE48  A9 D6
    sta zp_DB                                   ; EE4A  85 DB
    lda #>D3C_81D6                              ; EE4C  A9 81
    sta zp_DC                                   ; EE4E  85 DC
    lda #<D3C_824E                              ; EE50  A9 4E
    sta zp_DD                                   ; EE52  85 DD
    lda #>D3C_824E                              ; EE54  A9 82
    sta zp_DE                                   ; EE56  85 DE
    jmp L3B_EE6B                                ; EE58  4C 6B EE


L3B_EE5B:
    lda #<D3C_82C6                              ; EE5B  A9 C6
    sta zp_DB                                   ; EE5D  85 DB
    lda #>D3C_82C6                              ; EE5F  A9 82
    sta zp_DC                                   ; EE61  85 DC
    lda #<D3C_833E                              ; EE63  A9 3E
    sta zp_DD                                   ; EE65  85 DD
    lda #>D3C_833E                              ; EE67  A9 83
    sta zp_DE                                   ; EE69  85 DE

; <- jmp L3B_EE38
; modos: selecao, VS, frase final
L3B_EE6B:
    jsr L3B_E181                                ; EE6B  20 81 E1
    ldx #$02                                    ; EE6E  A2 02
    stx a:PaletteDirty                          ; EE70  8E D4 00
L3B_EE73:
    lda ram_0303,x                              ; EE73  BD 03 03
    sta a:PaletteBuf,x                          ; EE76  9D BC 00
    lda ram_0300,x                              ; EE79  BD 00 03
    sta a:PaletteBuf+3,x                        ; EE7C  9D BF 00
    lda a:RoundResult                           ; EE7F  AD B9 00
    beq L3B_EE8A                                ; EE82  F0 06
    lda ram_0306,x                              ; EE84  BD 06 03
    sta a:PaletteBuf+6,x                        ; EE87  9D C2 00
L3B_EE8A:
    dex                                         ; EE8A  CA
    bpl L3B_EE73                                ; EE8B  10 E6
    lda #$3C                                    ; EE8D  A9 3C
    ora #$80                                    ; EE8F  09 80
    sta MMC5_PRG_8000                           ; EE91  8D 14 51
    ldx FighterChar                             ; EE94  A6 00
    lda CharFrameBankTbl,x                      ; EE96  BD D2 80    [bancos $3C idx $00..$09]
    sta zp_DD                                   ; EE99  85 DD
    txa                                         ; EE9B  8A
    asl a                                       ; EE9C  0A
    tax                                         ; EE9D  AA
    lda a:RoundResult                           ; EE9E  AD B9 00
    bne L3B_EEAE                                ; EEA1  D0 0B
    lda D3C_84A6,x                              ; EEA3  BD A6 84    [bancos $3C idx $00..$12]
    ldy D3C_84A6+1,x                            ; EEA6  BC A7 84    [bancos $3C idx $00..$12]
    ldx #$02                                    ; EEA9  A2 02
    jmp L3B_EEB6                                ; EEAB  4C B6 EE


L3B_EEAE:
    lda D3C_84BA,x                              ; EEAE  BD BA 84    [bancos $3C idx $00..$00]
    ldy D3C_84BA+1,x                            ; EEB1  BC BB 84    [bancos $3C idx $00..$00]
    ldx #$03                                    ; EEB4  A2 03

; <- jmp L3B_EE5B
; modos: selecao, VS, frase final
L3B_EEB6:
    sta zp_DB                                   ; EEB6  85 DB
    sty zp_DC                                   ; EEB8  84 DC
    stx zp_DE                                   ; EEBA  86 DE
    jsr PortraitBuild                           ; EEBC  20 F6 E1
    lda zp_D5                                   ; EEBF  A5 D5
    sta ram_0346                                ; EEC1  8D 46 03
    lda zp_D6                                   ; EEC4  A5 D6
    sta ram_0347                                ; EEC6  8D 47 03
    lda #$3C                                    ; EEC9  A9 3C
    ora #$80                                    ; EECB  09 80
    sta MMC5_PRG_8000                           ; EECD  8D 14 51
    lda a:RoundResult                           ; EED0  AD B9 00
    bne L3B_EEDC                                ; EED3  D0 07
    lda #<D3C_842E                              ; EED5  A9 2E
    ldx #>D3C_842E                              ; EED7  A2 84
    jmp L3B_EEE0                                ; EED9  4C E0 EE


L3B_EEDC:
    lda #<D3C_846A                              ; EEDC  A9 6A
    ldx #>D3C_846A                              ; EEDE  A2 84

; <- jmp L3B_EEAE
; modos: selecao, VS, frase final
L3B_EEE0:
    sta zp_DB                                   ; EEE0  85 DB
    stx zp_DC                                   ; EEE2  86 DC
    lda FighterChar                             ; EEE4  A5 00
    asl a                                       ; EEE6  0A
    adc FighterChar                             ; EEE7  65 00
    asl a                                       ; EEE9  0A
    tay                                         ; EEEA  A8
    ldx #$00                                    ; EEEB  A2 00
L3B_EEED:
    lda (zp_DB),y                               ; EEED  B1 DB       [le bancos $3C]
    sta ram_038A,x                              ; EEEF  9D 8A 03
    iny                                         ; EEF2  C8
    inx                                         ; EEF3  E8
    cpx #$06                                    ; EEF4  E0 06
    bcc L3B_EEED                                ; EEF6  90 F5
    lda zp_DA                                   ; EEF8  A5 DA
    sta ram_0349                                ; EEFA  8D 49 03
    sta ram_034B                                ; EEFD  8D 4B 03
    sta ram_034D                                ; EF00  8D 4D 03
    clc                                         ; EF03  18
    lda zp_D9                                   ; EF04  A5 D9
    sta ram_0348                                ; EF06  8D 48 03
    adc #$08                                    ; EF09  69 08
    sta ram_034A                                ; EF0B  8D 4A 03
    bcc L3B_EF14                                ; EF0E  90 04
    inc ram_034B                                ; EF10  EE 4B 03    (nt)
    clc                                         ; EF13  18          (nt)
L3B_EF14:
    adc #$08                                    ; EF14  69 08
    sta ram_034C                                ; EF16  8D 4C 03
    bcc L3B_EF1E                                ; EF19  90 03
    inc ram_034D                                ; EF1B  EE 4D 03    (nt)
L3B_EF1E:
    lda #$01                                    ; EF1E  A9 01
    sta ram_03AE                                ; EF20  8D AE 03
    rts                                         ; EF23  60


; <- jmp L3B_EBF2
; modos: VS, frase final
L3B_EF24:
    ldx #$01                                    ; EF24  A2 01
    lda ScreenMode                              ; EF26  A5 B0
    cmp #$07                                    ; EF28  C9 07
    beq L3B_EF2F                                ; EF2A  F0 03
    stx a:RoundResult                           ; EF2C  8E B9 00
L3B_EF2F:
    cpx a:RoundResult                           ; EF2F  EC B9 00
    bne L3B_EF47                                ; EF32  D0 13
    lda #<D3C_81D6                              ; EF34  A9 D6
    sta zp_DB                                   ; EF36  85 DB
    lda #>D3C_81D6                              ; EF38  A9 81
    sta zp_DC                                   ; EF3A  85 DC
    lda #<D3C_824E                              ; EF3C  A9 4E
    sta zp_DD                                   ; EF3E  85 DD
    lda #>D3C_824E                              ; EF40  A9 82
    sta zp_DE                                   ; EF42  85 DE
    jmp L3B_EF57                                ; EF44  4C 57 EF


L3B_EF47:
    lda #<D3C_82C6                              ; EF47  A9 C6
    sta zp_DB                                   ; EF49  85 DB
    lda #>D3C_82C6                              ; EF4B  A9 82
    sta zp_DC                                   ; EF4D  85 DC
    lda #<D3C_833E                              ; EF4F  A9 3E
    sta zp_DD                                   ; EF51  85 DD
    lda #>D3C_833E                              ; EF53  A9 83
    sta zp_DE                                   ; EF55  85 DE

; <- jmp L3B_EF24
; modos: VS, frase final
L3B_EF57:
    jsr L3B_E181                                ; EF57  20 81 E1
    ldx #$02                                    ; EF5A  A2 02
L3B_EF5C:
    lda ram_030C,x                              ; EF5C  BD 0C 03
    sta a:PaletteBuf+12,x                       ; EF5F  9D C8 00
    lda ram_0309,x                              ; EF62  BD 09 03
    sta a:PaletteBuf+15,x                       ; EF65  9D CB 00
    lda ram_030F,x                              ; EF68  BD 0F 03
    sta a:PaletteBuf+18,x                       ; EF6B  9D CE 00
    dex                                         ; EF6E  CA
    bpl L3B_EF5C                                ; EF6F  10 EB
    lda #$3C                                    ; EF71  A9 3C
    ora #$80                                    ; EF73  09 80
    sta MMC5_PRG_8000                           ; EF75  8D 14 51
    lda FighterChar+1                           ; EF78  A5 01
    asl a                                       ; EF7A  0A
    tax                                         ; EF7B  AA
    lda a:RoundResult                           ; EF7C  AD B9 00
    cmp #$01                                    ; EF7F  C9 01
    bne L3B_EF8C                                ; EF81  D0 09
    lda D3C_84A6,x                              ; EF83  BD A6 84    [bancos $3C idx $00..$00]
    ldy D3C_84A6+1,x                            ; EF86  BC A7 84    [bancos $3C idx $00..$00]
    jmp L3B_EF92                                ; EF89  4C 92 EF


L3B_EF8C:
    lda D3C_84BA,x                              ; EF8C  BD BA 84    [bancos $3C idx $00..$00]
    ldy D3C_84BA+1,x                            ; EF8F  BC BB 84    [bancos $3C idx $00..$00]

; <- jmp L3B_EF47
; modos: VS, frase final
L3B_EF92:
    sta zp_D9                                   ; EF92  85 D9
    sty zp_DA                                   ; EF94  84 DA
    lda a:FighterFrameBank+1                    ; EF96  AD 19 00
    ora #$80                                    ; EF99  09 80
    sta MMC5_PRG_8000                           ; EF9B  8D 14 51
    ldy #$00                                    ; EF9E  A0 00
    lda (zp_D9),y                               ; EFA0  B1 D9       [le bancos $00]
    sta a:FighterChrPage+1                      ; EFA2  8D 41 00
    ldx #$00                                    ; EFA5  A2 00
    stx OamIndex                                ; EFA7  86 AD
    lda zp_D5                                   ; EFA9  A5 D5
    sta zp_DB                                   ; EFAB  85 DB
    lda zp_D6                                   ; EFAD  A5 D6
    sta zp_DC                                   ; EFAF  85 DC
    lda #$40                                    ; EFB1  A9 40
    sta zp_DD                                   ; EFB3  85 DD
    lda #$80                                    ; EFB5  A9 80
    sta zp_E4                                   ; EFB7  85 E4
    lda a:RoundResult                           ; EFB9  AD B9 00
    cmp #$01                                    ; EFBC  C9 01
    beq L3B_EFC7                                ; EFBE  F0 07
    lda #$02                                    ; EFC0  A9 02
    sta zp_E1                                   ; EFC2  85 E1
    jsr DrawMetasprite                          ; EFC4  20 EA F2
L3B_EFC7:
    lda #$00                                    ; EFC7  A9 00
    sta zp_E1                                   ; EFC9  85 E1
    jsr DrawMetasprite                          ; EFCB  20 EA F2
    inc zp_E1                                   ; EFCE  E6 E1
    jmp DrawMetasprite                          ; EFD0  4C EA F2


; <- farcall L37_F093, jsr L3B_EAF2
; modos: selecao, VS
L3B_EFD3:
    lda #$92                                    ; EFD3  A9 92
    sta zp_D9                                   ; EFD5  85 D9
    lda #$03                                    ; EFD7  A9 03
    sta zp_DA                                   ; EFD9  85 DA
    ldy zp_D5                                   ; EFDB  A4 D5
    beq L3B_EFE7                                ; EFDD  F0 08
    lda #$A0                                    ; EFDF  A9 A0
    sta zp_D9                                   ; EFE1  85 D9
    lda #$03                                    ; EFE3  A9 03
    sta zp_DA                                   ; EFE5  85 DA
L3B_EFE7:
    clc                                         ; EFE7  18
    lda zp_D9                                   ; EFE8  A5 D9
    adc #$07                                    ; EFEA  69 07
    sta zp_D5                                   ; EFEC  85 D5
    lda zp_DA                                   ; EFEE  A5 DA
    adc #$00                                    ; EFF0  69 00
    sta zp_D6                                   ; EFF2  85 D6
    ldx FighterChar,y                           ; EFF4  B6 00
    ldy #$06                                    ; EFF6  A0 06
    lda #$00                                    ; EFF8  A9 00
L3B_EFFA:
    sta (zp_D9),y                               ; EFFA  91 D9
    sta (zp_D5),y                               ; EFFC  91 D5
    dey                                         ; EFFE  88
    bpl L3B_EFFA                                ; EFFF  10 F9
    lda #$3C                                    ; F001  A9 3C
    ora #$80                                    ; F003  09 80
    sta MMC5_PRG_8000                           ; F005  8D 14 51
    lda #$07                                    ; F008  A9 07
    sec                                         ; F00A  38
    sbc D3C_851E,x                              ; F00B  FD 1E 85    [bancos $3C idx $00..$09]
    lsr a                                       ; F00E  4A
    tay                                         ; F00F  A8
    txa                                         ; F010  8A
    asl a                                       ; F011  0A
    asl a                                       ; F012  0A
    asl a                                       ; F013  0A
    tax                                         ; F014  AA
L3B_F015:
    lda CharNameTbl,x                           ; F015  BD CE 84    [bancos $3C idx $00..$4E]
    asl a                                       ; F018  0A
    sec                                         ; F019  38
    sbc #$3A                                    ; F01A  E9 3A
    cmp #$30                                    ; F01C  C9 30
    bcc L3B_F027                                ; F01E  90 07
    sta (zp_D9),y                               ; F020  91 D9
    clc                                         ; F022  18
    adc #$01                                    ; F023  69 01
    sta (zp_D5),y                               ; F025  91 D5
L3B_F027:
    inx                                         ; F027  E8
    iny                                         ; F028  C8
    cpy #$07                                    ; F029  C0 07
    bcc L3B_F015                                ; F02B  90 E8
    rts                                         ; F02D  60


; <- farcall Irq_MenuLast, jmp NmiTask_VsQuote
; modos: selecao, VS, frase final
L3B_F02E:
    lda PpuCtrlShadow                           ; F02E  A5 ED
    ora #$04                                    ; F030  09 04
    sta PpuCtrlShadow                           ; F032  85 ED
    sta PPUCTRL                                 ; F034  8D 00 20
    ldx ram_0346                                ; F037  AE 46 03
    ldy ram_0347                                ; F03A  AC 47 03
    sty PPUADDR                                 ; F03D  8C 06 20
    stx PPUADDR                                 ; F040  8E 06 20
    lda ram_034E                                ; F043  AD 4E 03
    sta PPUDATA                                 ; F046  8D 07 20
    lda ram_0354                                ; F049  AD 54 03
    sta PPUDATA                                 ; F04C  8D 07 20
    lda ram_035A                                ; F04F  AD 5A 03
    sta PPUDATA                                 ; F052  8D 07 20
    lda ram_0360                                ; F055  AD 60 03
    sta PPUDATA                                 ; F058  8D 07 20
    lda ram_0366                                ; F05B  AD 66 03
    sta PPUDATA                                 ; F05E  8D 07 20
    lda ram_036C                                ; F061  AD 6C 03
    sta PPUDATA                                 ; F064  8D 07 20
    lda ram_0372                                ; F067  AD 72 03
    sta PPUDATA                                 ; F06A  8D 07 20
    lda ram_0378                                ; F06D  AD 78 03
    sta PPUDATA                                 ; F070  8D 07 20
    lda ram_037E                                ; F073  AD 7E 03
    sta PPUDATA                                 ; F076  8D 07 20
    lda ram_0384                                ; F079  AD 84 03
    sta PPUDATA                                 ; F07C  8D 07 20
    inx                                         ; F07F  E8
    sty PPUADDR                                 ; F080  8C 06 20
    stx PPUADDR                                 ; F083  8E 06 20
    lda ram_034F                                ; F086  AD 4F 03
    sta PPUDATA                                 ; F089  8D 07 20
    lda ram_0355                                ; F08C  AD 55 03
    sta PPUDATA                                 ; F08F  8D 07 20
    lda ram_035B                                ; F092  AD 5B 03
    sta PPUDATA                                 ; F095  8D 07 20
    lda ram_0361                                ; F098  AD 61 03
    sta PPUDATA                                 ; F09B  8D 07 20
    lda ram_0367                                ; F09E  AD 67 03
    sta PPUDATA                                 ; F0A1  8D 07 20
    lda ram_036D                                ; F0A4  AD 6D 03
    sta PPUDATA                                 ; F0A7  8D 07 20
    lda ram_0373                                ; F0AA  AD 73 03
    sta PPUDATA                                 ; F0AD  8D 07 20
    lda ram_0379                                ; F0B0  AD 79 03
    sta PPUDATA                                 ; F0B3  8D 07 20
    lda ram_037F                                ; F0B6  AD 7F 03
    sta PPUDATA                                 ; F0B9  8D 07 20
    lda ram_0385                                ; F0BC  AD 85 03
    sta PPUDATA                                 ; F0BF  8D 07 20
    inx                                         ; F0C2  E8
    sty PPUADDR                                 ; F0C3  8C 06 20
    stx PPUADDR                                 ; F0C6  8E 06 20
    lda ram_0350                                ; F0C9  AD 50 03
    sta PPUDATA                                 ; F0CC  8D 07 20
    lda ram_0356                                ; F0CF  AD 56 03
    sta PPUDATA                                 ; F0D2  8D 07 20
    lda ram_035C                                ; F0D5  AD 5C 03
    sta PPUDATA                                 ; F0D8  8D 07 20
    lda ram_0362                                ; F0DB  AD 62 03
    sta PPUDATA                                 ; F0DE  8D 07 20
    lda ram_0368                                ; F0E1  AD 68 03
    sta PPUDATA                                 ; F0E4  8D 07 20
    lda ram_036E                                ; F0E7  AD 6E 03
    sta PPUDATA                                 ; F0EA  8D 07 20
    lda ram_0374                                ; F0ED  AD 74 03
    sta PPUDATA                                 ; F0F0  8D 07 20
    lda ram_037A                                ; F0F3  AD 7A 03
    sta PPUDATA                                 ; F0F6  8D 07 20
    lda ram_0380                                ; F0F9  AD 80 03
    sta PPUDATA                                 ; F0FC  8D 07 20
    lda ram_0386                                ; F0FF  AD 86 03
    sta PPUDATA                                 ; F102  8D 07 20
    inx                                         ; F105  E8
    sty PPUADDR                                 ; F106  8C 06 20
    stx PPUADDR                                 ; F109  8E 06 20
    lda ram_0351                                ; F10C  AD 51 03
    sta PPUDATA                                 ; F10F  8D 07 20
    lda ram_0357                                ; F112  AD 57 03
    sta PPUDATA                                 ; F115  8D 07 20
    lda ram_035D                                ; F118  AD 5D 03
    sta PPUDATA                                 ; F11B  8D 07 20
    lda ram_0363                                ; F11E  AD 63 03
    sta PPUDATA                                 ; F121  8D 07 20
    lda ram_0369                                ; F124  AD 69 03
    sta PPUDATA                                 ; F127  8D 07 20
    lda ram_036F                                ; F12A  AD 6F 03
    sta PPUDATA                                 ; F12D  8D 07 20
    lda ram_0375                                ; F130  AD 75 03
    sta PPUDATA                                 ; F133  8D 07 20
    lda ram_037B                                ; F136  AD 7B 03
    sta PPUDATA                                 ; F139  8D 07 20
    lda ram_0381                                ; F13C  AD 81 03
    sta PPUDATA                                 ; F13F  8D 07 20
    lda ram_0387                                ; F142  AD 87 03
    sta PPUDATA                                 ; F145  8D 07 20
    inx                                         ; F148  E8
    sty PPUADDR                                 ; F149  8C 06 20
    stx PPUADDR                                 ; F14C  8E 06 20
    lda ram_0352                                ; F14F  AD 52 03
    sta PPUDATA                                 ; F152  8D 07 20
    lda ram_0358                                ; F155  AD 58 03
    sta PPUDATA                                 ; F158  8D 07 20
    lda ram_035E                                ; F15B  AD 5E 03
    sta PPUDATA                                 ; F15E  8D 07 20
    lda ram_0364                                ; F161  AD 64 03
    sta PPUDATA                                 ; F164  8D 07 20
    lda ram_036A                                ; F167  AD 6A 03
    sta PPUDATA                                 ; F16A  8D 07 20
    lda ram_0370                                ; F16D  AD 70 03
    sta PPUDATA                                 ; F170  8D 07 20
    lda ram_0376                                ; F173  AD 76 03
    sta PPUDATA                                 ; F176  8D 07 20
    lda ram_037C                                ; F179  AD 7C 03
    sta PPUDATA                                 ; F17C  8D 07 20
    lda ram_0382                                ; F17F  AD 82 03
    sta PPUDATA                                 ; F182  8D 07 20
    lda ram_0388                                ; F185  AD 88 03
    sta PPUDATA                                 ; F188  8D 07 20
    inx                                         ; F18B  E8
    sty PPUADDR                                 ; F18C  8C 06 20
    stx PPUADDR                                 ; F18F  8E 06 20
    lda ram_0353                                ; F192  AD 53 03
    sta PPUDATA                                 ; F195  8D 07 20
    lda ram_0359                                ; F198  AD 59 03
    sta PPUDATA                                 ; F19B  8D 07 20
    lda ram_035F                                ; F19E  AD 5F 03
    sta PPUDATA                                 ; F1A1  8D 07 20
    lda ram_0365                                ; F1A4  AD 65 03
    sta PPUDATA                                 ; F1A7  8D 07 20
    lda ram_036B                                ; F1AA  AD 6B 03
    sta PPUDATA                                 ; F1AD  8D 07 20
    lda ram_0371                                ; F1B0  AD 71 03
    sta PPUDATA                                 ; F1B3  8D 07 20
    lda ram_0377                                ; F1B6  AD 77 03
    sta PPUDATA                                 ; F1B9  8D 07 20
    lda ram_037D                                ; F1BC  AD 7D 03
    sta PPUDATA                                 ; F1BF  8D 07 20
    lda ram_0383                                ; F1C2  AD 83 03
    sta PPUDATA                                 ; F1C5  8D 07 20
    lda ram_0389                                ; F1C8  AD 89 03
    sta PPUDATA                                 ; F1CB  8D 07 20
    lda PpuCtrlShadow                           ; F1CE  A5 ED
    and #$FB                                    ; F1D0  29 FB
    sta PpuCtrlShadow                           ; F1D2  85 ED
    sta PPUCTRL                                 ; F1D4  8D 00 20
    lda ram_0349                                ; F1D7  AD 49 03
    sta PPUADDR                                 ; F1DA  8D 06 20
    lda ram_0348                                ; F1DD  AD 48 03
    sta PPUADDR                                 ; F1E0  8D 06 20
    lda ram_038A                                ; F1E3  AD 8A 03
    sta PPUDATA                                 ; F1E6  8D 07 20
    lda ram_038B                                ; F1E9  AD 8B 03
    sta PPUDATA                                 ; F1EC  8D 07 20
    lda ram_034B                                ; F1EF  AD 4B 03
    sta PPUADDR                                 ; F1F2  8D 06 20
    lda ram_034A                                ; F1F5  AD 4A 03
    sta PPUADDR                                 ; F1F8  8D 06 20
    lda ram_038C                                ; F1FB  AD 8C 03
    sta PPUDATA                                 ; F1FE  8D 07 20
    lda ram_038D                                ; F201  AD 8D 03
    sta PPUDATA                                 ; F204  8D 07 20
    lda ram_034D                                ; F207  AD 4D 03
    sta PPUADDR                                 ; F20A  8D 06 20
    lda ram_034C                                ; F20D  AD 4C 03
    sta PPUADDR                                 ; F210  8D 06 20
    lda ram_038E                                ; F213  AD 8E 03
    sta PPUDATA                                 ; F216  8D 07 20
    lda ram_038F                                ; F219  AD 8F 03
    sta PPUDATA                                 ; F21C  8D 07 20
    lda #$00                                    ; F21F  A9 00
    sta ram_03AE                                ; F221  8D AE 03
    rts                                         ; F224  60


; <- jmp K_FED5
; modos: VS, frase final
L3B_F225:
    lda ram_03B0                                ; F225  AD B0 03
    sta PPUADDR                                 ; F228  8D 06 20
    lda ram_03AF                                ; F22B  AD AF 03
    sta PPUADDR                                 ; F22E  8D 06 20
    lda ram_03B3                                ; F231  AD B3 03
    sta PPUDATA                                 ; F234  8D 07 20
    lda ram_03B2                                ; F237  AD B2 03
    sta PPUADDR                                 ; F23A  8D 06 20
    lda ram_03B1                                ; F23D  AD B1 03
    sta PPUADDR                                 ; F240  8D 06 20
    lda ram_03B4                                ; F243  AD B4 03
    sta PPUDATA                                 ; F246  8D 07 20
    rts                                         ; F249  60


; <- jsr RoundInit
; modos: intro do round
L3B_F24A:
    lda a:FighterFrameBank,x                    ; F24A  BD 18 00
    ora #$80                                    ; F24D  09 80
    sta MMC5_PRG_8000                           ; F24F  8D 14 51
    lda ram_0342,x                              ; F252  BD 42 03
    sta zp_D5                                   ; F255  85 D5
    lda ram_0344,x                              ; F257  BD 44 03
    sta zp_D6                                   ; F25A  85 D6
    ldy #$00                                    ; F25C  A0 00
    lda (zp_D5),y                               ; F25E  B1 D5       [le bancos $00]
    sta AiScriptPtrLo,x                         ; F260  95 69
    iny                                         ; F262  C8
    lda (zp_D5),y                               ; F263  B1 D5       [le bancos $00]
    sta AiScriptPtrHi,x                         ; F265  95 6B
    lda #$80                                    ; F267  A9 80
    sta zp_71,x                                 ; F269  95 71
    lda #$00                                    ; F26B  A9 00
    sta zp_6D                                   ; F26D  85 6D
    sta zp_6E                                   ; F26F  85 6E
    sta zp_6F,x                                 ; F271  95 6F
    sta a:zp_73,x                               ; F273  9D 73 00
    sta a:zp_75,x                               ; F276  9D 75 00
    rts                                         ; F279  60


; <- jsr DrawFighters
; modos: intro do round, luta, fim do round
L3B_F27A:
    lda zp_7B,x                                 ; F27A  B5 7B
    bne L3B_F27F                                ; F27C  D0 01
    rts                                         ; F27E  60


L3B_F27F:
    lda zp_7B,x                                 ; F27F  B5 7B
    sta zp_DB                                   ; F281  85 DB
    lda zp_7D,x                                 ; F283  B5 7D
    sta zp_DC                                   ; F285  85 DC
    lda zp_81,x                                 ; F287  B5 81
    and #$40                                    ; F289  29 40
    sta zp_DD                                   ; F28B  85 DD
    stx zp_E1                                   ; F28D  86 E1
    lda #$01                                    ; F28F  A9 01
    sta zp_E4                                   ; F291  85 E4
    lda #$20                                    ; F293  A9 20
    ora #$80                                    ; F295  09 80
    sta MMC5_PRG_8000                           ; F297  8D 14 51
    lda zp_81,x                                 ; F29A  B5 81
    and #$80                                    ; F29C  29 80
    beq L3B_F2B5                                ; F29E  F0 15
    lda zp_7F,x                                 ; F2A0  B5 7F
    lsr a                                       ; F2A2  4A
    and #$07                                    ; F2A3  29 07
    lsr a                                       ; F2A5  4A
    asl a                                       ; F2A6  0A
    tay                                         ; F2A7  A8
    lda D3B_E595,y                              ; F2A8  B9 95 E5    [idx $00..$06]
    sta zp_D9                                   ; F2AB  85 D9
    lda D3B_E595+1,y                            ; F2AD  B9 96 E5    [idx $00..$06]
    sta zp_DA                                   ; F2B0  85 DA
    jmp L3B_F2D0                                ; F2B2  4C D0 F2


L3B_F2B5:
    lda zp_77,x                                 ; F2B5  B5 77
    lsr a                                       ; F2B7  4A
    asl a                                       ; F2B8  0A
    asl a                                       ; F2B9  0A
    asl a                                       ; F2BA  0A
    sta zp_D9                                   ; F2BB  85 D9
    lda zp_7F,x                                 ; F2BD  B5 7F
    lsr a                                       ; F2BF  4A
    and #$03                                    ; F2C0  29 03
    asl a                                       ; F2C2  0A
    adc zp_D9                                   ; F2C3  65 D9
    tay                                         ; F2C5  A8
    lda D3B_E57D,y                              ; F2C6  B9 7D E5    [idx $00..$06]
    sta zp_D9                                   ; F2C9  85 D9
    lda D3B_E57D+1,y                            ; F2CB  B9 7E E5    [idx $00..$06]
    sta zp_DA                                   ; F2CE  85 DA

; <- jmp L3B_F27F
; modos: luta, fim do round
L3B_F2D0:
    ldy #$00                                    ; F2D0  A0 00
    lda (zp_D9),y                               ; F2D2  B1 D9       [le bancos $20]
    sta MMC5_CHR_SPR5                           ; F2D4  8D 25 51
    ldx OamIndex                                ; F2D7  A6 AD
    jsr DrawMetasprite                          ; F2D9  20 EA F2
    jmp DrawMetasprite                          ; F2DC  4C EA F2


; <- farcall L37_F18C, jsr L3B_E455, jmp L3B_E455, jsr FadeIn, jmp L3B_F36C, jsr FightFrame
; modos: todos
OamHideRest:
    ldx OamIndex                                ; F2DF  A6 AD       esconde os sprites nao usados neste quadro (Y = $FE do indice OamIndex ate o fim)
    lda #$FE                                    ; F2E1  A9 FE
L3B_F2E3:
    sta OamBuf,x                                ; F2E3  9D 00 02
    inx                                         ; F2E6  E8
    bne L3B_F2E3                                ; F2E7  D0 FA
    rts                                         ; F2E9  60


; Desenha um metasprite (lista de sprites 8x16) na OAM. Dados em (zp_D9): atributo, depois grupos
; "quantidade, dx, dy, tiles..." ate um byte negativo. zp_DB/zp_DC = posicao base, zp_DD = espelhado.
; <- jsr DrawFighter, jmp DrawFighter, jsr L3B_EF8C, jmp L3B_EF8C, jsr L3B_F2B5, jmp L3B_F2B5 ... (+6)
; modos: selecao, VS, intro do round, luta, fim do round, frase final
DrawMetasprite:
    iny                                         ; F2EA  C8
    lda (zp_D9),y                               ; F2EB  B1 D9       [le bancos $00,$20]
    cmp #$FF                                    ; F2ED  C9 FF
    beq L3B_F356                                ; F2EF  F0 65
    eor zp_DD                                   ; F2F1  45 DD
    ora zp_E1                                   ; F2F3  05 E1
    sta zp_E0                                   ; F2F5  85 E0
    lda #$08                                    ; F2F7  A9 08
    sta zp_E3                                   ; F2F9  85 E3

; <- jmp L3B_F315, jmp L3B_F331
; modos: selecao, VS, intro do round, luta, fim do round, frase final
L3B_F2FB:
    iny                                         ; F2FB  C8
    lda (zp_D9),y                               ; F2FC  B1 D9       [le bancos $00,$20]
    bmi L3B_F356                                ; F2FE  30 56
    sta zp_E2                                   ; F300  85 E2
    iny                                         ; F302  C8
    lda (zp_D9),y                               ; F303  B1 D9       [le bancos $00,$20]
    sta zp_DE                                   ; F305  85 DE
    lda zp_DD                                   ; F307  A5 DD
    beq L3B_F315                                ; F309  F0 0A
    lda #$F8                                    ; F30B  A9 F8
    sta zp_E3                                   ; F30D  85 E3
    sec                                         ; F30F  38
    sbc zp_DE                                   ; F310  E5 DE
    jmp L3B_F317                                ; F312  4C 17 F3


L3B_F315:
    lda zp_DE                                   ; F315  A5 DE

; <- jmp DrawMetasprite
; modos: selecao, VS, intro do round, luta, fim do round, frase final
L3B_F317:
    clc                                         ; F317  18
    adc zp_DB                                   ; F318  65 DB
    sta zp_DE                                   ; F31A  85 DE
    iny                                         ; F31C  C8
    lda (zp_D9),y                               ; F31D  B1 D9       [le bancos $00,$20]
    clc                                         ; F31F  18
    adc zp_DC                                   ; F320  65 DC
    sta zp_DF                                   ; F322  85 DF
L3B_F324:
    lda zp_DE                                   ; F324  A5 DE
    cmp #$08                                    ; F326  C9 08
    bcs L3B_F331                                ; F328  B0 07
    tya                                         ; F32A  98
    adc zp_E2                                   ; F32B  65 E2
    tay                                         ; F32D  A8
    jmp L3B_F2FB                                ; F32E  4C FB F2


L3B_F331:
    sta OamBuf+3,x                              ; F331  9D 03 02
    clc                                         ; F334  18
    adc zp_E3                                   ; F335  65 E3
    sta zp_DE                                   ; F337  85 DE
    lda zp_DF                                   ; F339  A5 DF
    sta OamBuf,x                                ; F33B  9D 00 02
    lda zp_E0                                   ; F33E  A5 E0
    sta OamBuf+2,x                              ; F340  9D 02 02
    iny                                         ; F343  C8
    lda (zp_D9),y                               ; F344  B1 D9       [le bancos $00,$20]
    clc                                         ; F346  18
    adc zp_E4                                   ; F347  65 E4
    sta OamBuf+1,x                              ; F349  9D 01 02
    txa                                         ; F34C  8A
    axs #$FC                                    ; F34D  CB FC
    dec zp_E2                                   ; F34F  C6 E2
    bne L3B_F324                                ; F351  D0 D1
    jmp L3B_F2FB                                ; F353  4C FB F2


L3B_F356:
    stx OamIndex                                ; F356  86 AD
    rts                                         ; F358  60


; <- farcall L37_EFFA
; modos: selecao
L3B_F359:
    ldx #$00                                    ; F359  A2 00
    stx OamIndex                                ; F35B  86 AD
    lda FrameCounter                            ; F35D  A5 B1
    and #$01                                    ; F35F  29 01
    bne L3B_F364                                ; F361  D0 01
    rts                                         ; F363  60


L3B_F364:
    ldy #$00                                    ; F364  A0 00
    jsr DrawMetasprite                          ; F366  20 EA F2
    jmp DrawMetasprite                          ; F369  4C EA F2


; <- farcall L37_EFFA, farcall L37_F0CF
; modos: selecao
L3B_F36C:
    ldx OamIndex                                ; F36C  A6 AD
    ldy #$01                                    ; F36E  A0 01
    jsr DrawMetasprite                          ; F370  20 EA F2
    jmp OamHideRest                             ; F373  4C DF F2


; <- farcall ScreenPlayerSelect
; modos: selecao
L3B_F376:
    lda #$00                                    ; F376  A9 00
    sta a:FighterChrPage+1                      ; F378  8D 41 00
    ldx #$05                                    ; F37B  A2 05
L3B_F37D:
    lda D3B_F545,x                              ; F37D  BD 45 F5    [idx $00..$05]
    sta a:PaletteBuf+6,x                        ; F380  9D C2 00
    lda D3B_F54B,x                              ; F383  BD 4B F5    [idx $00..$05]
    sta a:PaletteBuf+18,x                       ; F386  9D CE 00
    dex                                         ; F389  CA
    bpl L3B_F37D                                ; F38A  10 F1
    lda #$28                                    ; F38C  A9 28
    sta PPUADDR                                 ; F38E  8D 06 20
    lda #$00                                    ; F391  A9 00
    sta PPUADDR                                 ; F393  8D 06 20
    lda #<D3B_F3AB                              ; F396  A9 AB
    ldx #>D3B_F3AB                              ; F398  A2 F3
    jsr PpuUnRle                                ; F39A  20 BE E3
    lda #<D3B_F4B9                              ; F39D  A9 B9
    ldx #>D3B_F4B9                              ; F39F  A2 F4
    jsr PpuUnRle                                ; F3A1  20 BE E3
    lda #<D3B_F538                              ; F3A4  A9 38
    ldx #>D3B_F538                              ; F3A6  A2 F5
    jmp PpuUnRle                                ; F3A8  4C BE E3

D3B_F3AB:
    .byte $9B,$00,$9B,$27,$66,$5E,$48,$78,$50,$6A,$00,$00,$6C,$50,$5E,$50; F3AB
    .byte $4C,$6E,$00,$9B,$11,$67,$5F,$49,$79,$51,$6B,$00,$00,$6D,$51,$5F; F3BB
    .byte $51,$4D,$6F,$00,$9B,$10,$01,$02,$00,$03,$04,$05,$06,$07,$08,$00; F3CB
    .byte $9B,$05,$09,$0A,$00,$9B,$0D,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13; F3DB
    .byte $14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$00,$9B,$0C,$1D,$1E,$1F,$20; F3EB
    .byte $21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2B,$2C,$2D,$2E,$2F; F3FB
    .byte $00,$9B,$0B,$30,$31,$32,$33,$34,$35,$2B,$9B,$02,$36,$37,$38,$39; F40B
    .byte $3A,$3B,$2B,$3C,$3D,$3E,$3F,$00,$9B,$0B,$40,$41,$42,$43,$44,$45; F41B
    .byte $2B,$9B,$02,$46,$47,$48,$49,$4A,$4B,$2B,$2B,$4C,$4D,$4E,$00,$9B; F42B
    .byte $0B,$4F,$2B,$2B,$50,$51,$52,$2B,$53,$54,$55,$56,$57,$58,$59,$5A; F43B
    .byte $5B,$5C,$5D,$5E,$5F,$00,$9B,$0B,$60,$61,$62,$63,$64,$65,$66,$67; F44B
    .byte $68,$69,$6A,$6B,$00,$9B,$02,$6C,$6D,$6E,$6F,$00,$9B,$0D,$70,$71; F45B
    .byte $72,$73,$00,$74,$75,$76,$77,$78,$00,$9B,$04,$79,$7A,$7B,$7C,$00; F46B
    .byte $9B,$0D,$7D,$7E,$7F,$00,$00,$80,$81,$82,$83,$84,$00,$9B,$03,$85; F47B
    .byte $86,$87,$88,$00,$9B,$0D,$89,$8A,$00,$9B,$03,$8B,$8C,$8D,$8E,$00; F48B
    .byte $9B,$03,$8F,$90,$91,$92,$00,$9B,$13,$93,$59,$94,$95,$00,$9B,$03; F49B
    .byte $96,$97,$98,$00,$9B,$1C,$99,$9A,$00,$9B,$07,$00,$9B,$00; F4AB
D3B_F4B9:
    .byte $61,$00,$61,$48,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C; F4B9
    .byte $00,$61,$13,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$16,$17,$18,$00; F4C9
    .byte $61,$13,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$00,$61; F4D9
    .byte $13,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,$30,$00,$61,$13; F4E9
    .byte $31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$00,$61,$13,$3D; F4F9
    .byte $3E,$3F,$40,$41,$42,$43,$44,$45,$46,$47,$48,$00,$61,$13,$49,$4A; F509
    .byte $4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$00,$61,$13,$55,$56,$57; F519
    .byte $58,$59,$5A,$5B,$5C,$5D,$5E,$5F,$60,$00,$61,$A9,$00,$61,$00; F529
D3B_F538:
    .byte $00,$AA,$00,$1F,$FF,$00,$17,$0F,$00,$06,$0F,$00,$00; F538
D3B_F545:
    .byte $00,$28,$11,$00,$10,$20               ; F545
D3B_F54B:
    .byte $11,$16,$20,$1A,$27,$21               ; F54B

; ------------------------------------------------------------------------------------------------
; A LUTA INTEIRA: rounds ate alguem fechar a partida.
; <- farcall Main
; modos: VS
Match:
    lda #$FF                                    ; F551  A9 FF
    sta a:RoundNumber                           ; F553  8D B8 00

; <- jmp FightFrame, jmp L3B_F605
; modos: VS, fim do round
RoundStart:
    lda #$00                                    ; F556  A9 00
    sta FrameCounter                            ; F558  85 B1
    jsr RoundInit                               ; F55A  20 0F F6
    farcall FadeIn                              ; F55D  A9 F5 48 A9 6E 48 A9 3B .. -> 3B:E4D6
    lda #$2D                                    ; F56F  A9 2D
    sta MusicBank                               ; F571  8D 5F 04
    lda #<D2D_A000                              ; F574  A9 00
    sta zp_D5                                   ; F576  85 D5
    lda #>D2D_A000                              ; F578  A9 A0
    sta zp_D6                                   ; F57A  85 D6
    farcall SoundLoadSong                       ; F57C  A9 F5 48 A9 8D 48 A9 3B .. -> 37:E3E0

; Laco de um quadro da luta: espera o vblank, som, regras do round, divisao de tela, logica dos lutadores.
; modos: intro do round, luta, fim do round
FightFrame:
    lda #$00                                    ; F58E  A9 00
    sta VBlankFlag                              ; F590  85 AC
L3B_F592:
    lda VBlankFlag                              ; F592  A5 AC
    beq L3B_F592                                ; F594  F0 FC
    lda #$00                                    ; F596  A9 00
    sta OamIndex                                ; F598  85 AD
    farcall SoundUpdate                         ; F59A  A9 F5 48 A9 AB 48 A9 3B .. -> 37:E45F
    jsr RoundLogic                              ; F5AC  20 4F F6
    jsr StageSplitSetup                         ; F5AF  20 08 F9
    lda HitStop                                 ; F5B2  AD 0C 04    "hit stop": enquanto HitStop nao zera, a logica roda quadro sim, quadro nao
    and #$01                                    ; F5B5  29 01
    bne FightFrame                              ; F5B7  D0 D5
    farcall FightersUpdate                      ; F5B9  A9 F5 48 A9 CA 48 A9 3B .. -> 3F:EF74
    jsr StageParallaxCalc                       ; F5CB  20 40 F9
    jsr OamHideRest                             ; F5CE  20 DF F2
    lda ScreenMode                              ; F5D1  A5 B0
    cmp #$06                                    ; F5D3  C9 06
    bne FightFrame                              ; F5D5  D0 B7
    lda a:RoundStep                             ; F5D7  AD B6 00
    bne FightFrame                              ; F5DA  D0 B2
    farcall SoundStopMusic                      ; F5DC  A9 F5 48 A9 ED 48 A9 3B .. -> 37:E479
    jsr FadeOut                                 ; F5EE  20 26 E4
    lda #$02                                    ; F5F1  A9 02
    cmp FighterWins                             ; F5F3  C5 10
    beq L3B_F60E                                ; F5F5  F0 17
    cmp FighterWins+1                           ; F5F7  C5 11
    beq L3B_F60E                                ; F5F9  F0 13
    cmp a:RoundNumber                           ; F5FB  CD B8 00
    bcc L3B_F60E                                ; F5FE  90 0E
    beq L3B_F605                                ; F600  F0 03
    jmp RoundStart                              ; F602  4C 56 F5


L3B_F605:
    lda #$01                                    ; F605  A9 01
    sta FighterWins                             ; F607  85 10
    sta FighterWins+1                           ; F609  85 11
    jmp RoundStart                              ; F60B  4C 56 F5


L3B_F60E:
    rts                                         ; F60E  60


; <- jsr Match
; modos: VS, fim do round
RoundInit:
    inc a:RoundNumber                           ; F60F  EE B8 00
    lda #$FF                                    ; F612  A9 FF
    sta a:RoundResult                           ; F614  8D B9 00
    lda #$09                                    ; F617  A9 09
    sta a:TimerOnes                             ; F619  8D BA 00
    sta a:TimerTens                             ; F61C  8D BB 00
    lda #$00                                    ; F61F  A9 00
    sta a:RoundStepTimer                        ; F621  8D B7 00
    lda #$18                                    ; F624  A9 18
    sta a:RoundStep                             ; F626  8D B6 00
    lda #$04                                    ; F629  A9 04
    sta ScreenMode                              ; F62B  85 B0
    jsr L3B_E377                                ; F62D  20 77 E3
    ldx #$00                                    ; F630  A2 00
    jsr FighterRoundInit                        ; F632  20 98 E0
    ldx #$01                                    ; F635  A2 01
    jsr FighterRoundInit                        ; F637  20 98 E0
    lda FighterIsCpu                            ; F63A  A5 02
    beq L3B_F643                                ; F63C  F0 05
    ldx #$00                                    ; F63E  A2 00       (nt)
    jsr L3B_F24A                                ; F640  20 4A F2    (nt)
L3B_F643:
    lda FighterIsCpu+1                          ; F643  A5 03
    beq L3B_F64C                                ; F645  F0 05
    ldx #$01                                    ; F647  A2 01
    jsr L3B_F24A                                ; F649  20 4A F2
L3B_F64C:
    jmp L3B_F8D3                                ; F64C  4C D3 F8


; <- jsr FightFrame
; modos: intro do round, luta, fim do round
RoundLogic:
    lda ScreenMode                              ; F64F  A5 B0
    cmp #$04                                    ; F651  C9 04
    bne L3B_F658                                ; F653  D0 03
    jmp RoundIntroStep                          ; F655  4C D0 F6


L3B_F658:
    cmp #$06                                    ; F658  C9 06
    bne L3B_F65F                                ; F65A  D0 03
    jmp RoundEndStep                            ; F65C  4C E1 F7


L3B_F65F:
    bit a:RoundResult                           ; F65F  2C B9 00
    bmi RoundTimerTick                          ; F662  30 27
    lda a:FighterState                          ; F664  AD 26 00
    cmp #$E9                                    ; F667  C9 E9
    bcc L3B_F6CF                                ; F669  90 64
    bne L3B_F66F                                ; F66B  D0 02
    inc FighterWins                             ; F66D  E6 10
L3B_F66F:
    lda a:FighterState+1                        ; F66F  AD 27 00
    cmp #$E9                                    ; F672  C9 E9
    bcc L3B_F6CF                                ; F674  90 59
    bne L3B_F67A                                ; F676  D0 02
    inc FighterWins+1                           ; F678  E6 11
L3B_F67A:
    lda #$00                                    ; F67A  A9 00
    sta a:RoundStepTimer                        ; F67C  8D B7 00
    lda #$80                                    ; F67F  A9 80
    sta a:RoundStep                             ; F681  8D B6 00
    lda #$06                                    ; F684  A9 06
    sta ScreenMode                              ; F686  85 B0
    jmp L3B_F8D3                                ; F688  4C D3 F8


; modos: luta
RoundTimerTick:
    lda FrameCounter                            ; F68B  A5 B1       o relogio desce 1 a cada 32 quadros
    and #$1F                                    ; F68D  29 1F
    bne L3B_F6CF                                ; F68F  D0 3E
    dec a:TimerOnes                             ; F691  CE BA 00
    bpl L3B_F6CF                                ; F694  10 39
    ldx a:TimerTens                             ; F696  AE BB 00
    bne L3B_F6C6                                ; F699  D0 2B
    ldy a:TimerOff                              ; F69B  AC B5 00
    bne L3B_F6CA                                ; F69E  D0 2A
    lda FighterHP                               ; F6A0  A5 0E       tempo esgotado: compara a energia dos dois
    sec                                         ; F6A2  38
    sbc a:FighterDmgPending                     ; F6A3  ED 14 00
    bpl L3B_F6AA                                ; F6A6  10 02
    lda #$00                                    ; F6A8  A9 00       (nt)
L3B_F6AA:
    sta zp_D5                                   ; F6AA  85 D5
    lda FighterHP+1                             ; F6AC  A5 0F
    sec                                         ; F6AE  38
    sbc a:FighterDmgPending+1                   ; F6AF  ED 15 00
    bpl L3B_F6B6                                ; F6B2  10 02
    lda #$00                                    ; F6B4  A9 00       (nt)
L3B_F6B6:
    cmp zp_D5                                   ; F6B6  C5 D5
    bcc L3B_F6BF                                ; F6B8  90 05
    beq L3B_F6BD                                ; F6BA  F0 01
    dey                                         ; F6BC  88
L3B_F6BD:
    iny                                         ; F6BD  C8
    iny                                         ; F6BE  C8
L3B_F6BF:
    sty a:RoundResult                           ; F6BF  8C B9 00
    stx a:TimerOnes                             ; F6C2  8E BA 00
    rts                                         ; F6C5  60


L3B_F6C6:
    dex                                         ; F6C6  CA
    stx a:TimerTens                             ; F6C7  8E BB 00
L3B_F6CA:
    lda #$09                                    ; F6CA  A9 09
    sta a:TimerOnes                             ; F6CC  8D BA 00
L3B_F6CF:
    rts                                         ; F6CF  60


; <- jmp RoundLogic
; modos: intro do round
RoundIntroStep:
    ldx a:RoundStep                             ; F6D0  AE B6 00
    cpx #$08                                    ; F6D3  E0 08
    bcc L3B_F6DC                                ; F6D5  90 05
    dex                                         ; F6D7  CA
    stx a:RoundStep                             ; F6D8  8E B6 00
    rts                                         ; F6DB  60


L3B_F6DC:
    dec a:RoundStepTimer                        ; F6DC  CE B7 00
    bpl L3B_F71C                                ; F6DF  10 3B
    dex                                         ; F6E1  CA
    stx a:RoundStep                             ; F6E2  8E B6 00
    bpl L3B_F6F2                                ; F6E5  10 0B
    lda #$05                                    ; F6E7  A9 05
    sta ScreenMode                              ; F6E9  85 B0
    lda #$01                                    ; F6EB  A9 01
    sta FrameCounter                            ; F6ED  85 B1
    jmp L3B_F8E6                                ; F6EF  4C E6 F8


L3B_F6F2:
    ldy D3B_F7D9,x                              ; F6F2  BC D9 F7    [idx $00..$06]
    dey                                         ; F6F5  88
    sty a:RoundStepTimer                        ; F6F6  8C B7 00
    cpx #$06                                    ; F6F9  E0 06
    bne L3B_F705                                ; F6FB  D0 08
    lda #$00                                    ; F6FD  A9 00       voz 0 = "ROUND"
    sta VoiceQueued                             ; F6FF  8D 5E 04
    jmp L3B_F71C                                ; F702  4C 1C F7


L3B_F705:
    cpx #$05                                    ; F705  E0 05
    bne L3B_F713                                ; F707  D0 0A
    ldx a:RoundNumber                           ; F709  AE B8 00    vozes 1..3 = numero do round
    inx                                         ; F70C  E8
    stx VoiceQueued                             ; F70D  8E 5E 04
    jmp L3B_F71C                                ; F710  4C 1C F7


L3B_F713:
    cpx #$03                                    ; F713  E0 03
    bne L3B_F71C                                ; F715  D0 05
    lda #$05                                    ; F717  A9 05       voz 5 = "FIGHT"
    sta VoiceQueued                             ; F719  8D 5E 04

; <- jmp L3B_F6F2, jmp L3B_F705
; modos: intro do round
L3B_F71C:
    lda a:RoundNumber                           ; F71C  AD B8 00
    asl a                                       ; F71F  0A
    asl a                                       ; F720  0A
    asl a                                       ; F721  0A
    adc a:RoundStep                             ; F722  6D B6 00
    asl a                                       ; F725  0A
    tax                                         ; F726  AA
    lda D3B_F799,x                              ; F727  BD 99 F7    [idx $00..$3C]
    sta zp_D9                                   ; F72A  85 D9
    lda D3B_F799+1,x                            ; F72C  BD 9A F7    [idx $00..$3C]
    sta zp_DA                                   ; F72F  85 DA
    lda #$20                                    ; F731  A9 20
    ora #$80                                    ; F733  09 80
    sta MMC5_PRG_8000                           ; F735  8D 14 51
    ldy #$00                                    ; F738  A0 00
    lda (zp_D9),y                               ; F73A  B1 D9       [le bancos $20]
    sta MMC5_CHR_SPR5                           ; F73C  8D 25 51
    iny                                         ; F73F  C8
    ldx OamIndex                                ; F740  A6 AD
    lda #$64                                    ; F742  A9 64
    sta zp_DB                                   ; F744  85 DB
    lda #$70                                    ; F746  A9 70
    sta zp_DC                                   ; F748  85 DC
    lda #$00                                    ; F74A  A9 00
    sta zp_DD                                   ; F74C  85 DD
    lda #$01                                    ; F74E  A9 01
    sta zp_E1                                   ; F750  85 E1
    sta zp_E4                                   ; F752  85 E4
    jsr DrawMetasprite                          ; F754  20 EA F2
    lda #$01                                    ; F757  A9 01
    sta OamBuf+2,x                              ; F759  9D 02 02
    sta OamBuf+6,x                              ; F75C  9D 06 02
    lda #$6F                                    ; F75F  A9 6F
    sta OamBuf,x                                ; F761  9D 00 02
    sta OamBuf+4,x                              ; F764  9D 04 02
    lda #$94                                    ; F767  A9 94
    sta OamBuf+3,x                              ; F769  9D 03 02
    lda #$9C                                    ; F76C  A9 9C
    sta OamBuf+7,x                              ; F76E  9D 07 02
    lda zp_B3                                   ; F771  A5 B3
    asl a                                       ; F773  0A
    adc #$01                                    ; F774  69 01
    sta OamBuf+1,x                              ; F776  9D 01 02
    lda zp_B2                                   ; F779  A5 B2
    asl a                                       ; F77B  0A
    adc #$01                                    ; F77C  69 01
    sta OamBuf+5,x                              ; F77E  9D 05 02
    txa                                         ; F781  8A
    axs #$F8                                    ; F782  CB F8
    lda #$5C                                    ; F784  A9 5C
    sta zp_DB                                   ; F786  85 DB
    lda #$80                                    ; F788  A9 80
    sta zp_DC                                   ; F78A  85 DC
    lda #<D20_8469                              ; F78C  A9 69
    sta zp_D9                                   ; F78E  85 D9
    lda #>D20_8469                              ; F790  A9 84
    sta zp_DA                                   ; F792  85 DA
    ldy #$01                                    ; F794  A0 01
    jmp DrawMetasprite                          ; F796  4C EA F2

D3B_F799:
    .word D20_84C6                              ; F799  C6 84
    .word D20_84B9                              ; F79B  B9 84
    .word D20_84AC                              ; F79D  AC 84
    .word D20_8574                              ; F79F  74 85
    .word D20_8580                              ; F7A1  80 85
    .word D20_858E                              ; F7A3  8E 85
    .word D20_8580                              ; F7A5  80 85
    .word D20_8574                              ; F7A7  74 85       (inferido)
    .word D20_84C6                              ; F7A9  C6 84
    .word D20_84B9                              ; F7AB  B9 84
    .word D20_84AC                              ; F7AD  AC 84
    .word D20_8574                              ; F7AF  74 85
    .word D20_8580                              ; F7B1  80 85
    .word D20_859E                              ; F7B3  9E 85
    .word D20_8580                              ; F7B5  80 85
    .word D20_8574                              ; F7B7  74 85       (inferido)
    .word D20_84C6                              ; F7B9  C6 84
    .word D20_84B9                              ; F7BB  B9 84
    .word D20_84AC                              ; F7BD  AC 84
    .word D20_8574                              ; F7BF  74 85
    .word D20_8580                              ; F7C1  80 85
    .word D20_85AE                              ; F7C3  AE 85
    .word D20_8580                              ; F7C5  80 85
    .word D20_8574                              ; F7C7  74 85       (inferido)
    .word D20_84C6                              ; F7C9  C6 84
    .word D20_84B9                              ; F7CB  B9 84
    .word D20_84AC                              ; F7CD  AC 84
    .word D20_8574                              ; F7CF  74 85
    .word D20_8580                              ; F7D1  80 85
    .word D20_85BE                              ; F7D3  BE 85
    .word D20_8580                              ; F7D5  80 85
    .byte $74,$85                               ; F7D7
D3B_F7D9:
    .byte $40,$01,$01,$02,$02,$50,$02,$02       ; F7D9

; <- jmp L3B_F658
; modos: fim do round
RoundEndStep:
    lda FrameCounter                            ; F7E1  A5 B1
    and #$07                                    ; F7E3  29 07
    bne L3B_F7F0                                ; F7E5  D0 09
    ldx ram_0460                                ; F7E7  AE 60 04
    beq L3B_F7F0                                ; F7EA  F0 04
    dex                                         ; F7EC  CA
    stx ram_0460                                ; F7ED  8E 60 04
L3B_F7F0:
    lda a:TimerOff                              ; F7F0  AD B5 00
    ora a:TimerOnes                             ; F7F3  0D BA 00
    ora a:TimerTens                             ; F7F6  0D BB 00
    bne L3B_F819                                ; F7F9  D0 1E
    ldy a:RoundStepTimer                        ; F7FB  AC B7 00
    cpy #$40                                    ; F7FE  C0 40
    bcs L3B_F819                                ; F800  B0 17
    iny                                         ; F802  C8
    sty a:RoundStepTimer                        ; F803  8C B7 00
    lda #<D20_85CE                              ; F806  A9 CE
    sta zp_D9                                   ; F808  85 D9
    lda #>D20_85CE                              ; F80A  A9 85
    sta zp_DA                                   ; F80C  85 DA
    lda #$70                                    ; F80E  A9 70
    sta zp_DB                                   ; F810  85 DB
    lda #$70                                    ; F812  A9 70
    sta zp_DC                                   ; F814  85 DC
    jmp L3B_F8B5                                ; F816  4C B5 F8


L3B_F819:
    ldy a:RoundStep                             ; F819  AC B6 00
    bne L3B_F81F                                ; F81C  D0 01
    rts                                         ; F81E  60          (nt)


L3B_F81F:
    dey                                         ; F81F  88
    sty a:RoundStep                             ; F820  8C B6 00
    ldx a:RoundResult                           ; F823  AE B9 00    RoundResult: 0 = P1 venceu, 1 = P2 venceu, 2 = empate, $FF = luta em andamento
    cpx #$02                                    ; F826  E0 02
    beq L3B_F887                                ; F828  F0 5D
    cpy #$7F                                    ; F82A  C0 7F
    bne L3B_F833                                ; F82C  D0 05
    lda #$06                                    ; F82E  A9 06       voz 6 = "YOU"
    sta VoiceQueued                             ; F830  8D 5E 04
L3B_F833:
    lda FighterIsCpu,x                          ; F833  B5 02
    bne L3B_F86B                                ; F835  D0 34
    lda FighterHP,x                             ; F837  B5 0E
    cmp #$58                                    ; F839  C9 58
    beq L3B_F84D                                ; F83B  F0 10
L3B_F83D:
    cpy #$7E                                    ; F83D  C0 7E
    bne L3B_F846                                ; F83F  D0 05
    lda #$07                                    ; F841  A9 07       voz 7 = "WIN"
    sta VoiceQueued                             ; F843  8D 5E 04
L3B_F846:
    lda #<D20_85EA                              ; F846  A9 EA
    ldx #>D20_85EA                              ; F848  A2 85
    jmp L3B_F85C                                ; F84A  4C 5C F8


L3B_F84D:
    cpy #$40                                    ; F84D  C0 40
    bcc L3B_F858                                ; F84F  90 07
    bne L3B_F83D                                ; F851  D0 EA
    lda #$09                                    ; F853  A9 09       voz 9 = "PERFECT" (vencedor humano com energia cheia, $58)
    sta VoiceQueued                             ; F855  8D 5E 04
L3B_F858:
    lda #<D20_852B                              ; F858  A9 2B
    ldx #>D20_852B                              ; F85A  A2 85

; <- jmp L3B_F81F
; modos: fim do round
L3B_F85C:
    sta zp_D9                                   ; F85C  85 D9
    stx zp_DA                                   ; F85E  86 DA
    lda #$64                                    ; F860  A9 64
    sta zp_DB                                   ; F862  85 DB
    lda #$70                                    ; F864  A9 70
    sta zp_DC                                   ; F866  85 DC
    jmp L3B_F8B5                                ; F868  4C B5 F8


L3B_F86B:
    cpy #$7E                                    ; F86B  C0 7E
    bne L3B_F874                                ; F86D  D0 05
    lda #$08                                    ; F86F  A9 08       voz 8 = "LOSE" (o vencedor e' a CPU)
    sta VoiceQueued                             ; F871  8D 5E 04
L3B_F874:
    lda #<D20_85D9                              ; F874  A9 D9
    sta zp_D9                                   ; F876  85 D9
    lda #>D20_85D9                              ; F878  A9 85
    sta zp_DA                                   ; F87A  85 DA
    lda #$60                                    ; F87C  A9 60
    sta zp_DB                                   ; F87E  85 DB
    lda #$70                                    ; F880  A9 70
    sta zp_DC                                   ; F882  85 DC
    jmp L3B_F8B5                                ; F884  4C B5 F8


L3B_F887:
    lda a:TimerOnes                             ; F887  AD BA 00
    ora a:TimerTens                             ; F88A  0D BB 00
    bne L3B_F8A2                                ; F88D  D0 13
    lda #<D20_84A1                              ; F88F  A9 A1
    sta zp_D9                                   ; F891  85 D9
    lda #>D20_84A1                              ; F893  A9 84
    sta zp_DA                                   ; F895  85 DA
    lda #$70                                    ; F897  A9 70
    sta zp_DB                                   ; F899  85 DB
    lda #$70                                    ; F89B  A9 70
    sta zp_DC                                   ; F89D  85 DC
    jmp L3B_F8B5                                ; F89F  4C B5 F8


L3B_F8A2:
    lda #<D20_848B                              ; F8A2  A9 8B       (nt)
    sta zp_D9                                   ; F8A4  85 D9       (nt)
    lda #>D20_848B                              ; F8A6  A9 84       (nt)
    sta zp_DA                                   ; F8A8  85 DA       (nt)
    lda #$68                                    ; F8AA  A9 68       (nt)
    sta zp_DB                                   ; F8AC  85 DB       (nt)
    lda #$70                                    ; F8AE  A9 70       (nt)
    sta zp_DC                                   ; F8B0  85 DC       (nt)
    jmp L3B_F8B5                                ; F8B2  4C B5 F8    (nt)


; <- jmp RoundEndStep, jmp L3B_F84D, jmp L3B_F86B, jmp L3B_F887, jmp L3B_F8A2
; modos: fim do round
L3B_F8B5:
    lda #$20                                    ; F8B5  A9 20
    ora #$80                                    ; F8B7  09 80
    sta MMC5_PRG_8000                           ; F8B9  8D 14 51
    ldy #$00                                    ; F8BC  A0 00
    lda (zp_D9),y                               ; F8BE  B1 D9       [le bancos $20]
    sta MMC5_CHR_SPR5                           ; F8C0  8D 25 51
    iny                                         ; F8C3  C8
    ldx OamIndex                                ; F8C4  A6 AD
    lda #$00                                    ; F8C6  A9 00
    sta zp_DD                                   ; F8C8  85 DD
    lda #$01                                    ; F8CA  A9 01
    sta zp_E1                                   ; F8CC  85 E1
    sta zp_E4                                   ; F8CE  85 E4
    jmp DrawMetasprite                          ; F8D0  4C EA F2


; <- jmp RoundInit, jmp L3B_F65F
; modos: intro do round, fim do round
L3B_F8D3:
    lda #$26                                    ; F8D3  A9 26
    sta a:PaletteBuf+15                         ; F8D5  8D CB 00
    lda #$28                                    ; F8D8  A9 28
    sta a:PaletteBuf+16                         ; F8DA  8D CC 00
    lda #$01                                    ; F8DD  A9 01
    sta a:PaletteBuf+17                         ; F8DF  8D CD 00
    sta a:PaletteDirty                          ; F8E2  8D D4 00
    rts                                         ; F8E5  60


; <- jmp L3B_F6DC
; modos: luta
L3B_F8E6:
    lda #$01                                    ; F8E6  A9 01
    sta a:PaletteDirty                          ; F8E8  8D D4 00
    lda ram_030C                                ; F8EB  AD 0C 03
    sta a:PaletteBuf+15                         ; F8EE  8D CB 00
    lda ram_030D                                ; F8F1  AD 0D 03
    sta a:PaletteBuf+16                         ; F8F4  8D CC 00
    lda ram_030E                                ; F8F7  AD 0E 03
    sta a:PaletteBuf+17                         ; F8FA  8D CD 00
    rts                                         ; F8FD  60

D3B_F8FE:
    .byte $36,$36,$36,$36,$36,$3A,$3A,$3A,$3A,$3A; F8FE

; <- jsr L3B_E455, jsr FadeIn, jsr FightFrame
; modos: intro do round, luta, fim do round
StageSplitSetup:
    lda #$0E                                    ; F908  A9 0E
    sta MMC5_CHR_BG1                            ; F90A  8D 29 51
    lda CameraX                                 ; F90D  AD B7 03
    sta ram_0400                                ; F910  8D 00 04
    ldy ram_03B8                                ; F913  AC B8 03
    sty ram_0401                                ; F916  8C 01 04
    ldy ram_03B9                                ; F919  AC B9 03
    sty ram_0402                                ; F91C  8C 02 04
    ldy #$00                                    ; F91F  A0 00
    sty IrqStage                                ; F921  8C FF 03
    lda ram_0403                                ; F924  AD 03 04
    sta MMC5_IRQ_LINE                           ; F927  8D 03 52
    lda #$80                                    ; F92A  A9 80
    sta MMC5_IRQ_STATUS                         ; F92C  8D 04 52
    jsr L3B_E689                                ; F92F  20 89 E6
    lda HitStop                                 ; F932  AD 0C 04
    beq L3B_F93F                                ; F935  F0 08
    sec                                         ; F937  38
    sbc #$01                                    ; F938  E9 01
    sta HitStop                                 ; F93A  8D 0C 04
    and #$01                                    ; F93D  29 01
L3B_F93F:
    rts                                         ; F93F  60


; <- jsr L3B_E455, jsr FadeIn, jsr FightFrame
; modos: intro do round, luta, fim do round
StageParallaxCalc:
    sec                                         ; F940  38
    lda CameraX                                 ; F941  AD B7 03
    sbc #$80                                    ; F944  E9 80
    sta zp_D5                                   ; F946  85 D5
    sta zp_D7                                   ; F948  85 D7
    lda #$00                                    ; F94A  A9 00
    sbc #$00                                    ; F94C  E9 00
    sta zp_D6                                   ; F94E  85 D6
    sta zp_D8                                   ; F950  85 D8
    lda zp_D7                                   ; F952  A5 D7
    asl a                                       ; F954  0A
    rol zp_D8                                   ; F955  26 D8
    asl a                                       ; F957  0A
    rol zp_D8                                   ; F958  26 D8
    clc                                         ; F95A  18
    adc zp_D5                                   ; F95B  65 D5
    sta zp_D7                                   ; F95D  85 D7
    lda zp_D8                                   ; F95F  A5 D8
    adc zp_D6                                   ; F961  65 D6
    sta zp_D8                                   ; F963  85 D8
    ldx #$00                                    ; F965  A2 00
L3B_F967:
    clc                                         ; F967  18
    lda zp_D7                                   ; F968  A5 D7
    adc zp_D5                                   ; F96A  65 D5
    sta zp_D5                                   ; F96C  85 D5
    lda zp_D8                                   ; F96E  A5 D8
    adc zp_D6                                   ; F970  65 D6
    sta zp_D6                                   ; F972  85 D6
    clc                                         ; F974  18
    lda zp_D5                                   ; F975  A5 D5
    adc ram_03B6                                ; F977  6D B6 03
    sta ram_03BF,x                              ; F97A  9D BF 03
    lda zp_D6                                   ; F97D  A5 D6
    adc CameraX                                 ; F97F  6D B7 03
    sta FloorScrollX,x                          ; F982  9D DF 03
    inx                                         ; F985  E8
    cpx FloorLines                              ; F986  EC BB 03
    bcc L3B_F967                                ; F989  90 DC
    rts                                         ; F98B  60

RleSupportScreen:
    .byte $11,$00,$11,$65,$D3,$D5,$D0,$D0,$CF,$D2,$D4,$00,$D4,$C8,$C9,$D3; F98C
    .byte $00,$D0,$D2,$CF,$CA,$C5,$C3,$D4,$00,$11,$6E,$01,$02,$02,$03,$01; F99C
    .byte $03,$04,$02,$05,$01,$06,$01,$02,$02,$03,$00,$11,$10,$03,$07,$03; F9AC
    .byte $03,$05,$08,$00,$09,$0A,$0B,$06,$03,$07,$03,$03,$00,$11,$10,$03; F9BC
    .byte $02,$0C,$03,$0D,$02,$0B,$0A,$0B,$05,$08,$03,$02,$0C,$03,$00,$11; F9CC
    .byte $10,$02,$11,$02,$06,$0B,$0A,$03,$0A,$0B,$0B,$03,$02,$11,$02,$06; F9DC
    .byte $00,$11,$10,$0B,$02,$04,$02,$0E,$0B,$04,$05,$0D,$0F,$08,$0B,$10; F9EC
    .byte $0D,$03,$00,$11,$10,$10,$08,$10,$0F,$0B,$09,$0D,$00,$01,$00,$03; F9FC
    .byte $05,$03,$02,$08,$00,$11,$11,$06,$05,$06,$05,$09,$06,$01,$05,$04; FA0C
    .byte $08,$09,$0D,$0B,$08,$00,$11,$10,$0D,$06,$0F,$0A,$05,$0D,$0D,$10; FA1C
    .byte $03,$04,$08,$0F,$03,$0F,$06,$00,$11,$10,$0E,$05,$01,$0A,$0D,$08; FA2C
    .byte $03,$01,$08,$01,$07,$0E,$0F,$05,$00,$11,$11,$06,$00,$0D,$0A,$0D; FA3C
    .byte $02,$0F,$01,$05,$0A,$06,$0D,$00,$03,$00,$11,$11,$0D,$06,$02,$06; FA4C
    .byte $08,$01,$0D,$06,$05,$03,$01,$02,$07,$0B,$08,$00,$11,$10,$01,$02; FA5C
    .byte $02,$03,$07,$0E,$0B,$0B,$0D,$10,$03,$06,$07,$0D,$08,$00,$11,$10; FA6C
    .byte $03,$07,$03,$03,$09,$02,$0B,$04,$05,$09,$07,$02,$0B,$02,$08,$00; FA7C
    .byte $11,$10,$03,$02,$0C,$03,$0F,$04,$0A,$03,$10,$00,$05,$04,$0E,$0A; FA8C
    .byte $06,$00,$11,$10,$02,$11,$02,$06,$02,$06,$00,$02,$00,$02,$06,$06; FA9C
    .byte $0D,$0D,$00,$11,$6E,$D0,$C1,$D4,$D2,$C5,$CF,$CE,$AE,$C3,$CF,$CD; FAAC
    .byte $AF,$D0,$C1,$D2,$C9,$D3,$CF,$C6,$D4,$00,$11,$C4,$00,$11,$00; FABC

; <- farcall ScreenSupport
; modos: aviso/QR
DrawSupportScreen:
    lda #$28                                    ; FACB  A9 28
    sta PPUADDR                                 ; FACD  8D 06 20
    lda #$00                                    ; FAD0  A9 00
    sta PPUADDR                                 ; FAD2  8D 06 20
    lda #<RleSupportScreen                      ; FAD5  A9 8C
    ldx #>RleSupportScreen                      ; FAD7  A2 F9
    jmp PpuUnRle                                ; FAD9  4C BE E3


; <- farcall ScreenTitle
; modos: titulo
DrawTitleScreen:
    lda #$28                                    ; FADC  A9 28
    sta PPUADDR                                 ; FADE  8D 06 20
    lda #$00                                    ; FAE1  A9 00
    sta PPUADDR                                 ; FAE3  8D 06 20
    lda #<RleTitleScreen                        ; FAE6  A9 ED
    ldx #>RleTitleScreen                        ; FAE8  A2 FA
    jmp PpuUnRle                                ; FAEA  4C BE E3

RleTitleScreen:
    .byte $F3,$00,$F3,$48,$01,$02,$03,$00,$F3,$1A,$04,$05,$06,$07,$08,$09; FAED
    .byte $0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$00,$F3,$0E,$15,$16; FAFD
    .byte $17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25,$26; FB0D
    .byte $00,$F3,$0D,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,$30,$31,$32,$33; FB1D
    .byte $34,$00,$00,$35,$36,$00,$F3,$0D,$37,$38,$39,$00,$3A,$3B,$3C,$3D; FB2D
    .byte $3E,$3F,$40,$41,$42,$43,$00,$44,$45,$00,$46,$47,$48,$00,$F3,$0A; FB3D
    .byte $49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$55,$56,$00,$00; FB4D
    .byte $57,$58,$59,$5A,$5B,$00,$F3,$08,$5C,$5D,$5E,$5F,$60,$61,$62,$63; FB5D
    .byte $64,$00,$65,$66,$67,$68,$69,$6A,$6B,$00,$6C,$6D,$6E,$6F,$00,$F3; FB6D
    .byte $08,$70,$71,$5F,$5F,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C; FB7D
    .byte $7D,$7E,$00,$F3,$02,$7F,$80,$00,$F3,$0A,$81,$82,$83,$84,$85,$86; FB8D
    .byte $00,$00,$87,$88,$89,$8A,$8B,$8C,$8D,$8E,$8F,$00,$00,$90,$91,$00; FB9D
    .byte $F3,$0A,$92,$93,$94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F; FBAD
    .byte $A0,$A1,$A2,$00,$00,$A3,$A4,$00,$F3,$0A,$A5,$A6,$A7,$A8,$A9,$AA; FBBD
    .byte $AB,$AC,$AD,$AE,$AF,$B0,$B1,$B2,$B3,$B4,$B5,$00,$B6,$B7,$B8,$00; FBCD
    .byte $F3,$0A,$B9,$BA,$BB,$BC,$BD,$BE,$BF,$C0,$C1,$C2,$C3,$C4,$C5,$5F; FBDD
    .byte $C6,$C7,$C8,$00,$C9,$CA,$CB,$00,$F3,$0A,$CC,$CD,$CE,$CF,$D0,$D1; FBED
    .byte $D2,$D3,$D4,$D5,$D6,$D7,$D8,$D9,$00,$DA,$DB,$DC,$DD,$DE,$DF,$E0; FBFD
    .byte $E1,$00,$F3,$08,$E2,$E3,$00,$E4,$E5,$00,$E6,$E7,$E8,$E9,$EA,$00; FC0D
    .byte $EB,$EC,$00,$00,$ED,$EE,$EF,$F0,$F1,$00,$F3,$0B,$F2,$00,$F3,$3F; FC1D
    .byte $62,$64,$6C,$6E,$48,$5E,$54,$58,$4C,$00,$00,$50,$4E,$58,$6E,$58; FC2D
    .byte $64,$62,$00,$F3,$0D,$63,$65,$6D,$6F,$49,$5F,$55,$59,$4D,$00,$00; FC3D
    .byte $51,$4F,$59,$6F,$59,$65,$63,$00,$F3,$FE,$00,$F3,$67,$50,$F3,$07; FC4D
    .byte $AA,$F3,$0F,$0A,$F3,$06,$0A,$F3,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF; FC5D

.ifdef FIX_SOFT_RESET
__alt_3B_FC6D:
ResetStub:
    lda #$00
    sta MMC5_IRQ_STATUS
    lda #$BF
    sta MMC5_PRG_E000
    jmp $FF9F
    .assert * - __alt_3B_FC6D <= $F, error, "bloco alt FIX_SOFT_RESET em $FC6D passou do tamanho"
    .res $F - (* - __alt_3B_FC6D), $FF
.else
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; FC6D
.endif


.assert * = $FC7C, error, "o kernel precisa comecar em $FC7C"
.include "kernel.inc"

    .byte $FF,$FF,$FF,$FF                       ; FF9B
D3B_FF9F:
    .res 91, $FF                                ; FF9F
    .word NmiHandler                            ; FFFA  1E FE

.ifdef FIX_SOFT_RESET
__alt_3B_FFFC:
    .word ResetStub
    .assert * - __alt_3B_FFFC <= $2, error, "bloco alt FIX_SOFT_RESET em $FFFC passou do tamanho"
    .res $2 - (* - __alt_3B_FFFC), $FF
.else
    .word D3B_FF9F                              ; FFFC  9F FF
.endif

    .word IrqHandler                            ; FFFE  7C FC
