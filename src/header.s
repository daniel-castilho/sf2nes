; NES 2.0 header: mapper 5 (MMC5), 512K PRG + 512K CHR, no PRG-RAM.
.segment "HEADER"
    .byte "NES", $1A
    .byte $20            ; PRG-ROM: 32 x 16K
    .byte $40            ; CHR-ROM: 64 x 8K
    .byte $51            ; flags 6: mapper (low nibble) = 5, vertical mirroring
    .byte $08            ; flags 7: NES 2.0
    .byte $00,$00,$00,$00,$02,$00,$00,$00   ; byte 12 = $02: multi-region
