        .setcpu "6502"
;
; NES (1.0) header
; http://wiki.nesdev.com/w/index.php/INES
;
.segment "HEADER"
        .byte "NES", $1a
        .byte $04               ; 4x 16KB PRG-ROM banks = 64 KB total
        .byte $01               ; 1x 8KB CHR-ROM banks = 8 KB total
        .byte $40, $00          ; Mapper 4 (MMC3) w/ battery-backed RAM
        .byte $00               ; 8k of PRG RAM
        .byte $00               ;
        .byte $00
        .byte $00
        .byte $00
        .byte $00
        .byte $00
        .byte $00