.include "bhop.inc"
.include "bhop_internal.inc"
.include "commands.inc"
.include "nes.inc"
.include "word_util.inc"

.scope BHOP

        .zeropage
scratch_byte: .byte $00

        .segment "RAM"
vibrato_settings: .res ::NUM_CHANNELS
vibrato_accumulator: .res ::NUM_CHANNELS

        .segment "PRG0_8000"
.include "vibrato_lut.inc"

; Vibrato LUT: there are 16 tables, each containing the first 1/4 of a sine
; wave at the desired depth. This function takes care of duplicating that
; table reversed / inverted, as appropriate, to generate the other 3 sections
; and complete the full waveform.

; prep: 
;   channel_index set for the desired channel
; return:
;   a - vibrato strength, signed
; clobbers: x, y, scratch_byte
.proc read_vibrato_lut
        ldx channel_index
        ; note: we can't use BIT here, it has inconvenient addressing modes
        ; fortunately it's ideal for A to end up mostly cleared
        lda #%00010000
        and vibrato_accumulator, x
        bne reverse_lut
normal_lut:
        lda #$0F
        and vibrato_accumulator, x
        jmp store_index
reverse_lut:
        ; A already contains 0000 in its low bits, which
        ; works fine in this case
        sec
        sbc vibrato_accumulator, x
        and #$0F ; mask off the upper bits
store_index:
        sta scratch_byte
        lda vibrato_settings, x
        and #$F0
        ora scratch_byte
        tay
        ; now we check to see if we'll need to invert this read
        lda #%00100000
        and vibrato_accumulator, x
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
        
.endscope