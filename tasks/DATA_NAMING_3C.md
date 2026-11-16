# Naming de dados — lote 1: banco `$3C` (fichas, paletas e retratos)

- **Status:** **APLICADO** em `annotations/sf2ne.ann`; build e SHA-1 validados.
- **Escopo:** os 33 labels automáticos `D3C_*` de `src/bank_3C.s`.
- **Fonte de verdade:** `annotations/sf2ne.ann` (labels/comentários) + leitura dos consumidores em `src/bank_3B.s` e `src/bank_3F.s`.
- **Regra:** só labels e comentários mudam; bytes e SHA-1 do ROM devem permanecer idênticos.

## 1. Evidência usada

| Fluxo | Onde | O que prova |
|-------|------|-------------|
| `FighterLoadChar` | `3B:E000-E097` | carrega 23 tabelas de 10 bytes (uma coluna por personagem) do `$3C` |
| `InputDispatch` / `TransViaTbl` | `3F:F695-F703` | consome as tabelas de transição por direção, ataque e especial |
| `GuardRedirect` | `3F:F704-F74B` | consome a tabela de reação de guarda por `HitReactClass` |
| `HitDamageReact` / `AnimUpdate_EE78` | `3F:EE4E-EEB5` | consome as tabelas de reação de dano por fase (`FighterState & 3`) |
| `PortraitLoadPalettes` | `3B:E181-E1F5` | soma `FighterChar*12` e lê 3 paletas (9 cores) de 3 tabelas |
| `PortraitSetupP1/P2` | `3B:EE38-EF60` | escolhe tabelas de paleta/layout/tiles de vitória e derrota |
| `RoundIntro_DrawNames` | `3B:E63E-E684` | usa o comprimento do nome para centralizar/limpar o nome na tela |

Convenções propostas: prefixo `Char` para tabelas indexadas por personagem; sufixo `Tbl`; `Lo`/`Hi` para as duas metades de um ponteiro; `Portrait*` para dados exclusivos do retrato.

## 2. Ficha do personagem — 20 tabelas de ponteiros (10 bytes cada)

Cada linha é um campo da ficha: 1 byte por personagem (10 personagens). O par `Lo`/`Hi` forma um ponteiro de 16 bits.

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `3C:8000` | 10 | `FighterLoadChar` → `ram_031E`; `InputDispatch` | `CharDirTransLoTbl` | ALTA |
| `3C:800A` | 10 | `FighterLoadChar` → `ram_0320` | `CharDirTransHiTbl` | ALTA |
| `3C:8014` | 10 | `FighterLoadChar` → `ram_0322`; `InputDispatch` | `CharAttackTransLoTbl` | ALTA |
| `3C:801E` | 10 | `FighterLoadChar` → `ram_0324` | `CharAttackTransHiTbl` | ALTA |
| `3C:8028` | 10 | `FighterLoadChar` → `ram_0326`; `InputDispatch` | `CharSpecialTransLoTbl` | ALTA |
| `3C:8032` | 10 | `FighterLoadChar` → `ram_0328` | `CharSpecialTransHiTbl` | ALTA |
| `3C:803C` | 10 | `FighterLoadChar` → `ram_032A`; `GuardRedirect` | `CharGuardReactLoTbl` | ALTA |
| `3C:8046` | 10 | `FighterLoadChar` → `ram_032C` | `CharGuardReactHiTbl` | ALTA |
| `3C:8050` | 10 | `FighterLoadChar` → `ram_032E`; fase 1 do dano | `CharHitReact1LoTbl` | MÉDIA |
| `3C:805A` | 10 | `FighterLoadChar` → `ram_0330` | `CharHitReact1HiTbl` | MÉDIA |
| `3C:8064` | 10 | `FighterLoadChar` → `ram_0336`; fase 2 do dano | `CharHitReact2LoTbl` | MÉDIA |
| `3C:806E` | 10 | `FighterLoadChar` → `ram_0338` | `CharHitReact2HiTbl` | MÉDIA |
| `3C:8078` | 10 | `FighterLoadChar` → `ram_0332`; fase 0 do dano | `CharHitReact0LoTbl` | MÉDIA |
| `3C:8082` | 10 | `FighterLoadChar` → `ram_0334` | `CharHitReact0HiTbl` | MÉDIA |
| `3C:808C` | 10 | `FighterLoadChar` → `ram_033A`; `HitReactClass=$0C` | `CharHitReact12LoTbl` | MÉDIA |
| `3C:8096` | 10 | `FighterLoadChar` → `ram_033C` | `CharHitReact12HiTbl` | MÉDIA |
| `3C:80A0` | 10 | `FighterLoadChar` → `ram_033E`; reconhecedor `3F:EA24` | `CharCmdListLoTbl` | ALTA |
| `3C:80AA` | 10 | `FighterLoadChar` → `ram_0340` | `CharCmdListHiTbl` | ALTA |
| `3C:80B4` | 10 | `FighterLoadChar` → `ram_0342`; IA do lutador | `CharAiScriptLoTbl` | ALTA |
| `3C:80BE` | 10 | `FighterLoadChar` → `ram_0344` | `CharAiScriptHiTbl` | ALTA |

> `CharHitReact0/1/2/12` vêm de `FighterState & 3` em `3F:EE94-EEB5` e de `HitReactClass=$0C` em `3F:EE51`. A ordem 0/1/2 é a das fases lidas no código, não a ordem física no arquivo.

## 3. Ficha do personagem — tabelas auxiliares

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `3C:80DC` | 10 | `FighterLoadChar` → `zp_1C`; `LoadHitBoxes` | `CharHitBoxBankTbl` | ALTA |

## 4. Paletas (12 bytes por personagem: 3 cores + 3 de passo)

`PortraitLoadPalettes` soma `FighterChar*12` e lê 3 bytes de cada uma das 3 tabelas. As tabelas 0/1/2 abastecem `ram_0300/0303/0306`.

| Endereço | Bytes | Uso no código | Nome proposto | Confiança |
|----------|-------|---------------|---------------|-----------|
| `3C:80E6` | 120 | `FighterRoundInit` → paleta 0 da luta | `CharPal0FightTbl` | MÉDIA |
| `3C:815E` | 120 | `FighterRoundInit` → paleta 1 da luta | `CharPal1FightTbl` | MÉDIA |
| `3C:83B6` | 120 | 3ª paleta compartilhada (luta/vitória/derrota) | `CharPal2Tbl` | ALTA |
| `3C:81D6` | 120 | `PortraitP1WinSet`/`P2WinSet` → paleta 0 da vitória | `CharPal0WinTbl` | MÉDIA |
| `3C:824E` | 120 | `PortraitP1WinSet`/`P2WinSet` → paleta 1 da vitória | `CharPal1WinTbl` | MÉDIA |
| `3C:82C6` | 120 | `PortraitP1LoseSet`/`P2LoseSet` → paleta 0 da derrota | `CharPal0LoseTbl` | MÉDIA |
| `3C:833E` | 120 | `PortraitP1LoseSet`/`P2LoseSet` → paleta 1 da derrota | `CharPal1LoseTbl` | MÉDIA |

## 5. Retratos — tiles, layouts e nomes

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `3C:842E` | 60 | `PortraitTilesP1/P2` (vitória), 6 bytes por personagem | `PortraitWinTilesTbl` | ALTA |
| `3C:846A` | 60 | `PortraitP1LoseTiles`/`P2LoseTiles`, 6 bytes por personagem | `PortraitLoseTilesTbl` | ALTA |
| `3C:84A6` | 20 | `PortraitP1WinSet`/`P2WinSet`, 1 word por personagem | `PortraitWinLayoutTbl` | ALTA |
| `3C:84BA` | 20 | `PortraitP1LoseLayout`/`P2LoseLayout`, 1 word por personagem | `PortraitLoseLayoutTbl` | ALTA |
| `3C:851E` | 10 | `RoundIntro_DrawNames` e `PortraitNameDestCalc` | `CharNameLenTbl` | ALTA |

## 6. Riscos e validação

- **Risco:** baixo. Nenhuma diretiva `.byte`/`.word`/`.patch` é tocada; só entram linhas `label 3C:XXXX <Nome>` em `annotations/sf2ne.ann`.
- **Efeito colateral esperado:** `src/bank_3C.s`, `src/globals.inc` e os comentários gerados passam a usar os novos nomes; `src/bank_05.s` não referencia `D3C_*`.
- **Validação obrigatória:**
  1. `make gen` sem erro;
  2. `make` sem erro;
  3. SHA-1 de `build/sf2ne.nes` = `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`;
  4. diff de `annotations/sf2ne.ann` contendo apenas linhas `label`;
  5. `git diff --stat` mostrando mudanças só em `annotations/`, `src/bank_3C.s`, `src/globals.inc` e comentários correlatos.

## 7. Resultado da aplicação

Os 33 nomes foram aplicados em `annotations/sf2ne.ann`. Validação executada:

- `make gen`: OK; `src/bank_3C.s`, `src/bank_3B.s` e `src/globals.inc` regenerados apenas com os novos nomes.
- `make`: OK.
- SHA-1 de `build/sf2ne.nes`: `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` (idêntico).
- Diff de dados: **0** linhas `.byte`/`.word` alteradas; 33 labels trocados.
- `src/bank_05.s` (Ken, escrito à mão) não referencia `D3C_*`, portanto não foi tocado.
- Métrica canônica após o lote: `autoD=1180`, `semantic=961` (antes: 1.213 / 928).

