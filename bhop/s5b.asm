S5B_AUDIO_REG  = $C000
S5B_AUDIO_DATA = $E000

S5B_AUDIO_CMD_PULSE_1_PERIOD_LOW     = $0
S5B_AUDIO_CMD_PULSE_1_PERIOD_HIGH    = $1
S5B_AUDIO_CMD_PULSE_2_PERIOD_LOW     = $2
S5B_AUDIO_CMD_PULSE_2_PERIOD_HIGH    = $3
S5B_AUDIO_CMD_PULSE_3_PERIOD_LOW     = $4
S5B_AUDIO_CMD_PULSE_3_PERIOD_HIGH    = $5
S5B_AUDIO_CMD_NOISE_PERIOD           = $6
S5B_AUDIO_CMD_NOISE_TONE_FLAGS       = $7
S5B_AUDIO_CMD_PULSE_1_ENV_VOL        = $8
S5B_AUDIO_CMD_PULSE_2_ENV_VOL        = $9
S5B_AUDIO_CMD_PULSE_3_ENV_VOL        = $A
S5B_AUDIO_CMD_ENV_PERIOD_LOW         = $B
S5B_AUDIO_CMD_ENV_PERIOD_HIGH        = $C
S5B_AUDIO_CMD_ENV_FLAGS              = $D

FT_S5B_ENV_FLAG   = %00100000
FT_S5B_TONE_FLAG  = %01000000
FT_S5B_NOISE_FLAG = %10000000
FT_S5B_NOISE_MASK = %00011111

S5B_PULSE_1_TONE_DISABLED  = %00000001
S5B_PULSE_2_TONE_DISABLED  = %00000010
S5B_PULSE_3_TONE_DISABLED  = %00000100
S5B_PULSE_1_NOISE_DISABLED = %00001000
S5B_PULSE_2_NOISE_DISABLED = %00010000
S5B_PULSE_3_NOISE_DISABLED = %00100000

; TODO: if we can make an EPSM-specific command macro, supporting it should be cake?
; ... very SLOW cake, but cake all the same
.macro s5b_command command_byte, data_byte
    lda command_byte
    sta S5B_AUDIO_REG
    lda data_byte
    sta S5B_AUDIO_DATA
.endmacro

.macro s5b_command_a command_byte
    ldx command_byte
    stx S5B_AUDIO_REG
    sta S5B_AUDIO_DATA
.endmacro

.proc init_s5b
        ; Mute all three channels
        lda #0
        s5b_command_a #S5B_AUDIO_CMD_PULSE_1_ENV_VOL
        s5b_command_a #S5B_AUDIO_CMD_PULSE_2_ENV_VOL
        s5b_command_a #S5B_AUDIO_CMD_PULSE_3_ENV_VOL
        rts
.endproc

.proc play_s5b
        lda #0
        sta s5b_noise_tone_scratch

tick_pulse1:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + S5B_PULSE_1_INDEX
        bne tick_pulse2
        bmi pulse1_muted

        ; Process the tone/noise/env flags into their respective bits
        lda channel_instrument_duty + S5B_PULSE_1_INDEX
        and #FT_S5B_TONE_FLAG
        bne pulse_1_tone_enabled
        lda #S5B_PULSE_1_TONE_DISABLED
        ora s5b_noise_tone_scratch
        sta s5b_noise_tone_scratch
pulse_1_tone_enabled:
        lda channel_instrument_duty + S5B_PULSE_1_INDEX
        and #FT_S5B_NOISE_FLAG
        bne pulse_1_noise_enabled
        lda #S5B_PULSE_1_NOISE_DISABLED
        ora s5b_noise_tone_scratch
        sta s5b_noise_tone_scratch
        jmp done_with_pulse1_noise
pulse_1_noise_enabled:
        lda channel_instrument_duty + S5B_PULSE_1_INDEX
        and #FT_S5B_NOISE_MASK
        sta s5b_noise_period
done_with_pulse1_noise:
        ; TODO: envelopes!
        
        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + S5B_PULSE_1_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + S5B_PULSE_1_INDEX
        tax
        lda volume_table, x
        ora scratch_byte
        ; TODO: if envelope is enabled, what do?
        s5b_command_a #S5B_AUDIO_CMD_PULSE_1_ENV_VOL

        lda channel_detuned_frequency_low + S5B_PULSE_1_INDEX
        s5b_command_a #S5B_AUDIO_CMD_PULSE_1_PERIOD_LOW
        lda channel_detuned_frequency_high + S5B_PULSE_1_INDEX
        s5b_command_a #S5B_AUDIO_CMD_PULSE_1_PERIOD_HIGH
        jmp tick_pulse2
pulse1_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #0
        s5b_command_a #S5B_AUDIO_CMD_PULSE_1_ENV_VOL

tick_pulse2:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + S5B_PULSE_2_INDEX
        bne tick_pulse3
        bmi pulse2_muted

        ; Process the tone/noise/env flags into their respective bits
        lda channel_instrument_duty + S5B_PULSE_2_INDEX
        and #FT_S5B_TONE_FLAG
        bne pulse_2_tone_enabled
        lda #S5B_PULSE_2_TONE_DISABLED
        ora s5b_noise_tone_scratch
        sta s5b_noise_tone_scratch
pulse_2_tone_enabled:
        lda channel_instrument_duty + S5B_PULSE_2_INDEX
        and #FT_S5B_NOISE_FLAG
        bne pulse_2_noise_enabled
        lda #S5B_PULSE_2_NOISE_DISABLED
        ora s5b_noise_tone_scratch
        sta s5b_noise_tone_scratch
        jmp done_with_pulse2_noise
pulse_2_noise_enabled:
        lda channel_instrument_duty + S5B_PULSE_2_INDEX
        and #FT_S5B_NOISE_MASK
        sta s5b_noise_period
done_with_pulse2_noise:
        ; TODO: envelopes!
        
        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + S5B_PULSE_2_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + S5B_PULSE_2_INDEX
        tax
        lda volume_table, x
        ora scratch_byte
        ; TODO: if envelope is enabled, what do?
        s5b_command_a #S5B_AUDIO_CMD_PULSE_2_ENV_VOL

        lda channel_detuned_frequency_low + S5B_PULSE_2_INDEX
        s5b_command_a #S5B_AUDIO_CMD_PULSE_2_PERIOD_LOW
        lda channel_detuned_frequency_high + S5B_PULSE_2_INDEX
        s5b_command_a #S5B_AUDIO_CMD_PULSE_2_PERIOD_HIGH
        jmp tick_pulse3
pulse2_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #0
        s5b_command_a #S5B_AUDIO_CMD_PULSE_2_ENV_VOL

tick_pulse3:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + S5B_PULSE_3_INDEX
        bne apply_global_writes
        bmi pulse3_muted

        ; Process the tone/noise/env flags into their respective bits
        lda channel_instrument_duty + S5B_PULSE_3_INDEX
        and #FT_S5B_TONE_FLAG
        bne pulse_3_tone_enabled
        lda #S5B_PULSE_3_TONE_DISABLED
        ora s5b_noise_tone_scratch
        sta s5b_noise_tone_scratch
pulse_3_tone_enabled:
        lda channel_instrument_duty + S5B_PULSE_3_INDEX
        and #FT_S5B_NOISE_FLAG
        bne pulse_3_noise_enabled
        lda #S5B_PULSE_3_NOISE_DISABLED
        ora s5b_noise_tone_scratch
        sta s5b_noise_tone_scratch
        jmp done_with_pulse3_noise
pulse_3_noise_enabled:
        lda channel_instrument_duty + S5B_PULSE_3_INDEX
        and #FT_S5B_NOISE_MASK
        sta s5b_noise_period
done_with_pulse3_noise:
        ; TODO: envelopes!
        
        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + S5B_PULSE_3_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + S5B_PULSE_3_INDEX
        tax
        lda volume_table, x
        ora scratch_byte
        ; TODO: if envelope is enabled, what do?
        s5b_command_a #S5B_AUDIO_CMD_PULSE_3_ENV_VOL

        lda channel_detuned_frequency_low + S5B_PULSE_3_INDEX
        s5b_command_a #S5B_AUDIO_CMD_PULSE_3_PERIOD_LOW
        lda channel_detuned_frequency_high + S5B_PULSE_3_INDEX
        s5b_command_a #S5B_AUDIO_CMD_PULSE_3_PERIOD_HIGH
        jmp apply_global_writes
pulse3_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #0
        s5b_command_a #S5B_AUDIO_CMD_PULSE_3_ENV_VOL

apply_global_writes:
        lda s5b_noise_tone_scratch
        s5b_command_a #S5B_AUDIO_CMD_NOISE_TONE_FLAGS
        ; of *course* this is inverted >_>
        lda #$1F
        sec
        sbc s5b_noise_period
        s5b_command_a #S5B_AUDIO_CMD_NOISE_PERIOD

        rts
.endproc