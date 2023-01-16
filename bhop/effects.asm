        .segment BHOP_RAM_SEGMENT
channel_vibrato_settings: .res BHOP::NUM_CHANNELS
channel_vibrato_accumulator: .res BHOP::NUM_CHANNELS
channel_tuning: .res BHOP::NUM_CHANNELS
channel_arpeggio_settings: .res BHOP::NUM_CHANNELS
channel_arpeggio_counter: .res BHOP::NUM_CHANNELS
channel_pitch_effect_settings: .res BHOP::NUM_CHANNELS
channel_tremolo_settings: .res BHOP::NUM_CHANNELS
channel_tremolo_accumulator: .res BHOP::NUM_CHANNELS
channel_volume_slide_settings: .res BHOP::NUM_CHANNELS
channel_volume_slide_accumulator: .res BHOP::NUM_CHANNELS

scratch_target_frequency: .res 2

        .segment BHOP_PLAYER_SEGMENT
.include "vibrato_lut.inc"

; Vibrato LUT: there are 16 tables, each containing the first 1/4 of a sine
; wave at the desired depth. This function takes care of duplicating that
; table reversed / inverted, as appropriate, to generate the other 3 sections
; and complete the full waveform.

; prep: 
;   x contains channel_index
; return:
;   a - vibrato strength, signed
; clobbers: y, scratch_byte
.proc read_vibrato_lut
        ; note: we can't use BIT here, it has inconvenient addressing modes
        ; fortunately it's ideal for A to end up mostly cleared
        lda #%00010000
        and channel_vibrato_accumulator, x
        bne reverse_lut
normal_lut:
        lda #$0F
        and channel_vibrato_accumulator, x
        jmp store_index
reverse_lut:
        ; A already contains 0000 in its low bits, which
        ; works fine in this case
        clc
        sbc channel_vibrato_accumulator, x
        and #$0F ; mask off the upper bits
store_index:
        sta scratch_byte
        lda channel_vibrato_settings, x
        and #$F0
        ora scratch_byte
        tay
        ; now we check to see if we'll need to invert this read
        lda #%00100000
        and channel_vibrato_accumulator, x
        bne invert_read
normal_read:
        lda vibrato_lut, y
        rts
invert_read:
        lda #$00
        sec
        sbc vibrato_lut, y
        rts
.endproc

; prep: 
;   channel_index set for the desired channel
;   detuned_frequency contains base pitch
; effects:
;   detuned_frequency has vibrato strength applied to it
; clobbers: x, y, scratch_byte
.proc update_vibrato
        ldx channel_index
        lda channel_vibrato_settings, x
        beq done ; bail early if vibrato is disabled

        ; apply the current vibrato speed to the accumulator
        and #$0F
        clc
        adc channel_vibrato_accumulator, x
        sta channel_vibrato_accumulator, x
        
        ; now apply that to detuned_frequency
        jsr read_vibrato_lut ; does not clobber x
        sta scratch_byte
        sadd16_split_x channel_detuned_frequency_low, channel_detuned_frequency_high, scratch_byte
done:
        rts
.endproc

.proc update_tuning
        ldx channel_index
        lda channel_tuning, x
        sta scratch_byte
        sadd16_split_x channel_detuned_frequency_low, channel_detuned_frequency_high, scratch_byte
        rts
.endproc

; prep: 
;   channel_index set for the desired channel
;   base_note contains the tracked note
; effects:
;   relative_frequency gets the arp'd note
.proc update_arp
        ldx channel_index
        lda channel_pitch_effects_active, x
        and #(PITCH_EFFECT_ARP)
        beq done

        ; the current arp counter determines which offset we apply to base_note
        lda channel_arpeggio_counter, x
        beq first_tick
        cmp #1
        beq second_tick
third_tick:
        ; add the low nybble to the base note
        lda channel_arpeggio_settings, x
        and #$0F
        clc
        adc channel_base_note, x
        tay
        jmp apply_adjusted_note
second_tick:
        ; add the high nybble to the base note
        lda channel_arpeggio_settings, x
        lsr
        lsr
        lsr
        lsr
        clc
        adc channel_base_note, x
        tay
        jmp apply_adjusted_note
first_tick:
        ; use the base_note directly
        lda channel_base_note, x
        tay
        ; fall through to:
apply_adjusted_note:
        lda ntsc_period_low, y
        sta channel_relative_frequency_low, x
        lda ntsc_period_high, y
        sta channel_relative_frequency_high, x
increment_arp_counter:
        inc channel_arpeggio_counter, x
        lda #3
        cmp channel_arpeggio_counter, x
        bne done
        lda #0
        sta channel_arpeggio_counter, x

done:
        rts
.endproc

.if ::BHOP_ZSAW_ENABLED
; prep: 
;   channel_index set for the desired channel
;   base_note contains the tracked note
; effects:
;   relative_frequency gets the arp'd note
.proc update_arp_zsaw
        ldx channel_index
        lda channel_pitch_effects_active, x
        and #(PITCH_EFFECT_ARP)
        beq done

        ; the current arp counter determines which offset we apply to base_note
        lda channel_arpeggio_counter, x
        beq first_tick
        cmp #1
        beq second_tick
third_tick:
        ; add the low nybble to the base note
        lda channel_arpeggio_settings, x
        and #$0F
        clc
        adc channel_base_note, x
        tay
        jmp apply_adjusted_note
second_tick:
        ; add the high nybble to the base note
        lda channel_arpeggio_settings, x
        lsr
        lsr
        lsr
        lsr
        clc
        adc channel_base_note, x
        tay
        jmp apply_adjusted_note
first_tick:
        ; use the base_note directly
        lda channel_base_note, x
        tay
        ; fall through to:
apply_adjusted_note:
        sty zsaw_relative_note
increment_arp_counter:
        inc channel_arpeggio_counter, x
        lda #3
        cmp channel_arpeggio_counter, x
        bne done
        lda #0
        sta channel_arpeggio_counter, x

done:
        rts
.endproc
.endif

; sortof a dispatch function, since pitch effects are all processed at
; the same time but have subtly different behavior
; prep: 
;   channel_index set for the desired channel
;   base_note contains the triggered OR current target note (depending on effect)
;   relative_frequency contains the active frequency
; effects:
;   relative_frequency gets the adjusted frequency
;   on trigger, base_note might be adjusted (depends on effect)
.proc update_pitch_effects
        ldx channel_index
        lda channel_pitch_effects_active, x
        and #($FF - PITCH_EFFECT_ARP)
        beq done ; no effects active at all
        
        ; here we abuse the flag layout for the effects; only one of these
        ; will ever be enabled at a time, and they are in this order:
        ;PITCH_EFFECT_UP           = %00000001
        ;PITCH_EFFECT_DOWN         = %00000010
        ;PITCH_EFFECT_PORTAMENTO   = %00000100
        ;PITCH_EFFECT_NOTE_UP      = %00001000
        ;PITCH_EFFECT_NOTE_DOWN    = %00010000

        ; given the above, let's shift the bits of A out to the right,
        ; and call the selected function
check_slide_up:
        lsr
        bcc check_slide_down
        jsr update_pitch_slide_up
        rts
check_slide_down:
        lsr
        bcc check_portamento
        jsr update_pitch_slide_down
        rts
check_portamento:
        lsr
        bcc check_note_up
        jsr update_portamento
        rts
check_note_up:
        lsr
        bcc check_note_down
        jsr update_pitch_note_slide_up
        rts
check_note_down:
        lsr
        bcc done
        jsr update_pitch_note_slide_down
done:
        rts
.endproc

; 1xx: unconditional slide upwards; amount in xx
.proc update_pitch_slide_up
        ; (to increase pitch, we decrease period)
        sec
        lda channel_relative_frequency_low, x
        sbc channel_pitch_effect_settings, x
        sta channel_relative_frequency_low, x
        lda channel_relative_frequency_high, x
        sbc #0
        sta channel_relative_frequency_high, x
        rts
.endproc

; 2xx: unconditional pitch slide downwards; amount in xx
.proc update_pitch_slide_down
        ; (to decrease pitch, we increase period)
        clc
        lda channel_relative_frequency_low, x
        adc channel_pitch_effect_settings, x
        sta channel_relative_frequency_low, x
        lda channel_relative_frequency_high, x
        adc #0
        sta channel_relative_frequency_high, x
        rts
.endproc

; 3xx: automatic portamento, speed in xx
; prep: base_note, set by the tracked row, is the relative target
; note: does not disable itself automatically (that's the "automatic" part)
.proc update_portamento
        ; work out the target frequency based on the base_note
        ldy channel_base_note, x
        lda ntsc_period_low, y
        sta scratch_target_frequency
        lda ntsc_period_high, y
        sta scratch_target_frequency+1
        ; determine if our current relative_frequency is above or below the target
check_high:
        lda channel_relative_frequency_high, x
        cmp scratch_target_frequency+1
        beq check_low
        bcc pitch_up ; channel frequency (A) is lower than target (M)
        jmp pitch_down   
check_low:
        lda channel_relative_frequency_low, x
        cmp scratch_target_frequency
        beq done ; we are already at the target, no change needed
        bcc pitch_up ; channel frequency (A) is lower than target (M)
pitch_down:
        ; subtract towards our target, based on the current speed
        sec
        lda channel_relative_frequency_low, x
        sbc channel_pitch_effect_settings, x
        sta channel_relative_frequency_low, x
        lda channel_relative_frequency_high, x
        sbc #0
        sta channel_relative_frequency_high, x
        ; did we overshoot our target? (is relative_frequency now BELOW target_frequency?)
post_down_check_high:
        lda scratch_target_frequency+1
        cmp channel_relative_frequency_high, x
        beq post_down_check_low
        bcc done ; target frequency (A) is STILL lower than channel frequency (M)
        jmp fix_it
post_down_check_low:
        lda scratch_target_frequency
        cmp channel_relative_frequency_low, x
        beq done ; we have reached the target, no change needed
        bcc done ; target frequency (A) is STILL lower than channel frequency (M)
        jmp fix_it
pitch_up:
        ; add towards our target, based on the current speed
        clc
        lda channel_relative_frequency_low, x
        adc channel_pitch_effect_settings, x
        sta channel_relative_frequency_low, x
        lda channel_relative_frequency_high, x
        adc #0
        sta channel_relative_frequency_high, x
        ; did we overshoot our target? (is relative_frequency now ABOVE target_frequency?)
post_up_check_high:
        lda channel_relative_frequency_high, x
        cmp scratch_target_frequency+1
        beq post_up_check_low
        bcc done ; channel frequency (A) is STILL lower than target (M)
        jmp fix_it
post_up_check_low:
        lda channel_relative_frequency_low, x
        cmp scratch_target_frequency
        beq done ; we have reached the target, no change needed
        bcc done ; channel frequency (A) is STILL lower than target (M)
        ; fall through to fix_it
fix_it:
        lda scratch_target_frequency
        sta channel_relative_frequency_low, x
        lda scratch_target_frequency+1
        sta channel_relative_frequency_high, x
done:
        rts
.endproc

; Qxy: targeted note slide upwards; speed in x, semitones in y
; prep: original note in base_note
; when the target note is reached, the effect becomes disabled
.proc update_pitch_note_slide_up
        ; have we just triggered? If so, adjust base_note to use the new offset
        lda channel_pitch_effects_active, x
        and #PITCH_EFFECT_TRIGGERED
        beq not_triggered
        ; clear the trigger flag which we are about to service
        lda channel_pitch_effects_active, x
        and #($FF - PITCH_EFFECT_TRIGGERED)
        sta channel_pitch_effects_active, x

        lda channel_pitch_effect_settings, x
        and #$0F ; a now contains semitone offset
        clc
        adc channel_base_note, x
        sta channel_base_note, x
        ; set the portamento speed based on the high nybble
        ; Given Qxy, compute (x >> 3 + 1)
        lda channel_pitch_effect_settings, x
        lsr
        lsr
        lsr
        ora #1
        sta channel_pitch_effect_settings, x
        jmp apply_effect
not_triggered:
        ; was the *channel* just triggered?
        ; if so, disable ourselves
        lda channel_status, x
        and #CHANNEL_TRIGGERED
        bne disable_effect

apply_effect:
        ; apply a portamento effect to chase the target note
        jsr update_portamento
        rts ; all done
disable_effect:
        lda #0
        sta channel_pitch_effects_active, x
done:   
        rts
.endproc

; Rxy: targeted note slide downwards; speed in x, semitones in y
; prep: original note in base_note
; when the target note is reached, the effect becomes disabled
.proc update_pitch_note_slide_down
        ; have we just triggered? If so, adjust base_note to use the new offset
        lda channel_pitch_effects_active, x
        and #PITCH_EFFECT_TRIGGERED
        beq not_triggered
        ; clear the trigger flag which we are about to service
        lda channel_pitch_effects_active, x
        and #($FF - PITCH_EFFECT_TRIGGERED)
        sta channel_pitch_effects_active, x

        lda channel_pitch_effect_settings, x
        and #$0F ; a now contains semitone offset
        sta scratch_byte
        lda channel_base_note, x
        sec
        sbc scratch_byte
        sta channel_base_note, x
        ; set the portamento speed based on the high nybble
        ; Given Rxy, compute (x >> 3 + 1)
        lda channel_pitch_effect_settings, x
        lsr
        lsr
        lsr
        ora #1
        sta channel_pitch_effect_settings, x
        jmp apply_effect
not_triggered:
        ; was the *channel* just triggered?
        ; if so, disable ourselves
        lda channel_status, x
        and #CHANNEL_TRIGGERED
        bne disable_effect

apply_effect:
        ; apply a portamento effect to chase the target note
        jsr update_portamento
        rts ; all done
disable_effect:
        lda #0
        sta channel_pitch_effects_active, x
done:   
        rts
.endproc

.proc update_volume_effects
        ldx channel_index
        jsr update_tremolo
        jsr update_volume_slide
        rts
.endproc

.proc update_tremolo
        lda channel_tremolo_settings, x
        beq no_tremolo ; bail fast

        ; apply the current tremolo speed to the accumulator
        and #$0F
        clc
        adc channel_tremolo_accumulator, x
        sta channel_tremolo_accumulator, x

        ; now read the "tremolo" LUT, then subtract the result from channel_volume
        jsr read_tremolo_lut
        sta scratch_byte
        lda channel_volume, x
        sec
        sbc scratch_byte
        ; if we land on 0 or end up negative, we need to clamp to 1
        bpl no_clamp
        lda #1
no_clamp:
        sta channel_tremolo_volume, x
        rts

no_tremolo:
        ; use the channel volume directly then
        lda channel_volume, x
        sta channel_tremolo_volume, x
        rts
.endproc

; Read the "tremolo" LUT, which is actually a riff on the vibrato LUT. Here we only
; care about the first half of the table, so we need the mirroring logic, but not the
; negation logic.
; prep: 
;   x contains channel_index
; return:
;   a - tremolo strength, unsigned
; clobbers: y, scratch_byte
.proc read_tremolo_lut
        ; tremolo advances the accumulator at half speed
        lda channel_tremolo_accumulator, x
        lsr
        sta scratch_byte
        ; note: we can't use BIT here, it has inconvenient addressing modes
        ; fortunately it's ideal for A to end up mostly cleared
        lda #%00010000
        and scratch_byte
        bne reverse_lut
normal_lut:
        lda #$0F
        and scratch_byte
        jmp store_index
reverse_lut:
        ; A already contains 0000 in its low bits, which
        ; works fine in this case
        clc
        sbc scratch_byte
        and #$0F ; mask off the upper bits
store_index:
        sta scratch_byte
        lda channel_tremolo_settings, x
        and #$F0
        ora scratch_byte
        tay        
normal_read:
        lda vibrato_lut, y
        ; tremolo is at half-strength
        lsr
        rts
.endproc

.proc update_volume_slide
        lda channel_volume_slide_settings, x
        beq done

        ; the high nybble should be added to the accumulator
        lsr
        lsr
        lsr
        lsr
        clc
        adc channel_volume_slide_accumulator, x
        sta channel_volume_slide_accumulator, x
        ; the low nybble should be subtracted from the same accumulator
        lda channel_volume_slide_settings, x
        and #$0F
        sta scratch_byte
        lda channel_volume_slide_accumulator, x
        sec
        sbc scratch_byte
        ; at this stage the high 5 bits describe our desired change to channel_volume
        sta scratch_byte
        ; mask the change off and keep the low 3 bits for future accumulation
        and #%00000111
        sta channel_volume_slide_accumulator, x
        ; ASR 3 times
        lda scratch_byte
        .repeat 3
        cmp #$80
        ror
        .endrep
        ; A now contains the desired change to channel_volume
        clc
        adc channel_volume, x
        ; if channel volume is now negative, set it to 0
        bmi zero_volume
        ; if it now exceeds 15, cap it there
        cmp #15
        bcs cap_volume
        ; store this volume and bail
        sta channel_volume, x
        rts
cap_volume:
        lda #15
        sta channel_volume, x
        rts
zero_volume:
        lda #0
        sta channel_volume, x
done:
        rts
.endproc
