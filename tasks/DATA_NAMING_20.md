# Naming de dados — lote 3: banco `$20` (HUD, efeitos e retrato)

- **Status:** **PROPOSTO** — aguardando aprovação para aplicar em `annotations/sf2ne.ann`.
- **Escopo:** os 30 labels automáticos `D20_*` de `src/bank_20.s`.
- **Fonte de verdade:** `annotations/sf2ne.ann`, `docs/FORMATOS.md`, os consumidores em `src/bank_3B.s` / `src/bank_37.s` / `src/bank_3C.s` e a decodificação direta do CHR de `build/sf2ne.nes`.
- **Regra:** só labels e comentários mudam; bytes e SHA-1 do ROM devem permanecer idênticos.

## 1. Evidência usada

### 1.1 Como os sprites foram lidos

O banco `$20` guarda metasprites no formato usado por `DrawMetasprite` (`3B:F2EA`):

```
[chrPage] [$FF] [attr] [count] [dx] [dy] [tiles...]  ...  $80
```

- `byte[0]` = página de CHR de 2 KB (lida pelo chamador e escrita em `MMC5_CHR_SPR5`);
- o byte seguinte é o atributo da OAM. Nos metasprites do intro, do fim do round e das bandeiras o chamador já entra com `y=1`, então o `$FF` que aparece ali é **pulado** (separador); nos projéteis e no cursor o chamador entra com `y=0` e o byte seguinte já é o atributo;
- `count` = quantidade de sprites; `dx`/`dy` = deslocamento em relação à base;
- terminador de grupo = `count` com bit 7 ligado (`$80`).

Cada sprite é **8x16**: o tile `t` desenha `(t, t+1)` no PPU. Para ler o conteúdo, o CHR foi decodificado de `build/sf2ne.nes` (2 bits por pixel) e renderizado em ASCII. Páginas relevantes:

| Página | Offset no CHR | Conteúdo |
|--------|---------------|----------|
| `$00` | `$0000` | bandeiras dos países |
| `$01` | `$0800` | fonte do intro do round (`BATTLE`, `ROUND`, `FIGHT`, dígitos) |
| `$02` | `$1000` | projétil e choque de projéteis |
| `$03` | `$1800` | fim do round (`PERFECT`, `TIME OVER`, `YOU LOSE`, `YOU WIN`, `DRAW GAME`) |

### 1.2 Consumidores

| Fluxo | Onde | O que prova |
|-------|------|-------------|
| `RoundIntroDraw` | `3B:F71C-F796` | `8469` = "BATTLE"; `D3B_F799` escolhe o texto do passo do intro |
| `D3B_F799` | `3B:F799-F7D7` | `84C6`/`84B9`/`84AC` = "FIGHT!" em 3 tamanhos; `8574` = "FIGHT"; `8580` = texto de flash; `858E`/`859E`/`85AE`/`85BE` = "ROUND 1..4" |
| `SelectDrawCursor` | `37:EFFA-F031` | `8476` = cursor da seleção (desenhado por `SelectDrawBlink`) |
| `D37_F29B` + `D37_F293` | `37:F293-F2A2` | mapa cursor→personagem e cursor→bandeira (ver §2.3) |
| `RoundEnd_DrawTie` | `3B:F887-F89F` | `84A1` = "DRAW GAME" (empate com o relógio zerado) |
| `RoundEnd_DrawTieAlt` | `3B:F8A2-F8B2` | `848B` = variante do empate (relógio ainda no ar) |
| `RoundEnd_DrawPerfect` | `3B:F858-F85A` | `852B` = "PERFECT!" |
| `RoundEnd_TimeUpCheck` | `3B:F7F0-F816` | `85CE` = "TIME OVER" |
| `RoundEnd_DrawYouWin` | `3B:F846-F84A` | `85EA` = "YOU WIN" |
| `RoundEnd_DrawYouLose` | `3B:F874-F884` | `85D9` = "YOU LOSE" |
| `DrawProjectile` / `DrawProjectileSprite` | `3B:F27A-F2CE` | `8509`/`851A` = 2 quadros do projétil normal (`D3B_E57D`) |
| `ProjClash` + `D3B_E595` | `3F:E8BB-E8EC` / `3B:E595` | `853A`/`8549`/`8556`/`8565` = 4 quadros do choque de projéteis |
| `PortraitWinLayoutTbl` | `3C:84A6` (`3C:84B6`) | índice 8 = M.BISON → `D20_8391` (retrato de vitória) |

> O bit 7 de `ProjFlags` é ligado por `ProjClash` quando os dois projéteis estão a menos de `$18` px; é ele que seleciona `D3B_E595` (choque) em vez de `D3B_E57D` (voo normal).

## 2. Nomes propostos

### 2.1 Retrato

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `20:8391` | 216 | `PortraitWinLayoutTbl[8]` (`3C:84B6`) | `PortraitWinMBison` | ALTA |

> `docs/ARQUITETURA.md` §4.1 confirma `8 = M.BISON` e `CharFrameBankTbl[8] = $20`. O índice 8 de `PortraitWinLayoutTbl` aponta para `D20_8391`, então é o retrato de vitória do M.Bison. O banco `$20` também guarda o HUD; este é o único retrato nele.

### 2.2 Intro do round

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `20:8469` | 13 | `RoundIntroDraw` (`3B:F78C`) | `RoundIntroBattleText` | ALTA |
| `20:84AC` | 13 | `D3B_F799` (`3B:F79D`) | `FightTextZoomSmall` | ALTA |
| `20:84B9` | 13 | `D3B_F799` (`3B:F79B`) | `FightTextZoomMedium` | ALTA |
| `20:84C6` | 13 | `D3B_F799` (`3B:F799`) | `FightTextZoomLarge` | ALTA |
| `20:8574` | 12 | `D3B_F799` (`3B:F79F`) | `FightText` | ALTA |
| `20:8580` | 14 | `D3B_F799` (`3B:F7A1`, `3B:F7D1`) | `RoundTextFlash` | MÉDIA |
| `20:858E` | 16 | `D3B_F799` (`3B:F7A3`) | `RoundText1` | ALTA |
| `20:859E` | 16 | `D3B_F799` (`3B:F7B3`) | `RoundText2` | ALTA |
| `20:85AE` | 16 | `D3B_F799` (`3B:F7C3`) | `RoundText3` | ALTA |
| `20:85BE` | 16 | `D3B_F799` (`3B:F7D3`) | `RoundText4` | ALTA |

Leitura dos sprites:

- `8469` = **BATTLE** (B,A,T,T,L,E).
- `84AC` / `84B9` / `84C6` = **FIGHT!** em três tamanhos crescentes (mesmo texto, arte com mais preenchimento a cada passo).
- `8574` = **FIGHT**.
- `858E` / `859E` / `85AE` = **ROUND 1 / 2 / 3** ("ROUND" em `dx=0`, dígito em `dx=$30`).
- `8580` = texto compacto de **ROUND** usado como flash (aparece nos passos 6 e 4 da sequência, 2 quadros cada). A segmentação exata dos glifos é difícil, mas o consumidor e a posição na sequência confirmam que é a variante de flash do texto de round — por isso MÉDIA.

> **Particularidade de `85BE`:** o dígito `$46` ("4") fica em `dx=0` e "ROUND" em `dx=$10`, ou seja, a ordem de desenho é **"4" + "ROUND"**, invertida em relação a `858E`/`859E`/`85AE`. O nome `RoundText4` descreve o conteúdo (round 4), não a ordem visual. Vale registrar como curiosidade/possível bug do original; não corrigir neste lote.

### 2.3 Seleção de personagem

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `20:8476` | 21 | `SelectDrawCursor` (`37:F001`) → `SelectDrawBlink` | `SelectCursorMetasprite` | ALTA |
| `20:84D3` | 9 | `D37_F29B` (`37:F29C`) | `FlagBrazil` | ALTA |
| `20:84DC` | 9 | `D37_F29B` (`37:F2A0`) | `FlagChina` | ALTA |
| `20:84E5` | 9 | `D37_F29B` (`37:F29B`) | `FlagJapan` | ALTA |
| `20:84EE` | 9 | `D37_F29B` (`37:F29E`, `37:F2A2`) | `FlagThailand` | ALTA |
| `20:84F7` | 9 | `D37_F29B` (`37:F29D`, `37:F29F`) | `FlagUsa` | ALTA |
| `20:8500` | 9 | `D37_F29B` (`37:F2A1`) | `FlagUssr` | ALTA |

**Mapa das bandeiras** (`D37_F293` = cursor→personagem; `D37_F29B` = cursor→bandeira):

| Cursor | Personagem (`D37_F293`) | Bandeira | Nome |
|--------|--------------------------|----------|------|
| 0 | 0 RYU | `84E5` | Japão |
| 1 | 4 BLANKA | `84D3` | Brasil |
| 2 | 3 GUILE | `84F7` | EUA |
| 3 | 7 SAGAT | `84EE` | Tailândia |
| 4 | 1 KEN | `84F7` | EUA |
| 5 | 2 CHUN LI | `84DC` | China |
| 6 | 9 ZANGIEF | `8500` | URSS |
| 7 | 8 M.BISON | `84EE` | Tailândia |

> `84F7` e `84EE` são compartilhadas por dois personagens cada (EUA: Guile/Ken; Tailândia: Sagat/M.Bison), coerente com o elenco. A ordem de personagens vem de `CharNameTbl` (`3C:84CE`) e de `docs/ARQUITETURA.md` §4.1.

### 2.4 Fim do round

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `20:848B` | 22 | `RoundEnd_DrawTieAlt` (`3B:F8A2`) | `RoundEndDrawTieAltMetasprite` | MÉDIA |
| `20:84A1` | 11 | `RoundEnd_DrawTie` (`3B:F88F`) | `DrawGameText` | ALTA |
| `20:852B` | 15 | `RoundEnd_DrawPerfect` (`3B:F858`) | `PerfectText` | ALTA |
| `20:85CE` | 11 | `RoundEnd_TimeUpCheck` (`3B:F806`) | `TimeOverText` | ALTA |
| `20:85D9` | 17 | `RoundEnd_DrawYouLose` (`3B:F874`) | `YouLoseText` | ALTA |
| `20:85EA` | 70¹ | `RoundEnd_DrawYouWin` (`3B:F846`) | `YouWinText` | ALTA |

- `84A1` = **DRAW GAME**: 4 sprites 8x16, cada um com dois caracteres 8x8 empilhados (linha de cima "DRAW", linha de baixo "GAME").
- `852B` = **PERFECT!** (7 letras + sinal).
- `85CE` = **TIME OVER**: 4 sprites 8x16, dois caracteres 8x8 por sprite ("TIME" em cima, "OVER" embaixo).
- `85D9` = **YOU** (`dx=0`) + **LOSE** (`dx=$20`).
- `85EA` = **YOU** (`dx=0`) + **WIN** (`dx=$20`).
- `848B` = imagem de 48x32 (6x2 sprites de 8x16) usada no empate com o relógio ainda no ar. O conteúdo não é texto legível na renderização; o nome descreve o consumidor (`RoundEnd_DrawTieAlt`), por isso MÉDIA.

> ¹ `85EA` tem 70 bytes no inventário porque o label se estende até o `.res` em `8630`; o metasprite em si termina em `85F9` (16 bytes). Os bytes `85FA-862F` não são referenciados por nenhum consumidor conhecido e ficam fora do escopo do nome — não afirmamos nada sobre eles.

### 2.5 Projéteis

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `20:8509` | 17 | `D3B_E57D` (`3B:E57D`) | `ProjectileFrame0` | ALTA |
| `20:851A` | 17 | `D3B_E57D` (`3B:E581`) | `ProjectileFrame1` | ALTA |
| `20:853A` | 15 | `D3B_E595` (`3B:E595`) | `ProjectileClashFrame0` | MÉDIA |
| `20:8549` | 13 | `D3B_E595` (`3B:E597`) | `ProjectileClashFrame1` | MÉDIA |
| `20:8556` | 15 | `D3B_E595` (`3B:E599`) | `ProjectileClashFrame2` | MÉDIA |
| `20:8565` | 15 | `D3B_E595` (`3B:E59B`) | `ProjectileClashFrame3` | MÉDIA |

> Os dois metasprites do projétil são desenhados em sequência por `DrawProjectileMetasprite` (`jsr` + `jmp`). `8509`/`851A` são os quadros de voo; `853A`/`8549`/`8556`/`8565` são os quadros do choque (`ProjFlags` bit 7). A numeração `0..3` é apenas a ordem de endereço, não uma ordem de animação afirmada.

## 3. Convenções e decisões

- Nomes em inglês, CamelCase, sem `D20_`.
- `...Text` para metasprites de texto; `FightTextZoomSmall/Medium/Large` para os três tamanhos do "FIGHT!".
- `Flag<País>` para as bandeiras; `Projectile*` para os projéteis.
- `PortraitWinMBison` segue o prefixo já usado em `PortraitWinLayoutTbl` / `PortraitBuild`.
- `848B` mantém um nome descritivo de consumidor porque o conteúdo gráfico não é legível; confiança MÉDIA, como os demais casos de arte não textual.

## 4. Riscos e validação

- **Risco:** baixo. Nenhuma diretiva `.byte`/`.word`/`.patch` é tocada; só entram linhas `label 20:XXXX <Nome>` (e comentários) em `annotations/sf2ne.ann`.
- **Efeito colateral esperado:** `src/bank_20.s` e `src/globals.inc` passam a usar os novos nomes; comentários gerados que citam `D20_*` também mudam (texto, não byte). Referências em `src/bank_3B.s`, `src/bank_37.s` e `src/bank_3C.s` passam a citar os novos nomes.
- **Validação obrigatória após aprovação:**
  1. `make gen` sem erro;
  2. `make` sem erro;
  3. SHA-1 de `build/sf2ne.nes` = `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`;
  4. `git diff -U0 -- src` sem nenhuma linha `.byte`/`.word`/`.patch` alterada;
  5. conferir que `src/bank_05.s` (Ken, fonte manual) não referencia `D20_*`.
- **Métrica esperada:** os 30 labels saem de `autoD`; `semantic unique` deve subir de 976 para 1.006 (se todos forem aplicados), mantendo `autoL=0`.

## 5. Resultado da aplicação

Os 30 nomes foram aplicados em `annotations/sf2ne.ann` (seção `# BANCO $20`, entre `$3C` e `# RAM`). Validação executada:

- `make gen`: OK; `src/bank_20.s`, `src/bank_37.s`, `src/bank_3B.s`, `src/bank_3C.s` e `src/globals.inc` regenerados apenas com os novos nomes.
- `make`: OK.
- SHA-1 de `build/sf2ne.nes`: `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` (idêntico).
- `src/bank_20.s`: **0** labels `D20_*` restantes; os 144 `.byte`/`.word` do banco mantêm os mesmos operandos (só comentários gerados mudaram).
- `src/bank_37.s` / `src/bank_3B.s` / `src/bank_3C.s`: as únicas mudanças são a troca de `D20_*` pelos novos nomes, com os mesmos endereços nos comentários (`; F29B E5`, `; E57D 09 85`, `; 84B6 91 83`, …).
- `src/bank_05.s` (Ken, fonte manual): **0** referências a `D20_*`.
- Métrica canônica após o lote: `defs=2145`, `unique=2141`, `autoL=0`, `autoD=1135` (antes: 1.165), `semantic unique=1006` (antes: 976), `semantic sum=1010` (antes: 980).

