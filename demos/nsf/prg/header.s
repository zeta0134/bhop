        .import nsf_init, bhop_play
        .importzp track_count
        .import __NSFDRV_LOAD__
        .setcpu "6502"
        .include "nsf.inc"
;
; NSF2 header
; with NSFe metadata appended
; https://www.nesdev.org/wiki/NSF
; https://www.nesdev.org/wiki/NSF2
; https://www.nesdev.org/wiki/NSFe
;

.segment "HEADER"
        .byte $4E, $45, $53, $4D, $1A   ; ID
        .byte $02                       ; Version
        .byte track_count               ; Number of songs
        .byte 1                         ; Start song
        .addr __NSFDRV_LOAD__           ; LOAD address
        .addr nsf_init                  ; INIT address
        .addr bhop_play                 ; PLAY address
align_strings:
        .byte "bhop NSF demo"           ; Name, 32 bytes
        .res align_strings+32-*, $00
        .byte "Jenny, v.a."             ; Artist, 32 bytes
        .res align_strings+64-*, $00
        .byte "2024"                    ; Copyright, 32 bytes
        .res align_strings+96-*, $00

        .word $40FF                     ; NTSC play rate = round(1000000 / ((21477272 / 4)  / (341 * 262)))
        ; Bank values
        .byte 0, 1  ; PRGFIXED_8000
        .byte 0, 0
        .byte 0, 0
        .byte 2, 3  ; PRGFIXED_E000
        .word $4E1D                     ; PAL play rate = round(1000000 / ((26601712 / 5)  / (341 * 312)))
        .byte NSF_REGION_NTSC           ; Region, NTSC
        .byte NSF_EXPANSION_FLAGS       ; Expansion audio flags
        .byte NSF2_FEATURE_FLAGS        ; NSF2 flags
        ; todo: figure out NSF data length on compile
        .faraddr $100000                ; NSF data length

.segment "NSFDRV"
        .byte "bhop"
        .byte $08, $67, $53, $09

.segment "FOOTER"
    .dword auth_size
    .byte "auth"
auth:
    .asciiz "bhop NSF demo"
    .asciiz "Jenny, v.a."
    .asciiz "2024"
    .asciiz "bhop"
auth_size := * - auth
