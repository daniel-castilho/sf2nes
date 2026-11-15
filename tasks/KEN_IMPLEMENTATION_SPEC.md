# Especificação de implementação — Ken como segundo lutador

**Status:** proposta pronta para implementação, com parâmetros arcade secundários ainda candidatos; consultar §3.1 e não declarar valores como medidos na placa.  
**Projeto:** Street Fighter II NE (`daniel-castilho/sf2nes`)  
**Base documental consultada:** `main` / `9ba9b88`  
**Referência comportamental:** *Street Fighter II: The World Warrior*, World 910522 (`sf2`); dados publicados abaixo são candidatos de fontes secundárias, não medições próprias da placa.  
**Última revalidação documental:** 2026-11-10.  
**Escopo:** Etapa 3 — tornar Ken jogável como humano ID `1`; não implementar outros personagens.

## 1. Objetivo

Integrar Ken como segundo lutador humano jogável no SF2 NES, ID `1`, reutilizando o motor comum e os recursos de Ken já presentes no cartucho. A entrega deve permitir selecioná-lo e concluir uma luta normal, usando Ryu como referência estrutural do motor, mas preservando os comportamentos de Ken do *World Warrior* identificados em §3.1 (em vez de pressupor equivalência total de quadros, caixas ou resultado de golpes).

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
- Exigir paridade numérica perfeita de balanceamento com arcade. Use dados públicos versionados de Ken como candidatos antes de recorrer aos parâmetros do Ryu; reutilização do Ryu é apenas fallback estrutural/técnico, e todo valor não medido deve ser marcado como provisório. Não simplificar as diferenças de Ken identificadas em §3.1 para uma troca de paleta.

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

### 3.1 Auditoria comportamental da referência World 910522

O repertório e as distinções abaixo delimitam o que significa aproximar Ken do arcade. A tabela triangula fontes comunitárias versionadas; não declara que houve teste de input na ROM. Os números de frames/dano permanecem candidatos, não valores finais de balanceamento NES.

| Aspecto | Evidência secundária para *World Warrior* | Consequência para o requisito |
|---|---|---|
| Especiais base | Hadouken, Shoryuken e Tatsumaki Senpukyaku aparecem nas listas japonesas versionadas e na tabela SuperCombo WW. | Manter esses três como conjunto de especiais; não acrescentar air Tatsumaki, Shoryureppa, ou técnicas de chute das revisões posteriores. |
| Normais característicos | SuperCombo WW lista Axe Kick como HK de perto e Drop Knee como LK no ar. | RF-3 deve contabilizar a seleção close/far e essas variantes no inventário normal; não tratá-las como especiais nem pressupor que trocar sprites do Ryu produza a pose/caixa correta. Fonte secundária, confirmar vínculo com o recurso real de Ken. |
| Agarrões terrestres | Comandos versionados: perto + frente/trás + MP/HP para agarrão de braço/ombro; perto + frente/trás + MK/HK para o agarrão de perna. A página japonesa chama-os 背負い投げ (Seoi Nage) e 地獄車 (Jigoku Guruma); SuperCombo usa Seoi Nage e Tomoe Nage; FAQs em inglês usam Arm/Shoulder Throw e Back Roll. | São dois movimentos funcionais obrigatórios, não apenas “throw” genérico. Preservar distância de captura, trajetória/queda, dano único e diferenças de deslocamento. Para o segundo, registrar os nomes como aliases divergentes e especificar pelo comando/resultado até resolver a nomenclatura da revisão. Não confundir alcance de captura com distância lançada. |
| Diferença no kick throw | Uma página de matchup SuperCombo descreve o kick throw de Ken como vantagem sobre Ryu; fonte comunitária o descreve como arremesso mais distante. Não há medida comum de deslocamento na referência consultada. | Não reutilizar automaticamente o endpoint/knockback do kick throw do Ryu. A direção qualitativa “lança mais longe” é hipótese de comportamento a verificar; não fixar pixels ou frames. |
| Tatsumaki — força e multi-hit | SuperCombo WW lista 1 acerto para Short, 2 para Forward e 3 para Roundhouse; também publica startup/duração/dano candidatos. Outras fontes generalistas dizem que Ryu e Ken ainda eram quase clones no World Warrior e que a divergência forte de multi-hit se consolidou em revisões posteriores. | Manter o número de hits como diferença específica por força a conferir. O NES só expõe classes fraca/forte de soco/chute: decidir/documentar o mapeamento de duas forças para os níveis arcade disponíveis, sem inventar um botão médio; não declarar igualdade integral de três níveis. Não copiar o perfil de multi-hit do Ryu sem justificar a adaptação. |
| Shoryuken | SuperCombo WW assinala maior alcance horizontal que o de Ryu e publica contagens/dano por força; a fama do punho flamejante é atribuída por fontes históricas a Super Street Fighter II, não ao World Warrior. | Preservar como hipótese a possível diferença de alcance por força; manter Shoryuken **sem chama/efeito de fogo** no alvo World 910522. Métricas numéricas não são critério obrigatório nesta etapa. |
| Hadouken | O comando é o mesmo da família Ryu/Ken; SuperCombo WW e o FAQ de 1999 descrevem variantes de força, e o FAQ afirma que socos mais fortes aceleram o projétil. | Os comandos NES já têm duas classes fraca/forte; a velocidade por classe deve ser associada explicitamente, mas não copiada de Ryu nem quantificada sem validação/versionamento. |
| Comandos e médio arcade | O arcade possui LP/MP/HP e LK/MK/HK; o motor NES documenta quatro classes `InputAttack`: soco fraco/forte e chute fraco/forte. | Usar a interface NES existente e mapear duas forças, preservando as diferenças de resultado relevantes. A força média arcade não existe como classe separada no esquema atual; não alterar controles nem declarar seis forças suportadas sem decisão explícita. |
| Revisões posteriores | Páginas brasileiras gerais misturam air Hurricane Kick, especiais adicionais e Super; fontes de SFII Turbo/CE/Super não são prova do World 910522. | Excluir Air Tatsumaki, Shoryureppa, técnicas de chute avançadas e chama do Shoryuken, a menos que haja nova decisão de escopo e confirmação específica de versão. |

**Conclusão de escopo arcade:** Ken se parece muito com Ryu no *World Warrior*, mas não é seguro traduzir “clone” como “copiar todos os estados, caixas e parâmetros”. Os pontos de atenção sustentados pelo material consultado são os dois agarrões (especialmente o resultado do kick throw), close HK/Axe Kick, aerial LK/Drop Knee, a possível diferença de alcance do Shoryuken e as contagens por força do Tatsumaki. Valores publicados podem guiar uma validação posterior, mas esta especificação não afirma que foram medidos na placa World 910522.

### 3.2 Valores públicos de referência — candidatos, não oráculo

| Grupo | Valor publicado | Uso permitido nesta especificação |
|---|---|---|
| Normais | SuperCombo WW lista como exemplos: standing LP `6`, MP `16`, HP `26`, LK `8`, MK `16`, HK `22`; close HK aparece `24,6` (componentes apresentados pela wiki). | Ilustra que não se deve reduzir ataques a uma tabela comum por força nem copiar danos de Ryu. Não converter diretamente para HP/frames NES; consultar os dados completos da wiki apenas para planejar a validação. |
| Agarrões | SuperCombo WW: dano `32`, duração `130`, stun `7–13`, timer `100`, alcance axial `48`, vantagem de alcance `19`. T.Akiba/NKI: linha “Ken toss” para WW `38` normal / `39` quando atrás, em dados de *Capcom Generations 5* (PlayStation). | Valores de fontes/plataformas diferentes não conciliados. Não escolher um número final nem converter alcance para pixels NES. A eventual distância de lançamento do kick throw é uma propriedade distinta do alcance de captura. |
| Hadouken | SuperCombo WW: dano `12`, stun `13–19`, timer `120` nas três forças; GameFAQs 1999 diz que força maior acelera o projétil. | Números e diferenças de velocidade são candidatos secundários; verificar se são pertinentes ao alvo e à escala NES antes de usar. |
| Shoryuken | SuperCombo WW publica a sequência de dano `32/32,16` e vantagens `-11/-22/-33` por força; o formato resumido não explica de modo suficiente a interpretação dos componentes multi-hit. | Conservar apenas como pista para observação, sem inferir quantidade de hits, dano final ou frames de recuperação. A ausência de chama em WW é a restrição de versão mais clara. |
| Tatsumaki | SuperCombo WW discrimina `1/2/3` acertos para Short/Forward/Roundhouse. As tabelas de Hitboxes são dados comunitários e podem variar por leitura/revisão. | Priorizar a diferença qualitativa por força como candidato. O NES deve mapear as classes disponíveis e declarar a força média não representada; não atribuir dano NES com base nesta contagem isolada. |

Não replicar extensas tabelas, imagens, hitboxes ou ativos de sites; registrar apenas os requisitos comportamentais e referências para conferência, respeitando licenças. A validação quantitativa pertence à etapa de implementação e não foi executada nesta revalidação documental.

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

Ken deve completar um round usando as regras e controles existentes. Cobrir o conjunto-base de luta e preservar as diferenças de referência conhecidas:

- neutro, virar, caminhar para frente/trás, agachar, saltos neutro/diagonal e pouso;
- ataques normais do esquema de botões em pé, agachado e no ar, com seleção close/far quando aplicável; incluir close HK (Axe Kick, fonte secundária WW) e aerial LK (Drop Knee, fonte secundária WW) no inventário de estados/animações;
- guarda alta/baixa, reação de dano, hit-freeze/knockback, queda, KO e retorno ao fluxo de round;
- os dois agarrões terrestres: perto + frente/trás + soco forte (a adaptação NES da família arcade MP/HP) e perto + frente/trás + chute forte (MK/HK); garantir captura elegível, saída/queda própria e dano uma única vez. Não herdar automaticamente o deslocamento do kick throw de Ryu;
- Hadouken, Shoryuken e Tatsumaki com os comandos já suportados pelo motor; associar transições aos estados próprios de Ken. O arcade tem três forças e o NES duas classes por família: mapear fraco/forte sem alegar variante média. Preservar velocidades distintas do Hadouken como hipótese publicada, tratar a maior extensão do Shoryuken e os hits do Tatsumaki como diferenças a conferir. World 910522 não recebe chama de Shoryuken nem Tatsumaki aéreo das versões posteriores.

Reaproveitar lógica comum somente após conferir a semântica dos comandos, os destinos de transição e os efeitos de Ken; o uso do banco/tabelas de Ryu como ponto de partida não autoriza assumir equivalência de frames, hitboxes ou resultados.

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
| 1. Inventário | Mapear frames/metasprites de Ken, paleta, colisões, vozes e gaps frente ao conjunto de luta; registrar Axe Kick, Drop Knee, close/far, os dois agarrões e as diferenças candidatas de Hadouken/Shoryuken/Tatsumaki em §3.1. | Nota de implementação com banco/labels, comportamento de origem, mapeamento ao NES e gaps. |
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
- percorrer movimento, defesa, ataques normais, close HK/Axe Kick, aerial LK/Drop Knee e os três especiais com os comandos atuais;
- executar ambos os agarrões terrestres e conferir elegibilidade, orientação, animação da vítima, queda e aplicação única de dano; observar se o kick throw desloca a vítima diferentemente do Ryu, sem exigir distância numérica não validada;
- verificar variantes fraca/forte nos especiais, velocidade/resultados, e documentar que o NES não possui classe média; confirmar que Shoryuken não usa efeito de chama e que não existe comando de Tatsumaki aéreo para World 910522;
- confirmar visuais, colisões/acertos, dano/reação e funcionamento de um round até o encerramento;
- repetir a escolha de Ken no slot P2 se o build incluir o modo versus humano;
- confirmar que não há crash, tela travada, sprite corrompido ou uso acidental de ficha/IA vazia.

Se o Engineer não executar o aceite manual, entregar a ROM e instruções para o usuário validar. Como evidência, preferir vídeo curto e/ou filme reproduzível `.mmo` do Mesen iniciado antes do problema; usar Trace Logger somente para uma janela de execução específica quando necessário. Registrar a versão do Mesen, configuração/flags de build e hash da ROM entregue para identificar o artefato — esse hash é metadado, não exigência de igualdade com o original.

## 8. Critérios de conclusão

- [ ] Build canônico produz a ROM modificada sem falhar por diferença em relação à demo original.
- [ ] Ken está ligado às tabelas de dados e é selecionável/controlável nos slots humanos previstos.
- [ ] Os estados necessários do conjunto de luta funcionam com sprites de Ken, comandos, colisões e transições válidos; incluem dois agarrões terrestres, Axe Kick/Drop Knee e adaptação documentada das variantes de força arcade ao NES.
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
| Reuso integral de Ryu apaga diferenças de Ken em World Warrior. | Usar Ryu como referência estrutural apenas; revisar kick throw, Axe Kick, Drop Knee e os candidatos de especial de §3.1. |
| Nomes/fontes discordam sobre o kick throw de Ken. | Priorizar o comportamento observável do comando F/B + chute forte e resultado da captura; documentar aliases (Jigoku Guruma / Back Roll / Tomoe Nage) sem transformar a divergência editorial em movimentos extras. |
| Três forças arcade não cabem nas quatro classes do input NES. | Mapear fraco/forte por família e declarar a força média como não representada; não alterar o esquema de controle nesta entrega sem decisão explícita. |
| Dados públicos secundários são confundidos com medição de World 910522. | Manter números de frame/dano/alcance como candidatos e distingui-los de evidência da placa; aceite manual é tarefa futura do implementador, não evidência prévia da especificação. |

## 10. Inspiração documental aplicada

Foram consultados os cinco repositórios indicados: [dargent](https://github.com/daniel-castilho/dargent), [spotpobre](https://github.com/daniel-castilho/spotpobre), [timao-flix](https://github.com/daniel-castilho/timao-flix), [tycoma](https://github.com/daniel-castilho/tycoma) e [url-shortener-service](https://github.com/daniel-castilho/url-shortener-service).

A especificação adapta práticas úteis observadas nesses projetos: fontes de verdade explícitas, regras/limites não negociáveis, separação entre escopo e não-escopo, requisitos rastreáveis, fases com saídas verificáveis, riscos/pendências visíveis, sincronização de documentação e definição de conclusão. Foram descartadas instruções específicas de Java/Spring/React, arquitetura web, deploy, segurança de serviços e pipelines de testes, por não se aplicarem ao cartucho NES e à decisão atual de não ter testes automatizados.

## 11. Referências comportamentais consultadas na revalidação

- [SuperCombo Wiki — Ken, The World Warrior](https://wiki.supercombo.gg/w/Street_Fighter_2:_The_World_Warrior/Ken): repertório versionado, nomes de golpes, tabelas de dano/frames, agarrões e notas sobre variações por força. Fonte de comunidade; seus números e hitboxes são candidatos, não medição independente confirmada da placa World 910522.
- [SuperCombo Wiki — Ryu, The World Warrior](https://wiki.supercombo.gg/w/Street_Fighter_2:_The_World_Warrior/Ryu): comparação secundária de Tatsumaki e matchup; útil para detectar quando a especificação de Ken herda valores do Ryu sem justificação.
- [GameFAQs — Ryu/Ken Guide (ARC), RCarlos (1999)](https://gamefaqs.gamespot.com/arcade/583626-street-fighter-ii/faqs/848): identifica versões arcade originais e descreve throws/especiais; afirma que Ryu e Ken são iguais em todos os aspectos, generalização que não deve substituir observações específicas de throws/alcance. Relato comunitário antigo, sem protocolo reproduzível.
- [homepage3gore — Ken, ストII](https://homepage3gore.game.coocan.jp/st2/ken_1.html): lista japonesa específica para SFII com Seoi Nage e Jigoku Guruma, comandos dos dois throws e os três especiais base. Fonte comunitária concisa; não oferece frames/danos.
- [T.Akiba’s SF2 Data, tradução NKI](https://zachd.com/nki/ST/data.html): inclui dados comparativos de throws/dano; a própria introdução informa que WW/CE/HF foram testados em *Capcom Generations 5* (PlayStation), não diretamente na placa World 910522. Usar somente como candidato, especialmente onde diverge da SuperCombo.
- [Jogo de Luta — Ken em Street Fighter 2](https://jogodeluta.com.br/street-fighter/street-fighter-2/ken): fonte brasileira de título/versionamento amplo; a página lista Air Hurricane Kick e Shoryu Reppa, sem separar com clareza World Warrior das revisões posteriores. Não usar esses movimentos para ampliar o conjunto de 910522.
- [Critical Hits — especiais de Street Fighter 2](https://criticalhits.com.br/games/street-fighter-2-todos-os-golpes-especiais/): lista brasileira não segmentada por revisão e inclui técnicas extras/super; útil apenas para contexto em português, não como prova de World Warrior. A página separada de Champion Edition também é excluída como prova do alvo.

Nenhuma referência desta lista concede licença para incorporar imagens, dados, código ou outros ativos de terceiros. Esta revalidação incorporou somente requisitos e fatos comportamentais parafraseados, com limitações indicadas; não alterou fontes, assets ou ROM.
