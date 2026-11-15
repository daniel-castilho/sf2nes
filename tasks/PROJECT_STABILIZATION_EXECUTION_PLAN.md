# Plano de execução — estabilização e manutenibilidade do projeto

**Status:** plano proposto; não autoriza implementação, build nem execução de testes.  
**Decisão de produto:** pausar novos personagens e funcionalidades para reduzir o custo e o risco de manutenção do que já existe.  
**Projeto:** Street Fighter II NE (`daniel-castilho/sf2nes`).  
**Data:** 2026-11-10.  
**Público:** mantenedor do projeto e Software Engineer responsável por eventual execução.

## 1. Objetivo

Organizar uma fase de melhoria interna que torne o projeto mais fácil de entender, editar e validar, sem ampliar o conteúdo do jogo. O plano aproveita as sugestões externas que têm valor, corrige recomendações incompatíveis com o fluxo existente e adia refatorações ou funcionalidades sem necessidade demonstrada.

O foco é:

1. estabelecer um retrato confiável do estado atual e reconciliar documentação divergente;
2. melhorar a forma de autoria dos dados de estados e quadros;
3. reduzir o custo de navegação pelo código com nomenclatura baseada em evidência;
4. deixar hipóteses, fontes de verdade e validações planejadas explícitas;
5. preparar uma proposta de validação futura sem executá-la nesta etapa.

## 2. Princípios e limites não negociáveis

- **Sem novos personagens ou funcionalidades** durante esta fase. Não implementar novos estados de Ken nem iniciar outro lutador.
- A decisão de escopo de Ken continua: humano P2, `ID 1`; a CPU de um jogador continua Ryu; IA própria de Ken fora do escopo. Nenhum outro personagem deve ser declarado implementado.
- A REA da IA arcade é uma pesquisa separada. Nenhum código, bytecode, dado ou ativo da ROM arcade pode ser copiado para o projeto.
- `src/` é gerado no fluxo atual. Não congelar ou editar esses arquivos informalmente; qualquer troca de fonte de verdade exige decisão documentada e migração explícita.
- Não usar `clean`, `reset`, `restore` ou operações que descartem alterações locais sem autorização.
- Este documento **não autoriza** modificar fontes, annotations, ferramentas, assets, ROMs, compilar, executar emulador, rodar testes ou validar gameplay. Essas ações requerem uma autorização posterior, com escopo próprio.
- Testes e verificações citados adiante são tarefas futuras do Engineer, não autorização para executá-los agora.
- Nenhum percentual de labels nomeados é um critério de sucesso isolado. Prioridade é reduzir a ambiguidade nas rotinas e dados que mais dificultam manutenção.

## 3. Leitura crítica das sugestões externas

| Sugestão | Decisão | Motivo / tratamento |
|---|---|---|
| Melhorar naming | **Adotar com foco** | Começar por rotinas centrais, chamadas frequentes, dispatchers e RAM compartilhada. Nomear apenas quando houver evidência; manter hipótese marcada. |
| Criar formato textual para estados/quadros | **Prioridade alta, especificar antes de implementar** | Já consta no `docs/ROTEIRO.md` como ferramenta futura. Usar dados atuais do Ryu como caso de referência, sem criar conteúdo novo. Preservar uma fonte de verdade. |
| Congelar `src/` e editar assembly gerado | **Não adotar informalmente** | Contradiz o fluxo atual `annotations` → gerador → `src/` e pode causar sobrescrita ou divergência. Qualquer congelamento futuro precisa de ADR, plano de migração e indicação explícita da nova fonte canônica. |
| Criar testes específicos para Ken | **Adiar** | A ideia pode ser útil quando Ken for retomado, mas a IA de Ken e Ken-vs-Ken conflitam com o escopo atual. Preparar apenas uma proposta de cobertura futura; não criar nem executar testes agora. |
| Criar conversores PNG→CHR e WAV→DPCM | **Adiar** | São ferramentas de produção de conteúdo; não reduzem o principal atrito imediato sem demanda de arte/áudio. Antes de retomá-las, verificar ferramentas, disponibilidade, licenças e formatos. |
| Extrair o kernel para um banco dedicado | **Adiar / não priorizar** | Há bancos PRG vazios, e o roteiro já descreve como acomodar código adicional. A repetição do kernel atende vetores/interrupções e tem restrições de tempo; refatorar sem necessidade medida aumenta risco. |
| UI de dificuldade/versus | **Fora desta fase** | É funcionalidade visível ao jogador, não manutenção interna. |
| Planejar novos bancos de código | **Manter mapa, sem expansão preventiva** | `docs/ARQUITETURA.md` e `docs/ROTEIRO.md` já documentam ocupação e alternativa para bancos adicionais. Atualizar somente se os dados atuais divergirem. |
| Documentar decisões e formatos | **Adotar como trabalho contínuo** | Já existem `docs/FORMATOS.md`, `docs/ARQUITETURA.md` e marcações de hipótese; o trabalho é reconciliar e completar lacunas com evidência, sem duplicar conteúdo. |

## 4. Ordem de execução proposta

A ordem abaixo é deliberada: primeiro medir e organizar; depois desenhar a ferramenta; só então alterar o fluxo. Nenhuma fase de implementação começa automaticamente pela aprovação deste plano.

### Fase 0 — congelar escopo e preparar o trabalho

**Objetivo:** evitar que tarefas de conteúdo se infiltrem na fase de manutenibilidade.

**Atividades futuras**

- Registrar em `docs/ROTEIRO.md` ou num ADR a pausa de novos personagens e funcionalidades.
- Separar manutenção estrutural, REA/documentação e conteúdo de jogo em listas distintas.
- Criar uma lista de decisões pendentes, com responsável e evidência necessária.

**Saída:** escopo de estabilização acordado; nenhuma tarefa desta fase pode introduzir uma mudança jogável.

**Gate:** autorização do mantenedor antes de editar documentação do projeto.

### Fase 1 — auditoria reproduzível do estado atual

**Objetivo:** criar uma única linha de base confiável, sem inferir números de documentos possivelmente desatualizados.

**Atividades futuras**

- Inventariar fontes de verdade: `annotations/sf2ne.ann`, gerador, `src/`, `docs/`, scripts em `tools/` e configurações do build.
- Definir como contar labels totais, nomes semânticos, labels de código e labels de dados. Documentar o critério para não comparar categorias diferentes.
- Reconciliar a contagem publicada de labels no README com as notas do roteiro e a saída atual do gerador.
- Confirmar mapa de bancos, espaço livre e localização do kernel, distinguindo ocupação por banco da ocupação total do PRG.
- Inventariar scripts de comparação/regressão e documentos que os mencionam. Marcar “existente”, “documentado”, “executado anteriormente” ou “pendente” apenas com evidência disponível; não executar nenhum script nesta fase.
- Identificar contradições entre README, `docs/ARQUITETURA.md`, `docs/ROTEIRO.md`, `docs/FORMATOS.md`, `docs/BUGS.md` e especificações de tarefas.

**Saídas propostas**

- Um registro de estado atual com métricas e critérios de contagem.
- Uma matriz documento → fonte de verdade → divergência → ação proposta.
- Um inventário de validações existentes e pendentes, sem resultados novos de teste.

**Critérios de saída**

- Os números usados no plano são reproduzíveis por um método descrito.
- “Código”, “dados”, “label genérico” e “label semântico” não são misturados numa única métrica.
- Não há afirmação de teste aprovado sem evidência já existente.

### Fase 2 — especificação do formato de autoria de estados e quadros

**Objetivo:** definir um formato humano-legível para os dados atuais, sem alterar sua semântica ou acrescentar conteúdo.

**Atividades futuras**

- Usar `docs/FORMATOS.md` como contrato inicial e listar todos os campos, tamanhos, ponteiros, laços, sentinelas, tabelas de seleção e exceções documentadas.
- Escolher entre macros ca65 e uma entrada declarativa externa (por exemplo, YAML/TOML/JSON) somente depois de comparar legibilidade, tipagem, validação, diffs e integração com o gerador.
- Definir como representar labels simbólicos, bancos, ponteiros relativos/absolutos, campos opcionais e hipóteses.
- Proibir conversões silenciosas de valores inválidos ou perda de campos desconhecidos.
- Especificar como o gerador reporta erros com arquivo/linha/campo e como evita sobrescrever fontes canônicas.
- Usar primeiro um subconjunto representativo dos dados existentes do Ryu para documentar a prova de cobertura; não criar estados de Ken nesta fase.

**Saídas propostas**

- ADR de formato e decisão explícita da fonte canônica.
- Esquema da linguagem/formatos e gramática dos registros.
- Plano de conversão do banco existente em etapas, com rollback documental.
- Critérios de equivalência estrutural que o Engineer poderá verificar depois de autorização.

**Critérios de saída**

- Todos os campos já documentados no formato binário têm representação definida ou uma exceção registrada.
- O formato não exige editar `src/` gerado à mão.
- A especificação separa os dados originais de qualquer conteúdo futuro.
- A conversão e a verificação ainda não são executadas por este plano.

### Fase 3 — naming guiado por risco e evidência

**Objetivo:** tornar as áreas mais caras de navegar mais compreensíveis sem produzir nomes especulativos.

**Ordem sugerida**

1. Dispatchers, chamadas entre bancos e rotinas centrais do ciclo da luta.
2. Carregamento da ficha do personagem, mudança de estado, input/comandos e movimentação compartilhada.
3. Rotinas de desenho, colisão, dano e demais funções que afetam muitas tabelas.
4. Dados de personagem/tabelas com função recorrente, sempre distinguindo dados de código.
5. Rotinas auxiliares raras, somente quando forem tocadas por outra tarefa autorizada.

**Regras de naming**

- Um nome semântico precisa de evidência estática, anotação de rastreamento já existente ou relação de dados demonstrável.
- Não substituir label genérico por nome “plausível” sem demonstrar a função; marcar incertezas como hipótese.
- Registrar nomes de RAM compartilhada de forma consistente com `docs/RAM.md`.
- Não renomear símbolos públicos usados por ferramentas/scripts sem atualizar suas referências de forma controlada.
- Medir progresso por cobertura de rotinas críticas nomeadas e por redução de ambiguidades, além da contagem global.

**Saídas propostas**

- Lista priorizada de labels críticos e evidência associada.
- Alterações futuras em annotations/documentação geradas pelo fluxo estabelecido.
- Métricas antes/depois produzidas com o critério da Fase 1.

**Critérios de saída**

- Nomes novos são rastreáveis à evidência.
- Não há edição direta e divergente de `src/` gerado.
- A meta é compreensão/manutenção, não atingir arbitrariamente 60–70% do total.

### Fase 4 — completar documentação operacional e decisões

**Objetivo:** reduzir o custo de retomada do projeto e evitar que documentos diferentes orientem ações incompatíveis.

**Atividades futuras**

- Marcar cada formato e comportamento como confirmado, hipótese ou desconhecido.
- Manter uma matriz de responsabilidade documental: arquitetura descreve estrutura; formatos descreve registros/semântica; roteiro lista etapas; bugs registra defeito e status; tasks especificam entregas pontuais.
- Corrigir recomendações históricas incompatíveis com decisões atuais, por exemplo, validações ou mudanças de escopo já adiadas.
- Registrar limites e interfaces das ferramentas: arquivos de entrada, saída, opções, se são geradas e os casos de erro esperados.
- Manter REA arcade em documento separado, sem misturá-la a dados/implementação NES.

**Saída:** documentação consistente, sem duplicar especificações funcionais em diversos arquivos.

**Critério de saída:** cada fato crítico tem uma fonte de verdade identificável e as hipóteses permanecem explicitamente sinalizadas.

### Fase 5 — proposta de validação futura (somente especificação)

**Objetivo:** determinar o que deveria ser verificado quando houver autorização e quando a implementação de conteúdo for retomada.

**Atividades futuras**

- Mapear o que os scripts existentes afirmam cobrir e quais cenários não cobrem, sem executá-los agora.
- Propor níveis distintos: integridade do gerador/formato, equivalência estrutural dos dados, build, regressão de funcionalidades já existentes e aceitação manual em emulador.
- Definir casos de Ken somente quando a implementação for retomada e respeitando o escopo vigente; não presumir Ken-vs-Ken ou IA de Ken.
- Descrever evidências requeridas para qualquer alegação de “aprovado”.

**Saída:** plano de validação com casos, pré-condições, artefatos e responsável.

**Gate obrigatório:** nenhuma automação é criada e nenhum teste/build/emulador é executado sem autorização explícita posterior.

## 5. Trabalho explicitamente adiado ou excluído

- Implementar Ken, IA de Ken, novos personagens ou novos golpes/estados jogáveis.
- Acrescentar tela de seleção de dificuldade/versus ou qualquer outra interface nova.
- Converter imagens/áudio ou integrar ferramenta externa de assets.
- Extrair/refatorar o kernel para banco dedicado.
- Alterar o layout de bancos apenas para antecipar uma expansão hipotética.
- Refazer o sistema de build ou congelar `src/` sem ADR aprovado.
- Executar Mesen, MAME, regressão, teste de shift/realocação, build ou teste manual nesta etapa.
- Copiar código, dados ou ativos do arcade ou de ports de terceiros.

Os itens podem ser reconsiderados em decisões futuras, cada um com objetivo, risco, evidência e escopo próprios.

## 6. Dependências e riscos

| Risco/dependência | Tratamento |
|---|---|
| Métricas antigas ou critérios diferentes de contagem | Definir o método na Fase 1 antes de estabelecer metas. |
| `src/` e annotations divergirem | Preservar o fluxo gerado; se houver mudança de fonte canônica, exigir ADR e migração explícita. |
| Novo formato não representar casos raros do Ryu | Fazer inventário completo dos campos e exceções antes de codificar o conversor. |
| Naming especulativo piorar a documentação | Exigir evidência e registrar hipóteses em vez de nomes definitivos. |
| Testes documentados parecerem autorização para executá-los | Repetir o gate de autorização em toda especificação de execução. |
| Refatoração do kernel perturbar vetores/tempos de IRQ | Adiar até existir necessidade mensurável e plano específico de compatibilidade/ciclos. |
| Ferramentas externas de assets indisponíveis ou com licença inadequada | Fazer auditoria de disponibilidade/licença antes de incluí-las num escopo futuro. |
| REA arcade se misturar à implementação NES | Manter documentos e rastreabilidade separados; transportar apenas especificações comportamentais autorizadas. |

## 7. Gates de decisão

Cada fase de execução futura exige uma decisão explícita do mantenedor:

1. **Gate A — auditoria documental:** autoriza leitura e edição de documentação; não autoriza alteração de código ou execução de build/teste.
2. **Gate B — desenho do formato:** autoriza produzir a especificação/ADR do formato; não autoriza o conversor.
3. **Gate C — implementação do formato:** autoriza mudanças em ferramentas e dados, com arquivos de entrada/saída delimitados; verificações técnicas só conforme autorização expressa.
4. **Gate D — naming:** autoriza mudanças em annotations e geração das fontes simbólicas; qualquer build/teste continua dependente de autorização própria.
5. **Gate E — validação:** define se serão permitidos testes automatizados, build, emulador ou testes manuais, quais arquivos/artefatos e quais cenários.

A aprovação deste documento, por si só, **não abre nenhum desses gates**.

## 8. Definição de conclusão da fase de estabilização

A fase só será considerada concluída quando:

- [ ] houver uma linha de base verificável de labels, bancos, ferramentas, fontes canônicas e validações;
- [ ] README, roteiro, arquitetura, formatos e bugs estiverem consistentes sobre o estado do projeto;
- [ ] houver decisão documentada sobre o formato canônico de autoria de estados/quadros e seu gerador;
- [ ] a estratégia de naming priorizar criticidade e evidência, sem meta percentual arbitrária;
- [ ] houver um plano de validação futuro explicitamente separado da autorização para executá-lo;
- [ ] novos personagens/funcionalidades permanecerem pausados durante a fase;
- [ ] nenhuma alteração local preexistente for descartada sem autorização.

## 9. Próxima ação recomendada

Solicitar primeiro o **Gate A** para realizar a auditoria documental e consolidar as métricas atuais. Depois da linha de base, decidir se o maior retorno imediato vem da especificação do formato textual ou do naming das rotinas críticas. Não iniciar conversor, campanha ampla de renomeação, teste, build ou refatoração antes dessa decisão.
