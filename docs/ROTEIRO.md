# Roteiro: do demo ao jogo terminado

## Resposta curta à pergunta original

> "É possível fazer engenharia reversa, obter o código-fonte e terminar o projeto usando IA?"

**Sim, e a primeira metade já está feita.** Este repositório é o código-fonte reconstruído: monta idêntico ao ROM,
é realocável (dá para inserir código e dados) e a arquitetura do jogo está mapeada. Em jogos de NES não existe
"decompilar para C": o original foi escrito em assembly 6502, então o fonte reconstruído **é** assembly — o que
se recupera com trabalho são os nomes e os comentários, não uma linguagem de nível mais alto.

O que muda de figura é o tamanho de "terminar":

* **o motor está pronto e é dirigido por dados** — estados, animações, IA, comandos e vozes de um lutador são
  tabelas, não código. Isso é a melhor notícia possível para quem quer acrescentar personagens;
* **mas só o Ryu tem conteúdo.** Dos outros nove do elenco planejado existem nome, frase, voz do país e (para sete)
  o retrato. O Ken tem 4,3 KB de frames prontos e nunca usados. Cada lutador novo é sobretudo trabalho de
  **arte e dados**: sprites, estados, caixas de colisão, roteiros de IA, vozes.

Para referência, o Ryu sozinho tem 71 estados e 274 quadros de animação.
Programação: semanas. Conteúdo de um elenco inteiro: muito mais que isso. Planeje por lutador.

---------------------------------------------------------------------------------------------------

## Etapas

### Etapa 0 — base (feita)

- [x] fonte que monta idêntico (`make`)
- [x] código × dados e ponteiros tirados da execução real
- [x] fonte realocável, com teste automático (`shift_test.sh` + `regress.sh`)
- [x] arquitetura, mapa de RAM, formato do banco de estados
- [x] extração de gráficos e vozes
- [x] travamento no soft reset corrigido
- [x] causa do atraso/repetição de comandos encontrada e medida
- [x] modo versus (2 jogadores) destravado como opção de montagem

### Etapa 1 — entender o motor (feita — o resultado está em `docs/FORMATOS.md`)

- [x] **As 12 condições de transição** (`StateCond00`–`0B`, `3F:E189`–`E296`) — §4
- [x] **Os bytes do quadro** (+5…+11): efeito, dano, tipo de golpe, flags, movimento — §6–§8
- [x] **Caixas de colisão** (`00:91C1`…) e as rotinas de acerto/dano — §10/§11
- [x] **O reconhecedor de comandos** e o `InputDispatch`/`GuardRedirect` — §13 (fechado na fase 2.0
  da Etapa 2: os 5 tratadores `CmdStep*` decodificados; carga/3×botão/A+B seguem `(nt)` no trace)
- [x] **Os 18 opcodes dos roteiros de IA** e a lógica de `RyuAiThink` — §14
- [x] As oito tabelas do início do banco de estados (`$A000`–`$A0AF`) — §1/§13
- [x] O resto: projétil (hadouken) — §12 — e física do pulo (§8, integração de `VelY`); HUD e
  seleção de personagem ficaram fora do escopo
- [ ] nomear os ~276 rótulos `L3F_*` que sobraram no banco `$3F` — 82 no bloco de movimento
  (`F0A5`–`F648`, descritos em `docs/FORMATOS.md` §8), 194 espalhados em rotinas auxiliares;
  renomear cada um ao mexer nele na Etapa 2

Meta da etapa — um documento `docs/FORMATOS.md` com cada estrutura de dados descrita campo a
campo, lida no código e conferida no ROM: **feita** (com `(hipótese)` e `(nt)` marcados onde a
leitura não é garantida). A parte "nenhum rótulo `L3F_xxxx`" não fechou: sobram os ~276 acima.

### Etapa 2 — corrigir e destravar o que já existe

Decidido: as 4 decisões abaixo, tudo em blocos `alt`/`FIXDEFS` (opt-in) — o caminho padrão segue byte a
byte idêntico; Ken e conteúdo de personagem ficam para a Etapa 3; **sem testes nesta etapa** (a
validação fica para depois, registrada como pendência, não como critério).

- [x] **2.0** documentar o reconhecedor de comandos por inteiro — §13: os 5 tratadores `CmdStep*`,
  `CmdMotionTbl`/`CmdKeyAttackTbl`/listas de chaves, estado intercalado `CmdMotionStep`/`CmdMotionWin`,
  consumo no `InputDispatch`
- [x] **2.1** comandos: golpe na borda de subida do botão + promoção fraco→forte (ver `docs/BUGS.md` §2.1) —
  feito como `FIX_EDGE_ATTACK`: `InputButtons` (`3F:E99A–E9FB`) reescrito num bloco só + marcador seletivo
  `EdgeMarkHold` (`$F949`) no lugar da gravação cega de `$15`; `-D FIX_HEAVY_ONCE` continua independente e é
  subsumido quando o `FIX_EDGE_ATTACK` está ligado; validação de jogabilidade pendente
- [ ] **2.2** dificuldade: SELECT na seleção alterna Fácil/Normal/Difícil (`AiLevel` 2/4/7,
  padrão 4) + ler/documentar a IA — depende da 2.0
- [ ] **2.3** versus: P2 entra com START na tela de seleção, HUD "PRESS START" → "P2", P2 travado no
  Ryu (sem seleção de personagem para o P2) — o motor em si já funciona com dois humanos
  (`-D MODE_VERSUS`, testado; ver `docs/BUGS.md`)
- [ ] **2.4** fim de partida: frase do vencedor → volta ao título (hoje volta ao aviso de demo)

Fora do escopo desta etapa (ficam para depois): IA menos mecânica além do seletor de dificuldade,
próximo adversário/tela de continue, frase do vencedor por personagem.

### Etapa 3 — segundo lutador (Ken)

É o caso mais barato: os frames já estão no banco `$04` e ele é quase um Ryu.

1. conferir os gráficos: `make assets` e localizar os tiles do Ken nas páginas de CHR;
2. banco de estados do Ken: copiar o do Ryu para um banco livre da janela `$A000` (`$05`), trocando os ponteiros de
   metasprite para o banco `$04` — com o fonte realocável é copiar e renomear rótulos, não recalcular endereços;
3. preencher a **coluna 1** das tabelas da ficha (`3C:8000`–`80E5`) e `CharStateBankTbl`;
4. IA: entrada em `AiCharRoutine` (pode reaproveitar `RyuAiThink` no começo);
5. vozes: coluna 1 de `FighterVoiceTbl`; paleta; liberar o cursor da tela de seleção;
6. acrescentar `statebank 05 frames=04 from=… to=…` nas anotações (ou, se o fonte já estiver congelado, nada).

Quando o Ken funcionar, o caminho para os outros está provado; o que sobra é arte.

### Etapa 4 — ferramentas de conteúdo

Editar estados em `.byte` não escala. Antes do terceiro lutador vale construir:

- [ ] conversor **PNG → CHR + metasprites** (o autor tem o `yanct`, em `ref/`; veja se serve);
- [ ] um formato de texto para estados/quadros (macros do ca65 ou um script) no lugar de bytes soltos;
- [ ] conversor WAV → DPCM alinhado em 64 bytes, atualizando o diretório de vozes.

### Etapa 5 — cenários, músicas, finais

Há 36 bancos de PRG vazios e 198 páginas de CHR livres: espaço não é o problema. O banco `$3B` (código da luta) está
cheio — código novo vai para um banco novo da janela `$E000` (`$33`, `$2F`…), que precisa da sua cópia do kernel:
basta um arquivo `bank_33.s` com `.include "kernel.inc"` no mesmo endereço e os vetores no fim.

---------------------------------------------------------------------------------------------------

## Como usar IA neste projeto sem se enganar

A IA é muito boa em ler 40 linhas de 6502 e dizer o que fazem. Ela é ruim em saber se está certa. O projeto foi
montado para que **toda afirmação possa ser conferida por máquina**:

| O que a IA propõe | Como conferir |
|---|---|
| um nome ou comentário | `make gen && make` → continua idêntico (um nome nunca muda um byte) |
| "esta variável é a energia do P2" | `SF2_HOLD="0F:01:2200:99999"` e ver a partida; ou despejo por quadro (`SF2_RAMDUMP=1`) |
| "esta rotina só roda na seleção" | a linha `; modos:` acima da rotina já diz onde ela executou |
| "isto é um ponteiro" | `trace/pointers.txt`; se não estiver lá, rode `ptrtrace.lua` num cenário que passe por ali |
| uma mudança que não deveria alterar nada | `tools/mesen/regress.sh build/…nes` |
| uma correção | um script de teste que falha antes e passa depois (modelo: `reset_test.lua`) |

### Ciclo de trabalho (usado na Etapa 1; vale para as próximas)

1. Escolha uma rotina sem nome: `python3 tools/show.py 3F:E189 60`.
2. Dê à IA **junto**: a rotina, as rotinas que ela chama, o trecho de `docs/RAM.md` e `docs/ARQUITETURA.md`
   pertinente. As linhas `; <-` (quem chama) e `; modos:` já vêm na saída do `show.py`.
3. Peça uma **hipótese com teste**: "o que esta rotina faz, que nome você daria, e que experimento no emulador
   confirmaria ou derrubaria isso?".
4. Rode o experimento. Só então grave em `annotations/sf2ne.ann` (`label`, `ram`, `comment`, `block`).
5. `make gen && make`. Commit.

O arquivo de anotações é a memória do projeto: cada sessão nova de IA começa lendo `docs/` e `annotations/` e
continua de onde a anterior parou, sem depender do histórico da conversa.

### Armadilhas conhecidas

* **Nome plausível, errado.** Não aceite nome sem evidência. Marque palpites como palpite (`comment … (hipótese)`).
* **Código contado em ciclos.** O `IrqHandler` e a leitura de controle não podem mudar de duração. Não deixe a IA
  "limpar" esses trechos.
* **Banco `$3B` cheio.** Qualquer acréscimo ali estoura o banco; o montador avisa (`.assert` do kernel).
* **Opcode não oficial.** `axs #imm` (`$CB`) é usado de propósito; alguns emuladores antigos não o suportam.
* **Código nunca executado** (`(nt)` no fonte): desmontado por análise estática. Trate como menos confiável até
  um teste passar por ele.
* **Cobertura dos testes.** `regress.sh` cobre o que o demo permite jogar com o Ryu. Quando houver conteúdo novo,
  acrescente cenários.

### Se você nunca programou em 6502

Dá para começar pelos dados. Trocar a duração de um quadro, o dano de um golpe ou um roteiro de IA é editar
números numa tabela e ver o resultado — e é exatamente assim que os formatos da Etapa 1 se descobrem.
O assembly entra aos poucos, lendo rotinas curtas com a IA ao lado. Referência rápida de 6502:
<https://www.nesdev.org/obelisk-6502-guide/reference.html>; sobre o MMC5: <https://www.nesdev.org/wiki/MMC5>.
