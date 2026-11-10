#!/usr/bin/env python3
"""Monta uma folha de contato (grade) a partir de varios PNGs, com legenda. uso: sheet.py saida.png cols escala arq1.png arq2.png ..."""
import sys, os
from PIL import Image, ImageDraw
out, cols, scale = sys.argv[1], int(sys.argv[2]), float(sys.argv[3])
files = sys.argv[4:]
ims = [Image.open(f).convert('RGB') for f in files]
w, h = ims[0].size
w2, h2 = int(w * scale), int(h * scale)
rows = (len(ims) + cols - 1) // cols
sheet = Image.new('RGB', (cols * (w2 + 4) + 4, rows * (h2 + 16) + 4), (40, 40, 40))
d = ImageDraw.Draw(sheet)
for i, (im, f) in enumerate(zip(ims, files)):
    x = 4 + (i % cols) * (w2 + 4); y = 4 + (i // cols) * (h2 + 16)
    sheet.paste(im.resize((w2, h2), Image.NEAREST), (x, y + 12))
    d.text((x + 2, y), os.path.splitext(os.path.basename(f))[0], fill=(255, 255, 0))
sheet.save(out)
print('ok', out, sheet.size)
