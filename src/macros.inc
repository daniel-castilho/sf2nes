; Macros do projeto.

FarCall := $049E        ; trampolim de chamada distante (copiado do ROM para a RAM na inicializacao)

; ---------------------------------------------------------------------------------------------------------
; farcall <rotina>
;   Chamada "distante": executa uma rotina que esta em OUTRO banco de codigo (todos rodam em $E000-$FFFF).
;   Empilha o endereco de retorno e o banco atual e pula para o trampolim que fica na RAM (FarCall, $049E),
;   que troca o banco em $5117, chama a rotina, restaura o banco e retorna.
;   A, X e Y sao destruidos na ida (parametros vao por variaveis de pagina zero).
;   O banco de destino e o banco atual sao resolvidos pelo linker (.bank), entao da para mover rotinas.
;   Gera exatamente os mesmos 18 bytes do ROM original.
; ---------------------------------------------------------------------------------------------------------
.macro farcall target
    .local ret
    lda #>(ret-1)
    pha
    lda #<(ret-1)
    pha
    lda #<.bank(ret)
    pha
    lda #<.bank(target)
    ldx #>(target-1)
    ldy #<(target-1)
    jmp FarCall
ret:
.endmacro

; ---------------------------------------------------------------------------------------------------------
; farjmp <rotina>
;   Salto distante (tail-call): igual ao farcall, mas sem empilhar endereco de retorno — quando a rotina
;   de destino retornar, o trampolim restaura o banco atual e volta para QUEM CHAMOU a rotina atual.
;   Gera exatamente os mesmos 12 bytes do ROM original.
; ---------------------------------------------------------------------------------------------------------
.macro farjmp target
    .local here
here:
    lda #<.bank(here)
    pha
    lda #<.bank(target)
    ldx #>(target-1)
    ldy #<(target-1)
    jmp FarCall
.endmacro
