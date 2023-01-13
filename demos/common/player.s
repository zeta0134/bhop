        .setcpu "6502"
        .include "nes.inc"
        .include "input.inc"
        .include "player.inc"
        .include "../../bhop/bhop.inc"

        .zeropage
CurrentTrack: .res 1
TrackPtr: .res 2

        .segment "CODE"

; External Functions, declared in player.inc

.proc player_init
        lda #0
        sta CurrentTrack
        jsr initialize_current_track
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