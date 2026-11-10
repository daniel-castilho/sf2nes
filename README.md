# Street Fighter II NE (DEMO, Parisoft) — código-fonte reconstruído

Disassembly **remontável** do demo de NES `Street Fighter II – Nostalgic Edition`, feito para estudo e para
continuar o jogo. O fonte é assembly 6502 para o `ca65` (a mesma ferramenta que o autor usa).

```
make          # monta build/sf2ne.nes e confere: IDÊNTICO ao ROM original, byte a byte
make fixed    # monta build/sf2ne_fixed.nes com a correção do travamento no soft reset
make fixed FIXDEFS="-D FIX_SOFT_RESET -D MODE_VERSUS"       # idem + modo versus (P2 no controle 2)
make fixed FIXDEFS="-D FIX_SOFT_RESET -D FIX_HEAVY_ONCE"    # idem + golpe forte sem repetição (experimental)
make prontos  # remonta as três variantes jogáveis em prontos/
make assets   # exporta os gráficos (PNG) e as 31 vozes (WAV) para extracted/
make gen      # regenera src/ depois de editar annotations/sf2ne.ann
```

Requisitos: `python3` e `cc65` (`sudo apt install cc65`). O emulador só é preciso para gerar traces novos.

## O que está pronto (e verificado)

| | |
|---|---|
| **Monta idêntico** | `make` reproduz o ROM de 1.048.592 bytes; SHA-1 `0bf9dc57…a9aed`. |
| **Realocável** | Todos os 11 bancos de código e dados deslocados em 1 byte ao mesmo tempo (44.892 bytes diferentes) → o jogo roda **igual ao original**: mesmas telas, mesmo som, mesmo resultado, em 5 partidas de teste de 9.000–12.000 quadros. Ou seja: dá para inserir e remover código e dados. |
| **Código × dados** | Separação tirada da execução real no emulador (7.805 instruções vistas em 28 partidas roteirizadas) + análise estática. Cobertura por banco: `$00` 96%, `$37` 83%, `$3B` 98%, `$3F` 86%. |
| **Ponteiros simbólicos** | 114 pares de imediatos e 2.550 bytes de dados descobertos por rastreamento de origem no emulador; mais 187 completados pela estrutura das tabelas. |
| **Estrutura entendida** | mapa do cartucho e do MMC5, kernel de IRQ/NMI, chamadas entre bancos, fluxo das telas, laço da luta, som (FamiTone2), diretório de vozes, ficha de personagem, **formato do banco de estados** (71 estados, 274 quadros). |
| **Bugs** | travamento no soft reset: causa encontrada, corrigido (14 bytes por banco) e testado. Atraso e repetição dos comandos: causa encontrada e medida (`InputButtons`). |
| **Achados** | o motor já roda **2 jogadores** — falta só ligar (opção `MODE_VERSUS`, 1 byte); o elenco planejado de 10 lutadores, com nomes e frases, está no ROM; o Ken tem 4,3 KB de frames prontos que nunca são usados. |

Leia nesta ordem:

1. [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md) — como o jogo funciona por dentro.
2. [`docs/RAM.md`](docs/RAM.md) — variáveis conhecidas.
3. [`docs/BUGS.md`](docs/BUGS.md) — bugs relatados: o que já foi resolvido e onde estão os outros.
4. [`docs/ROTEIRO.md`](docs/ROTEIRO.md) — o caminho para terminar o jogo, e como usar IA nisso sem se enganar.
5. [`docs/FERRAMENTAS.md`](docs/FERRAMENTAS.md) — scripts, formato das anotações, emulador sem janela.

## O que ainda **não** está pronto

* **Nomes.** Há 1.793 rótulos; 161 têm nome de verdade (`Main`, `FightFrame`, `DrawMetasprite`, `InputButtons`,
  `FamiToneUpdate`…). O resto ainda é `L3F_E4DA`, `D01_A4CB`. Das variáveis, 78 têm nome. É o grosso do trabalho
  que falta na fase de entendimento — e é onde a IA mais ajuda.
* **Formatos de dados parcialmente documentados:** metasprites e estados estão entendidos; caixas de colisão,
  bytes 5–10 do quadro de animação, opcodes dos roteiros de IA e condições de transição ainda não.
* **Código nunca executado** (14–17% dos bancos `$37` e `$3F`): veio de análise estática. São sobretudo recursos
  não usados do FamiTone2 e ramos raros do motor. Está desmontado, mas não foi exercitado.
* **Vozes:** o diretório de amostras guarda endereço/64; mover uma amostra exige mexer na tabela à mão.

## Organização

```
rom/sf2ne_demo.nes        o ROM original (referência para a conferência)
annotations/sf2ne.ann     NOMES, COMENTÁRIOS e CORREÇÕES — o arquivo que você edita
trace/                    o que o emulador observou (código, leituras, ponteiros, modos de tela…)
src/                      fonte ca65 GERADO (um arquivo por banco + kernel.inc, ram.inc, hw.inc, macros.inc)
assets/                   CHR e bancos de vozes, incluídos com .incbin
tools/                    gerador, extratores, testes; tools/mesen/ = scripts do emulador
docs/                     documentação
extracted/                PNGs e WAVs (make assets)
prontos/                  ROMs já montados para jogar: reset corrigido, modo versus, golpe forte único
ref/                      bibliotecas públicas do autor (familib, pa65, yanct) para comparação
build/                    saída da montagem (não versionar)
```

## Fluxo de trabalho

**Fase atual — anotação.** `src/` é gerado; não edite à mão.

```
tools/show.py 3F:E4DA 60          # lê uma rotina (mostra quem chama e em que telas ela roda)
$EDITOR annotations/sf2ne.ann     # label / ram / comment / block ...
make gen && make                  # tem que continuar dizendo "idêntico"
```

**Fase seguinte — modificação.** Quando quiser mudar o jogo de verdade (não só corrigir no lugar), há dois caminhos:

* mudanças pequenas e opcionais: blocos `alt` nas anotações (é como a correção do reset foi feita) — o `make`
  continua provando que o original está intacto e `make fixed` monta a versão alterada;
* mudanças grandes: congelar `src/` (parar de rodar `make gen`) e editar o assembly diretamente. A partir daí o
  teste deixa de ser "idêntico ao original" e passa a ser `tools/mesen/compare_roms.sh` (mesmas entradas, mesmas
  telas e som) para tudo que **não** deveria mudar.

## Uso

Projeto de estudo, para uso pessoal. O ROM e os dados extraídos pertencem aos seus autores.
