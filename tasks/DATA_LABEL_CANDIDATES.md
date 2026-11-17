# Inventário de labels de dados — triagem inicial

- **Status:** triagem estática; nomes aplicados nos lotes `$3C`, `$3F` e `$20`.
- **Escopo:** 1.213 labels automáticos de dados (`D<bb>_<aaaa>`) em `src/bank_*.s`.
- **Fonte:** `src/bank_*.s` gerados a partir de `annotations/sf2ne.ann`; leitura somente.
- **Objetivo:** classificar por banco/subsistema, referências e categoria para escolher o primeiro lote de naming de dados.
- **Inventário completo:** `tasks/DATA_LABEL_INVENTORY.tsv` (1.213 linhas, tabulação).
- **Nota:** snapshot anterior aos lotes de dados. Após `tasks/DATA_NAMING_3C.md` (33 labels), `tasks/DATA_NAMING_3F.md` (15) e `tasks/DATA_NAMING_20.md` (30), restam **1.135** labels automáticos de dados.

## 1. Método

- **`data_bytes`:** bytes emitidos por `.byte`/`.word` entre o label e o próximo label.
- **`res_bytes`:** preenchimento `.res` no mesmo intervalo (não é dado lógico; separado para não inflar o tamanho).
- **`unknown=yes`:** há `.include` no intervalo, então o tamanho real não é conhecido só pela fonte.
- **Referências:** ocorrências do label nos `src/bank_*.s`, separadas em código, dados (`.byte`/`.word`) e comentários.
- **Categoria:** heurística por comentário de contexto, subsistema do banco e diretiva inicial.
- **Prioridade:** `P0` = referência direta de código; `P1` = 2+ referências em dados; `P2` = 1 referência em dados; `P3` = nenhuma referência.

> Prioridade é pista de triagem, não decisão de naming. Nomes só devem ser propostos após leitura do fluxo que consome cada tabela.

## 2. Resumo por banco/subsistema

| Banco | Subsistema | Labels | P0 | P1 | P2 | P3 |
|-------|------------|--------|----|----|----|----|
| `$00` | Ryu: metasprites/IA/colisao | 206 | 28 | 108 | 70 | 0 |
| `$01` | Ryu: estados/animacoes | 304 | 0 | 33 | 271 | 0 |
| `$04` | Ken: frames/metasprites/colisao/retrato | 3 | 0 | 2 | 1 | 0 |
| `$05` | Ken: estados/animacoes | 352 | 0 | 33 | 271 | 48 |
| `$08` | Retratos da selecao | 1 | 0 | 0 | 1 | 0 |
| `$0C` | Retratos da selecao | 1 | 0 | 0 | 1 | 0 |
| `$10` | Retratos da selecao | 1 | 0 | 0 | 1 | 0 |
| `$1C` | Retratos da selecao | 1 | 0 | 0 | 1 | 0 |
| `$20` | HUD/efeitos (sprites) | 30 | 8 | 13 | 9 | 0 |
| `$24` | Retratos da selecao | 1 | 0 | 0 | 1 | 0 |
| `$29` | Musica (FamiTone2) | 103 | 4 | 40 | 59 | 0 |
| `$2D` | Musica (FamiTone2) | 70 | 1 | 30 | 39 | 0 |
| `$36` | Telas RLE + tabelas | 30 | 21 | 0 | 9 | 0 |
| `$37` | Som/telas (FamiTone2) | 27 | 15 | 1 | 11 | 0 |
| `$3B` | Luta/HUD/VS/utilitarios de video | 35 | 34 | 0 | 1 | 0 |
| `$3C` | Fichas/selecao/VS | 33 | 33 | 0 | 0 | 0 |
| `$3F` | Motor/nucleo de luta | 15 | 15 | 0 | 0 | 0 |
| **Total** | — | **1213** | **159** | **260** | **746** | **48** |

| Subsistema | Labels | P0 | P1 | P2 | P3 |
|------------|--------|----|----|----|----|
| Motor/nucleo de luta | 15 | 15 | 0 | 0 | 0 |
| Ryu: estados/animacoes | 304 | 0 | 33 | 271 | 0 |
| Ken: estados/animacoes | 352 | 0 | 33 | 271 | 48 |
| Ryu: metasprites/IA/colisao | 206 | 28 | 108 | 70 | 0 |
| Ken: frames/metasprites/colisao/retrato | 3 | 0 | 2 | 1 | 0 |
| Luta/HUD/VS/utilitarios de video | 35 | 34 | 0 | 1 | 0 |
| Fichas/selecao/VS | 33 | 33 | 0 | 0 | 0 |
| Telas RLE + tabelas | 30 | 21 | 0 | 9 | 0 |
| HUD/efeitos (sprites) | 30 | 8 | 13 | 9 | 0 |
| Musica (FamiTone2) | 173 | 5 | 70 | 98 | 0 |
| Som/telas (FamiTone2) | 27 | 15 | 1 | 11 | 0 |
| Retratos da selecao | 5 | 0 | 0 | 5 | 0 |

| Categoria | Labels |
|-----------|--------|
| Quadro | 502 |
| Dados | 338 |
| FamiTone2 | 200 |
| Estado | 140 |
| TabelaPonteiros | 30 |
| IA | 1 |
| Selecao | 1 |
| Paleta | 1 |

## 3. Lista curta — P0 (referência direta de código), até 5 por subsistema

São os labels com consumidor identificável no código — maior chance de receber nome por evidência. A lista mostra até 5 por subsistema para não concentrar tudo no `$3F`.

| # | Endereço | Label | Dados (B) | `.res` | Xrefs (cód/dados/com.) | Categoria | Consumidor (primeira referência) |
|---|----------|-------|-----------|--------|------------------------|-----------|-----------------------------------|
| 1 | `3F:F0B1` | `D3F_F0B1` | 6 | 0 | 6 (2/0/4) | Dados | `ldy a:MoveMode,x ; F0A5 BC 2E 00 despacha a aplicacao do movimento pelo MoveMode (tabela D3F_F0B1)` |
| 2 | `3F:E4CE` | `D3F_E4CE` | 6 | 0 | 4 (1/0/3) | Dados | `lda D3F_E4CE,y ; E4C9 B9 CE E4 [idx $00..$05]` |
| 3 | `3F:E05E` | `D3F_E05E` | 6 | 0 | 2 (2/0/0) | Dados | `sta ProjSpeed,x ; E837 95 77 A = velocidade ($00/$01/$02, passo em D3F_E05E): nasce em FighterX +/- $27, direcao = Fight` |
| 4 | `3F:E068` | `D3F_E068` | 71 | 0 | 2 (2/0/0) | Dados | `lda #$00 ; EB73 A9 00 passo cumprido: zera a janela, avanca o passo; D3F_E068,y (MESMO y) le o byte SEGUINTE — $0 cai ja` |
| 5 | `3F:E055` | `D3F_E055` | 6 | 0 | 1 (1/0/0) | Dados | `lda D3F_E055,y ; EE8C B9 55 E0 [idx $00..$05]` |
| 6 | `00:8E82` | `D00_8E82` | 9 | 0 | 7 (4/3/0) | Dados | `lda #<D00_8E82 ; 8FC8 A9 82 RyuAiProjScriptMid — IA do Ryu: projetil a 32-64 px -> roteiro $00:8E82` |
| 7 | `00:8EA6` | `D00_8EA6` | 7 | 0 | 5 (2/3/0) | Dados | `lda #<D00_8EA6 ; 90BC A9 A6` |
| 8 | `00:8F03` | `D00_8F03` | 7 | 0 | 4 (4/0/0) | Dados | `lda #<D00_8F03 ; 8FBB A9 03` |
| 9 | `00:8F1B` | `D00_8F1B` | 9 | 0 | 4 (2/2/0) | Dados | `lda #<D00_8F1B ; 905C A9 1B RyuAiOpponentScript — IA do Ryu: oponente perto -> roteiro $00:8F1B` |
| 10 | `00:8F24` | `D00_8F24` | 2 | 0 | 4 (4/0/0) | Dados | `lda #<D00_8F24 ; 8FB1 A9 24` |
| 11 | `3B:E57D` | `D3B_E57D` | 24 | 0 | 2 (2/0/0) | TabelaPonteiros | `lda D3B_E57D,y ; F2C6 B9 7D E5 [idx $00..$06]` |
| 12 | `3B:E595` | `D3B_E595` | 8 | 0 | 2 (2/0/0) | TabelaPonteiros | `lda D3B_E595,y ; F2A8 B9 95 E5 [idx $00..$06]` |
| 13 | `3B:E808` | `D3B_E808` | 1 | 0 | 2 (2/0/0) | Dados | `lda D3B_E808,x ; E6A0 BD 08 E8 (nt)` |
| 14 | `3B:E809` | `D3B_E809` | 1 | 0 | 2 (2/0/0) | Dados | `lda D3B_E809,x ; E6A6 BD 09 E8 (nt)` |
| 15 | `3B:E80A` | `D3B_E80A` | 1 | 0 | 2 (2/0/0) | Dados | `lda D3B_E80A,x ; E6AC BD 0A E8 (nt)` |
| 16 | `3C:81D6` | `D3C_81D6` | 96 | 24 | 4 (4/0/0) | Dados | `lda #<D3C_81D6 ; EE48 A9 D6` |
| 17 | `3C:824E` | `D3C_824E` | 96 | 24 | 4 (4/0/0) | Dados | `lda #<D3C_824E ; EE50 A9 4E` |
| 18 | `3C:82C6` | `D3C_82C6` | 24 | 96 | 4 (4/0/0) | Dados | `lda #<D3C_82C6 ; EE5B A9 C6 PortraitP1LoseSet — retrato do P1: P1 perdeu -> layout de derrota` |
| 19 | `3C:833E` | `D3C_833E` | 24 | 96 | 4 (4/0/0) | Dados | `lda #<D3C_833E ; EE63 A9 3E` |
| 20 | `3C:83B6` | `D3C_83B6` | 24 | 96 | 4 (4/0/0) | Dados | `lda #<D3C_83B6 ; E158 A9 B6` |
| 21 | `36:C03C` | `D36_C03C` | 10 | 0 | 2 (2/0/0) | TabelaPonteiros | `lda D36_C03C,y ; E2C9 B9 3C C0 [bancos $36 idx $00..$00]` |
| 22 | `36:C046` | `D36_C046` | 10 | 0 | 2 (2/0/0) | TabelaPonteiros | `lda D36_C046,y ; E2F4 B9 46 C0 [bancos $36 idx $00..$00]` |
| 23 | `36:C050` | `D36_C050` | 10 | 0 | 2 (2/0/0) | TabelaPonteiros | `lda D36_C050,y ; E2D4 B9 50 C0 [bancos $36 idx $00..$00]` |
| 24 | `36:C05A` | `D36_C05A` | 10 | 0 | 2 (2/0/0) | TabelaPonteiros | `lda D36_C05A,y ; E2FF B9 5A C0 [bancos $36 idx $00..$00]` |
| 25 | `36:C064` | `D36_C064` | 10 | 0 | 2 (2/0/0) | TabelaPonteiros | `lda D36_C064,y ; E2DF B9 64 C0 [bancos $36 idx $00..$00]` |
| 26 | `20:8469` | `D20_8469` | 13 | 0 | 2 (2/0/0) | Dados | `lda #<D20_8469 ; F78C A9 69` |
| 27 | `20:8476` | `D20_8476` | 21 | 0 | 2 (2/0/0) | Dados | `lda #<D20_8476 ; F001 A9 76` |
| 28 | `20:848B` | `D20_848B` | 22 | 0 | 2 (2/0/0) | Dados | `lda #<D20_848B ; F8A2 A9 8B RoundEnd_DrawTieAlt — empate com relogio no ar: variante do sprite ($20:848B) (nt)` |
| 29 | `20:84A1` | `D20_84A1` | 11 | 0 | 2 (2/0/0) | Dados | `lda #<D20_84A1 ; F88F A9 A1` |
| 30 | `20:852B` | `D20_852B` | 15 | 0 | 2 (2/0/0) | Dados | `lda #<D20_852B ; F858 A9 2B RoundEnd_DrawPerfect — desenha o sprite de "PERFECT" ($20:852B)` |
| 31 | `29:A000` | `D29_A000` | 19 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D29_A000 ; F4F3 A9 00` |
| 32 | `29:AAB6` | `D29_AAB6` | 19 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D29_AAB6 ; EF97 A9 B6` |
| 33 | `29:B34A` | `D29_B34A` | 19 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D29_B34A ; EB97 A9 4A` |
| 34 | `29:B4BD` | `D29_B4BD` | 19 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D29_B4BD ; EC5F A9 BD` |
| 35 | `2D:A000` | `D2D_A000` | 19 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D2D_A000 ; F574 A9 00` |
| 36 | `37:F293` | `D37_F293` | 8 | 0 | 4 (4/0/0) | FamiTone2 | `lda D37_F293,x ; F049 BD 93 F2 [idx $00..$07]` |
| 37 | `37:E199` | `D37_E199` | 6 | 0 | 2 (2/0/0) | FamiTone2 | `ldx zp_DC ; E40B A6 DC efeito sonoro por classe de estado: canal em D37_E199[x], sfx em SfxChannelOfs[estado]` |
| 38 | `37:E8AD` | `D37_E8AD` | 4 | 0 | 2 (2/0/0) | FamiTone2 | `lda D37_E8AD,x ; E72E BD AD E8 [idx $00..$00]` |
| 39 | `37:EE74` | `D37_EE74` | 3 | 0 | 2 (2/0/0) | FamiTone2 | `lda #<D37_EE74 ; E4FF A9 74 _FT2MusicStopEnvelopes — FamiTone2: aponta todos os envelopes para o envelope mudo` |
| 40 | `37:F29B` | `D37_F29B` | 8 | 0 | 2 (2/0/0) | FamiTone2 | `lda D37_F29B,x ; F035 BD 9B F2 [idx $00..$07]` |

## 4. Próximo passo sugerido

1. Lotes já aplicados: **Motor/núcleo de luta (`$3F`, 15)**, **Fichas/seleção/VS (`$3C`, 33)** e
   **HUD/efeitos (`$20`, 30)** — ver `tasks/DATA_NAMING_3F.md`, `tasks/DATA_NAMING_3C.md` e
   `tasks/DATA_NAMING_20.md`.
2. Próximos candidatos da seção 2, pela relação evidência/esforço: **Telas RLE + tabelas (`$36`, 30)** e
   **Luta/HUD/VS/utilitários de vídeo (`$3B`, 35)**.
3. Ler o fluxo consumidor e propor nomes com evidência/confiança/risco no formato de `tasks/NAMING_CANDIDATES.md`.
4. Aplicar somente após autorização explícita; validar com `make gen`, `make` e SHA-1 idêntico.

> Os lotes aplicados não mudaram bytes. ROM canônico: `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`.

