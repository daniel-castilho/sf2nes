# Relatório de execução — Fase 3 (naming guiado por evidência)

**Data:** 2026-11-15 (lotes de código); atualizado em 2026-11-16 (lotes de dados e fechamento)  
**Base commitada:** `2df963c` (lote `$20`; anteriores: `e2e18f3`, `64a29f8`, `92fbde1`)  
**Estado:** Fase 3 concluída e verificada; todos os lotes commitados e pushados.  
**Escopo:** renomeação de símbolos e comentários; nenhum byte de código/dado foi alterado.

> As seções 1–9 preservam o registro de 2026-11-15, quando apenas os lotes de código estavam no diff. A seção 10 consolida os lotes de dados, as métricas finais e o aceite da fase.

## 1. Arquivos alterados

| Arquivo | Natureza da alteração |
|---------|-----------------------|
| `annotations/sf2ne.ann` | Fonte canônica: 388 rótulos (21 P0/P1 já commitados no Gate D; 367 no diff atual: 251 P2, 7 PAD e 109 FamiTone2) e comentários de evidência |
| `src/bank_00.s`, `src/bank_01.s`, `src/bank_37.s`, `src/bank_3B.s`, `src/bank_3F.s` | Saída gerada por `make gen`; apenas rótulos/comentários |
| `tasks/NAMING_CANDIDATES.md` | Inventário completo, 388 linhas com ID único, ID anterior, evidência, confiança, prioridade, risco e decisão |
| `docs/ESTADO_DO_PROJETO.md` | Métricas reconciliadas e nova seção 11 com o estado após a Fase 3 |
| `README.md` | Métrica de rótulos atualizada (2.145 definições; 928 semânticos; 0 automáticos de código) |

Não houve alteração em `tools/`, `Makefile`, `sf2ne.cfg`, assets, ROM de referência ou código de gameplay.

## 2. Símbolos renomeados

O detalhamento por endereço está em `tasks/NAMING_CANDIDATES.md` (tabelas 3.1 a 3.4). Resumo:

| Lote | Linhas | Distribuição |
|------|--------|--------------|
| P0/P1 (Gate D) | 21 | `$3F` 10, `$3B` 11 |
| P2 | 251 | `$00` 48, `$37` 49, `$3B` 142, `$3F` 12 |
| PAD | 7 | `$3F` 7 |
| FamiTone2 | 109 | `$37` 109 (107 internos `_FT2*` + 2 rotinas de topo) |
| **Total** | **388** | — |

## 3. Evidência e confiança

- **P0/P1:** fluxo/chamadas demonstráveis; maioria `ALTA`, com `MÉDIA` em blocos de retrato, HUD e seleção.
- **P2:** leitura estática do fluxo e dos comentários já existentes no `.ann`; `ALTA` em todas as linhas aplicadas.
- **PAD:** semântica das condições de transição confirmada no código; `ALTA`.
- **FamiTone2:** estrutura conferida contra a biblioteca pública v1.15; `ALTA` para o papel estrutural.
- **Nenhum** nome foi aplicado com confiança `BAIXA`.
- Nomes ambíguos ou sem evidência suficiente permaneceram automáticos (não houve renomeação por suposição).

## 4. Métricas antes/depois

Método canônico: `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s`.

| Métrica | Fase 1 | Após a Fase 3 |
|---------|--------|---------------|
| Definições de rótulo | 2.145 | **2.145** |
| Nomes únicos | 2.141 | **2.141** |
| Automáticos de código (`L`) | 379 | **0** |
| Automáticos de dados (`D`) | 1.213 | **1.213** |
| Semânticos únicos | 549 | **928** |
| Soma semântica por banco | — | **931** |

A soma por banco (931) difere do total único (928) por `ResetStub` (3 bancos), `RoundStart` (2 bancos) e `InputButtons` (2× no `$3F`). O regex não conta três rótulos com comentário na mesma linha (`EdgeARel`, `EdgeBRel`, `EdgeBBtn`).

## 5. Ambiguidades e limitações

- `EdgeARel`, `EdgeBRel` e `EdgeBBtn` ficam fora da métrica canônica por terem comentário na mesma linha; a métrica publicada permanece 928 para ser reproduzível.
- `InputButtons` continua duplicado dentro do banco `$3F`; não foi renomeado para não alterar o contrato existente.
- Não houve execução em emulador; a verificação é estática (fluxo, chamadas, comentários) + build + SHA-1/bytes.
- No estado de 2026-11-15, D-01…D-07 continuavam `PENDENTE`; o fechamento resolveu D-01 e D-03 e manteve D-02 `PROPOSTO` (ver §10.4).
- A migração de estados/quadros para TOML não foi autorizada nem iniciada.

## 6. Efeitos em ferramentas e documentos

- `src/globals.inc` não precisou de alteração (os rótulos renomeados não mudaram exports entre bancos).
- `docs/ESTADO_DO_PROJETO.md` foi reconciliado com a métrica canônica e ganhou a seção 11.
- `README.md` deixou de publicar a métrica histórica (1.795/304) e passou a publicar a atual.
- Nenhum script de `tools/` foi criado ou modificado.

## 7. Comandos e validações executados

| Comando/validação | Resultado |
|-------------------|-----------|
| `make gen` | OK; `src/` regenerado a partir de `annotations/sf2ne.ann` |
| `make` | OK; build canônico com `DEST_FLAG_BLINK` |
| `sha1sum build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — idêntico ao baseline |
| Colunas de bytes vs `HEAD` | 29 bancos comparados, 8.891 bytes, todas idênticas |
| `make fixed` | OK; divergência esperada (`-D FIX_SOFT_RESET`) |
| Contagem de rótulos | `unique=2141 extra=4 autoL=0 autoD=1213 semantic=928` |

## 8. Preservação e escopo

- A coluna 0 (Ryu) permaneceu intocada; nenhum byte de personagem, estado, quadro, IA ou gameplay foi alterado.
- Nenhum novo personagem, IA de Ken, funcionalidade, conversor ou refatoração de kernel foi iniciado.
- As alterações locais preexistentes foram preservadas; não houve `clean`, `reset` ou `restore`.
- Naquela sessão, nada foi commitado ou pushado; os lotes foram commitados depois (ver §10).

## 9. Proposta de commit

> **Status:** executada em `e2e18f3`; esta seção é mantida como registro histórico.

Recomendo **um commit único** para o conjunto já verificado, porque o diff de `annotations/sf2ne.ann` contém os lotes P2, PAD e FamiTone2 intercalados no mesmo arquivo e o inventário/documentação já descrevem o estado final. Separar em dois commits exigiria staging manual de hunks e deixaria o commit intermediário com documentação inconsistente.

Mensagem sugerida:

```text
Fase 3: naming guiado por evidência (P2, PAD e FamiTone2)

- 251 rótulos P2, 7 condições PAD e 109 mapeamentos FamiTone2
- inventário completo com 388 linhas e IDs únicos
- métricas reconciliadas: 0 auto código, 1.213 auto dados, 928 semânticos
- ROM SHA-1 idêntico: 3ad177a0a7867a821e6c1709b4e6dbdda3555aa1
```

---

## 10. Fechamento final — lotes de dados e estado consolidado

As métricas das seções 4 e 7 são históricas (antes dos lotes de dados). Valem as métricas desta seção.

### 10.1 Lotes de dados aplicados

| Lote | Linhas | Escopo | Commit |
|------|--------|--------|--------|
| Dados `$3C` | 33 | fichas, paletas e retratos | `64a29f8` |
| Dados `$3F` | 15 | núcleo de luta | `92fbde1` |
| Dados `$20` | 30 | HUD/efeitos, bandeiras, projéteis e retrato do M.Bison | `2df963c` |
| **Total** | **78** | — | — |

Com os 388 rótulos de código, a Fase 3 renomeou **466 rótulos**.

### 10.2 Métricas finais

Método canônico: `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s`, com a ressalva dos três rótulos que têm comentário na mesma linha (`EdgeARel`, `EdgeBRel`, `EdgeBBtn`).

| Métrica | Fase 1 | Fechamento |
|---------|--------|------------|
| Definições de rótulo | 2.145 | **2.145** |
| Nomes únicos | 2.141 | **2.141** |
| Automáticos de código (`L`) | 379 | **0** |
| Automáticos de dados (`D`) | 1.213 | **1.135** |
| Semânticos únicos | 549 | **1.006** |
| Soma semântica por banco | — | **1.010** |

A diferença de 1.010 para 1.006 vem de `ResetStub` (3×), `RoundStart` (2×) e `InputButtons` (2× no `$3F`). O regex canônico não conta os três rótulos com comentário na mesma linha; incluí-los daria 1.009 semânticos únicos e 1.013 na soma por banco.

### 10.3 Verificação

| Verificação | Resultado |
|-------------|-----------|
| `make gen` | OK |
| `make` | OK — build canônico com `DEST_FLAG_BLINK` |
| SHA-1 de `build/sf2ne.nes` | `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` — idêntico ao baseline |
| `src/bank_20.s` | 0 labels `D20_*`; 144 diretivas `.byte`/`.word` com operandos idênticos |
| `src/bank_37.s`, `src/bank_3B.s`, `src/bank_3C.s` | apenas troca de `D20_*` pelos novos nomes; mesmos endereços nos comentários |
| `src/bank_05.s` (Ken, fonte manual) | 0 referências a `D20_*` |
| `make fixed` | OK — divergência esperada (`-D FIX_SOFT_RESET`) |

### 10.4 Decisões e aceite

- **D-01 — RESOLVIDO.** Método reproduzível registrado em `docs/ESTADO_DO_PROJETO.md` §4/§11 e nesta seção: contar definições e nomes únicos separadamente, distinguir código/dados/semânticos e manter a ressalva dos três rótulos com comentário na mesma linha.
- **D-03 — RESOLVIDO.** A primeira leva foi P0/P1 (núcleo do motor), seguida de P2/PAD/FamiTone2 e dos dados `$3C`, `$3F` e `$20`. Evidência mínima: consumidor demonstrável, estrutura de tabela ou documentação existente; confiança `ALTA`/`MÉDIA`; `BAIXA` permanece automático.
- **D-02 — PROPOSTO, não bloqueante para o naming.** A decisão sobre fonte canônica de estados/quadros (`tasks/STATE_DATA_FORMAT_DECISION.md`) continua aguardando o Mantenedor. A Fase 3 não a usou: o naming atuou apenas em símbolos, cuja fonte canônica é `annotations/sf2ne.ann`.
- **D-04…D-07 — PENDENTE**, sem mudança nesta fase.

Critérios de aceite da spec §12:

| Critério | Estado | Evidência |
|----------|--------|-----------|
| Gates das Fases 0–2 e fonte canônica disponíveis | ATENDIDO para símbolos | Fases 0/1 concluídas; fonte de símbolos = `annotations/sf2ne.ann`; D-02 (estados/quadros) segue `PROPOSTO` e fora do escopo do naming |
| Métrica inicial reconciliada e método congelado | ATENDIDO | §10.2 e `docs/ESTADO_DO_PROJETO.md` §4/§11 |
| Inventário com endereço, label, nome, categoria, evidência, confiança e prioridade | ATENDIDO | `tasks/NAMING_CANDIDATES.md` e `tasks/DATA_NAMING_3C.md`, `_3F.md`, `_20.md` |
| Lotes P0/P1 limitados, revisáveis e baseados em evidência; P3 sem rename definitivo | ATENDIDO | Lotes por subsistema; nenhum nome `BAIXA` aplicado |
| Convenções de nomes registradas | ATENDIDO | `tasks/NAMING_CANDIDATES.md` §1 e relatórios de lote |
| Fonte alterada após autorização; `src/` não editado à mão | ATENDIDO | `annotations/sf2ne.ann`; `src/` regenerado por `make gen` (exceto `$05`, manual e intocado) |
| Nenhum byte, endereço, fluxo ou conteúdo alterado | ATENDIDO | SHA-1 idêntico; operandos `.byte`/`.word` conferidos |
| Equivalência binária alegada somente após verificação autorizada | ATENDIDO | Build/SHA-1 executados com autorização; resultado reportado |
| Mesma métrica da Fase 1, categorias separadas | ATENDIDO | §10.2 |
| Nenhum personagem, funcionalidade, IA de Ken, conversor ou refatoração de kernel iniciado | ATENDIDO | Escopo restrito a labels/comentários |
| Nenhum build/teste/emulador sem autorização própria | ATENDIDO | `make gen`, `make` e `make fixed` autorizados na sessão |
| Alterações locais preexistentes preservadas | ATENDIDO | Sem `clean`, `reset` ou `restore` |

### 10.5 Pendências e próximo passo

- Restam **1.135 labels automáticos de dados**; a spec permite mantê-los quando a semântica não está determinada (P3/opacos). Distribuição: `$00` 206, `$01` 304, `$04` 3, `$05` 352, `$08/$0C/$10/$1C/$24` 5, `$29` 103, `$2D` 70, `$36` 30, `$37` 27, `$3B` 35.
- Próximos candidatos por evidência/esforço: `$36` (30) e `$3B` (35); depois `$37` (27) e música (`$29`/`$2D`, 173). Os bancos grandes de Ryu/Ken (`$00`/`$01`/`$05`, 865) exigem análise por estado/quadro e podem permanecer P3.
- Nenhum personagem, funcionalidade ou conteúdo jogável foi iniciado.
