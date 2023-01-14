        .setcpu "6502"
        .include "charmap.inc"
        .include "nes.inc"
        .include "input.inc"
        .include "player.inc"
        .include "ppu.inc"
        .include "word_util.inc"

        .include "../../bhop/bhop.inc"

        .zeropage
CurrentTrack: .res 1
TrackPtr: .res 2

ScratchPtr: .res 2
ScratchWord: .res 2

        .segment "CODE"

bnuuy_nametable:
        .incbin "bnuuy.nam"

bnuuy_palette:
        .incbin "bnuuy_pal.pal"

bnuuy_sprite_layout:
        .byte $40, $01, $00, $48
        .byte $48, $0b, $00, $48
        .byte $60, $13, $03, $31
        .byte $68, $16, $03, $31
        .byte $60, $14, $03, $39
        .byte $68, $17, $03, $39
        .byte $60, $15, $03, $41
        .byte $68, $18, $03, $41
        .byte $23, $03, $01, $22
        .byte $2B, $0c, $01, $22
        .byte $23, $04, $01, $2A
        .byte $2B, $0d, $01, $2A
        .byte $23, $05, $01, $32
        .byte $2B, $0e, $01, $32
        .byte $23, $06, $01, $3A
        .byte $2B, $0f, $01, $3A
        .byte $33, $07, $01, $2B
        .byte $3B, $10, $01, $2A
        .byte $33, $08, $01, $3A
        .byte $3B, $11, $01, $3A
        .byte $33, $09, $01, $42
        .byte $3B, $12, $01, $42
        .byte $43, $0a, $01, $2A
        .byte $4B, $1b, $01, $2D
        .byte $4B, $1c, $01, $35
        .byte $4B, $1f, $01, $3D
        .byte $4B, $20, $01, $45
        .byte $53, $22, $01, $2D
        .byte $53, $23, $01, $39
        .byte $53, $24, $01, $43
        .byte $5B, $25, $01, $30
        .byte $5B, $26, $01, $38
        .byte $5C, $27, $01, $40
        .byte $63, $1a, $01, $3D
        .byte $6B, $29, $01, $2D
        .byte $6B, $2a, $01, $35
        .byte $6B, $2b, $01, $3D
        .byte $73, $2f, $01, $32
        .byte $73, $30, $01, $3A
        .byte $52, $02, $00, $38
        .byte $5B, $1d, $00, $35
        .byte $5B, $1e, $00, $3D
        .byte $63, $21, $00, $3D
        .byte $4E, $2d, $02, $57
        .byte $4E, $2e, $02, $5F
        .byte $50, $28, $02, $40
        .byte $58, $2c, $02, $40
        .byte $63, $19, $02, $40

bnuuy_sprite_layout_end:
bnuuy_oam_length = (bnuuy_sprite_layout_end - bnuuy_sprite_layout)


; External Functions, declared in player.inc

.proc player_init
        lda #0
        sta CurrentTrack
        jsr initialize_current_track

        jsr demo_copy_palette
        jsr demo_copy_nametable
        jsr demo_bnuuy_sprites
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