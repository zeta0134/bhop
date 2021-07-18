.include "bhop.inc"
.include "bhop_internal.inc"
.include "commands.inc"
.include "nes.inc"
.include "word_util.inc"

.scope BHOP

        .zeropage
cmd_ptr: .word $0000

        .segment "PRG0_8000"
        .export command_table

command_table:
    .word cmd_instrument           ;CMD_INSTRUMENT
    .word cmd_unimplemented_short  ;CMD_HOLD
    .word cmd_set_duration         ;CMD_SET_DURATION
    .word cmd_reset_duration       ;CMD_RESET_DURATION
    .word cmd_unimplemented        ;CMD_EFF_SPEED
    .word cmd_unimplemented        ;CMD_EFF_TEMPO
    .word cmd_eff_jump             ;CMD_EFF_JUMP
    .word cmd_unimplemented        ;CMD_EFF_SKIP
    .word cmd_unimplemented        ;CMD_EFF_HALT
    .word cmd_unimplemented        ;CMD_EFF_VOLUME
    .word cmd_unimplemented_short  ;CMD_EFF_CLEAR
    .word cmd_unimplemented        ;CMD_EFF_PORTAUP
    .word cmd_unimplemented        ;CMD_EFF_PORTADOWN
    .word cmd_unimplemented        ;CMD_EFF_PORTAMENTO
    .word cmd_unimplemented        ;CMD_EFF_ARPEGGIO
    .word cmd_unimplemented        ;CMD_EFF_VIBRATO
    .word cmd_unimplemented        ;CMD_EFF_TREMOLO
    .word cmd_unimplemented        ;CMD_EFF_PITCH
    .word cmd_unimplemented_short  ;CMD_EFF_RESET_PITCH
    .word cmd_unimplemented        ;CMD_EFF_DUTY
    .word cmd_unimplemented        ;CMD_EFF_DELAY
    .word cmd_unimplemented        ;CMD_EFF_SWEEP
    .word cmd_unimplemented        ;CMD_EFF_DAC
    .word cmd_unimplemented        ;CMD_EFF_OFFSET
    .word cmd_unimplemented        ;CMD_EFF_SLIDE_UP
    .word cmd_unimplemented        ;CMD_EFF_SLIDE_DOWN
    .word cmd_unimplemented        ;CMD_EFF_VOL_SLIDE
    .word cmd_unimplemented        ;CMD_EFF_NOTE_CUT
    .word cmd_unimplemented        ;CMD_EFF_RETRIGGER
    .word cmd_unimplemented        ;CMD_EFF_DPCM_PITCH
    .word cmd_unimplemented        ;CMD_EFF_NOTE_RELEASE
    .word cmd_unimplemented        ;CMD_EFF_LINEAR_COUNTER
    .word cmd_unimplemented        ;CMD_EFF_GROOVE
    .word cmd_unimplemented        ;CMD_EFF_DELAYED_VOLUME
    .word cmd_unimplemented        ;CMD_EFF_TRANSPOSE
    .word cmd_unimplemented        ;CMD_EFF_VRC7_PATCH
    .word cmd_unimplemented        ;CMD_EFF_VRC7_PORT
    .word cmd_unimplemented        ;CMD_EFF_VRC7_WRITE
    .word cmd_unimplemented        ;CMD_EFF_FDS_MOD_DEPTH
    .word cmd_unimplemented        ;CMD_EFF_FDS_MOD_RATE_HI
    .word cmd_unimplemented        ;CMD_EFF_FDS_MOD_RATE_LO
    .word cmd_unimplemented        ;CMD_EFF_FDS_VOLUME
    .word cmd_unimplemented        ;CMD_EFF_FDS_MOD_BIAS
    .word cmd_unimplemented        ;CMD_EFF_N163_WAVE_BUFFER
    .word cmd_unimplemented        ;CMD_EFF_S5B_ENV_TYPE
    .word cmd_unimplemented        ;CMD_EFF_S5B_ENV_RATE_HI
    .word cmd_unimplemented        ;CMD_EFF_S5B_ENV_RATE_LO
    .word cmd_unimplemented        ;CMD_EFF_S5B_NOISE
        ; fill out this table to 128 entries. Assume any new command
    ; added has one parameter. If it doesn't, oh well!
    .repeat 80
      .word cmd_unimplemented
    .endrep

.proc dispatch_command
        ; get the command byte into A
        asl ; drop the high bit, and also expand the lower 7 bits into a table index
        tay
        lda command_table, y
        sta cmd_ptr
        lda command_table+1, y
        sta cmd_ptr+1
        jmp (cmd_ptr)
        ; dispatched command executes rts
.endproc

.export dispatch_command

.proc cmd_unimplemented
        ; fetch the command argument and throw it away
        fetch_pattern_byte
        rts
.endproc

.proc cmd_unimplemented_short
        ; this command has no argument. Do absolutely nothing!
        rts
.endproc

.proc cmd_set_duration
        fetch_pattern_byte
        ldy #ChannelState::global_duration
        sta (channel_ptr), y
        ldy #ChannelState::status
        lda (channel_ptr), y
        ora #CHANNEL_GLOBAL_DURATION
        sta (channel_ptr), y
        rts
.endproc

.proc cmd_reset_duration
        ldy #ChannelState::status
        lda (channel_ptr), y
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta (channel_ptr), y
        rts
.endproc

.proc cmd_eff_jump
        fetch_pattern_byte
        sta frame_counter ; target frame counter
        lda row_cmp
        sta row_counter ; target row (so we immediately advance)
        ; but we haven't incremented either pointer yet! So decrement them
        ; both by 1, this way when we are done ticking rows, we end up where
        ; we want on the next one
        dec frame_counter ; the effect encodes target+1, we want target...
        dec frame_counter ; ... and one _less_ than target
        dec row_counter
        ; important: new frames expect to begin with global duration disabled;
        ; ordinarily the last note in a frame fixes this, but if we jump mid-way
        ; through a frame, we'll be in an inconsistent state. Fix it *now*, for
        ; *all* channels
        lda pulse1_state + ChannelState::status
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta pulse1_state + ChannelState::status

        lda pulse2_state + ChannelState::status
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta pulse2_state + ChannelState::status

        lda triangle_state + ChannelState::status
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta triangle_state + ChannelState::status

        lda noise_state + ChannelState::status
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta noise_state + ChannelState::status

        lda dpcm_state + ChannelState::status
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta dpcm_state + ChannelState::status

        rts
.endproc

.proc cmd_instrument
        fetch_pattern_byte
        ; of *course* this is pre-shifted, so un-do that:
        lsr
        ; store the instrument and load it up
        ldy #ChannelState::selected_instrument
        sta (channel_ptr), y
        jsr load_instrument
        rts
.endproc

.endscope