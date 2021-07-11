.include "nes.inc"
.include "word_util.inc"

.scope BHOP
        .zeropage
bhop_ptr: .word $0000 ; used for all sorts of indirect reads

        .segment "RAM"
tempo_counter: .word $0000
tempo_cmp: .word $0000
tempo: .byte $00
row_counter: .byte $00
row_cmp: .byte $00
frame_counter: .byte $00
frame_cmp: .byte $00

song_ptr: .word $0000
frame_ptr: .word $0000

pulse1_pattern_ptr: .word $0000
pulse2_pattern_ptr: .word $0000
triangle_pattern_ptr: .word $0000
noise_pattern_ptr: .word $0000
dpcm_pattern_ptr: .word $0000

        .segment "PRG0_8000"
        .export bhop_init, bhop_play

MUSIC_BASE = $A000
SONG_LIST = MUSIC_BASE

.struct SongInfo
        frame_list_ptr .word
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
        sta row_counter
        sta frame_counter

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
        ldy #SongInfo::frame_count
        lda (bhop_ptr), y
        sta frame_cmp
        ldy #SongInfo::pattern_length
        lda (bhop_ptr), y
        sta row_cmp

        ; initialize at the first frame, and prime our pattern pointers
        ldx #0
        jsr jump_to_frame
        jsr load_frame_patterns


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

; frame number goes in x
.proc jump_to_frame
        ; load the frame pointer list from the song data; we're going to rewrite
        ; frame_ptr here anyway, so use it as temp storage
        prepare_ptr song_ptr
        ldy #SongInfo::frame_list_ptr
        lda (bhop_ptr), y
        sta frame_ptr
        iny
        lda (bhop_ptr), y
        sta frame_ptr+1
        ; now add our target frame number to that
        txa
        clc
        add16a frame_ptr
        ; twice
        txa
        clc
        add16a frame_ptr
        ; now use this to load the actual frame pointer from the list
        prepare_ptr frame_ptr
        ldy #0
        lda (bhop_ptr), y
        sta frame_ptr
        iny
        lda (bhop_ptr), y
        sta frame_ptr+1
        rts
.endproc

.proc load_frame_patterns
        ;initialize all the pattern rows from the current frame pointer
        prepare_ptr frame_ptr
        ldy #0

        lda (bhop_ptr), y
        sta pulse1_pattern_ptr
        iny
        lda (bhop_ptr), y
        sta pulse1_pattern_ptr+1
        iny

        lda (bhop_ptr), y
        sta pulse2_pattern_ptr
        iny
        lda (bhop_ptr), y
        sta pulse2_pattern_ptr+1
        iny

        lda (bhop_ptr), y
        sta triangle_pattern_ptr
        iny
        lda (bhop_ptr), y
        sta triangle_pattern_ptr+1
        iny

        lda (bhop_ptr), y
        sta noise_pattern_ptr
        iny
        lda (bhop_ptr), y
        sta noise_pattern_ptr+1
        iny

        lda (bhop_ptr), y
        sta dpcm_pattern_ptr
        iny
        lda (bhop_ptr), y
        sta dpcm_pattern_ptr+1
        iny
        rts
.endproc

.proc tick_frame_counter
        add16 tempo_counter, tempo
        ; have we exceeded the tempo_counter?
        lda tempo_counter+1
        cmp tempo_cmp+1
        bcc done_advancing_rows ; counter is lower than threshold (high byte)
        bne advance_row  ; should be impossible to take, because we only add 255 or less?
        lda tempo_counter
        cmp tempo_cmp
        bcc done_advancing_rows
        ; is either the same or higher; do the thing
advance_row:
        jsr advance_pattern_rows
        ; subtract tempo_cmp from tempo_counter
        sec
        lda tempo_counter
        sbc tempo_cmp
        sta tempo_counter
        lda tempo_counter+1
        sbc tempo_cmp+1
        sta tempo_counter+1
        ; advance the row counter and, if necessary, move to the next frame
        inc row_counter
        lda row_counter
        cmp row_cmp
        bcc done_advancing_rows
        ; row is equal or greater to max
        jsr advance_frame
        lda #0
        sta row_counter
done_advancing_rows:
        rts
.endproc

.proc advance_pattern_rows
        rts
.endproc

.proc advance_frame
        inc frame_counter
        lda frame_counter
        cmp frame_cmp
        bcc no_wrap
        lda #0
        sta frame_counter
no_wrap:
        ldx frame_counter
        jsr jump_to_frame
        jsr load_frame_patterns
        rts
.endproc

.proc bhop_play
        jsr tick_frame_counter
        ; D:
        rts
.endproc

.endscope


