# Especificação técnica — Fase 2: formato de autoria de estados e quadros

**Status:** pronta para o Software Engineer executar como fase de desenho; não autoriza implementação do formato/conversor.  
**Projeto:** Street Fighter II NE (`daniel-castilho/sf2nes`).  
**Origem:** Fase 2 de `tasks/PROJECT_STABILIZATION_EXECUTION_PLAN.md`.  
**Pré-requisitos:** Fase 0 aceita e Fase 1 concluída, com `docs/ESTADO_DO_PROJETO.md` disponível.  
**Tipo de trabalho:** levantamento, comparação de alternativas, especificação e recomendação de decisão.  
**Código, migração de dados, build, compilação, ROM, testes e emulador:** fora do escopo e não autorizados por esta especificação.

## 1. Objetivo

Definir uma forma legível, segura e sustentável de **autorizar futuramente** a edição dos dados existentes de estados e quadros de animação, reduzindo a edição manual de bytes sem perda de controle sobre o formato original.

A Fase 2 deve produzir uma decisão técnica e uma especificação suficientes para que uma fase posterior possa implementar a ferramenta. Ela **não** deve construir conversor, migrar dados, alterar `src/`, mudar annotations nem acrescentar estados ou conteúdo de personagem.

Usar os dados atuais do Ryu somente para verificar se a proposta representa as estruturas existentes. Não criar dados de Ken nem afirmar que o formato já está validado por geração/build/runtime.

## 2. Gate de entrada

Antes de começar a execução desta fase, o Engineer deve confirmar:

1. a Fase 0 foi concluída e aceita;
2. a Fase 1 foi concluída e `docs/ESTADO_DO_PROJETO.md` contém o inventário das fontes de verdade e gerados;
3. `docs/FORMATOS.md`, annotations, gerador e fontes `src/` continuam coerentes o bastante para comparar alternativas;
4. a árvore local e as alterações preexistentes foram registradas e preservadas.

Se qualquer requisito falhar, parar e relatar o bloqueio. Não resolver divergências da Fase 1 por suposição nem iniciar o conversor para contornar dados faltantes.

## 3. Escopo de decisão

A decisão deve responder explicitamente:

- qual arquivo ou conjunto de arquivos será a **fonte canônica de autoria** dos estados/quadros;
- qual ferramenta os transforma em assembly/dados consumidos pelo build;
- como essa fonte se integra ao gerador atual sem ser sobrescrita por `make gen`;
- qual parte permanece responsabilidade de `annotations/sf2ne.ann` (labels, comentários, correções/alternates, blocos de código, metadados de disassembly);
- quais arquivos são gerados e nunca devem ser editados manualmente;
- como preservar símbolos, referências, bancos, ordem e valores atuais sem introduzir mudança semântica.

Comparar no mínimo:

1. **Macros/DSL em ca65:** declarações de estados/quadros em assembly com macros e diretivas simbólicas.
2. **Formato declarativo externo:** arquivo estruturado processado por ferramenta (ex.: TOML, YAML ou JSON), com geração de assembly compatível com o fluxo.

O Engineer pode recomendar alternativa híbrida apenas se explicar a fronteira de responsabilidade e fonte canônica. A decisão final pertence ao Mantenedor. A proposta do Engineer deve ser marcada `PROPOSTA`, não `APROVADA`, até obter essa decisão explícita.

## 4. Fontes técnicas obrigatórias

Usar como contrato inicial, sem copiar conteúdo de terceiros:

- `docs/FORMATOS.md` — campos, tamanhos, tabelas, condições, estados, quadros, laços e ponteiros;
- `docs/ARQUITETURA.md` — banco de estados, banco de frames, carregador e mapeamento;
- `docs/RAM.md` — símbolos/variáveis que conectam dados ao motor;
- `annotations/sf2ne.ann` — diretivas de anotação, marcação de bancos, condições, blocks e alternates;
- `tools/disasm.py` — fluxo atual de geração e fronteira do que ele lê/escreve;
- `src/` — forma assembly atualmente consumida pelo build;
- `Makefile` e `sf2ne.cfg` — integração atual de geração/montagem/linkedição, apenas por leitura.

O relatório da Fase 1 é a referência para conflitos ou dúvidas sobre as fontes canônicas. Se o código real contradizer uma afirmação documental, documentar a divergência; não alterar gerador, source ou build nesta fase.

## 5. Cobertura estrutural que a proposta deve representar

A especificação do formato deve descrever todos os elementos necessários para serializar sem perda o conjunto atual de estados/quadros do Ryu, inclusive registros não alcançáveis ou apontados como órfãos nos documentos.

Pelo menos:

### 5.1 Tabelas da ficha e referências

- tabelas de ponteiros usadas para estados por direção, botões, especiais, guarda/defesa, reações a dano, agarrões e IA, conforme inventário atual;
- tabela de bytes para banco de estados, banco de frames e fonte de colisões, se o formato da ficha fizer parte da proposta;
- contagem/ordem das entradas, vazios, terminadores, aliases e referências fora do banco, quando aplicáveis;
- endereços por label simbólico; valores literais só como escape explícito e documentado;
- separação clara entre metadados da ficha e conteúdo do banco de estados.

A Fase 2 não deve preencher a ficha do Ken nem alterar as tabelas existentes.

### 5.2 Cabeçalho de estado

Representar os campos documentados em `docs/FORMATOS.md`, incluindo:

- condição/critério de entrada;
- vínculo/ponteiro para a próxima alternativa;
- vínculo/ponteiro da cadeia natural;
- classe do estado;
- contagem de acertos do estado.

Condições e classes devem aceitar nomes simbólicos quando já houver uma definição confiável e, em todos os casos, permitir um valor numérico bruto para manter registros cujo significado permaneça incerto.

### 5.3 Quadros de animação

Representar, sem perda:

- duração;
- ponteiro de metasprite;
- ponteiro de caixas de colisão ou ausência delas;
- parâmetros/tipo de efeito;
- flags;
- modo de movimento;
- velocidades X/Y;
- repetição e ponteiro de desvio do laço;
- ponteiro para o quadro seguinte ou sentinela de fim.

A representação deve tratar corretamente os registros de tamanho variável documentados — quadro normal e quadro com dados de laço — e garantir que o caso sem laço não emita nem interprete campos inexistentes.

### 5.4 Dados não totalmente compreendidos

- Preservar literalmente o valor bruto de campos cujo significado seja hipótese ou desconhecido.
- Permitir comentários/anotações por registro e por campo para indicar evidência, hipótese ou referência documental.
- Não forçar nomes semânticos para opcodes, condições, efeitos ou flags ainda não confirmados.
- Distinguir “zero”, “ausente/null”, “terminador” e “campo omitido”; não tratá-los como equivalentes.
- Representar dados não alcançáveis/órfãos quando fizerem parte da região auditada, evitando conversão baseada apenas na cadeia de estados alcançável.

### 5.5 Relocação e geração

A proposta deve especificar como conservar:

- rótulos e referências simbólicas entre estados e quadros;
- associação de cada estado ao banco de estados e dos quadros/metasprites às fontes de frames;
- alinhamento, ordem de emissão e sentinelas, caso afetem a estrutura;
- relocação pelo assembler/linker sem endereços absolutos duplicados na fonte;
- formato de assembly que se integra ao processo existente.

Não fixar endereços ou assumir banco específico para personagens futuros nesta fase. O foco é modelar os registros atuais sem bloquear a relocação.

## 6. Matriz de comparação das alternativas

A decisão deve comparar macros ca65 e formato declarativo externo nos critérios abaixo, com avaliação curta e evidência:

| Critério | Pergunta que deve ser respondida |
|---|---|
| Legibilidade de diff | É fácil revisar mudanças de um estado/quadro sem decodificar bytes? |
| Tipagem/validação | Como detectar condição inválida, ponteiro faltante, duração fora da faixa ou laço malformado antes de gerar assembly? |
| Cobertura | Todos os campos e exceções atuais têm representação sem perda? |
| Símbolos | Como nomes de estados, frames, caixas e bancos são referenciados sem número mágico? |
| Dados desconhecidos | É possível preservar valores brutos e comentários de incerteza? |
| Fonte canônica | Existe um único local que o Engineer edita? O que acontece ao executar `make gen`? |
| Integração | Qual seria o ponto de entrada no fluxo atual sem sobrescrever annotations ou `src/` manualmente? |
| Erros | O diagnóstico aponta arquivo, registro, campo e referência inválida? |
| Determinismo | A mesma entrada produz assembly ordenado e reprodutível? |
| Dependências | Exige biblioteca ou runtime adicional? Qual o custo de manutenção? |
| Migração | Como adotar gradualmente sem transformar toda a árvore de uma vez? |
| Reversibilidade | Como desfazer adoção ou corrigir formato sem perder dados? |

Não escolher formato apenas por preferência de sintaxe. A proposta precisa demonstrar a interação com a geração atual e as limitações encontradas na auditoria da Fase 1.

## 7. Requisitos para a proposta de schema/gramática

A entrega deve incluir uma especificação legível do schema, independente da sintaxe escolhida, com:

- unidades de medida e limites conhecidos;
- nomes simbólicos permitidos e sua origem;
- campos obrigatórios, opcionais, repetíveis e mutuamente exclusivos;
- regra de referência e detecção de destino inexistente;
- regra de ordenação e serialização;
- valores brutos para campos desconhecidos;
- representação de null/ausente/fim/terminador;
- representação do quadro com/sem laço;
- comentário de procedência e confiança sem afetar os bytes emitidos;
- comportamento definido para valores duplicados, labels duplicados e endereços não resolvidos;
- compatibilidade com os tamanhos/limites binários documentados, sem corrigir ou normalizar dados silenciosamente.

### Exemplo ilustrativo

A especificação pode incluir um exemplo mínimo **esquemático** para mostrar o desenho do schema, mas deve:

- usar valores fictícios/simbólicos que não reproduzam uma sequência real de dados do jogo;
- não incluir dados completos ou bytecode extraídos da ROM arcade;
- não apresentar o exemplo como dado válido pronto para montagem;
- marcar campos cujo significado dependa de confirmação.

Não é obrigatório incluir exemplo se a gramática ficar clara sem ele.

## 8. Integração com o fluxo existente — decisão, não implementação

O ADR deve desenhar um fluxo-alvo e demarcar explicitamente a responsabilidade de cada camada. Considerar, sem assumir a solução:

- `annotations/sf2ne.ann` permanece fonte para anotações, símbolos e correções do disassembly;
- dados textuais de estados podem precisar de arquivo/fonte próprio;
- `src/` continua gerado, se esse for o resultado aprovado;
- `make gen` não pode destruir nem ignorar silenciosamente dados de autoria novos;
- o build deve consumir artefatos previstos pelo fluxo, sem depender de edição manual de arquivo gerado.

A proposta deve indicar se a integração exige modificar `tools/disasm.py`, `Makefile`, layout de diretórios ou configuração do linker. Essas mudanças são apenas listadas como trabalho futuro. Não as realizar na Fase 2.

## 9. Saídas obrigatórias

Criar os documentos de decisão/projeto abaixo:

1. `tasks/STATE_DATA_FORMAT_DECISION.md` — matriz de opções, recomendação do Engineer, fonte canônica proposta, trade-offs, riscos e estado de aprovação do Mantenedor.
2. `tasks/STATE_DATA_FORMAT_SCHEMA.md` — schema/gramática conceitual, tipos, regras, referências, valores desconhecidos e serialização esperada.
3. `tasks/STATE_DATA_FORMAT_MIGRATION_PLAN.md` — passos futuros de implementação/migração, arquivos que provavelmente seriam afetados, salvaguardas para `make gen`, rollback e critérios de verificação futura.

Esses são documentos de desenho. Se um arquivo já existir ou houver convenção de ADR criada após esta especificação, não sobrescrever: preservar conteúdo, apontar o conflito e pedir decisão antes de criar duplicata.

## 10. Fora do escopo

- Implementar parser, conversor, gerador, macros ou novos scripts permanentes.
- Alterar `tools/disasm.py`, `Makefile`, `sf2ne.cfg`, annotations, `src/`, dados ou assets.
- Converter Ryu ou Ken para o formato novo.
- Acrescentar, editar ou normalizar registros reais do jogo.
- Criar ficha/estados/frames de Ken ou de qualquer outro personagem.
- Rodar gerador, assembler, linker, `make`, build, teste, Mesen, MAME ou validação manual.
- Reestruturar o kernel, mudar bancos ou mexer em ROMs.
- Resolver lacunas semânticas dos formatos que dependam de investigação adicional; listá-las como abertas.

## 11. Critérios de aceite

- [ ] O gate de entrada (Fase 0 e Fase 1 concluídas) foi confirmado; sem isso, a execução foi interrompida.
- [ ] Foram consultadas as versões atuais das fontes listadas na §4 e o resultado da Fase 1.
- [ ] Macros ca65 e formato declarativo externo foram comparados pela matriz da §6; qualquer alternativa híbrida está justificada.
- [ ] O Engineer recomenda uma opção e indica a fonte canônica proposta; a aprovação final permanece explícita do Mantenedor.
- [ ] O schema cobre os elementos da §5 e explicita como preservar dados órfãos, valores desconhecidos, sentinelas, laços e referências simbólicas.
- [ ] A proposta distingue zero/null/ausente/fim e não depende somente de estados alcançáveis.
- [ ] A interação com annotations, gerador, `src/`, `make gen` e build está desenhada sem alteração do fluxo nesta fase.
- [ ] Há plano gradual de migração, rollback e verificações futuras, sem alegar que foram executadas.
- [ ] Os documentos de decisão, schema e migração estão entregues, sem código/fonte de dados novo.
- [ ] Nenhum arquivo fora dos documentos permitidos da §9 foi modificado.
- [ ] Nenhum código, ferramenta, annotation, asset ou ROM foi alterado; nenhum build, teste ou emulador foi executado.
- [ ] Alterações locais preexistentes foram preservadas.

## 12. Relatório de entrega do Engineer

Ao concluir, informar:

1. arquivos documentais criados ou atualizados;
2. alternativas comparadas e evidência usada;
3. formato/fonte canônica recomendados e estado `PROPOSTO` ou `APROVADO` (com decisão explícita do Mantenedor);
4. casos de formato ainda desconhecidos e os dados que não puderam ser classificados;
5. arquivos e ferramentas que uma futura implementação provavelmente precisará alterar;
6. riscos, migração e rollback propostos;
7. confirmação de que nenhum conversor/migração/build/teste/emulador foi executado e que o estado local foi preservado.
