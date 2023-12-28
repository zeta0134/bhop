; note that "zsaw.asm" is the upstream library. This file contains alternate routines and behaviors
; that are entirely specific to bhop, for driving that library.

; These are used to more or less match N163 volumes in Dn-FamiTracker,
; which helps to keep the mix as close as possible between the tracker
; and the in-engine result.
zsaw_n163_equivalence_table:
zsaw_00_volume_table:
.byte   0,   3,   5,   8
.byte  11,  13,  16,  19
.byte  22,  25,  28,  31
.byte  34,  38,  41,  44
zsaw_7F_volume_table:
.byte 127, 122, 116, 111
.byte 106, 101,  96,  92
.byte  87,  83,  79,  74
.byte  70,  66,  62,  59

; a variant without all the shifting and masking business
.proc tick_duty_envelope_zsaw
        ldy channel_index
        lda sequences_active, y
        and #SEQUENCE_DUTY
        beq done ; if sequence isn't enabled, bail fast

        ; prepare the duty pointer for reading
        lda duty_sequence_ptr_low, y
        sta bhop_ptr
        lda duty_sequence_ptr_high, y
        sta bhop_ptr + 1

        ; read the current sequence byte, and set instrument_volume to this
        lda duty_sequence_index, y
        tax ; stash for later
        ; for reading the sequence, +4
        clc
        adc #4
        tay
        lda (bhop_ptr), y
        ldy channel_index
        sta channel_instrument_duty, y

        ; tick the sequence counter and exit
        jsr tick_sequence_counter

        ; have we reached the end of the sequence?
        ldy #SequenceHeader::length
        lda (bhop_ptr), y
        sta scratch_byte
        cpx scratch_byte
        bne end_not_reached

        ; this sequence is finished! Disable the sequence flag and exit
        ldy channel_index
        lda sequences_active, y
        and #($FF - SEQUENCE_DUTY)
        sta sequences_active, y
        rts

end_not_reached:
        ; write the new sequence index (should still be in x)
        ldy channel_index
        txa
        sta duty_sequence_index, y

done:
        rts
.endproc

; and yet another variant for Z-Saw, which simply copies the base note into the
; relative frequency byte (which is then played back directly)
.proc tick_arp_envelope_zsaw
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

        ; apply the current base note as the channel frequency,
        ; then exit:
        lda channel_base_note, x
        sta zsaw_relative_note
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
        ; were we just triggered? if so, reset the relative offset
        lda channel_status, x
        and #CHANNEL_TRIGGERED
        beq not_triggered
        lda #0
        sta channel_relative_note_offset, x
not_triggered:
        ; arp accumulates an offset each frame, from the previous frame
        lda channel_relative_note_offset, x
        clc
        adc scratch_byte
        sta channel_relative_note_offset, x
        ; this offset is then applied to base_note
        lda channel_base_note, x
        clc
        adc channel_relative_note_offset, x
        ; stuff that result in y, and apply it
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
        sty zsaw_relative_note

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

.proc play_zsaw
        ; Safety: if Z-Saw is disabled, DO NOTHING.
        lda dpcm_status
        and #DPCM_ZSAW_ENABLED
        bne safe_to_continue
        rts

safe_to_continue:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + ZSAW_INDEX
        bne skip
        bmi zsaw_muted

        lda channel_instrument_duty + ZSAW_INDEX
        and #%00000111
        jsr zsaw_set_timbre

        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + ZSAW_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + ZSAW_INDEX
        tax
        lda volume_table, x
        beq zsaw_muted

        ; New approach: use the tracked volume to index into our N163 equivalence lookup table
        ; First we need to pick which table, so do that based on the timbre
        sta scratch_byte
        lda channel_instrument_duty + ZSAW_INDEX
        and #%00000001
        asl
        asl
        asl
        asl
        ora scratch_byte
        tax
        lda zsaw_n163_equivalence_table, x
        jsr zsaw_set_volume

        ; Z-Saw will use the tracked note directly
        ; TODO: or, for arps, maybe we copy tracked note to one of the "pitch" variables?
        lda zsaw_relative_note
        jsr zsaw_play_note
        rts

zsaw_muted:
        jsr zsaw_silence

skip:
        ; Do not pass go. Do not collect $200
        rts
.endproc