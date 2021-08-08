.include "bhop.inc"
.include "bhop_internal.inc"
.include "commands.inc"
.include "nes.inc"
.include "word_util.inc"

.scope BHOP

        .segment "RAM"
channel_vibrato_settings: .res ::NUM_CHANNELS
channel_vibrato_accumulator: .res ::NUM_CHANNELS
channel_tuning: .res ::NUM_CHANNELS
.export channel_vibrato_settings, channel_vibrato_accumulator, channel_tuning

        .segment "PRG0_8000"
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
        
.endscope