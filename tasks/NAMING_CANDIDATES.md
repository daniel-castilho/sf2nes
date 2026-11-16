# Inventário completo de naming — Fase 3

- **Status:** executado e verificado — lotes P0/P1 (Gate D), P2, PAD e FamiTone2.
- **Fonte canônica:** `annotations/sf2ne.ann` (editada; `src/` regenerado por `make gen`).
- **ROM de verificação:** `build/sf2ne.nes` — SHA-1 `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`.
- **Linha de base (Fase 1):** 379 rótulos automáticos de código, 1.213 de dados, 549 semânticos.
- **Estado atual:** 0 rótulos automáticos de código; 1.213 de dados; 928 semânticos únicos; 2.141 nomes únicos em 2.145 definições.
  *Este é o retrato do fim da Fase 3. Depois dele, o lote de dados `$3C` renomeou 33 labels (`tasks/DATA_NAMING_3C.md`), levando a 1.180 automáticos de dados e 961 semânticos únicos — ver `docs/ESTADO_DO_PROJETO.md` §11.*
- **Escopo:** somente rótulos e comentários; nenhum byte de código ou dado foi alterado.
- **Data:** 2026-11-15

---

## 1. Como ler este inventário

- **ID:** identificador novo, único e sequencial (`N-001`…`N-388`), para referência estável.
- **ID anterior:** ID do inventário preliminar, quando existia. IDs repetidos no inventário antigo receberam a marca `(duplicado)`; `—` indica que não havia ID anterior.
- **Símbolo anterior:** nome no fonte gerado antes do lote (`L<bb>_<aaaa>` para código automático, ou nome semântico em português).
- **Símbolo aplicado:** nome atual em `annotations/sf2ne.ann`.
- **Evidência:** resumo do comentário canônico e do fluxo estático que sustenta o nome; para FamiTone2, a referência é a estrutura pública v1.15.
- **Confiança:** `ALTA` = papel demonstrado por fluxo/chamadas ou estrutura oficial; `MÉDIA` = papel provável, porém com menos confirmação. Não há `BAIXA` neste lote.
- **Risco:** `Baixo` em todas as linhas — a alteração é apenas de rótulo/comentário e o ROM permaneceu idêntico.
- **Decisão:** `ACEITO` = aplicado e verificado por build/SHA-1.

### 1.1 Correções ao inventário preliminar

- **`C3F-01`:** o nome proposto era `TimerUpdate`; a leitura do fluxo mostrou que o bloco define `FighterFlip`, então o nome aplicado é **`TimerUpdateFlip`**.
- **`C3B-04` e `C3B-05`:** linhas fantasmas (`StageSplitSetup`/`StageSplitContinue`, `3B:F015`/`3B:F027`) removidas — não há rótulos automáticos nesses endereços nem evidência de divisão de tela ali.
- **`C37-01`:** placeholder (`37:XXXX`, `SelectDrawFighterLoop`) removido — não tinha endereço nem evidência.
- **IDs duplicados `C3F-04`…`C3F-08`:** eliminados. O ID antigo permanece na coluna “ID anterior” com a marca `(duplicado)`, e cada linha tem agora um `N-xxx` único.
- **Contagem do lote P2:** **251** renomeações aplicadas (não 245). Inclui as duas linhas de reconciliação do projétil (`DrawFightersProjectile` e `DrawProjectileMetasprite`), que separam o teste de existência do desenho propriamente dito.

---

## 2. Resumo por lote

| Lote | Escopo | Linhas | Bancos | Verificação |
|------|--------|--------|--------|-------------|
| **P0/P1** (Gate D) | Núcleo do motor, vetores, temporizador, input, retrato, HUD, metasprites, projétil | 21 | `$3F` 10, `$3B` 11 | `make` + SHA-1 idêntico |
| **P2** | Motor de estados, luta, telas, IA do Ryu, som/telas | 251 | `$00` 48, `$37` 49, `$3B` 142, `$3F` 12 | `make` + SHA-1 idêntico |
| **PAD** | Condições de transição padronizadas em inglês | 7 | `$3F` 7 | `make` + SHA-1 idêntico |
| **FT2** | Motor de som FamiTone2 (interno + rotinas de topo) | 109 | `$37` 109 | `make` + SHA-1 idêntico |
| **Total** | — | **388** | — | — |

> **PAD:** 14 condições foram padronizadas para inglês. Sete já existiam como nomes semânticos e aparecem na tabela PAD; as outras sete nasceram no lote P2 e já aparecem com o nome final na tabela P2.

> **FT2:** 109 mapeamentos = 107 rótulos internos `_FT2*` + 2 rotinas de topo (`VoicePlayFighterEnd`, `SoundUpdateMusic`). Quatro rótulos `_FT2*` já existiam antes do lote (`37:E6DD`, `37:E6DF`, `37:E6F6`, `37:E719`) e não foram renomeados.

---

## 3. Inventário completo

### 3.1 Lote P0/P1 — Gate D (21)

| ID | ID anterior | Banco | Endereço | Símbolo anterior | Símbolo aplicado | Categoria | Evidência | Confiança | Prioridade | Risco | Decisão |
|----|-------------|-------|----------|------------------|------------------|-----------|-----------|-----------|------------|-------|---------|
| N-001 | C3B-01 | `$3B` | `3B:E0A0` | `L3B_E0A0` | `PortraitLoadPalettesLoop` | Código | laco de copia de paletas dentro de PortraitLoadPalettes | MÉDIA | P1 | Baixo | ACEITO |
| N-002 | C3B-02 | `$3B` | `3B:E131` | `L3B_E131` | `FighterFlipSet` | Código | define o bit de espelhamento (FighterFlip) do lutador | ALTA | P1 | Baixo | ACEITO |
| N-003 | C3B-03 | `$3B` | `3B:E165` | `L3B_E165` | `PortraitPaletteCopyLoop` | Código | laco de copia de 3 bytes de paleta para ram_0300/0303/0306 | MÉDIA | P1 | Baixo | ACEITO |
| N-004 | C3B-06 | `$3B` | `3B:F27F` | `L3B_F27F` | `DrawProjectile` | Código | desenha o projetil (hadouken) do lutador | ALTA | P1 | Baixo | ACEITO |
| N-005 | C3B-07 | `$3B` | `3B:F2B5` | `L3B_F2B5` | `DrawProjectileSprite` | Código | desenha o sprite do projetil na OAM | ALTA | P1 | Baixo | ACEITO |
| N-006 | C3B-08 | `$3B` | `3B:F315` | `L3B_F315` | `DrawMetaspritePosition` | Código | posiciona um grupo de metasprite na tela | ALTA | P1 | Baixo | ACEITO |
| N-007 | C3B-09 | `$3B` | `3B:F324` | `L3B_F324` | `DrawMetaspriteGroupLoop` | Código | laco de grupos de metasprite | ALTA | P1 | Baixo | ACEITO |
| N-008 | C3B-10 | `$3B` | `3B:F331` | `L3B_F331` | `DrawMetaspriteWriteOAM` | Código | escreve um sprite na OAM | ALTA | P1 | Baixo | ACEITO |
| N-009 | C3B-11 | `$3B` | `3B:F356` | `L3B_F356` | `DrawMetaspriteEnd` | Código | termino do desenho de metasprite | ALTA | P1 | Baixo | ACEITO |
| N-010 | C3B-12 | `$3B` | `3B:F364` | `L3B_F364` | `SelectDrawBlinkDraw` | Código | desenha o lutador piscando na tela de selecao | MÉDIA | P1 | Baixo | ACEITO |
| N-011 | C3B-13 | `$3B` | `3B:F37D` | `L3B_F37D` | `SelectScreenBuildPaletteLoop` | Código | laco de copia de paletas na construcao da tela de selecao | MÉDIA | P1 | Baixo | ACEITO |
| N-012 | C3F-08 | `$3F` | `3F:E0F2` | `L3F_E0F2` | `StateCondDispatchLoop` | Código | loop de despacho das condições de transição de estado | ALTA | P0 | Baixo | ACEITO |
| N-013 | C3F-04 (duplicado) | `$3F` | `3F:E111` | `L3F_E111` | `StateCondTableEntry` | Código | entrada da tabela de condições de transição | ALTA | P1 | Baixo | ACEITO |
| N-014 | C3F-05 (duplicado) | `$3F` | `3F:E11D` | `L3F_E11D` | `StateCondTableContinue` | Código | continuação da tabela de condições | ALTA | P1 | Baixo | ACEITO |
| N-015 | C3F-01 | `$3F` | `3F:EFF5` | `L3F_EFF5` | `TimerUpdateFlip` | Código | define FighterFlip no loop do temporizador (chamado por FightFrame) | ALTA | P0 | Baixo | ACEITO |
| N-016 | C3F-02 | `$3F` | `3F:EFF7` | `L3F_EFF7` | `TimerUpdateContinue` | Código | continuação do loop do temporizador | MÉDIA | P0 | Baixo | ACEITO |
| N-017 | C3F-03 | `$3F` | `3F:F927` | `L3F_F927` | `JoyReadLoop` | Código | loop de leitura de bits do controle dentro de JoyRead | ALTA | P0 | Baixo | ACEITO |
| N-018 | C3F-04 | `$3F` | `3F:FFBE` | `L3F_FFBE` | `ResetVector37` | Código/Dados | vetor de reset do banco $37 | ALTA | P0 | Baixo | ACEITO |
| N-019 | C3F-05 | `$3F` | `3F:FFC4` | `L3F_FFC4` | `ResetVector3B` | Código/Dados | vetor de reset do banco $3B | ALTA | P0 | Baixo | ACEITO |
| N-020 | C3F-06 | `$3F` | `3F:FFDD` | `L3F_FFDD` | `ResetVector3F` | Código/Dados | vetor de reset do banco $3F | ALTA | P0 | Baixo | ACEITO |
| N-021 | C3F-07 | `$3F` | `3F:FFE6` | `L3F_FFE6` | `NmiVector` | Código/Dados | vetor de NMI comum aos bancos de código | ALTA | P0 | Baixo | ACEITO |

### 3.2 Lote P2 — localizado (251)

| ID | ID anterior | Banco | Endereço | Símbolo anterior | Símbolo aplicado | Categoria | Evidência | Confiança | Prioridade | Risco | Decisão |
|----|-------------|-------|----------|------------------|------------------|-----------|-----------|-----------|------------|-------|---------|
| N-022 | — | `$00` | `00:8F5C` | `L00_8F5C` | `RyuAiAirDistY` | Código | IA do Ryu: no ar, exige distancia vertical < $38 | ALTA | P2 | Baixo | ACEITO |
| N-023 | — | `$00` | `00:8F66` | `L00_8F66` | `RyuAiAirDistX` | Código | IA do Ryu: no ar, exige distancia horizontal < $38 | ALTA | P2 | Baixo | ACEITO |
| N-024 | — | `$00` | `00:8F70` | `L00_8F70` | `RyuAiAirVelCheck` | Código | IA do Ryu: no ar, so age se o proprio pulo termina ou o oponente esta no ar | ALTA | P2 | Baixo | ACEITO |
| N-025 | — | `$00` | `00:8F7F` | `L00_8F7F` | `RyuAiAirScriptPick` | Código | IA do Ryu: no ar, escolhe o roteiro pela classe de estado | ALTA | P2 | Baixo | ACEITO |
| N-026 | — | `$00` | `00:8F8F` | `L00_8F8F` | `RyuAiAirScriptDefault` | Código | IA do Ryu: no ar, roteiro padrao ($00:8EFB) | ALTA | P2 | Baixo | ACEITO |
| N-027 | — | `$00` | `00:8F96` | `L00_8F96` | `RyuAiProjCheck` | Código | IA do Ryu: o oponente tem projetil no ar? | ALTA | P2 | Baixo | ACEITO |
| N-028 | — | `$00` | `00:8FA5` | `L00_8FA5` | `RyuAiProjAbsDist` | Código | IA do Ryu: distancia horizontal ate o projetil | ALTA | P2 | Baixo | ACEITO |
| N-029 | — | `$00` | `00:8FAB` | `L00_8FAB` | `RyuAiProjDistDiv16` | Código | IA do Ryu: distancia do projetil / 16 | ALTA | P2 | Baixo | ACEITO |
| N-030 | — | `$00` | `00:8FB8` | `L00_8FB8` | `RyuAiProjDistDiv32` | Código | IA do Ryu: distancia do projetil / 32 | ALTA | P2 | Baixo | ACEITO |
| N-031 | — | `$00` | `00:8FC2` | `L00_8FC2` | `RyuAiProjDistDiv64` | Código | IA do Ryu: distancia do projetil / 64 (longe demais: nao faz nada) | ALTA | P2 | Baixo | ACEITO |
| N-032 | — | `$00` | `00:8FC8` | `L00_8FC8` | `RyuAiProjScriptMid` | Código | IA do Ryu: projetil a 32-64 px -> roteiro $00:8E82 | ALTA | P2 | Baixo | ACEITO |
| N-033 | — | `$00` | `00:8FCF` | `L00_8FCF` | `RyuAiOpponentHitState` | Código | IA do Ryu: sem projetil; o oponente esta em reacao de golpe? | ALTA | P2 | Baixo | ACEITO |
| N-034 | — | `$00` | `00:8FE9` | `L00_8FE9` | `RyuAiOpponentWalkCheck` | Código | IA do Ryu: o oponente esta andando (classe >= $54)? | ALTA | P2 | Baixo | ACEITO |
| N-035 | — | `$00` | `00:8FFC` | `L00_8FFC` | `RyuAiOpponentJumpUp` | Código | IA do Ryu: o oponente esta subindo | ALTA | P2 | Baixo | ACEITO |
| N-036 | — | `$00` | `00:900F` | `L00_900F` | `RyuAiJumpDistCheck` | Código | IA do Ryu: distancia horizontal do oponente que esta subindo | ALTA | P2 | Baixo | ACEITO |
| N-037 | — | `$00` | `00:9016` | `L00_9016` | `RyuAiJumpScriptMid` | Código | IA do Ryu: oponente subindo a 40-96 px -> roteiro $00:8F0A | ALTA | P2 | Baixo | ACEITO |
| N-038 | — | `$00` | `00:901D` | `L00_901D` | `RyuAiOpponentGrounded` | Código | IA do Ryu: o oponente esta no chao | ALTA | P2 | Baixo | ACEITO |
| N-039 | — | `$00` | `00:9028` | `L00_9028` | `RyuAiOpponentDistX` | Código | IA do Ryu: distancia horizontal ate o oponente que anda | ALTA | P2 | Baixo | ACEITO |
| N-040 | — | `$00` | `00:903D` | `L00_903D` | `RyuAiOpponentDistY` | Código | IA do Ryu: sorteia entre dois roteiros conforme a distancia vertical | ALTA | P2 | Baixo | ACEITO |
| N-041 | — | `$00` | `00:9055` | `L00_9055` | `RyuAiOpponentTooFar` | Código | IA do Ryu: oponente longe demais -> nao faz nada | ALTA | P2 | Baixo | ACEITO |
| N-042 | — | `$00` | `00:905C` | `L00_905C` | `RyuAiOpponentScript` | Código | IA do Ryu: oponente perto -> roteiro $00:8F1B | ALTA | P2 | Baixo | ACEITO |
| N-043 | — | `$00` | `00:9063` | `L00_9063` | `RyuAiOpponentSpecial` | Código | IA do Ryu: oponente com estado especial (zp_62) -> roteiro $00:8ECA | ALTA | P2 | Baixo | ACEITO |
| N-044 | — | `$00` | `00:906F` | `L00_906F` | `RyuAiOpponentStateHigh` | Código | IA do Ryu: classe de estado do oponente >= $58? | ALTA | P2 | Baixo | ACEITO |
| N-045 | — | `$00` | `00:907B` | `L00_907B` | `RyuAiState58Check` | Código | IA do Ryu: classe >= $69 tem outro tratamento | ALTA | P2 | Baixo | ACEITO |
| N-046 | — | `$00` | `00:9089` | `L00_9089` | `RyuAiState58DistDiv8` | Código | IA do Ryu: distancia horizontal / 8 | ALTA | P2 | Baixo | ACEITO |
| N-047 | — | `$00` | `00:9095` | `L00_9095` | `RyuAiState58DistDiv16` | Código | IA do Ryu: distancia horizontal / 16 | ALTA | P2 | Baixo | ACEITO |
| N-048 | — | `$00` | `00:9098` | `L00_9098` | `RyuAiState58Script32` | Código | IA do Ryu: roteiro $00:8F32 | ALTA | P2 | Baixo | ACEITO |
| N-049 | — | `$00` | `00:909F` | `L00_909F` | `RyuAiState58DistDiv32` | Código | IA do Ryu: distancia horizontal / 32 (longe: nao faz nada) | ALTA | P2 | Baixo | ACEITO |
| N-050 | — | `$00` | `00:90A5` | `L00_90A5` | `RyuAiState58Random` | Código | IA do Ryu: sorteia o roteiro conforme a postura do oponente | ALTA | P2 | Baixo | ACEITO |
| N-051 | — | `$00` | `00:90C3` | `L00_90C3` | `RyuAiState58Script` | Código | IA do Ryu: roteiro $00:8EAD | ALTA | P2 | Baixo | ACEITO |
| N-052 | — | `$00` | `00:90CA` | `L00_90CA` | `RyuAiState69Dist` | Código | IA do Ryu: classe >= $69, calcula a distancia horizontal | ALTA | P2 | Baixo | ACEITO |
| N-053 | — | `$00` | `00:90D4` | `L00_90D4` | `RyuAiState69DistDiv8` | Código | IA do Ryu: distancia horizontal / 8 | ALTA | P2 | Baixo | ACEITO |
| N-054 | — | `$00` | `00:90F5` | `L00_90F5` | `RyuAiState69DistDiv16` | Código | IA do Ryu: distancia horizontal / 16 | ALTA | P2 | Baixo | ACEITO |
| N-055 | — | `$00` | `00:910C` | `L00_910C` | `RyuAiState69DistDiv32` | Código | IA do Ryu: distancia horizontal / 32 (longe: nao faz nada) | ALTA | P2 | Baixo | ACEITO |
| N-056 | — | `$00` | `00:9113` | `L00_9113` | `RyuAiState69Random` | Código | IA do Ryu: sorteia entre 4 roteiros | ALTA | P2 | Baixo | ACEITO |
| N-057 | — | `$00` | `00:912B` | `L00_912B` | `RyuAiState69RandomNow` | Código | IA do Ryu: sorteia entre 2 roteiros (execucao imediata) | ALTA | P2 | Baixo | ACEITO |
| N-058 | — | `$00` | `00:9159` | `L00_9159` | `RyuAiAntiAirDist` | Código | IA anti-aereo: distancia horizontal ate o oponente no ar | ALTA | P2 | Baixo | ACEITO |
| N-059 | — | `$00` | `00:9163` | `L00_9163` | `RyuAiAntiAirRange` | Código | IA anti-aereo: distancia < $28? | ALTA | P2 | Baixo | ACEITO |
| N-060 | — | `$00` | `00:916F` | `L00_916F` | `RyuAiAntiAirVelCheck` | Código | IA anti-aereo: o oponente esta descendo? | ALTA | P2 | Baixo | ACEITO |
| N-061 | — | `$00` | `00:9174` | `L00_9174` | `RyuAiAntiAirScript8E9F` | Código | IA anti-aereo: roteiro $00:8E9F | ALTA | P2 | Baixo | ACEITO |
| N-062 | — | `$00` | `00:917B` | `L00_917B` | `RyuAiAntiAirVelCheck2` | Código | IA anti-aereo (perto): o oponente esta descendo? | ALTA | P2 | Baixo | ACEITO |
| N-063 | — | `$00` | `00:9183` | `L00_9183` | `RyuAiAntiAirVelCheck3` | Código | IA anti-aereo (perto): o oponente esta parado? | ALTA | P2 | Baixo | ACEITO |
| N-064 | — | `$00` | `00:9188` | `L00_9188` | `RyuAiAntiAirScript8F11` | Código | IA anti-aereo: roteiro $00:8F11 | ALTA | P2 | Baixo | ACEITO |
| N-065 | — | `$00` | `00:918F` | `L00_918F` | `RyuAiAntiAirStateCheck` | Código | IA anti-aereo: classes $D0/$D8 do oponente | ALTA | P2 | Baixo | ACEITO |
| N-066 | — | `$00` | `00:9197` | `L00_9197` | `RyuAiAntiAirDist2` | Código | IA anti-aereo ($D0/$D8): distancia horizontal | ALTA | P2 | Baixo | ACEITO |
| N-067 | — | `$00` | `00:91A5` | `L00_91A5` | `RyuAiAntiAirDist3` | Código | IA anti-aereo ($D0/$D8): distancia < $10? | ALTA | P2 | Baixo | ACEITO |
| N-068 | — | `$00` | `00:91B0` | `L00_91B0` | `RyuAiAntiAirScript8F29` | Código | IA anti-aereo ($D0/$D8): roteiro $00:8F29 | ALTA | P2 | Baixo | ACEITO |
| N-069 | — | `$00` | `00:91B7` | `L00_91B7` | `RyuAiAntiAirEnd` | Código | IA anti-aereo: nenhuma acao | ALTA | P2 | Baixo | ACEITO |
| N-070 | — | `$37` | `37:EFBF` | `L37_EFBF` | `SelectInitP2Char` | Código | selecao: carrega o lutador do P2 (zp_D8) e a paleta (zp_13) | ALTA | P2 | Baixo | ACEITO |
| N-071 | — | `$37` | `37:EFD0` | `L37_EFD0` | `SelectWaitFlagClear` | Código | selecao: inicia a espera do proximo vblank | ALTA | P2 | Baixo | ACEITO |
| N-072 | — | `$37` | `37:EFD4` | `L37_EFD4` | `SelectWaitVBlank` | Código | selecao: espera o vblank do laco | ALTA | P2 | Baixo | ACEITO |
| N-073 | — | `$37` | `37:EFFA` | `L37_EFFA` | `SelectDrawCursor` | Código | selecao: desenha o cursor e a bandeira do pais na posicao atual | ALTA | P2 | Baixo | ACEITO |
| N-074 | — | `$37` | `37:F052` | `L37_F052` | `SelectDrawFighterSprite` | Código | selecao: desenha o lutador sob o cursor | ALTA | P2 | Baixo | ACEITO |
| N-075 | — | `$37` | `37:F076` | `L37_F076` | `SelectConfirmVoice` | Código | selecao: P1 confirmou -> toca a voz do pais escolhido | ALTA | P2 | Baixo | ACEITO |
| N-076 | — | `$37` | `37:F10E` | `L37_F10E` | `SelectIntroDrawFighter` | Código | entrada do lutador escolhido: desenha o lutador | ALTA | P2 | Baixo | ACEITO |
| N-077 | — | `$37` | `37:F124` | `L37_F124` | `SelectIntroFlagClear` | Código | entrada do lutador: inicia a espera do proximo vblank | ALTA | P2 | Baixo | ACEITO |
| N-078 | — | `$37` | `37:F128` | `L37_F128` | `SelectIntroWaitVBlank` | Código | entrada do lutador: espera o vblank | ALTA | P2 | Baixo | ACEITO |
| N-079 | — | `$37` | `37:F155` | `L37_F155` | `SelectIntroFlagClear2` | Código | entrada do lutador: 2o inicio de espera do vblank | ALTA | P2 | Baixo | ACEITO |
| N-080 | — | `$37` | `37:F159` | `L37_F159` | `SelectIntroWaitVBlank2` | Código | entrada do lutador: 2o vblank da animacao | ALTA | P2 | Baixo | ACEITO |
| N-081 | — | `$37` | `37:F18C` | `L37_F18C` | `SelectIntroHideOam` | Código | entrada do lutador: esconde os sprites restantes da OAM | ALTA | P2 | Baixo | ACEITO |
| N-082 | — | `$37` | `37:F1E7` | `L37_F1E7` | `SelectInputRead` | Código | selecao: o jogador ainda nao confirmou -> le o controle | ALTA | P2 | Baixo | ACEITO |
| N-083 | — | `$37` | `37:F1EE` | `L37_F1EE` | `SelectInputUp` | Código | selecao: botao CIMA (novo flanco) -> cursor 4 casas para tras | ALTA | P2 | Baixo | ACEITO |
| N-084 | — | `$37` | `37:F20C` | `L37_F20C` | `SelectInputDown` | Código | selecao: botao BAIXO (novo flanco) -> cursor 4 casas para frente | ALTA | P2 | Baixo | ACEITO |
| N-085 | — | `$37` | `37:F246` | `L37_F246` | `SelectInputRight` | Código | selecao: botao DIREITA (novo flanco) -> cursor 1 casa para frente | ALTA | P2 | Baixo | ACEITO |
| N-086 | — | `$37` | `37:F271` | `L37_F271` | `SelectInputButtonB` | Código | selecao: botao B -> zera a flag de confirmacao (zp_D7,x) | ALTA | P2 | Baixo | ACEITO |
| N-087 | — | `$37` | `37:F281` | `L37_F281` | `SelectEndVoice` | Código | selecao: toca a voz enfileirada | ALTA | P2 | Baixo | ACEITO |
| N-088 | — | `$37` | `37:F292` | `L37_F292` | `SelectEnd` | Código | fim da tela de selecao | ALTA | P2 | Baixo | ACEITO |
| N-089 | — | `$37` | `37:F2DD` | `L37_F2DD` | `DisclaimerClearRows` | Código | aviso/QR: limpa 4 linhas de 256 tiles da nametable | ALTA | P2 | Baixo | ACEITO |
| N-090 | — | `$37` | `37:F2DF` | `L37_F2DF` | `DisclaimerClearCols` | Código | aviso/QR: limpa as colunas da linha | ALTA | P2 | Baixo | ACEITO |
| N-091 | — | `$37` | `37:F324` | `L37_F324` | `DisclaimerTextFlagClear` | Código | aviso/QR: inicia a espera do vblank do texto | ALTA | P2 | Baixo | ACEITO |
| N-092 | — | `$37` | `37:F328` | `L37_F328` | `DisclaimerTextWaitVBlank` | Código | aviso/QR: espera o vblank do texto | ALTA | P2 | Baixo | ACEITO |
| N-093 | — | `$37` | `37:F33C` | `L37_F33C` | `DisclaimerTextAddr` | Código | aviso/QR: calcula o endereco da nametable do proximo caractere | ALTA | P2 | Baixo | ACEITO |
| N-094 | — | `$37` | `37:F356` | `L37_F356` | `DisclaimerTextLineReset` | Código | aviso/QR: fim de linha -> volta para a primeira coluna | ALTA | P2 | Baixo | ACEITO |
| N-095 | — | `$37` | `37:F35A` | `L37_F35A` | `DisclaimerTextWrite` | Código | aviso/QR: escreve o caractere na nametable | ALTA | P2 | Baixo | ACEITO |
| N-096 | — | `$37` | `37:F370` | `L37_F370` | `DisclaimerEndFlagClear` | Código | aviso/QR: espera o fim do texto | ALTA | P2 | Baixo | ACEITO |
| N-097 | — | `$37` | `37:F374` | `L37_F374` | `DisclaimerEndWaitVBlank` | Código | aviso/QR: espera o vblank do fim do texto | ALTA | P2 | Baixo | ACEITO |
| N-098 | — | `$37` | `37:F4A9` | `L37_F4A9` | `SupportWaitFlagClear` | Código | tela de apoio: inicia a espera do vblank | ALTA | P2 | Baixo | ACEITO |
| N-099 | — | `$37` | `37:F4AD` | `L37_F4AD` | `SupportWaitVBlank` | Código | tela de apoio: espera o vblank | ALTA | P2 | Baixo | ACEITO |
| N-100 | — | `$37` | `37:F4B5` | `L37_F4B5` | `SupportInputFlagClear` | Código | tela de apoio: inicia a espera do vblank da leitura do controle | ALTA | P2 | Baixo | ACEITO |
| N-101 | — | `$37` | `37:F4B9` | `L37_F4B9` | `SupportInputWaitVBlank` | Código | tela de apoio: espera o vblank antes de ler o controle | ALTA | P2 | Baixo | ACEITO |
| N-102 | — | `$37` | `37:F4D9` | `L37_F4D9` | `SupportExit` | Código | tela de apoio: sai com o fade | ALTA | P2 | Baixo | ACEITO |
| N-103 | — | `$37` | `37:F524` | `L37_F524` | `TitlePaletteCopyLoop` | Código | titulo: copia 12 bytes de paleta | ALTA | P2 | Baixo | ACEITO |
| N-104 | — | `$37` | `37:F557` | `L37_F557` | `TitleClearRows` | Código | titulo: limpa as linhas da nametable | ALTA | P2 | Baixo | ACEITO |
| N-105 | — | `$37` | `37:F558` | `L37_F558` | `TitleClearCols` | Código | titulo: limpa as colunas da linha | ALTA | P2 | Baixo | ACEITO |
| N-106 | — | `$37` | `37:F592` | `L37_F592` | `TitleWaitVBlank` | Código | titulo: espera o vblank do laco | ALTA | P2 | Baixo | ACEITO |
| N-107 | — | `$37` | `37:F5BB` | `L37_F5BB` | `TitleWaitOverflowClear` | Código | titulo: espera o flag de overflow de sprites do PPU | ALTA | P2 | Baixo | ACEITO |
| N-108 | — | `$37` | `37:F5C0` | `L37_F5C0` | `TitleWaitVBlankStart` | Código | titulo: espera o inicio do vblank | ALTA | P2 | Baixo | ACEITO |
| N-109 | — | `$37` | `37:F5C7` | `L37_F5C7` | `TitleDelayLoop` | Código | titulo: espera de sincronizacao (256 voltas) | ALTA | P2 | Baixo | ACEITO |
| N-110 | — | `$37` | `37:F5E6` | `L37_F5E6` | `TitleScrollStep` | Código | titulo: avanca a rolagem horizontal do titulo | ALTA | P2 | Baixo | ACEITO |
| N-111 | — | `$37` | `37:F601` | `L37_F601` | `TitleCheckStart` | Código | titulo: o START ja foi apertado? | ALTA | P2 | Baixo | ACEITO |
| N-112 | — | `$37` | `37:F616` | `L37_F616` | `TitleBlinkOn` | Código | titulo: acende o "PRESS START" e le os controles | ALTA | P2 | Baixo | ACEITO |
| N-113 | — | `$37` | `37:F62F` | `L37_F62F` | `TitleCheckButtons` | Código | titulo: procura START/A/B nos dois controles | ALTA | P2 | Baixo | ACEITO |
| N-114 | — | `$37` | `37:F63B` | `L37_F63B` | `TitleStartPressed` | Código | titulo: botao apertado -> guarda e toca a voz | ALTA | P2 | Baixo | ACEITO |
| N-115 | — | `$37` | `37:F645` | `L37_F645` | `TitleCheckPalette` | Código | titulo: apaga o "PRESS START" ou sai da tela | ALTA | P2 | Baixo | ACEITO |
| N-116 | — | `$37` | `37:F652` | `L37_F652` | `TitleExit` | Código | titulo: para a musica e sai com o fade | ALTA | P2 | Baixo | ACEITO |
| N-117 | — | `$37` | `37:F67B` | `L37_F67B` | `TitleBlinkOffLoop` | Código | titulo: apaga as 10 cores do "PRESS START" | ALTA | P2 | Baixo | ACEITO |
| N-118 | — | `$37` | `37:F682` | `L37_F682` | `TitleBlinkOnLoop` | Código | titulo: escreve as 10 cores do "PRESS START" | ALTA | P2 | Baixo | ACEITO |
| N-119 | C3B-14 | `$3B` | `3B:E1A6` | `L3B_E1A6` | `PortraitPalPtr2Add` | Código | em PortraitLoadPalettes: soma o offset do lutador no 2o ponteiro de paleta | ALTA | P2 | Baixo | ACEITO |
| N-120 | C3B-15 | `$3B` | `3B:E1B1` | `L3B_E1B1` | `PortraitPalPtr3Add` | Código | em PortraitLoadPalettes: soma o offset do lutador no 3o ponteiro de paleta | ALTA | P2 | Baixo | ACEITO |
| N-121 | C3B-16 | `$3B` | `3B:E1BB` | `L3B_E1BB` | `PortraitPalIndexCalc` | Código | indice da paleta dentro do lutador (zp_12,x * 3) | ALTA | P2 | Baixo | ACEITO |
| N-122 | C3B-17 | `$3B` | `3B:E1C6` | `L3B_E1C6` | `PortraitPalCopyLoop` | Código | copia as 3 paletas (9 bytes) do lutador para ram_0300/ram_0303/ram_0306 | ALTA | P2 | Baixo | ACEITO |
| N-123 | C3B-18 | `$3B` | `3B:E201` | `L3B_E201` | `PortraitClearLoop` | Código | limpa o buffer de pixels do retrato (ram_034E+) | ALTA | P2 | Baixo | ACEITO |
| N-124 | C3B-19 | `$3B` | `3B:E20E` | `L3B_E20E` | `PortraitDecodeNextChunk` | Código | em PortraitBuild: proximo bloco do decodificador de retrato | ALTA | P2 | Baixo | ACEITO |
| N-125 | C3B-20 | `$3B` | `3B:E230` | `L3B_E230` | `PortraitDecodePixelLoop` | Código | em PortraitBuild: escreve os pixels do bloco em ram_034E,x | ALTA | P2 | Baixo | ACEITO |
| N-126 | — | `$3B` | `3B:E241` | `L3B_E241` | `PortraitRowShiftSetup` | Código | fim dos blocos: desloca as linhas do retrato (6 pixels) com a cor +1 | ALTA | P2 | Baixo | ACEITO |
| N-127 | — | `$3B` | `3B:E247` | `L3B_E247` | `PortraitRowShift1` | Código | 1a linha do grupo copiada de ram_034E para ram_0354 | ALTA | P2 | Baixo | ACEITO |
| N-128 | — | `$3B` | `3B:E252` | `L3B_E252` | `PortraitRowShift2` | Código | 2a linha do grupo | ALTA | P2 | Baixo | ACEITO |
| N-129 | — | `$3B` | `3B:E25C` | `L3B_E25C` | `PortraitRowShift3` | Código | 3a linha do grupo | ALTA | P2 | Baixo | ACEITO |
| N-130 | — | `$3B` | `3B:E266` | `L3B_E266` | `PortraitRowShift4` | Código | 4a linha do grupo | ALTA | P2 | Baixo | ACEITO |
| N-131 | — | `$3B` | `3B:E270` | `L3B_E270` | `PortraitRowShift5` | Código | 5a linha do grupo | ALTA | P2 | Baixo | ACEITO |
| N-132 | — | `$3B` | `3B:E27A` | `L3B_E27A` | `PortraitRowShift6` | Código | 6a linha do grupo | ALTA | P2 | Baixo | ACEITO |
| N-133 | — | `$3B` | `3B:E284` | `L3B_E284` | `PortraitRowShiftEnd` | Código | proximo grupo de linhas (X -= $0C) | ALTA | P2 | Baixo | ACEITO |
| N-134 | — | `$3B` | `3B:E294` | `L3B_E294` | `VsStageIndex` | Código | tela VS: indice do cenario (x2) para as tabelas do banco $36 | ALTA | P2 | Baixo | ACEITO |
| N-135 | — | `$3B` | `3B:E381` | `L3B_E381` | `RoundStageIndex` | Código | inicio do round: indice do cenario (x2) para as tabelas do banco $36 | ALTA | P2 | Baixo | ACEITO |
| N-136 | — | `$3B` | `3B:E397` | `L3B_E397` | `StagePaletteCopyLoop` | Código | copia 12 bytes da paleta do cenario para PaletteBuf | ALTA | P2 | Baixo | ACEITO |
| N-137 | — | `$3B` | `3B:E3CE` | `L3B_E3CE` | `RleNextByte` | Código | PpuUnRle: le o proximo byte do stream RLE | ALTA | P2 | Baixo | ACEITO |
| N-138 | — | `$3B` | `3B:E3D5` | `L3B_E3D5` | `RleIsMarker` | Código | o byte e' o marcador? entao e' uma repeticao | ALTA | P2 | Baixo | ACEITO |
| N-139 | — | `$3B` | `3B:E3E0` | `L3B_E3E0` | `RleRepeatCount` | Código | le a quantidade de repeticoes (0 = fim do stream) | ALTA | P2 | Baixo | ACEITO |
| N-140 | — | `$3B` | `3B:E3E9` | `L3B_E3E9` | `RleLastByte` | Código | le o ultimo byte literal para repetir | ALTA | P2 | Baixo | ACEITO |
| N-141 | — | `$3B` | `3B:E3EC` | `L3B_E3EC` | `RleWriteLoop` | Código | escreve o byte repetido no PPUDATA | ALTA | P2 | Baixo | ACEITO |
| N-142 | — | `$3B` | `3B:E3F4` | `L3B_E3F4` | `RleEnd` | Código | fim do stream RLE | ALTA | P2 | Baixo | ACEITO |
| N-143 | — | `$3B` | `3B:E3FB` | `L3B_E3FB` | `PpuWrite64Loop` | Código | copia 64 bytes crus para o PPUDATA | ALTA | P2 | Baixo | ACEITO |
| N-144 | — | `$3B` | `3B:E42C` | `L3B_E42C` | `FadeOut_WaitVBlank` | Código | fade-out: espera o vblank antes de mexer na paleta | ALTA | P2 | Baixo | ACEITO |
| N-145 | — | `$3B` | `3B:E443` | `L3B_E443` | `FadeOut_WaitOverflowClear` | Código | fade-out: espera o flag de overflow de sprites do PPU | ALTA | P2 | Baixo | ACEITO |
| N-146 | — | `$3B` | `3B:E448` | `L3B_E448` | `FadeOut_WaitVBlankStart` | Código | fade-out: espera o inicio do vblank | ALTA | P2 | Baixo | ACEITO |
| N-147 | — | `$3B` | `3B:E455` | `L3B_E455` | `FadeOut_RoundEndPath` | Código | fade-out no fim do round: redesenha os lutadores com a paleta de fade | ALTA | P2 | Baixo | ACEITO |
| N-148 | — | `$3B` | `3B:E493` | `L3B_E493` | `FadeOut_StoreColor` | Código | grava a cor escurecida | ALTA | P2 | Baixo | ACEITO |
| N-149 | — | `$3B` | `3B:E496` | `L3B_E496` | `FadeOut_NextColor` | Código | proxima cor do fade (24 cores) | ALTA | P2 | Baixo | ACEITO |
| N-150 | — | `$3B` | `3B:E4A6` | `L3B_E4A6` | `FadeOut_WaitNextFrame` | Código | fade-out: espera mais 32 quadros antes de aplicar o PPU | ALTA | P2 | Baixo | ACEITO |
| N-151 | — | `$3B` | `3B:E4AA` | `L3B_E4AA` | `FadeOut_WaitVBlankFinal` | Código | fade-out: espera o vblank final | ALTA | P2 | Baixo | ACEITO |
| N-152 | — | `$3B` | `3B:E4F3` | `L3B_E4F3` | `FadeIn_WaitVBlank` | Código | fade-in: espera o vblank antes de marcar a paleta | ALTA | P2 | Baixo | ACEITO |
| N-153 | — | `$3B` | `3B:E509` | `L3B_E509` | `FadeIn_WaitVBlankStage1` | Código | fade-in na luta: espera o vblank para dividir a tela | ALTA | P2 | Baixo | ACEITO |
| N-154 | — | `$3B` | `3B:E517` | `L3B_E517` | `FadeIn_WaitVBlankStage2` | Código | fade-in na luta: segundo vblank antes do parallax | ALTA | P2 | Baixo | ACEITO |
| N-155 | — | `$3B` | `3B:E521` | `L3B_E521` | `FadeIn_PpuMask` | Código | fade-in: ajusta a mascara do PPU ($18) | ALTA | P2 | Baixo | ACEITO |
| N-156 | — | `$3B` | `3B:E529` | `L3B_E529` | `FadeIn_VBlankFlagClear` | Código | fade-in: inicia a espera do proximo vblank | ALTA | P2 | Baixo | ACEITO |
| N-157 | — | `$3B` | `3B:E52D` | `L3B_E52D` | `FadeIn_WaitVBlankLoop` | Código | fade-in: espera o vblank de cada degrau | ALTA | P2 | Baixo | ACEITO |
| N-158 | — | `$3B` | `3B:E55F` | `L3B_E55F` | `FadeIn_StepPrepare` | Código | fade-in: prepara o degrau (24 cores) | ALTA | P2 | Baixo | ACEITO |
| N-159 | — | `$3B` | `3B:E561` | `L3B_E561` | `FadeIn_ColorLoop` | Código | fade-in: clareia as cores dentro da faixa do degrau | ALTA | P2 | Baixo | ACEITO |
| N-160 | — | `$3B` | `3B:E576` | `L3B_E576` | `FadeIn_NextColor` | Código | fade-in: proxima cor | ALTA | P2 | Baixo | ACEITO |
| N-161 | — | `$3B` | `3B:E5A9` | `L3B_E5A9` | `RoundIntro_HudFixedP1` | Código | intro do round: P1 humano -> texto fixo 'P1' | ALTA | P2 | Baixo | ACEITO |
| N-162 | — | `$3B` | `3B:E5E4` | `L3B_E5E4` | `RoundIntro_HudScrollP2` | Código | intro do round: P2 e' CPU -> inicia o texto rolando | ALTA | P2 | Baixo | ACEITO |
| N-163 | — | `$3B` | `3B:E5FD` | `L3B_E5FD` | `RoundIntro_HudBarFill` | Código | preenche as barras de energia dos dois lutadores (tiles $70) | ALTA | P2 | Baixo | ACEITO |
| N-164 | — | `$3B` | `3B:E60A` | `L3B_E60A` | `RoundIntro_HudBarFill2` | Código | segunda linha das barras de energia (tiles $78) | ALTA | P2 | Baixo | ACEITO |
| N-165 | — | `$3B` | `3B:E62F` | `L3B_E62F` | `RoundIntro_HudTimerBlank` | Código | sem cronometro na tela: limpa os digitos do relogio | ALTA | P2 | Baixo | ACEITO |
| N-166 | — | `$3B` | `3B:E659` | `L3B_E659` | `RoundIntro_NameP1` | Código | escreve o nome do P1 na nametable ($28C4) | ALTA | P2 | Baixo | ACEITO |
| N-167 | — | `$3B` | `3B:E67C` | `L3B_E67C` | `RoundIntro_NameP2` | Código | escreve o nome do P2 na nametable | ALTA | P2 | Baixo | ACEITO |
| N-168 | — | `$3B` | `3B:E69D` | `L3B_E69D` | `HudNameScrollP1Set` | Código | atualiza o nome rolante do P1 (ram_040D-ram_0411) | ALTA | P2 | Baixo | ACEITO |
| N-169 | — | `$3B` | `3B:E6BE` | `L3B_E6BE` | `HudNameScrollP2` | Código | le o indice de rolagem do nome do P2 | ALTA | P2 | Baixo | ACEITO |
| N-170 | — | `$3B` | `3B:E6CC` | `L3B_E6CC` | `HudNameScrollP2Set` | Código | atualiza o nome rolante do P2 (ram_0413-ram_0417) | ALTA | P2 | Baixo | ACEITO |
| N-171 | — | `$3B` | `3B:E6ED` | `L3B_E6ED` | `HudWinsUpdate` | Código | escreve os placares de vitorias dos dois lutadores | ALTA | P2 | Baixo | ACEITO |
| N-172 | — | `$3B` | `3B:E741` | `L3B_E741` | `HudDamageUpdate` | Código | desconta o dano pendente e ajusta a barra de energia | ALTA | P2 | Baixo | ACEITO |
| N-173 | — | `$3B` | `3B:E773` | `L3B_E773` | `HudBarTileP1` | Código | escreve os tiles da barra do P1 (ram_0425/ram_0430) | ALTA | P2 | Baixo | ACEITO |
| N-174 | — | `$3B` | `3B:E785` | `L3B_E785` | `HudDamageUpdateP2` | Código | mesmo ajuste de dano para o P2 | ALTA | P2 | Baixo | ACEITO |
| N-175 | — | `$3B` | `3B:E796` | `L3B_E796` | `HudBarTileP2` | Código | escreve os tiles da barra do P2 (ram_043D/ram_0448) | ALTA | P2 | Baixo | ACEITO |
| N-176 | — | `$3B` | `3B:E7BB` | `L3B_E7BB` | `HudWarnBlinkToggle` | Código | alterna o estado de pisca do aviso de energia baixa | ALTA | P2 | Baixo | ACEITO |
| N-177 | — | `$3B` | `3B:E7C4` | `L3B_E7C4` | `HudWarnSelectP1` | Código | fora do fim de round: o aviso de energia baixa e' do P1 | ALTA | P2 | Baixo | ACEITO |
| N-178 | — | `$3B` | `3B:E7E0` | `L3B_E7E0` | `HudTimerUpdate` | Código | atualiza os digitos do relogio do round (a cada 32 quadros) | ALTA | P2 | Baixo | ACEITO |
| N-179 | — | `$3B` | `3B:E807` | `L3B_E807` | `HudTimerUpdateEnd` | Código | fim do bloco do relogio | ALTA | P2 | Baixo | ACEITO |
| N-180 | — | `$3B` | `3B:E8C6` | `L3B_E8C6` | `NmiFightVramTick` | Código | NMI da luta: alterna entre barras e placar a cada quadro | ALTA | P2 | Baixo | ACEITO |
| N-181 | — | `$3B` | `3B:E8CF` | `L3B_E8CF` | `NmiFightVramWins` | Código | NMI da luta: envia os placares de vitorias para a VRAM | ALTA | P2 | Baixo | ACEITO |
| N-182 | — | `$3B` | `3B:EA77` | `L3B_EA77` | `VsScreenIndexSet` | Código | tela VS: guarda o indice do cenario da VS | ALTA | P2 | Baixo | ACEITO |
| N-183 | — | `$3B` | `3B:EB08` | `L3B_EB08` | `VsPaletteCopyLoop` | Código | copia 6 bytes da paleta da tela VS para PaletteBuf | ALTA | P2 | Baixo | ACEITO |
| N-184 | — | `$3B` | `3B:EB24` | `L3B_EB24` | `VsTextP1Line1Loop` | Código | texto de 7 caracteres do P1 (ram_0392) para a nametable $2A64 | ALTA | P2 | Baixo | ACEITO |
| N-185 | — | `$3B` | `3B:EB3B` | `L3B_EB3B` | `VsTextP1Line2Loop` | Código | texto de 7 caracteres do P1 (ram_0399) para a nametable $2A84 | ALTA | P2 | Baixo | ACEITO |
| N-186 | — | `$3B` | `3B:EB59` | `L3B_EB59` | `VsTextP2Line1Loop` | Código | texto de 7 caracteres do P2 (ram_03A0) para a nametable $2A75 | ALTA | P2 | Baixo | ACEITO |
| N-187 | — | `$3B` | `3B:EB70` | `L3B_EB70` | `VsTextP2Line2Loop` | Código | texto de 7 caracteres do P2 (ram_03A7) para a nametable $2A95 | ALTA | P2 | Baixo | ACEITO |
| N-188 | — | `$3B` | `3B:EBB9` | `L3B_EBB9` | `VsWaitFlagClear` | Código | tela VS: inicia a espera do proximo vblank | ALTA | P2 | Baixo | ACEITO |
| N-189 | — | `$3B` | `3B:EBBD` | `L3B_EBBD` | `VsWaitVBlank` | Código | tela VS: espera o vblank (3 x 64 quadros) | ALTA | P2 | Baixo | ACEITO |
| N-190 | — | `$3B` | `3B:EC2D` | `L3B_EC2D` | `WinQuoteClearRows` | Código | frase final: limpa 32 linhas da nametable | ALTA | P2 | Baixo | ACEITO |
| N-191 | — | `$3B` | `3B:EC2F` | `L3B_EC2F` | `WinQuoteClearCols` | Código | frase final: limpa as 30 colunas da linha | ALTA | P2 | Baixo | ACEITO |
| N-192 | — | `$3B` | `3B:EC3C` | `L3B_EC3C` | `WinQuoteClearAttr` | Código | frase final: limpa 64 bytes de atributos | ALTA | P2 | Baixo | ACEITO |
| N-193 | — | `$3B` | `3B:EC83` | `L3B_EC83` | `WinQuoteWinnerText` | Código | frase final: calcula o ponteiro da frase do vencedor e a escreve | ALTA | P2 | Baixo | ACEITO |
| N-194 | — | `$3B` | `3B:ECE9` | `L3B_ECE9` | `WinQuoteWaitCount` | Código | frase final: guarda o contador de espera (2 ou 3 x 64 quadros) | ALTA | P2 | Baixo | ACEITO |
| N-195 | — | `$3B` | `3B:ECEB` | `L3B_ECEB` | `WinQuoteWaitFlagClear` | Código | frase final: inicia a espera do proximo vblank | ALTA | P2 | Baixo | ACEITO |
| N-196 | — | `$3B` | `3B:ECEF` | `L3B_ECEF` | `WinQuoteWaitVBlank` | Código | frase final: espera o vblank | ALTA | P2 | Baixo | ACEITO |
| N-197 | — | `$3B` | `3B:ED2C` | `L3B_ED2C` | `WinQuoteLineWaitVBlank1` | Código | frase final: 1o vblank do avanco do texto | ALTA | P2 | Baixo | ACEITO |
| N-198 | — | `$3B` | `3B:ED46` | `L3B_ED46` | `WinQuoteLineWaitVBlank2` | Código | frase final: 2o vblank do avanco do texto | ALTA | P2 | Baixo | ACEITO |
| N-199 | — | `$3B` | `3B:ED6A` | `L3B_ED6A` | `WinQuoteCharTile` | Código | frase final: converte o caractere em tile (0 = espaco) | ALTA | P2 | Baixo | ACEITO |
| N-200 | — | `$3B` | `3B:ED72` | `L3B_ED72` | `WinQuoteCharTile2` | Código | frase final: segundo tile do caractere (shift) | ALTA | P2 | Baixo | ACEITO |
| N-201 | — | `$3B` | `3B:ED9D` | `L3B_ED9D` | `DrawFightersDistCheck` | Código | FightersUpdate: \|dx\| < $20 -> ordem invertida de desenho | ALTA | P2 | Baixo | ACEITO |
| N-202 | — | `$3B` | `3B:EDBB` | `L3B_EDBB` | `DrawFightersNormal` | Código | desenha o P2 e depois o P1 | ALTA | P2 | Baixo | ACEITO |
| N-203 | — | `$3B` | `3B:EDC5` | `L3B_EDC5` | `DrawFightersKoOrder` | Código | desenha o P1 e depois o P2 (um deles esta em KO) | ALTA | P2 | Baixo | ACEITO |
| N-204 | — | `$3B` | `3B:EDCF` | `L3B_EDCF` | `DrawFightersCurOrder` | Código | desenha o oponente e depois o lutador atual | ALTA | P2 | Baixo | ACEITO |
| N-205 | — | `$3B` | `3B:EDDE` | `L3B_EDDE` | `DrawFighterSide` | Código | DrawFighter: lutador 1 = sem espelhamento, lutador 2 = $80 | ALTA | P2 | Baixo | ACEITO |
| N-206 | — | `$3B` | `3B:EDF7` | `L3B_EDF7` | `DrawFighterVariant` | Código | DrawFighter: escolhe a variante do metasprite (lutador 2 na tela de luta) | ALTA | P2 | Baixo | ACEITO |
| N-207 | — | `$3B` | `3B:EE35` | `L3B_EE35` | `DrawFighterSecond` | Código | DrawFighter: desenha o segundo metasprite do lutador | ALTA | P2 | Baixo | ACEITO |
| N-208 | — | `$3B` | `3B:EE43` | `L3B_EE43` | `PortraitP1WinSet` | Código | retrato do P1: P1 venceu (RoundResult = 0) -> layout de vitoria | ALTA | P2 | Baixo | ACEITO |
| N-209 | — | `$3B` | `3B:EE5B` | `L3B_EE5B` | `PortraitP1LoseSet` | Código | retrato do P1: P1 perdeu -> layout de derrota | ALTA | P2 | Baixo | ACEITO |
| N-210 | — | `$3B` | `3B:EE73` | `L3B_EE73` | `PortraitPalCopyLoopP1` | Código | copia as 3 cores de cada paleta do P1 para PaletteBuf | ALTA | P2 | Baixo | ACEITO |
| N-211 | — | `$3B` | `3B:EE8A` | `L3B_EE8A` | `PortraitPalCopyLoopP1End` | Código | fim do laco de paletas do P1 | ALTA | P2 | Baixo | ACEITO |
| N-212 | — | `$3B` | `3B:EEAE` | `L3B_EEAE` | `PortraitP1LoseLayout` | Código | layout (metasprites) do retrato de derrota do P1 | ALTA | P2 | Baixo | ACEITO |
| N-213 | — | `$3B` | `3B:EEDC` | `L3B_EEDC` | `PortraitP1LoseTiles` | Código | tiles do retrato de derrota do P1 | ALTA | P2 | Baixo | ACEITO |
| N-214 | — | `$3B` | `3B:EEED` | `L3B_EEED` | `PortraitTilesCopyLoopP1` | Código | copia 6 bytes de tiles do retrato do P1 para ram_038A | ALTA | P2 | Baixo | ACEITO |
| N-215 | — | `$3B` | `3B:EF14` | `L3B_EF14` | `PortraitTilesPtr2` | Código | 2o/3o endereco de tiles do retrato do P1 (ram_034A/ram_034C) | ALTA | P2 | Baixo | ACEITO |
| N-216 | — | `$3B` | `3B:EF1E` | `L3B_EF1E` | `PortraitTilesReadyP1` | Código | retrato do P1 pronto (ram_03AE = 1) | ALTA | P2 | Baixo | ACEITO |
| N-217 | — | `$3B` | `3B:EF2F` | `L3B_EF2F` | `PortraitP2WinSet` | Código | retrato do P2: P2 venceu (RoundResult = 1) -> layout de vitoria | ALTA | P2 | Baixo | ACEITO |
| N-218 | — | `$3B` | `3B:EF47` | `L3B_EF47` | `PortraitP2LoseSet` | Código | retrato do P2: P2 perdeu -> layout de derrota | ALTA | P2 | Baixo | ACEITO |
| N-219 | — | `$3B` | `3B:EF8C` | `L3B_EF8C` | `PortraitP2LoseLayout` | Código | layout (metasprites) do retrato de derrota do P2 | ALTA | P2 | Baixo | ACEITO |
| N-220 | — | `$3B` | `3B:EFC7` | `L3B_EFC7` | `PortraitP2WinMetasprite` | Código | retrato do P2: desenha o metasprite de vitoria | ALTA | P2 | Baixo | ACEITO |
| N-221 | — | `$3B` | `3B:EFE7` | `L3B_EFE7` | `PortraitNameDestCalc` | Código | calcula o destino do nome do lutador (nametable + tiles) | ALTA | P2 | Baixo | ACEITO |
| N-222 | — | `$3B` | `3B:EFFA` | `L3B_EFFA` | `PortraitNameClearLoop` | Código | limpa 7 bytes do nome nas duas nametables | ALTA | P2 | Baixo | ACEITO |
| N-223 | — | `$3B` | `3B:F015` | `L3B_F015` | `PortraitNameCharLoop` | Código | escreve as tiles do nome do lutador | ALTA | P2 | Baixo | ACEITO |
| N-224 | — | `$3B` | `3B:F027` | `L3B_F027` | `PortraitNameCharEnd` | Código | fim do laco do nome (7 caracteres) | ALTA | P2 | Baixo | ACEITO |
| N-225 | — | `$3B` | `3B:F27A` | `L3B_F27A` | `DrawFightersProjectile` | Código | FightersUpdate: desenha o projetil do lutador, se houver | ALTA | P2 | Baixo | ACEITO |
| N-226 | — | `$3B` | `3B:F2D0` | `L3B_F2D0` | `DrawProjectileMetasprite` | Código | desenha os dois metasprites do projetil | ALTA | P2 | Baixo | ACEITO |
| N-227 | — | `$3B` | `3B:F592` | `L3B_F592` | `FightFrame_WaitVBlank` | Código | laco principal da luta: espera o vblank | ALTA | P2 | Baixo | ACEITO |
| N-228 | — | `$3B` | `3B:F605` | `L3B_F605` | `FightFrame_DrawReset` | Código | empate na melhor de 3: zera os placares e comeca outro round | ALTA | P2 | Baixo | ACEITO |
| N-229 | — | `$3B` | `3B:F60E` | `L3B_F60E` | `FightFrame_End` | Código | fim da luta | ALTA | P2 | Baixo | ACEITO |
| N-230 | — | `$3B` | `3B:F643` | `L3B_F643` | `RoundInit_CheckAiP2` | Código | P1 humano: pula a IA do P1 e testa a IA do P2 | ALTA | P2 | Baixo | ACEITO |
| N-231 | — | `$3B` | `3B:F64C` | `L3B_F64C` | `RoundInit_StartRound` | Código | P2 humano: pula a IA do P2 e comeca o round (flash de paleta) | ALTA | P2 | Baixo | ACEITO |
| N-232 | — | `$3B` | `3B:F658` | `L3B_F658` | `RoundLogic_EndCheck` | Código | ScreenMode = 6 (fim de round) -> RoundEndStep | ALTA | P2 | Baixo | ACEITO |
| N-233 | — | `$3B` | `3B:F65F` | `L3B_F65F` | `RoundLogic_KoCheck` | Código | luta: verifica o estado do P1 (KO em $E9) | ALTA | P2 | Baixo | ACEITO |
| N-234 | — | `$3B` | `3B:F66F` | `L3B_F66F` | `RoundLogic_KoCheckP2` | Código | luta: verifica o estado do P2 | ALTA | P2 | Baixo | ACEITO |
| N-235 | — | `$3B` | `3B:F67A` | `L3B_F67A` | `RoundLogic_RoundOver` | Código | round encerrado: ScreenMode = 6, RoundStep = $80 | ALTA | P2 | Baixo | ACEITO |
| N-236 | — | `$3B` | `3B:F6AA` | `L3B_F6AA` | `RoundTimer_P1Hp` | Código | tempo esgotado: HP efetivo do P1 (HP - dano pendente) | ALTA | P2 | Baixo | ACEITO |
| N-237 | — | `$3B` | `3B:F6B6` | `L3B_F6B6` | `RoundTimer_CompareHp` | Código | compara o HP efetivo do P2 com o do P1 | ALTA | P2 | Baixo | ACEITO |
| N-238 | — | `$3B` | `3B:F6BD` | `L3B_F6BD` | `RoundTimer_ResultAdjust` | Código | Y = 1 (P2 venceu) ou 2 (empate) | ALTA | P2 | Baixo | ACEITO |
| N-239 | — | `$3B` | `3B:F6BF` | `L3B_F6BF` | `RoundTimer_SetResult` | Código | grava RoundResult e reinicia o relogio | ALTA | P2 | Baixo | ACEITO |
| N-240 | — | `$3B` | `3B:F6C6` | `L3B_F6C6` | `RoundTimer_TensDec` | Código | dezena do relogio -1 | ALTA | P2 | Baixo | ACEITO |
| N-241 | — | `$3B` | `3B:F6CA` | `L3B_F6CA` | `RoundTimer_OnesReset` | Código | unidade do relogio = 9 | ALTA | P2 | Baixo | ACEITO |
| N-242 | — | `$3B` | `3B:F6CF` | `L3B_F6CF` | `RoundTimer_End` | Código | fim do tique do relogio | ALTA | P2 | Baixo | ACEITO |
| N-243 | — | `$3B` | `3B:F6DC` | `L3B_F6DC` | `RoundIntro_TimerTick` | Código | intro do round: -1 no temporizador do passo | ALTA | P2 | Baixo | ACEITO |
| N-244 | — | `$3B` | `3B:F6F2` | `L3B_F6F2` | `RoundIntro_StepDelay` | Código | carrega o atraso do passo; passo 6 = voz "ROUND" | ALTA | P2 | Baixo | ACEITO |
| N-245 | — | `$3B` | `3B:F705` | `L3B_F705` | `RoundIntro_RoundVoice` | Código | passo 5 = voz do numero do round | ALTA | P2 | Baixo | ACEITO |
| N-246 | — | `$3B` | `3B:F713` | `L3B_F713` | `RoundIntro_FightVoice` | Código | passo 3 = voz "FIGHT" | ALTA | P2 | Baixo | ACEITO |
| N-247 | — | `$3B` | `3B:F7F0` | `L3B_F7F0` | `RoundEnd_TimeUpCheck` | Código | tempo zerado: mostra o aviso e comeca a contagem de $40 | ALTA | P2 | Baixo | ACEITO |
| N-248 | — | `$3B` | `3B:F819` | `L3B_F819` | `RoundEnd_StepCheck` | Código | fim do round: RoundStep = 0 -> terminou | ALTA | P2 | Baixo | ACEITO |
| N-249 | — | `$3B` | `3B:F81F` | `L3B_F81F` | `RoundEnd_NextStep` | Código | fim do round: avanca para o proximo passo | ALTA | P2 | Baixo | ACEITO |
| N-250 | — | `$3B` | `3B:F833` | `L3B_F833` | `RoundEnd_WinnerIsCpu` | Código | o vencedor e' a CPU? | ALTA | P2 | Baixo | ACEITO |
| N-251 | — | `$3B` | `3B:F83D` | `L3B_F83D` | `RoundEnd_VoiceWin` | Código | passo $7E = voz "WIN" | ALTA | P2 | Baixo | ACEITO |
| N-252 | — | `$3B` | `3B:F846` | `L3B_F846` | `RoundEnd_DrawYouWin` | Código | desenha o sprite de "YOU WIN" ($20:85EA) | ALTA | P2 | Baixo | ACEITO |
| N-253 | — | `$3B` | `3B:F84D` | `L3B_F84D` | `RoundEnd_VoicePerfect` | Código | vencedor humano com energia cheia: voz "PERFECT" | ALTA | P2 | Baixo | ACEITO |
| N-254 | — | `$3B` | `3B:F858` | `L3B_F858` | `RoundEnd_DrawPerfect` | Código | desenha o sprite de "PERFECT" ($20:852B) | ALTA | P2 | Baixo | ACEITO |
| N-255 | — | `$3B` | `3B:F86B` | `L3B_F86B` | `RoundEnd_VoiceLose` | Código | vencedor e' a CPU: passo $7E = voz "LOSE" | ALTA | P2 | Baixo | ACEITO |
| N-256 | — | `$3B` | `3B:F874` | `L3B_F874` | `RoundEnd_DrawYouLose` | Código | desenha o sprite de "YOU LOSE" ($20:85D9) | ALTA | P2 | Baixo | ACEITO |
| N-257 | — | `$3B` | `3B:F887` | `L3B_F887` | `RoundEnd_DrawTie` | Código | empate: desenha o sprite de empate ($20:84A1) | ALTA | P2 | Baixo | ACEITO |
| N-258 | — | `$3B` | `3B:F8A2` | `L3B_F8A2` | `RoundEnd_DrawTieAlt` | Código | empate com relogio no ar: variante do sprite ($20:848B) | ALTA | P2 | Baixo | ACEITO |
| N-259 | — | `$3B` | `3B:F93F` | `L3B_F93F` | `StageSplit_HitStopTick` | Código | StageSplitSetup: -1 no HitStop e devolve a paridade nos flags | ALTA | P2 | Baixo | ACEITO |
| N-260 | — | `$3B` | `3B:F967` | `L3B_F967` | `StageParallaxLoop` | Código | calcula o deslocamento do parallax do cenario | ALTA | P2 | Baixo | ACEITO |
| N-261 | C3F-06 (duplicado) | `$3F` | `3F:E158` | `L3F_E158` | `TransAnimTimerSet` | Código | em TransApply: quadro de golpe/reacao -> FighterAnimTimer = 1 | ALTA | P2 | Baixo | ACEITO |
| N-262 | C3F-07 (duplicado) | `$3F` | `3F:E15D` | `L3F_E15D` | `TransNextPtrSet` | Código | em TransApply: grava o ponteiro do proximo estado (FighterNextPtrLo/Hi) | ALTA | P2 | Baixo | ACEITO |
| N-263 | C3F-08 (duplicado) | `$3F` | `3F:E191` | `L3F_E191` | `CondOpponentAttackClass` | Código | em CondOpponentAttacks: classe do oponente (reacao/golpe/projetil) | ALTA | P2 | Baixo | ACEITO |
| N-264 | — | `$3F` | `3F:E1CA` | `L3F_E1CA` | `CondFarBackFacing` | Código | em CondOpponentFarBack: devolve o bit de virada ($40) | ALTA | P2 | Baixo | ACEITO |
| N-265 | — | `$3F` | `3F:E1E0` | `L3F_E1E0` | `CondNearAbsDiff` | Código | em CondOpponentNear: normaliza o sinal da diferenca de X | ALTA | P2 | Baixo | ACEITO |
| N-266 | — | `$3F` | `3F:E1E6` | `L3F_E1E6` | `CondNearLimit` | Código | em CondOpponentNear: compara \|dx\| com $21 | ALTA | P2 | Baixo | ACEITO |
| N-267 | C3F-09 | `$3F` | `3F:E239` | `L3F_E239` | `CondGrabAbsDiff` | Código | em CondCanGrab: normaliza o sinal da diferenca de X | ALTA | P2 | Baixo | ACEITO |
| N-268 | C3F-10 | `$3F` | `3F:E252` | `L3F_E252` | `CondGrabOpponentClass` | Código | em CondCanGrab: classe do oponente ($30-$A8) | ALTA | P2 | Baixo | ACEITO |
| N-269 | C3F-11 | `$3F` | `3F:E2A3` | `L3F_E2A3` | `CondRoundLostFalse` | Código | em CondRoundLost: caminho falso (RoundResult = este lutador ou $FF) | ALTA | P2 | Baixo | ACEITO |
| N-270 | — | `$3F` | `3F:E2B3` | `L3F_E2B3` | `AnimNextStateCheck` | Código | em AnimAdvance: ha proximo estado escolhido? (FighterNextPtrHi) | ALTA | P2 | Baixo | ACEITO |
| N-271 | — | `$3F` | `3F:E2D8` | `L3F_E2D8` | `AnimStatePtrSet` | Código | em AnimAdvance: grava o ponteiro do novo estado e do novo quadro | ALTA | P2 | Baixo | ACEITO |
| N-272 | — | `$3F` | `3F:E2F0` | `L3F_E2F0` | `AnimStateClassSet` | Código | em AnimAdvance: aplica a classe do novo quadro (StateSetByte) | ALTA | P2 | Baixo | ACEITO |

### 3.3 Lote PAD — condições em inglês (7)

| ID | ID anterior | Banco | Endereço | Símbolo anterior | Símbolo aplicado | Categoria | Evidência | Confiança | Prioridade | Risco | Decisão |
|----|-------------|-------|----------|------------------|------------------|-----------|-----------|-----------|------------|-------|---------|
| N-273 | — | `$3F` | `3F:E189` | `CondOponenteAtaca` | `CondOpponentAttacks` | Código | verdadeiro se EU estou em pe/agachado (classe & 3) E o oponente esta em classe de reacao ($70-$98), de golpe ($B0-$E0) ou com projetil no ar (dele) | ALTA | P1 | Baixo | ACEITO |
| N-274 | — | `$3F` | `3F:E1B1` | `CondOponenteLongeCostas` | `CondOpponentFarBack` | Código | verdadeiro se o oponente esta a \|dx\| >= $0F E eu de costas para ele: devolve $40 (e' o bit 6 de FighterFlip) para virar, 0 se esta encarando ou colado | ALTA | P1 | Baixo | ACEITO |
| N-275 | — | `$3F` | `3F:E1D6` | `CondOponentePerto` | `CondOpponentNear` | Código | verdadeiro se \|dx\| < $21 | ALTA | P1 | Baixo | ACEITO |
| N-276 | — | `$3F` | `3F:E204` | `CondNoChaoOuVelX` | `CondOnGroundOrVelX` | Código | verdadeiro se FighterY = FloorY ou VelX/VelXSub != 0 (esta no chao ou deslizando) | ALTA | P1 | Baixo | ACEITO |
| N-277 | — | `$3F` | `3F:E22E` | `CondPodeAgarrar` | `CondCanGrab` | Código | \|dx\| < $18, os dois no chao, InputDir = frente/tras ($05/$06) e classe do oponente < $30 ou $50-$9F (estados de virar $A0-$A9 nao contam, nt) | ALTA | P1 | Baixo | ACEITO |
| N-278 | — | `$3F` | `3F:E271` | `CondVitoria` | `CondVictory` | Código | verdadeiro se RoundResult = este lutador E o oponente esta caido (classe >= $F0) E nao ha projeteis no ar E o canal de voz esta livre | ALTA | P1 | Baixo | ACEITO |
| N-279 | — | `$3F` | `3F:E296` | `CondRoundPerdido` | `CondRoundLost` | Código | verdadeiro se RoundResult != este lutador E RoundResult != $FF (round encerrado; vale para empate) | ALTA | P1 | Baixo | ACEITO |

### 3.4 Lote FT2 — FamiTone2 (109)

| ID | ID anterior | Banco | Endereço | Símbolo anterior | Símbolo aplicado | Categoria | Evidência | Confiança | Prioridade | Risco | Decisão |
|----|-------------|-------|----------|------------------|------------------|-----------|-----------|-----------|------------|-------|---------|
| N-280 | — | `$37` | `37:E45E` | `L37_E45E` | `VoicePlayFighterEnd` | Código | FamiTone2/vozes: termina a voz do lutador apos encadear a continuacao | ALTA | P2 | Baixo | ACEITO |
| N-281 | — | `$37` | `37:E46E` | `L37_E46E` | `SoundUpdateMusic` | Código | FamiTone2 v1.15: som: mapeia o banco da musica e atualiza o FamiTone2 | ALTA | P2 | Baixo | ACEITO |
| N-282 | — | `$37` | `37:E4E5` | `L37_E4E5` | `_FT2MusicStopChannels` | Código | FamiTone2: zera os campos das canais ao parar a musica | ALTA | P2 | Baixo | ACEITO |
| N-283 | — | `$37` | `37:E4FF` | `L37_E4FF` | `_FT2MusicStopEnvelopes` | Código | FamiTone2: aponta todos os envelopes para o envelope mudo | ALTA | P2 | Baixo | ACEITO |
| N-284 | — | `$37` | `37:E56D` | `L37_E56D` | `_FT2MusicPlayChannels` | Código | FamiTone2: inicializa os ponteiros e os campos das canais da musica | ALTA | P2 | Baixo | ACEITO |
| N-285 | — | `$37` | `37:E5AB` | `L37_E5AB` | `_FT2MusicPlayDone` | Código | FamiTone2: musica invalida ou musica iniciada; fim do carregamento | ALTA | P2 | Baixo | ACEITO |
| N-286 | — | `$37` | `37:E5C7` | `L37_E5C7` | `_FT2MusicPauseUnpause` | Código | FamiTone2: remove a marca de pausa da musica | ALTA | P2 | Baixo | ACEITO |
| N-287 | — | `$37` | `37:E5CC` | `L37_E5CC` | `_FT2MusicPauseDone` | Código | FamiTone2: grava o novo estado de pausa da musica | ALTA | P2 | Baixo | ACEITO |
| N-288 | — | `$37` | `37:E5D7` | `L37_E5D7` | `_FT2UpdateSoundPaused` | Código | FamiTone2: atualiza os sons mesmo com a musica pausada | ALTA | P2 | Baixo | ACEITO |
| N-289 | — | `$37` | `37:E5DA` | `L37_E5DA` | `_FT2UpdateTempo` | Código | FamiTone2: soma o passo de tempo e decide se atualiza uma linha | ALTA | P2 | Baixo | ACEITO |
| N-290 | — | `$37` | `37:E5F5` | `L37_E5F5` | `_FT2UpdateRow` | Código | FamiTone2: aplica uma nova linha da musica as cinco canais | ALTA | P2 | Baixo | ACEITO |
| N-291 | — | `$37` | `37:E613` | `L37_E613` | `_FT2Channel1NewNote` | Código | FamiTone2: a canal 1 recebeu uma nota nova | ALTA | P2 | Baixo | ACEITO |
| N-292 | — | `$37` | `37:E630` | `L37_E630` | `_FT2Channel1Instrument` | Código | FamiTone2: instala o instrumento da canal 1 | ALTA | P2 | Baixo | ACEITO |
| N-293 | — | `$37` | `37:E638` | `L37_E638` | `_FT2Channel2Update` | Código | FamiTone2: processa a canal 2 | ALTA | P2 | Baixo | ACEITO |
| N-294 | — | `$37` | `37:E64F` | `L37_E64F` | `_FT2Channel2NewNote` | Código | FamiTone2: a canal 2 recebeu uma nota nova | ALTA | P2 | Baixo | ACEITO |
| N-295 | — | `$37` | `37:E66C` | `L37_E66C` | `_FT2Channel2Instrument` | Código | FamiTone2: instala o instrumento da canal 2 | ALTA | P2 | Baixo | ACEITO |
| N-296 | — | `$37` | `37:E674` | `L37_E674` | `_FT2Channel3Update` | Código | FamiTone2: processa a canal 3 | ALTA | P2 | Baixo | ACEITO |
| N-297 | — | `$37` | `37:E69B` | `L37_E69B` | `_FT2Channel3Instrument` | Código | FamiTone2: instala o instrumento da canal 3 | ALTA | P2 | Baixo | ACEITO |
| N-298 | — | `$37` | `37:E6A3` | `L37_E6A3` | `_FT2Channel4Update` | Código | FamiTone2: processa a canal 4 | ALTA | P2 | Baixo | ACEITO |
| N-299 | — | `$37` | `37:E6BA` | `L37_E6BA` | `_FT2Channel4Instrument` | Código | FamiTone2: instala o instrumento da canal 4 | ALTA | P2 | Baixo | ACEITO |
| N-300 | — | `$37` | `37:E6C4` | `L37_E6C4` | `_FT2Channel5Update` | Código | FamiTone2: processa a canal 5 de amostras | ALTA | P2 | Baixo | ACEITO |
| N-301 | — | `$37` | `37:E6DA` | `L37_E6DA` | `_FT2Channel5PlaySample` | Código | FamiTone2: inicia ou para a amostra da canal 5 | ALTA | P2 | Baixo | ACEITO |
| N-302 | — | `$37` | `37:E6E9` | `L37_E6E9` | `_FT2EnvRead` | Código | FamiTone2: le o ponteiro e o proximo valor do envelope | ALTA | P2 | Baixo | ACEITO |
| N-303 | — | `$37` | `37:E703` | `L37_E703` | `_FT2EnvSpecial` | Código | FamiTone2: trata um codigo especial do envelope | ALTA | P2 | Baixo | ACEITO |
| N-304 | — | `$37` | `37:E70C` | `L37_E70C` | `_FT2EnvSetRepeat` | Código | FamiTone2: grava o contador de repeticao do envelope | ALTA | P2 | Baixo | ACEITO |
| N-305 | — | `$37` | `37:E710` | `L37_E710` | `_FT2EnvStorePtr` | Código | FamiTone2: salva o ponteiro corrente do envelope | ALTA | P2 | Baixo | ACEITO |
| N-306 | — | `$37` | `37:E714` | `L37_E714` | `_FT2EnvNext` | Código | FamiTone2: passa para o proximo envelope | ALTA | P2 | Baixo | ACEITO |
| N-307 | — | `$37` | `37:E728` | `L37_E728` | `_FT2UpdateSoundCh1Note` | Código | FamiTone2: calcula o periodo da nota da canal 1 | ALTA | P2 | Baixo | ACEITO |
| N-308 | — | `$37` | `37:E74F` | `L37_E74F` | `_FT2UpdateSoundCh1Sign` | Código | FamiTone2: prolonga o sinal do periodo da canal 1 | ALTA | P2 | Baixo | ACEITO |
| N-309 | — | `$37` | `37:E76E` | `L37_E76E` | `_FT2UpdateSoundCh1ScaleLimit` | Código | FamiTone2: limita a atenuacao de volume da canal 1 | ALTA | P2 | Baixo | ACEITO |
| N-310 | — | `$37` | `37:E776` | `L37_E776` | `_FT2UpdateSoundCh1ApplyScale` | Código | FamiTone2: aplica a atenuacao de volume da canal 1 | ALTA | P2 | Baixo | ACEITO |
| N-311 | — | `$37` | `37:E779` | `L37_E779` | `_FT2UpdateSoundCh1Volume` | Código | FamiTone2: grava o volume final da canal 1 | ALTA | P2 | Baixo | ACEITO |
| N-312 | — | `$37` | `37:E7A6` | `L37_E7A6` | `_FT2UpdateSoundCh2Sign` | Código | FamiTone2: prolonga o sinal do periodo da canal 2 | ALTA | P2 | Baixo | ACEITO |
| N-313 | — | `$37` | `37:E7C5` | `L37_E7C5` | `_FT2UpdateSoundCh2ScaleLimit` | Código | FamiTone2: limita a atenuacao de volume da canal 2 | ALTA | P2 | Baixo | ACEITO |
| N-314 | — | `$37` | `37:E7CD` | `L37_E7CD` | `_FT2UpdateSoundCh2ApplyScale` | Código | FamiTone2: aplica a atenuacao de volume da canal 2 | ALTA | P2 | Baixo | ACEITO |
| N-315 | — | `$37` | `37:E7D0` | `L37_E7D0` | `_FT2UpdateSoundCh2Volume` | Código | FamiTone2: grava o volume final da canal 2 | ALTA | P2 | Baixo | ACEITO |
| N-316 | — | `$37` | `37:E7F1` | `L37_E7F1` | `_FT2UpdateSoundCh3Sign` | Código | FamiTone2: prolonga o sinal do periodo da canal 3 | ALTA | P2 | Baixo | ACEITO |
| N-317 | — | `$37` | `37:E80E` | `L37_E80E` | `_FT2UpdateSoundCh3Control` | Código | FamiTone2: prepara o controle linear do triangulo da canal 3 | ALTA | P2 | Baixo | ACEITO |
| N-318 | — | `$37` | `37:E840` | `L37_E840` | `_FT2UpdateSoundCh4ScaleLimit` | Código | FamiTone2: limita a atenuacao de volume da canal 4 | ALTA | P2 | Baixo | ACEITO |
| N-319 | — | `$37` | `37:E848` | `L37_E848` | `_FT2UpdateSoundCh4ApplyScale` | Código | FamiTone2: aplica a atenuacao de volume da canal 4 | ALTA | P2 | Baixo | ACEITO |
| N-320 | — | `$37` | `37:E84B` | `L37_E84B` | `_FT2UpdateSoundCh4Volume` | Código | FamiTone2: grava o volume final do ruido da canal 4 | ALTA | P2 | Baixo | ACEITO |
| N-321 | — | `$37` | `37:E874` | `L37_E874` | `_FT2UpdateSoundPulse2` | Código | FamiTone2: envia volume e periodo da canal 2 aos registradores da APU | ALTA | P2 | Baixo | ACEITO |
| N-322 | — | `$37` | `37:E88E` | `L37_E88E` | `_FT2UpdateSoundTriangle` | Código | FamiTone2: envia volume e periodo do triangulo aos registradores da APU | ALTA | P2 | Baixo | ACEITO |
| N-323 | — | `$37` | `37:E8C2` | `L37_E8C2` | `_FT2ChannelPitchVibrato` | Código | FamiTone2: recompoe o tom antes de aplicar o vibrato | ALTA | P2 | Baixo | ACEITO |
| N-324 | — | `$37` | `37:E8D6` | `L37_E8D6` | `_FT2ChannelPitchSlideMode` | Código | FamiTone2: le o modo de slide da canal | ALTA | P2 | Baixo | ACEITO |
| N-325 | — | `$37` | `37:E8DE` | `L37_E8DE` | `_FT2ChannelPitchSlideType` | Código | FamiTone2: distingue slide para cima, para baixo e portamento | ALTA | P2 | Baixo | ACEITO |
| N-326 | — | `$37` | `37:E8E9` | `L37_E8E9` | `_FT2ChannelPitchSlideUp` | Código | FamiTone2: soma o deslocamento de slide para cima | ALTA | P2 | Baixo | ACEITO |
| N-327 | — | `$37` | `37:E8F6` | `L37_E8F6` | `_FT2ChannelPitchSlideUpStore` | Código | FamiTone2: grava a parte baixa do tom apos o slide para cima | ALTA | P2 | Baixo | ACEITO |
| N-328 | — | `$37` | `37:E905` | `L37_E905` | `_FT2ChannelPitchSlideUpLimit` | Código | FamiTone2: limita a parte alta do tom apos o slide para cima | ALTA | P2 | Baixo | ACEITO |
| N-329 | — | `$37` | `37:E914` | `L37_E914` | `_FT2ChannelPitchSlideDown` | Código | FamiTone2: subtrai o deslocamento de slide para baixo | ALTA | P2 | Baixo | ACEITO |
| N-330 | — | `$37` | `37:E923` | `L37_E923` | `_FT2ChannelPitchSlideDownStore` | Código | FamiTone2: grava o tom apos o slide para baixo | ALTA | P2 | Baixo | ACEITO |
| N-331 | — | `$37` | `37:E933` | `L37_E933` | `_FT2ChannelPitchSlideEnd` | Código | FamiTone2: encerra o slide quando o tom ultrapassa o limite | ALTA | P2 | Baixo | ACEITO |
| N-332 | — | `$37` | `37:E957` | `L37_E957` | `_FT2SlideToNoteLoad` | Código | FamiTone2: compara o tom corrente com o tom alvo | ALTA | P2 | Baixo | ACEITO |
| N-333 | — | `$37` | `37:E965` | `L37_E965` | `_FT2SlideToNoteDown` | Código | FamiTone2: reduz o tom enquanto ele esta acima do alvo | ALTA | P2 | Baixo | ACEITO |
| N-334 | — | `$37` | `37:E974` | `L37_E974` | `_FT2SlideToNoteDownStore` | Código | FamiTone2: grava o tom reduzido durante o slide | ALTA | P2 | Baixo | ACEITO |
| N-335 | — | `$37` | `37:E982` | `L37_E982` | `_FT2SlideToNoteApply` | Código | FamiTone2: aplica o tom corrente ao registrador da voz | ALTA | P2 | Baixo | ACEITO |
| N-336 | — | `$37` | `37:E991` | `L37_E991` | `_FT2SlideToNoteReached` | Código | FamiTone2: alcancou o tom alvo e substitui o tom corrente | ALTA | P2 | Baixo | ACEITO |
| N-337 | — | `$37` | `37:E9AC` | `L37_E9AC` | `_FT2SlideToNoteDone` | Código | FamiTone2: termina o slide e segue para o vibrato | ALTA | P2 | Baixo | ACEITO |
| N-338 | — | `$37` | `37:E9AF` | `L37_E9AF` | `_FT2SlideToNoteUp` | Código | FamiTone2: aumenta o tom enquanto ele esta abaixo do alvo | ALTA | P2 | Baixo | ACEITO |
| N-339 | — | `$37` | `37:E9BC` | `L37_E9BC` | `_FT2SlideToNoteUpStore` | Código | FamiTone2: grava o tom aumentado durante o slide | ALTA | P2 | Baixo | ACEITO |
| N-340 | — | `$37` | `37:E9E2` | `L37_E9E2` | `_FT2PitchCompareAbove` | Código | FamiTone2: indica que o tom corrente esta acima do alvo | ALTA | P2 | Baixo | ACEITO |
| N-341 | — | `$37` | `37:E9E5` | `L37_E9E5` | `_FT2PitchCompareBelow` | Código | FamiTone2: indica que o tom corrente esta abaixo do alvo | ALTA | P2 | Baixo | ACEITO |
| N-342 | — | `$37` | `37:EA15` | `L37_EA15` | `_FT2VibratoClampLow` | Código | FamiTone2: limita o tom ao minimo quando o vibrato e negativo | ALTA | P2 | Baixo | ACEITO |
| N-343 | — | `$37` | `37:EA1D` | `L37_EA1D` | `_FT2VibratoStore` | Código | FamiTone2: grava o tom corrigido pelo vibrato | ALTA | P2 | Baixo | ACEITO |
| N-344 | — | `$37` | `37:EA20` | `L37_EA20` | `_FT2VibratoReturn` | Código | FamiTone2: devolve o tom final da voz | ALTA | P2 | Baixo | ACEITO |
| N-345 | — | `$37` | `37:EAE7` | `L37_EAE7` | `_FT2SetInstrumentNoThirdEnv` | Código | FamiTone2: encerra a parte opcional do instrumento sem terceiro envelope | ALTA | P2 | Baixo | ACEITO |
| N-346 | — | `$37` | `37:EAFD` | `L37_EAFD` | `_FT2SetInstrumentSkipExtra` | Código | FamiTone2: avanca os dados extras do instrumento | ALTA | P2 | Baixo | ACEITO |
| N-347 | — | `$37` | `37:EAFF` | `L37_EAFF` | `_FT2SetInstrumentLoadEnvelopes` | Código | FamiTone2: carrega os ponteiros de envelope restantes do instrumento | ALTA | P2 | Baixo | ACEITO |
| N-348 | — | `$37` | `37:EB1A` | `L37_EB1A` | `_FT2ChannelNoRepeat` | Código | FamiTone2: o contador de repeticao terminou; le a proxima nota | ALTA | P2 | Baixo | ACEITO |
| N-349 | — | `$37` | `37:EB2E` | `L37_EB2E` | `_FT2ReadByteAdvance` | Código | FamiTone2: terminou de avancar o ponteiro do canal | ALTA | P2 | Baixo | ACEITO |
| N-350 | — | `$37` | `37:EB35` | `L37_EB35` | `_FT2ReadVolumeCommand` | Código | FamiTone2: le um comando de volume | ALTA | P2 | Baixo | ACEITO |
| N-351 | — | `$37` | `37:EB43` | `L37_EB43` | `_FT2ReadVolumeClamp` | Código | FamiTone2: limita e grava o volume solicitado | ALTA | P2 | Baixo | ACEITO |
| N-352 | — | `$37` | `37:EB49` | `L37_EB49` | `_FT2ReadCommand` | Código | FamiTone2: distingue nota comum de comando do canal | ALTA | P2 | Baixo | ACEITO |
| N-353 | — | `$37` | `37:EB50` | `L37_EB50` | `_FT2ReadStopSlide` | Código | FamiTone2: comando $5F encerra o slide | ALTA | P2 | Baixo | ACEITO |
| N-354 | — | `$37` | `37:EB59` | `L37_EB59` | `_FT2ReadShiftDown` | Código | FamiTone2: comando $6F desloca a nota para baixo | ALTA | P2 | Baixo | ACEITO |
| N-355 | — | `$37` | `37:EB60` | `L37_EB60` | `_FT2ReadSlideCommand` | Código | FamiTone2: seleciona os modos de slide ou a profundidade do vibrato | ALTA | P2 | Baixo | ACEITO |
| N-356 | — | `$37` | `37:EB79` | `L37_EB79` | `_FT2ReadSlideStop` | Código | FamiTone2: zera o deslocamento e habilita o tom fixo | ALTA | P2 | Baixo | ACEITO |
| N-357 | — | `$37` | `37:EB91` | `L37_EB91` | `_FT2ReadSlideDownMode` | Código | FamiTone2: comando $6B habilita o slide para baixo | ALTA | P2 | Baixo | ACEITO |
| N-358 | — | `$37` | `37:EBA4` | `L37_EBA4` | `_FT2ReadSlideUpMode` | Código | FamiTone2: comando $6C habilita o slide para cima | ALTA | P2 | Baixo | ACEITO |
| N-359 | — | `$37` | `37:EBB7` | `L37_EBB7` | `_FT2ReadPortamentoMode` | Código | FamiTone2: comando $6D habilita o portamento ate a nota | ALTA | P2 | Baixo | ACEITO |
| N-360 | — | `$37` | `37:EBDF` | `L37_EBDF` | `_FT2ShiftUpNote` | Código | FamiTone2: soma o deslocamento a uma nota da sequencia | ALTA | P2 | Baixo | ACEITO |
| N-361 | — | `$37` | `37:EC11` | `L37_EC11` | `_FT2ShiftCurrentUp` | Código | FamiTone2: soma o deslocamento a nota corrente | ALTA | P2 | Baixo | ACEITO |
| N-362 | — | `$37` | `37:EC35` | `L37_EC35` | `_FT2ShiftDownNote` | Código | FamiTone2: subtrai o deslocamento de uma nota da sequencia | ALTA | P2 | Baixo | ACEITO |
| N-363 | — | `$37` | `37:EC3D` | `L37_EC3D` | `_FT2ShiftCurrentDown` | Código | FamiTone2: subtrai o deslocamento da nota corrente | ALTA | P2 | Baixo | ACEITO |
| N-364 | — | `$37` | `37:EC83` | `L37_EC83` | `_FT2PlainNoteClearPitch` | Código | FamiTone2: nota comum e desativacao do tom fixo | ALTA | P2 | Baixo | ACEITO |
| N-365 | — | `$37` | `37:EC8B` | `L37_EC8B` | `_FT2PlainNoteStoreOnly` | Código | FamiTone2: grava a nota sem alterar o estado de tom fixo | ALTA | P2 | Baixo | ACEITO |
| N-366 | — | `$37` | `37:EC9E` | `L37_EC9E` | `_FT2SpecialEmptyRows` | Código | FamiTone2: tratta linhas vazias e comandos de referencia do canal | ALTA | P2 | Baixo | ACEITO |
| N-367 | — | `$37` | `37:ECCF` | `L37_ECCF` | `_FT2SpecialSpeed` | Código | FamiTone2: le e grava a velocidade da musica | ALTA | P2 | Baixo | ACEITO |
| N-368 | — | `$37` | `37:ECDB` | `L37_ECDB` | `_FT2SpecialSpeedAdvance` | Código | FamiTone2: avanca o ponteiro apos ler a velocidade | ALTA | P2 | Baixo | ACEITO |
| N-369 | — | `$37` | `37:ECE2` | `L37_ECE2` | `_FT2SpecialLoop` | Código | FamiTone2: troca o ponteiro do canal pelo destino do loop | ALTA | P2 | Baixo | ACEITO |
| N-370 | — | `$37` | `37:ECF3` | `L37_ECF3` | `_FT2SpecialRepeat` | Código | FamiTone2: grava o contador de repeticao do canal | ALTA | P2 | Baixo | ACEITO |
| N-371 | — | `$37` | `37:ECF6` | `L37_ECF6` | `_FT2SpecialDone` | Código | FamiTone2: finaliza o comando e trata a referencia ativa | ALTA | P2 | Baixo | ACEITO |
| N-372 | — | `$37` | `37:ED0D` | `L37_ED0D` | `_FT2SpecialContinue` | Código | FamiTone2: mantem o ponteiro corrente do canal | ALTA | P2 | Baixo | ACEITO |
| N-373 | — | `$37` | `37:ED20` | `L37_ED20` | `_FT2ReadParamDone` | Código | FamiTone2: devolve o parametro apos avancar o ponteiro | ALTA | P2 | Baixo | ACEITO |
| N-374 | — | `$37` | `37:ED35` | `L37_ED35` | `_FT2SamplePlayMNotBusy` | Código | FamiTone2: o canal DMC esta livre; inicia a amostra de musica | ALTA | P2 | Baixo | ACEITO |
| N-375 | — | `$37` | `37:ED89` | `L37_ED89` | `_FT2SfxInitChannels` | Código | FamiTone2: inicializa todos os canais de efeito sonoro | ALTA | P2 | Baixo | ACEITO |
| N-376 | — | `$37` | `37:EDD5` | `L37_EDD5` | `_FT2SfxUpdateNoRepeat` | Código | FamiTone2: o contador de repeticao do efeito terminou | ALTA | P2 | Baixo | ACEITO |
| N-377 | — | `$37` | `37:EDDB` | `L37_EDDB` | `_FT2SfxUpdateActive` | Código | FamiTone2: carrega o roteiro do efeito ativo | ALTA | P2 | Baixo | ACEITO |
| N-378 | — | `$37` | `37:EDF9` | `L37_EDF9` | `_FT2SfxReadData` | Código | FamiTone2: le um comando de escrita de registrador do efeito | ALTA | P2 | Baixo | ACEITO |
| N-379 | — | `$37` | `37:EE16` | `L37_EE16` | `_FT2SfxAdvanceDone` | Código | FamiTone2: terminou de avancar o ponteiro do efeito | ALTA | P2 | Baixo | ACEITO |
| N-380 | — | `$37` | `37:EE17` | `L37_EE17` | `_FT2SfxEnd` | Código | FamiTone2: marca o canal de efeito como inativo | ALTA | P2 | Baixo | ACEITO |
| N-381 | — | `$37` | `37:EE33` | `L37_EE33` | `_FT2SfxUpdatePulse1` | Código | FamiTone2: mistura o volume e o periodo da canal 1 do efeito | ALTA | P2 | Baixo | ACEITO |
| N-382 | — | `$37` | `37:EE4C` | `L37_EE4C` | `_FT2SfxUpdatePulse2` | Código | FamiTone2: mistura o volume e o periodo da canal 2 do efeito | ALTA | P2 | Baixo | ACEITO |
| N-383 | — | `$37` | `37:EE60` | `L37_EE60` | `_FT2SfxUpdateTriangle` | Código | FamiTone2: mistura o controle e o periodo do triangulo do efeito | ALTA | P2 | Baixo | ACEITO |
| N-384 | — | `$37` | `37:EE73` | `L37_EE73` | `_FT2SfxUpdateNoise` | Código | FamiTone2: mistura o volume e o periodo do ruido do efeito | ALTA | P2 | Baixo | ACEITO |
| N-385 | — | `$37` | `37:EF35` | `L37_EF35` | `_FT2ScaleVolumeLoop` | Código | FamiTone2: laco de escala do volume pela atenuacao | ALTA | P2 | Baixo | ACEITO |
| N-386 | — | `$37` | `37:EF3F` | `L37_EF3F` | `_FT2ScaleVolumeNext` | Código | FamiTone2: proximo passo da escala de volume | ALTA | P2 | Baixo | ACEITO |
| N-387 | — | `$37` | `37:EF48` | `L37_EF48` | `_FT2ScaleVolumeReturn` | Código | FamiTone2: devolve o volume ja escalado | ALTA | P2 | Baixo | ACEITO |
| N-388 | — | `$37` | `37:EF49` | `L37_EF49` | `_FT2ScaleVolumeMinimum` | Código | FamiTone2: devolve volume minimo 1 quando o resultado seria zero | ALTA | P2 | Baixo | ACEITO |

---

## 4. Convenções de naming aplicadas

| Tipo | Padrão | Exemplos |
|------|--------|----------|
| Rotina | PascalCase, verbo + objeto | `StateCondDispatchLoop`, `DrawProjectile` |
| Bloco interno de rotina | `<Rotina><Ação>` ou sufixo descritivo | `TimerUpdateFlip`, `PortraitPalCopyLoop` |
| Condição de transição | `Cond` + predicado | `CondOpponentNear`, `CondCanGrab` |
| IA do Ryu | `RyuAi` + subsistema + ação | `RyuAiAntiAirDist2`, `RyuAiOpponentGrounded` |
| FamiTone2 interno | `_FT2` + nome estrutural | `_FT2UpdateTempo`, `_FT2Channel1NewNote` |
| Vetor de banco | `ResetVector<bb>` / `NmiVector` | `ResetVector37`, `NmiVector` |

Princípios: nomear pelo papel demonstrado; não afirmar característica não provada; preservar o nome antigo no inventário; não fazer renomeação cosmética em massa.

---

## 5. Métricas finais e reconciliação

Método canônico: `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s`, com `L<bb>_<aaaa>` = código automático, `D<bb>_<aaaa>` = dados automáticos, e o restante = semântico.

| Métrica | Fase 1 | Após Fase 3 |
|---------|--------|-------------|
| Definições de rótulo | 2.145 | **2.145** |
| Nomes únicos | 2.141 | **2.141** |
| Automáticos de código (`L`) | 379 | **0** |
| Automáticos de dados (`D`) | 1.213 | **1.213** |
| Semânticos únicos | 549 | **928** |
| Soma semântica por banco | — | **931** |

**Reconciliação:** a soma por banco dá 931 porque `ResetStub` aparece em três bancos (`$37`, `$3B`, `$3F`) e `RoundStart` em dois (`$3B`, `$3F`); globalmente são 928 nomes únicos. `InputButtons` aparece duas vezes dentro do banco `$3F`, mas conta uma vez no total único do banco.

**Limitação do método:** o regex `^...:$` não conta três rótulos semânticos com comentário na mesma linha (`EdgeARel`, `EdgeBRel`, `EdgeBBtn`, no banco `$3F`). Incluí-los elevaria a contagem semântica para 931 únicos; a métrica publicada permanece 928 para ser reproduzível pelo comando acima.

### 5.1 Detalhamento por banco (métrica canônica)

| Banco | Definições | Únicos | Auto código | Auto dados | Semânticos |
|-------|------------|--------|-------------|------------|------------|
| `$00` | 257 | 257 | 0 | 206 | 51 |
| `$01` | 305 | 305 | 0 | 304 | 1 |
| `$04` | 3 | 3 | 0 | 3 | 0 |
| `$05` | 353 | 353 | 0 | 352 | 1 |
| `$08`, `$0C`, `$10`, `$1C`, `$24` | 5 | 5 | 0 | 5 | 0 |
| `$20` | 30 | 30 | 0 | 30 | 0 |
| `$29` | 103 | 103 | 0 | 103 | 0 |
| `$2D` | 70 | 70 | 0 | 70 | 0 |
| `$36` | 30 | 30 | 0 | 30 | 0 |
| `$37` | 277 | 277 | 0 | 27 | 250 |
| `$3B` | 263 | 263 | 0 | 35 | 228 |
| `$3C` | 38 | 38 | 0 | 33 | 5 |
| `$3F` | 411 | 410 | 0 | 15 | 395 |
| **Total** | **2.145** | **2.144**¹ | **0** | **1.213** | **931**¹ |

¹ Soma por banco. Globalmente: 2.141 nomes únicos e 928 semânticos únicos, descontando `ResetStub` (3×), `RoundStart` (2×) e `InputButtons` (2× no mesmo banco).

---

## 6. Verificação de integridade

| Verificação | Resultado |
|-------------|-----------|
| `make gen` | OK — `src/` regenerado a partir de `annotations/sf2ne.ann` |
| `make` | OK — ROM canônico com `DEST_FLAG_BLINK` |
| SHA-1 de `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` (idêntico ao baseline) |
| Colunas de bytes vs `HEAD` | `$00` 297/297, `$37` 1723/1723, `$3B` 2461/2461, `$3F` 3001/3001 — idênticas |
| `make fixed` | OK — divergência esperada (`-D FIX_SOFT_RESET`) |
| Rótulos automáticos de código | 0 |

---

## 7. Proveniência do lote FamiTone2

- Referência estrutural: **FamiTone2 v1.15** (Shiru), pacote `famitone2.zip`.
- SHA-256 do pacote usado: `7b124d03ed7b7cfa9ebbc9bbaa3d43448f57b79cc558760d97ffab2cd2e88738`.
- Os nomes internos foram normalizados de `FamiTone*` para `_FT2*` (21 ocorrências) para deixar claro que são símbolos internos da biblioteca, não API do jogo.
- A numeração de canais e a estrutura de envelopes/notas foram conferidas contra o código desmontado; nenhum byte foi alterado.

---

## 8. Pendências e próximo passo

1. **Commit:** os lotes P2, PAD e FT2 e esta documentação aguardam aprovação explícita do usuário; nada foi commitado ou pushado nesta sessão. O relatório de execução está em `tasks/PHASE_3_EXECUTION_REPORT.md`.
2. **Lote de dados (`D<bb>_<aaaa>`, 1.213):** priorizado em `tasks/DATA_LABEL_INVENTORY.tsv`; o primeiro lote (`$3C`, 33 labels) foi aplicado em `tasks/DATA_NAMING_3C.md`. Restam 1.180.
3. **Decisões D-01…D-07:** permanecem `PENDENTE` em `tasks/STABILIZATION_BACKLOG.md`.
4. **Migração de estados/quadros para TOML:** não autorizada e não iniciada.
