# Street Fighter II NE (DEMO, Parisoft) — código-fonte reconstruído

Disassembly **remontável** do demo de NES `Street Fighter II – Nostalgic Edition`, feito para estudo e para
continuar o jogo. O fonte é assembly 6502 para o `ca65` (a mesma ferramenta que o autor usa).

```
make          # monta build/sf2ne.nes (build canônico: ROM modificada, com o Ken jogável)
make verify   # conferência HISTÓRICA opcional: compara o build com o ROM original
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
| **Reconstrução histórica** | A reconstrução original (sem os `patch` do Ken) reproduz o ROM de 1.048.592 bytes; SHA-1 `0bf9dc57…a9aed`. `make verify` faz essa conferência e avisa que o build com o Ken diverge. |
| **Ken jogável (P1)** | Selecionável com A (vermelho) ou B (azul), luta contra Ryu CPU. A coluna 0 (Ryu) permanece byte a byte intocada. O travamento nos golpes especiais foi diagnosticado e corrigido (2 bytes no despacho anti-aéreo da IA); o passo a passo está em [`docs/lessons.md`](docs/lessons.md). Moveset completo e aceite manual ainda pendentes. |
| **Realocável** | Todos os 11 bancos de código e dados deslocados em 1 byte ao mesmo tempo (44.892 bytes diferentes) → o jogo roda **igual ao original**: mesmas telas, mesmo som, mesmo resultado, em 5 partidas de teste de 9.000–12.000 quadros. Ou seja: dá para inserir e remover código e dados. |
| **Código × dados** | Separação tirada da execução real no emulador (7.805 instruções vistas em 28 partidas roteirizadas) + análise estática. Cobertura por banco: `$00` 96%, `$37` 83%, `$3B` 98%, `$3F` 86%. |
| **Ponteiros simbólicos** | 114 pares de imediatos e 2.550 bytes de dados descobertos por rastreamento de origem no emulador; mais 187 completados pela estrutura das tabelas. |
| **Estrutura entendida** | mapa do cartucho e do MMC5, kernel de IRQ/NMI, chamadas entre bancos, fluxo das telas, laço da luta, som (FamiTone2), diretório de vozes, ficha de personagem, **formato do banco de estados** (71 estados, 274 quadros). |
| **Bugs** | travamento no soft reset: causa encontrada, corrigido (14 bytes por banco) e testado. Atraso e repetição dos comandos: causa encontrada e medida (`InputButtons`). |
| **Achados** | o motor já roda **2 jogadores** — falta só ligar (opção `MODE_VERSUS`, 1 byte); o elenco planejado de 10 lutadores, com nomes e frases, está no ROM; o Ken tem 4,3 KB de frames prontos agora integrados ao banco $05; modos versus e single player funcionam. |

Leia nesta ordem:

1. [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md) — como o jogo funciona por dentro.
2. [`docs/RAM.md`](docs/RAM.md) — variáveis conhecidas.
3. [`docs/BUGS.md`](docs/BUGS.md) — bugs relatados: o que já foi resolvido e onde estão os outros.
4. [`docs/ROTEIRO.md`](docs/ROTEIRO.md) — o caminho para terminar o jogo, e como usar IA nisso sem se enganar.
5. [`docs/FERRAMENTAS.md`](docs/FERRAMENTAS.md) — scripts, formato das anotações, emulador sem janela.
6. [`docs/lessons.md`](docs/lessons.md) — lições aprendidas: como o travamento do Ken nos golpes especiais foi diagnosticado e corrigido (sintoma, traço de PC, causa raiz, correção e verificação).

## O que ainda **não** está pronto

**Foco atual — estabilização e manutenibilidade.** A implementação de novos personagens e funcionalidades de jogo está pausada, não cancelada. O próximo ciclo de trabalho será definido após a Fase 3 de naming (`tasks/NAMING_CANDIDATES.md`, `docs/ESTADO_DO_PROJETO.md` e `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`).

Há 2.145 definições de rótulo (2.141 nomes únicos): **928 semânticos** e **1.213 automáticos de dados**
  (`D01_A4CB`…). **Não resta nenhum rótulo automático de código** (`L3F_E4DA`…): os lotes P0/P1, P2 e
  FamiTone2 da Fase 3 nomearam os 379 que existiam. Das variáveis, 78 têm nome. O inventário completo está
  em `tasks/NAMING_CANDIDATES.md`.
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

**Fase atual — estabilização e manutenibilidade (apenas documentação).** Nenhum novo personagem ou funcionalidade de jogo está sendo implementado nesta fase. `src/` permanece gerado a partir de `annotations/sf2ne.ann`; não edite à mão. A próxima etapa de implementação será definida após a auditoria documental da Fase 1.

```
tools/show.py 3F:E4DA 60          # lê uma rotina (mostra quem chama e em que telas ela roda)
$EDITOR annotations/sf2ne.ann     # label / ram / comment / block / patch / keepbank ...
make gen && make                  # regenera src/ e monta o build canônico
make verify                       # opcional: confere a reconstrução histórica contra o ROM original
```

Alterações em bancos gerados (ficha do Ken, paleta, seleção e stub de IA) são declaradas como `patch` nas
anotações, no offset **+1** da coluna do personagem; assim `make gen` não apaga o Ken e a coluna 0 do Ryu
continua intocada.

**Fase seguinte — modificação.** Quando quiser mudar o jogo de verdade (não só corrigir no lugar), há três caminhos:

* mudanças pequenas e opcionais: blocos `alt` nas anotações (é como a correção do reset foi feita) e
  `make fixed` monta a variante;
* dados novos ou correções que devem entrar no build canônico: diretivas `patch` (bytes) e `keepbank` (fonte
  mantida à mão) nas anotações — é assim que a ficha, a paleta, a seleção e o stub de IA do Ken são ligados;
* mudanças grandes que não passam pelo gerador: congelar o banco em `src/` e editá-lo à mão, como em
  `src/bank_05.s`; nesse caso o teste deixa de ser "idêntico ao original" e passa a ser
  `tools/mesen/compare_roms.sh` (mesmas entradas, mesmas telas e som) para tudo que **não** deveria mudar.

## Uso

Projeto de estudo, para uso pessoal. O ROM e os dados extraídos pertencem aos seus autores.

## Implementacao do Segundo Lutor (Ken) - Fase 6: Entrega

### Status Atual

A implementacao do Ken esta dividida em 6 fases conforme especificada em `tasks/KEN_IMPLEMENTATION_SPEC.md`:

| Fase | Conquista | Status |
|------|-----------|--------|
| **Fase 1** | Banco relocavel em $A000-$BFFF com 10 estados definidos | ✅ Concluida |
| **Fase 2** | Estados com cabecalhos e quadros usando sprites banco $04 | ✅ Concluida |
| **Fase 3** | Column 1 (Ken) conectado a D05_A10B | ✅ Concluida |
| **Fase 4** | Ken selecionavel, CPU permanece Ryu em single player | ✅ Concluida |
| **Fase 5** | Build produz ROM modificada sem comparacao byte-a-byte | ✅ Concluida |

### Arquivos Modificados

- `src/bank_05.s`: Banco relocavel de estados em $A000-$BFFF com 10 estados
- `src/bank_3C.s`: Column 1 (Ken) alterada de $00 para $05
- `src/globals.inc`: Símbolos D05_ exportados para linking cross-bank
- `sf2ne.cfg`: Ja continha segmento BANK05

### Build e ROM

```
make clean && make
# SHA1: 843a869e6f61c076ae1f8cfbd0b6cea073c164f6
```

### Aleacao

- **Versus mode, P1/P2=Ken**: Jogo usa bank $05 states + bank $04 graphics
- **Single player**: CPU permanece como Ryu (comportamento nativo)
- **Movimentos especiais**: Hadouken, Shoryuken, Tatsumaki estruturados no banco $05

### Limitações

- Implementacao estrutural (Fases 1-5): gameplay completo ainda requer Fases 5-6
- Sem IA propria de Ken: Em modo single player, o oponente continua Ryu
- Sem testes automatizados: Aceite manual recomendado

### Hash da ROM Entregue

`843a869e6f61c076ae1f8cfbd0b6cea073c164f6`
