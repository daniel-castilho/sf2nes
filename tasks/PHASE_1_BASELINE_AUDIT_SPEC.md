# Especificação técnica — Fase 1: auditoria reproduzível do estado atual

**Status:** pronta para o Software Engineer executar após o gate de entrada.  
**Projeto:** Street Fighter II NE (`daniel-castilho/sf2nes`).  
**Origem:** Fase 1 de `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.  
**Pré-requisito:** Fase 0 concluída e aceita conforme `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md`.  
**Tipo de trabalho:** inspeção estática e documentação da linha de base.  
**Build, compilação, execução da ROM, testes, emulador e alterações de código:** fora do escopo e não autorizados por esta especificação.

## 1. Objetivo

Produzir um retrato verificável e datado do estado do repositório, das fontes de verdade, dos indicadores de nomenclatura, da ocupação de bancos tal como documentada, dos utilitários de validação existentes e das divergências entre documentos.

A auditoria deve permitir que as próximas fases tomem decisões com base em dados reproduzíveis, sem confundir:

- contagens atuais com números históricos publicados;
- código com dados;
- labels gerados por endereço com nomes semânticos;
- scripts existentes com testes aprovados;
- documentação de validação com validação executada;
- trabalho planejado com trabalho autorizado ou concluído.

## 2. Resultado exigido

Criar um documento principal:

- `docs/ESTADO_DO_PROJETO.md`

O documento deve ser suficiente para alguém repetir as contagens puramente textuais usando o critério descrito nesta especificação e entender o que ficou sem confirmação por exigir build, execução ou inspeção fora do escopo.

Opcionalmente, atualizar somente os estados/links correspondentes em:

- `tasks/STABILIZATION_BACKLOG.md`, se o arquivo já existir por conclusão da Fase 0.

Não corrigir divergências em outros documentos nesta fase. Registrá-las no relatório para priorização pela fase documental posterior.

## 3. Gate de entrada e preservação da árvore

Antes de iniciar, o Engineer deve:

1. confirmar que a Fase 0 foi aceita; se não foi, parar e reportar o bloqueio, sem executar a auditoria;
2. registrar data/hora local, hash do commit (`HEAD`) e estado resumido da árvore de trabalho;
3. separar arquivos modificados/não rastreados preexistentes dos arquivos produzidos pela tarefa;
4. preservar todas as alterações existentes. É proibido usar `clean`, `reset`, `restore`, checkout destrutivo ou ação equivalente;
5. ler as versões atuais dos documentos de entrada listados na §4, não confiar em transcrições antigas da conversa.

Se um arquivo de saída já existir, não substituí-lo integralmente: comparar, manter conteúdo local e acrescentar/atualizar apenas a seção pertinente, registrando a divergência.

## 4. Fontes a inspecionar

### 4.1 Núcleo do projeto

- `README.md`
- `Makefile`
- `sf2ne.cfg`
- `annotations/sf2ne.ann`
- `src/bank_*.s` e `src/*.inc`
- `docs/ARQUITETURA.md`
- `docs/FORMATOS.md`
- `docs/RAM.md`
- `docs/ROTEIRO.md`
- `docs/BUGS.md`
- `docs/FERRAMENTAS.md`

### 4.2 Ferramentas e documentos de trabalho

- `tools/` e `tools/mesen/` — leitura de nomes, argumentos, entradas/saídas e comentários; **não executar**;
- `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`;
- `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md`;
- `tasks/STABILIZATION_BACKLOG.md`, se existente;
- especificações de Ken, Guile e REA arcade, apenas para detectar restrições/duplicações de escopo; não alterar conteúdo destas especificações.

Não inspecionar ou executar a ROM arcade nesta fase. A REA arcade é uma trilha separada.

## 5. Procedimento da auditoria

### 5.1 Proveniência e estado da árvore

No cabeçalho de `docs/ESTADO_DO_PROJETO.md`, registrar:

- data da auditoria;
- commit `HEAD` examinado;
- se a árvore estava limpa ou modificada;
- quais áreas/arquivos tinham alterações locais relevantes, sem atribuí-las à auditoria;
- limitações de escopo: nenhuma montagem, execução, emulação ou teste realizado nesta auditoria.

Não incluir credenciais, conteúdo de configuração sensível, caminhos privados de usuário ou valores de segredos.

### 5.2 Inventário de fontes de verdade e artefatos gerados

Montar tabela com colunas:

| Área | Fonte canônica declarada | Arquivo/artefato gerado ou derivado | Método atual de atualização | Observação/risco |

Cobrir, no mínimo:

- labels/comentários/correções e `annotations/sf2ne.ann`;
- gerador e arquivos `src/`;
- configuração e fluxo de build;
- dados/estruturas de estados e quadros;
- assets fonte versus `extracted/`;
- ROM de referência e ROMs de saída/versionadas;
- scripts de trace/validação e seus artefatos de evidência.

Quando os documentos discordarem sobre a fonte canônica, registrar a divergência; não escolher uma nova fonte por inferência.

### 5.3 Métricas de labels

Calcular as métricas a partir dos arquivos-fonte gerados atualmente em `src/`, sem executar o gerador nem o assembler. Registrar o método exato (glob, parser/regex, exclusões e versão do comando/script utilizado) para possibilitar repetição.

Relatar separadamente:

1. **definições de labels globais** encontradas em `src/bank_*.s`;
2. **ocorrências totais** e **nomes únicos** — não assumir que são iguais;
3. labels gerados a partir de endereços, no padrão exato definido pelo gerador (por exemplo, famílias de código `L<bank>_<address>` e dados `D<bank>_<address>`); confirmar o padrão no gerador antes de contar;
4. labels semânticos, definidos para esta auditoria como labels globais que não correspondem ao padrão automático de banco/endereço confirmado na etapa anterior;
5. contagem por banco e por categoria, distinguindo código/dado apenas quando a classificação puder ser sustentada pelas annotations/gerador; caso contrário, registrar categoria `não classificada`;
6. labels locais/temporários, labels anônimos, constantes e símbolos de RAM como categorias separadas ou explicitamente fora da métrica principal.

Regras:

- Não usar o número publicado no README como resultado atual sem recalcular.
- Não somar categorias sobrepostas nem usar o total de labels como medida única de qualidade.
- Se houver label duplicado entre bancos, informar ocorrências e símbolos únicos separadamente.
- Não criar uma ferramenta permanente nem modificar `tools/` nesta fase. Se não for possível obter uma métrica reproduzível por inspeção textual simples, descrever o bloqueio e propor uma ferramenta numa decisão futura; não improvisar um parser que altere ou gere fontes.
- Não renomear nenhum label.

### 5.4 Ocupação de bancos e espaço

Registrar o mapa publicado em `docs/ARQUITETURA.md` e `docs/ROTEIRO.md`, incluindo:

- bancos descritos como código, dados, assets, música ou vazios;
- valores publicados de bytes livres/ocupados, quando existirem;
- o método e a evidência histórica que sustentam cada número, se documentados;
- divergências entre os documentos.

Como não é permitido compilar/linkar nem executar a ROM, **não recalcular ocupação a partir de um novo mapa de linker, não gerar build e não declarar o espaço atual revalidado**. Identificar os valores como “publicados na documentação, não revalidados nesta auditoria” quando não houver uma fonte estática atual suficiente.

Separar claramente:

- limitação local de um banco específico (por exemplo, código concentrado no banco `$3B`);
- capacidade total restante do PRG;
- requisitos de kernel/vetores que condicionam a colocação de código;
- afirmações de datas diferentes ou de versões/builds distintas.

### 5.5 Inventário de scripts e alegações de validação

Ler `tools/mesen/`, `tools/` e documentos que referenciam build/regressão/realocação/testes. Não executar scripts.

Para cada item identificado, registrar:

| Ferramenta/script | Finalidade declarada | Inputs/outputs inferidos pela leitura | Cenário/afirmação coberta | Evidência de execução existente | Status auditado |

Usar estados controlados:

- `EXISTE — não executado nesta auditoria`;
- `EXECUÇÃO HISTÓRICA DOCUMENTADA` (somente se houver registro verificável nos documentos/artefatos já presentes);
- `STATUS DESCONHECIDO`;
- `DOCUMENTADO, ARTEFATO AUSENTE`.

Não transformar presença do script em aprovação. Não rodar Mesen/MAME, scripts shell, assembler/linker, `make`, regressão, teste de shift/realocação ou teste manual. Não produzir ROM, mapa, trace ou vídeo novo.

### 5.6 Matriz de consistência documental

Comparar README, roteiro, arquitetura, formatos, RAM, bugs, ferramentas e especificações de tarefa. Para cada conflito ou ambiguidade relevante, registrar:

| ID | Afirmação/assunto | Documento A | Documento B | Categoria | Risco | Proposta de destino |

Categorias mínimas:

- status/escopo;
- contagem/métrica;
- fonte de verdade/geração;
- capacidade de banco/build;
- formato/semântica;
- validação/teste;
- restrição de personagem/IA.

A auditoria não deve corrigir estes documentos. O campo “proposta de destino” é recomendação, não decisão aprovada. Não marcar interpretação como fato se as fontes não permitirem resolvê-la.

### 5.7 Backlog e decisões pendentes

Se `tasks/STABILIZATION_BACKLOG.md` existir, atualizar somente:

- status da Fase 1 para `AUDITORIA CONCLUÍDA — DOCUMENTO ENTREGUE`, sem indicar testes aprovados;
- links relativos para o novo relatório;
- decisões D-01–D-07 com estado/evidência apenas quando a auditoria trouxer informação, preservando-as como pendentes até decisão do Mantenedor.

Se o backlog não existir porque a Fase 0 não foi executada, isso é bloqueio de entrada; não criar o backlog em nome da Fase 0 dentro desta tarefa.

## 6. Estrutura obrigatória de `docs/ESTADO_DO_PROJETO.md`

1. **Metadados da auditoria e limitações** — data, commit, árvore modificada/limpa e atividades não realizadas.
2. **Resumo executivo** — somente fatos de auditoria; separar itens confirmados de históricos/desconhecidos.
3. **Fontes de verdade e artefatos gerados**.
4. **Métricas de labels** — método reproduzível, categorias, totais, limitações.
5. **Mapa de bancos e capacidade documentada** — status de revalidação explícito.
6. **Inventário de ferramentas/validações** — sem alegação de aprovação nova.
7. **Matriz de inconsistências** — IDs estáveis e documentos envolvidos.
8. **Decisões que permanecem pendentes** — referência ao backlog, se existir.
9. **Limitações e próximos passos recomendados** — sem implementar ou escolher fonte canônica.
10. **Índice de fontes** — caminhos relativos internos, método de contagem e arquivos consultados.

## 7. Regras de redação e evidência

Cada declaração significativa deve ser rotulada por contexto, por exemplo:

- **Confirmado por inspeção estática nesta auditoria**;
- **Publicado anteriormente, não revalidado agora**;
- **Inferido a partir do nome/estrutura — hipótese**;
- **Desconhecido/pendente**.

Evitar expressões como “testado”, “passa”, “funciona atualmente” ou “validado” sem evidência existente e identificável. Preservar a distinção entre versão de ROM original, builds opcionais e arquivos `.nes` já versionados.

## 8. Fora do escopo

- Corrigir ou reescrever README, roteiro, arquitetura, formatos, bugs ou especificações; registrar divergências para trabalho posterior.
- Mudar escopo, resolver decisões pendentes ou autorizar novos personagens/funcionalidades.
- Alterar annotations, assembly, scripts, ferramentas, assets, configs ou ROMs.
- Criar ferramentas permanentes de auditoria nesta fase.
- Executar gerador, assembler, linker, build, Mesen, MAME, testes, regressão, shift/realocação ou validação manual.
- Inspecionar ou validar a ROM arcade, portar IA ou incorporar dados externos.

## 9. Critérios de aceite

- [ ] O gate de entrada da Fase 0 foi verificado; caso contrário, a tarefa foi interrompida e reportada como bloqueada.
- [ ] `docs/ESTADO_DO_PROJETO.md` existe e contém todas as seções da §6.
- [ ] As métricas de labels informam método, arquivos, padrões, exclusões, ocorrências e nomes únicos.
- [ ] Nenhuma métrica de labels depende de número copiado de README/roteiro sem recálculo.
- [ ] Ocupação de banco está identificada como documental/histórica ou estática atual; nenhum novo mapa de linker foi produzido.
- [ ] Scripts e validações existentes foram inventariados por leitura, sem execução ou alegação de aprovação.
- [ ] Divergências têm IDs, referências e proposta; não foram corrigidas silenciosamente.
- [ ] O status de cada claim distingue confirmação atual, dado histórico, hipótese e desconhecido.
- [ ] Nenhum arquivo fora da lista de saídas da §2 foi alterado.
- [ ] Nenhum build, teste, emulador, script de validação ou comando que gere artefatos foi executado.
- [ ] O estado local preexistente foi preservado.

## 10. Relatório de entrega do Engineer

Ao encerrar, o Engineer deve informar:

1. confirmação do pré-requisito da Fase 0;
2. arquivos criados/alterados;
3. método exato usado para as métricas de labels e resultados por categoria;
4. quais valores de ocupação são apenas históricos/documentados;
5. scripts inventariados e status, sem inferir que foram executados;
6. divergências de maior risco e onde devem ser resolvidas;
7. decisões que permanecem pendentes;
8. declaração explícita de que não alterou código/ROM/tools, não compilou, não executou build/teste/emulador e preservou alterações locais.
