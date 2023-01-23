
        .segment BHOP_PLAYER_SEGMENT

command_table:
    .word cmd_instrument           ;CMD_INSTRUMENT
    .word cmd_unimplemented_short  ;CMD_HOLD
    .word cmd_set_duration         ;CMD_SET_DURATION
    .word cmd_reset_duration       ;CMD_RESET_DURATION
    .word cmd_eff_speed            ;CMD_EFF_SPEED
    .word cmd_eff_tempo            ;CMD_EFF_TEMPO
    .word cmd_eff_jump             ;CMD_EFF_JUMP
    .word cmd_eff_skip             ;CMD_EFF_SKIP
    .word cmd_eff_halt             ;CMD_EFF_HALT
    .word cmd_unimplemented        ;CMD_EFF_VOLUME
    .word cmd_eff_clear            ;CMD_EFF_CLEAR
    .word cmd_eff_portaup          ;CMD_EFF_PORTAUP
    .word cmd_eff_portadown        ;CMD_EFF_PORTADOWN
    .word cmd_eff_portamento       ;CMD_EFF_PORTAMENTO
    .word cmd_eff_arpeggio         ;CMD_EFF_ARPEGGIO
    .word cmd_eff_vibrato          ;CMD_EFF_VIBRATO
    .word cmd_eff_tremolo          ;CMD_EFF_TREMOLO
    .word cmd_eff_pitch            ;CMD_EFF_PITCH
    .word cmd_eff_reset_pitch      ;CMD_EFF_RESET_PITCH
    .word cmd_eff_duty             ;CMD_EFF_DUTY
    .word cmd_eff_delay            ;CMD_EFF_DELAY
    .word cmd_unimplemented        ;CMD_EFF_SWEEP
    .word cmd_eff_dac              ;CMD_EFF_DAC
    .word cmd_eff_offset           ;CMD_EFF_OFFSET
    .word cmd_eff_slide_up         ;CMD_EFF_SLIDE_UP
    .word cmd_eff_slide_down       ;CMD_EFF_SLIDE_DOWN
    .word cmd_eff_vol_slide        ;CMD_EFF_VOL_SLIDE
    .word cmd_eff_note_cut         ;CMD_EFF_NOTE_CUT
    .word cmd_eff_retrigger        ;CMD_EFF_RETRIGGER
    .word cmd_unimplemented        ;CMD_EFF_DPCM_PITCH
    .word cmd_unimplemented        ;CMD_EFF_NOTE_RELEASE
    .word cmd_unimplemented        ;CMD_EFF_LINEAR_COUNTER
    .word cmd_eff_groove           ;CMD_EFF_GROOVE
    .word cmd_unimplemented        ;CMD_EFF_DELAYED_VOLUME
    .word cmd_unimplemented        ;CMD_EFF_TRANSPOSE
    .word cmd_eff_phase_reset      ;CMD_EFF_PHASE_RESET
    .word cmd_eff_phase_reset_dpcm ;CMD_EFF_DPCM_PHASE_RESET
    .word cmd_unimplemented        ;CMD_EFF_HARMONIC
    .word cmd_unimplemented        ;CMD_EFF_TARGET_VOL_SLIDE
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
        sta bhop_ptr
        lda command_table+1, y
        sta bhop_ptr+1
        jmp (bhop_ptr)
        ; dispatched command executes rts
.endproc

.proc skip_command
        and #$7F ; mask off the high bit
        ; we can't *actually* skip the duration commands, otherwise we'll bug out the bytecode reader on the next row
        cmp #CommandBytes::CMD_SET_DURATION
        bne not_set_duration
        jmp cmd_set_duration
not_set_duration:
        cmp #CommandBytes::CMD_RESET_DURATION
        bne not_reset_duration
        jmp cmd_reset_duration
not_reset_duration:
        ; these commands have NO parameter byte:
        cmp #CommandBytes::CMD_HOLD
        beq no_parameter_byte
        cmp #CommandBytes::CMD_EFF_CLEAR
        beq no_parameter_byte
        cmp #CommandBytes::CMD_EFF_RESET_PITCH
        beq no_parameter_byte
        ; for anything else, fetch the parameter byte and throw it away
        fetch_pattern_byte
        rts
no_parameter_byte:
        rts
.endproc

; Note: Every command begins with channel_index conveniently in x. This does
; not need to be explicitly restored (calling code does that), but initialization
; *can* be safely skipped.

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
        sta channel_global_duration, x
        lda channel_status, x
        ora #CHANNEL_GLOBAL_DURATION
        sta channel_status, x
        rts
.endproc

.proc cmd_reset_duration
        lda channel_status, x
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta channel_status, x
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
        lda channel_status + PULSE_1_INDEX
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta channel_status + PULSE_1_INDEX

        lda channel_status + PULSE_2_INDEX
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta channel_status + PULSE_2_INDEX

        lda channel_status + TRIANGLE_INDEX
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta channel_status + TRIANGLE_INDEX

        lda channel_status + NOISE_INDEX
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta channel_status + NOISE_INDEX

        lda channel_status + DPCM_INDEX
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta channel_status + DPCM_INDEX

        rts
.endproc

.proc cmd_instrument
        fetch_pattern_byte
        ; of *course* this is pre-shifted, so un-do that:
        lsr
        ; store the instrument and load it up
        sta channel_selected_instrument, x

.if ::BHOP_PATTERN_BANKING
        ; Instruments live in the module bank, so we need to swap that in before processing them
        lda module_bank
        switch_music_bank
.endif
        jsr load_instrument
.if ::BHOP_PATTERN_BANKING
        ; And now we need to switch back to the pattern bank before continuing
        ldx channel_index
        lda channel_pattern_bank, x
        switch_music_bank
        ldx channel_index
.endif  
        rts
.endproc

; Gxx
.proc cmd_eff_delay
        fetch_pattern_byte
        ; here we want to store delay +1... but we can't do that to 
        ; 0xFF or we'll wrap and break the "delay active" logic later. Excessively
        ; large delay values don't make much sense anyway, so lop off the high bit
        ; here to avoid this edge case
        and #$7F
        clc
        adc #1
        ldy channel_index
        sta effect_note_delay, y
        rts
.endproc

.proc cmd_eff_vibrato
        fetch_pattern_byte
        sta channel_vibrato_settings, x
        bne done
        ; for `400` specifically, reset the vibrato phase
        lda #0
        sta channel_vibrato_accumulator, x
done:
        rts
.endproc

.proc cmd_eff_pitch
        fetch_pattern_byte
        sta scratch_byte
        sec
        lda #$80 ; center this on 0, where 0 is in tune
        sbc scratch_byte
        sta channel_tuning, x
        rts
.endproc

.proc cmd_eff_reset_pitch
        lda #0
        sta channel_tuning, x
        rts
.endproc

.proc cmd_eff_note_cut
        fetch_pattern_byte
        clc
        adc #1
        sta effect_cut_delay, x
        lda channel_status, x
        ora #CHANNEL_FRESH_DELAYED_CUT
        sta channel_status, x
        rts
.endproc

.proc cmd_eff_speed
        fetch_pattern_byte
        tax
        jsr set_speed
        rts
.endproc

.proc cmd_eff_tempo
        fetch_pattern_byte
        sta tempo
        rts
.endproc

.proc cmd_eff_skip
        fetch_pattern_byte
        sta effect_skip_target
        rts
.endproc

.proc cmd_eff_arpeggio
        fetch_pattern_byte
        sta channel_arpeggio_settings, x
        lda #0
        sta channel_arpeggio_counter, x
        lda #PITCH_EFFECT_ARP
        sta channel_pitch_effects_active, x
        rts
.endproc

.proc cmd_eff_portaup
        fetch_pattern_byte
        sta channel_pitch_effect_settings, x
        lda #PITCH_EFFECT_UP
        sta channel_pitch_effects_active, x
        rts
.endproc

.proc cmd_eff_portadown
        fetch_pattern_byte
        sta channel_pitch_effect_settings, x
        lda #PITCH_EFFECT_DOWN
        sta channel_pitch_effects_active, x
        rts
.endproc

.proc cmd_eff_portamento
        fetch_pattern_byte
        sta channel_pitch_effect_settings, x
        lda #PITCH_EFFECT_PORTAMENTO
        sta channel_pitch_effects_active, x
        rts
.endproc

.proc cmd_eff_slide_up
        fetch_pattern_byte
        sta channel_pitch_effect_settings, x
        lda #(PITCH_EFFECT_NOTE_UP | PITCH_EFFECT_TRIGGERED)
        sta channel_pitch_effects_active, x
        rts
.endproc

.proc cmd_eff_slide_down
        fetch_pattern_byte
        sta channel_pitch_effect_settings, x
        lda #(PITCH_EFFECT_NOTE_DOWN | PITCH_EFFECT_TRIGGERED)
        sta channel_pitch_effects_active, x
        rts
.endproc

.proc cmd_eff_clear
        lda #0
        sta channel_pitch_effects_active, x
        rts
.endproc

.proc cmd_eff_duty
        fetch_pattern_byte
        ror
        ror
        ror
        ; safety
        and #%11000000
        sta channel_duty, x
        rts
.endproc

.proc cmd_eff_tremolo
        fetch_pattern_byte
        sta channel_tremolo_settings, x
        bne done
        ; for `700` specifically, reset the tremolo phase
        lda #0
        sta channel_tremolo_accumulator, x
done:
        rts
.endproc

.proc cmd_eff_vol_slide
        fetch_pattern_byte
        sta channel_volume_slide_settings, x
        lda #0
        sta channel_volume_slide_accumulator, x
        rts
.endproc

.proc cmd_eff_halt
        fetch_pattern_byte ; and throw it away
        ; set the tempo to 0 (stops rows from advancing at all)
        lda #0
        sta tempo
        ; immediately mute all channels
        ldx #NUM_CHANNELS
loop:
        dex
        lda channel_status, x
        ora #CHANNEL_MUTED
        sta channel_status, x
        cpx #0
        bne loop
        rts
.endproc

; Xxx
.proc cmd_eff_retrigger
; from Channels2A03.cpp:
; mRetriggerPeriod = std::max((int)EffParam, 1);
; if (mRetriggerCtr == 0) {	// Most recent row contains note without Xxx
    ; queueSample();
; }
        fetch_pattern_byte
        ; X00 == X01
        bne skip_increment
        inc a
skip_increment:
        sta effect_retrigger_period
        lda effect_retrigger_counter
        bne done
        jsr queue_sample
done:
        rts
.endproc

; =xx
.proc cmd_eff_phase_reset
        fetch_pattern_byte
        bne continue ; currently, =xx commands are only valid if the parameter is 0
        rts
continue:
        cpx #PULSE_1_INDEX
        beq p1phasereset
        cpx #PULSE_2_INDEX
        beq p2phasereset
        rts ; else, exit
p1phasereset:
; write current period value to registers again
        lda channel_detuned_frequency_low + PULSE_1_INDEX
        sta $4002
        lda channel_detuned_frequency_high + PULSE_1_INDEX
        sta shadow_pulse1_freq_hi
        ora #%11111000
        sta $4003
        rts
p2phasereset:
; write current period value to registers again
        lda channel_detuned_frequency_low + PULSE_2_INDEX
        sta $4006
        lda channel_detuned_frequency_high + PULSE_2_INDEX
        sta shadow_pulse2_freq_hi
        ora #%11111000
        sta $4007
        rts
.endproc

; =xx for DPCM, practically a one-shot retrigger command
.proc cmd_eff_phase_reset_dpcm
; from Channels2A03.cpp:
; if (EffParam == 0) {
    ; resetPhase();
; }
        fetch_pattern_byte
        bne continue ; currently, =xx commands are only valid if the parameter is 0
        rts
continue:
        cpx #DPCM_INDEX
        bne done
        jsr trigger_sample
done:
        rts
.endproc

.proc cmd_eff_dac
        fetch_pattern_byte
        and #$7F
        sta effect_dac_level
        rts
.endproc

.proc cmd_eff_offset
        fetch_pattern_byte
        sta effect_dpcm_offset
        rts
.endproc

.proc cmd_eff_groove
        fetch_pattern_byte
        sta groove_index
        sta groove_position
        rts
.endproc