.include "nes.inc"
.include "word_util.inc"

.scope BHOP
        .zeropage
bhop_ptr: .word $0000 ; used for all sorts of indirect reads

        .segment "RAM"
tempo_counter: .word $0000
tempo_cmp: .word $0000
tempo: .byte $00


song_ptr: .word $0000
frame_ptr: .word $0000

pulse1_pattern_ptr: .word $0000

        .segment "PRG0_8000"
        .export bhop_init, bhop_play

MUSIC_BASE = $A000
SONG_LIST = MUSIC_BASE

.struct SongInfo
        frame_ptr .word
        frame_count .byte
        pattern_length .byte
        speed .byte
        tempo .byte
        groove_position .byte
        initial_bank .byte
.endstruct

.macro prepare_ptr address
        lda address
        sta bhop_ptr
        lda address+1
        sta bhop_ptr+1
.endmacro

; TODO: I believe the convention is to pick a song here?
; right now lots of stuff is hard coded, that could instead
; be read from the chosen song header

; param: song index (a)
.proc bhop_init
        ; preserve parameters
        pha ; song index

        ; global initialization things
        lda #00
        sta tempo_counter
        sta tempo_counter+1

        ; switch to the requested song
        lda SONG_LIST
        sta bhop_ptr
        lda SONG_LIST+1
        sta bhop_ptr+1

        pla
        asl ; song list is made of words
        tay
        lda (bhop_ptr), y
        sta song_ptr
        iny
        lda (bhop_ptr), y
        sta song_ptr+1

        ; load speed and tempo from the requested song
        prepare_ptr song_ptr
        ldy #SongInfo::speed
        lda (bhop_ptr), y
        tax
        jsr set_speed
        ldy #SongInfo::tempo
        lda (bhop_ptr), y
        sta tempo

        rts
.endproc

; speed goes in x
.proc set_speed
        st16 tempo_cmp, $0000
loop:
        add16 tempo_cmp, #150
        dex
        bne loop
        rts
.endproc

; frame number goes on the stack
.proc jump_to_frame
        prepare_ptr song_ptr
.endproc

.proc bhop_play
        ; D:
        rts
.endproc

.endscope


