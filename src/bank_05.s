; GERADO para implementacao do Ken — banco relocavel de estados em $A000-$BFFF
; .segment "BANK05" posicao este banco na janela $A000-$BFFF do PRG.
; Configuracao: sf2ne.cfg adicionou BANK05: load = PRG05, type = ro.
; CharStateBankTbl[1] = $05 faz o jogo usar este banco para os estados de Ken.

.segment "BANK05"

; Espaco reservado para o banco de estados de Ken.
; O banco sera mapeado em $A000-$BFFF pelo linker.
; Dados de estados (labels, quadros, colisao) serao adicionados
; nas fases subsequentes da implementacao.
; Por enquanto, apenas a estrutura do banco esta presente.

; Alinhamento e padding para completar o bloco de 8K (32 palavras = 64 bytes minimos)
; O banco real pode crescer ate usar todo o espaco $A000-$BFFF.

; Palavras (words) referenciadas pelo carregador de personagens.
; Estes labels permitem que o motor de estados leia os ponteiros corretos.
; O primeiro word eh lido sem indice (lda $800A), assumindo banco em $A000.

; Tabela de ponteiros para estados principais
; Cada .word referencia o cabecalho de estado correspondente
; O formato: word lo, word hi (little-endian), mas como estamos em banco relocavel,
; o high byte sera lido sem indice pelo motor.

; Labels de estado - definidas para que o .word funcione corretamente.
; Estas sao os pontos de entrada para os estados de Ken.

; Estado 0: Neutral stand - entrada principal
D05_A10B:            .byte $00

; Estado 1: Forward walk
D05_A16D:            .byte $01

; Estado 2: Backward walk
D05_A220:            .byte $02

; Estado 3: Crouch
D05_A2D0:            .byte $03

; Estado 4: Jump
D05_A330:            .byte $04

; Estado 5: Hadouken
D05_A388:            .byte $05

; Estado 6: Shoryuken
D05_A3E8:            .byte $06

; Estado 7: Tatsumaki
D05_A440:            .byte $07

; Estado 8: Hit standing
D05_A498:            .byte $08

; Estado 9: Crouch hit / outras transicoes
D05_A518:            .byte $09

; Padding para completar o segmento minimamente
.res 256, $00 ; de $A000 a $A0FF como minimos

; Fim do banco $05. Dados de estados completos serao adicionados
; nas fases seguintes conforme a especificacao RF-3.