# Mapa de RAM (o que já é conhecido)

A lista completa de endereços usados, com contagem de leituras/escritas, está em `src/ram.inc` (gerado) e, com
**quais instruções** tocam cada endereço, em `trace/ram.txt`. Aqui ficam só as variáveis identificadas.

Como foram achadas: despejo da RAM a cada quadro durante partidas inteiras (`SF2_RAMDUMP=1`), cruzado com os
screenshots, mais leitura do código que as usa. Para confirmar uma hipótese, force o valor no emulador
(`SF2_HOLD="endereço:valor:de:até"`) e veja o que muda.

## Lutadores — vetores de 2 posições (`,x` com X = 0 para P1, 1 para P2)

| Endereço | Nome | Significado |
|---|---|---|
| `$00` | `FighterChar` | personagem (0 = Ryu; `$FF` = nenhum) |
| `$02` | `FighterIsCpu` | 0 = humano, 1 = CPU. `MainLoop` fixa P1 = 0, P2 = 1 |
| `$04` | `FighterFlip` | `$40` = espelhado (olhando para a esquerda) |
| `$06` / `$08` | `FighterXSub` / `FighterX` | posição X (fração / pixel). Início do round: `$5A` e `$A6` |
| `$0A` / `$0C` | `FighterYSub` / `FighterY` | posição Y. Chão = `$CD` |
| `$0E` | `FighterHP` | energia. Cheia = `$58` (88); negativa = nocauteado |
| `$10` | `FighterWins` | rounds vencidos |
| `$14` | `FighterDmgPending` | dano ainda não descontado (a barra desce aos poucos) |
| `$18` | `FighterFrameBank` | banco dos frames (janela `$8000`) |
| `$1A` | `FighterStateBank` | banco dos estados (janela `$A000`) |
| `$1E` / `$20` | `FighterStatePtrLo/Hi` | estado atual (cabeçalho no banco de estados) |
| `$22` / `$24` | `FighterNextPtrLo/Hi` | próximo estado escolhido por `StateCheckTransitions` |
| `$26` | `FighterState` | byte do estado: 5 bits altos = classe, 3 baixos = flags |
| `$2A` / `$2C` | `FighterFramePtrLo/Hi` | quadro de animação atual |
| `$30` / `$32` | `FighterVelXSub` / `FighterVelX` | velocidade X (com sinal) |
| `$34` / `$36` | `FighterVelYSub` / `FighterVelY` | velocidade Y |
| `$40` | `FighterChrPage` | página de CHR dos sprites do lutador (vai para `$5121` / `$5123`) |
| `$42` | `FighterAnimTimer` | quadros restantes do quadro de animação atual |
| `$69` / `$6B` | `AiScriptPtrLo/Hi` | roteiro de IA em execução |

Ainda sem nome, mas claramente por lutador (pares): `$12`, `$16`, `$1C`, `$28`, `$2E`, `$38`, `$3A`–`$3F`, `$44`–`$63`,
`$6D`–`$A9` (inclui o estado do reconhecedor de comandos: `CmdMotionStep` `$90`–`$9B` e `CmdMotionWin`
`$9E`–`$A9`, 6 entradas × 2 lutadores intercaladas — §13 do `docs/FORMATOS.md`), e `$0300`–`$0345`
(ficha carregada do banco `$3C`).

## Sistema

| Endereço | Nome | Significado |
|---|---|---|
| `$64` / `$65` | `CurFighter` / `OtherFighter` | índices do lutador sendo processado e do oponente |
| `$66`–`$68` | `RngState` | gerador pseudo-aleatório (`RandomSeed` põe `"2FS"`) |
| `$AC` | `VBlankFlag` | o NMI põe 1; os laços de tela esperam por ela |
| `$AD` | `OamIndex` | próximo byte livre da OAM neste quadro |
| `$B0` | `ScreenMode` | 0 aviso, 1 título, 2 seleção, 3 VS, 4 intro do round, 5 luta, 6 fim do round, 7 frase |
| `$B1` | `FrameCounter` | incrementado no NMI |
| `$B4` | `AiLevel` | nível da IA (0–7). `MainLoop` fixa 7 |
| `$B5` | `TimerOff` | ≠ 0 desliga o relógio (**hipótese**; sempre 0 no demo) |
| `$B6` / `$B7` | `RoundStep` / `RoundStepTimer` | passo e contador das sequências de intro e fim de round |
| `$B8` | `RoundNumber` | 0 = primeiro round |
| `$B9` | `RoundResult` | `$FF` em andamento, 0 = P1 venceu, 1 = P2 venceu, 2 = empate |
| `$BA` / `$BB` | `TimerOnes` / `TimerTens` | dígitos do relógio |
| `$BC`–`$D3` | `PaletteBuf` | 24 cores (8 paletas × 3) |
| `$D4` | `PaletteDirty` | ≠ 0: o NMI envia a paleta |
| `$D5`–`$E4` | — | temporários de uso geral (ponteiros, coordenadas, argumentos) |
| `$ED` / `$EE` | `PpuCtrlShadow` / `PpuMaskShadow` | cópias de `$2000` / `$2001` |
| `$EF` / `$F0` | `ScrollX` / `ScrollY` | rolagem |
| `$F2` | `JoyState` (×2) | botões apertados agora |
| `$F6` | `JoyPrev` (×2) | botões do quadro anterior |
| `$FA`–`$FD` | `RlePtr`, `RleTag`, `RleLast` | descompactador RLE |

Bits do controle: A `$80`, B `$40`, Select `$20`, Start `$10`, Cima `$08`, Baixo `$04`, Esquerda `$02`, Direita `$01`.

## Páginas `$01`–`$07`

| Faixa | Uso |
|---|---|
| `$0100`–`$018B` | variáveis do FamiTone2 (`FT_BASE_ADR = $0100`); a pilha usa o topo da página |
| `$0200`–`$02FF` | `OamBuf` — cópia da OAM |
| `$0300`–`$0345` | ficha dos lutadores (ponteiros de estados básicos), pares P1/P2 |
| `$034E`–`$0389` | buffer de retrato |
| `$0392`–`$03AD` | textos do HUD escritos pelo IRQ de menu |
| `$03B6` / `$03B7` | `CameraX` (fração / pixel) |
| `$03BB` | `FloorLines` — linhas do chão em paralaxe |
| `$03BF`… / `$03DF`… | `FloorScrollX` — rolagem de cada linha do chão |
| `$03FF` | `IrqStage` — etapa atual do IRQ |
| `$0400`–`$040B` | parâmetros da divisão de tela |
| `$040C` | `HitStop` — congelamento após um golpe |
| `$0426`–`$043A` | tiles das barras de energia |
| `$045E` | `VoiceQueued` — voz a tocar / continuação (`$FF` = nenhuma) |
| `$045F` | `MusicBank` |
| `$046B`–`$047E` | extensões do FamiTone2 (slides) |
| `$0485`–`$049C` | `FadePalette` — paleta de destino do fade |
| `$049E`–`$04B1` | `FarCall` — trampolim das chamadas entre bancos (código na RAM) |
