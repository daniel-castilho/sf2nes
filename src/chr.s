; CHR-ROM: 512K = 512 pages of 1K (the game uses MMC5 in CHR mode 2: 2K pages).
.segment "CHR"
    .incbin "assets/chr/chr.bin"
