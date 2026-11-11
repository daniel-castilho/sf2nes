# Formatos de dados — Street Fighter II NE (DEMO, Parisoft)

Referência campo a campo dos dados que dirigem o motor de luta: ficha de personagem, estados,
animações, sprites, colisão, dano, comandos e IA. Este é o documento da Etapa 1 do roteiro
(`docs/ROTEIRO.md`): cada tabela aqui foi lida no código desmontado e conferida nos bytes do ROM.
Onde a leitura não é garantida está marcado **(hipótese)**; código que nenhum trace executou está
marcado **(nt)**. A visão geral de como as peças se encaixam está em `docs/ARQUITETURA.md` §4.

Convenções:

* `BB:AAAA` = banco de PRG de 8 KB + endereço de CPU. Ponteiros de 16 bits são little-endian (lo
  primeiro). Bytes com sinal: `$80`–`$FF` são negativos.
* **Banco de frames** = o mapeado em `$8000` por `FighterFrameBank` (`$00` no Ryu): metasprites e
  caixas de colisão. **Banco de estados** = o mapeado em `$A000` por `FighterStateBank` (`$01` no
  Ryu): estados e quadros de animação.
* Tudo é **por lutador**: X = 0 (P1) ou 1 (P2) indexa as variáveis `Fighter*` e as cópias de tabela
  em `ram_03xx`.
* Os números de censo (71 estados / 274 quadros do Ryu) são do gerador (`make gen`); as
  estatísticas por campo saem de `tools/frame_census.py`, que só enxerga os **269 quadros
  alcançáveis** (os 5 órfãos de §2 ficam fora) — por isso os totais das seções abaixo dão 269.

Sumário: §1 ficha · §2 banco de estados · §3 cabeçalho de estado · §4 condições · §5 caminhador ·
§6 quadro · §7 efeitos · §8 movimento · §9 metasprite · §10 colisão · §11 acerto e dano ·
§12 projetil · §13 comandos · §14 IA · §15 índice de tabelas.

---------------------------------------------------------------------------------------------------

## 1. A ficha do personagem (banco `$3C`)

`FighterLoadChar` (`3B:E000`) carrega a coluna `FighterChar` de cada lutador: **10 pares de
tabelas** (uma de bytes baixos, outra de altos, com 10 posições cada — uma por personagem) que
apontam as tabelas do banco de estados, e 3 tabelas de bytes avulsas. Tudo vira cópia por lutador
na RAM (`ram_031E`–`ram_0344`), lida pelo motor sem tocar no banco `$3C` de novo.

| Par no banco `$3C` | Copiado para | Tabela apontada | Papel |
|---|---|---|---|
| `$8000`/`$800A` | `ram_031E` | `$A000` | estados por **direção** (9 entradas) |
| `$8014`/`$801E` | `ram_0322` | `$A012` | estados por **botão** (4) |
| `$8028`/`$8032` | `ram_0326` | `$A01A` (`RyuSpcTrans`) | **golpes especiais** (6 no Ryu) |
| `$803C`/`$8046` | `ram_032A` | `$A026` | **defesas** (12) |
| `$8050`/`$805A` | `ram_032E` | `$A03E` | reação de dano **em pé** (12) |
| `$8064`/`$806E` | `ram_0336` | `$A056` | reação de dano **agachado** (12) |
| `$8078`/`$8082` | `ram_0332` | `$A06E` | reação de dano **neutra** (12) |
| `$808C`/`$8096` | `ram_033A` | `$A086` | **agarrões** (12) |
| `$80A0`/`$80AA` | `ram_033E` | fora do banco de estados | lista de especiais do reconhecedor (`CmdKeyListRyu`, `3F:E0C0`) |
| `$80B4`/`$80BE` | `ram_0342` | fora do banco de estados | tabela de roteiros de IA (`00:8E72`) |

| Tabela de bytes | Copiado para | Papel |
|---|---|---|
| `$80C8` `CharStateBankTbl` | `FighterStateBank` | banco dos estados (janela `$A000`) |
| `$80D2` `CharFrameBankTbl` | `FighterFrameBank` | banco dos frames (janela `$8000`) |
| `$80DC` | `zp_1C` | banco das caixas de colisão (janela `$8000`, mesmo valor do de frames) |

Detalhe: o byte alto do 1º par é lido **sem índice** (`lda $800A`). Funciona porque todo banco de
estados é mapeado em `$A000`, então o byte alto é sempre `$A0` — um personagem novo só precisa
manter suas tabelas em `$A000`–`$BFFF` do banco dele.

Coluna do Ryu (id 0): estados no banco `$01`, frames/colisão no `$00`, lista de especiais
`3F:E0C0`, roteiros de IA `00:8E72`. Só a coluna 0 está preenchida.

`FighterRoundInit` (`3B:E098`) começa o round: P1 nasce em X=`$5A`, P2 em X=`$A6`, ambos Y=`$CD`
(chão) e HP cheio `$58` (88); P2 nasce espelhado (`FighterFlip=$40`). O estado inicial é o alvo da
**cadeia natural** (+3/+4) do 1º estado da tabela de direções (o neutro), com a classe `$59`
gravada à mão.

## 2. O banco de estados — layout

O banco de estados é uma pilha de words e depois uma sequência de registros. No Ryu (`$01`):

1. **8 tabelas de ponteiros**, words consecutivas (`lo,hi`), entradas `$0000` = vaga:
   `$A000` (9), `$A012` (4), `$A01A` (6), `$A026` (12), `$A03E` (12), `$A056` (12), `$A06E` (12),
   `$A086` (12) — papel e índice de cada uma na tabela da §1 e do §13.
2. padding `$00` até `$A0AF`;
3. **registros** de `$A0B0` a `$B1C6`: cabeçalhos de estado de 7 bytes (§3), cada um seguido dos
   seus quadros de animação (§6). O primeiro quadro do estado mora em `cabeçalho + 7`.

Censo do Ryu: **71 estados, 274 quadros**. Três registros não têm ponteiro conhecido apontando
para eles (o gerador marca com `[nenhum ponteiro conhecido aponta para ca]`): os estados `$A388`
(classe `$59`) e `$A432` (classe `$29`) e o quadro `$B02D` (pulado pela cadeia de quadros, que vai
direto para `$B03B`) — dados mortos deixados pelo autor do demo.

## 3. Cabeçalho de estado — 7 bytes

| Desl. | Campo | Conteúdo |
|---|---|---|
| +0 | condição | `$00`–`$0B` (§4); `≥ $80` (na prática `$FF`) = incondicional |
| +1, +2 | alternativa | ponteiro para o próximo nó a testar se esta condição falhar; `0` = fim da lista |
| +3, +4 | cadeia natural | ponteiro para o estado seguinte quando a animação deste termina (`StateAdvance`) |
| +5 | classe | byte gravado em `FighterState` ao entrar no estado (famílias abaixo) |
| +6 | acertos | `AttackHitsLeft`: quantas caixas de ataque o estado ainda pode cravar (0, 1, 2 ou 6 nos dados reais; 6 = tatsumaki) |

Famílias da classe (+5) — a parte alta escolhe som e comportamento, os 3 bits baixos são a
postura (bit 0 = em pé, bit 1 = agachado, bit 2 = no ar **(hipótese)**; a favor: pulos
`$5C`/`$64`/`$6C`, golpes aéreos `$74`/`$84`/`$8C`/`$9C` e reação `$34` têm o bit; contra:
`$9C` também cobre o soco forte no chão):

| Faixa | Significado |
|---|---|
| `$29`/`$2A` | guarda em pé / agachada (`GuardRedirect`, teste do chip) |
| `$30`–`$39` | reação a dano; `$30`: se HP ≤ dano pendente, usa a alternativa +1/+2 (morte) |
| `$49` | caso especial: com `zp_62≠0` (derrubado) usa a alternativa +1/+2 (`AnimAdvance`) |
| `$4C`, `$51` | vistos 1× cada, sem semântica decifrada (Fase 2) |
| `$58`–`$6F` | aceita input de direção (§13); `$59` = parado (estado inicial, gravado à mão no round init), `$61` = andar, `$5C`/`$64`/`$6C` = pulos |
| `$70`–`$98` | toca efeito sonoro ao entrar (`StateSetByte`); golpe em andamento |
| `$99`–`9F` | idem, sem som |
| `$A0`–`E0` | toca voz do lutador ao entrar; `$A0`–`$A9` = virar (com input de trás vira o oponente = agarrão) |
| `$F0`+ | caído (`CondVitoria` checa `≥ $F0`) |

Golpes especiais do Ryu (para referência): hadouken `$B1`/`$B9` (dano vem do projetil, 0 acertos),
shoryuken `$C4`/`$CC` (2 acertos), tatsumaki `$D4`/`$DC` (6 acertos).

Censo real das 39 classes (71 estados): `29`×5 `2A`×5 `30`×2 `31`×8 `32`×4 `34`×4 `39`×1 `49`×1
`4C`×1 `51`×1 `59`×5 `5A`×3 `5C`×1 `61`×1 `64`×1 `69`×1 `6C`×1 `71`×2 `72`×1 `74`×1 `81`×2
`82`×1 `84`×1 `89`×1 `8A`×1 `8C`×1 `99`×2 `9A`×1 `9C`×2 `A1`×1 `B1`×1 `B9`×1 `C4`×1 `CC`×1
`D4`×1 `DC`×1 `E9`×1 `F0`×1 `F1`×1. Condições: 27 nós com condição, 44 incondicionais (`$FF`);
acertos (+6): 0×50, 1×16, 2×3, 6×2.

Exemplo real (o 1º estado do banco, pose de vitória):

```
D01_A0B0:   ; cond=$0A CondVitoria | classe=$E9 | acertos=0
    .byte $0A          ; +0  vitoria
    .word D01_A10B     ; +1/+2 alternativa
    .word D01_A12E     ; +3/+4 cadeia natural
    .byte $E9          ; +5  classe (voz na entrada, caido)
    .byte $00          ; +6  acertos
    ; primeiro quadro em $A0B7...
```

## 4. As 12 condições

O byte +0 do cabeçalho despacha por `StateCondDispatch` (`3F:E168`): a tabela `3F:E171` (diretiva
`statecond 3F:E171 n=12` no `.ann`) tem 12 words com **endereço−1** (truque do RTS). Valores
`≥ $80` nem passam pelo despacho. Números `$0C`–`$7F` não existem nos dados do Ryu.

| # | Nome (`3F:xxxx`) | Verdadeiro quando |
|---|---|---|
| `$00` | CondOponenteAtaca (E189) | eu em pé/agachado E o oponente em reação (`$70`–`$98`), golpe (`$B0`–`$E0`) ou com projetil no ar |
| `$01` | CondOponenteLongeCostas (E1B1) | `\|ΔX\| ≥ $0F` e eu de costas para ele; devolve `$40` (o bit de flip) |
| `$02` | CondOponentePerto (E1D6) | `\|ΔX\| < $21` |
| `$03` | CondEmPe (E1ED) | bit 0 da minha classe |
| `$04` | CondAgachado (E1F3) | bit 1 da minha classe |
| `$05` | CondNoAr (E1F9) | `FighterY < FloorY` |
| `$06` | CondNoChaoOuVelX (E204) | no chão ou deslizando (`VelX`/`VelXSub` ≠ 0) |
| `$07` | CondInputBaixo (E212) | `InputDir` = `$08`/`$0B`/`$0C`; devolve o próprio `InputDir` |
| `$08` | CondProjetilLivre (E224) | minha vaga de projetil livre (`ProjX` = 0) |
| `$09` | CondPodeAgarrar (E22E) | `\|ΔX\| < $18`, ambos no chão, direção frente/trás e classe do oponente < `$30` ou `$50`–`$9F` |
| `$0A` | CondVitoria (E271) | round meu, oponente caído (`≥ $F0`), sem projéteis no ar e canal de voz livre |
| `$0B` | CondRoundPerdido (E296) | round encerrado sem ser meu (vale para empate) |

`CondOponenteLongeCostas` devolve o byte completo do espelhamento (`$00`/`$40`): fora do
caminhador (que só testa ≠ 0), esse valor é o que se grava em `FighterFlip` para virar — ver
flag bit 4 na §6.

## 5. O caminhador de transições

Por quadro, para cada lutador (`FighterUpdate` → `3F:EFCE`): input/IA → `InputDispatch` →
decrementa `AnimTimer` (0 → `AnimAdvance`) → `ProjUpdate` → re-face (flag bit 4).

**`StateCheckTransitions` (`3F:E0CE`)** recebe em `zp_D7/zp_D8` a lista e em `zp_DD` a origem
(`$01` especial, `$02` botão, `$04` guarda/dano/reação). Andar:

1. Pré-filtros por origem: com `zp_DD=$04`, um nó igual ao estado atual é pulado (exceto se a
   classe atual `& $F8` é `$28` — guarda `$28`–`$2F` — ou `$30` — reação `$30`–`$37`); com
   `zp_DD=$02` durante um golpe com som (classe `$70`–`$98`), só o próprio nó atual passa.
2. Fora desses casos: se a minha classe não tem o bit 2 (no ar, §3), testa
   `CondOponenteLongeCostas` — de costas e longe, o nó é pulado (não reage de costas).
3. Testa o nó: `+0 ≥ $80` = verdadeiro na hora; senão chama a condição (§4).
4. Verdadeiro → `TransApply` (`3F:E13B`): grava `FighterNextPtr` = endereço do nó; para classes
   `$28`–`$40` e `$B0`–`$E0` força `AnimTimer=1` (o golpe começa no próximo quadro), a menos que
   o quadro atual tenha a flag bit 3.
5. Falso → `TransNextNode` (`3F:E129`): segue +1/+2 e repete; ponteiro `0` = fim, nada muda.

O commit de `FighterNextPtr` acontece em `AnimAdvance` (`3F:E2A6`): o nó vira
`FighterStatePtr`, o 1º quadro é `nó+7`, a classe passa por `StateSetByte` (grava `FighterState`
e dispara som/voz da família) e +6 vai para `AttackHitsLeft`.

Quem alimenta o caminhador:

* `TransViaTbl` (`3F:F6F5`): lê a word da tabela de input e chama o caminhador;
* `InputDispatch` (§13) — direção/botão/especial;
* `GuardRedirect` (§13) — defesa;
* rotina de dano (§11) — reação;
* `AnimAdvance` — uma transição pendente vence o avanço natural do quadro; classe `$49` com
  `zp_62≠0` desvia para a alternativa +1/+2 do estado atual; sem transição e sem hit-freeze,
  avança os quadros (laço §6) e, no fim, `StateAdvance` (`3F:E371`) segue a cadeia natural +3/+4
  (com a exceção da classe `$30` morta, que usa +1/+2).

## 6. Quadro de animação — 14 bytes (16 se houver laço)

| Desl. | Campo | Conteúdo |
|---|---|---|
| +0 | duração | quadros de vídeo (1–100 nos dados reais) |
| +1, +2 | metasprite | ponteiro no banco de frames (§9) |
| +3, +4 | colisão | ponteiro para as caixas (§10); `0` = nenhuma |
| +5 | parâmetro | ver §7 |
| +6 | tipo do efeito | ver §7 |
| +7 | flags | ver abaixo |
| +8 | modo de movimento | 0–5, ver §8 |
| +9, +10 | VelX / VelY | com sinal, interpretados conforme +8 |
| +11 | repetições | laço: quantas vezes repetir o desvio antes de seguir |
| +12, +13 | próximo quadro | `0` = fim da animação (`StateAdvance`) |
| +14, +15 | desvio do laço | **só se +11 ≠ 0**: para onde voltar enquanto o laço não zerar |

Flags (+7 → `FrameFlags`):

| Bit | Efeito |
|---|---|
| 0 (`$01`) | quadro aceita **golpe especial** (tabela `ram_0326`) |
| 1 (`$02`) | quadro aceita **golpe por botão** (tabela `ram_0322`; seta `BtnAHold`/`BtnBHold=$15`) |
| 2 (`$04`) | quadro aceita **direção** (tabela `ram_031E`) |
| 3 (`$08`) | não forçar `AnimTimer=1` na transição (§5) |
| 4 (`$10`) | re-face: a cada quadro grava `FighterFlip=$40`/`$00` conforme o lado do oponente (`3F:EFCE`) |
| 5 (`$20`) | isento da trava de borda de X (`$20`–`$E0`) e do ajuste de velocidade perto do canto (§8); bloqueia o `GuardRedirect` (§13) |
| 6 (`$40`) | travado na borda, o transbordo do clamp é somado ao X do **oponente** (`F62C`) — o empurrão "atravessa" a vítima |
| 7 (`$80`) | não usado nos dados do Ryu |

Censo das flags: bit 5 em 36 quadros (fl `$20`×22 + `$30`×14) — todos com caixa de colisão e sem
efeito, nos estados de guarda/reação: o tremor de ±2 px que antecede o deslizamento; bit 6 em 34
(fl `$40`×33 + `$50`×1) — os deslizamentos longos (dur 19–36, modo `$02`).

O laço funciona assim (`AnimAdvance`): com `LoopRepeat` (+11) ≠ 0, decrementa e, enquanto não
zerar, salta para +14/+15; zerou ou +11 = 0 → segue +12/+13.

Exemplo real — o 3º quadro do chute forte de longe (estado `$ABE2`: 1º `ABE9`, 2º `ABF7`) e,
embaixo, um laço do tremor de guarda:

```
D01_AC05:  ; dur=6 efe=$12/$C2 fl=$00 mov=$04 vx=0 vy=0 rep=0
    .byte $06           ; +0  6 quadros
    .word D00_87E2      ; +1/+2 metasprite
    .word D00_9356      ; +3/+4 caixas de colisao (o exemplo da secao 10)
    .byte $12           ; +5  dano 18
    .byte $C2           ; +6  golpe: bloqueavel nas 2 posturas, classe de reacao 2
    .byte $00,$04,$00,$00,$00   ; +7..+11
    .word D01_AC13      ; +12/+13 proximo quadro

D01_A439:  ; dur=1 efe=$00/$00 fl=$30 mov=$04 vx=-32 vy=0 rep=0
D01_A447:  ; dur=1 efe=$00/$00 fl=$30 mov=$04 vx=32 vy=0 rep=7 br=$A439 (16 bytes)
```

No exemplo: `AC05` é um quadro de ataque típico — duração 6, dano 18 (`$12`), tipo `$C2` (golpe
bloqueável nas duas posturas, classe de reação 2 — §7), caixa de colisão ativa (§10) e sem
deslocamento (`mov $04`, vx=0). `A439`/`A447` são o tremor do estado órfão `$A432` (§2, guarda):
±32 (`±$20`) = ±2 px por quadro, laço `A447 → A439` repetido 7×, flag bit 5 (isento da trava de
borda, §8). O andar de verdade é outro estado — `D01_A16D` (entrada "frente" da tabela de
direções, classe `$61`): quadros `rep=0` com flags `$17`/`$1F` (aceitam direção, botão e especial)
e `vx = $17` (23) ≈ 1,4 px por quadro, só para frente (§8).

## 7. Efeitos do quadro (+5 parâmetro, +6 tipo)

`+6` é o `EffectType` (o `+5` é o `EffectParam`); aplicados na entrada do quadro
(`FrameEnterCommon`) e no `AnimAdvance`:

| `+6` | Efeito | `+5` significa |
|---|---|---|
| `$00` | nada | — |
| `$01` | não decifrado (1 quadro no Ryu) | — |
| `$0B` | dispara **projetil** (`ProjLaunch`, §12) | velocidade `$00`/`$01`/`$02` (passo em `D3F_E05E`) |
| `$0C` | **agarrão** | dano = `&$1F` (o valor real é `$16` = 22); `>>5` = índice do estado de agarrão do agarrador (§11) |
| `$20` | efeito sonoro (índice) | índice do sfx |
| `$43`/`$8x`/`$Cx` | **golpe** | ver decomposição abaixo |

Golpe (`$43`, `$83`, `$86`, `$C0`, `$C2`, `$C3`, `$C5`, `$C7`, `$C8` nos dados reais):

* bits 6–7 = **posturas que bloqueiam** o golpe: `$40` (só guarda em pé), `$80` (só agachada),
  `$C0` (ambas). A vítima que bloqueia leva chip (§11); a que guarda do jeito errado leva o dano
  cheio;
* bits 0–5 = classe de reação: copiada inteira para `HitReactClass` da vítima e usada com `&$3F`
  para indexar reação, knockback e defesa (valores reais ≤ `$0B`);
* `+5` = dano em `&$1F` (3 a 22 nos dados reais) e **chip** em `>>5` (0–3; só os
  parâmetros `$6B`/`$6F`/`$72` têm chip = 3).

Censo dos 269 quadros alcançáveis (§2): `+6` = `$00`×229, `$01`×1, `$0B`×2, `$0C`×1, `$20`×7,
`$43`×6, `$83`×2, `$86`×1, `$C0`×2, `$C2`×4, `$C3`×1, `$C5`×5, `$C7`×7, `$C8`×1.

## 8. Movimento (+8 modo, +9/+10 VelX/VelY)

**Ao entrar no quadro** (`MoveVelSetup`, `3F:E4C2`), o modo +8 despacha pela tabela
`D3F_E4CE`/`$E4D4` (6 words, endereço−1) e interpreta +9/+10 como velocidade; aqui o bit 0 do
modo não muda nada (0≡1, 2≡3, 4≡5):

| Modo | Rotina | `+9`/`+10` significam |
|---|---|---|
| 0/1 | `MoveVelAbs` (`3F:E4DA`) | velocidade nova, direto (zera o subpixel) |
| 2/3 | `MoveVelAccel` (`3F:E597`) → `MoveVelAdd` (`3F:E53C`) | aceleração: soma com sinal `vel/16` à velocidade atual (Vel, VelSub) |
| 4/5 | `MoveVelSubpixel` (`3F:E4F1`) | `vel/16`: inteiro em `Vel`, resto `×16` em `VelSub` |

Censo: modo `$02`×105, `$04`×143, `$01`×12, `$05`×8, `$00`×1. Andar usa `$04` com `+$17` =
23/16 ≈ 1,4 px por quadro, **só para frente** — segurar trás é guarda (entrada 2 da tabela de
direções, §13); o ±32 = ±2 px é o tremor de guarda/reação (§6); pulos usam `$02`/`$04` com `VelY`
negativo.

**A cada quadro**, a aplicação despacha de novo pelo modo (`L3F_F0A5`, tabela `D3F_F0B1`): o modo
`$00` posiciona **relativo ao oponente** (`F0BD`: X = X do oponente ± `VelX`, consumido — o quadro
da vítima de agarrão, único do censo); os outros são absolutos: `$01` aplica direto (`F0F2`),
`$02`/`$03` integram `VelY` com chão e câmera (`F236`) e `$04`/`$05` aplicam `VelX` com regras de
canto (`F377`). Depois de mover: lutadores sobrepostos (mesma altura, |ΔX| < $10) se empurram
metade da invasão (máx. 2 px) e `L3F_F5CD` trava o X de cada um em `$20`–`$E0`, guardando o
transbordo em `zp_E1`/`zp_E2` (cruzados: cada um grava no slot do outro). O flag bit 5 isenta o
quadro da trava; com o bit 6, o transbordo é somado ao X do **oponente** (`F62C`) — o knockback
no canto empurra o atacante junto. E a vítima de agarrão (`HitReactClass & $3F = $0C`) que se
moveu e ficou travada na borda com a câmera no limite (`$58`/`$A0`) escapa do agarrão (`F648`:
`HitFreeze`, `HitReactClass=0`, sfx `$09`).

## 9. Metasprite (banco de frames)

Cada ponteiro de metasprite do quadro (+1/+2) aponta um **registro**:

```
[página de CHR][sub-metasprite 1][sub-metasprite 2]
     1 byte      ??? bytes             ??? bytes
```

* **Página de CHR** (byte 0): `DrawFighter` (`3B:EDD9`) grava em `FighterChrPage` do lutador; o
  NMI (`kernel.inc`) envia `FighterChrPage`/`FighterChrPage+1` para `$5121`/`$5123` (MMC5).
  O desenho do **projetil** (`3B:F2D0`) lê o byte 0 e o escreve direto em `$5125`.
* Cada **sub-metasprite** = `[atributo][grupos…][terminador]`:
  * `atributo` = byte de atributo da OAM XOR `FighterFlip` OR paleta (`zp_E1`); o 1º
    sub-metasprite usa a paleta do lutador e o 2º usa paleta+2 — o corpo é dividido em duas
    metades com duas paletas (P1: paletas 0 e 2; P2: 3);
  * cada grupo = `[n][dx][dy][n tiles]`: `n` sprites 8x16 lado a lado, X = `FighterX+dx` e o
    próximo tile 8 pixels à direita, Y = `FighterY+dy`, tile = byte + `zp_E4` (`$00` lutador 0,
    `$80` lutador 1 — tiles de cada lutador em metades diferentes da página);
  * espelhado (`FighterFlip`): dx' = `$F8−dx` e cada tile anda −8 (X = `FighterX−8−dx`);
  * X < `$08` (sprite fora da tela à esquerda): o resto do grupo é descartado;
  * `terminador` = byte `≥ $80` (o `$FF` encerra o registro inteiro).
* Registros ficam colados um no outro; `DrawMetasprite` (`3B:F2EA`) é chamado 2× seguidas para
  desenhar os dois sub-metasprites de um lutador.

Exemplo real (`00:8D81`, pose de pé):

```
2B 00 | 02 FA BE 70 72 80 | 00 | 02 F2 BE 58 5A | 03 F2 CE 5C 5E 60 | ... | 80
 ^^    ^^^^^^^^^^^^^^^^^^^    atributo do 2o sub-MS; grupos; terminador >= $80
 |     1o sub-MS: atributo $00, grupo de 2 tiles em dx=$FA dy=$BE, tiles $70/$72
 pagina de CHR $2B
```

## 10. Caixas de colisão (banco de frames)

Ponteiro +3/+4 do quadro → **12 bytes = 3 caixas** `[altura][dy][dx][largura]`: corpo 1, corpo 2
e ataque. Altura `0` = caixa ausente (a de ataque é `0000`-pontada nos quadros sem golpe).

Geometria (com `FighterX`/`FighterY` do lutador):

* topo = `Y + dy`, base = topo + altura;
* sem espelho: esquerda = `X + dx`, direita = esquerda + largura;
* espelhado: direita = `X − dx`, esquerda = direita − largura;
* a caixa de ataque é travada em `$20`–`$E0` (nunca sai da tela).

Exemplo real (`00:9356`, quadro do chute forte de longe — tronco, corpo inteiro e perna esticada):

```
0D BD 00 0E | 36 C8 FB 14 | 0A C8 03 25
corpo1:  h=$0D dy=-67 dx=0    w=14  (tronco)
corpo2:  h=$36 dy=-56 dx=-5   w=20  (corpo inteiro, pra hit de projetil/agarrao)
ataque:  h=$0A dy=-56 dx=3    w=37  (perna ate X+40)
```

## 11. Acerto e dano

**`HitTest` (`3F:ECF1`)**, depois dos dois lutadores andarem: AABB da caixa de ataque do
atacante contra as caixas de corpo 1/2 da vítima. Um acerto por quadro (`HitThisFrame`); cada
acerto **esgota 1 de `AttackHitsLeft`** (por isso o tatsumaki tem 6) e grava na vítima
`HitReactClass = EffectType` do quadro do atacante. Se a classe da vítima é `$A0`–`$A9` (virar) e
ela aperta trás, os papéis se invertem (agarrão) `(nt)`.

**`HitFreeze` (`3F:E000`)**: congela a vítima por `$0E` quadros — salva movimento, velocidades e
timer em `ram_0312`–`$031C` e devolve tudo em `FreezeRestore` (`3F:E301`).

**Rotina de dano (`3F:ED83`)**, chamada por `HitTest` e pelo projetil:

1. **Chip**: vítima em guarda (`classe & $F8 = $28`) e golpe bloqueável na sua postura (bits 6–7
   do tipo AND postura da vítima ≠ 0): dano = `(param >> 5)`, reação pela tabela de defesas
   (`ram_032A`, índice `(classe & $3F)×2`), sem knockback. Golpe não bloqueável nela: segue como
   dano cheio.
2. **Dano**: `FighterDmgPending += param & $1F`; se ficou ≥ `FighterHP` (cheio = `$58` = 88) →
   KO (passo 7). O dano pendente é subtraído do HP uma vez por round-hit (acumula no
   hit-freeze).
3. Já derrubado (`zp_62 ≠ 0`): zera o knockback e pula para a reação.
4. `HitReactClass & $3F = $0B` (projetil): `HitStop = $3C` (congela os DOIS lutadores).
5. **Knockback** (acumula entre hits): vítima em pé/agachada (bits 0–1 da classe) soma
   `D3F_EF06`/`$EF20`; neutra/no ar soma `D3F_EF13`/`$EF2D` — sempre indexadas por
   `classe & $3F`. Acumulou `$20` em `zp_5E` → **derruba**: `zp_62=$78` e classe nova por
   `D3F_EF3A[classe & $3F]`.
6. **Reação**: pela postura da vítima escolhe a tabela (`ram_032E` em pé, `ram_0336` agachada,
   `ram_0332` neutra), pega a word em `(classe & $3F)×2` e chama o caminhador com `zp_DD=$04`.
   Classe `$0C` (agarrão): usa a tabela de agarrões `ram_033A` indexada por
   `(param >> 5) + char_do_agarrador × 4` (quem escolhe o estado é o agarrador). Som de impacto:
   `D3F_E055` (`05 06 07 05 06 07`) indexado pela classe do **atacante**.
7. **KO**: classe nova por `D3F_EF47[classe & $1F]` e segue o passo 6 (reação de derrota).

## 12. Projetil

RAM por lutador: `ProjSpeed $77`, `ProjXSub $79`, `ProjX $7B`, `ProjY $7D`, `ProjStep $7F`,
`ProjFlags $81` (bit 6 = direita, bit 7 = clash). `ProjX = 0` = vaga livre.

* **Nasce** (`ProjLaunch`, `3F:E837`, no `AnimAdvance` do quadro com efeito `$0B`): X =
  `FighterX ± $27` (`D3F_E064`), Y = `FloorY − $27` (`D3F_E05B`), direção = bit 6 do
  `FighterFlip` (vira a cargo do flip do lutador).
* **Anda** (`ProjUpdate`, `3F:E854`): passo por velocidade (`D3F_E05E` = `$17`/`$25` para
  velocidade 0/1), 1/16 por quadro com subpixel (`ProjStep` conta os subpassos). Morre fora de
  `$0C`–`$FB`.
* **Clash** (`ProjClash`, `3F:E8BB`): dois projéteis a `|ΔX| < $18` → os dois ganham bit 7 e
  morrem após 16 passos (animação de choque em `D3B_E595`).
* **Acerto** (`ProjHitTest`, `3F:E8F1`): AABB do projetil (ponto ± `$0C`/`$0B`) contra as caixas
  de corpo; acertou → `ProjHit` (`3F:E941`): morre, `HitReactClass=$CB`, dano `$6C` (12 + chip 3)
  e chama a rotina de dano.
* **Desenho** (`3B:F27F`): metasprites no banco `$20` (HUD/efeitos), tabela `D3B_E57D` indexada
  por velocidade+passo; byte 0 → MMC5 `$5125` direto.

## 13. Comandos

**Input** (`InputUpdate`, `3F:E98D`): lê o controle, monta `InputDir` (já relativo ao lado que o
lutador olha) e `InputAttack`, e roda o reconhecedor de especiais (`InputCommands`, `3F:EA24`).

`InputDir` (`DirCodeTbl`): `$04` neutro, `$05` frente, `$06` trás, `$07` cima, `$08` baixo,
`$09`/`$0A` diagonais cima, `$0B`/`$0C` diagonais baixo. `InputAttack`: 0 soco fraco, 1 soco
forte, 2 chute fraco, 3 chute forte, `$FF` nada — a força vem do **tempo com o botão apertado**
(a origem do atraso, `docs/BUGS.md`).

**`InputDispatch` (`3F:F671`)** — as flags do quadro atual (§6) decidem qual tabela consultar,
sempre como words indexadas `(chave)×2`:

| Flag bit | Tabela | Índice | Marca `zp_DD` |
|---|---|---|---|
| 2 | `ram_031E` (direções) | `InputDir − $04` | `$04` |
| 1 | `ram_0322` (botões) | `InputAttack` (seta `BtnAHold`/`BtnBHold=$15`) | `$02` |
| 0 | `ram_0326` (especiais) | `CmdMoveIdx` | `$01` |

A classe do **nó pendente** (mascarada `& $F8`) decide o que passa: sem nó pendente, tudo.
`< $58` (guarda/reação/intro) ou `≥ $A0` (virar/agarrão `$A1`, especiais, fim de round) → só o
`GuardRedirect`; `$58`–`$6F` → despacho completo; `$70`–`$9F` (golpes) → **só especial** (`F6D6`)
— na janela de buffer dá para enfileirar um especial atrás do golpe, botão não. Os três despachos
correm em sequência (direção → botão → especial), cada um saltando para o próximo quando a flag do
quadro ou a chave falta; o botão exige `InputAttack ≠ $FF`; o especial consome `CmdMoveIdx` (que
volta a `$FF`) e, sem flag ou sem comando, cai no `GuardRedirect`.

**Cadeias de botões** (tabela `ram_0322`/`$A012`, 4 entradas por `InputAttack`; o caminhador segue
a alternativa +1/+2 de cada nó — §5; classe do estado entre parênteses):

| `InputAttack` | nós da cadeia (condição §4 → estado) |
|---|---|
| 0 soco fraco | no ar (`$05`) → `$AD86` (`$8C`) · baixo (`$07`) → `$AD55` (`$8A`) · sempre → `$AD08` (`$89`) |
| 1 soco forte | chão/deslizando (`$06`) → `$AF07` (`$9C`) · no ar (`$05`) → `$AEAC` (`$9C`) · baixo (`$07`) → `$AE51` (`$9A`) · perto (`$02`) → `$ADF6` (`$99`, 2 acertos) · sempre → `$ADA9` (`$99`) |
| 2 chute fraco | no ar (`$05`) → `$ABBF` (`$74`) · baixo (`$07`) → `$AB8E` (`$72`) · perto (`$02`) → `$AB5D` (`$71`) · sempre → `$AB2C` (`$71`) |
| 3 chute forte | pode agarrar (`$09`) → `$AADF` (`$A1`) · no ar (`$05`) → `$ACC9` (`$84`) · baixo (`$07`) → `$AC7C` (`$82`) · perto (`$02`) → `$AC2F` (`$81`) · sempre → `$ABE2` (`$81`) |

A cadeia é **dado**; qual variante dispara em cada postura é comportamento (ex.: o soco forte
agachado `$AE51` fica atrás do teste "no chão ou deslizando" `$06`, que já cobre o chão — na
prática parece inalcançável).

**`GuardRedirect` (`3F:F704`)** — só age em guarda (`FighterState & $F8 = $28`), com o quadro sem
os bits 2 e 5 (`FrameFlags & $24 = 0`) e sem transição pendente; fora disso, só retorna. Salva o
`AnimTimer`; grava a classe da guarda pela direção (`GuardClassTbl`, `3F:F799`, 9 entradas
`29 29 29 29 2A 29 29 2A 2A` por `InputDir−$04`) e aplica a defesa do golpe recebido
(`ram_032A[(HitReactClass & $3F)×2]`, `zp_DD=$04`). Se o caminhador commitou, o nó vira o estado
atual **preservando o ponto da animação**: `FramePtr = NextPtr + (FramePtr − StatePtr)`, relê
flags (+7) e classe (+5) do nó, zera o pendente e restaura o timer — a defesa entra no mesmo
quadro da animação de guarda.

**Reconhecedor de especiais** (`InputCommands`, `3F:EA24`) — a ponte "movimento no controle → índice
de golpe". A cada quadro de luta, para cada lutador humano:

1. **Caminhada** (`CmdWalkLoop`): percorre a lista de especiais do personagem (slot 8 da ficha, copiada
   para `ram_033E`/`ram_0340`); cada byte é uma **chave** ($00–$12), bit 7 (`$FF`) termina. `JoyState`/
   `JoyPrev` são espelhados por `FighterFlip` (bits frente/trás trocados) e a chave despacha
   `CmdStep[chave]` pela tabela dividida `CmdStepLo`/`CmdStepHi` (truque do RTS), com `Y = chave`. O
   `inx; inx` por entrada faz `x = lutador + 2×posição`.
2. **Estado por entrada**: cada entrada da lista tem passo e janela próprios, nos arrays intercalados
   `CmdMotionStep` (`$90`–`$9B`) e `CmdMotionWin` (`$9E`–`$A9`), indexados por `lutador + 2×posição`
   (P1 usa os bytes pares, P2 os ímpares). São 12 bytes: no máximo **6 especiais por personagem** —
   uma lista maior pisaria no estado do outro lutador.
3. **Reconhecido**: o tratador que completa grava `CmdMoveIdx[lutador] = posição na lista`; o
   `InputDispatch` (flag bit 0 do quadro, acima) vira transição de estado via `RyuSpcTrans` (`01:A01A`,
   apontada por `ram_0326`) e **consome** o índice.

Os cinco estilos de tratador (`(nt)` = lido do código; o trace só executou o de movimento):

| Chaves | Tratador | Regra |
|---|---|---|
| `$00`–`$07`, `$10` | `CmdStepMotion` (`EB4B`) | sequência de direções (`CmdMotionTbl[chave×4+passo]`); um passo vale quando o bit exigido está apertado **e** alguma direção é nova (não estava no quadro anterior) — segurando parado não avança; janela de 12 quadros entre passos; o byte `$00` encerra e começa a fase do botão (outras 12), exigindo `InputAttack == CmdKeyAttackTbl[chave]` |
| `$08`–`$0D` | `CmdStepCharge` (`EA9C`) | carga: segurar a direção ≥ 60 quadros (contador satura em `$3C`), soltar apertando a direção de liberação (byte seguinte da sequência) num prazo de 8 quadros, depois o botão no mesmo prazo |
| `$0E`/`$0F` | `CmdStepMash` (`EAFD`) | apertar o mesmo botão (`CmdKeyAttackTbl[chave] == InputAttack`) 3×, intervalos ≤ 8 quadros |
| `$11` | `CmdStepBothBtn` (`EB32`) | A+B apertados juntos na borda de subida |
| `$12` | `CmdStepNone` (`EB4A`) | vazio — lugar vago na tabela |

* `CmdMotionTbl` (`3F:E067`): 19 chaves ($00–$12) × 4 bytes — bits `$04` baixo, `$01` frente, `$02`
  trás, `$08` cima, `$80` A, `$40` B; `$00` encerra. Sequências: `04 01` ×4 (↓→), `04 02` ×2 (↓←),
  `01 04 01` ×2 (→↓→), `02 01` ×4 (carga ← … →), `04 08` ×2 (carga ↓ … ↑), `80 80 80` (3×A),
  `40 40 40` (3×B), `01 04 02 08` (→↓←↑). `CmdMotionAdvance` (`EB73`) lê `CmdMotionTbl+1` com o
  mesmo índice para ver o byte seguinte sem `iny`. Os 4 bytes "da chave `$12`" são a própria
  `CmdKeyAttackTbl` — inofensivo, o tratador é só `rts`.
* `CmdKeyAttackTbl` (`3F:E0AF`, **17 bytes** = chaves `$00`–`$10`): **botão exigido** — `00 01 02 03`
  ×3 (chaves $00–$0B; 0/1 soco, 2/3 chute) e `00 01 00 02 03` (chaves `$0C`–`$10`; a sequência de 3×A
  exige soco fraco, a de 3×B chute fraco e o giro de 4 direções, chute forte).
* Listas de especiais: `CmdKeyListRyu` (`3F:E0C0`): `02 03 06 07 04 05 FF` — cada byte é uma chave e
  a **posição na lista** vira `CmdMoveIdx` (hadouken 0/1 com chute, shoryuken 2/3 com chute,
  tatsumaki 4/5 com soco). Há uma segunda lista em `$E0C7` (`0A 0B 08 09 0C 0D FF`, só chaves de
  carga), pronta para outro personagem — nenhum ponteiro da ficha aponta para ela hoje.

Notas de leitura: (a) o `InputClear` (`3F:E974`), que roda fora da luta ativa, só zera a entrada 0 do
reconhecedor — e o `sta CmdMotionStep+1,x` / `CmdMotionWin+1,x` de `E988`/`E98A` não é a entrada 1 do
lutador, é um byte do vizinho (o layout é intercalado); as entradas 1–5 nunca são zeradas ali, só
expiram pela janela. (b) No trace, as leituras de `$90` parecem ~8× maiores que o uso real: é a
leitura fantasma do 6502 (toda instrução `(zp),X` lê o byte-base sem índice no ciclo anterior), não
um bug. (c) A CPU não passa pelo reconhecedor: os operadores `AiOp00`–`AiOp03` escrevem `InputDir`/
`InputAttack`/`CmdMoveIdx` direto.

## 14. IA (roteiros)

Dois níveis: `RyuAiThink` (`00:8F46`) escolhe o roteiro (tabela `00:8E72`, 8 ponteiros, roteiros
em `00:8E82`–`$8F45`); `AiUpdate` (`3F:E7D2`) executa o bytecode. `AiLevel` é fixo em 7
(`3F:F84C`); `AiStartScript` hesita se `Random & 7 ≥ AiLevel`.

Fora de golpe (classe < `$50`, flags & 7 = 0), `L3F_E74C` segura trás por padrão (`$06`, ou `$0C`
diagonal-baixa se o oponente está agachado) — é por isso que a CPU recua.

**Bytecode**: cada byte `≥ $80` é um opcode (`$80`–`$91` → `AiOp00`–`AiOp11` via tabela
`AiOpLo/Hi`), com 0–2 operandos `< $80`; `$FF` termina (zp_71=0 → chama o pensador de novo).
Ações (`$80`–`$86`) encadeiam no mesmo quadro; **testes (`≥ $07`) que falham pausam o roteiro e
re-testam a cada quadro**; `$8D` decrementa `zp_6F` e espera zerar (é o delay: `$84 $78` +
`$8D` ≈ 120 quadros).

| Opcode | Ação |
|---|---|
| `$80` | direção (1 op) |
| `$81` | direção + botão (2 ops) |
| `$82` | golpe especial por índice (grava `CmdMoveIdx` direto) |
| `$83` | defender (trás / diagonal-baixa se oponente agachado) |
| `$84` | `zp_6F` = operando |
| `$85` | `zp_6F` = byte da zeropage dada por op0+x `(nt)` |
| `$86` | `zp_6F`++ |
| `$87` | meu estado >> 3 = op0? |
| `$88` | meu estado & op0 = op0? |
| `$89` | meu estado = `$58`-família (ex.: espera o estado inicial `$59`) |
| `$8A` | estou em golpe `$B0`–`$E0`? `(nt)` |
| `$8B` | sem projetil meu no ar? |
| `$8C` | teste de distância `(nt)` |
| `$8D` | decrementa `zp_6F` e espera zerar |
| `$8E` | espera `\|ΔX\| < op0` |
| `$8F` | espera `\|ΔX\| ≥ op0` |
| `$90` | estado do oponente >> 3 = op0? |
| `$91` | `zp_73` = 0? `(nt)` |

Exemplo real decodificado (`00:8E82`):

```
80 04  89  8B  82 00  82 89  FF
parado  espera neutro ($59)  espera projetil livre  hadouken (idx 0)  de novo  espera neutro  fim
```

## 15. Índice de tabelas auxiliares

| Endereço | Tamanho | Conteúdo |
|---|---|---|
| `3F:E055` | 6 | sfx de impacto por classe do atacante (`05 06 07 05 06 07`) |
| `3F:E05B` | 2 | Y de nascimento do projetil (`−$27`) |
| `3F:E05E` | 2 | passo do projetil por velocidade (`$17`/`$25`) |
| `3F:E064` | 2 | ΔX de nascimento do projetil (`$27`) |
| `3F:E067` | 64 | `CmdMotionTbl` — 16 golpes × 4 bytes (§13) |
| `3F:E0AF` | 16 | botão exigido por golpe (§13) |
| `3F:E0C0` | 7 | lista de especiais do Ryu (§13) |
| `3F:E171` | 24 | despacho das 12 condições (endereço−1) |
| `3F:E4CE`/`$E4D4` | 6+6 | despacho do modo de movimento (endereço−1) |
| `3F:EF06`/`$EF13` | 13+13 | knockback X por classe (em pé/agachado · neutro) |
| `3F:EF20`/`$EF2D` | 13+13 | knockback Y por classe (em pé/agachado · neutro) |
| `3F:EF3A` | 13 | classe de reação ao derrubar |
| `3F:EF47` | 13 | classe de reação no KO |
| `3F:F799` | 9 | `GuardClassTbl` — guarda por direção |
| `00:8E72` | 16 | tabela de roteiros de IA (8 ponteiros) |
| `00:8E82`–`$8F45` | — | roteiros de IA do Ryu |
| `3B:E57D` | 16 | metasprites do projetil (por velocidade+passo) |
| `3B:E595` | 16 | metasprites do choque de projéteis |
| `3C:8000`–`$80BE` | 180 | ficha: 10 pares de ponteiros de tabela (§1) |
| `3C:80C8`/`$80D2`/`$80DC` | 10+10+10 | bancos de estados / frames / colisão por personagem |
