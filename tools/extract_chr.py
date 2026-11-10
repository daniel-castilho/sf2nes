#!/usr/bin/env python3
"""Exporta o CHR-ROM (512 KB = 32768 tiles 8x8, 2 bits por pixel) para PNG.

O jogo usa o MMC5 em modo CHR 2 (bancos de 2K = 128 tiles) e sprites 8x16, entao a unidade natural e'
a "pagina de 2K": $5121/$5123/$5125/$5127 escolhem paginas para sprites e $5129/$512B para o fundo.
Cada PNG gerado tem 16 paginas de 2K (uma por linha de 16x8 tiles... ver --help) em tons de cinza.

uso: extract_chr.py [rom] [dir_saida] [--scale N]
"""
import sys, os
from PIL import Image, ImageDraw

PAL = [(0, 0, 0), (96, 96, 96), (176, 176, 176), (255, 255, 255)]

def tile(chr_, n):
    o = n * 16; px = [[0] * 8 for _ in range(8)]
    for y in range(8):
        a = chr_[o + y]; b = chr_[o + 8 + y]
        for x in range(8):
            px[y][x] = ((a >> (7 - x)) & 1) | (((b >> (7 - x)) & 1) << 1)
    return px

def page2k(chr_, page, sprite8x16=False):
    """imagem 128x64 (16x8 tiles) de uma pagina de 2K. Com sprite8x16, pares de tiles (n, n+1) ficam um sobre o outro."""
    im = Image.new('RGB', (128, 64) if not sprite8x16 else (64 * 8 // 8 * 2 * 4, 16 * 2))
    if not sprite8x16:
        for t in range(128):
            px = tile(chr_, page * 128 + t)
            for y in range(8):
                for x in range(8): im.putpixel(((t % 16) * 8 + x, (t // 16) * 8 + y), PAL[px[y][x]])
        return im
    im = Image.new('RGB', (32 * 8, 2 * 16))
    for s in range(64):
        for half in range(2):
            px = tile(chr_, page * 128 + s * 2 + half)
            for y in range(8):
                for x in range(8): im.putpixel(((s % 32) * 8 + x, (s // 32) * 16 + half * 8 + y), PAL[px[y][x]])
    return im

def main():
    here = os.path.dirname(os.path.abspath(__file__))
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    romp = args[0] if args else os.path.join(here, '..', 'rom', 'sf2ne_demo.nes')
    outd = args[1] if len(args) > 1 else os.path.join(here, '..', 'extracted', 'chr')
    scale = int(sys.argv[sys.argv.index('--scale') + 1]) if '--scale' in sys.argv else 2
    os.makedirs(outd, exist_ok=True)
    rom = open(romp, 'rb').read()
    prg = rom[4] * 0x4000 + (((rom[9] & 0x0F) << 8) * 0x4000 if (rom[7] & 0x0C) == 0x08 else 0)
    chr_ = rom[16 + prg:]
    npages = len(chr_) // 2048
    used = [p for p in range(npages) if any(b not in (0x00, 0xFF) for b in chr_[p * 2048:(p + 1) * 2048])]
    print('CHR: %d bytes, %d paginas de 2K, %d com conteudo' % (len(chr_), npages, len(used)))
    # folhas com 16 paginas (4 colunas x 4 linhas), rotuladas
    per = 16
    for s in range(0, npages, per):
        pages = [p for p in range(s, min(s + per, npages))]
        if not any(p in used for p in pages): continue
        W = 4 * (128 * scale + 8) + 8; H = 4 * (64 * scale + 20) + 8
        sheet = Image.new('RGB', (W, H), (24, 24, 40)); dr = ImageDraw.Draw(sheet)
        for i, p in enumerate(pages):
            x = 8 + (i % 4) * (128 * scale + 8); y = 8 + (i // 4) * (64 * scale + 20)
            dr.text((x, y), 'pag 2K $%02X  (1K $%02X-$%02X)' % (p, p * 2, p * 2 + 1), fill=(255, 220, 120))
            sheet.paste(page2k(chr_, p).resize((128 * scale, 64 * scale), Image.NEAREST), (x, y + 12))
        fn = os.path.join(outd, 'chr_2k_%02X-%02X.png' % (pages[0], pages[-1]))
        sheet.save(fn)
    open(os.path.join(outd, 'INDICE.txt'), 'w').write(
        'CHR-ROM: %d bytes = %d paginas de 2K (128 tiles cada).\nPaginas com conteudo: %s\n'
        'Cada PNG mostra 16 paginas de 2K (16x8 tiles por pagina), em tons de cinza (indices 0-3).\n'
        % (len(chr_), npages, ' '.join('%02X' % p for p in used)))
    print('paginas usadas:', ' '.join('%02X' % p for p in used))

if __name__ == '__main__':
    main()
