        .setcpu "6502"
;
; NES (1.0) header
; http://wiki.nesdev.com/w/index.php/INES
;
.segment "HEADER"
        .byte "NES", $1a
        .byte $10               ; 16x 16KB PRG-ROM banks = 256 KB total
        .byte $01               ; 1x 8KB CHR-ROM banks = 8 KB total
        .byte $40, $00          ; MMC3 without battery-backed PRG RAM
        .byte $00               ; No PRG RAM (ines 1.0 will give us 8k, which we will ignore)
        .byte $00               ;
        .byte $00
        .byte $00
        .byte $00
        .byte $00
        .byte $00
        .byte $00