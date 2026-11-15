# Backlog de estabilização — Fase 0

**Origem:** `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md` e `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` (Fase 0).  
**Tipo:** documento de planejamento e registro de decisões pendentes.  
**Nenhuma implementação, build, teste ou execução de emulador está autorizada por este arquivo.**

Este backlog separa o trabalho em três trilhas distintas. Nenhuma decisão D-01 a D-07 está resolvida aqui; todas começam como `PENDENTE`.

---

## Trilha A — estabilização/manutenibilidade (candidatos, sem aprovação de implementação)

- **Fase 1** — auditoria reproduzível de métricas, fontes de verdade, documentação, bancos e validações existentes → **AUDITORIA CONCLUÍDA — DOCUMENTO ENTREGUE** (`docs/ESTADO_DO_PROJETO.md`, commit `ada6c6f`). Sem indicação de testes aprovados.
- **Fase 2** — especificação do formato textual de autoria de estados/quadros e decisão sobre fonte canônica.
- **Fase 3** — naming dirigido por criticidade e evidência.
- **Fase 4** — reconciliação documental e registro de decisões técnicas.
- **Fase 5** — proposta de validação futura, sem executar testes.

Referenciar `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md` e `docs/ESTADO_DO_PROJETO.md` em vez de duplicar os requisitos completos.

---

## Trilha B — REA e documentação técnica (pesquisa/documentação, separada)

Registrar separadamente:

- REA estática da IA arcade e respectiva especificação de sala limpa.
- Conclusão da análise das lacunas de Ken na revisão arcade identificada, quando esse trabalho for retomado.
- Documentação de formatos/hipóteses do motor NES, quando priorizada pela auditoria.

Esta trilha não autoriza portar bytecode, dados ou código arcade para o projeto, nem executar a ROM arcade. Não apresentar a REA como implementação NES.

---

## Trilha C — conteúdo e funcionalidades (pausada)

Registrar como pausados, não cancelados:

- implementação de Ken como personagem jogável, conforme sua especificação vigente (`tasks/KEN_IMPLEMENTATION_SPEC.md`);
- qualquer IA própria de Ken no NES;
- implementação de outros personagens;
- novas telas, controles, modos, golpes, cenários, músicas, finais ou outras funções de jogo;
- produção/conversão de assets e ferramentas ligadas diretamente à criação de conteúdo, até decisão posterior.

A trilha não deve reescrever nem alterar a especificação de Ken; deve referenciá-la.

---

## Decisões pendentes

Todos os itens abaixo começam como `PENDENTE`. O backlog não os resolve por conta própria nem trata a ausência de decisão como aprovação.

| ID | Pergunta a resolver | Estado | Responsável | Evidência/entrada necessária | Bloqueia |
|----|---------------------|--------|-------------|------------------------------|----------|
| D-01 | Qual método reproduzível será usado para contar labels totais, labels de código/dados e labels semanticamente nomeados? | PENDENTE | Mantenedor | Auditoria de fontes e critério de classificação da Fase 1. | Métricas de naming e comparação futura. |
| D-02 | Qual será a fonte canônica para autoria de estados/quadros: annotations, macros ca65 ou formato declarativo externo? | PENDENTE | Mantenedor | Inventário dos formatos/exceções e comparação de manutenção da Fase 2. | Implementar conversor ou migrar dados. |
| D-03 | Quais rotinas/tabelas serão a primeira leva de naming e qual evidência mínima torna um nome aceitável? | PENDENTE | Mantenedor | Mapa de criticidade e evidência reunido nas Fases 1/3. | Campanha de renomeação. |
| D-04 | Quais critérios e decisão explícita reabrem a implementação de personagens/funcionalidades? | PENDENTE | Mantenedor | Prioridades do Mantenedor e conclusão da estabilização. | Retomar a trilha C. |
| D-05 | Que validações futuras serão autorizadas, por quem, e em qual escopo? | PENDENTE | Mantenedor | Proposta de validação da Fase 5 e autorização explícita. | Criar/rodar testes, builds ou validação em emulador no trabalho futuro. |
| D-06 | Ferramentas externas de assets serão avaliadas e em que momento? | PENDENTE | Mantenedor | Necessidade de conteúdo, disponibilidade e revisão de licença. | Integração de conversores externos. |
| D-07 | Há necessidade mensurável de mudar a organização do kernel/bancos? | PENDENTE | Mantenedor | Auditoria de espaço, requisitos de vetores e restrições de ciclos. | Qualquer refatoração do kernel. |

---

## Regras de estado e linguagem

- **ATIVO:** trabalho efetivamente autorizado e em execução.
- **PLANEJADO / CANDIDATO:** trabalho apenas listado, ainda não autorizado.
- **PAUSADO:** conteúdo que permanece desejado, mas não pode iniciar nesta fase.
- **PENDENTE:** decisão ainda sem resposta.
- Não usar "pronto", "validado", "testado" ou "aprovado" para indicar apenas que a documentação foi escrita.

---

## Critérios de aceite (Fase 0)

- [ ] O roteiro declara a fase atual e a pausa de conteúdo de forma clara, sem cancelar o backlog antigo.
- [ ] Etapas futuras de personagens e funcionalidades estão rotuladas como pausadas, sem mudar o status de etapas concluídas.
- [ ] O README aponta para a prioridade atual e para os documentos de planejamento sem afirmar validações recém-executadas.
- [ ] Este arquivo contém as três trilhas separadas e as decisões D-01 a D-07 como pendentes.
- [ ] Cada tarefa futura está corretamente classificada como ativa, planejada/candidata, pausada ou pendente; nenhuma decisão foi implicitamente tomada.
- [ ] Links internos são relativos e apontam para arquivos existentes.
- [ ] Somente os arquivos permitidos na §3 da especificação da Fase 0 foram alterados ou criados.
- [ ] Nenhum código, dado, asset, configuração, ROM ou ferramenta foi alterado.
- [ ] Nenhum build, teste, emulador ou validação de ROM foi executado.
