# Especificação técnica — Fase 0: congelamento de escopo e preparação

**Status:** pronta para o Software Engineer executar; documentação apenas.  
**Projeto:** Street Fighter II NE (`daniel-castilho/sf2nes`).  
**Origem:** Fase 0 de `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.  
**Data:** 2026-11-10.  
**Tipo de mudança autorizada por esta especificação:** somente documentação e registro de backlog.  
**Build, compilação, execução da ROM, testes e alterações em código:** fora do escopo e não autorizados.

## 1. Objetivo

Registrar de forma inequívoca que o projeto inicia uma fase de estabilização e manutenibilidade, durante a qual novos personagens e funcionalidades do jogo ficam pausados. Separar o trabalho em trilhas distintas — manutenção, REA/documentação e conteúdo — e criar um registro pequeno de decisões pendentes, sem resolver antecipadamente decisões que pertencem às fases seguintes.

A pausa significa **adiamento, não cancelamento** de itens existentes no roteiro. O trabalho de conteúdo continua documentado, mas não é a próxima execução ativa.

## 2. Fontes a consultar

Antes de editar, o Engineer deve ler o estado atual destes arquivos e verificar se as referências continuam corretas:

- `README.md` — resumo do projeto e indicação do próximo trabalho;
- `docs/ROTEIRO.md` — etapas, status e decisões de escopo;
- `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` — plano global que origina esta fase;
- `tasks/KEN_IMPLEMENTATION_SPEC.md` — escopo vigente de Ken, somente para manter coerência; não editar nesta Fase 0;
- `tasks/GUILE_BEHAVIORAL_ENGINEERING_SPEC.md` e `tasks/ARCADE_AI_CLEAN_ROOM_REA.md` — referências a trabalhos independentes, somente quando necessário para evitar mistura de escopos; não editar nesta Fase 0.

Se a árvore local ou os arquivos diferirem desta especificação, registrar a divergência no relatório de entrega e pedir decisão; não sobrescrever silenciosamente conteúdo local.

## 3. Arquivos permitidos

O Engineer pode alterar apenas os seguintes arquivos:

1. `docs/ROTEIRO.md` — declarar a fase atual, registrar a pausa e rotular as etapas de conteúdo futuras como pausadas, preservando o histórico e as instruções existentes.
2. `README.md` — atualizar apenas a indicação de prioridade/próximo trabalho e apontar para o roteiro e este plano, sem reescrever as alegações históricas sobre resultados já obtidos.
3. `tasks/STABILIZATION_BACKLOG.md` — criar o registro de trilhas de trabalho e decisões pendentes descrito na §5.

Nenhum outro arquivo deve ser modificado nesta fase. Em particular, não editar `src/`, `annotations/`, `tools/`, `assets/`, `rom/`, `prontos/`, configuração de build, especificações de implementação de personagem, nem o relatório de REA arcade.

## 4. Mudanças requeridas

### 4.1 `docs/ROTEIRO.md`

Adicionar no início do roteiro uma seção breve **“Fase atual — estabilização e manutenibilidade”**, contendo:

- objetivo: facilitar entendimento, autoria e manutenção do que já existe;
- declaração de pausa: novos personagens e funcionalidades de jogo não são trabalho ativo nesta fase;
- links relativos para `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` e `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md`;
- indicação de que as próximas tarefas ativas serão escolhidas após a auditoria documental da Fase 1, não presumidas a partir da ordem antiga do roteiro.

Nas etapas futuras relacionadas a Ken, ferramentas de conteúdo, cenários/músicas/finais e outras funcionalidades:

- adicionar rótulo visível `PAUSADO — fora da fase atual` (ou formulação equivalente);
- preservar listas, notas técnicas e caixas de status já existentes;
- não marcar itens incompletos como concluídos, cancelados ou aprovados;
- não reordenar nem reescrever o histórico concluído da Etapa 0/1/2.

Se houver uma recomendação textual antiga do tipo “próxima etapa é implementar Ken”, ajustá-la para refletir que Ken está pausado e que sua especificação vigente não foi cancelada.

### 4.2 `README.md`

Atualizar somente o bloco que orienta o leitor sobre “o que ainda falta” ou o próximo passo, para:

- identificar a estabilização/manutenibilidade como foco atual;
- dizer que a implementação de novos personagens e funcionalidades está pausada, não cancelada;
- apontar para `docs/ROTEIRO.md` e para o plano/spec de estabilização;
- manter as descrições de capacidade, experimentos históricos e estado de builds/testes como afirmações históricas, sem promovê-las a resultados recém-verificados.

Não executar comandos citados no README para confirmar as afirmações; esta tarefa é somente documental.

### 4.3 `tasks/STABILIZATION_BACKLOG.md`

Criar o arquivo com três trilhas separadas, um estado inicial e o registro de decisões pendentes.

#### Trilha A — estabilização/manutenibilidade (ativa como planejamento)

Registrar como candidatos, sem presumir aprovação de implementação:

- Fase 1 — auditoria reproduzível de métricas, fontes de verdade, documentação, bancos e validações existentes;
- Fase 2 — especificação do formato textual de autoria de estados/quadros e decisão sobre fonte canônica;
- Fase 3 — naming dirigido por criticidade e evidência;
- Fase 4 — reconciliação documental e registro de decisões técnicas;
- Fase 5 — proposta de validação futura, sem executar testes.

Referenciar o plano global em vez de duplicar os requisitos completos.

#### Trilha B — REA e documentação técnica (pesquisa/documentação, separada)

Registrar separadamente:

- REA estática da IA arcade e respectiva especificação de sala limpa;
- conclusão da análise das lacunas de Ken na revisão arcade identificada, quando esse trabalho for retomado;
- documentação de formatos/hipóteses do motor NES, quando priorizada pela auditoria.

Esta trilha não autoriza portar bytecode, dados ou código arcade para o projeto, nem executar a ROM arcade. Não apresentar a REA como implementação NES.

#### Trilha C — conteúdo e funcionalidades (pausada)

Registrar como pausados, não cancelados:

- implementação de Ken como personagem jogável, conforme sua especificação vigente;
- qualquer IA própria de Ken no NES;
- implementação de outros personagens;
- novas telas, controles, modos, golpes, cenários, músicas, finais ou outras funções de jogo;
- produção/conversão de assets e ferramentas ligadas diretamente à criação de conteúdo, até decisão posterior.

A trilha não deve reescrever nem alterar a especificação de Ken; deve referenciá-la.

#### Decisões pendentes

Incluir pelo menos os itens abaixo, cada um com **ID**, **pergunta**, **estado**, **responsável pela decisão** (Mantenedor), **evidência/entrada necessária** e **bloqueia**:

| ID | Pergunta a resolver | Evidência/entrada necessária | Bloqueia |
|---|---|---|---|
| `D-01` | Qual método reproduzível será usado para contar labels totais, labels de código/dados e labels semanticamente nomeados? | Auditoria de fontes e critério de classificação da Fase 1. | Métricas de naming e comparação futura. |
| `D-02` | Qual será a fonte canônica para autoria de estados/quadros: annotations, macros ca65 ou formato declarativo externo? | Inventário dos formatos/exceções e comparação de manutenção da Fase 2. | Implementar conversor ou migrar dados. |
| `D-03` | Quais rotinas/tabelas serão a primeira leva de naming e qual evidência mínima torna um nome aceitável? | Mapa de criticidade e evidência reunido nas Fases 1/3. | Campanha de renomeação. |
| `D-04` | Quais critérios e decisão explícita reabrem a implementação de personagens/funcionalidades? | Prioridades do Mantenedor e conclusão da estabilização. | Retomar a trilha C. |
| `D-05` | Que validações futuras serão autorizadas, por quem, e em qual escopo? | Proposta de validação da Fase 5 e autorização explícita. | Criar/rodar testes, builds ou validação em emulador no trabalho futuro. |
| `D-06` | Ferramentas externas de assets serão avaliadas e em que momento? | Necessidade de conteúdo, disponibilidade e revisão de licença. | Integração de conversores externos. |
| `D-07` | Há necessidade mensurável de mudar a organização do kernel/bancos? | Auditoria de espaço, requisitos de vetores e restrições de ciclos. | Qualquer refatoração do kernel. |

Todos os itens começam como `PENDENTE`. O backlog não deve resolvê-los por conta própria nem tratar a ausência de decisão como aprovação. As entradas devem permanecer concisas; planos técnicos detalhados pertencem ao plano global ou a uma especificação própria.

## 5. Regras de estado e linguagem

- Usar **ATIVO** apenas para trabalho efetivamente autorizado e em execução; trabalho apenas listado fica como `PLANEJADO` ou `CANDIDATO`.
- Usar **PAUSADO** para conteúdo que permanece desejado, mas não pode iniciar nesta fase.
- Usar **PENDENTE** para decisões ainda sem resposta.
- Não usar “pronto”, “validado”, “testado” ou “aprovado” para indicar apenas que a documentação foi escrita.
- A aprovação desta Fase 0 não autoriza qualquer Gate A–E do plano global além da edição documental definida aqui.

## 6. Fora do escopo

- Resolver as decisões D-01 a D-07.
- Executar a auditoria da Fase 1.
- Projetar ou implementar o formato textual, conversores ou naming batch.
- Fazer mudanças em código, annotations, ferramentas, assets, ROMs ou configurações.
- Compilar, montar, executar ou testar ROM; executar Mesen/MAME ou scripts de regressão/realocação.
- Editar a especificação de Ken, a especificação de Guile ou a REA arcade.
- Retomar IA arcade ou transferir achados da arcade para o jogo NES.

## 7. Preservação do estado de trabalho

Antes de editar, verificar e registrar o estado do diretório de trabalho. A inspeção não deve descartar alterações. Preservar todos os arquivos modificados ou não rastreados já existentes; não executar `clean`, `reset`, `restore`, checkout destrutivo ou equivalente. Se um dos três arquivos permitidos já tiver alterações locais, editar apenas as seções necessárias e relatar o conflito/diff para revisão.

## 8. Critérios de aceite

- [ ] O roteiro declara a fase atual e a pausa de conteúdo de forma clara, sem cancelar o backlog antigo.
- [ ] Etapas futuras de personagens e funcionalidades estão rotuladas como pausadas, sem mudar o status de etapas concluídas.
- [ ] O README aponta para a prioridade atual e para os documentos de planejamento sem afirmar validações recém-executadas.
- [ ] `tasks/STABILIZATION_BACKLOG.md` contém as três trilhas separadas e as decisões D-01 a D-07 como pendentes.
- [ ] Cada tarefa futura está corretamente classificada como ativa, planejada/candidata, pausada ou pendente; nenhuma decisão foi implicitamente tomada.
- [ ] Links internos são relativos e apontam para arquivos existentes.
- [ ] Somente os arquivos permitidos na §3 foram alterados ou criados.
- [ ] Nenhum código, dado, asset, configuração, ROM ou ferramenta foi alterado.
- [ ] Nenhum build, teste, emulador ou validação de ROM foi executado.
- [ ] A entrega informa arquivos alterados, resumo do texto incluído, divergências encontradas e confirmação dos limites respeitados.

## 9. Relatório de entrega exigido

Ao concluir, o Engineer deve retornar:

1. lista exata de arquivos criados/alterados;
2. resumo das declarações de pausa e das três trilhas registradas;
3. decisões deixadas pendentes (D-01–D-07);
4. divergências encontradas entre README, roteiro e especificações; não resolvidas sem autorização;
5. confirmação explícita de que não alterou código/ROM/tools, não compilou e não executou testes ou emulador.
