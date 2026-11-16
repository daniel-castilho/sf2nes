# Relatório de execução — Fase 3 (naming guiado por evidência)

**Data:** 2026-11-15  
**Base commitada:** `688b552` (Gate D: lotes P0/P1)  
**Estado:** execução concluída e verificada; commit pendente de aprovação explícita.  
**Escopo:** renomeação de símbolos e comentários; nenhum byte de código/dado foi alterado.

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
- D-01…D-07 continuam `PENDENTE` em `tasks/STABILIZATION_BACKLOG.md`.
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
- Nada foi commitado ou pushado nesta sessão.

## 9. Proposta de commit

Recomendo **um commit único** para o conjunto já verificado, porque o diff de `annotations/sf2ne.ann` contém os lotes P2, PAD e FamiTone2 intercalados no mesmo arquivo e o inventário/documentação já descrevem o estado final. Separar em dois commits exigiria staging manual de hunks e deixaria o commit intermediário com documentação inconsistente.

Mensagem sugerida:

```text
Fase 3: naming guiado por evidência (P2, PAD e FamiTone2)

- 251 rótulos P2, 7 condições PAD e 109 mapeamentos FamiTone2
- inventário completo com 388 linhas e IDs únicos
- métricas reconciliadas: 0 auto código, 1.213 auto dados, 928 semânticos
- ROM SHA-1 idêntico: 3ad177a0a7867a821e6c1709b4e6dbdda3555aa1
```
