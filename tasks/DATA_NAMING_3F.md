# Naming de dados — lote 2: banco `$3F` (núcleo de luta)

- **Status:** **APLICADO** em `annotations/sf2ne.ann`; build e SHA-1 validados.
- **Escopo:** os 15 labels automáticos `D3F_*` de `src/bank_3F.s`.
- **Fonte de verdade:** `annotations/sf2ne.ann`, `docs/FORMATOS.md` §11–§15 e leitura dos consumidores no próprio `src/bank_3F.s`.
- **Regra:** só labels e comentários mudam; bytes e SHA-1 do ROM devem permanecer idênticos.

## 1. Evidência usada

| Fluxo | Onde | O que prova |
|-------|------|-------------|
| `ProjLaunch` | `3F:E837-E853` | `D3F_E064` = ΔX de nascimento; `D3F_E05E` = passo por velocidade |
| `ProjUpdate` | `3F:E854-E89D` | `D3F_E05B` = Y de nascimento; `D3F_E05E` = passo por subquadro |
| `MoveVelSetup` | `3F:E4C2-E4CD` | `D3F_E4CE`/`$E4D4` = despacho `endereço-1` por `MoveMode` (absoluta/aceleração/subpixel) |
| `MoveDispatch_F0A5` | `3F:F0A5-F0B0` | `D3F_F0B1`/`$F0B7` = despacho `endereço-1` por `MoveMode` (aplicação do movimento) |
| `PostProc` / `RoundStart2` | `3F:EDE9-EE24` | `D3F_EF20`/`$EF06` (solo) e `$EF2D`/`$EF13` (neutro/ar): knockback Y/X por classe |
| `HitDamageHeavy` | `3F:EE27-EE3D` | `D3F_EF3A` = nova classe de reação ao derrubar |
| `HitDamageKO` | `3F:EEF7-EF03` | `D3F_EF47` = nova classe de reação no KO |
| `AnimUpdate_EE78` → `HitDamageSfx` | `3F:EE78-EEC4` | `D3F_E055` = sfx de impacto por classe do atacante |
| `CmdMotionAdvance` | `3F:EB73-EB7D` | `D3F_E068` = `CmdMotionTbl+1` (leitura do próximo byte com o mesmo índice) |

`docs/FORMATOS.md` §11 (acerto e dano) e §15 (índice de tabelas auxiliares) já descrevem essas tabelas com os mesmos endereços, o que confirma a leitura do código.

Convenções: sufixo `Tbl` para tabela de dados; `Lo`/`Hi` para as duas metades de um despacho `endereço-1` (como `CmdStepLo`/`CmdStepHi`); nomes em inglês.

## 2. Projétil

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `3F:E05B` | 3 (2 usados) | `ProjUpdate` | `ProjSpawnYOffsetTbl` | ALTA |
| `3F:E05E` | 6 (2 usados) | `ProjLaunch`/`ProjUpdate` | `ProjSpeedStepTbl` | ALTA |
| `3F:E064` | 3 (2 usados) | `ProjLaunch` | `ProjSpawnXOffsetTbl` | ALTA |

## 3. Impacto e reação

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `3F:E055` | 6 (3 usados) | `AnimUpdate_EE78` → `HitDamageSfx` | `HitSfxTbl` | ALTA |
| `3F:EF06` | 13 | `PostProc` (solo/agachado) | `KnockbackXGroundTbl` | ALTA |
| `3F:EF13` | 13 | `RoundStart2` (neutro/ar) | `KnockbackXAirTbl` | ALTA |
| `3F:EF20` | 13 | `PostProc` (solo/agachado) | `KnockbackYGroundTbl` | ALTA |
| `3F:EF2D` | 13 | `RoundStart2` (neutro/ar) | `KnockbackYAirTbl` | ALTA |
| `3F:EF3A` | 13 | `HitDamageHeavy` | `KnockdownReactTbl` | ALTA |
| `3F:EF47` | 45 (13 usados) | `HitDamageKO` | `KOReactTbl` | ALTA |

> `KnockbackX/YGround` cobre “em pé/agachado”; `KnockbackX/YAir` cobre “neutro/no ar”, conforme `docs/FORMATOS.md` §11. A separação Ground/Air é a que o próprio código usa (`FighterState & 3`).

## 4. Despachos de movimento (`endereço-1`, truque do `RTS`)

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `3F:E4CE` | 6 | `MoveVelSetup` | `MoveVelDispatchLo` | ALTA |
| `3F:E4D4` | 6 | `MoveVelSetup` | `MoveVelDispatchHi` | ALTA |
| `3F:F0B1` | 6 | `MoveDispatch_F0A5` | `MoveApplyDispatchLo` | ALTA |
| `3F:F0B7` | 6 | `MoveDispatch_F0A5` | `MoveApplyDispatchHi` | ALTA |

## 5. Alias de tabela

| Endereço | Bytes | Consumidor | Nome proposto | Confiança |
|----------|-------|------------|---------------|-----------|
| `3F:E068` | 71 | `CmdMotionAdvance` (`EB79`) | `CmdMotionTblNext` | MÉDIA |

> `E068` é exatamente `CmdMotionTbl+1` (a tabela começa em `E067`). O gerador criou um label separado porque `EB79` referencia `E068` diretamente. `CmdMotionTblNext` documenta essa vista deslocada sem fingir que é uma tabela independente. Se preferir, este label pode continuar automático.

## 6. Riscos e validação

- **Risco:** baixo. Nenhuma diretiva `.byte`/`.word`/`.patch` é tocada; só entram linhas `label 3F:XXXX <Nome>` em `annotations/sf2ne.ann`.
- **Efeito colateral esperado:** `src/bank_3F.s` e `src/globals.inc` passam a usar os novos nomes; comentários gerados que citam `D3F_*` também mudam (texto, não byte).
- **Validação obrigatória:**
  1. `make gen` sem erro;
  2. `make` sem erro;
  3. SHA-1 de `build/sf2ne.nes` = `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1`;
  4. `git diff -U0 -- src` sem nenhuma linha `.byte`/`.word`;
  5. conferir que `src/bank_05.s` não referencia `D3F_*` (Ken é fonte manual).
- **Fora de escopo (documentar depois):** `docs/FORMATOS.md` §15 diz que `CmdMotionTbl` tem 64 bytes (16 golpes × 4), mas a tabela real vai de `E067` a `E0AE` (72 bytes, 18 chaves × 4). Não corrigir neste lote.

## 7. Resultado da aplicação

Os 15 nomes foram aplicados em `annotations/sf2ne.ann`. Validação executada:

- `make gen`: OK; `src/bank_3F.s` e `src/globals.inc` regenerados apenas com os novos nomes.
- `make`: OK.
- SHA-1 de `build/sf2ne.nes`: `3ad177a0a7867a821e6c1709b4e6dbdda3555aa1` (idêntico).
- Diretivas `.byte`/`.word` de `src/bank_3F.s`: **155 antes, 155 depois, operandos idênticos**; só comentários e labels mudaram.
- `src/bank_05.s` (Ken, escrito à mão) não referencia `D3F_*`.
- Métrica canônica após o lote: `autoD=1165`, `semantic=976` (antes: 1.180 / 961).
- `docs/FORMATOS.md` §11/§15 atualizado para os novos nomes; de passagem, corrigidos os tamanhos de `E05B`/`E05E`/`E064`, de `CmdMotionTbl` (72 bytes, 18 chaves) e de `CmdKeyAttackTbl` (17 bytes).
