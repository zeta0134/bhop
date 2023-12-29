; TODO: roll these into the frequency setting functions?
; also not having done this consistently might explain
; why noise arps were being weird...
.proc fix_noise_freq
        lda channel_status + NOISE_INDEX
        and #CHANNEL_TRIGGERED
        beq done
        lda channel_base_note + NOISE_INDEX
        sta channel_base_frequency_low + NOISE_INDEX
        sta channel_relative_frequency_low + NOISE_INDEX
done:
        rts
.endproc

; We need a special variant of this just for noise, which uses a different
; means of frequency to base_note mapping
; setup:
;   channel_index points to channel structure
; TODO: do we really need to duplicate the entire arp structure here? noise isn't
; the only channel that will need special treatment, but it's a tiny bit of this
; code that changes and the rest is hard to keep in sync...
.proc tick_noise_arp_envelope
        ldx channel_index
        lda sequences_active, x
        and #SEQUENCE_ARP
        beq early_exit ; if sequence isn't enabled, bail fast

        ; prepare the arp pointer for reading
        lda arpeggio_sequence_ptr_low, x
        sta bhop_ptr
        lda arpeggio_sequence_ptr_high, x
        sta bhop_ptr + 1

        ; For fixed arps, we need to "reset" the channel if the envelope finishes, so we're doing
        ; the length check first thing

        lda arpeggio_sequence_index, x
        sta scratch_byte
        ; have we reached the end of the sequence?
        ldy #SequenceHeader::length
        lda (bhop_ptr), y
        cmp scratch_byte
        bne end_not_reached

        ; this sequence is finished! Disable the sequence flag
        lda sequences_active, x
        and #($FF - SEQUENCE_ARP)
        sta sequences_active, x

        ; is this a fixed arp?
        ldy #SequenceHeader::mode
        lda (bhop_ptr), y
        cmp #ARP_MODE_FIXED
        bne early_exit

        ; now apply the current base note as the channel frequency,
        ; then exit:
        lda channel_base_note, x
        sta channel_relative_frequency_low, x
early_exit:
        rts

end_not_reached:
        ; read the current sequence byte, and set instrument_volume to this
        lda arpeggio_sequence_index, x
        pha ; stash for later
        ; for reading the sequence, +4
        clc
        adc #4
        tay
        lda (bhop_ptr), y
        sta scratch_byte ; will affect the note, depending on mode
        clc

        ; what we actually *do* with the arp byte depends on the mode
        ldy #SequenceHeader::mode
        lda (bhop_ptr), y
        cmp #ARP_MODE_ABSOLUTE
        beq arp_absolute
        cmp #ARP_MODE_RELATIVE
        beq arp_relative
        cmp #ARP_MODE_FIXED
        beq arp_fixed
        ; ARP SCHEME, unimplemented! for now, treat this just like absolute
arp_absolute:
        ; arp is an offset from base note to apply each frame
        lda channel_base_note, x
        clc
        adc scratch_byte
        tay
        jmp apply_arp
arp_relative:
        ; arp accumulates an offset each frame, from the previous frame
        lda channel_base_note, x
        clc
        adc scratch_byte
        sta channel_base_note, x
        tay
        jmp apply_arp
arp_fixed:
        ; the arp value +1 is the note to apply
        lda scratch_byte
        clc
        adc #1
        tay
        ; fall through to apply_arp
apply_arp:
        tya ; for noise, we'll use the value directly
        sta channel_relative_frequency_low, x

done_applying_arp:
        pla ; unstash the sequence counter
        tax ; move into x, which tick_sequence_counter expects

        ; tick the sequence counter and exit
        jsr tick_sequence_counter

        ; write the new sequence index (should still be in x)
        ldy channel_index
        txa
        sta arpeggio_sequence_index, y

done:
        rts
.endproc