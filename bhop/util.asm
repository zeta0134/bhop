; utility functions to aid in setting initial pitch
; All three accept MIDI index in A, and channel index in X
; All three will clobber Y, and differ only in their output
; The channel index (X) determines which pitch table is used

; TODO: 2A03, VRC6 and S5B could share a single pitch table
; with a bit of extra logic to deal with minor variances. We
; should consider doing this, as it saves quite a bit of space!

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
    
.if ::BHOP_S5B_ENABLED
    cpx #S5B_PULSE_1_INDEX
    beq is_s5b
    cpx #S5B_PULSE_2_INDEX
    beq is_s5b
    cpx #S5B_PULSE_3_INDEX
    beq is_s5b
    jmp not_s5b
is_s5b:
    lda s5b_period_low, y
    sta target_low
    lda s5b_period_high, y
    sta target_high

    rts

not_s5b:
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