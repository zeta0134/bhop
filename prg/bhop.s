.include "nes.inc"

.scope BHOP
        .zeropage
bhop_ptr: .word $0000 ; used for all sorts of indirect reads

        .segment "RAM"
tempo_counter: .word $0000
tempo_cmp: .word $0000
tempo: .byte $00
frame_index: .byte $00
pulse1_pattern_ptr: .word $0000

        .segment "PRG0_8000"
        .export bhop_init, bhop_play

; TODO: I believe the convention is to pick a song here?
; right now lots of stuff is hard coded, that could instead
; be read from the chosen song header
.proc bhop_init
        ; global initialization things
        lda #00
        sta tempo_cmp
        sta frame_index
        sta pulse1_pattern_ptr
        sta pulse1_pattern_ptr+1
        

        ; default tempo
        lda #150
        sta tempo
        lda #<(150 * 6)
        sta tempo_cmp
        lda #>(150 * 6)
        sta tempo_cmp+1
        rts
.endproc

.proc bhop_play
        ; D:
        rts
.endproc

.endscope


