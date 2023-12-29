.proc play_vrc6
tick_pulse1:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + VRC6_PULSE_1_INDEX
        bne tick_pulse2
        bmi pulse1_muted

        ; add in the duty
        lda channel_instrument_duty + VRC6_PULSE_1_INDEX
        asl
        asl
        asl
        asl
        sta scratch_byte
        
        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + VRC6_PULSE_1_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + VRC6_PULSE_1_INDEX
        tax
        lda volume_table, x
        ora scratch_byte
        sta $9000

        lda channel_detuned_frequency_low + VRC6_PULSE_1_INDEX
        sta $9001
        lda channel_detuned_frequency_high + VRC6_PULSE_1_INDEX
        ora #%10000000
        sta $9002
        jmp tick_pulse2
pulse1_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00000000
        sta $9000

tick_pulse2:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + VRC6_PULSE_2_INDEX
        bne tick_sawtooth
        bmi pulse2_muted

        ; add in the duty
        lda channel_instrument_duty + VRC6_PULSE_2_INDEX
        asl
        asl
        asl
        asl
        sta scratch_byte
        
        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + VRC6_PULSE_2_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + VRC6_PULSE_2_INDEX
        tax
        lda volume_table, x
        ora scratch_byte
        sta $A000

        lda channel_detuned_frequency_low + VRC6_PULSE_2_INDEX
        sta $A001
        lda channel_detuned_frequency_high + VRC6_PULSE_2_INDEX
        ora #%10000000
        sta $A002
        jmp tick_sawtooth
pulse2_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00000000
        sta $A000

tick_sawtooth:
        ; TODO
        rts
.endproc