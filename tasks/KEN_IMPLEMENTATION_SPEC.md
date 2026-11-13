# Especificação de implementação — Ken como segundo lutador

**Status:** pronto para implementação, sujeito aos pontos de atenção abaixo  
**Projeto:** Street Fighter II NE (`daniel-castilho/sf2nes`)  
**Base documental consultada:** `main` / `9ba9b88`  
**Escopo:** Etapa 3 — tornar Ken jogável; não implementar outros personagens.

## 1. Objetivo

Integrar Ken como segundo lutador jogável no SF2 NES, reutilizando o motor comum e os recursos de Ken já presentes no cartucho. A entrega deve permitir selecioná-lo e concluir uma luta normal, com animações, ataques, colisões e transições de round coerentes com o funcionamento existente do Ryu.

Não se exige igualdade de tamanho, bytes ou hash com a ROM original. O conteúdo do jogo pode crescer; a ROM original permanece apenas como referência histórica, não como oráculo de build ou critério de aceite.

## 2. Fontes de verdade e limites

Antes de alterar fontes gerados ou dados do personagem, consulte, nesta ordem prática:

- `docs/ROTEIRO.md` — plano e dados preliminares da Etapa 3;
- `docs/ARQUITETURA.md` — bancos, motor e tabelas do elenco;
- `docs/FORMATOS.md` — ficha, estados, quadros, metasprites, colisão e golpes;
- `annotations/sf2ne.ann`, `Makefile`, `sf2ne.cfg` e fontes em `src/` — fluxo real de geração, montagem e ligação.

Quando a documentação divergir do código/anotações atuais, registre a divergência e atualize a documentação pertinente no mesmo conjunto de mudanças. Não copie código ou dados de outros ports. Use referências externas somente para esclarecer comportamento; a implementação deve seguir os formatos e o motor deste projeto.

### Dentro do escopo

- Dados de estados/transições necessários para Ken.
- Conexão de Ken à ficha, seleção e carregamento do lutador.
- Reutilização dos gráficos já existentes de Ken no banco `$04` e dos recursos de seleção já existentes.
- Compatibilidade com o motor comum de movimento, ataque, defesa, dano, animação e round.
- Ajustes necessários ao build para produzir a nova ROM sem exigir igualdade com a ROM original.
- Atualização da documentação de arquitetura/roteiro e instruções de build.

### Fora do escopo

- Implementar Chun-Li, Guile ou qualquer outro personagem incompleto.
- Criar um novo motor de luta, redesenhar a tela de seleção ou refazer o sistema de comandos.
- Implementar IA própria de Ken nesta entrega. No cenário de um jogador, o oponente CPU continua sendo Ryu; não encaminhe acidentalmente um CPU para dados de IA inexistentes de Ken.
- Criar testes automatizados, scripts de regressão, infraestrutura de testes ou gates de CI. **Não há testes automatizados neste marco.**
- Ajustar balanceamento para equivalência com arcade. Como ponto inicial, use os parâmetros comuns existentes do Ryu, salvo quando os dados de Ken no próprio projeto indiquem uma diferença necessária; registre quaisquer valores provisórios.

## 3. Fatos atuais relevantes

- O motor carrega uma ficha indexada por `FighterChar` no banco `$3C`; a coluna `0` (Ryu) é a única ficha de luta preenchida.
- A coluna `1` já corresponde a Ken. `CharFrameBankTbl[1]` aponta para `$04`; o banco `$04` contém cerca de 4,3 KB de recursos de Ken, incluindo frames não conectados ao motor e retrato.
- `CharStateBankTbl[1]` ainda é `$00` (placeholder). A documentação propõe o banco `$05`, mapeado na janela `$A000`, para os dados de estados de Ken.
- `D3C_80DC[1]` já contém `$04`; confirme no código e nos dados de quadros se esse valor é de fato a origem adequada das caixas de colisão de Ken antes de depender dele.
- A ficha contém 23 tabelas de 10 posições: 10 pares de ponteiros (bytes baixo/alto) e 3 tabelas de seleção de banco. O carregador está em `FighterLoadChar` (`3B:E000`). Há uma particularidade documentada: o byte alto do primeiro ponteiro é lido sem índice; isso pressupõe que todos os bancos de estados estejam mapeados em `$A000` e que o byte alto seja `$A0`.
- `CharNameTbl`, retrato, país/voz de país e frases de vitória já têm entradas para Ken. Reutilize-as; não crie conteúdo duplicado.
- `AiCharRoutine` só tem implementação para Ryu. Não declare a IA de Ken suportada nesta entrega.
- `make` atualmente passa por `verify`, que compara o arquivo montado byte a byte com `rom/sf2ne_demo.nes` e exige o SHA-1 histórico. Essa regra é incompatível com a nova direção do projeto e precisa deixar de ser requisito do build principal.

Esses fatos são pontos de partida para a implementação, não substituem a conferência das rotinas, endereços e assets no checkout de trabalho.

## 4. Requisitos funcionais

### RF-1 — Seleção e carregamento

- Ken deve ser selecionável como lutador humano no fluxo existente, usando o ID de personagem `1`.
- O carregador deve obter para Ken todos os ponteiros/tabelas exigidos pelo motor; nenhum ponteiro de luta requerido pode permanecer `$0000` ou herdar acidentalmente a coluna de Ryu.
- Deve funcionar para o slot P1 e para o slot P2 quando este estiver configurado como humano pelo modo versus já existente no projeto. No modo de um jogador, o oponente CPU permanece Ryu.
- A seleção de Ken não pode tornar selecionáveis como lutadores jogáveis outros personagens sem ficha implementada. Se a navegação atual permitir chegar a eles, aplique somente a proteção mínima necessária para impedir carregar dados vazios; não implemente os demais personagens.

### RF-2 — Gráficos e apresentação

- A seleção deve exibir o nome e retrato já existentes de Ken.
- Em luta, cada estado/quadro de Ken deve apontar para metasprites válidos dos assets já existentes no banco `$04`, usando as páginas CHR e paleta corretas.
- Não assuma que a ordem ou os offsets dos quadros de Ken são iguais aos de Ryu. Faça um inventário de estados/quadros necessários e mapeie cada referência aos recursos de Ken após inspecionar os registros reais.
- Não deve haver tiles/paletas incorretos, sprites corrompidos ou leituras fora dos dados do banco durante animações ou espelhamento.

### RF-3 — Conjunto de luta

Ken deve completar um round usando as regras e os controles já existentes. No mínimo, cobrir o conjunto de comportamento suportado pelo Ryu e necessário ao fluxo de jogo:

- neutro, virar, caminhar para frente/trás, agachar e saltar;
- ataques normais disponíveis pelo esquema atual de botões, em pé, agachado e no ar quando esses estados existirem no conjunto-base;
- guarda, reação a dano, hit-freeze/knockback, queda, derrota/KO e retorno ao fluxo de round;
- golpes especiais correspondentes aos movimentos que o reconhecedor do projeto já suporta para Ryu: Hadouken, Shoryuken e Tatsumaki. Reaproveite os comandos e a lógica comum do motor; associe transições e quadros corretos de Ken.

Use `docs/FORMATOS.md` como referência para estados, encadeamento de quadros, classes, efeitos, caixas de ataque/corpo e contagem de acertos. Os dados devem resultar em colisões compatíveis com os quadros visuais; não basta trocar o banco de sprites mantendo caixas de Ryu que claramente não correspondam à pose de Ken.

### RF-4 — Áudio e conclusão

- Use as entradas existentes de Ken em `CountryVoiceTbl` e `FighterVoiceTbl` quando compatíveis com os eventos do motor. Não invente índices de amostras DPCM.
- Nome, voz e frase final existentes devem continuar indexados por Ken. Não é requisito criar frase nova nem novas amostras.
- A luta deve poder avançar por vitória/derrota e transições normais sem travar nem entrar em tabelas não implementadas.

## 5. Requisitos de dados e implementação

1. **Auditar os assets antes de modelar estados.** Gere/consulte os PNGs exportados pelo fluxo `make assets`, localize os frames de Ken nas páginas CHR e catalogue quais poses cobrem os estados herdados do Ryu. Registre gaps reais; não suponha que todos os movimentos tenham animação dedicada.
2. **Criar os dados de estados no banco `$05` (`$A000`–`$BFFF`)**, começando pela estrutura de Ryu como referência. O banco deve ser relocável e os rótulos devem ser simbólicos; não copie words/endereço absolutos do banco `$01` sem remapeamento.
3. **Reaproveitar o motor, não duplicar rotinas comuns.** Estados de Ken devem continuar usando o contrato do motor: cabeçalho de estado de 7 bytes, quadros de 14 bytes (16 nos casos com laço), transições/condições e efeitos definidos em `docs/FORMATOS.md`.
4. **Preencher a coluna 1 da ficha `$3C`** para os ponteiros requeridos pelo carregador (`$8000`–`$80BE`) e revisar as três tabelas de bancos (`CharStateBankTbl`, `CharFrameBankTbl`, `$80DC`). Reutilize uma tabela comum de comandos apenas após confirmar que os índices e efeitos correspondem; crie uma tabela própria de transições de Ken quando os estados de destino forem específicos.
5. **Ligar a configuração do banco**: `CharStateBankTbl[1]` deve selecionar `$05`; os frames devem usar `$04`; a fonte das caixas de colisão deve ser verificada, não presumida.
6. **Anotar os dados estruturais** com a diretiva `statebank` de `annotations/sf2ne.ann`, incluindo faixa de estados/quadros correta, e nomes/rótulos úteis. Seguir o fluxo do projeto para fontes geradas: editar anotações/entradas-fonte apropriadas e regenerar `src/`; não editar manualmente arquivos marcados como gerados se a fonte de verdade for a anotação.
7. **Não acrescentar IA de Ken por conveniência.** Se os fluxos atuais puderem atribuir Ken à CPU, restrinja ou redirecione essa seleção de modo mínimo e documentado, mantendo a CPU em Ryu nesta entrega.
8. **Build principal:** o alvo canônico deve montar e entregar a ROM modificada sem comparar bytes/hash com a demo. Pode-se manter uma verificação histórica separada, explicitamente opcional e não usada como gate da ROM nova. Não apagar a ROM original nem sua identificação histórica apenas para fazer o build passar.
9. **Expansão:** não preservar tamanho ou quantidade de bytes do original. Reutilize bancos livres quando conveniente; se a ROM precisar de mais espaço, ajuste de forma coerente configuração de linkedição, cabeçalho NES/MMC5, contagem de bancos e documentação. O limite deve ser o formato/hardware e o build funcional, não a paridade com o tamanho original.

## 6. Sequência de trabalho

| Fase | Trabalho | Saída verificável |
|---|---|---|
| 1. Inventário | Mapear frames/metasprites de Ken, paleta, colisões, vozes e gaps frente ao conjunto de estados do Ryu. | Nota curta no PR/relatório com referências a bancos/rótulos e gaps. |
| 2. Estado-base | Criar banco de estados relocável de Ken com os estados comuns necessários; manter rotinas do motor compartilhadas. | Dados identificados por labels e diretiva `statebank`. |
| 3. Ficha | Preencher as tabelas/ponteiros da coluna 1 e conectar banco de estados, frames, colisões, especiais e voz. | Carregador resolve a ficha de Ken sem ponteiros vazios. |
| 4. Seleção | Garantir que o humano possa escolher Ken nos slots suportados; impedir que o fluxo encaminhe CPU para IA ausente. | Caminho de seleção documentado e seguro para Ken vs Ryu. |
| 5. Build | Ajustar alvo principal para produzir ROM modificada; remover a igualdade com original como condição de sucesso. | ROM montada + mapa/labels de linkedição, se gerados pelo projeto. |
| 6. Documentação e entrega | Sincronizar arquitetura, formatos, roteiro e instruções de build. | Estado atual, limitações e instruções de uso claros. |

## 7. Aceite manual (sem testes automatizados)

Não criar nem executar suítes, scripts de regressão, A/B automatizado ou gates de teste neste marco. O build/assembler/linker continua necessário para produzir a ROM — isso não é um teste automatizado.

O aceite de jogabilidade é manual em Mesen e deve ser reportado como **não executado**, **com falha** ou **aprovado**, sem inferir aprovação a partir de compilação. Lista para a sessão manual:

- iniciar a ROM nova e chegar à seleção; escolher Ken;
- confirmar nome/retrato e começar luta contra Ryu CPU;
- percorrer movimento, defesa, ataques normais e os três especiais com os comandos atuais;
- confirmar visuais, colisões/acertos, dano/reação e funcionamento de um round até o encerramento;
- repetir a escolha de Ken no slot P2 se o build incluir o modo versus humano;
- confirmar que não há crash, tela travada, sprite corrompido ou uso acidental de ficha/IA vazia.

Se o Engineer não executar o aceite manual, entregar a ROM e instruções para o usuário validar. Como evidência, preferir vídeo curto e/ou filme reproduzível `.mmo` do Mesen iniciado antes do problema; usar Trace Logger somente para uma janela de execução específica quando necessário. Registrar a versão do Mesen, configuração/flags de build e hash da ROM entregue para identificar o artefato — esse hash é metadado, não exigência de igualdade com o original.

## 8. Critérios de conclusão

- [ ] Build canônico produz a ROM modificada sem falhar por diferença em relação à demo original.
- [ ] Ken está ligado às tabelas de dados e é selecionável/controlável nos slots humanos previstos.
- [ ] Os estados necessários do conjunto de luta funcionam com sprites de Ken, comandos, colisões e transições válidos.
- [ ] O fluxo CPU permanece seguro usando Ryu; não há alegação de IA de Ken.
- [ ] Nenhum outro lutador é declarado implementado.
- [ ] Não foram adicionados testes automatizados; status do aceite manual está explícito.
- [ ] README/roteiro/arquitetura/formato e instrução de build descrevem o estado real, limitações, como montar e onde encontrar a ROM.
- [ ] Entrega inclui caminhos dos arquivos tocados, comando de build, configuração usada, caminho da ROM e seu hash para identificação.

## 9. Riscos e decisões de implementação a registrar

| Risco | Tratamento esperado |
|---|---|
| A ordem/layout dos frames de Ken difere de Ryu. | Fazer mapa explícito de estados para recursos de Ken; não usar offsets presumidos. |
| Quadros de Ken não trazem caixas equivalentes aos estados herdados. | Reutilizar/adaptar caixas do próprio banco de Ken se existirem; se for preciso desenhar/substituir dados, registrar quais poses ainda são provisórias. |
| Pointers internos continuam apontando para o banco `$01`. | Relocar e revisar todas as words/endereços; organizar estado de Ken em labels no banco `$05`. |
| Alguma tabela do personagem fica sem ponteiro. | Conferir as 10 tabelas de ponteiros e as 3 de bancos antes de declarar a ficha completa. |
| Build continua preso ao hash original ou ao layout fixo do ROM. | Corrigir o fluxo principal e atualizar header/configuração de bancos; manter comparação histórica somente separada e opcional. |
| Assets/vozes existentes não cobrem um evento necessário. | Não inventar amostras ou dados; documentar o gap e pedir decisão antes de criar conteúdo fora do escopo. |

## 10. Inspiração documental aplicada

Foram consultados os cinco repositórios indicados: [dargent](https://github.com/daniel-castilho/dargent), [spotpobre](https://github.com/daniel-castilho/spotpobre), [timao-flix](https://github.com/daniel-castilho/timao-flix), [tycoma](https://github.com/daniel-castilho/tycoma) e [url-shortener-service](https://github.com/daniel-castilho/url-shortener-service).

A especificação adapta práticas úteis observadas nesses projetos: fontes de verdade explícitas, regras/limites não negociáveis, separação entre escopo e não-escopo, requisitos rastreáveis, fases com saídas verificáveis, riscos/pendências visíveis, sincronização de documentação e definição de conclusão. Foram descartadas instruções específicas de Java/Spring/React, arquitetura web, deploy, segurança de serviços e pipelines de testes, por não se aplicarem ao cartucho NES e à decisão atual de não ter testes automatizados.
