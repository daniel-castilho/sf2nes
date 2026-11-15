# Plano de migração — formato de autoria de estados e quadros (Fase 2)

**Status:** PROPOSTO (parte da decisão de formato; aguarda aprovação do Mantenedor)  
**Origem:** `tasks/PHASE_2_STATE_DATA_FORMAT_SPEC.md` (Fase 2)  
**Tipo:** documento de planejamento futuro — não autoriza implementação, build, teste ou migração  
**Pré-requisitos confirmados:** Fase 0 e Fase 1 concluídas

---

## 1. Objetivo

Desenhar os passos futuros de implementação e adoção gradual do formato declarativo de estados e quadros, sem alterar o fluxo atual nem colocar dados existentes em risco. Este é um plano de trabalho futuro; nenhuma ação listada abaixo está autorizada para execução agora.

---

## 2. Pressupostos

- A decisão de formato (formato declarativo externo, sintaxe a definir) foi aprovada pelo Mantenedor (Gate C).
- `annotations/sf2ne.ann` permanece a fonte de anotações, símbolos e correções do disassembly.
- `src/` continua gerado por `make gen`; não é editado manualmente.
- O build consome artefatos previstos pelo novo fluxo, sem edição manual de arquivo gerado.
- Dados atuais do Ryu são o conjunto de referência para verificação de cobertura; Ken e outros personagens não são adicionados nesta fase.

---

## 3. Arquivos que uma futura implementação provavelmente precisará alterar

| Arquivo / diretório | Provável alteração | Justificativa |
|---|---|---|
| `tools/disasm.py` | novo estágio de leitura da fonte declarativa antes da emissão de `src/` | integrar o formato ao gerador sem destruir dados de autoria |
| `tools/` (novo script) | parser do formato declarativo + gerador de assembly de estados/quadros | converter fonte autoral em assembly consumível pelo build |
| `annotations/sf2ne.ann` | não alterado (ou ajuste mínimo de `keepbank`/`patch` se necessário) | permanece fonte de labels, comentários, blocos `alt` e `patch` |
| `src/*.s` | não editado manualmente; regenerado pelo fluxo atual + novo estágio | fonte gerada, nunca à mão |
| `Makefile` | possível novo alvo ou variável para a ferramenta de conversão | integrar a conversão no `make gen`/`make` |
| `sf2ne.cfg` | inalterado (layout de bancos já existe) | não há mudança de layout nesta fase |
| `docs/FORMATOS.md` | atualizar com referência ao novo formato de autoria | documentar o contrato atualizado |
| `docs/ESTADO_DO_PROJETO.md` | atualizar seções de fontes de verdade e métricas, se necessário | refletir a nova fonte canônica |

---

## 4. Passos futuros de implementação (plano gradual)

### Passo A — Especificar e aprovar (Fase 2, concluída com estes documentos)
- Definir sintaxe (TOML/YAML/JSON), schema e regras de validação.
- Mantenedor aprova a fonte canônica (Gate C).

### Passo B — Implementar a ferramenta de conversão (não iniciado)
- Criar parser do formato declarativo.
- Implementar geração de assembly equivalente aos registros atuais (cabeçalho 7 bytes, quadro 14/16 bytes).
- Implementar validação: condições conhecidas, duração 1–100, ponteiros resolvidos, laço bem formado, distinção zero/null/ausente/fim.
- Implementar diagnóstico com arquivo, registro, campo e referência inválida.

### Passo C — Integrar ao fluxo de geração (não iniciado)
- Inserir estágio de leitura da fonte declarativa entre `disasm.py` e `ca65` no `make gen`.
- Garantir que `make gen` não destrua nem ignore dados de autoria novos.
- Manter `annotations/sf2ne.ann` como fonte de anotações independentes.

### Passo D — Validar contra dados atuais do Ryu (não iniciado)
- Serializar os estados/quadros atuais do Ryu no novo formato.
- Gerar assembly a partir dele e comparar com o assembly gerado atualmente (equivalência estrutural, sem diferença semântica).
- Verificar registros órfãos, valores desconhecidos e sentinelas.

### Passo E — Adoção gradual (não iniciado)
- Adotar o formato para um subconjunto representativo (ex.: um estado do Ryu) antes de expandir.
- Manter o restante dos dados no formato assembly gerado existente.
- Rollback a qualquer momento: desligar a ferramenta e continuar com o assembly gerado.

---

## 5. Salvaguardas para `make gen`

- `make gen` não deve sobrescrever a fonte declarativa de autoria.
- `make gen` não deve ignorar silenciosamente dados de autoria novos.
- Se houver conflito entre a fonte declarativa e anotações existentes, a ferramenta futura deve reportar, não escolher silenciosamente.
- O assembly gerado a partir da fonte declarativa deve ser idêntico em bytes ao assembly atual (equivalência estrutural) antes de qualquer adoção ampla.

---

## 6. Rollback

- Desativar a ferramenta de conversão no `make gen` (voltar ao fluxo `disasm.py` → `ca65` direto).
- Continuar usando o `src/*.s` gerado pela última execução bem-sucedida antes da adoção.
- A fonte declarativa permanece como arquivo-fonte, mas não é consumida até nova ativação.
- Nenhum dado é perdido: o assembly gerado anterior continua disponível.

---

## 7. Critérios de verificação futura (não executados agora)

| Critério | Como verificar (futuro, com autorização) |
|---|---|
| Equivalência estrutural | Gerar assembly do novo formato e comparar byte a byte com o assembly atual do Ryu |
| Cobertura de campos | Todos os campos de `docs/FORMATOS.md` têm representação no schema |
| Registros órfãos | Registros não alcançáveis estão presentes no novo formato |
| Valores desconhecidos | Campos com significado incerto usam inteiro bruto + comentário |
| Sentinelas | Fim de estado, fim de lista e laço estão representados corretamente |
| Determinismo | Mesma entrada produz assembly ordenado e idêntico em execuções repetidas |
| Diagnóstico | Erros apontam arquivo, registro, campo e referência inválida |

---

## 8. Riscos e mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| Nova ferramenta adiciona complexidade de manutenção | Média | Médio | Manter a ferramenta mínima; documentar parser e gerador |
| `make gen` sobrescreve dados de autoria | Baixa | Alto | Salvaguarda explícita no estágio de integração (Passo C) |
| Dados órfãos não mapeados pelo schema | Média | Baixo | Tratar como exceção documentada; não normalizar |
| Diferença semântica na conversão | Baixa | Alto | Verificação de equivalência estrutural (Passo D) antes da adoção |
| Dependência de biblioteca externa | Baixa | Baixa | Usar stdlib Python (`tomllib`, `json`) sempre que possível |

---

## 9. Decisões que permanecem pendentes

- Sintaxe exata (TOML vs YAML vs JSON) — decisão do Mantenedor.
- Ponto exato de integração no `make gen` e no `tools/disasm.py`.
- Critério de aceite para "equivalência estrutural" na comparação de assembly.
- Quais estados/quadros entram na primeira leva de adoção gradual (Passo E).

---

## 10. Arquivos relacionados

- `tasks/STATE_DATA_FORMAT_DECISION.md` — decisão e matriz de opções
- `tasks/STATE_DATA_FORMAT_SCHEMA.md` — schema/gramática conceitual
- `docs/ESTADO_DO_PROJETO.md` — linha de base da Fase 1 (métricas, fontes de verdade)
- `docs/FORMATOS.md` — contrato inicial de campos, tamanhos, tabelas
- `docs/ARQUITETURA.md` — banco de estados, banco de frames, carregador, mapeamento
- `annotations/sf2ne.ann`, `tools/disasm.py`, `src/*.s`, `Makefile`, `sf2ne.cfg` — fluxo atual (leitura apenas)

---

## 11. Declaração de limites

Este documento **não autoriza**:
- Implementar parser, conversor, gerador, macros ou novos scripts permanentes.
- Alterar `tools/disasm.py`, `Makefile`, `sf2ne.cfg`, annotations, `src/`, dados ou assets.
- Converter Ryu ou Ken para o formato novo.
- Acrescentar, editar ou normalizar registros reais do jogo.
- Criar ficha/estados/frames de Ken ou de qualquer outro personagem.
- Rodar gerador, assembler, linker, `make`, build, teste, Mesen, MAME ou validação manual.
- Reestruturar o kernel, mudar bancos ou mexer em ROMs.

A execução destes itens requer Gate C (autorização explícita do Mantenedor) e uma fase de implementação posterior à Fase 2.
