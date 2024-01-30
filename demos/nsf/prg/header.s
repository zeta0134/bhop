        .import nsf_init, bhop_play
        .importzp track_count
        .import __NSFDRV_LOAD__, __FTR_FILEOFFS__
        NSF2_SIZE = __FTR_FILEOFFS__

        .setcpu "6502"
        .include "nsf.inc"
;
; NSF2 header
; with NSFe metadata appended
; https://www.nesdev.org/wiki/NSF
; https://www.nesdev.org/wiki/NSF2
; https://www.nesdev.org/wiki/NSFe
;

.macro nsf_string str
.assert .strlen(str) <= 32, error, "NSF string longer than 32 characters"
.byte str
.res 32 - .strlen(str), $00
.endmacro

.segment "HEADER"
        .byte $4E, $45, $53, $4D, $1A   ; ID
        .byte $02                       ; Version
        .byte track_count               ; Number of songs
        .byte 1                         ; Start song
        .addr __NSFDRV_LOAD__           ; LOAD address
        .addr nsf_init                  ; INIT address
        .addr bhop_play                 ; PLAY address
        nsf_string "bhop NSF demo"      ; Name, 32 bytes
        nsf_string "Jenny, v.a."        ; Artist, 32 bytes
        nsf_string "2024"               ; Copyright, 32 bytes

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
        .faraddr NSF2_SIZE              ; NSF data length

.segment "NSFDRV"
        .byte "bhop"
        .byte $08, $67, $53, $09

; stuff the track labels and authors here
.segment "FOOTER"
        .dword auth_size
        .byte "auth"
auth:
        .asciiz "bhop NSF demo"
        .asciiz "Jenny, v.a."
        .asciiz "2024"
        .asciiz "bhop"
auth_size := * - auth

        .dword tlbl_size
        .byte "tlbl"
tlbl:
        .asciiz "Ikenfell - In This Together"
        .asciiz "MMBN. - Virus Busting"
        .asciiz "Super Mario Bros - World 1-1"
        .asciiz "Chrono Trigger - Boss Battle"
        .asciiz "New Super Mario Bros - 1-1"
        .asciiz "Earthbound - Guardian"
        .asciiz "Chrono Trigger - Battle"
        .asciiz "DKC - Simian Segue"
        .asciiz "Shadow of the Ninja - Stage 1"
        .asciiz "Tactus - Shower Groove"
        .asciiz "Brain Age - Menu"
        .asciiz "in another world (head in the clouds)"
tlbl_size := * - tlbl

        .dword taut_size
        .byte "taut"
taut:
        .asciiz "aivi & surasshu"
        .asciiz "Yoshino Aoki"
        .asciiz "Koji Kondo"
        .asciiz "Yasunori Mitsuda"
        .asciiz "Koji Kondo"
        .asciiz "K. Suzuki, H. Tanaka"
        .asciiz "Yasunori Mitsuda"
        .asciiz "Eveline Fischer"
        .asciiz "I. Mizutani, K. Yamanishi"
        .asciiz "zeta0134"
        .asciiz "M. Hamano, A. Nakatsuka"
        .asciiz "Persune"
taut_size := * - taut

        .dword NEND_size
        .byte "NEND"
NEND:
        .asciiz "Jenny sends her regards!"
NEND_size := * - NEND
