.include "bhop.inc"
.include "bhop_internal.inc"

.scope BHOP

        .segment "RAM"
channel_vibrato_settings: .res ::NUM_CHANNELS
channel_vibrato_accumulator: .res ::NUM_CHANNELS
channel_tuning: .res ::NUM_CHANNELS
channel_arpeggio_settings: .res ::NUM_CHANNELS
channel_arpeggio_counter: .res ::NUM_CHANNELS
.export channel_vibrato_settings, channel_vibrato_accumulator, channel_tuning, channel_arpeggio_settings, channel_arpeggio_counter

        .segment "PRG_8000"
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
.export update_vibrato

.proc update_tuning
        ldx channel_index
        lda channel_tuning, x
        sta scratch_byte
        sadd16_split_x channel_detuned_frequency_low, channel_detuned_frequency_high, scratch_byte
        rts
.endproc
.export update_tuning

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
.export update_arp

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
.export update_pitch_effects

; 1xx: unconditional slide upwards; amount in xx
.proc update_pitch_slide_up
        ; unimplemented
        rts
.endproc

; 2xx: unconditional slide downwards; amount in xx
.proc update_pitch_slide_down
        ; unimplemented
        rts
.endproc

; 3xx: automatic portamento, speed in xx
; prep: base_note, set by the tracked row, is the relative target
; note: does not disable itself automatically (that's the "automatic" part)
.proc update_portamento
        ; unimplemented
        rts
.endproc

; Qxy: targeted note slide upwards; semitones in x, speed in y
; prep: original note in base_note
; when the target note is reached, the effect becomes disabled
.proc update_pitch_note_slide_up
        ; unimplemented
        rts
.endproc

; Rxy: targeted note slide downwards; semitones in x, speed in y
; prep: original note in base_note
; when the target note is reached, the effect becomes disabled
.proc update_pitch_note_slide_down
        ; unimplemented
        rts
.endproc

.endscope