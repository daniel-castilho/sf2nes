# Inventário de candidatos a naming — Fase 3

**Origem:** `tasks/PHASE_3_EVIDENCE_GUIDED_NAMING_SPEC.md` (Fase 3 do plano de estabilização)  
**Status:** inventário inicial — aguarda autorização de execução para aplicar renomeações  
**Linha de base:** `docs/ESTADO_DO_PROJETO.md` (Fase 1) — 379 labels automáticos de código, 1.213 de dados, 549 semânticos  
**Fonte canônica:** `annotations/sf2ne.ann` (conforme decisão da Fase 2)  
**Nenhuma alteração aplicada ainda** — apenas documentação de planejamento

---

## 1. Critérios de prioridade

| Nível | Critério | Tratamento |
|-------|----------|------------|
| **P0 — central e confirmado** | Rotina compartilhada, dispatcher, carregador, transição ou tabela central sem nome útil; uso/callers demonstráveis e confiança alta. | Primeiro lote sugerido. |
| **P1 — alto impacto e confirmado** | Rotina/dado frequentemente usado por luta, personagem, input, colisão, dano, desenho ou fluxo de telas; evidência clara. | Próximos lotes por subsistema. |
| **P2 — localizado** | Auxiliar com uso limitado, porém compreendido e relevante à manutenção. | Só após P0/P1 ou se bloqueia outra tarefa autorizada. |
| **P3 — opaco/hipótese** | Semântica não determinada, evidência contraditória, código não executado ou estrutura possivelmente morta. | Manter label atual; documentar pergunta/evidência faltante, sem renomear como fato. |

---

## 2. Candidatos P0 — central e confirmado

### Banco $3F (núcleo do motor de luta)

| ID | Endereço | Símbolo atual | Símbolo proposto | Categoria | Evidência | Confiança | Prioridade | Decisão |
|----|----------|---------------|------------------|-----------|-----------|-----------|------------|---------|
| C3F-01 | 3F:EFF5 | L3F_EFF5 | TimerUpdate | Código | Rotina contígua a TimerUpdate_F0ED (3F:F0ED), chamada por FightFrame; lida com decremento do timer de round | ALTA | P0 | PENDENTE |
| C3F-02 | 3F:EFF7 | L3F_EFF7 | TimerUpdateContinue | Código | Continuação de TimerUpdate, dentro do mesmo bloco de timer | MÉDIA | P0 | PENDENTE |
| C3F-03 | 3F:F927 | L3F_F927 | JoyReadLoop | Código | Loop interno de JoyRead que lê bits do controle e rota em JoyState; chamado repetidamente para cada botão | ALTA | P0 | PENDENTE |
| C3F-04 | 3F:FFBE | L3F_FFBE | ResetVector37 | Código/Dados | Vetor de reset no banco $37 (pontos de vetor em $FFFA-$FFFF) | ALTA | P0 | PENDENTE |
| C3F-05 | 3F:FFC4 | L3F_FFC4 | ResetVector3B | Código/Dados | Vetor de reset no banco $3B | ALTA | P0 | PENDENTE |
| C3F-06 | 3F:FFDD | L3F_FFDD | ResetVector3F | Código/Dados | Vetor de reset no banco $3F | ALTA | P0 | PENDENTE |
| C3F-07 | 3F:FFE6 | L3F_FFE6 | NmiVector | Código/Dados | Vetor de NMI comum aos bancos de código | ALTA | P0 | PENDENTE |

### Banco $3B (código da luta)

| ID | Endereço | Símbolo atual | Símbolo proposto | Categoria | Evidência | Confiança | Prioridade | Decisão |
|----|----------|---------------|------------------|-----------|-----------|-----------|------------|---------|
| C3B-01 | 3B:E0A0 | L3B_E0A0 | PortraitLoadPalettesLoop | Código | Dentro de PortraitLoadPalettes (3B:E181), loop de cópia de paletas de lutador | MÉDIA | P1 | PENDENTE |
| C3B-02 | 3B:E131 | L3B_E131 | FighterFlipSet | Código | Define FighterFlip (bit de espelhamento do lutador) baseado em entrada de direção | ALTA | P1 | PENDENTE |
| C3B-03 | 3B:E165 | L3B_E165 | PortraitPaletteCopyLoop | Código | Loop de cópia de 3 bytes de paleta para ram_0300/ram_0303/ram_0306 | MÉDIA | P1 | PENDENTE |

### Banco $37 (som, seleção, telas)

| ID | Endereço | Símbolo atual | Símbolo proposto | Categoria | Evidência | Confiança | Prioridade | Decisão |
|----|----------|---------------|------------------|-----------|-----------|-----------|------------|---------|
| C37-01 | 37:XXXX | L37_XXXX | SelectDrawFighterLoop | Código | Loop de desenho do lutador na seleção | MÉDIA | P1 | PENDENTE |

> Nota: lista de P0 do banco $37 pendente de leitura do contexto dos 158 labels automáticos.

---

## 3. Candidatos P1 — alto impacto e confirmado

### Banco $3F (núcleo do motor de luta)

| ID | Endereço | Símbolo atual | Símbolo proposto | Categoria | Evidência | Confiança | Prioridade | Decisão |
|----|----------|---------------|------------------|-----------|-----------|-----------|------------|---------|
| C3F-08 | 3F:E0F2 | L3F_E0F2 | StateCondDispatchLoop | Código | Loop de despacho das condições de transição de estado | ALTA | P1 | PENDENTE |
| C3F-04 | 3F:E111 | L3F_E111 | StateCondTableEntry | Código | Entrada da tabela de condições de transição | ALTA | P1 | PENDENTE |
| C3F-05 | 3F:E11D | L3F_E11D | StateCondTableContinue | Código | Continuação da tabela de condições | ALTA | P1 | PENDENTE |

### Banco $3B (código da luta)

| ID | Endereço | Símbolo atual | Símbolo proposto | Categoria | Evidência | Confiança | Prioridade | Decisão |
|----|----------|---------------|------------------|-----------|-----------|-----------|------------|---------|
| C3B-04 | 3B:F015 | L3B_F015 | StageSplitSetup | Código | Configuração da divisão de tela (IRQ de scanline) | ALTA | P1 | PENDENTE |
| C3B-05 | 3B:F027 | L3B_F027 | StageSplitContinue | Código | Continuação da divisão de tela | MÉDIA | P1 | PENDENTE |
| C3B-06 | 3B:F27F | L3B_F27F | DrawProjectile | Código | Desenho de projétil (hadouken) | ALTA | P1 | PENDENTE |
| C3B-07 | 3B:F2B5 | L3B_F2B5 | DrawProjectileSprite | Código | Desenho do sprite do projétil | ALTA | P1 | PENDENTE |
| C3B-08 | 3B:F315 | L3B_F315 | DrawMetaspritePosition | Código | Posicionamento de grupo de metasprite | ALTA | P1 | PENDENTE |
| C3B-09 | 3B:F324 | L3B_F324 | DrawMetaspriteGroupLoop | Código | Loop de grupos de metasprite | ALTA | P1 | PENDENTE |
| C3B-10 | 3B:F331 | L3B_F331 | DrawMetaspriteWriteOAM | Código | Escrita de um sprite na OAM | ALTA | P1 | PENDENTE |
| C3B-11 | 3B:F356 | L3B_F356 | DrawMetaspriteEnd | Código | Término do desenho de metasprite | ALTA | P1 | PENDENTE |
| C3B-12 | 3B:F364 | L3B_F364 | SelectDrawBlinkDraw | Código | Desenho do lutador piscando na seleção | MÉDIA | P1 | PENDENTE |
| C3B-13 | 3B:F37D | L3B_F37D | SelectScreenBuildPaletteLoop | Código | Loop de cópia de paletas na construção da tela de seleção | MÉDIA | P1 | PENDENTE |

---

## 4. Candidatos P2 — localizado

### Banco $3F (núcleo do motor de luta)

| ID | Endereço | Símbolo atual | Símbolo proposto | Categoria | Evidência | Confiança | Prioridade | Decisão |
|----|----------|---------------|------------------|-----------|-----------|-----------|------------|---------|
| C3F-06 | 3F:E158 | L3F_E158 | StateCondTableEntry2 | Código | Entrada secundária da tabela de condições | MÉDIA | P2 | PENDENTE |
| C3F-07 | 3F:E15D | L3F_E15D | StateCondTableEntry3 | Código | Entrada terciária da tabela de condições | MÉDIA | P2 | PENDENTE |
| C3F-08 | 3F:E191 | L3F_E191 | CondTableEntry4 | Código | Entrada da tabela de condições | MÉDIA | P2 | PENDENTE |

### Banco $3B (código da luta)

| ID | Endereço | Símbolo atual | Símbolo proposto | Categoria | Evidência | Confiança | Prioridade | Decisão |
|----|----------|---------------|------------------|-----------|-----------|-----------|------------|---------|
| C3B-14 | 3B:E1A6 | L3B_E1A6 | PortraitPaletteOffsetCalc | Código | Cálculo de offset para ponteiro de paleta de retrato | MÉDIA | P2 | PENDENTE |
| C3B-15 | 3B:E1B1 | L3B_E1B1 | PortraitPaletteOffsetCalc2 | Código | Continuação do cálculo de offset | MÉDIA | P2 | PENDENTE |
| C3B-16 | 3B:E1BB | L3B_E1BB | PortraitFighterIdxCalc | Código | Cálculo do índice de lutador para tabela de paleta | MÉDIA | P2 | PENDENTE |
| C3B-17 | 3B:E1C6 | L3B_E1C6 | PortraitPaletteByteCopy | Código | Cópia de byte de paleta de retrato | MÉDIA | P2 | PENDENTE |

### Banco $3B (código da luta — desenho)

| ID | Endereço | Símbolo atual | Símbolo proposto | Categoria | Evidência | Confiança | Prioridade | Decisão |
|----|----------|---------------|------------------|-----------|-----------|-----------|------------|---------|
| C3B-18 | 3B:E201 | L3B_E201 | PortraitBuildClearLoop | Código | Loop de limpeza do buffer de retrato | MÉDIA | P2 | PENDENTE |
| C3B-19 | 3B:E20E | L3B_E20E | PortraitDecodeChunkLoop | Código | Loop de decodificação de chunk de retrato | MÉDIA | P2 | PENDENTE |
| C3B-20 | 3B:E230 | L3B_E230 | PortraitDecodeChunkLoop2 | Código | Continuação do loop de decodificação | MÉDIA | P2 | PENDENTE |

---

## 5. Candidatos P3 — opaco/hipótese

| ID | Endereço | Símbolo atual | Símbolo proposto | Categoria | Evidência | Confiança | Prioridade | Decisão |
|----|----------|---------------|------------------|-----------|-----------|-----------|------------|---------|
| C3F-09 | 3F:E239 | L3F_E239 | Desconhecido | Código | Semântica não determinada; possível rotina auxiliar de estado | BAIXA | P3 | ADIADO |
| C3F-10 | 3F:E252 | L3F_E252 | Desconhecido | Código | Semântica não determinada | BAIXA | P3 | ADIADO |
| C3F-11 | 3F:E2A3 | L3F_E2A3 | Desconhecido | Código | Semântica não determinada | BAIXA | P3 | ADIADO |

> Todos os candidatos P3 permanecem com label atual até que evidência suficiente seja obtida (trace, execução ou leitura estática aprofundada).

---

## 6. Labels automáticos de dados (D<bb>_<addr>)

Os labels automáticos de dados (1.213 no total) incluem tabelas de ponteiros, constantes e estruturas. A priorização segue o mesmo critério, mas com foco em:

- **P0:** Tabelas de ponteiros centrais (StateCondLo, StateCondHi, D3F_F0B1/D3F_F0B7 do MoveDispatch, tabelas de IA)
- **P1:** Tabelas de dados frequentemente acessadas (tabelas de frames, colisão, paletas)
- **P2/P3:** Dados locais, padding, estruturas opacas

Lista detalhada pendente de leitura específica por banco.

---

## 7. Convenções de命名 (proposta)

Seguindo as convenções existentes no código:

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Rotina | PascalCase + sufixo de endereço opcional | `TimerUpdate`, `JoyReadLoop` |
| Tabela de ponteiros | PascalCase + `Tbl` | `MoveDispatchTbl` |
| Constante/dado | PascalCase | `FighterHP` |
| Campo de RAM | PascalCase | `PaletteBuf` |
| Label de banco | `Banco<Nome>` | `BancoEstadosRyu` |

Princípios:
- Nomear pelo papel demonstrado, não pelo valor ou aparência do dado
- Evitar nomes que afirmem característica não provada (`Random`, `Timer`, `Hitbox` sem confirmação)
- Manter nomes existentes coerentes, não renomeação cosmética em massa
- Preservar o nome antigo no inventário para mapeamento futuro

---

## 8. Próximos passos (aguardam autorização de execução)

1. **Gate C:** Autorização para editar `annotations/sf2ne.ann` (fonte canônica de símbolos)
2. **Lote P0:** Renomear os 7 candidatos P0 do banco 3F
3. **Lote P1:** Renomear os candidatos P1 dos bancos 3F e 3B
4. **Atualizar `docs/ESTADO_DO_PROJETO.md`** com métrica pós-lote (mesmo método da Fase 1)
5. **Relatório de lote:** diff de labels, ambiguidades não resolvidas, impacto em referências

Nenhuma alteração aplicada nesta fase de planejamento. O inventário está pronto para execução após autorização explícita.
