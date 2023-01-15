        .setcpu "6502"
        .include "charmap.inc"
        .include "nes.inc"
        .include "input.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "vram_buffer.inc"

        .include "../../bhop/bhop.inc"

        .zeropage
CurrentTrack: .res 1
TrackPtr: .res 2

ScratchPtr: .res 2
ScratchWord: .res 2
ScratchByte: .res 1

StringPtr: .res 2
StrPosX: .res 1
StrPosY: .res 1
FieldWidth: .res 1

        .segment "CODE"

bnuuy_nametable:
        .incbin "bnuuy.nam"

bnuuy_palette:
        .incbin "bnuuy_bg.pal"
        .incbin "bnuuy_obj.pal"

bnuuy_sprite_layout:
        ; Bnuuy sprites (48)
        .byte $30, $01, $00, $48
        .byte $38, $0b, $00, $48
        .byte $50, $13, $03, $31
        .byte $58, $16, $03, $31
        .byte $50, $14, $03, $39
        .byte $58, $17, $03, $39
        .byte $50, $15, $03, $41
        .byte $58, $18, $03, $41
        .byte $13, $03, $01, $22
        .byte $1B, $0c, $01, $22
        .byte $13, $04, $01, $2A
        .byte $1B, $0d, $01, $2A
        .byte $13, $05, $01, $32
        .byte $1B, $0e, $01, $32
        .byte $13, $06, $01, $3A
        .byte $1B, $0f, $01, $3A
        .byte $23, $07, $01, $2B
        .byte $2B, $10, $01, $2A
        .byte $23, $08, $01, $3A
        .byte $2B, $11, $01, $3A
        .byte $23, $09, $01, $42
        .byte $2B, $12, $01, $42
        .byte $33, $0a, $01, $2A
        .byte $3B, $1b, $01, $2D
        .byte $3B, $1c, $01, $35
        .byte $3B, $1f, $01, $3D
        .byte $3B, $20, $01, $45
        .byte $43, $22, $01, $2D
        .byte $43, $23, $01, $39
        .byte $43, $24, $01, $43
        .byte $4B, $25, $01, $30
        .byte $4B, $26, $01, $38
        .byte $4C, $27, $01, $40
        .byte $53, $1a, $01, $3D
        .byte $5B, $29, $01, $2D
        .byte $5B, $2a, $01, $35
        .byte $5B, $2b, $01, $3D
        .byte $63, $2f, $01, $32
        .byte $63, $30, $01, $3A
        .byte $42, $02, $00, $38
        .byte $4B, $1d, $00, $35
        .byte $4B, $1e, $00, $3D
        .byte $53, $21, $00, $3D
        .byte $3E, $2d, $02, $57
        .byte $3E, $2e, $02, $5F
        .byte $40, $28, $02, $40
        .byte $48, $2c, $02, $40
        .byte $53, $19, $02, $40

        ; Text header sprites (?)
TITLE_X = 38
TITLE_Y = 161
        .byte TITLE_Y, $40, $03, TITLE_X + 0
        .byte TITLE_Y, $41, $03, TITLE_X + 8
        .byte TITLE_Y, $42, $03, TITLE_X + 16
        .byte TITLE_Y, $43, $03, TITLE_X + 24

ARTIST_X = 30
ARTIST_Y = 193
        .byte ARTIST_Y, $44, $03, ARTIST_X + 0
        .byte ARTIST_Y, $45, $03, ARTIST_X + 8
        .byte ARTIST_Y, $46, $03, ARTIST_X + 16
        .byte ARTIST_Y, $47, $03, ARTIST_X + 24
        .byte ARTIST_Y, $48, $03, ARTIST_X + 32






bnuuy_sprite_layout_end:
bnuuy_oam_length = (bnuuy_sprite_layout_end - bnuuy_sprite_layout)

hello_world_str:
        .asciiz "Hello World!"

; External Functions, declared in player.inc

.proc player_init
        lda #0
        sta CurrentTrack
        jsr initialize_current_track

        jsr demo_copy_palette
        jsr demo_copy_nametable
        jsr demo_bnuuy_sprites

        jsr update_track_info

        rts
.endproc

.proc player_update
        jsr bhop_play
        jsr poll_input
        jsr handle_track_switching
        rts
.endproc

; Banking, needed by bhop. This is a thin wrapper around the player-specific
; banking function

.proc bhop_apply_dpcm_bank
        jsr player_bank_samples
        rts
.endproc
.export bhop_apply_dpcm_bank

; Internal Functions

.proc initialize_current_track
        lda CurrentTrack
        asl
        tax
        lda music_track_table+0, x
        sta TrackPtr+0
        lda music_track_table+1, x
        sta TrackPtr+1

        ldy #MusicTrack::BankNumber
        lda (TrackPtr), y
        jsr player_bank_music

        ldy #MusicTrack::TrackNumber
        lda (TrackPtr), y
        jsr bhop_init
        rts
.endproc

.proc handle_track_switching
check_right:
        lda #KEY_RIGHT
        bit ButtonsDown
        beq check_left
check_next_track:
        lda CurrentTrack
        clc
        adc #1
        cmp music_track_count
        beq finished
advance_to_next_track:
        sta CurrentTrack
        jsr initialize_current_track
        jsr update_track_info
finished:
        rts

check_left:
        lda #KEY_LEFT
        bit ButtonsDown
        beq finished
check_previous_track:
        lda CurrentTrack
        beq finished
advance_to_previous_track:
        dec CurrentTrack        
        jsr initialize_current_track        
        jsr update_track_info
        rts
.endproc

.proc demo_copy_palette
        lda #0
        sta PPUCTRL ; VRAM mode +0
        set_ppuaddr #$3F00
        ldx #0
loop:
        lda bnuuy_palette, x
        sta PPUDATA
        inx
        cpx #32
        bne loop

        rts
.endproc

; TODO: not this. We need to use the vram buffer later if we want to do this
; during runtime.
.proc demo_copy_nametable
        lda #0
        sta PPUCTRL ; VRAM mode +0
        set_ppuaddr #$2000

        st16 ScratchPtr, bnuuy_nametable
        st16 ScratchWord, $0400
        ldy #0
loop:
        lda (ScratchPtr), y
        sta PPUDATA
        inc16 ScratchPtr
        dec16 ScratchWord
        lda ScratchWord
        ora ScratchWord+1
        bne loop

        rts
.endproc

.proc demo_bnuuy_sprites
        ldx #0
loop:
        lda bnuuy_sprite_layout, x
        sta $200, x
        inx
        cpx #bnuuy_oam_length
        bne loop
        rts
.endproc

.proc dest_coords
DestAddr := ScratchWord
        lda StrPosY
        sta DestAddr+0
        lda #0
        sta DestAddr+1
        .repeat 5
        asl DestAddr+0
        rol DestAddr+1
        .endrepeat
        clc
        lda StrPosX
        adc DestAddr+0
        sta DestAddr+0
        lda #$20
        adc DestAddr+1
        sta DestAddr+1

        rts
.endproc

.proc draw_text_field
DestAddr := ScratchWord
        jsr dest_coords ; sets DestAddr based on StrPosX and StrPosY

        write_vram_header_ptr DestAddr, FieldWidth, VRAM_INC_1

        ldx VRAM_TABLE_INDEX
        ldy #0
loop:
        lda (StringPtr), y
        beq end_of_string
        sta VRAM_TABLE_START, x
        inx
        iny
        jmp loop
end_of_string:
        cpy FieldWidth
        beq finalize_vram_entry
        ; At this point we have written Y characters, but we need to
        ; fill out the entire field, to erase any previous contents. Here
        ; we loop again, this time writing blank tiles to fill out the
        ; FieldWidth
padding_loop:
        lda BLANK_TILE
        sta VRAM_TABLE_START, x
        inx
        iny
        cpy FieldWidth
        bne padding_loop
finalize_vram_entry:

        stx VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES
        rts
.endproc

blank_string:
                ;0123456789012345678901234567
        .asciiz "                            "

.proc update_track_info
TargetStringPtr := ScratchWord
        lda CurrentTrack
        asl
        tax
        lda music_track_table+0, x
        sta TrackPtr+0
        lda music_track_table+1, x
        sta TrackPtr+1

        
        lda #2
        sta StrPosX
        lda #22
        sta StrPosY
        lda #28
        sta FieldWidth
        ldy #MusicTrack::TitleStringPtr
        lda (TrackPtr), y
        sta StringPtr
        iny
        lda (TrackPtr), y
        sta StringPtr+1
        jsr draw_text_field

        lda #2
        sta StrPosX
        lda #26
        sta StrPosY
        lda #28
        sta FieldWidth
        ldy #MusicTrack::ArtistStringPtr
        lda (TrackPtr), y
        sta StringPtr
        iny
        lda (TrackPtr), y
        sta StringPtr+1
        jsr draw_text_field        

        rts
.endproc

