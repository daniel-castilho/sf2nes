# Schema de autoria — estados e quadros de animação (Fase 2)

**Status:** PROPOSTO (parte da decisão de formato; aguarda aprovação do Mantenedor)  
**Origem:** `tasks/PHASE_2_STATE_DATA_FORMAT_SPEC.md` (Fase 2)  
**Tipo:** documento de design conceitual — não é código, não é conversor, não é dados do jogo  
**Pré-requisitos confirmados:** Fase 0 e Fase 1 concluídas

---

## 1. Objetivo do schema

Definir uma gramática conceitual, independente de sintaxe (TOML/YAML/JSON), que permita serializar **sem perda** o conjunto atual de estados e quadros de animação do Ryu, incluindo registros não alcançáveis, valores desconhecidos, sentinelas, laços e referências simbólicas.

O schema é o contrato entre a fonte de autoria e a futura ferramenta de geração de assembly. Ele não impõe endereços, não normaliza dados silenciosamente e não exige banco específico para personagens futuros.

---

## 2. Unidades de medida e limites conhecidos

| Unidade | Valor / limite | Fonte |
|---|---|---|
| Duração de quadro | 1–100 quadros de vídeo | `docs/FORMATOS.md` §6 |
| Acertos do golpe (estado) | `zp_28`; contagem de caixas de ataque | `docs/FORMATOS.md` §3 |
| Classe do estado | byte; 3 bits baixos = postura | `docs/FORMATOS.md` §3 |
| Efeito (tipo) | `$0B` projetil, `$20` som, `$8x`/`$Cx` reação | `docs/FORMATOS.md` §7 |
| Modo de movimento | 0/1 absoluta, 2/3 aceleração, 4/5 subpixel | `docs/FORMATOS.md` §8 |
| VelX / VelY | com sinal, interpretados conforme modo | `docs/FORMATOS.md` §8 |
| Repetições de laço | `zp_44`; 0 = sem laço | `docs/FORMATOS.md` §6 |
| Sentinela de fim de quadro | ponteiro 0 = fim do estado | `docs/FORMATOS.md` §6 |
| Tamanho do quadro | 14 bytes normal; 16 se houver laço | `docs/FORMATOS.md` §6 |
| Cabeçalho de estado | 7 bytes | `docs/FORMATOS.md` §3 |
| Condições de transição | 12 (`0`–`$0B`); `≥$80`/`$FF` = incondicional | `docs/FORMATOS.md` §4 |

---

## 3. Unidades de autoria

### 3.1 Ficha de personagem (metadados)

Conjunto de referências que ligam o lutador às tabelas de estados por direção, botões, especiais, guarda/defesa, reações a dano, agarrões e IA.

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id_personagem | símbolo/inteiro | sim | identificador do lutador (0 = Ryu, 1 = Ken, …) |
| banco_estados | símbolo/inteiro | sim | banco dos estados (janela `$A000`) |
| banco_frames | símbolo/inteiro | sim | banco dos frames/metasprites (janela `$8000`) |
| banco_colisao | símbolo/inteiro | não | fonte de caixas de colisão (se diferente do de frames) |
| tabela_direcao | referência | não | ponteiros de estados por direção |
| tabela_botao | referência | não | ponteiros de estados por botão |
| tabela_especial | referência | não | ponteiros de estados dos golpes especiais |
| tabela_guarda | referência | não | ponteiros de defesa/reação ao golpe |
| tabela_dano_pe | referência | não | reação de dano em pé |
| tabela_dano_agachado | referência | não | reação de dano agachado |
| tabela_dano_neutro | referência | não | reação de dano neutra |
| tabela_agarrao | referência | não | agarrões |
| roteiro_ia | referência | não | tabela de roteiros de IA do personagem |
| lista_especiais | referência | não | lista de especiais do reconhecedor de comandos |

> Observação: a ficha é metadados de ligação. O conteúdo real dos estados/quadros vive nos registros abaixo.

### 3.2 Estado

Um estado é um cabeçalho seguido de um ou mais quadros de animação.

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id_estado | símbolo | sim | nome simbólico do estado (ex.: `EstadoParado`) |
| condicao_entrada | símbolo ou inteiro bruto | sim | critério de entrada (condição de transição; `0`–`$0B`, `≥$80` incondicional) |
| proxima_alternativa | referência a estado ou nulo | não | vínculo para a próxima alternativa na lista encadeada de transições |
| cadeia_natural | referência a estado ou nulo | não | vínculo do estado seguinte quando este termina (`StateAdvance`) |
| classe | símbolo ou inteiro bruto | sim | classe do estado (byte de estado → `FighterState`) |
| acertos_golpe | inteiro ou inteiro bruto | sim | contagem de acertos do golpe (`AttackHitsLeft`) |
| quadro_inicial | referência a quadro | sim | primeiro quadro de animação (cabeçalho + 7 no formato binário) |

**Regras:**
- `condicao_entrada`, `classe` e `acertos_golpe` aceitam nome simbólico quando houver definição confiável e valor numérico bruto como escape para significado incerto.
- `proxima_alternativa` e `cadeia_natural` podem ser nulos (lista termina).
- `quadro_inicial` aponta para o primeiro quadro do estado.

### 3.3 Quadro de animação

Um quadro pode ser **normal** (14 bytes) ou **com laço** (16 bytes).

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id_quadro | símbolo | sim | nome simbólico do quadro |
| duracao | inteiro | sim | duração em quadros de vídeo (1–100) |
| metasprite | referência a metasprite ou nulo | não | ponteiro para o metasprite (banco de frames) |
| colisao | referência a colisao ou nulo | não | ponteiro para caixas de colisão, ou ausente se não houver |
| efeito_parametro | inteiro ou inteiro bruto | sim | parâmetro do efeito (dano `&$1F` ou velocidade do projetil) |
| efeito_tipo | símbolo ou inteiro bruto | sim | tipo do efeito (`$0B`, `$20`, `$8x`, `$Cx`…) |
| flags | símbolo ou inteiro bruto | sim | flags do quadro (`FrameFlags`: bit 0 especial, bit 1 por botão, bit 2 direção) |
| movimento_modo | símbolo ou inteiro bruto | sim | modo de movimento (0/1, 2/3, 4/5) |
| velocidade_x | inteiro com sinal | sim | `VelX` |
| velocidade_y | inteiro com sinal | sim | `VelY` |
| repeticao | inteiro | sim | repetições do laço (`LoopRepeat`; 0 = sem laço) |
| desvio_laco | referência a quadro ou nulo | não | ponteiro do desvio; presente apenas se `repeticao != 0` |
| proximo_quadro | referência a quadro ou nulo | não | ponteiro para o quadro seguinte; nulo = fim do estado |

**Regras de tamanho variável:**
- Se `repeticao == 0`: o campo `desvio_laco` **não existe** nem é interpretado (quadro normal, 14 bytes).
- Se `repeticao != 0`: `desvio_laco` é obrigatório (quadro com laço, 16 bytes).
- `proximo_quadro == nulo` indica fim do estado (sentinela).

---

## 4. Tipos de dado

| Tipo | Valores permitidos | Notas |
|---|---|---|
| símbolo | identificador alfanumérico | rótulo de estado, quadro, metasprite, colisão, banco |
| inteiro | número inteiro, pode ter sinal | duração, velocidade, parâmetros |
| inteiro bruto | número hexadecimal ou decimal | escape para valores de significado incerto |
| símbolo ou inteiro bruto | símbolo | inteiro bruto | campos com significado condicional (condição, classe, efeito, flags, modo) |
| referência | símbolo de outro registro ou `nulo` | ponteiro entre estados/quadros/metasprites/colisões |
| nulo | `nulo` / ausente | sentinela de fim, campo omitido, ponteiro não definido |
| comentário | texto livre | procedência, confiança, hipótese, referência documental |

---

## 5. Nomes simbólicos permitidos e sua origem

| Categoria | Origem do nome | Exemplo |
|---|---|---|
| Estado | rótulo do cabeçalho de estado | `EstadoParado`, `EstadoGolpe` |
| Quadro | rótulo do quadro dentro do estado | `Quadro1`, `QuadroAtaque` |
| Metasprite | rótulo de metasprite no banco de frames | `MsParado`, `MsSoco` |
| Colisão | rótulo de caixa de colisão | `ColPe`, `ColAgachado` |
| Banco | símbolo de banco de PRG | `BancoEstadosRyu`, `BancoFramesRyu` |
| Condição | nome da condição de transição (quando conhecido) | `CondOponentePerto`, `CondNoAr` |
| Classe | nome da classe de estado (quando conhecido) | `ClaseEmPe`, `ClaseAgachado` |
| Efeito | nome do tipo de efeito (quando conhecido) | `EfeitoProjetil`, `EfeitoSom` |

> Nomes simbólicos são opcionais; todo registro pode ser referenciado por inteiro bruto se o significado ainda não for confiável.

---

## 6. Regras de referência e detecção de destino inexistente

- Toda referência (`proxima_alternativa`, `cadeia_natural`, `quadro_inicial`, `metasprite`, `colisao`, `desvio_laco`, `proximo_quadro`) deve apontar para um símbolo definido no mesmo documento de autoria ou para `nulo`.
- Referência a símbolo não definido é **erro de validação** da ferramenta futura (não é normalizado silenciosamente).
- Referências entre estados e quadros de bancos diferentes devem ser válidas dentro do escopo do personagem sendo autorizado.
- Não assumir banco específico para personagens futuros; associação banco-estado/quadro é declarada na ficha.

---

## 7. Regras de ordenação e serialização

- A mesma entrada produz assembly ordenado e reprodutível (determinismo).
- Ordem de emissão: estados na ordem declarada; quadros dentro de cada estado na ordem declarada; campos dentro de cada registro na ordem do schema.
- Sentinelas e alinhamento são de responsabilidade do assembler/linker; o schema não fixa endereços absolutos.
- Ordem de emissão não altera semântica dos dados.

---

## 8. Valores brutos para campos desconhecidos

- Campo cujo significado é hipótese ou desconhecido: usar **inteiro bruto** + comentário de procedência/confiança.
- Não forçar nome semântico para opcodes, condições, efeitos ou flags não confirmados.
- Comentários não afetam os bytes emitidos.

---

## 9. Representação de null / ausente / fim / terminador

| Conceito | Representação | Semântica |
|---|---|---|
| zero | inteiro `0` | valor numérico com significado próprio |
| ausente / null | campo omitido ou `nulo` | campo não fornecido; não é zero |
| fim | `proximo_quadro == nulo` | fim do estado |
| terminador | ponteiro nulo / sentinela explícita | fim de lista ou de cadeia |

Esses quatro conceitos são **distintos** e não equivalentes.

---

## 10. Quadro com e sem laço

| Caso | `repeticao` | `desvio_laco` | Tamanho |
|---|---|---|---|
| Sem laço | `0` | **ausente** (não emitido, não interpretado) | 14 bytes |
| Com laço | `> 0` | obrigatório (referência a quadro) | 16 bytes |

- O caso sem laço **não emite nem interpreta** campos de laço inexistentes.
- O caso com laço exige `desvio_laco` válido.

---

## 11. Comentário de procedência e confiança

- Cada registro e cada campo podem ter um comentário anexo.
- O comentário indica: evidência, hipótese, referência documental (`docs/FORMATOS.md` §X, `annotations/sf2ne.ann` linha Y).
- Comentários **não afetam os bytes emitidos**; são metadados de autoria apenas.

---

## 12. Comportamento para valores duplicados e endereços não resolvidos

| Situação | Comportamento da ferramenta futura |
|---|---|
| Label duplicado dentro de um mesmo documento | Erro de validação (não sobrescreve silenciosamente) |
| Label duplicado entre bancos diferentes | Permitido; escopo de símbolo por banco |
| Endereço não resolvido | Erro de validação; não assumir endereço |
| Valor duplicado em campos diferentes | Permitido (valores podem se repetir) |
| Campo obrigatório ausente | Erro de validação |
| Campo desconhecido no documento | Ignorado ou erro, conforme política da ferramenta (não normalizar) |

---

## 13. Compatibilidade com tamanhos e limites binários

- O schema respeita os tamanhos documentados (cabeçalho 7 bytes, quadro 14/16 bytes, duração 1–100, etc.).
- **Não corrige nem normaliza dados silenciosamente.** Se os dados atuais estiverem fora do limite documentado, a ferramenta futura deve reportar erro, não ajustar automaticamente.

---

## 14. Exemplo ilustrativo (esquemático, valores fictícios)

> Este exemplo é **apenas ilustrativo do desenho do schema**. Usa valores simbólicos/fictícios, não reproduz uma sequência real do jogo, não inclui bytecode da ROM arcade e não está pronto para montagem. Campos cujo significado depende de confirmação são marcados como inteiro bruto + comentário.

```toml
# Exemplo esquemático — NÃO é dado real do jogo
[[personagem]]
id = "ryu"
banco_estados = "BancoEstadosRyu"
banco_frames = "BancoFramesRyu"

[[personagem.estado]]
id = "estado_exemplo"
condicao_entrada = { simbolo = "CondOponentePerto", bruto = 0x02 }  # hipótese
proxima_alternativa = nulo
cadeia_natural = "estado_seguinte"
classe = { simbolo = "ClasseEmPe", bruto = 0x59 }  # confirme
acertos_golpe = 0
quadro_inicial = "q1"

[[personagem.estado.quadro]]
id = "q1"
duracao = 8
metasprite = "ms_exemplo"
colisao = nulo
efeito_parametro = { bruto = 0x00 }  # significado incerto
efeito_tipo = { simbolo = "EfeitoNenhum", bruto = 0x00 }
flags = { bruto = 0x10 }  # confirme bits
movimento_modo = { simbolo = "MovAbsoluto", bruto = 0 }
velocidade_x = 0
velocidade_y = 0
repeticao = 0
# desvio_laco ausente (sem laço)
proximo_quadro = "q2"

[[personagem.estado.quadro]]
id = "q2"
duracao = 4
metasprite = "ms_exemplo2"
colisao = nulo
efeito_parametro = { bruto = 0x00 }
efeito_tipo = { simbolo = "EfeitoNenhum", bruto = 0x00 }
flags = { bruto = 0x10 }
movimento_modo = { simbolo = "MovAbsoluto", bruto = 0 }
velocidade_x = 0
velocidade_y = 0
repeticao = 0
proximo_quadro = nulo  # fim do estado
```

---

## 15. Escopo e limitações

- O schema cobre os elementos da §5 do `tasks/PHASE_2_STATE_DATA_FORMAT_SPEC.md` (tabelas da ficha, cabeçalho de estado, quadros, dados não compreendidos, relocação).
- Não preenche a ficha do Ken nem altera tabelas existentes.
- Não acrescenta estados ou conteúdo de personagem.
- Não valida contra runtime nem gera build.

---

## 16. Arquivos relacionados

- `tasks/STATE_DATA_FORMAT_DECISION.md` — decisão e trade-offs
- `tasks/STATE_DATA_FORMAT_MIGRATION_PLAN.md` — passos futuros de implementação
- `docs/FORMATOS.md`, `docs/ARQUITETURA.md`, `docs/RAM.md` — fontes técnicas obrigatórias
- `annotations/sf2ne.ann`, `tools/disasm.py`, `src/*.s`, `Makefile`, `sf2ne.cfg` — fluxo atual (leitura apenas)
