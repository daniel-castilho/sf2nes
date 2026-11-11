#!/usr/bin/env python3
"""Patcha bytes em um banco de PRG de um ROM .nes, gravando uma copia.

Uso:
  poke_prg.py SAIDA BASE BANCO ADDR BYTE...     (patcha e grava SAIDA)
  poke_prg.py - SAIDA BASE                      (copia sem patch, para baselines)

BANCO em hex (00-3F), ADDR em hex dentro da janela fixa do banco
(janela = $8000 + (banco & 3) * $2000; ex.: banco 01 -> $A000-$BFFF).
Offset no arquivo: 16 (cabecalho iNES) + banco*$2000 + (ADDR - janela).

Antes de gravar, mostra o valor atual e pede confirmacao (opcao --force
para pular a pergunta).
"""
import sys

def window_base(bank: int) -> int:
    return 0x8000 + (bank & 3) * 0x2000

def prg_offset(bank: int, addr: int) -> int:
    base = window_base(bank)
    if not (base <= addr < base + 0x2000):
        raise SystemExit(
            f"erro: ${addr:04X} fora da janela ${base:04X}-${base+0x1FFF:04X} do banco ${bank:02X}")
    return 16 + bank * 0x2000 + (addr - base)

def main(argv):
    args = list(argv)
    force = "--force" in args
    if force:
        args.remove("--force")
    if len(args) == 3 and args[0] == "-":          # copia sem patch: - SAIDA BASE
        open(args[1], "wb").write(open(args[2], "rb").read())
        print(f"copiado {args[2]} -> {args[1]} (sem patch)")
        return
    if len(args) < 5:
        print(__doc__)
        raise SystemExit(1)
    out, rom = args[0], args[1]
    data = bytearray(open(rom, "rb").read())
    bank = int(args[2], 16)
    addr = int(args[3], 16)
    new = [int(b, 16) for b in args[4:]]
    off = prg_offset(bank, addr)
    old = data[off:off + len(new)]
    print(f"banco ${bank:02X}  ${addr:04X}  (offset {off} / +${addr-window_base(bank):04X} na janela)")
    print(f"  atual : {' '.join(f'{b:02X}' for b in old)}")
    print(f"  novo  : {' '.join(f'{b:02X}' for b in new)}")
    if old == bytes(new):
        print("  (valores ja conferem; nada a fazer)")
        raise SystemExit(0)
    if not force:
        try:
            r = input("  aplicar? [s/N] ")
        except EOFError:
            r = ""
        if r.strip().lower() not in ("s", "sim", "y", "yes"):
            raise SystemExit("abortado")
    data[off:off + len(new)] = bytes(new)
    open(out, "wb").write(data)
    print(f"  gravado em {out}")

if __name__ == "__main__":
    main(sys.argv[1:])
