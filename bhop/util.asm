; utility functions to aid in setting initial pitch
; All three accept MIDI index in A, and channel index in X
; All three will clobber Y, and differ only in their output
; The channel index (X) determines which pitch table is used

.macro __set_frequency target_low, target_high
.scope
    tay ; Y will index into the chosen pitch table

    ; some expansion chips have separate initial pitch tables, check for
    ; and use those here
.if ::BHOP_VRC6_ENABLED
    cpx #VRC6_SAWTOOTH_INDEX
    bne not_saw
    ; do saw here
    lda vrc6_sawtooth_period_low, y
    sta target_low
    lda vrc6_sawtooth_period_high, y
    sta target_high
    rts

not_saw:
    cpx #VRC6_PULSE_1_INDEX   
    bne not_vrc6_pulse_1
    jmp is_vrc6_pulse
not_vrc6_pulse_1:
    cpx #VRC6_PULSE_2_INDEX   
    bne not_vrc6
is_vrc6_pulse:
    ; do vrc6 pulse here
    lda vrc6_pulse_period_low, y
    sta target_low
    lda vrc6_pulse_period_high, y
    sta target_high
    rts

not_vrc6:
.endif
    
    ; if we don't hit a special case, fall through to typical 2A03
ntsc_2a03:
    lda ntsc_period_low, y
    sta target_low
    lda ntsc_period_high, y
    sta target_high
.endscope
.endmacro

.proc set_channel_base_frequency
    __set_frequency {channel_base_frequency_low, x}, {channel_base_frequency_high, x}
    rts
.endproc

.proc set_channel_relative_frequency
    __set_frequency {channel_relative_frequency_low, x}, {channel_relative_frequency_high, x}
    rts
.endproc

.proc set_scratch_target_frequency
    __set_frequency {scratch_target_frequency}, {scratch_target_frequency+1}
    rts
.endproc