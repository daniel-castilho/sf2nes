# Lições aprendidas — o travamento do Ken nos golpes especiais

Este documento registra, do começo ao fim, um bug que **só aparecia com o Ken**: o jogo congelava
assim que o Ken usava um golpe especial perto do Ryu (CPU). A causa não estava nos dados do Ken, nem
nos quadros de animação, nem na ficha do personagem: era um despacho por `RTS` que só funcionava para
**um** lutador. Fica aqui o sintoma, o diagnóstico, a causa raiz, a correção, a verificação e a
alternativa descartada — para não repetir o erro em outros despachos do mesmo tipo.

---

## 1. Sintoma

No Mesen (o emulador onde o usuário via o problema), ao escolher o Ken e lutar contra o Ryu controlado
pela CPU:

* o Ken andava, pulava, socava e chutava normalmente;
* ao sair um golpe especial (Hadouken, Shoryuken ou Tatsumaki), o jogo **congelava**;
* o quadro ficava parado, sem som e sem resposta ao controle;
* o travamento acontecia sobretudo quando o Ken ficava **no ar** — Shoryuken, salto ou o fim de um
  Tatsumaki — porque era aí que a IA do Ryu entrava no ramo anti-aéreo.

Não era um travamento aleatório: com a mesma sequência de entradas, o congelamento caía sempre no
mesmo ponto. No teste reproduzível, o Ken entrava no estado `$C4` (Shoryuken) no quadro 1091 e o OAM
(os sprites, `$0200-$02FF`) parava de mudar no quadro seguinte.

---

## 2. Como o diagnóstico foi feito

O projeto já tinha um harness de Mesen sem janela (`tools/mesen/`, modo `--testrunner`). Foram usados
três instrumentos, todos em Lua:

1. **Detector de congelamento de OAM** — o laço principal redesenha o buffer de sprites todo quadro.
   Se o hash de `$0200-$02FF` não muda por 150 quadros durante a luta, o jogo não está mais rodando.
2. **Anel de PCs** — um `addMemoryCallback` de execução grava os últimos milhares de
   `(PC, banco mapeado)`. Quando o PC repete o mesmo endereço 20 vezes seguidas, é porque a CPU parou
   (instrução `JAM`).
3. **Contador de instruções por quadro** — em jogo normal o laço gasta ~9.400 "ops" por quadro (a
   espera de vblank). No travamento o número saltava para ~29.780 e o OAM congelava: não era espera,
   era laço morto.

Com o anel de PCs, o instante do travamento mostrou a sequência:

```
pc=$8F46 ... pc=$8FE8 bank=00
pc=$A492 bank=01
pc=$A492 bank=01
pc=$A492 bank=01   (repetindo para sempre)
```

O byte em `$A492` (banco `$01`) é `$02`, que no 6502 é **`JAM`**: a CPU entra em halt e só sai com
reset. O `$8FE8` é o `RTS` do despacho anti-aéreo da IA do Ryu. Ou seja: o `RTS` estava devolvendo para
`$A492` em vez de para uma rotina de IA.

---

## 3. Causa raiz

A IA do Ryu tem um despacho por "truque do RTS": empilha um endereço e executa `RTS`; o processador
"retorna" para a rotina escolhida. Em `$00:8FDC`:

```asm
L00_8FCF:
    lda a:FighterState,y      ; estado do oponente
    and #$F8
    cmp #$B0
    bcc L00_8FE9
    cmp #$E1
    bcs L00_8FE9
    lda a:FighterChar,y       ; personagem do OPONENTE
    tay                       ; Y = 0 (Ryu), 1 (Ken), ...
    lda D00_9148+1,y          ; byte ALTO da entrada
    pha
    lda D00_9148,y            ; byte BAIXO da entrada
    pha
    rts                       ; "retorna" para o endereço empilhado
```

A tabela tem **uma única entrada**, guardada como `endereço-1` (o `RTS` soma 1):

```asm
D00_9148:
    .word RyuAiAntiAir-1      ; $9148: 49 91  -> alvo $9149 -> RTS vai para $914A
```

O problema é a indexação. `D00_9148+1,y` e `D00_9148,y` avançam de **1 em 1** com `Y`, mas cada
entrada ocupa **2 bytes**. Isso só funciona porque, com `Y=0`, os dois acessos caem exatamente nos dois
bytes da entrada. Com `Y=1` (Ken), eles caem **um byte fora** e leem o começo da rotina seguinte:

| `Y` | `D00_9148+1,y` lê | `D00_9148,y` lê | endereço empilhado | `RTS` vai para |
|---|---|---|---|---|
| `0` (Ryu) | `$9149 = $91` | `$9148 = $49` | `$9149` | `$914A` = `RyuAiAntiAir` ✅ |
| `1` (Ken) | `$914A = $A4` | `$9149 = $91` | `$A491` | `$A492` = `$02` = `JAM` ❌ |

O `$A4` vem do primeiro byte de `RyuAiAntiAir` (`ldy OtherFighter` = opcode `A4`). O `$91` é o byte
alto da própria entrada. A combinação `$A4:$91` forma `$A491`; o `RTS` soma 1 e cai em `$A492`, que no
banco `$01` é lixo (`$02` = `JAM`).

**Por que só o Ken?** Porque `Y` é o personagem do **oponente**. Enquanto o oponente era o Ryu
(personagem 0), a tabela era indexada com 0 e funcionava. Com o Ken (personagem 1), a mesma tabela foi
indexada com 1 e o truque do `RTS` apontou para fora dela. A tabela nunca teve uma segunda entrada — o
código só nunca tinha sido exercitado com outro índice.

O [NESdev Wiki](https://www.nesdev.org/wiki/RTS_Trick) descreve o padrão e a pegadinha: no *RTS Trick*
cada entrada guarda `alvo-1` (o `RTS` soma 1), e numa tabela de endereços de 16 bits o índice precisa
ser multiplicado por 2 (`ASL A`) antes de indexar. A tabela anti-aérea é uma tabela única de `.word`;
o `ASL` não existe porque, com uma entrada só, o índice 0 funciona sem escala. Foi essa economia que
quebrou quando o índice 1 passou a existir.

---

## 4. A correção

Como a IA desta entrega é **sempre a do Ryu** (a CPU continua sendo o Ryu; não há IA de Ken), a rotina
anti-aérea correta é sempre a do Ryu. Em vez de indexar a tabela pelo personagem do oponente, o código
passa a usar a entrada 0 **sem índice**:

```asm
    lda D00_9148+1            ; era: lda D00_9148+1,y   (B9 49 91)
    pha
    lda D00_9148              ; era: lda D00_9148,y     (B9 48 91)
    pha
    rts
```

São **dois bytes** trocados em `$00:8FE0` e `$00:8FE4`: `B9` (`LDA abs,Y`) vira `AD` (`LDA abs`). O
`tay` em `$8FDF` continua lá e fica inofensivo. Nada é deslocado; o resto do banco não muda.

A correção entra no build canônico pela diretiva `patch` das anotações (é o mecanismo usado para todas
as mudanças do Ken), em `annotations/sf2ne.ann`:

```
# Ken jogavel: ... (explicacao)
patch 00:8FE0 AD
patch 00:8FE4 AD
```

Efeito: qualquer oponente (Ryu, Ken ou outro) usa `RyuAiAntiAir`, exatamente como no Ryu-vs-Ryu. Para
o Ryu a semântica é **idêntica** à de antes, porque com `Y=0` o código antigo já caía na entrada 0.

---

## 5. Por que não uma tabela com duas entradas

A alternativa "óbvia" seria dar ao Ken a sua própria entrada em `D00_9148` e continuar indexando por
personagem. Ela foi descartada por dois motivos:

1. **A tabela é entrelaçada, não um vetor de 16 bits.** Os bytes baixos e altos são lidos por duas
   instruções separadas (`D00_9148` e `D00_9148+1`), com passo 1. Para acomodar duas entradas seria
   preciso multiplicar o índice por 2 (`ASL A`) antes do `TAY`. O NESdev chama o formato alternativo de
   *split table*: duas tabelas de 1 byte (baixos e altos) indexadas pelo mesmo `X`; é o formato das
   outras tabelas de IA do jogo (`D00_913C`/`D00_9140` etc.), mas não desta.
2. **Não cabe no mecanismo de `patch`.** `patch` sobrescreve bytes no lugar; inserir um `ASL A` (ou
   qualquer byte) deslocaria todo o código seguinte em 1 byte. Isso exigiria remontar/relocar o banco,
   muito mais arriscado do que dois bytes de mudança — e sem ganho, já que só existe IA de Ryu.

Se um dia houver IA de Ken, o caminho certo é refazer o despacho com índice escalado (`ASL A`) e uma
tabela de duas entradas em espaço livre (há 2.960 bytes `$FF` a partir de `$00:9470`), não espremer a
segunda entrada no passo 1.

---

## 6. Verificação

### 6.1 Invariantes do build

Comparando `build/sf2ne.nes` com `rom/sf2ne_demo.nes` banco a banco (8 KB por banco). SHA-1 do build
final: `85610a00f43c06de482f969d8df9764ee5379991`.

| Banco | Diferenças | O que é |
|---|---|---|
| `$00` | **2 bytes**: `$8FE0`, `$8FE4` | esta correção (`B9` → `AD`) |
| `$01` | 0 | banco de estados do Ryu — intocado |
| `$02` | 0 | dados do Ryu — intocado |
| `$06` | 0 | dados do Ryu — intocado |
| `$3B` | 0 | cópia do kernel/código do Ryu — intocado |
| `$04` | 16 bytes (`$90E0-$90EF`) | stub de IA do Ken |
| `$05` | banco inteiro | banco de estados do Ken (era `$FF`) |
| `$37` | 2 bytes (`$F06C-$F06D`) | seleção aceita Ken |
| `$3C` | 22 bytes | ficha/paleta do Ken na coluna 1 |
| `$3F` | 18 bytes (`$F828-$F839`) | telas de Disclaimer/QR puladas (NOPs temporários) |

O banco `$00` tem exatamente os dois bytes da correção; a coluna 0 (Ryu) continua byte a byte
intocada.

### 6.2 Reprodução do travamento (antes × depois)

O mesmo roteiro que travava o ROM anterior — Ken selecionado, Ryu CPU ativo, Hadouken repetido:

| ROM | Resultado |
|---|---|
| antes da correção | `CRASH OAM_FROZEN` no quadro **1271**; Ken preso em `$C4`; PC em `$A492` (`JAM`) |
| depois da correção | roda os **5.000** quadros até o fim, sem congelamento |

A única diferença funcional entre as duas ROMs é o par de bytes `$8FE0`/`$8FE4`; a tela de aviso já
estava pulada nas duas.

### 6.3 Bateria completa (todos os especiais)

Roteiro no Mesen com os oito movimentos — Hadouken fraco/forte, Shoryuken fraco/forte, Tatsumaki
fraco/forte, salto e salto com ataque — em ciclo, contra o Ryu CPU:

```
9.000 quadros totais, 5.907 quadros de luta
antiAir=559  dispatch=297  rts=297      (o caminho anti-aéreo rodou 297 vezes)
CRASH: 0
```

Cada movimento foi tentado 21–22 vezes. O contador `antiAir` confirma que o ramo que antes levava ao
`JAM` foi executado centenas de vezes **sem** travar. Os bytes no ROM montado são:

```
$8FDC: B9 00 00 A8 AD 49 91 48 AD 48 91 48 60
                          ^^          ^^
                       $8FE0       $8FE4
```

### 6.4 Como repetir

```sh
make gen && make
MESEN_DIR=$PWD/mesen OUT=/tmp/ken-test
# BATTERY = script Lua de diagnostico usado nesta investigacao (fica fora do repositorio)
env -u DISPLAY HOME="$MESEN_DIR/home" LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
    SF2_OUT="$OUT" SF2_FRAMES=9000 \
    "$MESEN_DIR/Mesen" --testrunner --timeout=480 \
    build/sf2ne.nes "$BATTERY"
grep -E "CRASH|COUNTERS|STATS" "$OUT/battery.log"
```

Os scripts de teste são ferramenta de diagnóstico e ficam **fora** do repositório (o aceite do projeto
é manual).

---

## 7. Lições gerais

* **"Funciona para o único caso que existe" não é "está correto".** O despacho foi escrito quando só
  havia Ryu; o índice 0 escondia o erro de passo. Ao adicionar o segundo personagem, o primeiro teste
  tem de ser justamente o índice 1.
* **Truque do `RTS` com tabela de passo 1 só comporta uma entrada.** Se a tabela guarda `endereço-1` e
  o índice avança 1 byte, duas entradas exigem `ASL A` (índice × 2) e uma tabela de verdade. Não
  empilhe a segunda entrada "no meio" da primeira.
* **`JAM` (`$02`) é assinatura de desvio para o vazio.** PC repetindo o mesmo endereço, OAM congelado e
  contagem de instruções muito acima do normal apontam para um `RTS`/`JMP` que caiu fora do código.
* **Um anel de `(PC, banco)` vale mais que um `breakpoint`.** Foi ele que mostrou `$8FE8` (o `RTS`) e
  `$A492` (o `JAM`) na ordem exata, sem precisar adivinhar onde parar.
* **Despachos irmãos merecem a mesma auditoria.** Há outro truque de `RTS` em `$3F:E6E6`
  (`AiCharRoutine`), com **uma** entrada (`RyuAiThink-1`) indexada por `FighterChar,x` (o personagem da
  própria IA). Hoje é seguro porque a única IA é a do Ryu (`x` sempre 0). Se um dia houver IA de Ken,
  esse é o primeiro lugar a corrigir — pelo mesmo motivo.

---

## 8. Arquivos tocados por esta correção

| Arquivo | Mudança |
|---|---|
| `annotations/sf2ne.ann` | comentário + `patch 00:8FE0 AD` e `patch 00:8FE4 AD` (correção) e `patch 3F:F828` (aviso/QR pulados, temporário) |
| `src/bank_00.s` | gerado: `lda D00_9148+1` / `lda D00_9148` (sem `,y`) |
| `src/bank_3F.s` | gerado: 18 `nop` no lugar do `farcall ScreenDisclaimer` |
| `docs/lessons.md` | este documento |
| `README.md` | referência a este documento |
| `build/sf2ne.nes` | ROM canônica com a correção |

O banco `$00` é o único banco de código do Ryu alterado, e apenas nesses dois bytes.

---

## 9. Referências

* NESdev Wiki — [RTS Trick](https://www.nesdev.org/wiki/RTS_Trick): entradas `alvo-1`, o `RTS` soma 1,
  e o launcher precisa ser chamado por `JSR` (ou ser tail-call) para o retorno não se perder.
* NESdev Wiki — [Jump table](https://www.nesdev.org/wiki/Jump_table): índice × 2 para tabela de
  endereços de 16 bits; *split tables* (baixos/altos) indexadas pelo mesmo `X`.
* NESdev Wiki — [6502 assembly optimisations](https://www.nesdev.org/wiki/6502_assembly_optimisations):
  seção "Use Jump tables with RTS instruction instead of JMP indirect".

---

## 10. Apêndice — o que os lotes de naming de dados `$3C`/`$3F` ensinaram

Os primeiros lotes de nomes para labels automáticos de dados (33 labels de `$3C` e 15 de `$3F`, ver
`tasks/DATA_NAMING_3C.md` e `tasks/DATA_NAMING_3F.md`) não mudaram bytes, mas expuseram quatro
armadilhas de leitura:

* **Não classifique um banco pelo endereço.** A triagem inicial tratou `$29`/`$2D` como "IA" porque
  ficam perto do motor; os cabeçalhos gerados mostram que são **música FamiTone2** (173 labels). Ler o
  cabeçalho e o consumidor antes de propor categoria custa menos que refazer o inventário.
* **A métrica canônica de labels é cega para comentário na mesma linha.** O regex
  `^[A-Za-z_][A-Za-z0-9_]*:$` não conta `EdgeARel`, `EdgeBRel` e `EdgeBBtn` (no `$3F`), que têm
  comentário depois dos dois-pontos. Por isso a soma por banco (980 semânticos) difere do total único
  publicado (976). Ao comparar métricas, use sempre o mesmo comando e registre a diferença.
* **Tabelas "por personagem" têm passo fixo — confirme o passo no consumidor.** Em `$3C`, as fichas
  usam 1 byte por personagem (10 bytes por tabela), enquanto as paletas usam 12 bytes por personagem
  (`FighterChar*12`) e os tiles de retrato, 6. Um nome `*Tbl` só é seguro depois de achar a
  multiplicação no código que lê a tabela; e pares `Lo`/`Hi` devem ser nomeados como par, porque um
  deles pode ser lido sem `,y` (caso de `CharDirTransHiTbl` em `3B:E025`).
* **Procure a documentação antes de inferir pelo código.** No lote `$3F`, `docs/FORMATOS.md` §11/§15 já
  descrevia as tabelas de knockback, reação de queda/KO, sfx de impacto e projetil com os mesmos
  endereços. Ler o documento primeiro evitou adivinhar a semântica de `EF06`/`EF20` (knockback X/Y) e
  revelou de passagem vários tamanhos errados no índice de tabelas.
* **O gerador anexa o comentário à linha `.byte`.** Por isso um diff "por linha" acusa dezenas de
  mudanças em dados mesmo quando os operandos são idênticos. A verificação correta compara as diretivas
  `.byte`/`.word` com o comentário removido (ou, mais simples, confia no SHA-1 do ROM).

**Regra prática:** para cada lote, (1) leia o consumidor, (2) proponha nome + confiança, (3) aplique só
labels/comentários, (4) valide com `make gen`, `make` e SHA-1 idêntico, (5) confirme que nenhum operando
`.byte`/`.word` mudou. O SHA-1 é a prova de que o naming é cosmético.
