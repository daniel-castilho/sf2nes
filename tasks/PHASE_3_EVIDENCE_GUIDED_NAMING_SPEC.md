# Especificação técnica — Fase 3: naming guiado por risco e evidência

**Status:** pronta para detalhamento/execução futura após os gates de entrada; não autoriza mudanças nesta conversa.  
**Projeto:** Street Fighter II NE (`daniel-castilho/sf2nes`).  
**Origem:** Fase 3 de `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.  
**Pré-requisitos:** Fase 0 aceita; Fase 1 concluída com métrica reproduzível em `docs/ESTADO_DO_PROJETO.md`; Fase 2 concluída com fonte canônica e fluxo de geração decididos/aprovados.  
**Tipo de trabalho futuro:** triagem e renomeação documentada de símbolos no fluxo canônico.  
**Implementação de gameplay, build, ROM, testes e emulador:** fora do escopo e não autorizados por esta especificação.

## 1. Objetivo

Melhorar a navegabilidade e a compreensão do código/dados existentes por meio de nomes semânticos sustentados por evidência. A prioridade é reduzir o custo de manutenção nas rotinas e tabelas centrais; não atingir uma porcentagem arbitrária de labels nomeados.

A renomeação é documental/simbólica: não deve alterar instruções, bytes de dados, ponteiros, ordenação, endereço, fluxo de execução, timing ou comportamento do jogo. Cada nome novo precisa ter evidência suficiente para que outro mantenedor entenda por que ele foi escolhido.

## 2. Gates de entrada

A execução futura deve parar e ser reportada como bloqueada se qualquer condição abaixo não estiver satisfeita:

1. **Fase 0 aceita:** a pausa de personagens/funcionalidades e as trilhas de trabalho estão registradas.
2. **Fase 1 aceita:** `docs/ESTADO_DO_PROJETO.md` fornece a métrica-base, seu método, categorias, escopo e limitações. Não usar números informados informalmente como substituto.
3. **Métrica reconciliada:** ocorrências versus nomes únicos, labels globais versus locais e labels de código versus dados estão definidos sem discrepância não resolvida. Em particular, valores que não somam ao total declarado não podem ser usados para medir progresso até a metodologia esclarecer a diferença.
4. **Fase 2 aceita:** a fonte canônica e o fluxo gerado estão definidos. Naming deve ocorrer no arquivo autoral correto, e não por edição manual de `src/` gerado.
5. **Árvore de trabalho inspecionada:** alterações locais preexistentes estão registradas e serão preservadas.
6. **Autorização de execução específica:** este documento é uma especificação, não autorização para editar annotations/fontes, regenerar `src/`, compilar, fazer build ou rodar validações.

## 3. Fontes e arquivos do fluxo

Na preparação, consultar versões atuais de:

- `docs/ESTADO_DO_PROJETO.md` — linha de base/método de contagem;
- `docs/ARQUITETURA.md`, `docs/FORMATOS.md`, `docs/RAM.md` e `docs/ROTEIRO.md` — contratos semânticos e estrutura;
- `docs/FERRAMENTAS.md` — sintaxe e fluxo das annotations;
- `annotations/sf2ne.ann` — fonte de símbolos, comentários e classificações conforme o fluxo atual;
- `tools/disasm.py` — regras de geração e nomenclatura automática;
- `src/` — artefatos gerados, somente para leitura/consulta durante a triagem;
- `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` e o ADR/formato aprovado na Fase 2.

A lista acima não presume que annotations permaneçam a fonte canônica de todos os dados depois da Fase 2. Labels devem ser alterados na fonte canônica aprovada para cada classe de informação.

## 4. Escopo

### Incluído

- Labels globais automáticos derivados de banco/endereço, somente nos casos em que a função ou identidade estrutural esteja suficientemente determinada.
- Símbolos de RAM se sua identidade for demonstrável e a Fase 1 registrar a fonte de verdade correspondente.
- Nomes de rotinas, tabelas, dispatchers, estruturas e pontos de entrada relacionados a subsistemas centrais.
- Comentários de evidência/confiança estritamente necessários para explicar um nome ou impedir que hipótese vire fato.
- Atualização da contagem pós-lote, usando exatamente o método aprovado na Fase 1.

### Excluído

- Alterar qualquer byte de opcode, operando, tabela, ponteiro, estado, quadro, condição, opcode de IA, valor de RAM ou dado de asset.
- Alterar fluxo, semântica, endereços, bankswitching, timing, IRQ/NMI, chamadas, macros executáveis ou código de jogo.
- Criar funcionalidades, personagens, IA de Ken ou conteúdo jogável.
- Renomear conteúdo arcade, bytecode, ROMs ou ativos externos; a REA arcade permanece separada.
- Renomear dados gráficos opacos por suposição (por exemplo, dar nomes de golpe a metasprites sem mapeamento demonstrado).
- Mudar a sintaxe ou fonte canônica de autoria decidida na Fase 2.

## 5. Método de priorização

O Engineer deve elaborar uma lista de candidatos antes de editar. Usar níveis de prioridade, não uma meta percentual:

| Nível | Critério | Tratamento |
|---|---|---|
| `P0 — central e confirmado` | Rotina compartilhada, dispatcher, carregador, transição ou tabela central sem nome útil; uso/callers demonstráveis e confiança alta. | Primeiro lote sugerido. |
| `P1 — alto impacto e confirmado` | Rotina/dado frequentemente usado por luta, personagem, input, colisão, dano, desenho ou fluxo de telas; evidência clara. | Próximos lotes por subsistema. |
| `P2 — localizado` | Auxiliar com uso limitado, porém compreendido e relevante à manutenção. | Só após P0/P1 ou se bloqueia outra tarefa autorizada. |
| `P3 — opaco/hipótese` | Semântica não determinada, evidence contraditória, código não executado ou estrutura possivelmente morta. | Manter label atual; documentar pergunta/evidência faltante, sem renomear como fato. |

A priorização deve considerar, no mínimo:

- número e criticidade de callers/referências cruzadas conhecidos;
- alcance do efeito (compartilhado, personagem, tela ou rotina rara);
- papel em caminhos essenciais documentados;
- nível de confiança da interpretação;
- risco de um nome errado induzir futuras mudanças incorretas;
- dependência de uma investigação ainda não autorizada ou não executada.

Não usar o número de callers sozinho como prova de função; não inferir semântica a partir de endereço ou vizinhança apenas.

## 6. Requisitos de evidência para um nome

Cada candidato no inventário precisa registrar:

| Campo | Requisito |
|---|---|
| ID / endereço | Banco e endereço atuais; preservar o identificador anterior para rastreabilidade. |
| Símbolo atual | Label automático ou nome atual. |
| Símbolo proposto | Nome curto, consistente com convenções documentadas. |
| Categoria | Código, dados estruturados, ponteiro, RAM, tabela, asset ou não classificado. |
| Evidência | Callers/xrefs, leitura estática, anotação/trace já existente, estrutura de tabela ou referência documental. |
| Confiança | `ALTA`, `MÉDIA` ou `BAIXA`, com justificativa. |
| Impacto/prioridade | P0–P3 conforme §5. |
| Risco/observação | Ambiguidade, variante, dado não alcançável ou dependência. |
| Decisão | `ACEITO`, `ADIADO` ou `REJEITADO`, com responsável/revisor. |

Evidências permitidas:

- fluxo e referências cruzadas demonstráveis por leitura estática;
- documentos existentes que descrevam a função e correspondam ao símbolo/endereço;
- traces históricos já versionados, com origem e cenário identificados;
- relação estrutural consistente com outras tabelas/rotinas.

Não produzir trace novo nem executar emulador. Se o nome depender de observação dinâmica inexistente, deixar P3/pendente e propor evidência necessária para outra fase.

### Convenção de confiança

- **ALTA:** função confirmada por múltiplas evidências convergentes ou pelo fluxo/dados de uso inequívoco.
- **MÉDIA:** hipótese fortemente sustentada, mas com um aspecto semântico importante não resolvido. Usar comentário explícito de hipótese; avaliar manter label antigo.
- **BAIXA:** semântica principal não comprovada. Não substituir label por nome definitivo.

## 7. Convenções para os nomes

O ADR/convenções existentes do projeto prevalecem. Se ainda não houver padrão suficiente, a proposta deve cobrir antes do primeiro lote:

- idioma predominante dos nomes e termos técnicos;
- `PascalCase`/`camelCase`/sufixos e prefixos de subsystema;
- nomes de funções versus tabelas, dados, ponteiros e campos de RAM;
- distinção de jogador/slot, se pertinente;
- indicação de índice, família ou unidade quando confirmada;
- nomes de condições/opcodes já definidos em `docs/FORMATOS.md`;
- como representar labels parcialmente conhecidos sem inventar significado.

Princípios:

- nomear pelo papel demonstrado, não pelo valor ou pela aparência do dado;
- evitar nomes que afirmem uma característica não provada (por exemplo, `Random`, `Timer`, `Hitbox` ou nome de golpe sem confirmação);
- manter nomes existentes coerentes, sem renomeação cosmética em massa;
- não usar comentário como substituto para um nome quando a função já está confirmada;
- preservar o nome antigo no inventário do lote para mapear referências em revisão futura.

## 8. Execução em lotes

Cada lote deve corresponder a um subsistema limitado e revisável.

### Preparação do lote

1. Identificar candidato na linha de base e registrar no inventário.
2. Confirmar localização na fonte canônica aprovada.
3. Juntar evidência existente e atribuir confiança/prioridade.
4. Separar nomes confirmados de hipóteses e candidatos que exigem trace/execução.
5. Solicitar decisão do revisor quando houver ambiguidade P0/P1.

### Mudança futura autorizada

Quando houver autorização explícita para executar a fase:

- editar exclusivamente a fonte canônica de símbolos indicada pela Fase 2;
- nunca corrigir manualmente um arquivo `src/` gerado;
- alterar apenas label/comment/RAM-symbol de forma semântica, sem tocar em diretivas ou dados que alterem bytes;
- se o gerador reescrever `src/`, preservar e relatar alterações preexistentes e rever os diffs produzidos;
- não misturar naming com correção de bug, refatoração ou formatação não relacionada;
- parar e abrir decisão se o rename exigir mudar uma referência externa, contrato de ferramenta ou dado.

A geração de `src/` é uma ação de execução e requer autorização específica. Não rodar automaticamente por constar no fluxo habitual.

## 9. Entregáveis futuros

Criar, após autorização de execução:

1. `tasks/NAMING_CANDIDATES.md` — inventário priorizado com evidência, confiança, estado e destino de cada candidato;
2. batches de alterações na fonte canônica de symbols, limitados por subsistema;
3. `docs/ESTADO_DO_PROJETO.md` atualizado com a mesma métrica da linha de base, sem somar categorias diferentes;
4. relatório de lote contendo diff de labels, ambiguidades não resolvidas e impacto sobre referências de ferramentas.

A especificação não define que todos os labels genéricos devam ser renomeados. Labels automáticos podem permanecer adequados para dados opacos ou de baixo valor de manutenção.

## 10. Verificação futura e não autorização

A renomeação tem como invariante esperado não alterar o conteúdo binário, mas esse fato só pode ser declarado como **verificado** após uma verificação autorizada. Não alegar equivalência byte a byte apenas porque a mudança foi planejada como simbólica.

Uma fase posterior, sob gate explícito, deve decidir como verificar:

- ausência de alterações de dados/opcodes/endereços;
- integridade das referências entre symbols e ferramentas;
- regeneração consistente dos fontes;
- equivalência do artefato, se isso for permitido e relevante.

Esta especificação, o plano global ou a presença de scripts existentes não autorizam executar gerador, assembler/linker, build, Mesen, MAME, testes de regressão/realocação ou validação manual.

## 11. Arquivos e preservação

Para a execução futura, arquivos potencialmente alteráveis ficam limitados a:

- fonte canônica de símbolos aprovada pela Fase 2 (atualmente `annotations/sf2ne.ann`, se a decisão mantiver esse fluxo);
- `src/` apenas como saída gerada por ferramenta autorizada, nunca edição manual;
- `tasks/NAMING_CANDIDATES.md`;
- `docs/ESTADO_DO_PROJETO.md` para a métrica de resultado.

Não alterar código de `tools/`, assets, configuração de build, ROM ou documentos de escopo do personagem. Registrar e preservar qualquer modificação local preexistente; não usar operações destrutivas (`clean`, `reset`, `restore` ou equivalentes).

## 12. Critérios de aceite da Fase 3

- [ ] Gates de Fases 0, 1 e 2 concluídos e decisões de fonte canônica disponíveis.
- [ ] A métrica inicial foi reconciliada e seu método congelado para comparação antes/depois.
- [ ] Há inventário de candidatos com endereço, label atual, nome proposto, categoria, evidência, confiança e prioridade.
- [ ] Lotes P0/P1 são limitados, revisáveis e baseados em evidência; P3 permanece sem renomeação definitiva.
- [ ] Convenções de nomes estão registradas e não contradizem a fonte canônica aprovada.
- [ ] A fonte de symbols foi alterada apenas após autorização expressa e `src/` não foi editado à mão.
- [ ] Nenhum byte de dados/código, endereço, fluxo de jogo ou conteúdo de personagem foi intencionalmente alterado.
- [ ] Não há alegação de equivalência binária/teste aprovado sem verificação autorizada e evidência reportada.
- [ ] O resultado usa a mesma definição de métrica da Fase 1 e reporta categorias separadamente.
- [ ] Nenhum personagem, funcionalidade, IA de Ken, conversor ou refatoração de kernel foi iniciado.
- [ ] Nenhum build, teste, emulador ou alteração de ROM foi executado sem autorização própria.
- [ ] Alterações locais preexistentes foram preservadas.

## 13. Relatório futuro do Engineer

Ao concluir um lote autorizado, relatar:

1. arquivos alterados e fonte canônica usada;
2. símbolos renomeados por banco/endereço e função proposta;
3. evidência/confiança de cada nome ou referência ao inventário;
4. métricas anteriores e posteriores obtidas pelo mesmo método;
5. ambiguidades adiadas e evidência que faltou;
6. efeitos em símbolos consumidos por ferramentas/documentos;
7. comandos/validações executados somente se autorizados, incluindo resultados e artefatos;
8. declaração explícita de preservação das alterações locais e de que nenhum escopo de gameplay foi ampliado.
