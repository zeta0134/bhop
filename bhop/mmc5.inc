.proc play_mmc5
; basically identical to 2A03 updates, except with MMC5 registers instead of APU ones
        ; firstly, enable MMC5 audio
        lda #%00000011
        sta $5015

tick_pulse1:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + MMC5_PULSE_1_INDEX
        bne tick_pulse2
        bmi pulse1_muted

        ; add in the duty
        lda channel_instrument_duty + MMC5_PULSE_1_INDEX
        ror
        ror
        ror
        and #%11000000
        sta scratch_byte

        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + MMC5_PULSE_1_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + MMC5_PULSE_1_INDEX
        tax
        lda volume_table, x
        ora #%00110000 ; disable length counter and envelope
        ora scratch_byte
        sta $5000

        lda channel_detuned_frequency_low + MMC5_PULSE_1_INDEX
        sta $5002

        ; If we triggered this frame, write unconditionally
        lda channel_status + MMC5_PULSE_1_INDEX
        and #CHANNEL_TRIGGERED
        bne write_pulse1

        ; otherwise, to avoid resetting the sequence counter, only
        ; write if the high byte has changed since the last time
        lda channel_detuned_frequency_high + MMC5_PULSE_1_INDEX
        cmp shadow_mmc5_pulse1_freq_hi
        beq tick_pulse2

write_pulse1:
        lda channel_detuned_frequency_high + MMC5_PULSE_1_INDEX
        sta shadow_mmc5_pulse1_freq_hi
        ora #%11111000
        sta $5003
        jmp tick_pulse2
pulse1_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00110000
        sta $5000

tick_pulse2:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + MMC5_PULSE_2_INDEX
        bne done_with_mmc5
        bmi pulse2_muted

        ; add in the duty
        lda channel_instrument_duty + MMC5_PULSE_2_INDEX
        ror
        ror
        ror
        and #%11000000
        sta scratch_byte

        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + MMC5_PULSE_2_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + MMC5_PULSE_2_INDEX
        tax
        lda volume_table, x
        ora #%00110000 ; disable length counter and envelope
        ora scratch_byte
        sta $5004

        lda channel_detuned_frequency_low + MMC5_PULSE_2_INDEX
        sta $5006

        ; If we triggered this frame, write unconditionally
        lda channel_status + MMC5_PULSE_2_INDEX
        and #CHANNEL_TRIGGERED
        bne write_pulse2

        ; otherwise, to avoid resetting the sequence counter, only
        ; write if the high byte has changed since the last time
        lda channel_detuned_frequency_high + MMC5_PULSE_2_INDEX
        cmp shadow_mmc5_pulse2_freq_hi
        beq done_with_mmc5

write_pulse2:
        lda channel_detuned_frequency_high + MMC5_PULSE_2_INDEX
        sta shadow_mmc5_pulse2_freq_hi
        ora #%11111000
        sta $5007
        jmp done_with_mmc5
pulse2_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00110000
        sta $5004

done_with_mmc5:
        rts
.endproc