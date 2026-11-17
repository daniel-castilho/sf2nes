# Decisão de formato — autoria de estados e quadros (Fase 2)

**Status:** PROPOSTO (recomendação do Engineer; aguarda decisão explícita do Mantenedor)  
**Atualização 2026-11-16:** a decisão permanece `PROPOSTO`; o fechamento da Fase 3 não a utilizou como pré-requisito, pois o naming atuou apenas em símbolos (`annotations/sf2ne.ann`). Ver `tasks/PHASE_3_EXECUTION_REPORT.md` §10.4.  
**Origem:** `tasks/PHASE_2_STATE_DATA_FORMAT_SPEC.md` (Fase 2 do plano de estabilização)  
**Tipo:** documento de decisão/design — não autoriza implementação, build, teste ou migração  
**Pré-requisitos confirmados:** Fase 0 aceita, Fase 1 concluída com `docs/ESTADO_DO_PROJETO.md` disponível

---

## 1. Decisão recomendada

O Engineer recomenda **formato declarativo externo** (arquivo estruturado processado por ferramenta própria) como fonte canônica de autoria de estados e quadros de animação, em vez de macros/DSL em ca65.

**Estado:** `PROPOSTO` — a aprovação final pertence ao Mantenedor. Nenhuma implementação, conversor, migração ou alteração de build é autorizada por este documento.

---

## 2. Matriz de comparação das alternativas

| Critério | Macros/DSL em ca65 | Formato declarativo externo (TOML/YAML/JSON) |
|---|---|---|
| Legibilidade de diff | Baixa. Estados e quadros ficam em assembly com bytes diretos; mudar um parâmetro exige decodificar valores hexadecimais no diff. | Alta. Campos nomeados (duracao, ponteiro_metasprite, etc.) tornam o diff revisável sem decodificação manual. |
| Tipagem/validação | Fraca. O assembler só valida sintaxe de assembly; condições inválidas, ponteiros faltantes, duração fora de faixa ou laço malformado só aparecem no build/runtime (se aparecerem). | Forte. Uma ferramenta própria pode validar antes de gerar assembly: condições conhecidas, duração na faixa 1–100, ponteiros resolvidos, laço bem formado. |
| Cobertura | Total (é assembly nativo), mas sem distinção entre "valor conhecido" e "valor incerto". | Total se o schema cobrir todos os campos documentados em `docs/FORMATOS.md`; permite campos brutos e comentários de incerteza. |
| Símbolos | Nomes de labels do assembly; números mágicos para endereços e ponteiros. | Nomes simbólicos próprios (estado, quadro, metasprite, caixa, banco), sem número mágico. |
| Dados desconhecidos | Difícil. Valor bruto em `.byte` sem campo para comentário de procedência. | Fácil. Campo `raw` ou comentário por registro/campo; distinção entre zero, ausente, terminador e omitido. |
| Fonte canônica | Ambígua: mistura dados de autoria com código gerado pelo disassembly. | Clara: um arquivo/fonte próprio que o Engineer edita; o gerador lê esse fonte sem destruí-lo. |
| Integração com `make gen` | Direta (é assembly), mas `make gen` regenera `src/` e pode sobrescrever edições manuais. | Precisa de um estágio entre `disasm.py` e `ca65`; `make gen` não deve destruir nem ignorar dados de autoria novos. |
| Erros de diagnóstico | Linha e arquivo do assembly gerado; difícil rastrear até a intenção do autor. | Arquivo, registro, campo e referência inválida apontados pela ferramenta própria. |
| Determinismo | Determinista (assembly). | Determinista se a serialização for ordenada. |
| Dependências | Nenhuma (ca65 já existe). | Exige parser + gerador de assembly; custo de manutenção da nova ferramenta. |
| Migração | Gradual por banco, mas com risco de sobrescrita pelo gerador. | Gradual por personagem/banco; rollback simples (voltar ao assembly gerado). |
| Reversibilidade | Difícil (edição manual de `src/` não sobrevive a `make gen`). | Fácil (desligar a ferramenta e continuar com o assembly gerado existente). |

---

## 3. Fonte canônica proposta

- **Fonte canônica de autoria:** arquivo declarativo externo (formato a definir: TOML, YAML ou JSON — veja seção 4), separado de `annotations/sf2ne.ann` e de `src/`.
- **Responsabilidades da fonte canônica:** estados, quadros de animação, durações, ponteiros de metasprite/colisão/efeito, flags, movimento, laços, sentinelas, comentários de procedência e confiança.
- **Responsabilidades de `annotations/sf2ne.ann`:** labels, comentários, blocos `alt` (correções/alternates), `patch`, `keepbank`, metadados de disassembly — permanece inalterada como fonte de anotação do gerador.
- **Arquivos gerados (nunca editar manualmente):** `src/*.s` (produzido por `make gen`), `sf2ne.cfg`, `build/*.nes`.
- **Integração:** um novo estágio de leitura da fonte declarativa deve ser inserido entre o gerador e o assembler, de forma que `make gen` não destrua nem ignore os dados de autoria. Detalhes de implementação são trabalho futuro (Fase 3/Gate C).

---

## 4. Comparação TOML vs YAML vs JSON (evidência da auditoria da Fase 1)

A auditoria da Fase 1 (`docs/ESTADO_DO_PROJETO.md`) registrou 549 labels semânticos vs 1.592 automáticos (379 código + 1.213 dados), e 322 símbolos `.global`. Isso indica que nomes simbólicos são valiosos e que o formato deve privilegiar legibilidade e validação prévia.

| Critério | TOML | YAML | JSON |
|---|---|---|---|
| Legibilidade de diff | Boa (seções explícitas, chave=valor) | Boa, mas sensível a indentação | Regular (colchetes/aspas verbosos) |
| Tipagem nativa | Boa (strings, inteiros, booleanos, arrays, tabelas) | Boa, mas implícita em alguns casos | Boa, mas sem comentários |
| Comentários | Sim | Sim | Não |
| Ferramentas maduras em Python | Sim (`tomllib` stdlib 3.11+, `tomli` antes) | Sim (`PyYAML`) | Sim (`json` stdlib) |
| Risco de ambiguidades | Baixo | Médio (indentação, tipos implícitos) | Baixo |
| Adequação para schema rígido | Alta | Média | Alta |

**Recomendação de sintaxe (ainda PROPOSTA):** TOML, por ter comentários, tipagem explícita e parser padrão em Python moderno, com baixo risco de ambiguidades de indentação. A decisão final entre TOML/YAML/JSON cabe ao Mantenedor.

---

## 5. Regras para preservar campos incertos, referências e registros órfãos

### 5.1 Campos incertos / desconhecidos
- Valor bruto preservado literalmente (não normalizado, não interpretado).
- Campo de comentário por registro e por campo para indicar evidência, hipótese ou referência documental.
- Não forçar nomes semânticos para opcodes, condições, efeitos ou flags ainda não confirmados.
- Permitir valor numérico bruto como escape explícito e documentado.

### 5.2 Distinção de sentinelas
- **zero:** valor numérico `0` com significado próprio (ex.: duração zero se permitido pelo schema).
- **ausente/null:** campo omitido ou explicitamente nulo; não tratado como zero.
- **fim/terminador:** sentinela explícita (ex.: ponteiro nulo, byte `$FF`), distinta de "ausente".
- **campo omitido:** campo não presente no registro; schema deve definir se é válido e qual o padrão.

### 5.3 Registros órfãos / não alcançáveis
- Registros não alcançáveis pela cadeia de estados, mas presentes na região auditada, devem ser representados sem perda.
- A conversão não pode se basear apenas na cadeia de estados alcançável a partir do estado inicial.

### 5.4 Referências simbólicas
- Rótulos e referências entre estados e quadros usam nomes simbólicos; valores numéricos brutos só como escape documentado.
- Associação de cada estado ao banco de estados e dos quadros/metasprites às fontes de frames deve ser preservada.

---

## 6. Riscos e limitações da proposta

| Risco | Descrição | Mitigação proposta |
|---|---|---|
| Nova ferramenta de parser/gerador | Custo de manutenção; dependência adicional. | Manter a ferramenta mínima e documentada; rollback para assembly gerado existente. |
| Integração com `make gen` | Risco de sobrescrever ou ignorar dados de autoria. | Desenhar estágio de leitura entre `disasm.py` e `ca65`; salvaguardas no plano de migração. |
| Dados órfãos não mapeados | Pode haver registros no binário que o schema não representa. | Listar como dados não classificados na Fase 1; tratar como exceção documentada. |
| Símbolos duplicados entre bancos | `InputButtons`, `ResetStub`, `RoundStart` aparecem em múltiplos bancos. | Escopo de símbolo por banco; não achatar namespaces. |
| Relocação | Endereços absolutos não podem ficar fixos na fonte. | Usar rótulos e referências simbólicas; deixar alinhamento/ordem para o assembler/linker. |

---

## 7. Estado de aprovação

| Item | Estado |
|------|--------|
| Formato declarativo externo como direção preferida | PROPOSTO |
| TOML como sintaxe preferida | PROPOSTO |
| Separação fonte canônica vs. gerado | PROPOSTO |
| Aprovação final (Mantenedor) | PENDENTE |

A decisão final cabe ao Mantenedor. Até aprovação explícita, nada de conversor, migração, alteração de `make gen`, build ou teste é autorizado.

---

## 8. Arquivos relacionados

- `tasks/PHASE_2_STATE_DATA_FORMAT_SPEC.md` — especificação desta fase (entrada)
- `docs/ESTADO_DO_PROJETO.md` — linha de base da Fase 1 (métricas, fontes de verdade)
- `docs/FORMATOS.md` — contrato inicial de campos, tamanhos, tabelas
- `docs/ARQUITETURA.md` — banco de estados, banco de frames, carregador, mapeamento
- `docs/RAM.md` — símbolos/variáveis que conectam dados ao motor
- `annotations/sf2ne.ann` — diretivas de anotação, símbolos, correções
- `tools/disasm.py` — fluxo atual de geração
- `src/*.s`, `src/*.inc`, `Makefile`, `sf2ne.cfg` — forma assembly e integração atual (leitura apenas)

---

## 9. Próximos passos (após aprovação)

1. Gate C: autorizar implementação da ferramenta (parser + gerador de assembly).
2. Implementar conversor e validar contra dados atuais do Ryu (sem Ken, sem novo conteúdo).
3. Migração gradual por banco/personagem, com rollback documentado.
4. Verificação futura: build, comparação de ROM e regressão de funcionalidades existentes.
