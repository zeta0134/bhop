        .setcpu "6502"
        .include "charmap.inc"
        .include "nes.inc"
        .include "input.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "vram_buffer.inc"

        .include "../../bhop/bhop.inc"

.struct FancyTextDisplay
        DestinationAddr .word
        StringPtr .word        
        CharacterPos .byte
        DelayCounter .byte
        State .byte
.endstruct

TEXT_STATE_FINISHED = 0
TEXT_STATE_RESET = 1
TEXT_STATE_DRAWING = 2

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

CurrentPaletteIndex: .res 1
PaletteFadeCounter: .res 1

TitleFancyText: .res .sizeof(FancyTextDisplay)
ArtistFancyText: .res .sizeof(FancyTextDisplay)

        .segment "CODE"

bnuuy_nametable:
        .incbin "bnuuy.nam"

bnuuy_palette:
        .incbin "bnuuy_bg_fade4.pal"
        .incbin "bnuuy_obj_fade4.pal"
        .incbin "bnuuy_bg_fade3.pal"
        .incbin "bnuuy_obj_fade3.pal"
        .incbin "bnuuy_bg_fade2.pal"
        .incbin "bnuuy_obj_fade2.pal"
        .incbin "bnuuy_bg_fade1.pal"
        .incbin "bnuuy_obj_fade1.pal"
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
FancyTextPtr := ScratchPtr
        lda #0
        sta CurrentTrack
        jsr initialize_current_track

        jsr init_palette
        jsr demo_copy_nametable
        jsr demo_bnuuy_sprites

        jsr update_track_info
        jsr update_track_counter

        lda #0
        sta CurrentPaletteIndex
        lda #0
        sta PaletteFadeCounter
        jsr handle_palette_fade

        st16 FancyTextPtr, TitleFancyText
        ldy #FancyTextDisplay::DestinationAddr
        lda #$C2
        sta (FancyTextPtr), y
        iny
        lda #$22
        sta (FancyTextPtr), y

        st16 FancyTextPtr, ArtistFancyText
        ldy #FancyTextDisplay::DestinationAddr
        lda #$42
        sta (FancyTextPtr), y
        iny
        lda #$23
        sta (FancyTextPtr), y

        rts
.endproc

.proc player_update
FancyTextPtr := ScratchPtr
        jsr bhop_play
        jsr poll_input
        jsr handle_track_switching
        jsr handle_palette_fade

        st16 FancyTextPtr, TitleFancyText
        jsr update_fancy_text
        st16 FancyTextPtr, ArtistFancyText
        jsr update_fancy_text

        rts
.endproc

; Banking, needed by bhop. This is a thin wrapper around the player-specific
; banking function

.proc bhop_apply_dpcm_bank
        jsr player_bank_samples
        rts
.endproc
.export bhop_apply_dpcm_bank

.proc bhop_apply_music_bank
        jsr player_bank_music
        rts
.endproc
.export bhop_apply_music_bank

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
        jsr bhop_set_module_bank
        jsr player_bank_music

        ldy #MusicTrack::TrackNumber
        lda (TrackPtr), y
        pha ; store the track number and reload it after loading the address for the song
        ldy #MusicTrack::ModulePtr
        lda (TrackPtr), y
        tax ; lo ptr for the module address
        iny
        lda (TrackPtr), y
        tay ; hi ptr for the module address
        pla
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
        jsr update_track_counter
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
        jsr update_track_counter
        rts
.endproc

.proc init_palette
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

PALETTE_FADE_SPEED = 3
MAX_PALETTE_INDEX = 128

.proc handle_palette_fade
        lda PaletteFadeCounter
        beq check_palette_index
        dec PaletteFadeCounter
        rts

check_palette_index:
        lda CurrentPaletteIndex
        clc
        adc #32
        cmp #(MAX_PALETTE_INDEX+1)
        bcc update_palette
        lda #255
        sta PaletteFadeCounter
        rts

update_palette:
        sta CurrentPaletteIndex

        write_vram_header_imm $3F00, #32, VRAM_INC_1

        ldx VRAM_TABLE_INDEX
        ldy CurrentPaletteIndex
loop:
        lda bnuuy_palette, y
        sta VRAM_TABLE_START, x
        inx
        iny
        tya
        and #%00011111
        bne loop

finalize_vram_entry:

        stx VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES

        lda #PALETTE_FADE_SPEED
        sta PaletteFadeCounter

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

.proc update_track_info
FancyTextPtr := ScratchPtr
TargetStringPtr := ScratchWord
        lda CurrentTrack
        asl
        tax
        lda music_track_table+0, x
        sta TrackPtr+0
        lda music_track_table+1, x
        sta TrackPtr+1

        st16 FancyTextPtr, TitleFancyText
        ldy #MusicTrack::TitleStringPtr
        lda (TrackPtr), y
        ldy #FancyTextDisplay::StringPtr
        sta (FancyTextPtr), y
        ldy #MusicTrack::TitleStringPtr+1
        lda (TrackPtr), y
        ldy #FancyTextDisplay::StringPtr+1
        sta (FancyTextPtr), y
        ldy #FancyTextDisplay::State
        lda #TEXT_STATE_RESET
        sta (FancyTextPtr), y
        ldy #FancyTextDisplay::DelayCounter
        lda #0
        sta (FancyTextPtr), y

        st16 FancyTextPtr, ArtistFancyText
        ldy #MusicTrack::ArtistStringPtr
        lda (TrackPtr), y
        ldy #FancyTextDisplay::StringPtr
        sta (FancyTextPtr), y
        ldy #MusicTrack::ArtistStringPtr+1
        lda (TrackPtr), y
        ldy #FancyTextDisplay::StringPtr+1
        sta (FancyTextPtr), y
        ldy #FancyTextDisplay::State
        lda #TEXT_STATE_RESET
        sta (FancyTextPtr), y
        ldy #FancyTextDisplay::DelayCounter
        lda #0
        sta (FancyTextPtr), y

        rts
.endproc

.proc draw_8bit_number
Number := ScratchByte
CurrentDigit := (ScratchWord)
LeadingCounter := (ScratchWord+1)
        lda #0
        sta CurrentDigit
        sta LeadingCounter

        lda #0
        sta CurrentDigit
hundreds_loop:
        lda Number
        cmp #100
        bcc display_hundreds
        inc CurrentDigit
        lda Number
        sec
        sbc #100
        sta Number
        jmp hundreds_loop
display_hundreds:
        lda LeadingCounter
        ora CurrentDigit
        sta LeadingCounter
        beq blank_hundreds
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        jmp draw_hundreds
draw_hundreds:
        sta VRAM_TABLE_START, x
        inx
        iny
blank_hundreds:

        lda #0
        sta CurrentDigit
tens_loop:
        lda Number
        cmp #10
        bcc display_tens
        inc CurrentDigit
        lda Number
        sec
        sbc #10
        sta Number
        jmp tens_loop
display_tens:
        lda LeadingCounter
        ora CurrentDigit
        sta LeadingCounter
        beq blank_tens
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        jmp draw_tens
draw_tens:
        sta VRAM_TABLE_START, x
        inx
        iny

blank_tens:
        lda #0
        sta CurrentDigit
ones_loop:
        lda Number
        cmp #1
        bcc display_ones
        inc CurrentDigit
        dec Number
        jmp ones_loop
display_ones:
        lda #NUMBERS_BASE
        clc
        adc CurrentDigit
        sta VRAM_TABLE_START, x
        inx
        iny

        rts
.endproc

.proc draw_string
        ldy #0
loop:
        lda (StringPtr), y
        beq end_of_string
        sta VRAM_TABLE_START, x
        inx
        iny
        jmp loop
end_of_string:
        rts
.endproc

leading_chevron_str: .asciiz "> "
track_separator_str: .asciiz " / "

.proc update_track_counter
Number := ScratchByte
        write_vram_header_imm $2224, #10, VRAM_INC_1
        ldx VRAM_TABLE_INDEX
        
        ldy #0 ; number of bytes we have written so far
        sty StrPosX
        
        st16 StringPtr, leading_chevron_str
        jsr draw_string
        tya
        clc
        adc StrPosX
        sta StrPosX
        tay
        
        lda CurrentTrack
        clc
        adc #1
        sta Number
        jsr draw_8bit_number
        sty StrPosX

        st16 StringPtr, track_separator_str
        jsr draw_string
        tya
        clc
        adc StrPosX
        sta StrPosX
        tay

        lda music_track_count
        sta Number
        jsr draw_8bit_number

        ; now we must write blank tiles to fill out the rest of the space
padding_loop:
        lda BLANK_TILE
        sta VRAM_TABLE_START, x
        inx
        iny
        cpy #10
        bne padding_loop
finalize_vram_entry:

        stx VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES
        rts
.endproc

.proc update_fancy_text
FancyTextPtr := ScratchPtr
        ldy #FancyTextDisplay::DelayCounter
        lda (FancyTextPtr), y
        beq perform_update
        sec
        sbc #1
        sta (FancyTextPtr), y
        rts

perform_update:
        ldy #FancyTextDisplay::State
        lda (FancyTextPtr), y
check_reset_state:
        cmp #TEXT_STATE_RESET
        bne check_draw_state
        jsr reset_fancy_text
        rts
check_draw_state:
        cmp #TEXT_STATE_DRAWING
        bne finished
        jsr draw_fancy_text
finished:
        rts
.endproc

.proc reset_fancy_text
FancyTextPtr := ScratchPtr
DestAddr := ScratchWord
        ; first clear the entire text field, to erase any old contents
        ldy #FancyTextDisplay::DestinationAddr
        lda (FancyTextPtr), y
        sta DestAddr
        iny
        lda (FancyTextPtr), y
        sta DestAddr+1

        write_vram_header_ptr DestAddr, #28, VRAM_INC_1
        ldx VRAM_TABLE_INDEX
        ldy #0
loop:
        lda #BLANK_TILE
        sta VRAM_TABLE_START, x
        inx
        iny
        cpy #28
        bne loop
finalize_vram_entry:
        stx VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES

        ; now set our state to drawing, so we can begin displaying the
        ; current string
        ldy #FancyTextDisplay::State
        lda #TEXT_STATE_DRAWING
        sta (FancyTextPtr), y

        ; And reset our state related to drawing
        lda #0
        ldy #FancyTextDisplay::CharacterPos
        sta (FancyTextPtr), y

        ; No need to set a delay here, we'll begin drawing immediately on the next frame
        ; ... maybe. Todo, polish, and all that.

        rts
.endproc

.proc draw_fancy_text
FancyTextPtr := ScratchPtr
DestAddr := ScratchWord
CharacterPos := ScratchByte
        ; First compute our destination address, which is always
        ; the current character postiion
        ldy #FancyTextDisplay::CharacterPos
        lda (FancyTextPtr), y
        sta CharacterPos

        clc
        ldy #FancyTextDisplay::DestinationAddr
        lda (FancyTextPtr), y
        adc CharacterPos
        sta DestAddr
        iny
        lda (FancyTextPtr), y
        adc #0 ; should be unnecessary, but let's be safe
        sta DestAddr+1

        ; Now read the current character, as we need to take
        ; a different path if we reach the end of the string
        ldy #FancyTextDisplay::StringPtr
        lda (FancyTextPtr), y
        sta StringPtr
        iny
        lda (FancyTextPtr), y
        sta StringPtr+1

        ldy CharacterPos
        lda (StringPtr), y
        beq end_of_string_reached

        ; We're not at the end of the string yet, so we will:
        ; - draw this character at the appropriate tile
        ; - draw the cursor one tile ahead of the character
        write_vram_header_ptr DestAddr, #2, VRAM_INC_1
        ldx VRAM_TABLE_INDEX
        ; Re-read the current character, which was clobbered when we wrote the vram header
        ldy CharacterPos
        lda (StringPtr), y
        sta VRAM_TABLE_START, x
        inx
        lda #1 ; cursor tile
        sta VRAM_TABLE_START, x
        inx
        stx VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES

        ; Now increment the character position...
        ldy #FancyTextDisplay::CharacterPos
        lda (FancyTextPtr), y
        clc
        adc #1
        sta (FancyTextPtr), y
        ; And set a delay to slow down this animation
        ldy #FancyTextDisplay::DelayCounter
        lda #0
        sta (FancyTextPtr), y

        ; And we should be all done
        rts


end_of_string_reached:
        ; We've reached the end of the string! All we need to do is
        ; erase the cursor, which conveniently is located at DestAddr
        write_vram_header_ptr DestAddr, #1, VRAM_INC_1
        ldx VRAM_TABLE_INDEX
        lda #BLANK_TILE
        sta VRAM_TABLE_START, x
        inx
        stx VRAM_TABLE_INDEX
        inc VRAM_TABLE_ENTRIES

        ; Now that we're done drawing, we move ourselves into the finished state
        ; so we stop receiving updates
        ldy #FancyTextDisplay::State
        lda #TEXT_STATE_FINISHED
        sta (FancyTextPtr), y

        rts
.endproc

