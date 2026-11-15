#!/usr/bin/env python3
"""state_data_gen.py — conversor de estados/quadros do formato declarativo (TOML) para assembly ca65.

Fase 2 — Gate C (implementação da ferramenta). Apenas converte um arquivo de autoria
declarativo em assembly equivalente aos registros atuais (cabeçalho de estado 7 bytes,
quadro de animação 14/16 bytes). Não altera annotations, não mexe em src/ manualmente,
não executa build nem emulador.

Uso:
    python3 tools/state_data_gen.py entrada.toml saida.s
"""

import sys
import tomllib  # Python 3.11+ stdlib

# ---------------------------------------------------------------------------
# Limites conhecidos (docs/FORMATOS.md)
# ---------------------------------------------------------------------------
DURACAO_MIN = 1
DURACAO_MAX = 100


class CampoSimbolico:
    """Representa um campo que aceita nome simbólico ou inteiro bruto."""

    def __init__(self, simbolo=None, bruto=None):
        self.simbolo = simbolo
        self.bruto = bruto

    def emit_byte(self):
        """Emite o byte para o assembly. Prioriza simbolo se houver, senão bruto."""
        if self.bruto is not None:
            return f"${self.bruto & 0xFF:02X}"
        if self.simbolo is not None:
            return self.simbolo
        raise ValueError("Campo simbolico sem simbolo nem bruto")


# ---------------------------------------------------------------------------
# Validadores
# ---------------------------------------------------------------------------
def validar_duracao(valor, contexto):
    if not isinstance(valor, int) or not (DURACAO_MIN <= valor <= DURACAO_MAX):
        raise ValueError(
            f"{contexto}: duracao invalida {valor} (deve ser {DURACAO_MIN}..{DURACAO_MAX})"
        )


def validar_referencia(valor, contexto, definidos):
    if valor is not None and valor not in definidos:
        raise ValueError(f"{contexto}: referencia '{valor}' nao definida")


# ---------------------------------------------------------------------------
# Emissores de assembly
# ---------------------------------------------------------------------------
def emitir_cabecalho_estado(estado, definidos_estados):
    """Gera o cabecalho de 7 bytes de um estado."""
    linhas = []
    linhas.append("; -- ESTADO (cabecalho, 7 bytes)")
    linhas.append(f"{estado['id']}:")

    cond = estado.get("condicao_entrada")
    if cond:
        c = CampoSimbolico(cond.get("simbolo"), cond.get("bruto"))
        linhas.append(f"    .byte {c.emit_byte()}")
    else:
        raise ValueError(f"{estado['id']}: condicao_entrada e obrigatoria")

    prox_alt = estado.get("proxima_alternativa")
    if prox_alt:
        validar_referencia(prox_alt, estado['id'], definidos_estados)
        linhas.append(f"    .word {prox_alt}-1")
    else:
        linhas.append("    .word 0")

    cadeia = estado.get("cadeia_natural")
    if cadeia:
        validar_referencia(cadeia, estado['id'], definidos_estados)
        linhas.append(f"    .word {cadeia}-1")
    else:
        linhas.append("    .word 0")

    classe = estado.get("classe")
    if classe:
        cl = CampoSimbolico(classe.get("simbolo"), classe.get("bruto"))
        acertos = estado.get("acertos_golpe")
        if acertos is None:
            raise ValueError(f"{estado['id']}: acertos_golpe e obrigatorio")
        linhas.append(f"    .byte {cl.emit_byte()},${acertos & 0xFF:02X}")
    else:
        raise ValueError(f"{estado['id']}: classe e obrigatoria")

    return linhas


def emitir_quadro(quadro, definidos_quadros, definidos_metasprites, definidos_colisoes):
    """Gera o quadro de 14 ou 16 bytes."""
    linhas = []
    linhas.append("; -- quadro")
    linhas.append(f"{quadro['id']}:")

    duracao = quadro.get("duracao")
    if duracao is None:
        raise ValueError(f"{quadro['id']}: duracao e obrigatoria")
    validar_duracao(duracao, quadro['id'])
    linhas.append(f"    .byte ${duracao & 0xFF:02X}")

    ms = quadro.get("metasprite")
    if ms:
        validar_referencia(ms, quadro['id'], definidos_metasprites)
        linhas.append(f"    .word {ms}")
    else:
        linhas.append("    .word 0")

    col = quadro.get("colisao")
    if col:
        validar_referencia(col, quadro['id'], definidos_colisoes)
        linhas.append(f"    .word {col}")
    else:
        linhas.append("    .word 0")

    ep = quadro.get("efeito_parametro")
    if ep:
        epv = CampoSimbolico(ep.get("simbolo"), ep.get("bruto"))
        linhas.append(f"    .byte {epv.emit_byte()}")
    else:
        raise ValueError(f"{quadro['id']}: efeito_parametro e obrigatorio")

    et = quadro.get("efeito_tipo")
    if et:
        etv = CampoSimbolico(et.get("simbolo"), et.get("bruto"))
        linhas.append(f"    .byte {etv.emit_byte()}")
    else:
        raise ValueError(f"{quadro['id']}: efeito_tipo e obrigatoria")

    fl = quadro.get("flags")
    if fl:
        flv = CampoSimbolico(fl.get("simbolo"), fl.get("bruto"))
        linhas.append(f"    .byte {flv.emit_byte()}")
    else:
        raise ValueError(f"{quadro['id']}: flags e obrigatoria")

    mm = quadro.get("movimento_modo")
    if mm:
        mmv = CampoSimbolico(mm.get("simbolo"), mm.get("bruto"))
        linhas.append(f"    .byte {mmv.emit_byte()}")
    else:
        raise ValueError(f"{quadro['id']}: movimento_modo e obrigatoria")

    vx = quadro.get("velocidade_x")
    if vx is not None:
        linhas.append(f"    .byte ${vx & 0xFF:02X}")
    else:
        raise ValueError(f"{quadro['id']}: velocidade_x e obrigatoria")

    vy = quadro.get("velocidade_y")
    if vy is not None:
        linhas.append(f"    .byte ${vy & 0xFF:02X}")
    else:
        raise ValueError(f"{quadro['id']}: velocidade_y e obrigatoria")

    rep = quadro.get("repeticao")
    if rep is None:
        raise ValueError(f"{quadro['id']}: repeticao e obrigatoria")
    linhas.append(f"    .byte ${rep & 0xFF:02X}")

    desvio = quadro.get("desvio_laco")
    prox = quadro.get("proximo_quadro")

    if rep != 0:
        if not desvio:
            raise ValueError(
                f"{quadro['id']}: desvio_laco obrigatorio quando repeticao != 0"
            )
        validar_referencia(desvio, quadro['id'], definidos_quadros)
        linhas.append(f"    .word {desvio}")

    if prox:
        validar_referencia(prox, quadro['id'], definidos_quadros)
        linhas.append(f"    .word {prox}")
    else:
        linhas.append("    .word 0")

    return linhas


# ---------------------------------------------------------------------------
# Conversao principal
# ---------------------------------------------------------------------------
def converter(toml_path, saida_path):
    with open(toml_path, "rb") as f:
        dados = tomllib.load(f)

    personagens = dados.get("personagem", [])
    if not personagens:
        raise ValueError("TOML sem secao [[personagem]]")

    saida = []
    saida.append("; GERADO por tools/state_data_gen.py — nao edite a mao.")
    saida.append("; Edite o arquivo TOML de origem e rode state_data_gen.py.")
    saida.append("")

    todos_estados = set()
    todos_quadros = set()
    todos_metasprites = set()
    todos_colisoes = set()

    # Primeira passagem: coletar nomes definidos para validar referencias
    for p in personagens:
        for e in p.get("estado", []):
            todos_estados.add(e["id"])
            for q in e.get("quadro", []):
                todos_quadros.add(q["id"])
                if q.get("metasprite"):
                    todos_metasprites.add(q["metasprite"])
                if q.get("colisao"):
                    todos_colisoes.add(q["colisao"])

    # Segunda passagem: emitir
    for p in personagens:
        pid = p.get("id", "desconhecido")
        saida.append(f"; Personagem: {pid}")
        saida.append(f"; banco_estados: {p.get('banco_estados','?')}")
        saida.append(f"; banco_frames: {p.get('banco_frames','?')}")
        saida.append("")

        for e in p.get("estado", []):
            saida.extend(emitir_cabecalho_estado(e, definidos_estados := todos_estados))
            saida.append("")
            for q in e.get("quadro", []):
                saida.extend(
                    emitir_quadro(
                        q,
                        definidos_quadros := todos_quadros,
                        definidos_metasprites := todos_metasprites,
                        definidos_colisoes := todos_colisoes,
                    )
                )
                saida.append("")

    with open(saida_path, "w") as f:
        f.write("\n".join(saida) + "\n")

    print(f"Gerado {saida_path} a partir de {toml_path}")
    print(f"  Personagens: {len(personagens)}")
    print(f"  Estados: {len(todos_estados)}")
    print(f"  Quadros: {len(todos_quadros)}")


def main():
    if len(sys.argv) != 3:
        print("Uso: python3 tools/state_data_gen.py entrada.toml saida.s", file=sys.stderr)
        sys.exit(1)
    converter(sys.argv[1], sys.argv[2])


if __name__ == "__main__":
    main()
