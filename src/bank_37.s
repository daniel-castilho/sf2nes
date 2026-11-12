; GERADO por tools/disasm.py — nao edite a mao enquanto estiver na fase de anotacao.
; Edite annotations/sf2ne.ann e rode `make gen`.  (nt) = instrucao nao executada no trace.
;
; Banco de PRG $37 (CODIGO) — janela $E000-$FFFF — offset no arquivo $06E010
;
.include "defs.inc"
.segment "BANK37"

; ------------------------------------------------------------------------------------------------
; DIRETORIO DE VOZES (DPCM): 32 amostras. VoiceBankTbl[i] = banco de PRG mapeado em $C000;
; VoiceSampleTbl+3+3*i = endereco/64, (tamanho-1)/16, taxa  (tabela de amostras no formato FamiTone2).
VoiceBankTbl:
    .byte $16,$16,$16,$16,$00,$0A,$0A,$0A,$0A,$12,$22,$22,$26,$22,$2A,$2A; E000
    .byte $02,$1A,$1A,$06,$06,$06,$02,$02,$1E,$0E,$0E,$0E,$12; E010
VoiceSampleTbl:
    .byte $12,$1E,$1E,$00,$C0,$0F,$31,$5C,$0F,$49,$61,$0F,$62,$6A,$0F,$00; E01D
    .byte $00,$00,$00,$5F,$0F,$18,$96,$0F,$3E,$5C,$0F,$56,$9F,$0F,$00,$62; E02D
    .byte $0F,$00,$C0,$0F,$31,$A8,$0F,$00,$C7,$0F,$5C,$85,$0F,$00,$FF,$0F; E03D
    .byte $40,$FF,$0F,$51,$95,$0F,$40,$92,$0F,$00,$FF,$0F,$56,$86,$0F,$00; E04D
    .byte $A3,$0F,$29,$B2,$0F,$00,$90,$0F,$25,$AE,$0F,$61,$55,$0F,$45,$63; E05D
    .byte $0F,$37,$35,$0F,$00,$DB,$0F,$19,$D2,$0F,$4E,$B8,$0F,$00,$C3,$0F; E06D
    .byte $31,$BF,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; E07D
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; E08D
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; E09D
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; E0AD
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; E0BD
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; E0CD
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; E0DD
    .byte $00,$00                               ; E0ED
CountryVoiceTbl:
    .byte $0A,$0C,$0D,$0C,$0B,$0A,$0C,$0F,$0F,$0E; E0EF              voz (nome do pais) de cada um dos 10 personagens na tela de selecao
FighterVoiceTbl:
    .byte $18                                   ; E0F9              16 bytes por personagem: pares (amostra, continuacao) para cada voz; $FF = nenhuma
D37_E0FA:
    .byte $FF,$1B,$FF,$1B,$FF,$1C,$1D,$1C,$1D,$1E,$1F,$1E,$1F,$FF,$FF,$18; E0FA
    .byte $FF,$1B,$FF,$1B,$FF,$1C,$1D,$1C,$1D,$1E,$1F,$1E,$1F,$FF,$FF,$19; E10A
    .res 47, $FF                                ; E11A
    .byte $18                                   ; E149
    .res 31, $FF                                ; E14A
    .byte $1A                                   ; E169
    .res 31, $FF                                ; E16A
    .byte $18,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; E189
D37_E199:
    .byte $02,$03,$04,$02,$03,$04               ; E199
SfxChannelOfs:
    .byte $00,$0F,$1E,$2D                       ; E19F
SfxData:
    .word D37_E1A7                              ; E1A3  A7 E1       efeitos sonoros no formato FamiTone2 (lista de ponteiros + fluxos de escrita na APU)
    .word D37_E1A7                              ; E1A5  A7 E1       (inferido)
D37_E1A7:
    .word D37_E1BD                              ; E1A7  BD E1
    .word D37_E1EC                              ; E1A9  EC E1
    .word D37_E20C                              ; E1AB  0C E2
    .word D37_E212                              ; E1AD  12 E2       (inferido)
    .word D37_E244                              ; E1AF  44 E2
    .word D37_E289                              ; E1B1  89 E2
    .word D37_E2A3                              ; E1B3  A3 E2       (inferido)
    .word D37_E2B1                              ; E1B5  B1 E2
    .word D37_E2FC                              ; E1B7  FC E2       (inferido)
    .word D37_E328                              ; E1B9  28 E3
    .byte $75,$E3                               ; E1BB
D37_E1BD:
    .byte $83,$B9,$84,$08,$85,$06,$89,$34,$8A,$0A,$01,$84,$C6,$8A,$0B,$01; E1BD
    .byte $83,$30,$89,$30,$01,$83,$B9,$84,$2D,$85,$07,$89,$39,$8A,$07,$01; E1CD
    .byte $84,$C6,$85,$06,$8A,$08,$01,$84,$08,$8A,$09,$01,$83,$30,$00; E1DD
D37_E1EC:
    .byte $89,$3F,$8A,$07,$01,$8A,$0B,$01,$89,$30,$01,$89,$3C,$8A,$0C,$01; E1EC
    .byte $89,$3A,$01,$89,$38,$01,$89,$36,$01,$89,$30,$01,$89,$35,$02,$00; E1FC
D37_E20C:
    .byte $89,$3F,$8A,$02,$04,$00               ; E20C
D37_E212:
    .byte $89,$32,$8A,$07,$01,$89,$35,$01,$89,$37,$01,$89,$3A,$01,$89,$3C; E212
    .byte $01,$89,$39,$8A,$08,$01,$89,$37,$8A,$09,$01,$89,$34,$8A,$0A,$01; E222
    .byte $89,$31,$8A,$0B,$01,$89,$35,$01,$89,$31,$01,$89,$33,$01,$89,$31; E232
    .byte $01,$00                               ; E242
D37_E244:
    .byte $83,$B7,$84,$CD,$85,$03,$01,$83,$BA,$84,$E6,$89,$32,$8A,$0B,$01; E244
    .byte $83,$BC,$84,$FE,$89,$34,$8A,$0A,$01,$83,$BF,$84,$16,$85,$04,$89; E254
    .byte $36,$8A,$09,$01,$89,$38,$8A,$08,$01,$83,$B5,$89,$3A,$8A,$07,$01; E264
    .byte $83,$B1,$89,$3C,$8A,$06,$01,$83,$30,$89,$36,$8A,$02,$01,$89,$34; E274
    .byte $02,$89,$32,$02,$00                   ; E284
D37_E289:
    .byte $89,$3F,$8A,$03,$01,$8A,$09,$01,$89,$30,$01,$89,$3C,$8A,$04,$01; E289
    .byte $89,$3A,$01,$89,$38,$01,$89,$36,$01,$00; E299
D37_E2A3:
    .byte $89,$3F,$8A,$0A,$03,$89,$30,$01,$89,$3F,$8A,$05,$06,$00; E2A3
D37_E2B1:
    .byte $83,$BF,$84,$AD,$85,$05,$89,$3F,$8A,$0C,$01,$84,$D4,$85,$02,$01; E2B1
    .byte $84,$5B,$85,$05,$89,$30,$01,$84,$AB,$85,$02,$89,$3F,$8A,$0F,$01; E2C1
    .byte $84,$0E,$85,$05,$01,$84,$84,$85,$02,$89,$3D,$8A,$0B,$01,$84,$3F; E2D1
    .byte $85,$04,$01,$83,$30,$89,$3C,$01,$89,$3A,$01,$89,$39,$01,$89,$38; E2E1
    .byte $01,$89,$37,$01,$89,$35,$01,$89,$31,$04,$00; E2F1
D37_E2FC:
    .byte $83,$BF,$84,$44,$85,$04,$89,$3C,$8A,$0C,$01,$84,$85,$89,$37,$8A; E2FC
    .byte $08,$01,$84,$CA,$01,$83,$30,$89,$36,$04,$89,$35,$04,$89,$34,$8A; E30C
    .byte $01,$01,$89,$33,$02,$89,$32,$01,$89,$31,$02,$00; E31C
D37_E328:
    .byte $86,$81,$87,$0C,$88,$01,$89,$3F,$8A,$06,$01,$87,$FB,$89,$38,$8A; E328
    .byte $07,$01,$87,$5B,$88,$02,$89,$36,$8A,$09,$01,$86,$00,$01,$86,$81; E338
    .byte $87,$C3,$88,$01,$01,$87,$FB,$01,$86,$00,$89,$34,$01,$86,$81,$87; E348
    .byte $DE,$01,$86,$00,$89,$33,$01,$86,$81,$87,$AA,$89,$32,$01,$86,$00; E358
    .byte $89,$31,$01,$86,$81,$87,$19,$88,$02,$01,$86,$00,$00,$86,$81,$87; E368
    .byte $03,$88,$02,$89,$3F,$8A,$0F,$04,$86,$00,$89,$30,$03,$86,$81,$87; E378
    .byte $CB,$88,$01,$89,$3F,$8A,$0E,$06,$89,$30,$02,$00; E388

; <- jmp K_FE93
; modos: titulo
TitleDrawPushStart:
    lda #$2A                                    ; E394  A9 2A       restaura as 11 cores do PRESS START no PPU ($2ACB) durante o fade do titulo
    sta PPUADDR                                 ; E396  8D 06 20
    lda #$CB                                    ; E399  A9 CB
    sta PPUADDR                                 ; E39B  8D 06 20
    lda FadePalette+11                          ; E39E  AD 90 04
    sta PPUDATA                                 ; E3A1  8D 07 20
    lda FadePalette+12                          ; E3A4  AD 91 04
    sta PPUDATA                                 ; E3A7  8D 07 20
    lda FadePalette+13                          ; E3AA  AD 92 04
    sta PPUDATA                                 ; E3AD  8D 07 20
    lda FadePalette+14                          ; E3B0  AD 93 04
    sta PPUDATA                                 ; E3B3  8D 07 20
    lda FadePalette+15                          ; E3B6  AD 94 04
    sta PPUDATA                                 ; E3B9  8D 07 20
    lda FadePalette+16                          ; E3BC  AD 95 04
    sta PPUDATA                                 ; E3BF  8D 07 20
    lda FadePalette+17                          ; E3C2  AD 96 04
    sta PPUDATA                                 ; E3C5  8D 07 20
    lda FadePalette+18                          ; E3C8  AD 97 04
    sta PPUDATA                                 ; E3CB  8D 07 20
    lda FadePalette+19                          ; E3CE  AD 98 04
    sta PPUDATA                                 ; E3D1  8D 07 20
    lda FadePalette+20                          ; E3D4  AD 99 04
    sta PPUDATA                                 ; E3D7  8D 07 20
    lda #$00                                    ; E3DA  A9 00
    sta FadePalette+10                          ; E3DC  8D 8F 04
    rts                                         ; E3DF  60


; Carrega musica: MusicBank = banco (mapeado em $A000), zp_D5/zp_D6 = ponteiro dos dados (FamiTone2).
; <- farcall SelectInit, farcall ScreenTitle, farcall VersusDraw, farcall ScreenWinQuote, farcall Match
; modos: titulo, selecao, VS, intro do round, frase final
SoundLoadSong:
    lda MusicBank                               ; E3E0  AD 5F 04
    ora #$80                                    ; E3E3  09 80
    sta MMC5_PRG_A000                           ; E3E5  8D 15 51
    ldx zp_D5                                   ; E3E8  A6 D5
    ldy zp_D6                                   ; E3EA  A4 D6
    jsr FamiToneInit                            ; E3EC  20 86 E4
    jsr SoundInitSfx                            ; E3EF  20 FA E3
    jsr SoundInitVoices                         ; E3F2  20 1B E4
    lda #$00                                    ; E3F5  A9 00
    jmp FamiToneMusicPlay                       ; E3F7  4C 19 E5


; <- jsr SoundLoadSong
; modos: titulo, selecao, VS, intro do round, frase final
SoundInitSfx:
    ldx #<SfxData                               ; E3FA  A2 A3
    ldy #>SfxData                               ; E3FC  A0 E1
    jmp FamiToneSfxInit                         ; E3FE  4C 76 ED


; <- farcall StateAdvance, farcall SoundProc_EEB8, farcall MoveGrabEscape
; modos: luta
SfxPlay:
    ldy zp_DC                                   ; E401  A4 DC
    ldx SfxChannelOfs,y                         ; E403  BE 9F E1    [idx $00..$01]
    lda zp_DB                                   ; E406  A5 DB
    jmp FamiToneSfxPlay                         ; E408  4C B0 ED


; <- farjmp StateSetByte
; modos: luta
SfxPlayByState:
    ldx zp_DC                                   ; E40B  A6 DC       efeito sonoro por classe de estado: canal em D37_E199[x], sfx em SfxChannelOfs[estado]
    lda D37_E199,x                              ; E40D  BD 99 E1    [idx $00..$05]
    ldy zp_DB                                   ; E410  A4 DB
    ldx SfxChannelOfs,y                         ; E412  BE 9F E1    [idx $00..$01]
    jsr FamiToneSfxPlay                         ; E415  20 B0 ED
    ldx zp_DB                                   ; E418  A6 DB
    rts                                         ; E41A  60


; <- jsr SoundLoadSong
; modos: titulo, selecao, VS, intro do round, frase final
SoundInitVoices:
    lda #$FF                                    ; E41B  A9 FF
    sta VoiceQueued                             ; E41D  8D 5E 04
    ldx #<VoiceSampleTbl                        ; E420  A2 1D
    ldy #>VoiceSampleTbl                        ; E422  A0 E0
    jmp FtSetSampleTable                        ; E424  4C 7F E4


; <- jsr VoicePlayFighter, jsr SoundUpdate, farcall L37_F076, farjmp L37_F281, farcall StateAdvance
; modos: titulo, selecao, intro do round, luta, fim do round
VoicePlay:
    ldx VoiceQueued                             ; E427  AE 5E 04    troca o banco em $C000 para o da amostra e dispara o canal DMC
    lda VoiceBankTbl,x                          ; E42A  BD 00 E0    [idx $00..$1F]
    ora #$80                                    ; E42D  09 80
    sta MMC5_PRG_C000                           ; E42F  8D 16 51
    lda #$FF                                    ; E432  A9 FF
    sta VoiceQueued                             ; E434  8D 5E 04
    inx                                         ; E437  E8
    txa                                         ; E438  8A
    jmp FamiToneSamplePlay                      ; E439  4C 3C ED


; <- farjmp ScreenConfig
; modos: luta
VoicePlayFighter:
    ldx zp_DB                                   ; E43C  A6 DB
    lda FighterChar,x                           ; E43E  B5 00
    asl a                                       ; E440  0A
    asl a                                       ; E441  0A
    asl a                                       ; E442  0A
    asl a                                       ; E443  0A
    adc zp_DC                                   ; E444  65 DC
    tay                                         ; E446  A8
    lda FighterVoiceTbl,y                       ; E447  B9 F9 E0    [idx $00..$0C]
    bmi L37_E45E                                ; E44A  30 12
    sty zp_DC                                   ; E44C  84 DC
    sta VoiceQueued                             ; E44E  8D 5E 04
    jsr VoicePlay                               ; E451  20 27 E4
    ldx zp_DB                                   ; E454  A6 DB
    ldy zp_DC                                   ; E456  A4 DC
    lda D37_E0FA,y                              ; E458  B9 FA E0    [idx $00..$0C]
    sta VoiceQueued                             ; E45B  8D 5E 04
L37_E45E:
    rts                                         ; E45E  60


; Chamado uma vez por quadro em todas as telas: encadeia a 2a metade de uma voz, mapeia a musica e roda o FamiTone2.
; <- jmp SoundStopMusic, farcall L37_EFD0, farcall SelectFighterIntro, farcall ScreenTitle, farcall VersusDraw, farcall L3B_EC83 ... (+2)
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
SoundUpdate:
    lda VoiceQueued                             ; E45F  AD 5E 04
    bmi L37_E46E                                ; E462  30 0A
    lda SND_CHN                                 ; E464  AD 15 40
    and #$10                                    ; E467  29 10
    bne L37_E46E                                ; E469  D0 03
    jsr VoicePlay                               ; E46B  20 27 E4
L37_E46E:
    lda MusicBank                               ; E46E  AD 5F 04
    ora #$80                                    ; E471  09 80
    sta MMC5_PRG_A000                           ; E473  8D 15 51
    jmp FamiToneUpdate                          ; E476  4C D0 E5


; <- farcall SelectWaitEnd, farcall L37_F652, farcall VersusDraw, farcall L3B_EC83, farcall FightFrame
; modos: titulo, selecao, VS, fim do round, frase final
SoundStopMusic:
    jsr FamiToneMusicStop                       ; E479  20 DB E4
    jmp SoundUpdate                             ; E47C  4C 5F E4


; <- jmp SoundInitVoices
; modos: titulo, selecao, VS, intro do round, frase final
FtSetSampleTable:
    stx FT_DPCM_LIST_L                          ; E47F  8E 7C 01
    sty FT_DPCM_LIST_H                          ; E482  8C 7D 01
    rts                                         ; E485  60


; ------------------------------------------------------------------------------------------------
; FamiTone2 (Shiru), versao do autor (familib/src/ft2) com extensoes (slides de afinacao).
; Variaveis em $0100-$018B (FT_BASE_ADR = $0100) + $046B-$047E.
; <- jsr SoundLoadSong
; modos: titulo, selecao, VS, intro do round, frase final
FamiToneInit:
    stx FT_SONG_LIST_L                          ; E486  8E 74 01
    sty FT_SONG_LIST_H                          ; E489  8C 75 01
    stx FT_TEMP_PTR_L                           ; E48C  86 83
    sty FT_TEMP_PTR_H                           ; E48E  84 84
    jsr FamiToneMusicStop                       ; E490  20 DB E4
    ldy #$01                                    ; E493  A0 01
    lda (FT_TEMP_PTR_L),y                       ; E495  B1 83       [le bancos $29,$2D]
    sta FT_INSTRUMENT_L                         ; E497  8D 76 01
    iny                                         ; E49A  C8
    lda (FT_TEMP_PTR_L),y                       ; E49B  B1 83       [le bancos $29,$2D]
    sta FT_INSTRUMENT_H                         ; E49D  8D 77 01
    iny                                         ; E4A0  C8
    lda (FT_TEMP_PTR_L),y                       ; E4A1  B1 83       [le bancos $29,$2D]
    sta FT_DPCM_LIST_L                          ; E4A3  8D 7C 01
    iny                                         ; E4A6  C8
    lda (FT_TEMP_PTR_L),y                       ; E4A7  B1 83       [le bancos $29,$2D]
    sta FT_DPCM_LIST_H                          ; E4A9  8D 7D 01
    lda #$FF                                    ; E4AC  A9 FF
    sta ram_0170                                ; E4AE  8D 70 01
    sta ram_0172                                ; E4B1  8D 72 01
    lda #$0F                                    ; E4B4  A9 0F
    sta SND_CHN                                 ; E4B6  8D 15 40
    lda #$80                                    ; E4B9  A9 80
    sta TRI_LINEAR                              ; E4BB  8D 08 40
    lda #$00                                    ; E4BE  A9 00
    sta NOISE_HI                                ; E4C0  8D 0F 40
    lda #$00                                    ; E4C3  A9 00
    sta DMC_RAW                                 ; E4C5  8D 11 40
    lda #$30                                    ; E4C8  A9 30
    sta SQ1_VOL                                 ; E4CA  8D 00 40
    sta SQ2_VOL                                 ; E4CD  8D 04 40
    sta NOISE_VOL                               ; E4D0  8D 0C 40
    lda #$08                                    ; E4D3  A9 08
    sta SQ1_SWEEP                               ; E4D5  8D 01 40
    sta SQ2_SWEEP                               ; E4D8  8D 05 40

; <- jsr SoundStopMusic, jsr FamiToneInit, jsr FamiToneMusicPlay
; modos: titulo, selecao, VS, intro do round, fim do round, frase final
FamiToneMusicStop:
    lda #$00                                    ; E4DB  A9 00
    sta ram_0159                                ; E4DD  8D 59 01
    sta FT_DPCM_EFFECT                          ; E4E0  8D 7E 01
    ldx #$46                                    ; E4E3  A2 46
L37_E4E5:
    lda #$00                                    ; E4E5  A9 00
    sta ram_0114,x                              ; E4E7  9D 14 01
    sta ram_010F,x                              ; E4EA  9D 0F 01
    sta ram_010A,x                              ; E4ED  9D 0A 01
    sta ram_0123,x                              ; E4F0  9D 23 01
    lda #$30                                    ; E4F3  A9 30
    sta ram_0128,x                              ; E4F5  9D 28 01
    inx                                         ; E4F8  E8
    cpx #$4B                                    ; E4F9  E0 4B
    bne L37_E4E5                                ; E4FB  D0 E8
    ldx #$00                                    ; E4FD  A2 00
L37_E4FF:
    lda #<D37_EE74                              ; E4FF  A9 74
    sta ram_011C,x                              ; E501  9D 1C 01
    lda #>D37_EE74                              ; E504  A9 EE
    sta ram_012A,x                              ; E506  9D 2A 01
    lda #$00                                    ; E509  A9 00
    sta ram_010E,x                              ; E50B  9D 0E 01
    sta ram_0100,x                              ; E50E  9D 00 01
    inx                                         ; E511  E8
    cpx #$0E                                    ; E512  E0 0E
    bne L37_E4FF                                ; E514  D0 E9
    jmp FamiToneSampleStop                      ; E516  4C 21 ED


; <- jmp SoundLoadSong
; modos: titulo, selecao, VS, intro do round, frase final
FamiToneMusicPlay:
    ldx #$0F                                    ; E519  A2 0F
    stx ram_0461                                ; E51B  8E 61 04
    stx ram_0462                                ; E51E  8E 62 04
    stx ram_0463                                ; E521  8E 63 04
    stx ram_0460                                ; E524  8E 60 04
    ldx #$00                                    ; E527  A2 00
    stx ram_0467                                ; E529  8E 67 04
    stx ram_0468                                ; E52C  8E 68 04
    stx ram_0469                                ; E52F  8E 69 04
    stx ram_046E                                ; E532  8E 6E 04
    stx ram_046F                                ; E535  8E 6F 04
    stx ram_0470                                ; E538  8E 70 04
    stx ram_046B                                ; E53B  8E 6B 04
    stx ram_046C                                ; E53E  8E 6C 04
    stx ram_046D                                ; E541  8E 6D 04
    ldx FT_SONG_LIST_L                          ; E544  AE 74 01
    stx FT_TEMP_PTR_L                           ; E547  86 83
    ldx FT_SONG_LIST_H                          ; E549  AE 75 01
    stx FT_TEMP_PTR_H                           ; E54C  86 84
    ldy #$00                                    ; E54E  A0 00
    cmp (FT_TEMP_PTR_L),y                       ; E550  D1 83       [le bancos $29,$2D]
    bcs L37_E5AB                                ; E552  B0 57
    asl a                                       ; E554  0A
    sta FT_TEMP_PTR_L                           ; E555  85 83
    asl a                                       ; E557  0A
    tax                                         ; E558  AA
    asl a                                       ; E559  0A
    adc FT_TEMP_PTR_L                           ; E55A  65 83
    stx FT_TEMP_PTR_L                           ; E55C  86 83
    adc FT_TEMP_PTR_L                           ; E55E  65 83
    adc #$05                                    ; E560  69 05
    tay                                         ; E562  A8
    lda FT_SONG_LIST_L                          ; E563  AD 74 01
    sta FT_TEMP_PTR_L                           ; E566  85 83
    jsr FamiToneMusicStop                       ; E568  20 DB E4
    ldx #$46                                    ; E56B  A2 46
L37_E56D:
    lda (FT_TEMP_PTR_L),y                       ; E56D  B1 83       [le bancos $29,$2D]
    sta ram_0100,x                              ; E56F  9D 00 01
    iny                                         ; E572  C8
    lda (FT_TEMP_PTR_L),y                       ; E573  B1 83       [le bancos $29,$2D]
    sta ram_0105,x                              ; E575  9D 05 01
    iny                                         ; E578  C8
    lda #$00                                    ; E579  A9 00
    sta ram_0114,x                              ; E57B  9D 14 01
    sta ram_010F,x                              ; E57E  9D 0F 01
    sta ram_010A,x                              ; E581  9D 0A 01
    sta ram_0123,x                              ; E584  9D 23 01
    lda #$30                                    ; E587  A9 30
    sta ram_0128,x                              ; E589  9D 28 01
    inx                                         ; E58C  E8
    cpx #$4B                                    ; E58D  E0 4B
    bne L37_E56D                                ; E58F  D0 DC
    iny                                         ; E591  C8
    iny                                         ; E592  C8
    lda (FT_TEMP_PTR_L),y                       ; E593  B1 83       [le bancos $29,$2D]
    sta ram_0178                                ; E595  8D 78 01
    iny                                         ; E598  C8
    lda (FT_TEMP_PTR_L),y                       ; E599  B1 83       [le bancos $29,$2D]
    sta ram_0179                                ; E59B  8D 79 01
    lda #$00                                    ; E59E  A9 00
    sta ram_017A                                ; E5A0  8D 7A 01
    lda #$06                                    ; E5A3  A9 06
    sta ram_017B                                ; E5A5  8D 7B 01
    sta ram_0159                                ; E5A8  8D 59 01
L37_E5AB:
    rts                                         ; E5AB  60


FamiToneMusicPause:
    tax                                         ; E5AC  AA          nunca chamada no demo (nt)
    beq L37_E5C7                                ; E5AD  F0 18       (nt)
    jsr FamiToneSampleStop                      ; E5AF  20 21 ED    (nt)
    lda #$00                                    ; E5B2  A9 00       (nt)
    sta ram_0100                                ; E5B4  8D 00 01    (nt)
    sta ram_0104                                ; E5B7  8D 04 01    (nt)
    sta ram_0108                                ; E5BA  8D 08 01    (nt)
    sta ram_010B                                ; E5BD  8D 0B 01    (nt)
    lda ram_0159                                ; E5C0  AD 59 01    (nt)
    ora #$80                                    ; E5C3  09 80       (nt)
    bne L37_E5CC                                ; E5C5  D0 05       (nt)
L37_E5C7:
    lda ram_0159                                ; E5C7  AD 59 01    (nt)
    and #$7F                                    ; E5CA  29 7F       (nt)
L37_E5CC:
    sta ram_0159                                ; E5CC  8D 59 01    (nt)
    rts                                         ; E5CF  60          (nt)


; <- jmp SoundUpdate
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
FamiToneUpdate:
    lda ram_0159                                ; E5D0  AD 59 01
    bmi L37_E5D7                                ; E5D3  30 02
    bne L37_E5DA                                ; E5D5  D0 03
L37_E5D7:
    jmp _FT2UpdateSound                         ; E5D7  4C 19 E7


L37_E5DA:
    clc                                         ; E5DA  18
    lda ram_017A                                ; E5DB  AD 7A 01
    adc ram_0178                                ; E5DE  6D 78 01
    sta ram_017A                                ; E5E1  8D 7A 01
    lda ram_017B                                ; E5E4  AD 7B 01
    adc ram_0179                                ; E5E7  6D 79 01
    cmp ram_0159                                ; E5EA  CD 59 01
    bcs L37_E5F5                                ; E5ED  B0 06
    sta ram_017B                                ; E5EF  8D 7B 01    (nt)
    jmp _FT2UpdateEnvelopes                     ; E5F2  4C DD E6    (nt)


L37_E5F5:
    sec                                         ; E5F5  38
    sbc ram_0159                                ; E5F6  ED 59 01
    sta ram_017B                                ; E5F9  8D 7B 01
    ldx #$46                                    ; E5FC  A2 46
    lda #$FF                                    ; E5FE  A9 FF
    sta ram_0464                                ; E600  8D 64 04
    ldy #$00                                    ; E603  A0 00
    sty ram_0479                                ; E605  8C 79 04
    jsr _FT2ChannelUpdate                       ; E608  20 0B EB
    lda ram_0464                                ; E60B  AD 64 04
    bmi L37_E613                                ; E60E  30 03
    sta ram_0461                                ; E610  8D 61 04
L37_E613:
    bcc L37_E638                                ; E613  90 23
    lda ram_046B                                ; E615  AD 6B 04
    cmp #$03                                    ; E618  C9 03
    bcs L37_E630                                ; E61A  B0 14
    lda ram_047E                                ; E61C  AD 7E 04
    bne L37_E630                                ; E61F  D0 0F
    ldx ram_0150                                ; E621  AE 50 01
    lda _FT2NoteTableLSB,x                      ; E624  BD 77 EE    [idx $00..$36]
    sta ram_0471                                ; E627  8D 71 04
    lda _FT2NoteTableMSB,x                      ; E62A  BD CF EE    [idx $00..$36]
    sta ram_0474                                ; E62D  8D 74 04
L37_E630:
    ldx #$00                                    ; E630  A2 00
    lda ram_0155                                ; E632  AD 55 01
    jsr _FT2SetInstrument                       ; E635  20 A1 EA
L37_E638:
    ldx #$47                                    ; E638  A2 47
    lda #$FF                                    ; E63A  A9 FF
    sta ram_0464                                ; E63C  8D 64 04
    ldy #$01                                    ; E63F  A0 01
    sty ram_0479                                ; E641  8C 79 04
    jsr _FT2ChannelUpdate                       ; E644  20 0B EB
    lda ram_0464                                ; E647  AD 64 04
    bmi L37_E64F                                ; E64A  30 03
    sta ram_0462                                ; E64C  8D 62 04
L37_E64F:
    bcc L37_E674                                ; E64F  90 23
    lda ram_046C                                ; E651  AD 6C 04
    cmp #$03                                    ; E654  C9 03
    bcs L37_E66C                                ; E656  B0 14
    lda ram_047F                                ; E658  AD 7F 04
    bne L37_E66C                                ; E65B  D0 0F
    ldx ram_0151                                ; E65D  AE 51 01
    lda _FT2NoteTableLSB,x                      ; E660  BD 77 EE    [idx $00..$33]
    sta ram_0472                                ; E663  8D 72 04
    lda _FT2NoteTableMSB,x                      ; E666  BD CF EE    [idx $00..$33]
    sta ram_0475                                ; E669  8D 75 04
L37_E66C:
    ldx #$04                                    ; E66C  A2 04
    lda ram_0156                                ; E66E  AD 56 01
    jsr _FT2SetInstrument                       ; E671  20 A1 EA
L37_E674:
    ldx #$48                                    ; E674  A2 48
    ldy #$02                                    ; E676  A0 02
    sty ram_0479                                ; E678  8C 79 04
    jsr _FT2ChannelUpdate                       ; E67B  20 0B EB
    bcc L37_E6A3                                ; E67E  90 23
    lda ram_046D                                ; E680  AD 6D 04
    cmp #$03                                    ; E683  C9 03
    bcs L37_E69B                                ; E685  B0 14
    lda ram_0480                                ; E687  AD 80 04
    bne L37_E69B                                ; E68A  D0 0F
    ldx ram_0152                                ; E68C  AE 52 01
    lda _FT2NoteTableLSB,x                      ; E68F  BD 77 EE    [idx $00..$29]
    sta ram_0473                                ; E692  8D 73 04
    lda _FT2NoteTableMSB,x                      ; E695  BD CF EE    [idx $00..$29]
    sta ram_0476                                ; E698  8D 76 04
L37_E69B:
    ldx #$08                                    ; E69B  A2 08
    lda ram_0157                                ; E69D  AD 57 01
    jsr _FT2SetInstrument                       ; E6A0  20 A1 EA
L37_E6A3:
    ldx #$49                                    ; E6A3  A2 49
    lda #$FF                                    ; E6A5  A9 FF
    sta ram_0464                                ; E6A7  8D 64 04
    ldy #$03                                    ; E6AA  A0 03
    sty ram_0479                                ; E6AC  8C 79 04
    jsr _FT2ChannelUpdate                       ; E6AF  20 0B EB
    lda ram_0464                                ; E6B2  AD 64 04
    bmi L37_E6BA                                ; E6B5  30 03
    sta ram_0463                                ; E6B7  8D 63 04
L37_E6BA:
    bcc L37_E6C4                                ; E6BA  90 08
    ldx #$0B                                    ; E6BC  A2 0B
    lda ram_0158                                ; E6BE  AD 58 01
    jsr _FT2SetInstrument                       ; E6C1  20 A1 EA
L37_E6C4:
    ldx #$4A                                    ; E6C4  A2 4A
    ldy #$04                                    ; E6C6  A0 04
    sty ram_0479                                ; E6C8  8C 79 04
    jsr _FT2ChannelUpdate                       ; E6CB  20 0B EB
    bcc _FT2UpdateEnvelopes                     ; E6CE  90 0D
    lda ram_0154                                ; E6D0  AD 54 01    (nt)
    bne L37_E6DA                                ; E6D3  D0 05       (nt)
    jsr FamiToneSampleStop                      ; E6D5  20 21 ED    (nt)
    bne _FT2UpdateEnvelopes                     ; E6D8  D0 03       (nt)
L37_E6DA:
    jsr FamiToneSamplePlayM                     ; E6DA  20 27 ED    (nt)

; <- jmp L37_E5DA
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2UpdateEnvelopes:
    ldx #$00                                    ; E6DD  A2 00       laco das 5 vozes: atualiza os envelopes de volume (X=0)
_FT2EnvProcess:
    lda ram_010E,x                              ; E6DF  BD 0E 01    processa o envelope da voz X: contador ram_010E e ponteiro
    beq L37_E6E9                                ; E6E2  F0 05
    dec ram_010E,x                              ; E6E4  DE 0E 01    (nt)
    bne L37_E714                                ; E6E7  D0 2B       (nt)
L37_E6E9:
    lda ram_011C,x                              ; E6E9  BD 1C 01
    sta FT_TEMP_PTR_L                           ; E6EC  85 83
    lda ram_012A,x                              ; E6EE  BD 2A 01
    sta FT_TEMP_PTR_H                           ; E6F1  85 84
    ldy ram_0138,x                              ; E6F3  BC 38 01

; <- jmp L37_E5F5
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2EnvReadValue:
    lda (FT_TEMP_PTR_L),y                       ; E6F6  B1 83       [le bancos $29,$2D,$37] le o valor do envelope; $80-$FF vira $40-$7F (offset no volume)
    bpl L37_E703                                ; E6F8  10 09
    clc                                         ; E6FA  18
    adc #$40                                    ; E6FB  69 40
    sta ram_0100,x                              ; E6FD  9D 00 01
    iny                                         ; E700  C8
    bne L37_E710                                ; E701  D0 0D
L37_E703:
    bne L37_E70C                                ; E703  D0 07
    iny                                         ; E705  C8
    lda (FT_TEMP_PTR_L),y                       ; E706  B1 83       [le bancos $29,$2D,$37]
    tay                                         ; E708  A8
    jmp _FT2EnvReadValue                        ; E709  4C F6 E6


L37_E70C:
    iny                                         ; E70C  C8          (nt)
    sta ram_010E,x                              ; E70D  9D 0E 01    (nt)
L37_E710:
    tya                                         ; E710  98
    sta ram_0138,x                              ; E711  9D 38 01
L37_E714:
    inx                                         ; E714  E8
    cpx #$0E                                    ; E715  E0 0E
    bne _FT2EnvProcess                          ; E717  D0 C6

; <- jmp FamiToneUpdate
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2UpdateSound:
    inc ram_046A                                ; E719  EE 6A 04    avanca a fase do vibrato global (ram_046A, 0..10)
    lda ram_046A                                ; E71C  AD 6A 04
    cmp #$0B                                    ; E71F  C9 0B
    bcc L37_E728                                ; E721  90 05
    lda #$00                                    ; E723  A9 00
    sta ram_046A                                ; E725  8D 6A 04
L37_E728:
    lda ram_0103                                ; E728  AD 03 01
    and #$03                                    ; E72B  29 03
    tax                                         ; E72D  AA
    lda D37_E8AD,x                              ; E72E  BD AD E8    [idx $00..$00]
    sta ram_047A                                ; E731  8D 7A 04
    lda ram_0150                                ; E734  AD 50 01
    beq L37_E779                                ; E737  F0 40
    clc                                         ; E739  18
    adc ram_0101                                ; E73A  6D 01 01
    tax                                         ; E73D  AA
    lda ram_0102                                ; E73E  AD 02 01
    tay                                         ; E741  A8
    adc _FT2NoteTableLSB,x                      ; E742  7D 77 EE    [idx $04..$36]
    sta ram_0477                                ; E745  8D 77 04
    tya                                         ; E748  98
    ora #$7F                                    ; E749  09 7F
    bmi L37_E74F                                ; E74B  30 02
    lda #$00                                    ; E74D  A9 00
L37_E74F:
    adc _FT2NoteTableMSB,x                      ; E74F  7D CF EE    [idx $04..$36]
    sta ram_0478                                ; E752  8D 78 04
    ldy #$00                                    ; E755  A0 00
    jsr _FT2ChannelPitch                        ; E757  20 B5 E8
    sta ram_0180                                ; E75A  8D 80 01
    stx ram_0181                                ; E75D  8E 81 01
    lda ram_0100                                ; E760  AD 00 01
    beq L37_E779                                ; E763  F0 14
    ldx ram_0461                                ; E765  AE 61 04
    bne L37_E76E                                ; E768  D0 04
    lda #$00                                    ; E76A  A9 00
    beq L37_E779                                ; E76C  F0 0B
L37_E76E:
    cpx ram_0460                                ; E76E  EC 60 04
    bcc L37_E776                                ; E771  90 03
    ldx ram_0460                                ; E773  AE 60 04
L37_E776:
    jsr _FT2ScaleVolume                         ; E776  20 27 EF
L37_E779:
    ora ram_047A                                ; E779  0D 7A 04
    sta ram_017F                                ; E77C  8D 7F 01
    lda ram_0107                                ; E77F  AD 07 01
    and #$03                                    ; E782  29 03
    tax                                         ; E784  AA
    lda D37_E8AD,x                              ; E785  BD AD E8    [idx $00..$00]
    sta ram_047A                                ; E788  8D 7A 04
    lda ram_0151                                ; E78B  AD 51 01
    beq L37_E7D0                                ; E78E  F0 40
    clc                                         ; E790  18
    adc ram_0105                                ; E791  6D 05 01
    tax                                         ; E794  AA
    lda ram_0106                                ; E795  AD 06 01
    tay                                         ; E798  A8
    adc _FT2NoteTableLSB,x                      ; E799  7D 77 EE    [idx $04..$33]
    sta ram_0477                                ; E79C  8D 77 04
    tya                                         ; E79F  98
    ora #$7F                                    ; E7A0  09 7F
    bmi L37_E7A6                                ; E7A2  30 02
    lda #$00                                    ; E7A4  A9 00
L37_E7A6:
    adc _FT2NoteTableMSB,x                      ; E7A6  7D CF EE    [idx $04..$33]
    sta ram_0478                                ; E7A9  8D 78 04
    ldy #$01                                    ; E7AC  A0 01
    jsr _FT2ChannelPitch                        ; E7AE  20 B5 E8
    sta ram_0183                                ; E7B1  8D 83 01
    stx ram_0184                                ; E7B4  8E 84 01
    lda ram_0104                                ; E7B7  AD 04 01
    beq L37_E7D0                                ; E7BA  F0 14
    ldx ram_0462                                ; E7BC  AE 62 04
    bne L37_E7C5                                ; E7BF  D0 04
    lda #$00                                    ; E7C1  A9 00
    beq L37_E7D0                                ; E7C3  F0 0B
L37_E7C5:
    cpx ram_0460                                ; E7C5  EC 60 04
    bcc L37_E7CD                                ; E7C8  90 03
    ldx ram_0460                                ; E7CA  AE 60 04
L37_E7CD:
    jsr _FT2ScaleVolume                         ; E7CD  20 27 EF
L37_E7D0:
    ora ram_047A                                ; E7D0  0D 7A 04
    sta ram_0182                                ; E7D3  8D 82 01
    lda ram_0152                                ; E7D6  AD 52 01
    beq L37_E80E                                ; E7D9  F0 33
    clc                                         ; E7DB  18
    adc ram_0109                                ; E7DC  6D 09 01
    tax                                         ; E7DF  AA
    lda ram_010A                                ; E7E0  AD 0A 01
    tay                                         ; E7E3  A8
    adc _FT2NoteTableLSB,x                      ; E7E4  7D 77 EE    [idx $04..$29]
    sta ram_0477                                ; E7E7  8D 77 04
    tya                                         ; E7EA  98
    ora #$7F                                    ; E7EB  09 7F
    bmi L37_E7F1                                ; E7ED  30 02
    lda #$00                                    ; E7EF  A9 00
L37_E7F1:
    adc _FT2NoteTableMSB,x                      ; E7F1  7D CF EE    [idx $04..$29]
    sta ram_0478                                ; E7F4  8D 78 04
    ldy #$02                                    ; E7F7  A0 02
    jsr _FT2ChannelPitch                        ; E7F9  20 B5 E8
    sta ram_0186                                ; E7FC  8D 86 01
    stx ram_0187                                ; E7FF  8E 87 01
    lda ram_0108                                ; E802  AD 08 01
    ldx ram_0460                                ; E805  AE 60 04
    cpx #$07                                    ; E808  E0 07
    bcs L37_E80E                                ; E80A  B0 02
    lda #$00                                    ; E80C  A9 00
L37_E80E:
    ora #$80                                    ; E80E  09 80
    sta ram_0185                                ; E810  8D 85 01
    lda ram_010D                                ; E813  AD 0D 01
    and #$03                                    ; E816  29 03
    tax                                         ; E818  AA
    lda D37_E8B1,x                              ; E819  BD B1 E8    [idx $00..$00]
    sta ram_047A                                ; E81C  8D 7A 04
    lda ram_0153                                ; E81F  AD 53 01
    beq L37_E84B                                ; E822  F0 27
    clc                                         ; E824  18
    adc ram_010C                                ; E825  6D 0C 01
    and #$0F                                    ; E828  29 0F
    eor #$0F                                    ; E82A  49 0F
    ora ram_047A                                ; E82C  0D 7A 04
    sta ram_0189                                ; E82F  8D 89 01
    lda ram_010B                                ; E832  AD 0B 01
    beq L37_E84B                                ; E835  F0 14
    ldx ram_0463                                ; E837  AE 63 04
    bne L37_E840                                ; E83A  D0 04
    lda #$00                                    ; E83C  A9 00
    beq L37_E84B                                ; E83E  F0 0B
L37_E840:
    cpx ram_0460                                ; E840  EC 60 04
    bcc L37_E848                                ; E843  90 03
    ldx ram_0460                                ; E845  AE 60 04
L37_E848:
    jsr _FT2ScaleVolume                         ; E848  20 27 EF
L37_E84B:
    ora #$F0                                    ; E84B  09 F0
    sta ram_0188                                ; E84D  8D 88 01
    ldx #$00                                    ; E850  A2 00
    jsr _FT2SfxUpdate                           ; E852  20 CB ED
    ldx #$0F                                    ; E855  A2 0F
    jsr _FT2SfxUpdate                           ; E857  20 CB ED
    lda ram_017F                                ; E85A  AD 7F 01
    sta SQ1_VOL                                 ; E85D  8D 00 40
    lda ram_0180                                ; E860  AD 80 01
    sta SQ1_LO                                  ; E863  8D 02 40
    lda ram_0181                                ; E866  AD 81 01
    cmp ram_0170                                ; E869  CD 70 01
    beq L37_E874                                ; E86C  F0 06
    sta ram_0170                                ; E86E  8D 70 01
    sta SQ1_HI                                  ; E871  8D 03 40
L37_E874:
    lda ram_0182                                ; E874  AD 82 01
    sta SQ2_VOL                                 ; E877  8D 04 40
    lda ram_0183                                ; E87A  AD 83 01
    sta SQ2_LO                                  ; E87D  8D 06 40
    lda ram_0184                                ; E880  AD 84 01
    cmp ram_0172                                ; E883  CD 72 01
    beq L37_E88E                                ; E886  F0 06
    sta ram_0172                                ; E888  8D 72 01
    sta SQ2_HI                                  ; E88B  8D 07 40
L37_E88E:
    lda ram_0185                                ; E88E  AD 85 01
    sta TRI_LINEAR                              ; E891  8D 08 40
    lda ram_0186                                ; E894  AD 86 01
    sta TRI_LO                                  ; E897  8D 0A 40
    lda ram_0187                                ; E89A  AD 87 01
    sta TRI_HI                                  ; E89D  8D 0B 40
    lda ram_0188                                ; E8A0  AD 88 01
    sta NOISE_VOL                               ; E8A3  8D 0C 40
    lda ram_0189                                ; E8A6  AD 89 01
    sta NOISE_LO                                ; E8A9  8D 0E 40
    rts                                         ; E8AC  60

D37_E8AD:
    .byte $30,$70,$B0,$F0                       ; E8AD
D37_E8B1:
    .byte $00,$80,$00,$80                       ; E8B1

; <- jsr L37_E70C
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2ChannelPitch:
    lda ram_0150,y                              ; E8B5  B9 50 01    calcula o tom da voz: se nao ha slide, carrega a nota atual de _FT2NoteTable
    bne L37_E8C2                                ; E8B8  D0 08
    sta ram_0471,y                              ; E8BA  99 71 04    (nt)
    sta ram_0474,y                              ; E8BD  99 74 04    (nt)
    tax                                         ; E8C0  AA          (nt)
    rts                                         ; E8C1  60          (nt)


L37_E8C2:
    lda ram_047E,y                              ; E8C2  B9 7E 04
    beq L37_E8D6                                ; E8C5  F0 0F
    lda ram_0474,y                              ; E8C7  B9 74 04    (nt)
    sta ram_0478                                ; E8CA  8D 78 04    (nt)
    lda ram_0471,y                              ; E8CD  B9 71 04    (nt)
    sta ram_0477                                ; E8D0  8D 77 04    (nt)
    jmp _FT2Vibrato                             ; E8D3  4C F9 E9    (nt)


L37_E8D6:
    lda ram_046B,y                              ; E8D6  B9 6B 04
    bne L37_E8DE                                ; E8D9  D0 03
    jmp _FT2Vibrato                             ; E8DB  4C F9 E9


L37_E8DE:
    cmp #$01                                    ; E8DE  C9 01       (nt)
    beq L37_E914                                ; E8E0  F0 32       (nt)
    cmp #$02                                    ; E8E2  C9 02       (nt)
    beq L37_E8E9                                ; E8E4  F0 03       (nt)
    jmp _FT2SlideToNote                         ; E8E6  4C 40 E9    (nt)


L37_E8E9:
    ldx ram_0474,y                              ; E8E9  BE 74 04    (nt)
    lda ram_0471,y                              ; E8EC  B9 71 04    (nt)
    clc                                         ; E8EF  18          (nt)
    adc ram_046E,y                              ; E8F0  79 6E 04    (nt)
    bcc L37_E8F6                                ; E8F3  90 01       (nt)
    inx                                         ; E8F5  E8          (nt)
L37_E8F6:
    sta ram_0471,y                              ; E8F6  99 71 04    (nt)
    txa                                         ; E8F9  8A          (nt)
    cmp #$08                                    ; E8FA  C9 08       (nt)
    bcc L37_E905                                ; E8FC  90 07       (nt)
    lda #$FF                                    ; E8FE  A9 FF       (nt)
    sta ram_0471,y                              ; E900  99 71 04    (nt)
    lda #$07                                    ; E903  A9 07       (nt)
L37_E905:
    sta ram_0474,y                              ; E905  99 74 04    (nt)
    sta ram_0478                                ; E908  8D 78 04    (nt)
    lda ram_0471,y                              ; E90B  B9 71 04    (nt)
    sta ram_0477                                ; E90E  8D 77 04    (nt)
    jmp _FT2Vibrato                             ; E911  4C F9 E9    (nt)


L37_E914:
    ldx ram_0474,y                              ; E914  BE 74 04    (nt)
    lda ram_0471,y                              ; E917  B9 71 04    (nt)
    sec                                         ; E91A  38          (nt)
    sbc ram_046E,y                              ; E91B  F9 6E 04    (nt)
    bcs L37_E923                                ; E91E  B0 03       (nt)
    dex                                         ; E920  CA          (nt)
    bmi L37_E933                                ; E921  30 10       (nt)
L37_E923:
    sta ram_0471,y                              ; E923  99 71 04    (nt)
    sta ram_0477                                ; E926  8D 77 04    (nt)
    txa                                         ; E929  8A          (nt)
    sta ram_0474,y                              ; E92A  99 74 04    (nt)
    sta ram_0478                                ; E92D  8D 78 04    (nt)
    jmp _FT2Vibrato                             ; E930  4C F9 E9    (nt)


L37_E933:
    lda #$00                                    ; E933  A9 00       (nt)
    sta ram_0150,y                              ; E935  99 50 01    (nt)
    sta ram_0471,y                              ; E938  99 71 04    (nt)
    sta ram_0474,y                              ; E93B  99 74 04    (nt)
    tax                                         ; E93E  AA          (nt)
    rts                                         ; E93F  60          (nt)


; <- jmp L37_E8DE
_FT2SlideToNote:
    lda ram_0471,y                              ; E940  B9 71 04    slide/portamento: carrega o tom alvo quando o deslocamento zera (nt)
    ora ram_0474,y                              ; E943  19 74 04    (nt)
    bne L37_E957                                ; E946  D0 0F       (nt)
    ldx ram_0150,y                              ; E948  BE 50 01    (nt)
    lda _FT2NoteTableLSB,x                      ; E94B  BD 77 EE    (nt)
    sta ram_0471,y                              ; E94E  99 71 04    (nt)
    lda _FT2NoteTableMSB,x                      ; E951  BD CF EE    (nt)
    sta ram_0474,y                              ; E954  99 74 04    (nt)
L37_E957:
    jsr _FT2LoadNotePitch                       ; E957  20 E8 E9    (nt)
    jsr _FT2PitchCompare                        ; E95A  20 CA E9    (nt)
    beq L37_E965                                ; E95D  F0 06       (nt)
    dex                                         ; E95F  CA          (nt)
    beq L37_E9AF                                ; E960  F0 4D       (nt)
    jmp _FT2Vibrato                             ; E962  4C F9 E9    (nt)


L37_E965:
    ldx ram_0474,y                              ; E965  BE 74 04    (nt)
    lda ram_0471,y                              ; E968  B9 71 04    (nt)
    sec                                         ; E96B  38          (nt)
    sbc ram_046E,y                              ; E96C  F9 6E 04    (nt)
    bcs L37_E974                                ; E96F  B0 03       (nt)
    dex                                         ; E971  CA          (nt)
    bmi L37_E991                                ; E972  30 1D       (nt)
L37_E974:
    sta ram_0471,y                              ; E974  99 71 04    (nt)
    txa                                         ; E977  8A          (nt)
    sta ram_0474,y                              ; E978  99 74 04    (nt)
    jsr _FT2PitchCompare                        ; E97B  20 CA E9    (nt)
    cpx #$01                                    ; E97E  E0 01       (nt)
    beq L37_E991                                ; E980  F0 0F       (nt)
L37_E982:
    lda ram_0471,y                              ; E982  B9 71 04    (nt)
    sta ram_0477                                ; E985  8D 77 04    (nt)
    lda ram_0474,y                              ; E988  B9 74 04    (nt)
    sta ram_0478                                ; E98B  8D 78 04    (nt)
    jmp _FT2Vibrato                             ; E98E  4C F9 E9    (nt)


L37_E991:
    jsr _FT2LoadNotePitch                       ; E991  20 E8 E9    (nt)
    lda ram_0477                                ; E994  AD 77 04    (nt)
    sta ram_0471,y                              ; E997  99 71 04    (nt)
    lda ram_0478                                ; E99A  AD 78 04    (nt)
    sta ram_0474,y                              ; E99D  99 74 04    (nt)
    lda ram_046B,y                              ; E9A0  B9 6B 04    (nt)
    cmp #$04                                    ; E9A3  C9 04       (nt)
    bne L37_E9AC                                ; E9A5  D0 05       (nt)
    lda #$00                                    ; E9A7  A9 00       (nt)
    sta ram_046B,y                              ; E9A9  99 6B 04    (nt)
L37_E9AC:
    jmp _FT2Vibrato                             ; E9AC  4C F9 E9    (nt)


L37_E9AF:
    ldx ram_0474,y                              ; E9AF  BE 74 04    (nt)
    lda ram_0471,y                              ; E9B2  B9 71 04    (nt)
    clc                                         ; E9B5  18          (nt)
    adc ram_046E,y                              ; E9B6  79 6E 04    (nt)
    bcc L37_E9BC                                ; E9B9  90 01       (nt)
    inx                                         ; E9BB  E8          (nt)
L37_E9BC:
    sta ram_0471,y                              ; E9BC  99 71 04    (nt)
    txa                                         ; E9BF  8A          (nt)
    sta ram_0474,y                              ; E9C0  99 74 04    (nt)
    jsr _FT2PitchCompare                        ; E9C3  20 CA E9    (nt)
    beq L37_E991                                ; E9C6  F0 C9       (nt)
    bne L37_E982                                ; E9C8  D0 B8       (nt)

; <- jsr _FT2SlideToNote, jsr L37_E965, jsr L37_E9AF
_FT2PitchCompare:
    lda ram_0474,y                              ; E9CA  B9 74 04    compara o tom atual com o alvo: devolve 2 se igual, 0/1 se abaixo/acima (nt)
    tax                                         ; E9CD  AA          (nt)
    cmp ram_0478                                ; E9CE  CD 78 04    (nt)
    bcc L37_E9E5                                ; E9D1  90 12       (nt)
    bne L37_E9E2                                ; E9D3  D0 0D       (nt)
    lda ram_0471,y                              ; E9D5  B9 71 04    (nt)
    cmp ram_0477                                ; E9D8  CD 77 04    (nt)
    bcc L37_E9E5                                ; E9DB  90 08       (nt)
    bne L37_E9E2                                ; E9DD  D0 03       (nt)
    ldx #$02                                    ; E9DF  A2 02       (nt)
    rts                                         ; E9E1  60          (nt)


L37_E9E2:
    ldx #$00                                    ; E9E2  A2 00       (nt)
    rts                                         ; E9E4  60          (nt)


L37_E9E5:
    ldx #$01                                    ; E9E5  A2 01       (nt)
    rts                                         ; E9E7  60          (nt)


; <- jsr _FT2SlideToNote, jsr L37_E991
_FT2LoadNotePitch:
    lda ram_0150,y                              ; E9E8  B9 50 01    carrega o tom alvo da nota atual em ram_0477/0478 (nt)
    tax                                         ; E9EB  AA          (nt)
    lda _FT2NoteTableLSB,x                      ; E9EC  BD 77 EE    (nt)
    sta ram_0477                                ; E9EF  8D 77 04    (nt)
    lda _FT2NoteTableMSB,x                      ; E9F2  BD CF EE    (nt)
    sta ram_0478                                ; E9F5  8D 78 04    (nt)
    rts                                         ; E9F8  60          (nt)


; <- jmp L37_E8C2, jmp L37_E8D6, jmp L37_E8E9, jmp L37_E914, jmp _FT2SlideToNote, jmp L37_E965 ... (+1)
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2Vibrato:
    ldx ram_0467,y                              ; E9F9  BE 67 04    aplica o vibrato: profundidade ram_0467 e fase ram_046A somam ao tom
    beq L37_EA20                                ; E9FC  F0 22
    lda D37_EA27,x                              ; E9FE  BD 27 EA    (nt)
    clc                                         ; EA01  18          (nt)
    adc ram_046A                                ; EA02  6D 6A 04    (nt)
    tax                                         ; EA05  AA          (nt)
    lda D37_EA33,x                              ; EA06  BD 33 EA    (nt)
    bmi L37_EA15                                ; EA09  30 0A       (nt)
    clc                                         ; EA0B  18          (nt)
    adc ram_0477                                ; EA0C  6D 77 04    (nt)
    bcc L37_EA1D                                ; EA0F  90 0C       (nt)
    lda #$FF                                    ; EA11  A9 FF       (nt)
    bne L37_EA1D                                ; EA13  D0 08       (nt)
L37_EA15:
    clc                                         ; EA15  18          (nt)
    adc ram_0477                                ; EA16  6D 77 04    (nt)
    bcs L37_EA1D                                ; EA19  B0 02       (nt)
    lda #$00                                    ; EA1B  A9 00       (nt)
L37_EA1D:
    sta ram_0477                                ; EA1D  8D 77 04    (nt)
L37_EA20:
    lda ram_0477                                ; EA20  AD 77 04
    ldx ram_0478                                ; EA23  AE 78 04
    rts                                         ; EA26  60

D37_EA27:
    .byte $00,$00,$0B,$16,$21,$2C,$37,$42,$4D,$58,$63,$6E; EA27
D37_EA33:
    .byte $00,$01,$01,$01,$01,$00,$00,$FF,$FF,$FF,$FF,$00,$01,$02,$02,$01; EA33
    .byte $00,$00,$FF,$FE,$FE,$FF,$00,$02,$03,$03,$02,$01,$FF,$FD,$FC,$FC; EA43
    .byte $FE,$00,$03,$05,$06,$05,$02,$FE,$FB,$FA,$FB,$FD,$00,$03,$06,$06; EA53
    .byte $05,$02,$FE,$FB,$FA,$FA,$FD,$00,$05,$08,$09,$07,$03,$FD,$F9,$F7; EA63
    .byte $F8,$FB,$00,$06,$0A,$0B,$08,$03,$FD,$F8,$F5,$F6,$FA,$00,$07,$0C; EA73
    .byte $0D,$0A,$04,$FC,$F6,$F3,$F4,$F9,$00,$09,$0F,$10,$0C,$04,$FC,$F4; EA83
    .byte $F0,$F1,$F7,$00,$0A,$11,$13,$0E,$05,$FB,$F2,$ED,$EF,$F6; EA93

; <- jsr L37_E5F5
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2SetInstrument:
    asl a                                       ; EAA1  0A
    tay                                         ; EAA2  A8
    lda FT_INSTRUMENT_H                         ; EAA3  AD 77 01
    adc #$00                                    ; EAA6  69 00
    sta FT_TEMP_PTR_H                           ; EAA8  85 84
    lda FT_INSTRUMENT_L                         ; EAAA  AD 76 01
    sta FT_TEMP_PTR_L                           ; EAAD  85 83
    lda (FT_TEMP_PTR_L),y                       ; EAAF  B1 83       [le bancos $29,$2D]
    sta ram_011C,x                              ; EAB1  9D 1C 01
    iny                                         ; EAB4  C8
    lda (FT_TEMP_PTR_L),y                       ; EAB5  B1 83       [le bancos $29,$2D]
    sta ram_012A,x                              ; EAB7  9D 2A 01
    iny                                         ; EABA  C8
    inx                                         ; EABB  E8
    lda (FT_TEMP_PTR_L),y                       ; EABC  B1 83       [le bancos $29,$2D]
    sta ram_011C,x                              ; EABE  9D 1C 01
    iny                                         ; EAC1  C8
    lda (FT_TEMP_PTR_L),y                       ; EAC2  B1 83       [le bancos $29,$2D]
    sta ram_012A,x                              ; EAC4  9D 2A 01
    iny                                         ; EAC7  C8
    inx                                         ; EAC8  E8
    lda #$00                                    ; EAC9  A9 00
    sta ram_010C,x                              ; EACB  9D 0C 01
    sta ram_0136,x                              ; EACE  9D 36 01
    sta ram_010D,x                              ; EAD1  9D 0D 01
    sta ram_0137,x                              ; EAD4  9D 37 01
    sta ram_010E,x                              ; EAD7  9D 0E 01
    sta ram_0138,x                              ; EADA  9D 38 01
    cpx #$08                                    ; EADD  E0 08
    bcs L37_EAE7                                ; EADF  B0 06
    sta ram_010F,x                              ; EAE1  9D 0F 01
    sta ram_0139,x                              ; EAE4  9D 39 01
L37_EAE7:
    cpx #$0B                                    ; EAE7  E0 0B
    bcs L37_EAFD                                ; EAE9  B0 12
    lda (FT_TEMP_PTR_L),y                       ; EAEB  B1 83       [le bancos $29,$2D]
    sta ram_011C,x                              ; EAED  9D 1C 01
    iny                                         ; EAF0  C8
    lda (FT_TEMP_PTR_L),y                       ; EAF1  B1 83       [le bancos $29,$2D]
    sta ram_012A,x                              ; EAF3  9D 2A 01
    iny                                         ; EAF6  C8
    inx                                         ; EAF7  E8
    cpx #$08                                    ; EAF8  E0 08
    bcc L37_EAFF                                ; EAFA  90 03
    rts                                         ; EAFC  60


L37_EAFD:
    iny                                         ; EAFD  C8
    iny                                         ; EAFE  C8
L37_EAFF:
    lda (FT_TEMP_PTR_L),y                       ; EAFF  B1 83       [le bancos $29,$2D]
    sta ram_011C,x                              ; EB01  9D 1C 01
    iny                                         ; EB04  C8
    lda (FT_TEMP_PTR_L),y                       ; EB05  B1 83       [le bancos $29,$2D]
    sta ram_012A,x                              ; EB07  9D 2A 01
    rts                                         ; EB0A  60


; <- jsr L37_E5F5
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2ChannelUpdate:
    lda #$00                                    ; EB0B  A9 00
    sta ram_047B                                ; EB0D  8D 7B 04
    lda ram_0114,x                              ; EB10  BD 14 01
    beq L37_EB1A                                ; EB13  F0 05
    dec ram_0114,x                              ; EB15  DE 14 01
    clc                                         ; EB18  18
    rts                                         ; EB19  60


L37_EB1A:
    lda ram_0100,x                              ; EB1A  BD 00 01
    sta FT_TEMP_PTR_L                           ; EB1D  85 83
    lda ram_0105,x                              ; EB1F  BD 05 01
    sta FT_TEMP_PTR_H                           ; EB22  85 84
    ldy #$00                                    ; EB24  A0 00

; <- jmp L37_EB35, jmp L37_EB60, jmp L37_EB79, jmp L37_EB91, jmp L37_EBA4, jmp L37_EBB7 ... (+8)
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2ReadByte:
    lda (FT_TEMP_PTR_L),y                       ; EB26  B1 83       [le bancos $29,$2D] le um byte do ponteiro do canal e avanca o ponteiro de 16 bits
    inc FT_TEMP_PTR_L                           ; EB28  E6 83
    bne L37_EB2E                                ; EB2A  D0 02
    inc FT_TEMP_PTR_H                           ; EB2C  E6 84
L37_EB2E:
    ora #$00                                    ; EB2E  09 00
    bpl L37_EB35                                ; EB30  10 03
    jmp _FT2SpecialCode                         ; EB32  4C 91 EC


L37_EB35:
    cmp #$70                                    ; EB35  C9 70
    bcc L37_EB49                                ; EB37  90 10
    and #$0F                                    ; EB39  29 0F
    cmp ram_0460                                ; EB3B  CD 60 04
    bcc L37_EB43                                ; EB3E  90 03
    lda ram_0460                                ; EB40  AD 60 04
L37_EB43:
    sta ram_0464                                ; EB43  8D 64 04
    jmp _FT2ReadByte                            ; EB46  4C 26 EB


L37_EB49:
    cmp #$5F                                    ; EB49  C9 5F
    bcs L37_EB50                                ; EB4B  B0 03
    jmp _FT2PlainNote                           ; EB4D  4C 65 EC


L37_EB50:
    beq L37_EB79                                ; EB50  F0 27       (nt)
    cmp #$6E                                    ; EB52  C9 6E       (nt)
    bne L37_EB59                                ; EB54  D0 03       (nt)
    jmp _FT2NoteShiftUp                         ; EB56  4C CA EB    (nt)


L37_EB59:
    cmp #$6F                                    ; EB59  C9 6F       (nt)
    bne L37_EB60                                ; EB5B  D0 03       (nt)
    jmp _FT2NoteShiftDown                       ; EB5D  4C 20 EC    (nt)


L37_EB60:
    cmp #$6B                                    ; EB60  C9 6B       (nt)
    beq L37_EB91                                ; EB62  F0 2D       (nt)
    cmp #$6C                                    ; EB64  C9 6C       (nt)
    beq L37_EBA4                                ; EB66  F0 3C       (nt)
    cmp #$6D                                    ; EB68  C9 6D       (nt)
    beq L37_EBB7                                ; EB6A  F0 4B       (nt)
    and #$0F                                    ; EB6C  29 0F       (nt)
    ldy ram_0479                                ; EB6E  AC 79 04    (nt)
    sta ram_0467,y                              ; EB71  99 67 04    (nt)
    ldy #$00                                    ; EB74  A0 00       (nt)
    jmp _FT2ReadByte                            ; EB76  4C 26 EB    (nt)


L37_EB79:
    lda #$00                                    ; EB79  A9 00       (nt)
    sta ram_047B                                ; EB7B  8D 7B 04    (nt)
    ldy ram_0479                                ; EB7E  AC 79 04    (nt)
    sta ram_046E,y                              ; EB81  99 6E 04    (nt)
    sta ram_046B,y                              ; EB84  99 6B 04    (nt)
    lda #$01                                    ; EB87  A9 01       (nt)
    sta ram_047E,y                              ; EB89  99 7E 04    (nt)
    ldy #$00                                    ; EB8C  A0 00       (nt)
    jmp _FT2ReadByte                            ; EB8E  4C 26 EB    (nt)


L37_EB91:
    jsr _FT2ReadParam                           ; EB91  20 18 ED    (nt)
    ldy ram_0479                                ; EB94  AC 79 04    (nt)
    sta ram_046E,y                              ; EB97  99 6E 04    (nt)
    lda #$01                                    ; EB9A  A9 01       (nt)
    sta ram_046B,y                              ; EB9C  99 6B 04    (nt)
    ldy #$00                                    ; EB9F  A0 00       (nt)
    jmp _FT2ReadByte                            ; EBA1  4C 26 EB    (nt)


L37_EBA4:
    jsr _FT2ReadParam                           ; EBA4  20 18 ED    (nt)
    ldy ram_0479                                ; EBA7  AC 79 04    (nt)
    sta ram_046E,y                              ; EBAA  99 6E 04    (nt)
    lda #$02                                    ; EBAD  A9 02       (nt)
    sta ram_046B,y                              ; EBAF  99 6B 04    (nt)
    ldy #$00                                    ; EBB2  A0 00       (nt)
    jmp _FT2ReadByte                            ; EBB4  4C 26 EB    (nt)


L37_EBB7:
    jsr _FT2ReadParam                           ; EBB7  20 18 ED    (nt)
    ldy ram_0479                                ; EBBA  AC 79 04    (nt)
    sta ram_046E,y                              ; EBBD  99 6E 04    (nt)
    lda #$03                                    ; EBC0  A9 03       (nt)
    sta ram_046B,y                              ; EBC2  99 6B 04    (nt)
    ldy #$00                                    ; EBC5  A0 00       (nt)
    jmp _FT2ReadByte                            ; EBC7  4C 26 EB    (nt)


; <- jmp L37_EB50
_FT2NoteShiftUp:
    jsr _FT2ReadShift                           ; EBCA  20 4C EC    comando $6E: sobe a nota em N semitons (le o deslocamento) (nt)

; <- jmp _FT2NoteShiftUp
_FT2ShiftUpReadNote:
    lda (FT_TEMP_PTR_L),y                       ; EBCD  B1 83       le o proximo byte nao-comando da sequencia (nota) (nt)
_FT2ShiftUpNext:
    beq L37_EB79                                ; EBCF  F0 A8       decodifica o byte: $00 encerra, >= $58 e comando, senao nota (nt)
    cmp #$58                                    ; EBD1  C9 58       (nt)
    bcc L37_EBDF                                ; EBD3  90 0A       (nt)
    and #$81                                    ; EBD5  29 81       (nt)
    cmp #$81                                    ; EBD7  C9 81       (nt)
    beq L37_EC11                                ; EBD9  F0 36       (nt)
    iny                                         ; EBDB  C8          (nt)
    jmp _FT2ShiftUpReadNote                     ; EBDC  4C CD EB    (nt)


L37_EBDF:
    pha                                         ; EBDF  48          (nt)
    clc                                         ; EBE0  18          (nt)
    adc ram_047C                                ; EBE1  6D 7C 04    (nt)

; <- jmp L37_EC35
_FT2NoteShiftApply:
    sta ram_010A,x                              ; EBE4  9D 0A 01    aplica o deslocamento de nota: grava a nova nota e o modo de slide 4 (nt)
    stx zp_85                                   ; EBE7  86 85       (nt)
    pla                                         ; EBE9  68          (nt)
    tax                                         ; EBEA  AA          (nt)
    ldy ram_0479                                ; EBEB  AC 79 04    (nt)
    lda _FT2NoteTableLSB,x                      ; EBEE  BD 77 EE    (nt)
    sta ram_0471,y                              ; EBF1  99 71 04    (nt)
    lda _FT2NoteTableMSB,x                      ; EBF4  BD CF EE    (nt)
    sta ram_0474,y                              ; EBF7  99 74 04    (nt)
    lda #$04                                    ; EBFA  A9 04       (nt)
    sta ram_046B,y                              ; EBFC  99 6B 04    (nt)
    lda ram_047D                                ; EBFF  AD 7D 04    (nt)
    sta ram_046E,y                              ; EC02  99 6E 04    (nt)
    lda #$00                                    ; EC05  A9 00       (nt)
    sta ram_047E,y                              ; EC07  99 7E 04    (nt)
    ldy #$00                                    ; EC0A  A0 00       (nt)
    ldx zp_85                                   ; EC0C  A6 85       (nt)
    jmp _FT2ReadByte                            ; EC0E  4C 26 EB    (nt)


L37_EC11:
    lda ram_010A,x                              ; EC11  BD 0A 01    (nt)
    clc                                         ; EC14  18          (nt)
    adc ram_047C                                ; EC15  6D 7C 04    (nt)
    sta ram_010A,x                              ; EC18  9D 0A 01    (nt)
    ldy #$00                                    ; EC1B  A0 00       (nt)
    jmp _FT2ReadByte                            ; EC1D  4C 26 EB    (nt)


; <- jmp L37_EB59
_FT2NoteShiftDown:
    jsr _FT2ReadShift                           ; EC20  20 4C EC    comando $6F: desce a nota em N semitons (nt)

; <- jmp _FT2NoteShiftDown
_FT2ShiftDownReadNote:
    lda (FT_TEMP_PTR_L),y                       ; EC23  B1 83       le o proximo byte nao-comando da sequencia (nota) (nt)
    beq _FT2ShiftUpNext                         ; EC25  F0 A8       (nt)
    cmp #$58                                    ; EC27  C9 58       (nt)
    bcc L37_EC35                                ; EC29  90 0A       (nt)
    and #$81                                    ; EC2B  29 81       (nt)
    cmp #$81                                    ; EC2D  C9 81       (nt)
    beq L37_EC3D                                ; EC2F  F0 0C       (nt)
    iny                                         ; EC31  C8          (nt)
    jmp _FT2ShiftDownReadNote                   ; EC32  4C 23 EC    (nt)


L37_EC35:
    pha                                         ; EC35  48          (nt)
    sec                                         ; EC36  38          (nt)
    sbc ram_047C                                ; EC37  ED 7C 04    (nt)
    jmp _FT2NoteShiftApply                      ; EC3A  4C E4 EB    (nt)


L37_EC3D:
    lda ram_010A,x                              ; EC3D  BD 0A 01    (nt)
    sec                                         ; EC40  38          (nt)
    sbc ram_047C                                ; EC41  ED 7C 04    (nt)
    sta ram_010A,x                              ; EC44  9D 0A 01    (nt)
    ldy #$00                                    ; EC47  A0 00       (nt)
    jmp _FT2ReadByte                            ; EC49  4C 26 EB    (nt)


; <- jsr _FT2NoteShiftUp, jsr _FT2NoteShiftDown
_FT2ReadShift:
    inc ram_047B                                ; EC4C  EE 7B 04    le o deslocamento de nota ($6E/$6F): parte baixa = passos, alta = modo (nt)
    jsr _FT2ReadParam                           ; EC4F  20 18 ED    (nt)
    pha                                         ; EC52  48          (nt)
    and #$0F                                    ; EC53  29 0F       (nt)
    sta ram_047C                                ; EC55  8D 7C 04    (nt)
    pla                                         ; EC58  68          (nt)
    and #$F0                                    ; EC59  29 F0       (nt)
    lsr a                                       ; EC5B  4A          (nt)
    lsr a                                       ; EC5C  4A          (nt)
    lsr a                                       ; EC5D  4A          (nt)
    clc                                         ; EC5E  18          (nt)
    adc #$01                                    ; EC5F  69 01       (nt)
    sta ram_047D                                ; EC61  8D 7D 04    (nt)
    rts                                         ; EC64  60          (nt)


; <- jmp L37_EB49
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2PlainNote:
    ldy ram_0479                                ; EC65  AC 79 04    nota simples: grava o indice em ram_010A e desliga o modo de afinacao fixa
    cpy #$03                                    ; EC68  C0 03
    bcs L37_EC8B                                ; EC6A  B0 1F
    ldy ram_047B                                ; EC6C  AC 7B 04
    bne L37_EC83                                ; EC6F  D0 12
    sta ram_010A,x                              ; EC71  9D 0A 01
    ldy ram_0479                                ; EC74  AC 79 04
    lda ram_046B,y                              ; EC77  B9 6B 04
    cmp #$04                                    ; EC7A  C9 04
    bne L37_EC83                                ; EC7C  D0 05
    lda #$00                                    ; EC7E  A9 00       (nt)
    sta ram_046B,y                              ; EC80  99 6B 04    (nt)
L37_EC83:
    lda #$00                                    ; EC83  A9 00
    sta ram_047E,y                              ; EC85  99 7E 04
    sec                                         ; EC88  38
    bcs L37_ECF6                                ; EC89  B0 6B
L37_EC8B:
    sta ram_010A,x                              ; EC8B  9D 0A 01
    sec                                         ; EC8E  38
    bcs L37_ECF6                                ; EC8F  B0 65

; <- jmp L37_EB1A
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2SpecialCode:
    and #$7F                                    ; EC91  29 7F       comandos $70-$7F: instrumento/volume (bit 0 = volume, senao instrumento)
    lsr a                                       ; EC93  4A
    bcs L37_EC9E                                ; EC94  B0 08
    asl a                                       ; EC96  0A
    asl a                                       ; EC97  0A
    sta ram_010F,x                              ; EC98  9D 0F 01
    jmp _FT2ReadByte                            ; EC9B  4C 26 EB


L37_EC9E:
    cmp #$3D                                    ; EC9E  C9 3D
    bcc L37_ECF3                                ; ECA0  90 51
    beq L37_ECCF                                ; ECA2  F0 2B
    cmp #$3E                                    ; ECA4  C9 3E
    beq L37_ECE2                                ; ECA6  F0 3A
    clc                                         ; ECA8  18
    lda FT_TEMP_PTR_L                           ; ECA9  A5 83
    adc #$03                                    ; ECAB  69 03
    sta ram_0119,x                              ; ECAD  9D 19 01
    lda FT_TEMP_PTR_H                           ; ECB0  A5 84
    adc #$00                                    ; ECB2  69 00
    sta ram_011E,x                              ; ECB4  9D 1E 01
    lda (FT_TEMP_PTR_L),y                       ; ECB7  B1 83       [le bancos $29,$2D]
    sta ram_0123,x                              ; ECB9  9D 23 01
    iny                                         ; ECBC  C8
    lda (FT_TEMP_PTR_L),y                       ; ECBD  B1 83       [le bancos $29,$2D]
    sta zp_85                                   ; ECBF  85 85
    iny                                         ; ECC1  C8
    lda (FT_TEMP_PTR_L),y                       ; ECC2  B1 83       [le bancos $29,$2D]
    sta FT_TEMP_PTR_H                           ; ECC4  85 84
    lda zp_85                                   ; ECC6  A5 85
    sta FT_TEMP_PTR_L                           ; ECC8  85 83
    ldy #$00                                    ; ECCA  A0 00
    jmp _FT2ReadByte                            ; ECCC  4C 26 EB


L37_ECCF:
    lda (FT_TEMP_PTR_L),y                       ; ECCF  B1 83       [le bancos $29,$2D]
    sta ram_0159                                ; ECD1  8D 59 01
    inc FT_TEMP_PTR_L                           ; ECD4  E6 83
    beq L37_ECDB                                ; ECD6  F0 03
    jmp _FT2ReadByte                            ; ECD8  4C 26 EB


L37_ECDB:
    inc FT_TEMP_PTR_H                           ; ECDB  E6 84       (nt)
    beq L37_ECE2                                ; ECDD  F0 03       (nt)
    jmp _FT2ReadByte                            ; ECDF  4C 26 EB    (nt)


L37_ECE2:
    lda (FT_TEMP_PTR_L),y                       ; ECE2  B1 83       [le bancos $29,$2D]
    sta zp_85                                   ; ECE4  85 85
    iny                                         ; ECE6  C8
    lda (FT_TEMP_PTR_L),y                       ; ECE7  B1 83       [le bancos $29,$2D]
    sta FT_TEMP_PTR_H                           ; ECE9  85 84
    lda zp_85                                   ; ECEB  A5 85
    sta FT_TEMP_PTR_L                           ; ECED  85 83
    dey                                         ; ECEF  88
    jmp _FT2ReadByte                            ; ECF0  4C 26 EB


L37_ECF3:
    sta ram_0114,x                              ; ECF3  9D 14 01
L37_ECF6:
    lda ram_0123,x                              ; ECF6  BD 23 01
    beq L37_ED0D                                ; ECF9  F0 12
    dec ram_0123,x                              ; ECFB  DE 23 01
    bne L37_ED0D                                ; ECFE  D0 0D
    lda ram_0119,x                              ; ED00  BD 19 01
    sta ram_0100,x                              ; ED03  9D 00 01
    lda ram_011E,x                              ; ED06  BD 1E 01
    sta ram_0105,x                              ; ED09  9D 05 01
    rts                                         ; ED0C  60


L37_ED0D:
    lda FT_TEMP_PTR_L                           ; ED0D  A5 83
    sta ram_0100,x                              ; ED0F  9D 00 01
    lda FT_TEMP_PTR_H                           ; ED12  A5 84
    sta ram_0105,x                              ; ED14  9D 05 01
    rts                                         ; ED17  60


; <- jsr L37_EB91, jsr L37_EBA4, jsr L37_EBB7, jsr _FT2ReadShift
_FT2ReadParam:
    lda (FT_TEMP_PTR_L),y                       ; ED18  B1 83       le um byte do ponteiro e avanca (parametro de comando) (nt)
    inc FT_TEMP_PTR_L                           ; ED1A  E6 83       (nt)
    bne L37_ED20                                ; ED1C  D0 02       (nt)
    inc FT_TEMP_PTR_H                           ; ED1E  E6 84       (nt)
L37_ED20:
    rts                                         ; ED20  60          (nt)


; <- jmp FamiToneMusicStop, jsr FamiToneMusicPause, jsr L37_E5F5
; modos: titulo, selecao, VS, intro do round, fim do round, frase final
FamiToneSampleStop:
    lda #$0F                                    ; ED21  A9 0F
    sta SND_CHN                                 ; ED23  8D 15 40
    rts                                         ; ED26  60


; <- jsr L37_E5F5
FamiToneSamplePlayM:
    ldx FT_DPCM_EFFECT                          ; ED27  AE 7E 01    (nt)
    beq _FT2SamplePlay                          ; ED2A  F0 15       (nt)
    tax                                         ; ED2C  AA          (nt)
    lda SND_CHN                                 ; ED2D  AD 15 40    (nt)
    and #$10                                    ; ED30  29 10       (nt)
    beq L37_ED35                                ; ED32  F0 01       (nt)
    rts                                         ; ED34  60          (nt)


L37_ED35:
    sta FT_DPCM_EFFECT                          ; ED35  8D 7E 01    (nt)
    txa                                         ; ED38  8A          (nt)
    jmp _FT2SamplePlay                          ; ED39  4C 41 ED    (nt)


; <- jmp VoicePlay
; modos: titulo, selecao, intro do round, luta, fim do round
FamiToneSamplePlay:
    ldx #$01                                    ; ED3C  A2 01
    stx FT_DPCM_EFFECT                          ; ED3E  8E 7E 01

; <- jmp L37_ED35
; modos: titulo, selecao, intro do round, luta, fim do round
_FT2SamplePlay:
    sta FT_TEMP_PTR_L                           ; ED41  85 83
    asl a                                       ; ED43  0A
    clc                                         ; ED44  18
    adc FT_TEMP_PTR_L                           ; ED45  65 83
    adc FT_DPCM_LIST_L                          ; ED47  6D 7C 01
    sta FT_TEMP_PTR_L                           ; ED4A  85 83
    lda #$00                                    ; ED4C  A9 00
    adc FT_DPCM_LIST_H                          ; ED4E  6D 7D 01
    sta FT_TEMP_PTR_H                           ; ED51  85 84
    lda #$0F                                    ; ED53  A9 0F
    sta SND_CHN                                 ; ED55  8D 15 40
    ldy #$00                                    ; ED58  A0 00
    lda (FT_TEMP_PTR_L),y                       ; ED5A  B1 83       [le bancos $37]
    sta DMC_START                               ; ED5C  8D 12 40
    iny                                         ; ED5F  C8
    lda (FT_TEMP_PTR_L),y                       ; ED60  B1 83       [le bancos $37]
    sta DMC_LEN                                 ; ED62  8D 13 40
    iny                                         ; ED65  C8
    lda (FT_TEMP_PTR_L),y                       ; ED66  B1 83       [le bancos $37]
    sta DMC_FREQ                                ; ED68  8D 10 40
    lda #$20                                    ; ED6B  A9 20
    sta DMC_RAW                                 ; ED6D  8D 11 40
    lda #$1F                                    ; ED70  A9 1F
    sta SND_CHN                                 ; ED72  8D 15 40
    rts                                         ; ED75  60


; <- jmp SoundInitSfx
; modos: titulo, selecao, VS, intro do round, frase final
FamiToneSfxInit:
    stx FT_TEMP_PTR_L                           ; ED76  86 83
    sty FT_TEMP_PTR_H                           ; ED78  84 84
    ldy #$00                                    ; ED7A  A0 00
    lda (FT_TEMP_PTR_L),y                       ; ED7C  B1 83       [le bancos $37]
    sta FT_SFX_ADR_L                            ; ED7E  8D 8A 01
    iny                                         ; ED81  C8
    lda (FT_TEMP_PTR_L),y                       ; ED82  B1 83       [le bancos $37]
    sta FT_SFX_ADR_H                            ; ED84  8D 8B 01
    ldx #$00                                    ; ED87  A2 00
L37_ED89:
    jsr _FT2SfxClearChannel                     ; ED89  20 96 ED
    txa                                         ; ED8C  8A
    clc                                         ; ED8D  18
    adc #$0F                                    ; ED8E  69 0F
    tax                                         ; ED90  AA
    cpx #$1E                                    ; ED91  E0 1E
    bne L37_ED89                                ; ED93  D0 F4
    rts                                         ; ED95  60


; <- jsr FamiToneSfxInit, jsr FamiToneSfxPlay
; modos: titulo, selecao, VS, intro do round, luta, frase final
_FT2SfxClearChannel:
    lda #$00                                    ; ED96  A9 00
    sta ram_018E,x                              ; ED98  9D 8E 01
    sta ram_018C,x                              ; ED9B  9D 8C 01
    sta ram_018F,x                              ; ED9E  9D 8F 01
    sta ram_0196,x                              ; EDA1  9D 96 01
    lda #$30                                    ; EDA4  A9 30
    sta ram_0190,x                              ; EDA6  9D 90 01
    sta ram_0193,x                              ; EDA9  9D 93 01
    sta ram_0199,x                              ; EDAC  9D 99 01
    rts                                         ; EDAF  60


; <- jmp SfxPlay, jsr SfxPlayByState
; modos: luta
FamiToneSfxPlay:
    asl a                                       ; EDB0  0A
    tay                                         ; EDB1  A8
    jsr _FT2SfxClearChannel                     ; EDB2  20 96 ED
    lda FT_SFX_ADR_L                            ; EDB5  AD 8A 01
    sta FT_TEMP_PTR_L                           ; EDB8  85 83
    lda FT_SFX_ADR_H                            ; EDBA  AD 8B 01
    sta FT_TEMP_PTR_H                           ; EDBD  85 84
    lda (FT_TEMP_PTR_L),y                       ; EDBF  B1 83       [le bancos $37]
    sta ram_018D,x                              ; EDC1  9D 8D 01
    iny                                         ; EDC4  C8
    lda (FT_TEMP_PTR_L),y                       ; EDC5  B1 83       [le bancos $37]
    sta ram_018E,x                              ; EDC7  9D 8E 01
    rts                                         ; EDCA  60


; <- jsr L37_E70C
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2SfxUpdate:
    lda ram_018C,x                              ; EDCB  BD 8C 01
    beq L37_EDD5                                ; EDCE  F0 05
    dec ram_018C,x                              ; EDD0  DE 8C 01
    bne _FT2SfxUpdateBuf                        ; EDD3  D0 45
L37_EDD5:
    lda ram_018E,x                              ; EDD5  BD 8E 01
    bne L37_EDDB                                ; EDD8  D0 01
    rts                                         ; EDDA  60


L37_EDDB:
    sta FT_TEMP_PTR_H                           ; EDDB  85 84
    lda ram_018D,x                              ; EDDD  BD 8D 01
    sta FT_TEMP_PTR_L                           ; EDE0  85 83
    ldy ram_018F,x                              ; EDE2  BC 8F 01
    clc                                         ; EDE5  18

; <- jmp L37_EDF9
; modos: luta, fim do round
_FT2SfxReadByte:
    lda (FT_TEMP_PTR_L),y                       ; EDE6  B1 83       [le bancos $37] le o byte do roteiro de sfx: $80+ = comando, $00 = fim
    bmi L37_EDF9                                ; EDE8  30 0F
    beq L37_EE17                                ; EDEA  F0 2B
    jsr _FT2SfxAdvance                          ; EDEC  20 0E EE
    sta ram_018C,x                              ; EDEF  9D 8C 01
    tya                                         ; EDF2  98
    sta ram_018F,x                              ; EDF3  9D 8F 01
    jmp _FT2SfxUpdateBuf                        ; EDF6  4C 1A EE


L37_EDF9:
    jsr _FT2SfxAdvance                          ; EDF9  20 0E EE
    stx zp_85                                   ; EDFC  86 85
    adc zp_85                                   ; EDFE  65 85
    tax                                         ; EE00  AA
    lda (FT_TEMP_PTR_L),y                       ; EE01  B1 83       [le bancos $37]
    sta ram_0110,x                              ; EE03  9D 10 01
    ldx zp_85                                   ; EE06  A6 85
    jsr _FT2SfxAdvance                          ; EE08  20 0E EE
    jmp _FT2SfxReadByte                         ; EE0B  4C E6 ED


; <- jsr L37_EDDB, jsr L37_EDF9
; modos: luta, fim do round
_FT2SfxAdvance:
    iny                                         ; EE0E  C8          avanca o ponteiro do sfx (Y e o offset corrente)
    bne L37_EE16                                ; EE0F  D0 05
    inc FT_TEMP_PTR_H                           ; EE11  E6 84       (nt)
    inc ram_018E,x                              ; EE13  FE 8E 01    (nt)
L37_EE16:
    rts                                         ; EE16  60


L37_EE17:
    sta ram_018E,x                              ; EE17  9D 8E 01

; <- jmp L37_EDDB
; modos: luta, fim do round
_FT2SfxUpdateBuf:
    lda ram_0190,x                              ; EE1A  BD 90 01    copia os parametros do sfx para as variaveis do canal (volume, etc.)
    and #$0F                                    ; EE1D  29 0F
    beq L37_EE33                                ; EE1F  F0 12
    lda ram_0190,x                              ; EE21  BD 90 01    (nt)
    sta ram_017F                                ; EE24  8D 7F 01    (nt)
    lda ram_0191,x                              ; EE27  BD 91 01    (nt)
    sta ram_0180                                ; EE2A  8D 80 01    (nt)
    lda ram_0192,x                              ; EE2D  BD 92 01    (nt)
    sta ram_0181                                ; EE30  8D 81 01    (nt)
L37_EE33:
    lda ram_0193,x                              ; EE33  BD 93 01
    and #$0F                                    ; EE36  29 0F
    beq L37_EE4C                                ; EE38  F0 12
    lda ram_0193,x                              ; EE3A  BD 93 01
    sta ram_0182                                ; EE3D  8D 82 01
    lda ram_0194,x                              ; EE40  BD 94 01
    sta ram_0183                                ; EE43  8D 83 01
    lda ram_0195,x                              ; EE46  BD 95 01
    sta ram_0184                                ; EE49  8D 84 01
L37_EE4C:
    lda ram_0196,x                              ; EE4C  BD 96 01
    beq L37_EE60                                ; EE4F  F0 0F
    sta ram_0185                                ; EE51  8D 85 01
    lda ram_0197,x                              ; EE54  BD 97 01
    sta ram_0186                                ; EE57  8D 86 01
    lda ram_0198,x                              ; EE5A  BD 98 01
    sta ram_0187                                ; EE5D  8D 87 01
L37_EE60:
    lda ram_0199,x                              ; EE60  BD 99 01
    and #$0F                                    ; EE63  29 0F
    beq L37_EE73                                ; EE65  F0 0C
    lda ram_0199,x                              ; EE67  BD 99 01
    sta ram_0188                                ; EE6A  8D 88 01
    lda ram_019A,x                              ; EE6D  BD 9A 01
    sta ram_0189                                ; EE70  8D 89 01
L37_EE73:
    rts                                         ; EE73  60

D37_EE74:
    .byte $C0,$00,$00                           ; EE74
_FT2NoteTableLSB:
    .byte $00,$F1,$7E,$13,$AD,$4D,$F3,$9D,$4C,$00,$B8,$74,$34,$F8,$BF,$89; EE77
    .byte $56,$26,$F9,$CE,$A6,$80,$5C,$3A,$1A,$FB,$DF,$C4,$AB,$93,$7C,$67; EE87
    .byte $52,$3F,$2D,$1C,$0C,$FD,$EF,$E1,$D5,$C9,$BD,$B3,$A9,$9F,$96,$8E; EE97
    .byte $86,$7E,$77,$70,$6A,$64,$5E,$59,$54,$4F,$4B,$46,$42,$3F,$3B,$38; EEA7
    .byte $34,$31,$2F,$2C,$29,$27,$25,$23,$21,$1F,$1D,$1B,$1A,$18,$17,$15; EEB7
    .byte $14,$13,$12,$11,$10,$0F,$0E,$0D       ; EEC7
_FT2NoteTableMSB:
    .byte $00,$07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04,$03,$03,$03; EECF
    .byte $03,$03,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01; EEDF
    .byte $01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; EEEF
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; EEFF
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; EF0F
    .byte $00,$00,$00,$00,$00,$00,$00,$00       ; EF1F

; <- jsr L37_E70C
; modos: titulo, selecao, VS, intro do round, luta, fim do round, frase final
_FT2ScaleVolume:
    sta ram_0465                                ; EF27  8D 65 04    escala o volume (A) pela atenuacao da voz e devolve no minimo 1 (0 = mudo)
    lda ram_0465                                ; EF2A  AD 65 04
    beq L37_EF48                                ; EF2D  F0 19
    inx                                         ; EF2F  E8
    stx ram_0466                                ; EF30  8E 66 04
    ldx #$08                                    ; EF33  A2 08
L37_EF35:
    asl a                                       ; EF35  0A
    asl ram_0465                                ; EF36  0E 65 04
    bcc L37_EF3F                                ; EF39  90 04
    clc                                         ; EF3B  18
    adc ram_0466                                ; EF3C  6D 66 04
L37_EF3F:
    dex                                         ; EF3F  CA
    bne L37_EF35                                ; EF40  D0 F3
    lsr a                                       ; EF42  4A
    lsr a                                       ; EF43  4A
    lsr a                                       ; EF44  4A
    lsr a                                       ; EF45  4A
    beq L37_EF49                                ; EF46  F0 01
L37_EF48:
    rts                                         ; EF48  60


L37_EF49:
    lda #$01                                    ; EF49  A9 01
    rts                                         ; EF4B  60


; <- farcall Main
; modos: titulo
ScreenPlayerSelect:
    lda #$02                                    ; EF4C  A9 02
    sta ScreenMode                              ; EF4E  85 B0
    lda PpuCtrlShadow                           ; EF50  A5 ED
    and #$FC                                    ; EF52  29 FC
    ora #$01                                    ; EF54  09 01
    sta PpuCtrlShadow                           ; EF56  85 ED
    lda #$F8                                    ; EF58  A9 F8
    sta a:ScrollX                               ; EF5A  8D EF 00
    lda #$E0                                    ; EF5D  A9 E0
    sta a:ScrollY                               ; EF5F  8D F0 00
    farcall SelectScreenBuild                   ; EF62  A9 EF 48 A9 73 48 A9 37 .. -> 3B:F376
    cli                                         ; EF74  58
    lda #$FF                                    ; EF75  A9 FF
    sta IrqStage                                ; EF77  8D FF 03
    farcall FadeIn                              ; EF7A  A9 EF 48 A9 8B 48 A9 37 .. -> 3B:E4D6
    jsr SelectInit                              ; EF8C  20 92 EF
    jmp SelectFighterIntro                      ; EF8F  4C CF F0


.ifdef FIX_SELECT_DIFFICULTY
__alt_37_EF92:
    ; le bit $20 (SELECT) do JoyState do jogador corrente
    lda JoyState,x
    and #$20
    beq +
    ; SELECT apertado: alterna AiLevel
    lda AiLevel,x
    clc
    adc #$02
    cmp #$09
    bcs ++
    sta AiLevel,x
    jmp ++
++;
    lda #$04
    sta AiLevel,x
++;
    .assert * - __alt_37_EF92 <= $2, error, "bloco alt FIX_SELECT_DIFFICULTY em $EF92 passou do tamanho"
    .res $2 - (* - __alt_37_EF92), $FF
.else

; <- jsr ScreenPlayerSelect
; modos: selecao
SelectInit:
    lda #$29                                    ; EF92  A9 29       inicia a tela de selecao: carrega a musica $29 e zera a escolha
.endif

    sta MusicBank                               ; EF94  8D 5F 04
    lda #<D29_AAB6                              ; EF97  A9 B6
    sta zp_D5                                   ; EF99  85 D5
    lda #>D29_AAB6                              ; EF9B  A9 AA
    sta zp_D6                                   ; EF9D  85 D6
    farcall SoundLoadSong                       ; EF9F  A9 EF 48 A9 B0 48 A9 37 .. -> 37:E3E0
    ldy #$00                                    ; EFB1  A0 00
    sty zp_E9                                   ; EFB3  84 E9
    lda FighterChar                             ; EFB5  A5 00
    sta zp_D7                                   ; EFB7  85 D7
    bpl L37_EFBF                                ; EFB9  10 04
    lda #$00                                    ; EFBB  A9 00
    sta zp_12                                   ; EFBD  85 12
L37_EFBF:
    lda FighterChar+1                           ; EFBF  A5 01
    sta zp_D8                                   ; EFC1  85 D8
    bpl SelectCheckDone                         ; EFC3  10 04
    lda #$00                                    ; EFC5  A9 00
    sta zp_13                                   ; EFC7  85 13

; <- jmp SelectLoopNext
; modos: selecao
SelectCheckDone:
    lda zp_D7                                   ; EFC9  A5 D7       se os dois jogadores ja escolheram, retorna; senao continua
    bmi L37_EFD0                                ; EFCB  30 03
    jmp SelectReturn                            ; EFCD  4C CE F0


L37_EFD0:
    lda #$00                                    ; EFD0  A9 00
    sta VBlankFlag                              ; EFD2  85 AC
L37_EFD4:
    lda VBlankFlag                              ; EFD4  A5 AC
    beq L37_EFD4                                ; EFD6  F0 FC
    lda ram_0390                                ; EFD8  AD 90 03
    sta ram_0391                                ; EFDB  8D 91 03
    farcall SoundUpdate                         ; EFDE  A9 EF 48 A9 EF 48 A9 37 .. -> 37:E45F
    jsr SelectReadInput                         ; EFF0  20 CC F1
    lda FighterIsCpu                            ; EFF3  A5 02
    beq L37_EFFA                                ; EFF5  F0 03
    jmp SelectLoopNext                          ; EFF7  4C CB F0    (nt)


L37_EFFA:
    lda #$20                                    ; EFFA  A9 20
    ora #$80                                    ; EFFC  09 80
    sta MMC5_PRG_8000                           ; EFFE  8D 14 51
    lda #<D20_8476                              ; F001  A9 76
    sta zp_D9                                   ; F003  85 D9
    lda #>D20_8476                              ; F005  A9 84
    sta zp_DA                                   ; F007  85 DA
    ldx zp_E9                                   ; F009  A6 E9
    lda D37_F2BB,x                              ; F00B  BD BB F2    [idx $00..$07]
    sta zp_DB                                   ; F00E  85 DB
    lda D37_F2C3,x                              ; F010  BD C3 F2    [idx $00..$07]
    sta zp_DC                                   ; F013  85 DC
    lda #$00                                    ; F015  A9 00
    sta zp_DD                                   ; F017  85 DD
    lda #$80                                    ; F019  A9 80
    sta zp_E4                                   ; F01B  85 E4
    lda #$02                                    ; F01D  A9 02
    sta zp_E1                                   ; F01F  85 E1
    farcall SelectDrawBlink                     ; F021  A9 F0 48 A9 32 48 A9 37 .. -> 3B:F359
    ldx zp_E9                                   ; F033  A6 E9
    lda D37_F29B,x                              ; F035  BD 9B F2    [idx $00..$07]
    sta zp_D9                                   ; F038  85 D9
    lda D37_F2A3,x                              ; F03A  BD A3 F2    [idx $00..$07]
    sta zp_DA                                   ; F03D  85 DA
    lda D37_F2AB,x                              ; F03F  BD AB F2    [idx $00..$07]
    sta zp_DB                                   ; F042  85 DB
    lda D37_F2B3,x                              ; F044  BD B3 F2    [idx $00..$07]
    sta zp_DC                                   ; F047  85 DC
    lda D37_F293,x                              ; F049  BD 93 F2    [idx $00..$07]
    cmp #$04                                    ; F04C  C9 04
    bne L37_F052                                ; F04E  D0 02
    inc zp_E1                                   ; F050  E6 E1
L37_F052:
    farcall SelectDrawFighter                   ; F052  A9 F0 48 A9 63 48 A9 37 .. -> 3B:F36C
    ldx zp_E9                                   ; F064  A6 E9
    lda D37_F293,x                              ; F066  BD 93 F2    [idx $00..$07]
    sta FighterChar                             ; F069  85 00
    cmp #$00                                    ; F06B  C9 00
    beq L37_F076                                ; F06D  F0 07
    lda #$FF                                    ; F06F  A9 FF
    sta zp_D7                                   ; F071  85 D7
    jmp SelectDrawCurrent                       ; F073  4C 93 F0


L37_F076:
    ldx zp_D7                                   ; F076  A6 D7
    bmi SelectDrawCurrent                       ; F078  30 19
    stx zp_12                                   ; F07A  86 12
    lda #$12                                    ; F07C  A9 12
    sta VoiceQueued                             ; F07E  8D 5E 04
    farcall VoicePlay                           ; F081  A9 F0 48 A9 92 48 A9 37 .. -> 37:E427

; <- jmp L37_EFFA
; modos: selecao
SelectDrawCurrent:
    lda #$00                                    ; F093  A9 00       desenha o retrato e o nome do lutador atual na selecao
    sta zp_D5                                   ; F095  85 D5
    lda #$2A                                    ; F097  A9 2A
    sta zp_D6                                   ; F099  85 D6
    lda #$E0                                    ; F09B  A9 E0
    sta zp_D9                                   ; F09D  85 D9
    lda #$2B                                    ; F09F  A9 2B
    sta zp_DA                                   ; F0A1  85 DA
    farcall PortraitSetupP1                     ; F0A3  A9 F0 48 A9 B4 48 A9 37 .. -> 3B:EE38
    lda #$00                                    ; F0B5  A9 00
    sta zp_D5                                   ; F0B7  85 D5
    farcall PortraitDrawName                    ; F0B9  A9 F0 48 A9 CA 48 A9 37 .. -> 3B:EFD3

; <- jmp L37_EFD0
; modos: selecao
SelectLoopNext:
    jmp SelectCheckDone                         ; F0CB  4C C9 EF    proximo lutador: volta ao inicio do laco da selecao


; <- jmp SelectInit
; modos: selecao
SelectReturn:
    rts                                         ; F0CE  60          fim do laco da selecao: retorna


; <- jmp ScreenPlayerSelect
; modos: selecao
SelectFighterIntro:
    lda #$00                                    ; F0CF  A9 00       entrada do lutador escolhido: prepara paleta, sprite e som da selecao
    sta FighterChar+1                           ; F0D1  85 01
    sta ram_03B5                                ; F0D3  8D B5 03
    lda zp_12                                   ; F0D6  A5 12
    eor #$01                                    ; F0D8  49 01
    sta zp_13                                   ; F0DA  85 13
    lda #$20                                    ; F0DC  A9 20
    ora #$80                                    ; F0DE  09 80
    sta MMC5_PRG_8000                           ; F0E0  8D 14 51
    lda #$00                                    ; F0E3  A9 00
    sta zp_DD                                   ; F0E5  85 DD
    lda #$80                                    ; F0E7  A9 80
    sta zp_E4                                   ; F0E9  85 E4
    lda #$02                                    ; F0EB  A9 02
    sta zp_E1                                   ; F0ED  85 E1
    ldx zp_E9                                   ; F0EF  A6 E9
    lda D37_F29B,x                              ; F0F1  BD 9B F2    [idx $00..$00]
    sta zp_D9                                   ; F0F4  85 D9
    lda D37_F2A3,x                              ; F0F6  BD A3 F2    [idx $00..$00]
    sta zp_DA                                   ; F0F9  85 DA
    lda D37_F2AB,x                              ; F0FB  BD AB F2    [idx $00..$00]
    sta zp_DB                                   ; F0FE  85 DB
    lda D37_F2B3,x                              ; F100  BD B3 F2    [idx $00..$00]
    sta zp_DC                                   ; F103  85 DC
    lda D37_F293,x                              ; F105  BD 93 F2    [idx $00..$00]
    cmp #$04                                    ; F108  C9 04
    bne L37_F10E                                ; F10A  D0 02
    inc zp_E1                                   ; F10C  E6 E1       (nt)
L37_F10E:
    farcall SelectDrawFighter                   ; F10E  A9 F1 48 A9 1F 48 A9 37 .. -> 3B:F36C
    lda #$00                                    ; F120  A9 00
    sta FrameCounter                            ; F122  85 B1
L37_F124:
    lda #$00                                    ; F124  A9 00
    sta VBlankFlag                              ; F126  85 AC
L37_F128:
    lda VBlankFlag                              ; F128  A5 AC
    beq L37_F128                                ; F12A  F0 FC
    farcall SoundUpdate                         ; F12C  A9 F1 48 A9 3D 48 A9 37 .. -> 37:E45F
    lda FrameCounter                            ; F13E  A5 B1
    and #$3F                                    ; F140  29 3F
    bne L37_F124                                ; F142  D0 E0
    ldx ram_03B5                                ; F144  AE B5 03
    lda CountryVoiceTbl,x                       ; F147  BD EF E0    [idx $00..$00]
    sta VoiceQueued                             ; F14A  8D 5E 04
    lda #$10                                    ; F14D  A9 10
    sta zp_EB                                   ; F14F  85 EB
    lda #$01                                    ; F151  A9 01
    sta zp_EC                                   ; F153  85 EC
L37_F155:
    lda #$00                                    ; F155  A9 00
    sta VBlankFlag                              ; F157  85 AC
L37_F159:
    lda VBlankFlag                              ; F159  A5 AC
    beq L37_F159                                ; F15B  F0 FC
    farcall SoundUpdate                         ; F15D  A9 F1 48 A9 6E 48 A9 37 .. -> 37:E45F
    lda #$00                                    ; F16F  A9 00
    sta OamIndex                                ; F171  85 AD
    lda zp_EC                                   ; F173  A5 EC
    beq L37_F18C                                ; F175  F0 15
    farcall SelectDrawFighter                   ; F177  A9 F1 48 A9 88 48 A9 37 .. -> 3B:F36C
    jmp SelectWaitEnd                           ; F189  4C 9E F1


L37_F18C:
    farcall OamHideRest                         ; F18C  A9 F1 48 A9 9D 48 A9 37 .. -> 3B:F2DF

; <- jmp SelectFighterIntro
; modos: selecao
SelectWaitEnd:
    lda FrameCounter                            ; F19E  A5 B1       espera o fim da animacao (contador zp_EB) e faz o fade para o VS
    and #$07                                    ; F1A0  29 07
    bne L37_F155                                ; F1A2  D0 B1
    lda zp_EC                                   ; F1A4  A5 EC
    eor #$01                                    ; F1A6  49 01
    sta zp_EC                                   ; F1A8  85 EC
    dec zp_EB                                   ; F1AA  C6 EB
    bpl L37_F155                                ; F1AC  10 A7
    farcall SoundStopMusic                      ; F1AE  A9 F1 48 A9 BF 48 A9 37 .. -> 37:E479
    farjmp FadeOut                              ; F1C0  A9 37 48 A9 3B A2 E4 A0 .. -> 3B:E426


; <- jsr L37_EFD0
; modos: selecao
SelectReadInput:
    farcall JoyPollBothSel                      ; F1CC  A9 F1 48 A9 DD 48 A9 37 .. -> 3F:F09B le os dois controles (JoyPollSafe) e processa a escolha de cada jogador
    ldx #$01                                    ; F1DE  A2 01

; <- jmp L37_F271
; modos: selecao
SelectPlayerInput:
    lda FighterIsCpu,x                          ; F1E0  B5 02       processa a entrada do jogador X (pula se for CPU)
    beq L37_F1E7                                ; F1E2  F0 03
    jmp SelectNextPlayer                        ; F1E4  4C 7B F2


L37_F1E7:
    lda zp_D7,x                                 ; F1E7  B5 D7
    bmi L37_F1EE                                ; F1E9  30 03
    jmp SelectNextPlayer                        ; F1EB  4C 7B F2    (nt)


L37_F1EE:
    lda JoyState,x                              ; F1EE  B5 F2
    and #$08                                    ; F1F0  29 08
    beq L37_F20C                                ; F1F2  F0 18
    lda JoyPrev,x                               ; F1F4  B5 F6
    and #$08                                    ; F1F6  29 08
    bne L37_F20C                                ; F1F8  D0 12
    lda zp_E9,x                                 ; F1FA  B5 E9
    cmp #$04                                    ; F1FC  C9 04
    bcc SelectMoveLeft                          ; F1FE  90 27
    sbc #$04                                    ; F200  E9 04
    sta zp_E9,x                                 ; F202  95 E9
    lda #$11                                    ; F204  A9 11
    sta VoiceQueued                             ; F206  8D 5E 04
    jmp SelectMoveLeft                          ; F209  4C 27 F2


L37_F20C:
    lda JoyState,x                              ; F20C  B5 F2
    and #$04                                    ; F20E  29 04
    beq SelectMoveLeft                          ; F210  F0 15
    lda JoyPrev,x                               ; F212  B5 F6
    and #$04                                    ; F214  29 04
    bne SelectMoveLeft                          ; F216  D0 0F
    lda zp_E9,x                                 ; F218  B5 E9
    cmp #$04                                    ; F21A  C9 04
    bcs SelectMoveLeft                          ; F21C  B0 09
    adc #$04                                    ; F21E  69 04
    sta zp_E9,x                                 ; F220  95 E9
    lda #$11                                    ; F222  A9 11
    sta VoiceQueued                             ; F224  8D 5E 04

; <- jmp L37_F1EE
; modos: selecao
SelectMoveLeft:
    lda JoyState,x                              ; F227  B5 F2       esquerda na borda: move o cursor para o lutador anterior
    and #$02                                    ; F229  29 02
    beq L37_F246                                ; F22B  F0 19
    lda JoyPrev,x                               ; F22D  B5 F6
    and #$02                                    ; F22F  29 02
    bne L37_F246                                ; F231  D0 13
    ldy zp_E9,x                                 ; F233  B4 E9
    beq SelectConfirm                           ; F235  F0 2D
    cpy #$04                                    ; F237  C0 04
    beq SelectConfirm                           ; F239  F0 29
    dey                                         ; F23B  88
    sty zp_E9,x                                 ; F23C  94 E9
    lda #$11                                    ; F23E  A9 11
    sta VoiceQueued                             ; F240  8D 5E 04
    jmp SelectConfirm                           ; F243  4C 64 F2


L37_F246:
    lda JoyState,x                              ; F246  B5 F2
    and #$01                                    ; F248  29 01
    beq SelectConfirm                           ; F24A  F0 18
    lda JoyPrev,x                               ; F24C  B5 F6
    and #$01                                    ; F24E  29 01
    bne SelectConfirm                           ; F250  D0 12
    ldy zp_E9,x                                 ; F252  B4 E9
    cpy #$03                                    ; F254  C0 03
    beq SelectConfirm                           ; F256  F0 0C
    cpy #$07                                    ; F258  C0 07
    beq SelectConfirm                           ; F25A  F0 08
    iny                                         ; F25C  C8
    sty zp_E9,x                                 ; F25D  94 E9
    lda #$11                                    ; F25F  A9 11
    sta VoiceQueued                             ; F261  8D 5E 04

; <- jmp L37_F20C
; modos: selecao
SelectConfirm:
    lda JoyState,x                              ; F264  B5 F2       A na borda: confirma o lutador atual (P1/P2)
    and #$80                                    ; F266  29 80
    beq L37_F271                                ; F268  F0 07
    lda #$01                                    ; F26A  A9 01
    sta zp_D7,x                                 ; F26C  95 D7
    jmp SelectNextPlayer                        ; F26E  4C 7B F2


L37_F271:
    lda JoyState,x                              ; F271  B5 F2
    and #$40                                    ; F273  29 40
    beq SelectNextPlayer                        ; F275  F0 04
    lda #$00                                    ; F277  A9 00
    sta zp_D7,x                                 ; F279  95 D7

; <- jmp SelectReadInput, jmp L37_F1E7, jmp L37_F246
; modos: selecao
SelectNextPlayer:
    dex                                         ; F27B  CA          passa ao outro jogador (X=1 -> 0) ou encerra
    bmi L37_F281                                ; F27C  30 03
    jmp SelectPlayerInput                       ; F27E  4C E0 F1


L37_F281:
    bit VoiceQueued                             ; F281  2C 5E 04
    bmi L37_F292                                ; F284  30 0C
    farjmp VoicePlay                            ; F286  A9 37 48 A9 37 A2 E4 A0 .. -> 37:E427


L37_F292:
    rts                                         ; F292  60

D37_F293:
    .byte $00,$04,$03,$07,$01,$02,$09,$08       ; F293
D37_F29B:
    .byte <(D20_84E5)                           ; F29B  E5
    .byte <(D20_84D3)                           ; F29C  D3
    .byte <(D20_84F7)                           ; F29D  F7
    .byte <(D20_84EE)                           ; F29E  EE
    .byte <(D20_84F7)                           ; F29F  F7
    .byte <(D20_84DC)                           ; F2A0  DC
    .byte <(D20_8500)                           ; F2A1  00
    .byte <(D20_84EE)                           ; F2A2  EE
D37_F2A3:
    .byte >(D20_84E5)                           ; F2A3  84
    .byte >(D20_84D3)                           ; F2A4  84
    .byte >(D20_84F7)                           ; F2A5  84
    .byte >(D20_84EE)                           ; F2A6  84
    .byte >(D20_84F7)                           ; F2A7  84
    .byte >(D20_84DC)                           ; F2A8  84
    .byte >(D20_8500)                           ; F2A9  85
    .byte >(D20_84EE)                           ; F2AA  84
D37_F2AB:
    .byte $80,$B0,$BC,$68,$B9,$6E,$4A,$68       ; F2AB
D37_F2B3:
    .byte $5F,$6F,$54,$6B,$33,$3B,$3D,$6B       ; F2B3
D37_F2BB:
    .byte $50,$68,$80,$98,$50,$68,$80,$98       ; F2BB
D37_F2C3:
    .byte $B8,$B8,$B8,$B8,$D8,$D8,$D8,$D8       ; F2C3

; <- farcall Main
; modos: aviso/QR, frase final
ScreenDisclaimer:
    lda #$00                                    ; F2CB  A9 00
    sta ScreenMode                              ; F2CD  85 B0
    lda #$28                                    ; F2CF  A9 28
    sta PPUADDR                                 ; F2D1  8D 06 20
    lda #$00                                    ; F2D4  A9 00
    sta PPUADDR                                 ; F2D6  8D 06 20
    lda #$00                                    ; F2D9  A9 00
    ldy #$03                                    ; F2DB  A0 03
L37_F2DD:
    ldx #$00                                    ; F2DD  A2 00
L37_F2DF:
    sta PPUDATA                                 ; F2DF  8D 07 20
    inx                                         ; F2E2  E8
    bne L37_F2DF                                ; F2E3  D0 FA
    dey                                         ; F2E5  88
    bpl L37_F2DD                                ; F2E6  10 F5
    lda #$27                                    ; F2E8  A9 27
    sta a:PaletteBuf                            ; F2EA  8D BC 00
    lda #$37                                    ; F2ED  A9 37
    sta a:PaletteBuf+1                          ; F2EF  8D BD 00
    lda #$0F                                    ; F2F2  A9 0F
    sta a:PaletteBuf+2                          ; F2F4  8D BE 00
    sta a:PaletteDirty                          ; F2F7  8D D4 00
    lda #$0E                                    ; F2FA  A9 0E
    sta MMC5_CHR_BG1                            ; F2FC  8D 29 51
    lda PpuCtrlShadow                           ; F2FF  A5 ED
    and #$FC                                    ; F301  29 FC
    ora #$02                                    ; F303  09 02
    sta PpuCtrlShadow                           ; F305  85 ED
    lda PpuMaskShadow                           ; F307  A5 EE
    ora #$08                                    ; F309  09 08
    sta PpuMaskShadow                           ; F30B  85 EE
    lda PpuCtrlShadow                           ; F30D  A5 ED
    ora #$80                                    ; F30F  09 80
    sta PpuCtrlShadow                           ; F311  85 ED
    sta PPUCTRL                                 ; F313  8D 00 20
    lda #$C4                                    ; F316  A9 C4
    sta zp_D6                                   ; F318  85 D6
    lda #$28                                    ; F31A  A9 28
    sta zp_D7                                   ; F31C  85 D7
    lda #$00                                    ; F31E  A9 00
    sta zp_D8                                   ; F320  85 D8
    sta zp_D5                                   ; F322  85 D5
L37_F324:
    lda #$00                                    ; F324  A9 00
    sta VBlankFlag                              ; F326  85 AC
L37_F328:
    lda VBlankFlag                              ; F328  A5 AC
    beq L37_F328                                ; F32A  F0 FC
    lda FrameCounter                            ; F32C  A5 B1
    and #$01                                    ; F32E  29 01
    bne L37_F324                                ; F330  D0 F2
    ldy zp_D7                                   ; F332  A4 D7
    lda zp_D6                                   ; F334  A5 D6
    clc                                         ; F336  18
    adc zp_D8                                   ; F337  65 D8
    bcc L37_F33C                                ; F339  90 01
    iny                                         ; F33B  C8          (nt)
L37_F33C:
    sty PPUADDR                                 ; F33C  8C 06 20
    sta PPUADDR                                 ; F33F  8D 06 20
    inc zp_D8                                   ; F342  E6 D8
    ldx zp_D5                                   ; F344  A6 D5
    lda TextDisclaimer,x                        ; F346  BD 91 F3    [idx $00..$CC]
    bne L37_F35A                                ; F349  D0 0F
    lda zp_D6                                   ; F34B  A5 D6
    clc                                         ; F34D  18
    adc #$20                                    ; F34E  69 20
    sta zp_D6                                   ; F350  85 D6
    bcc L37_F356                                ; F352  90 02
    inc zp_D7                                   ; F354  E6 D7
L37_F356:
    lda #$00                                    ; F356  A9 00
    sta zp_D8                                   ; F358  85 D8
L37_F35A:
    sta PPUDATA                                 ; F35A  8D 07 20
    lda #$00                                    ; F35D  A9 00
    sta PPUADDR                                 ; F35F  8D 06 20
    sta PPUADDR                                 ; F362  8D 06 20
    inx                                         ; F365  E8
    stx zp_D5                                   ; F366  86 D5
    cpx #$CD                                    ; F368  E0 CD
    bcc L37_F324                                ; F36A  90 B8
    lda #$BF                                    ; F36C  A9 BF
    sta FrameCounter                            ; F36E  85 B1
L37_F370:
    lda #$00                                    ; F370  A9 00
    sta VBlankFlag                              ; F372  85 AC
L37_F374:
    lda VBlankFlag                              ; F374  A5 AC
    beq L37_F374                                ; F376  F0 FC
    lda FrameCounter                            ; F378  A5 B1
    bne L37_F370                                ; F37A  D0 F4
    farcall FadeOut                             ; F37C  A9 F3 48 A9 8D 48 A9 37 .. -> 3B:E426
    jmp ScreenSupport                           ; F38E  4C 5E F4

TextDisclaimer:
    .byte $20,$20,$20,$20,$20,$20,$20,$44,$49,$53,$43,$4C,$41,$49,$4D,$45; F391
    .byte $52,$00,$00,$00,$54,$48,$49,$53,$20,$47,$41,$4D,$45,$20,$49,$53; F3A1
    .byte $20,$49,$4E,$20,$4E,$4F,$20,$57,$41,$59,$00,$41,$46,$46,$49,$4C; F3B1
    .byte $49,$41,$54,$45,$44,$2C,$20,$41,$53,$53,$4F,$43,$49,$41,$54,$45; F3C1
    .byte $44,$2C,$00,$41,$55,$54,$48,$4F,$52,$49,$5A,$45,$44,$2C,$20,$45; F3D1
    .byte $4E,$44,$4F,$52,$53,$45,$44,$20,$42,$59,$2C,$00,$4F,$52,$20,$49; F3E1
    .byte $4E,$20,$41,$4E,$59,$20,$57,$41,$59,$20,$4F,$46,$46,$49,$43,$49; F3F1
    .byte $41,$4C,$4C,$59,$00,$43,$4F,$4E,$4E,$45,$43,$54,$45,$44,$20,$57; F401
    .byte $49,$54,$48,$20,$43,$41,$50,$43,$4F,$4D,$2E,$00,$00,$49,$54,$27; F411
    .byte $53,$20,$41,$20,$46,$41,$4E,$2D,$4D,$41,$44,$45,$20,$57,$4F,$52; F421
    .byte $4B,$00,$57,$48,$49,$43,$48,$20,$41,$49,$4D,$53,$20,$54,$4F,$20; F431
    .byte $50,$52,$45,$53,$45,$52,$56,$45,$00,$56,$49,$44,$45,$4F,$20,$47; F441
    .byte $41,$4D,$45,$20,$48,$49,$53,$54,$4F,$52,$59,$2E,$00; F451

; <- jmp ScreenDisclaimer
; modos: aviso/QR
ScreenSupport:
    lda #$00                                    ; F45E  A9 00
    sta ScreenMode                              ; F460  85 B0
    farcall DrawSupportScreen                   ; F462  A9 F4 48 A9 73 48 A9 37 .. -> 3B:FACB
    lda #$10                                    ; F474  A9 10
    sta a:PaletteBuf                            ; F476  8D BC 00
    lda #$20                                    ; F479  A9 20
    sta a:PaletteBuf+1                          ; F47B  8D BD 00
    sta a:PaletteBuf+2                          ; F47E  8D BE 00
    sta a:PaletteDirty                          ; F481  8D D4 00
    lda #$FF                                    ; F484  A9 FF
    sta MMC5_CHR_BG1                            ; F486  8D 29 51
    lda #$0E                                    ; F489  A9 0E
    sta MMC5_CHR_BG3                            ; F48B  8D 2B 51
    lda PpuCtrlShadow                           ; F48E  A5 ED
    and #$FC                                    ; F490  29 FC
    ora #$02                                    ; F492  09 02
    sta PpuCtrlShadow                           ; F494  85 ED
    lda PpuMaskShadow                           ; F496  A5 EE
    ora #$08                                    ; F498  09 08
    sta PpuMaskShadow                           ; F49A  85 EE
    lda PpuCtrlShadow                           ; F49C  A5 ED
    ora #$80                                    ; F49E  09 80
    sta PpuCtrlShadow                           ; F4A0  85 ED
    sta PPUCTRL                                 ; F4A2  8D 00 20
    lda #$00                                    ; F4A5  A9 00
    sta FrameCounter                            ; F4A7  85 B1
L37_F4A9:
    lda #$00                                    ; F4A9  A9 00
    sta VBlankFlag                              ; F4AB  85 AC
L37_F4AD:
    lda VBlankFlag                              ; F4AD  A5 AC
    beq L37_F4AD                                ; F4AF  F0 FC
    lda FrameCounter                            ; F4B1  A5 B1
    bne L37_F4A9                                ; F4B3  D0 F4
L37_F4B5:
    lda #$00                                    ; F4B5  A9 00
    sta VBlankFlag                              ; F4B7  85 AC
L37_F4B9:
    lda VBlankFlag                              ; F4B9  A5 AC
    beq L37_F4B9                                ; F4BB  F0 FC
    farcall JoyPollBoth                         ; F4BD  A9 F4 48 A9 CE 48 A9 37 .. -> 3F:F8E7
    lda JoyState                                ; F4CF  A5 F2
    and #$D0                                    ; F4D1  29 D0
    bne L37_F4D9                                ; F4D3  D0 04
    lda FrameCounter                            ; F4D5  A5 B1
    bne L37_F4B5                                ; F4D7  D0 DC
L37_F4D9:
    farjmp FadeOut                              ; F4D9  A9 37 48 A9 3B A2 E4 A0 .. -> 3B:E426


; <- farcall Main
; modos: aviso/QR
ScreenTitle:
    lda #$01                                    ; F4E5  A9 01
    sta ScreenMode                              ; F4E7  85 B0
    lda #$00                                    ; F4E9  A9 00
    sta FadePalette+10                          ; F4EB  8D 8F 04
    lda #$29                                    ; F4EE  A9 29
    sta MusicBank                               ; F4F0  8D 5F 04
    lda #<D29_A000                              ; F4F3  A9 00
    sta zp_D5                                   ; F4F5  85 D5
    lda #>D29_A000                              ; F4F7  A9 A0
    sta zp_D6                                   ; F4F9  85 D6
    farcall SoundLoadSong                       ; F4FB  A9 F5 48 A9 0C 48 A9 37 .. -> 37:E3E0
    farcall DrawTitleScreen                     ; F50D  A9 F5 48 A9 1E 48 A9 37 .. -> 3B:FADC
    ldx #$0B                                    ; F51F  A2 0B
    stx a:PaletteDirty                          ; F521  8E D4 00
L37_F524:
    lda D37_F699,x                              ; F524  BD 99 F6    [idx $00..$0B]
    sta a:PaletteBuf,x                          ; F527  9D BC 00
    sta a:PaletteBuf+12,x                       ; F52A  9D C8 00
    dex                                         ; F52D  CA
    bpl L37_F524                                ; F52E  10 F4
    lda #$30                                    ; F530  A9 30
    sta a:FighterChrPage+1                      ; F532  8D 41 00
    lda #$30                                    ; F535  A9 30
    sta OamBuf+3                                ; F537  8D 03 02
    lda #$7F                                    ; F53A  A9 7F
    sta OamBuf                                  ; F53C  8D 00 02
    lda #$00                                    ; F53F  A9 00
    sta OamBuf+2                                ; F541  8D 02 02
    lda #$F2                                    ; F544  A9 F2
    sta OamBuf+1                                ; F546  8D 01 02
    lda #$2C                                    ; F549  A9 2C
    sta PPUADDR                                 ; F54B  8D 06 20
    lda #$00                                    ; F54E  A9 00
    sta PPUADDR                                 ; F550  8D 06 20
    lda #$00                                    ; F553  A9 00
    ldy #$03                                    ; F555  A0 03
L37_F557:
    tax                                         ; F557  AA
L37_F558:
    sta PPUDATA                                 ; F558  8D 07 20
    inx                                         ; F55B  E8
    bne L37_F558                                ; F55C  D0 FA
    dey                                         ; F55E  88
    bpl L37_F557                                ; F55F  10 F6
    lda PpuCtrlShadow                           ; F561  A5 ED
    and #$FC                                    ; F563  29 FC
    ora #$02                                    ; F565  09 02
    sta PpuCtrlShadow                           ; F567  85 ED
    lda PpuCtrlShadow                           ; F569  A5 ED
    ora #$80                                    ; F56B  09 80
    sta PpuCtrlShadow                           ; F56D  85 ED
    sta PPUCTRL                                 ; F56F  8D 00 20
    lda #$F0                                    ; F572  A9 F0
    sta zp_EB                                   ; F574  85 EB
    lda #$10                                    ; F576  A9 10
    sta zp_E9                                   ; F578  85 E9
    lda #$FF                                    ; F57A  A9 FF
    sta zp_EA                                   ; F57C  85 EA

; <- jmp L37_F5E6, jmp L37_F601, jmp L37_F616, jmp L37_F63B, jmp L37_F645
; modos: titulo
TitleLoop:
    lda #$00                                    ; F57E  A9 00       laco do titulo: zera rolagem e espera o START
    sta a:ScrollX                               ; F580  8D EF 00
    sta a:ScrollY                               ; F583  8D F0 00
    lda PpuCtrlShadow                           ; F586  A5 ED
    and #$FC                                    ; F588  29 FC
    ora #$02                                    ; F58A  09 02
    sta PpuCtrlShadow                           ; F58C  85 ED
    lda #$00                                    ; F58E  A9 00
    sta VBlankFlag                              ; F590  85 AC
L37_F592:
    lda VBlankFlag                              ; F592  A5 AC
    beq L37_F592                                ; F594  F0 FC
    lda PpuMaskShadow                           ; F596  A5 EE
    ora #$18                                    ; F598  09 18
    sta PpuMaskShadow                           ; F59A  85 EE
    sta PPUMASK                                 ; F59C  8D 01 20
    lda #$2F                                    ; F59F  A9 2F
    sta MMC5_CHR_BG1                            ; F5A1  8D 29 51
    lda #$30                                    ; F5A4  A9 30
    sta MMC5_CHR_BG3                            ; F5A6  8D 2B 51
    farcall SoundUpdate                         ; F5A9  A9 F5 48 A9 BA 48 A9 37 .. -> 37:E45F

L37_F5BB:
    bit PPUSTATUS                               ; F5BB  2C 02 20
    bvs L37_F5BB                                ; F5BE  70 FB
L37_F5C0:
    bit PPUSTATUS                               ; F5C0  2C 02 20
    bvc L37_F5C0                                ; F5C3  50 FB
    ldx #$FF                                    ; F5C5  A2 FF
L37_F5C7:
    dex                                         ; F5C7  CA
    bne L37_F5C7                                ; F5C8  D0 FD
    lda #$0D                                    ; F5CA  A9 0D
    sta MMC5_CHR_BG1                            ; F5CC  8D 29 51
    lda #$0E                                    ; F5CF  A9 0E
    sta MMC5_CHR_BG3                            ; F5D1  8D 2B 51
    lda FrameCounter                            ; F5D4  A5 B1
    and #$01                                    ; F5D6  29 01
    bne L37_F5E6                                ; F5D8  D0 0C
    ldx zp_EB                                   ; F5DA  A6 EB
    beq L37_F601                                ; F5DC  F0 23
    txa                                         ; F5DE  8A
    axs #$04                                    ; F5DF  CB 04
    stx zp_EB                                   ; F5E1  86 EB
    jmp TitleScrollSet                          ; F5E3  4C F8 F5


L37_F5E6:
    ldx zp_E9                                   ; F5E6  A6 E9
    beq L37_F601                                ; F5E8  F0 17
    lda PpuCtrlShadow                           ; F5EA  A5 ED
    ora #$03                                    ; F5EC  09 03
    sta PpuCtrlShadow                           ; F5EE  85 ED
    sta PPUCTRL                                 ; F5F0  8D 00 20
    txa                                         ; F5F3  8A
    axs #$FC                                    ; F5F4  CB FC
    stx zp_E9                                   ; F5F6  86 E9

; <- jmp L37_F5BB
; modos: titulo
TitleScrollSet:
    stx PPUSCROLL                               ; F5F8  8E 05 20    grava X nas duas portas de rolagem e volta ao laco do titulo
    stx PPUSCROLL                               ; F5FB  8E 05 20
    jmp TitleLoop                               ; F5FE  4C 7E F5


L37_F601:
    bit zp_EA                                   ; F601  24 EA
    bmi L37_F616                                ; F603  30 11
    lda SND_CHN                                 ; F605  AD 15 40
    and #$10                                    ; F608  29 10
    beq L37_F645                                ; F60A  F0 39
    lda FrameCounter                            ; F60C  A5 B1
    and #$01                                    ; F60E  29 01
    jsr TitleBlinkPushStart                     ; F610  20 70 F6
    jmp TitleLoop                               ; F613  4C 7E F5


L37_F616:
    lda #$01                                    ; F616  A9 01
    jsr TitleBlinkPushStart                     ; F618  20 70 F6
    farcall JoyPollBoth                         ; F61B  A9 F6 48 A9 2C 48 A9 37 .. -> 3F:F8E7
    ldx #$00                                    ; F62D  A2 00
L37_F62F:
    lda JoyState,x                              ; F62F  B5 F2
    and #$90                                    ; F631  29 90
    bne L37_F63B                                ; F633  D0 06
    dex                                         ; F635  CA
    bpl L37_F62F                                ; F636  10 F7
    jmp TitleLoop                               ; F638  4C 7E F5


L37_F63B:
    stx zp_EA                                   ; F63B  86 EA
    lda #$10                                    ; F63D  A9 10
    sta VoiceQueued                             ; F63F  8D 5E 04
    jmp TitleLoop                               ; F642  4C 7E F5


L37_F645:
    lda FadePalette+11                          ; F645  AD 90 04
    beq L37_F652                                ; F648  F0 08
    lda #$00                                    ; F64A  A9 00
    jsr TitleBlinkPushStart                     ; F64C  20 70 F6
    jmp TitleLoop                               ; F64F  4C 7E F5


L37_F652:
    farcall SoundStopMusic                      ; F652  A9 F6 48 A9 63 48 A9 37 .. -> 37:E479
    farjmp FadeOut                              ; F664  A9 37 48 A9 3B A2 E4 A0 .. -> 3B:E426


; <- jsr L37_F601, jsr L37_F616, jsr L37_F645
; modos: titulo
TitleBlinkPushStart:
    ldy #$09                                    ; F670  A0 09       pisca o PRESS START alternando a cor 10 da paleta
    sty FadePalette+10                          ; F672  8C 8F 04
    cmp #$01                                    ; F675  C9 01
    beq L37_F682                                ; F677  F0 09
    lda #$00                                    ; F679  A9 00
L37_F67B:
    sta FadePalette+11,y                        ; F67B  99 90 04
    dey                                         ; F67E  88
    bpl L37_F67B                                ; F67F  10 FA
    rts                                         ; F681  60


L37_F682:
    lda TextPushStart,y                         ; F682  B9 8F F6    [idx $00..$09]
    clc                                         ; F685  18
    adc #$80                                    ; F686  69 80
    sta FadePalette+11,y                        ; F688  99 90 04
    dey                                         ; F68B  88
    bpl L37_F682                                ; F68C  10 F4
    rts                                         ; F68E  60

TextPushStart:
    .byte $50,$55,$53,$48,$20,$53,$54,$41,$52,$54; F68F
D37_F699:
    .byte $16,$27,$37,$21,$31,$01,$27,$37,$37,$0F,$0F,$0F; F699
    .res 1480, $FF                              ; F6A5

.ifdef FIX_SOFT_RESET
__alt_37_FC6D:
ResetStub:
    lda #$00
    sta MMC5_IRQ_STATUS                         ; desliga o IRQ de scanline que pode ter ficado armado
    lda #$BF
    sta MMC5_PRG_E000                           ; banco $3F em $E000 (a proxima instrucao ja vem dele)
    jmp $FF9F                                   ; Reset original (so existe no banco $3F)
    .assert * - __alt_37_FC6D <= $F, error, "bloco alt FIX_SOFT_RESET em $FC6D passou do tamanho"
    .res $F - (* - __alt_37_FC6D), $FF
.else
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; FC6D
.endif


.assert * = $FC7C, error, "o kernel precisa comecar em $FC7C"
.include "kernel.inc"

    .byte $FF,$FF,$FF,$FF                       ; FF9B
D37_FF9F:
    .res 91, $FF                                ; FF9F
    .word NmiHandler                            ; FFFA  1E FE

.ifdef FIX_SOFT_RESET
__alt_37_FFFC:
    .word ResetStub
    .assert * - __alt_37_FFFC <= $2, error, "bloco alt FIX_SOFT_RESET em $FFFC passou do tamanho"
    .res $2 - (* - __alt_37_FFFC), $FF
.else
    .word D37_FF9F                              ; FFFC  9F FF
.endif

    .word IrqHandler                            ; FFFE  7C FC
