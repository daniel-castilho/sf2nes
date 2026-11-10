# Ferramentas do projeto

Tudo roda em Linux com `python3` e `cc65`. O emulador (Mesen 2) só é necessário para **gerar novos traces**;
o repositório já traz os traces mesclados em `trace/`, então `make gen` e `make` funcionam sem ele.

```
sudo apt install cc65            # ca65 + ld65
tools/mesen/setup_mesen.sh       # opcional: baixa o Mesen 2.1.1 e deixa pronto para rodar sem janela
```

## Visão geral do fluxo

```
 rom/sf2ne_demo.nes ──┐
 trace/*.txt ─────────┼──> tools/disasm.py ──> src/*.s, sf2ne.cfg, assets/ ──> ca65/ld65 ──> build/sf2ne.nes
 annotations/sf2ne.ann┘        (make gen)                                        (make)        == ROM original
```

* O que é **código** e o que é **dado** não é chute: vem da execução real no emulador (`trace/opstarts.txt`),
  completada por análise estática (alvos de desvio, tabelas de salto, rotinas nunca chamadas).
* O que é **ponteiro** também vem da execução (`trace/pointers.txt`).
* Nomes, comentários e correções ficam em `annotations/sf2ne.ann`. **Nesta fase não edite `src/` à mão** —
  o gerador sobrescreve.

## Makefile

| Comando | O que faz |
|---|---|
| `make` | monta `build/sf2ne.nes` e confere que é **idêntico** ao original (byte a byte) |
| `make gen` | regenera `src/`, `sf2ne.cfg` e `assets/` a partir de ROM + trace + anotações |
| `make fixed` | monta `build/sf2ne_fixed.nes` com as correções opcionais (`-D FIX_SOFT_RESET`) |
| `make fixed FIXDEFS="-D A -D B"` | escolhe quais blocos `alt` ligar: `FIX_SOFT_RESET`, `FIX_HEAVY_ONCE`, `MODE_VERSUS` |
| `make assets` | exporta gráficos (PNG) e vozes (WAV) para `extracted/` |
| `make clean` | apaga `build/` |

## Anotações (`annotations/sf2ne.ann`)

Uma diretiva por linha. `BB:AAAA` = banco:endereço; `K:AAAA` = kernel (vale para os três bancos de código).

| Diretiva | Efeito |
|---|---|
| `label BB:AAAA Nome` | nome de rotina ou tabela |
| `ram AAAA Nome [N]` | nome de variável (N bytes: `Nome`, `Nome+1`, …) |
| `comment BB:AAAA texto` | comentário no fim da linha |
| `block BB:AAAA texto` | comentário de bloco antes do endereço (repita a linha para várias) |
| `code BB:AAAA` / `data BB:AAAA-BBBB` | força código / dados |
| `table BB:AAAA split lo=… hi=… n=… delta=1` | tabela de saltos dividida (as do padrão RTS-trick já são detectadas sozinhas) |
| `table BB:AAAA words n=N` | tabela de ponteiros de 16 bits |
| `ptr BB:AAAA lo\|hi BB:TTTT` | declara à mão metade de um ponteiro (para o que o trace não pegou) |
| `imm BB:AAAA <Rotulo` | escreve à mão o operando de uma instrução imediata (ex.: endereços de RAM) |
| `statebank BB frames=BB from=AAAA to=AAAA` | banco de estados de um lutador: lê cabeçalhos e quadros pela estrutura |
| `ramcode BB:AAAA TAM ORG` | trecho copiado para a RAM e executado lá (o trampolim `FarCall`) |
| `alt SIMBOLO BB:AAAA TAM` + linhas `\|…` | código alternativo montado só com `-D SIMBOLO` (correções opcionais) |

Depois de qualquer mudança: `make gen && make`. Se aparecer `DIFERENTE do original`, a anotação quebrou algo.

## Scripts em `tools/`

| Script | Uso |
|---|---|
| `disasm.py` | o gerador do projeto (é o `make gen`). Imprime estatísticas por banco e avisos. |
| `show.py BB:AAAA [n]` | mostra uma rotina do fonte gerado, com quem chama e em que telas roda |
| `datamap.py 37,3B,3F [-u] [-m N]` | lista as faixas de dados de um banco e se foram lidas (R), tipadas (T) ou nunca tocadas (?) |
| `ptr_candidates.py` | pares de imediatos que **parecem** ponteiros mas o trace não confirmou (revisão manual) |
| `shift_test.sh <banco> [<banco>…]` | teste de realocação: insere 1 byte no começo de cada banco listado e monta `build/shift/…` |
| `extract_chr.py`, `extract_dpcm.py` | exportam gráficos e vozes (`make assets`) |
| `trace_merge.py rom saida dir…` | mescla execuções brutas do emulador em `trace/` |
| `sheet.py out.png colunas escala a.png b.png …` | folha de contato de screenshots |
| `d6502.py`, `tracelib.py` | bibliotecas (tabela de opcodes, leitura de traces) |

Cada rotina no fonte gerado traz duas linhas automáticas:

```
; <- jsr FightersUpdate, tabela StateCondLo          quem chama (JSR, JMP, farcall, tabela de salto)
; modos: intro do round, luta                        em que telas ela executou (ScreenMode)
```

e cada linha de código traz endereço e bytes originais; `(nt)` = nunca executada nos traces.

## Emulador sem janela (`tools/mesen/`)

O Mesen 2 tem um modo `--testrunner` que roda um script Lua sem abrir janela. Detalhes que custaram a descobrir
e que o `setup_mesen.sh` / `run_trace.sh` já resolvem:

* precisa de um `settings.json` **ao lado do executável**, senão abre o assistente de configuração e morre;
* `LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6`, senão aborta com `std::bad_cast`;
* `AllowIoOsAccess: true` para o Lua poder gravar arquivos; `--timeout=N` (o padrão é 100 s);
* `Nes.Port1/Port2 = NesController`, senão `emu.setInput` não faz nada.

| Script | O que registra |
|---|---|
| `cdl.lua` | código executado, leituras de dados (com a instrução que leu), saltos indiretos, uso da RAM, registradores do MMC5, amostras DPCM, em que modo de tela cada instrução rodou, screenshots |
| `ptrtrace.lua` | **ponteiros**, por rastreamento de origem (ver abaixo) |
| `reset_test.lua` / `reset_test.sh` | aperta RESET num quadro escolhido e verifica se o jogo volta |
| `compare_roms.sh A B plano quadros semente` | roda dois ROMs com as mesmas entradas e compara telas, som e linha do tempo |
| `regress.sh ROM` | bateria de 5 partidas contra o original (use depois de mudanças que não deveriam alterar nada) |
| `run_trace.sh <plano> <quadros> <semente> <saida> [shots] [pokes]` | roda um dos scripts acima (`SF2_SCRIPT=…`) |
| `batch1.sh`, `batch2.sh`, `batch3.sh`, `batch_ptr.sh` | os lotes usados para gerar `trace/` |

Planos de entrada: `attract` (não toca em nada), `idle` (entra na luta e fica parado), `p1random` (P1 aleatório,
incluindo comandos de golpes especiais), `p2join`.

Para chegar em caminhos que um jogador aleatório não alcança (vencer, perfect, empate, tempo esgotado, 3º round)
os lotes forçam a RAM: `SF2_HOLD="0E:58:2200:99999,0F:01:2200:99999"` mantém a energia do P1 cheia e a do P2 em 1.

Exemplo:

```
cd tools/mesen
./run_trace.sh p1random 6000 7 /tmp/sf2trace/teste 300        # cdl.lua
SF2_SCRIPT=ptrtrace.lua ./run_trace.sh p1random 6000 7 /tmp/sf2trace/ptr_teste 0
cd ../.. && python3 tools/trace_merge.py rom/sf2ne_demo.nes trace /tmp/sf2trace/*   # mescla tudo de novo
make gen && make
```

(`trace_merge.py` reescreve `trace/` com o que receber: passe sempre **todas** as execuções.)

## Como os ponteiros são descobertos (`ptrtrace.lua`)

Um disassembly que monta idêntico ainda pode ser "engessado": basta um `lda #$8C / ldx #$F9` (endereço `$F98C`
escrito como dois números) para o jogo quebrar quando alguma coisa muda de lugar.

O `ptrtrace.lua` acompanha, para A/X/Y e para cada byte da RAM, **de qual byte do ROM o valor veio** (operando
imediato ou dado lido de tabela). Quando o jogo lê o ROM por `(zp),y`, ou dá `RTS` para um endereço empilhado à mão,
os dois bytes de origem são, com certeza, as metades de um ponteiro — e o endereço lido diz para onde ele aponta.
O gerador então troca os números por símbolos:

```
    lda #<RleSupportScreen        ; era  lda #$8C
    ldx #>RleSupportScreen        ; era  ldx #$F9
    .word D01_A0F6                ; era  .byte $F6,$A0
```

Limite: só enxerga o que foi executado. O que falta é coberto por dois complementos do gerador — entradas de
tabela espremidas entre ponteiros confirmados e a leitura estrutural do banco de estados (`statebank`) — e por
`tools/ptr_candidates.py`, que lista por padrão os pares de imediatos suspeitos para revisão manual.

## Teste de realocação

```
tools/shift_test.sh 00 01 04 20 29 2D 36 3C 37 3B 3F      # desloca os 11 bancos de código e dados
tools/mesen/regress.sh build/shift/sf2ne_shift_00_01_04_20_29_2D_36_3C_37_3B_3F.nes
# -> REGRESSAO OK: comportamento identico nas 5 partidas      (~8 minutos)
```

Se um dia isso falhar depois de novos traces ou anotações, `compare_roms.sh` deixa os screenshots dos dois ROMs
lado a lado no diretório temporário que ele informa: o primeiro quadro diferente mostra onde procurar.
