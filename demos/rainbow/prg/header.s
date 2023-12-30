        .setcpu "6502"
;
; NES (1.0) header
; http://wiki.nesdev.com/w/index.php/INES
;
.segment "HEADER"
        .byte "NES", $1a
        .byte $02               ; 2x 16KB PRG-ROM banks = 32 KB total
        .byte $01               ; 1x 8KB CHR-ROM banks = 8 KB total
        .byte $A0, $A8          ; Mapper 682 (Rainbow)
        .byte $02               ; 
        .byte $00               ;
        .byte $00
        .byte $00
        .byte $00
        .byte $00
        .byte $00
        .byte $00