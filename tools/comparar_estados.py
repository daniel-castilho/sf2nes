#!/usr/bin/env python3
"""comparar_estados.py — compara assembly gerado pelo conversor com o original.

Fase 2 — Gate C, Peça 3. Extrai os bytes de dados (.byte e .word) de dois arquivos
assembly e compara a equivalência estrutural:
- .byte: compara valor exato
- .word: compara zero vs não-zero (endereços de label diferem entre origens)

Uso:
    python3 tools/comparar_estados.py original.s gerado.s
"""

import re
import sys

# Padrão para extrair bytes de uma linha .byte ou .word
BYTE_RE = re.compile(r'\.byte\s+((?:\$[0-9A-Fa-f]{2},?\s*)+)')
WORD_RE = re.compile(r'\.word\s+((?:[0-9A-Fa-f\$A-Za-z_\-]+,?\s*)+)')

def extrair_bytes(linha):
    """Retorna lista de inteiros (bytes) de uma linha .byte/.word, ou None se não for dado."""
    m = BYTE_RE.search(linha)
    if m:
        valores = []
        for v in re.findall(r'\$([0-9A-Fa-f]{2})', m.group(1)):
            valores.append(int(v, 16))
        return valores

    m = WORD_RE.search(linha)
    if m:
        valores = []
        for token in re.findall(r'([0-9A-Fa-f\$A-Za-z_\-]+)', m.group(1)):
            token = token.strip()
            if not token:
                continue
            # Remover sufixo -1 (RTS trick: Endereco-1)
            token = token.replace('-1', '')
            if token == '0':
                valores.extend([0, 0])  # palavra zero = dois bytes zero
            elif token.isdigit():
                val = int(token)
                valores.extend([val & 0xFF, (val >> 8) & 0xFF])
            else:
                # Label de endereço: não-zero em ambos os bytes (endereço válido)
                valores.extend([1, 1])
        return valores

    return None


def ler_bytes(caminho):
    """Lê um arquivo assembly e retorna lista de bytes (int) em ordem de aparição."""
    bytes_lista = []
    with open(caminho) as f:
        for linha in f:
            linha = linha.strip()
            if not linha or linha.startswith(';'):
                continue
            b = extrair_bytes(linha)
            if b:
                bytes_lista.extend(b)
    return bytes_lista


def comparar(original, gerado):
    b_orig = ler_bytes(original)
    b_ger = ler_bytes(gerado)

    print(f"Original ({original}): {len(b_orig)} bytes")
    print(f"Gerado   ({gerado}):   {len(b_ger)} bytes")

    if len(b_orig) != len(b_ger):
        print(f"DIFERENÇA: tamanhos diferem ({len(b_orig)} vs {len(b_ger)})")
        return False

    diferencas = 0
    for i, (o, g) in enumerate(zip(b_orig, b_ger)):
        if o != g:
            diferencas += 1
            if diferencas <= 10:
                print(f"  Byte {i}: original=${o:02X} gerado=${g:02X}")

    if diferencas == 0:
        print("RESULTADO: EQUIVALENTE (todos os bytes coincidem)")
        return True
    else:
        print(f"RESULTADO: {diferencas} byte(s) diferem")
        return False


def main():
    if len(sys.argv) != 3:
        print("Uso: python3 tools/comparar_estados.py original.s gerado.s", file=sys.stderr)
        sys.exit(1)
    ok = comparar(sys.argv[1], sys.argv[2])
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
