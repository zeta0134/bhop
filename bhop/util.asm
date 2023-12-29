; utility functions to aid in setting initial pitch
; All three accept MIDI index in A, and channel index in X
; All three will clobber Y, and differ only in their output
; The channel index (X) determines which pitch table is used

.proc set_channel_base_frequency
    tay
    
    ; TODO: other channel pitch table logic here

ntsc_2a03:
    lda ntsc_period_low, y
    sta channel_base_frequency_low, x
    lda ntsc_period_high, y
    sta channel_base_frequency_high, x
    rts
.endproc

.proc set_channel_relative_frequency
    tay
    
    ; TODO: other channel pitch table logic here

ntsc_2a03:
    lda ntsc_period_low, y
    sta channel_relative_frequency_low, x
    lda ntsc_period_high, y
    sta channel_relative_frequency_high, x
    rts
.endproc

.proc set_scratch_target_frequency
    tay
    
    ; TODO: other channel pitch table logic here

ntsc_2a03:
    lda ntsc_period_low, y
    sta scratch_target_frequency
    lda ntsc_period_high, y
    sta scratch_target_frequency+1
    rts
.endproc