# Estado do Projeto — linha de base da auditoria (Fase 1)

## 1. Metadados da auditoria e limitações

- **Data da auditoria:** 2026-11-15
- **Commit HEAD examinado:** `ada6c6fa5b26cb63119a0bdad8521966740dc64d` (Fase 0 concluída e aceita, pushado para `origin/main`)
- **Estado da árvore de trabalho:** limpa (não há modificações locais não commitadas; o único arquivo não rastreado é `tasks/PHASE_1_BASELINE_AUDIT_SPEC.md`, que é o arquivo de entrada desta auditoria)
- **Alterações locais preexistentes preservadas:** sim, nenhuma alteração foi descartada
- **Atividades NÃO realizadas nesta auditoria:** nenhuma montagem (`make`, `ca65`, `ld65`), nenhuma execução de ROM, nenhuma emulação (Mesen/MAME), nenhum teste, nenhum script de validação/regressão/shift/realocação, nenhuma geração de artefatos (ROM, mapa, trace, vídeo)

Este documento foi produzido exclusivamente por **inspeção estática** de arquivos-fonte e documentação. Nenhuma afirmação de "testado", "passa" ou "funciona atualmente" é feita sem evidência existente e identificável.

## 2. Resumo executivo

Fatos confirmados por inspeção estática nesta auditoria:

- O repositório contém o fonte reconstruído do demo NES *Street Fighter II NE* (mapper 5/MMC5, 512 KB PRG-ROM, 512 KB CHR-ROM).
- O fluxo de build é `annotations/sf2ne.ann` → `tools/disasm.py` (`make gen`) → `src/*.s` → `ca65`/`ld65` (`make`) → `build/sf2ne.nes`.
- O build canônico inclui o Ken jogável (P1) e diverge do ROM original; `make verify` aviso por design.
- Foram identificadas **2.145 definições de label** nos arquivos `src/bank_*.s`, gerando **2.141 nomes únicos** (4 ocorrências duplicadas de 3 nomes, sendo 1 nome duplicado dentro de um mesmo banco).
- Destes, **549 são labels semânticos** (nome atribuído, não padrão automático de endereço) e **1.592 são automáticos** (padrão `L<bb>_<aaaa>` para código e `D<bb>_<aaaa>` para dados).
- Há **322 diretivas `.global`** em `src/globals.inc` (símbolos visíveis entre bancos).
- Ocupação de bancos PRG é conhecida apenas pelos valores publicados na documentação (não revalidados nesta auditoria — nenhum build ou mapa de linker foi produzido).
- Existem scripts de validação em `tools/` e `tools/mesen/`; nenhum foi executado nesta auditoria, portanto nenhuma alegação de aprovação é feita.

Itens não confirmados (exigem build/execução/inspeção fora do escopo):

- Ocupação real de cada banco a partir de um novo mapa de linker.
- Funcionamento de qualquer script de validação (status desconhecido ou apenas histórico).
- Divergências entre documentos (registradas na seção 7, não corrigidas).

## 3. Fontes de verdade e artefatos gerados

| Área | Fonte canônica declarada | Arquivo/artefato gerado ou derivado | Método atual de atualização | Observação/risco |
|------|--------------------------|-------------------------------------|------------------------------|------------------|
| Labels, comentários, correções | `annotations/sf2ne.ann` | `src/*.s` (via `make gen`) | Edição manual do `.ann` + regeneração | O gerador sobrescreve `src/`; não editar `src/` à mão |
| Gerador | `tools/disasm.py` | `src/*.s`, `sf2ne.cfg`, `assets/chr/chr.bin`, `assets/dpcm/*.dmc` | `python3 tools/disasm.py` (`make gen`) | Lê ROM + trace + anotações |
| Configuração e build | `sf2ne.cfg`, `Makefile` | `build/sf2ne.nes`, `build/sf2ne_fixed.nes`, `prontos/*.nes` | `ca65` + `ld65` (`make`, `make fixed`, `make prontos`) | `build/` não é versionado |
| Dados/estruturas de estados e quadros | `annotations/sf2ne.ann` + `docs/FORMATOS.md` | `src/bank_01.s` (estados Ryu), `src/bank_05.s` (estados Ken, mantido à mão) | `patch`/`keepbank` nas anotações | Apenas Ryu e Ken têm conteúdo; outros 8 personagens só têm retrato/nome/frase/voz |
| Assets fonte vs `extracted/` | `assets/chr/chr.bin`, `assets/dpcm/*.dmc` | `extracted/chr/*.png`, `extracted/dpcm/*.wav` | `make assets` (`tools/extract_chr.py`, `tools/extract_dpcm.py`) | Exportação de produção de conteúdo |
| ROM de referência | `rom/sf2ne_demo.nes` | (nenhum derivado versionado além dos em `prontos/`) | SHA-1 `0bf9dc57…a9aed` declarado no `Makefile` e `docs/ARQUITETURA.md` | `make verify` compara build com o original (aviso por design) |
| ROMs de saída/versionadas | `build/sf2ne.nes` (não versionado) | `prontos/sf2ne_reset_corrigido.nes`, `prontos/sf2ne_versus.nes`, `prontos/sf2ne_golpe_forte_unico.nes`, `prontos/sf2ne_golpe_na_borda.nes` | `make prontos` | Versões históricas, sem o build canônico com o Ken |
| Scripts de trace/validação e artefatos | `tools/`, `tools/mesen/`, `trace/` | `trace/*.txt` (traces mesclados) | Execução do emulador (fora do escopo desta auditoria) | Traces já mesclados existem no repositório |

**Observação/risco:** quando documentos discordam sobre a fonte canônica, a divergência é registrada na seção 7; nenhuma nova fonte foi escolhida por inferência.

## 4. Métricas de labels

### Método reproduzível

- **Arquivos analisados:** todos os `src/bank_*.s` (26 arquivos de banco de código/dados gerados). Arquivos `.inc` (`kernel.inc`, `globals.inc`, `ram.inc`, `defs.inc`, `hw.inc`, `macros.inc`) contêm apenas diretivas `.global` e definições de RAM/hardware, não rótulos de código/dados por banco.
- **Comando/script utilizado:** inspeção textual com `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s` (linhas que começam com um rótulo seguido de `:`).
- **Padrões identificados no gerador:**
  - Código automático: `L<bb>_<aaaa>` (ex.: `L3F_E4DA`, `L00_8F46`).
  - Dados automáticos: `D<bb>_<aaaa>` (ex.: `D37_F2BB`, `D01_A4CB`).
  - Semântico: rótulo global que **não** corresponde a nenhum dos padrões automáticos acima.
- **Exclusões:** rótulos locais/temporários, rótulos anônimos, constantes e símbolos de RAM (`ram.inc`) estão fora da métrica principal de rótulos de código/dados por banco.

### Resultados por categoria

| Categoria | Nomes únicos | Observações |
|-----------|--------------|-------------|
| Total de definições de rótulo em `src/bank_*.s` | 2.145 ocorrências | Conta cada definição, incluindo duplicadas entre bancos |
| Nomes únicos globalmente | 2.141 | 4 ocorrências a menos que o total (3 nomes duplicados) |
| Automáticos de código (`L<bb>_<aaaa>`) | 379 únicos | Padrão confirmado no gerador |
| Automáticos de dados (`D<bb>_<aaaa>`) | 1.213 únicos | Padrão confirmado no gerador |
| **Semânticos (nome atribuído)** | **549 únicos** | Rótulos globais não automáticos |
| Diretivas `.global` em `src/globals.inc` | 322 únicos | Símbolos visíveis entre bancos (subconjunto dos semânticos) |

### Detalhamento por banco (nomes únicos)

| Banco | Total defs | Únicos | Auto código (L) | Auto dados (D) | Semânticos |
|-------|------------|--------|-----------------|----------------|------------|
| `$00` | 257 | 257 | 48 | 206 | 3 |
| `$01` | 305 | 305 | 0 | 304 | 1 |
| `$04` | 3 | 3 | 0 | 3 | 0 |
| `$05` | 353 | 353 | 0 | 352 | 1 |
| `$20` | 30 | 30 | 0 | 30 | 0 |
| `$29` | 103 | 103 | 0 | 103 | 0 |
| `$2D` | 70 | 70 | 0 | 70 | 0 |
| `$36` | 30 | 30 | 0 | 30 | 0 |
| `$37` | 277 | 277 | 158 | 27 | 92 |
| `$3B` | 263 | 263 | 151 | 35 | 77 |
| `$3C` | 38 | 38 | 0 | 33 | 5 |
| `$3F` | 411 | 410 | 22 | 15 | 373 |
| Outros ($02,$06,$08,$0A,$0C,$0E,$10,$12,$16,$1A,$1C,$1E,$22,$24,$26,$2A,$3A) | 5 | 5 | 0 | 5 | 0 |
| **Total** | **2.145** | **2.141** | **379** | **1.592** | **549** |

### Regras aplicadas e limitações

- O número publicado no README ("1.795 rótulos; 304 têm nome de verdade") **não foi usado** como resultado atual; as contagens acima foram recalculadas a partir dos fontes gerados.
- Não foram somadas categorias sobrepostas; o total de rótulos não é usado como medida única de qualidade.
- O rótulo `InputButtons` está duplicado dentro de `src/bank_3F.s` (2 definições, 1 nome único). Os rótulos `ResetStub` (bancos `$37`, `$3B`, `$3F`) e `RoundStart` (bancos `$3B`, `$3F`) aparecem em múltiplos bancos; contados como 1 nome único cada globalmente.
- Nenhum rótulo foi renomeado.
- Não foi criada nem modificada ferramenta permanente em `tools/` nesta fase.

## 5. Mapa de bancos e capacidade documentada

Os valores abaixo são **publicados na documentação (`docs/ARQUITETURA.md` §7), não revalidados nesta auditoria**. Nenhum build foi compilado, nenhum mapa de linker foi produzido, nenhuma ocupação foi recalculada a partir de um novo link.

| Banco | Janela | Conteúdo | Bytes usados (documentado) | Status de validação |
|-------|--------|----------|----------------------------|---------------------|
| `$00` | `$8000` | Ryu: metasprites, roteiros de IA, `RyuAiThink`, caixas de colisão | 5,2 KB | Documentado, não revalidado |
| `$01` | `$A000` | Ryu: estados/animações | 4,5 KB | Documentado, não revalidado |
| `$04` | `$8000` | Ken: frames/metasprites/colisões + retrato; stub de IA em `$90E0` | 4,3 KB | Documentado, não revalidado |
| `$05` | `$A000` | Ken: estados/animações (fonte à mão; original todo `$FF`) | 4,5 KB | Documentado, não revalidado |
| `$08 $0C $10 $1C $24` | `$8000` | Retratos da seleção | ~50 cada | Documentado, não revalidado |
| `$20` | `$8000` | Sprites de HUD/efeitos ("ROUND", "FIGHT", "YOU WIN"…) | 1,6 KB | Documentado, não revalidado |
| `$29`, `$2D` | `$A000` | Músicas (FamiTone2) | 5,7 / 4,9 KB | Documentado, não revalidado |
| `$36` | `$C000` | Telas RLE + tabelas | 1,3 KB | Documentado, não revalidado |
| `$3C` | `$8000` | Fichas dos personagens, nomes, frases de vitória, dados de seleção/VS | 1,8 KB | Documentado, não revalidado |
| `$02…$2A` (passo 4) | `$C000` | 11 bancos de vozes DPCM | — | Documentado, não revalidado |
| `$37` | `$E000` | Som (FamiTone2 + vozes), telas de aviso, título e seleção | 6,4 KB | Documentado, não revalidado |
| `$3B` | `$E000` | Luta (rounds, HUD, desenho, divisão de tela), telas VS e frase final, utilitários de vídeo | 8,1 KB (cheio!) | Documentado, não revalidado |
| `$3F` | `$E000` | Reset, laço principal, núcleo do motor de luta | 7,3 KB | Documentado, não revalidado |
| Outros 36 bancos | — | Vazios (`$FF`) | 0 | Documentado, não revalidado |

### Separação de conceitos

- **Limitação local de banco específico:** o banco `$3B` está descrito como "cheio" (~120 bytes livres) na documentação; qualquer acréscimo de código ali estoura o banco (o montador avisa via `.assert` do kernel).
- **Capacidade total restante do PRG:** documentado como 36 dos 64 bancos vazios (22% do PRG usado). Não revalidado.
- **Requisitos de kernel/vetores:** todo banco mapeado em `$E000` precisa dos vetores em `$FFFA`–`$FFFF`; o kernel (`$FC7C`–`$FF9A`) é repetido nos três bancos de código (`$37`, `$3B`, `$3F`) via `src/kernel.inc`.
- **Afirmações de datas/versões/builds distintas:** o README cita um SHA-1 histórico de ROM entregue (`843a869e…`) e um SHA-1 do ROM original (`0bf9dc57…a9aed`); estes são afirmações históricas, não revalidadas nesta auditoria.

## 6. Inventário de ferramentas e validações

Inventariado por leitura de `tools/` e `tools/mesen/`. **Nenhum script foi executado.** Nenhuma alegação de aprovação é feita.

| Ferramenta/script | Finalidade declarada | Inputs/outputs inferidos pela leitura | Cenário/afirmação coberta | Status auditado |
|-------------------|----------------------|---------------------------------------|---------------------------|-----------------|
| `tools/disasm.py` | Gerador do projeto (`make gen`) | ROM + trace + anotações → `src/*.s`, `sf2ne.cfg`, `assets/` | Regeneração do fonte | EXISTE — não executado nesta auditoria |
| `tools/show.py` | Mostrar uma rotina com quem chama e em que telas roda | Endereço de rotina → texto da rotina + linhas `; <-` e `; modos:` | Inspeção de rotina individual | EXISTE — não executado |
| `tools/datamap.py` | Listar faixas de dados de um banco (lidas/tipadas/nunca tocadas) | Banco(s) → lista de faixas | Cobertura de dados por banco | EXISTE — não executado |
| `tools/ptr_candidates.py` | Listar pares de imediatos que parecem ponteiros mas o trace não confirmou | — → pares suspeitos para revisão manual | Descoberta de ponteiros não cobertos por trace | EXISTE — não executado |
| `tools/poke_prg.py` | Gravar bytes trocados em cópia de ROM (experimentos) | ROM base + banco/endereço/byte → ROM modificado (cópia) | Experimentos de realocação em cópia | EXISTE — não executado |
| `tools/frame_census.py` | Censo dos bytes dos quadros de animação direto do ROM | Banco/ROM → estatísticas de efeitos, flags, modos, colisão | Quadros alcançáveis do Ryu | EXISTE — não executado |
| `tools/shift_test.sh` | Teste de realocação: insere 1 byte no começo de bancos e monta | Lista de bancos → ROM deslocado em `build/shift/` | Verificar realocabilidade | EXISTE — não executado |
| `tools/extract_chr.py` / `extract_dpcm.py` | Exportar gráficos (PNG) e vozes (WAV) | — → `extracted/chr/`, `extracted/dpcm/` | `make assets` | EXISTE — não executado |
| `tools/trace_merge.py` | Mesclar execuções brutas do emulador em `trace/` | Vários diretórios de trace → `trace/` mesclado | Consolidação de traces | EXISTE — não executado |
| `tools/sheet.py` | Folha de contato de screenshots | Várias imagens PNG → folha de contato | Visualização de capturas | EXISTE — não executado |
| `tools/d6502.py`, `tracelib.py` | Bibliotecas (tabela de opcodes, leitura de traces) | — → usados por outros scripts | Suporte a ferramentas | EXISTE — não executado |
| `tools/mesen/batch1.sh`, `batch2.sh`, `batch3.sh`, `batch_ptr.sh` | Lotes usados para gerar `trace/` | — → `trace/` | Geração de traces históricos | EXISTE — não executado |
| `tools/mesen/run_trace.sh` | Rodar um script Lua do Mesen com parâmetros | Plano + quadros + semente → saída de trace | Execução controlada no Mesen | EXISTE — não executado |
| `tools/mesen/reset_test.lua` / `reset_test.sh` | Apertar RESET num quadro e verificar se o jogo volta | ROM + quadro → resultado de reinício | Teste de soft reset | EXISTE — não executado |
| `tools/mesen/ptrtrace.lua` | Rastrear ponteiros por origem de valor | Execução → pares de imediatos reconhecidos como ponteiros | Descoberta de ponteiros | EXISTE — não executado |
| `tools/mesen/regress.sh` | Bateria de 5 partidas contra o original | ROM → comparação de comportamento | Regressão de funcionalidades existentes | EXISTE — não executado |
| `tools/mesen/compare_roms.sh` | Rodar dois ROMs com mesmas entradas e comparar | Dois ROMs + plano + quadros + semente → comparação de telas/som/timeline | Regressão visual/temporal | EXISTE — não executado |
| `tools/mesen/cdl.lua` | Registrar código executado, leituras de dados, saltos indiretos, uso de RAM, MMC5, DPCM, modo de tela, screenshots | Execução → `trace/` | Coleta de dados de execução | EXISTE — não executado |

**Estado geral:** todos os scripts existem, nenhum foi executado nesta auditoria. Status de execução: `EXISTE — não executado nesta auditoria` para todos.

## 7. Matriz de inconsistências

Comparando `README.md`, `docs/ROTEIRO.md`, `docs/ARQUITETURA.md`, `docs/FORMATOS.md`, `docs/RAM.md`, `docs/BUGS.md`, `docs/FERRAMENTAS.md` e especificações de tarefa. Nenhuma divergência foi corrigida; todas são registradas para priorização posterior.

| ID | Afirmação/assunto | Documento A | Documento B | Categoria | Risco | Proposta de destino |
|----|-------------------|-------------|-------------|-----------|-------|---------------------|
| IN-01 | Número de rótulos: "1.795 rótulos; 304 têm nome de verdade" (README §"O que ainda não está pronto") | `README.md` | Contagem recalculada nesta auditoria (2.145 definições, 2.141 únicos, 549 semânticos) | Contagem/métrica | Médio — métrica antiga pode não refletir o estado atual dos fontes gerados | Reconciliar na Fase 1/4; definir critério de contagem (D-01) |
| IN-02 | Contagem de variáveis nomeadas: "78 têm nome" (README) | `README.md` | Não recalculada nesta auditoria (exigiria inspeção de `ram.inc`) | Contagem/métrica | Baixo | Verificar contra `src/ram.inc` na Fase 1 |
| IN-03 | "Código nunca executado (14–17% dos bancos `$37` e `$3F`)" (README) | `README.md` | Não revalidado (exigiria traces atuais) | Capacidade de banco/build | Médio — percentual pode estar desatualizado | Confirmar com `datamap.py`/traces na Fase 1, sem executar emulador |
| IN-04 | "52 farcall e 7 farjmp" (ARQUITETURA.md §2.7) | `docs/ARQUITETURA.md` | Não recontado nesta auditoria | Fonte de verdade/geração | Baixo | Verificar contra anotações/gerador na Fase 4 |
| IN-05 | "Banco `$3B` está cheio — ~120 bytes livres" (ARQUITETURA.md §7 e ROTEIRO.md Etapa 5) | `docs/ARQUITETURA.md`, `docs/ROTEIRO.md` | Não revalidado (não houve build) | Capacidade de banco/build | Médio — limita acréscimo de código no `$3B` | Confirmar com mapa de linker se houver build autorizado (Gate C/D) |
| IN-06 | README descreve o build canônico como "com o Ken jogável" e `make verify` avisa que diverge do original | `README.md` | `Makefile` (`DEFS := -D DEST_FLAG_BLINK`, build diverge por design) | Fonte de verdade/geração | Baixo — comportamento intencional, documentado | Nenhuma ação; está consistente na intenção |
| IN-07 | "Ken tem 4,3 KB de frames prontos agora integrados ao banco $05" (README §Achados) vs "O banco $05 é fonte à mão (o original é todo $FF)" (ROTEIRO.md Etapa 3) | `README.md`, `docs/ROTEIRO.md` | Fontes descrevem situações complementares (frames vs estados) | Status/escopo | Baixo | Esclarecer na Fase 4 |

## 8. Decisões que permanecem pendentes

Referência a `tasks/STABILIZATION_BACKLOG.md` (criado na Fase 0). Todas as decisões D-01 a D-07 permanecem como `PENDENTE`:

- **D-01:** Método reproduzível para contar labels (bloqueia métricas de naming e comparação futura).
- **D-02:** Fonte canônica para autoria de estados/quadros (bloqueia implementar conversor ou migrar dados).
- **D-03:** Primeira leva de naming e evidência mínima (bloqueia campanha de renomeação).
- **D-04:** Critérios para reabrir implementação de personagens/funcionalidades (bloqueia retomar trilha C).
- **D-05:** Validações futuras autorizadas, por quem, em que escopo (bloqueia criar/rodar testes, builds ou validação em emulador).
- **D-06:** Avaliação de ferramentas externas de assets (bloqueia integração de conversores externos).
- **D-07:** Necessidade mensurável de mudar organização do kernel/bancos (bloqueia qualquer refatoração do kernel).

Nenhuma dessas decisões foi resolvida nesta auditoria.

## 9. Limitações e próximos passos recomendados

### Limitações desta auditoria

- Nenhuma montagem, execução, emulação ou teste foi realizado. Todas as métricas de ocupação de banco são documentadas/históricas, não revalidadas.
- Nenhuma ferramenta permanente de auditoria foi criada (conforme o escopo da Fase 1 proíbe).
- Nenhuma divergência de documento foi corrigida; todas foram registradas na seção 7.
- O número de rótulos do README (1.795) não foi usado; uma nova contagem foi feita a partir dos fontes gerados, mas pode diferir por critérios de classificação (código vs dados vs não classificados).

### Próximos passos recomendados (sem implementar nem escolher fonte canônica)

1. **Solicitar Gate A** (auditoria documental) para consolidar as métricas atuais e resolver divergências documentadas (seção 7).
2. **Definir critério de contagem de labels** (D-01) antes de estabelecer metas de naming (Fase 3).
3. **Decidir fonte canônica para estados/quadros** (D-02) antes de especificar formato textual (Fase 2).
4. **Avaliar se o percentual de código nunca executado (14–17%) precisa de revalidação** com traces existentes, sem executar emulador novo.

## 10. Índice de fontes

| Caminho relativo | Conteúdo | Utilizado para |
|------------------|----------|----------------|
| `README.md` | Visão geral, fluxo de trabalho, métricas históricas | Seções 2, 3, 4, 7 |
| `Makefile` | Comandos de build, defines do build canônico | Seções 3, 4 |
| `sf2ne.cfg` | Layout de bancos de PRG para ld65 | Seção 5 |
| `annotations/sf2ne.ann` (1.711 linhas) | Nomes, comentários, correções, blocos `alt`, `patch`, `keepbank` | Seções 3, 4, 7 |
| `src/bank_*.s` (26 arquivos) | Fonte gerado por banco de código/dados | Seção 4 (contagem de rótulos) |
| `src/*.inc` (6 arquivos: kernel, defs, ram, globals, hw, macros) | Compartilhado entre bancos; `.global` em `globals.inc` | Seções 3, 4 |
| `docs/ARQUITETURA.md` | Mapa de cartucho, bancos, código, fluxo, motor, formato, som, vídeo | Seções 2, 5, 7 |
| `docs/FORMATOS.md` | Formatos campo a campo de estados, quadros, comandos, IA | Seções 2, 3 |
| `docs/RAM.md` | Mapa de RAM conhecido | Seção 3 |
| `docs/ROTEIRO.md` | Etapas, status, declaração de pausa (Fase 0) | Seções 2, 5, 7 |
| `docs/BUGS.md` | Bugs relatados e status | Seção 2 |
| `docs/FERRAMENTAS.md` | Fluxo, Makefile, anotações, scripts, emulador | Seções 3, 6 |
| `tools/disasm.py` | Gerador | Seções 3, 4 |
| `tools/show.py`, `datamap.py`, `ptr_candidates.py`, `poke_prg.py`, `frame_census.py`, `shift_test.sh`, `extract_chr.py`, `extract_dpcm.py`, `trace_merge.py`, `sheet.py`, `d6502.py`, `tracelib.py` | Scripts de ferramenta | Seção 6 |
| `tools/mesen/` (14 arquivos) | Scripts de emulação e validação | Seção 6 |
| `tasks/PHASE_0_SCOPE_FREEZE_SPEC.md` | Especificação da Fase 0 (pré-requisito verificado) | Seção 1 |
| `tasks/STABILIZATION_BACKLOG.md` | Backlog criado na Fase 0 | Seções 2, 8 |

**Método de contagem de rótulos:** `grep -rhE '^[A-Za-z_][A-Za-z0-9_]*:$' src/bank_*.s`, com classificação por padrões `L<bb>_<aaaa>` (código) e `D<bb>_<aaaa>` (dados) confirmados no gerador; tudo o resto é semântico. Arquivos consultados: todos os `src/bank_*.s` listados no índice acima.
