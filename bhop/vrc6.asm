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
        ; TODO: support 6bit volume mode... somehow!
        lda #CHANNEL_SUPPRESSED
        bit channel_status + VRC6_SAWTOOTH_INDEX
        bne done
        bmi sawtooth_muted

        ; sawtooth supports a 6bit volume mode which works very differently
        ; check for that here
        lda channel_volume_mode + VRC6_SAWTOOTH_INDEX
        beq apply_4bit_vol
        jsr compute_6bit_vol
        jmp sawvol_converge

apply_4bit_vol:        
        ; duty is used to set bit 5
        lda channel_instrument_duty + VRC6_SAWTOOTH_INDEX
        asl
        asl
        asl
        asl
        and #%00100000
        sta scratch_byte

        ; combined channel and instrument volume sets bits 1-4 (and bit 0 remains 0)
        lda channel_tremolo_volume + VRC6_SAWTOOTH_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + VRC6_SAWTOOTH_INDEX
        tax
        lda volume_table, x
        asl
        ora scratch_byte
sawvol_converge:
        sta $B000

        lda channel_detuned_frequency_low + VRC6_SAWTOOTH_INDEX
        sta $B001
        lda channel_detuned_frequency_high + VRC6_SAWTOOTH_INDEX
        ora #%10000000
        sta $B002
        jmp done
sawtooth_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00000000
        sta $B000
        
done:
        rts
.endproc

.proc init_vrc6
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00000000
        sta $9000
        sta $A000
        sta $B000
        rts
.endproc

; This is slightly wrong; Dn-FamiTracker expects a /15, while this produces
; an effective /16. For the moment I've decided that I don't care, as doing
; it properly is stupidly expensive.
.proc compute_6bit_vol
scratch_result := bhop_ptr

        lda channel_volume + VRC6_SAWTOOTH_INDEX
        sta scratch_byte
        lda #0
        sta scratch_result

process_bit_0:
        ; if xxx1 then...
        lsr scratch_byte
        bcc process_bit_1
        ; add inst_vol to scratch result
        lda channel_instrument_volume + VRC6_SAWTOOTH_INDEX
        sta scratch_result
process_bit_1:
        lsr scratch_result
        ; if xx1x then...
        lsr scratch_byte
        bcc process_bit_2
        lda channel_instrument_volume + VRC6_SAWTOOTH_INDEX
        clc
        adc scratch_result
        sta scratch_result
process_bit_2:
        lsr scratch_result
        ; if x1xx then...
        lsr scratch_byte
        bcc process_bit_3
        lda channel_instrument_volume + VRC6_SAWTOOTH_INDEX
        clc
        adc scratch_result
        sta scratch_result
process_bit_3:
        lsr scratch_result
        ; if 1xxx then...
        lsr scratch_byte
        bcc done_with_mul
        lda channel_instrument_volume + VRC6_SAWTOOTH_INDEX
        clc
        adc scratch_result
        sta scratch_result
done_with_mul:
        lsr scratch_result
        lda scratch_result
        rts
.endproc
