.include "zsaw.inc"

.import ZSAW_NMI_GAME_HANDLER

.segment ZSAW_ZP_SEGMENT

table_entry: .res 1
table_pos: .res 1

zsaw_ptr: .res 2
zsaw_pos: .res 1
zsaw_volume: .res 1
zsaw_count: .res 1
zsaw_parity_counter: .res 1
zsaw_timbre_index: .res 1
zsaw_timbre_ptr: .res 2
zsaw_current_note: .res 1
zsaw_current_timbre: .res 1

irq_enabled: .res 1
irq_active: .res 1
zsaw_nmi_pending: .res 1
zsaw_oam_pending: .res 1

.segment ZSAW_SAMPLES_SEGMENT

; Note: these sample entries are somewhat wasteful!
; Not entirely certain how we can fix this in a sane manner

.align 64
all_00_byte: .byte $00

.align 64
all_FF_byte: .byte $FF

.align 64
all_55_byte: .byte $55

.segment ZSAW_FIXED_SEGMENT

.proc zsaw_init
        lda #0
        sta irq_enabled
        sta irq_active
        sta zsaw_oam_pending
        sta zsaw_nmi_pending
        sta zsaw_parity_counter

        lda #0
        sta zsaw_timbre_index

        ; mostly unnecessary, but just for safety, initialize this
        ; to the first index. On the off chance the IRQ gets called somehow
        ; before a note plays normally, this will prevent a crash
        lda timbre_behavior_lut+0
        sta zsaw_timbre_ptr+0
        lda timbre_behavior_lut+1
        sta zsaw_timbre_ptr+1

        rts
.endproc

; desired timbre in A
; note: will not take effect until next play_note command
.proc zsaw_set_timbre
        sta zsaw_timbre_index        
        rts
.endproc

; desired volume in A, clobbers X
; note: certain timbres invert the effect of volume, so
; we need to vary the actual volume we use based on that
; for music engine authors, the order should always be:
; - timbre
; - volume
; - play new note
; when changing timbre, always remember to restart the note
.proc zsaw_set_volume
        sta zsaw_volume
        ldx zsaw_timbre_index
        cpx #1
        beq inverted
        cpx #3
        beq inverted
        rts
inverted: 
        lda #$7F
        sec
        sbc zsaw_volume
        sta zsaw_volume
        rts
.endproc

timbre_behavior_lut:
        .addr timbre_sawtooth
        .addr timbre_sawtooth
        .addr timbre_square_00
        .addr timbre_square_7F
        .addr timbre_triangle
        .addr timbre_triangle ; note: we mask to 8 timbres, so the extra entries are mostly for safety
        .addr timbre_triangle
        .addr timbre_triangle
        

timbre_sample_lut:
        .byte <((all_00_byte - $C000) >> 6) ; sawtooth, floor
        .byte <((all_FF_byte - $C000) >> 6) ; sawtooth, ceiling
        .byte <((all_55_byte - $C000) >> 6) ; square, floor
        .byte <((all_55_byte - $C000) >> 6) ; square, ceiling
        .byte <((all_FF_byte - $C000) >> 6) ; triangle, starts ceiling and alternates
        .byte <((all_FF_byte - $C000) >> 6) ; triangle again
        .byte <((all_FF_byte - $C000) >> 6) ; triangle again
        .byte <((all_FF_byte - $C000) >> 6) ; triangle again

; note index in A, clobbers X
; assumes interrupts are already enabled
.proc zsaw_play_note
        ; sanity check: is this note index in bounds?
        cmp #ZSAW_MINIMUM_INDEX
        bcc bad_note_index
        cmp #(ZSAW_MAXIMUM_INDEX+1)
        bcs bad_note_index
        ; only queue up a new note if either the timbre
        ; or the note index is different from what's currently playing
        ; otherwise we reset the phase for no good reason, and this tends
        ; to annoy music engines
        ldx zsaw_timbre_index
        cpx zsaw_current_timbre
        bne play_note
        cmp zsaw_current_note
        bne play_note
        rts
bad_note_index:
        jsr zsaw_silence
        rts
play_note:
        sta zsaw_current_note
        stx zsaw_current_timbre 
        asl ; note index to word index for the table lookup
        tax

        sei ; briefly disable interrupts, for pointer safety
        lda zsaw_note_lists+0, x 
        sta zsaw_ptr+0
        lda zsaw_note_lists+1, x 
        sta zsaw_ptr+1
        lda #0
        sta zsaw_pos
        lda #1
        sta zsaw_count

standard_timbre:
        ; here also set the timbre pointer, using the LUT
        lda zsaw_timbre_index
        and #%00000111
        asl
        tax
        lda timbre_behavior_lut+0, x
        sta zsaw_timbre_ptr+0
        lda timbre_behavior_lut+1, x
        sta zsaw_timbre_ptr+1

        ; reset the parity counter (keeps square and triangle slightly more consistent)
        lda #0
        sta zsaw_parity_counter

        ; set up the sample address and size
        ldx zsaw_timbre_index
        lda timbre_sample_lut, x

        sta $4012
        lda #0
        sta $4013

        ; Now, if we were newly triggered, start the sample playback from scratch
        lda irq_enabled
        bne done ; Do not pass go. Do not collect $200

        ; start it up (the IRQ will take over future starts after this)
        lda #$8F
        sta $4010
        lda #$1F
        sta $4015

        ; tell the NMI handler that interrupts are active
        lda #$FF
        sta irq_enabled 
done:
        cli ; enable interrupts
        rts
.endproc

.proc zsaw_silence
        ; halt playback
        lda #$0F
        sta $4015 ; acknowledges DMC interrupt, if one is active
        ; disable DMC interrupts
        lda #0
        sta $4010

        ; Tell the NMI handler that interrupts are no longer active
        ; (It'll need to do its own OAM DMA)
        lda #$00
        sta irq_enabled

        ; Just for safety, clear any delayed OAM / NMI flags, so they
        ; aren't (accidentally) triggered the next time playback begins
        lda #0
        sta zsaw_nmi_pending
        sta zsaw_oam_pending

        lda #$FF
        sta zsaw_current_note

        rts
.endproc

.proc zsaw_irq
        dec irq_active ; (5) signal to NMI that the IRQ routine is in progress
        pha ; (3) save A and Y
        tya ; (2)
        pha ; (3)
        ; decrement the RLE counter
        dec zsaw_count ; (5)
        ; if this is still positive, simply continue playing the last sample
        bne restart_dmc ; (2) (3t)
        ; otherwise it's time to load the next entry
        ldy zsaw_pos ; (3)
        lda (zsaw_ptr), y ; (5)
        bne load_next_entry ; (2) (3t)
        ; if the count is zero, it's time to reset the entire sequence

        ; reset the postion counter to the beginning
        ldy #0 ; (2)
        lda (zsaw_ptr), y ; (5)
load_first_entry:
        sta zsaw_count ; (3)
        iny ; (2)
        lda (zsaw_ptr), y ; (5)
        ora #$80 ; (2) set the interrupt flag
        sta $4010 ; (4) set the period + interrupt for this sample
        iny ; (2)
        sty zsaw_pos ; (3)

        ; Now work out the new volume to write to the PCM level; the behavior
        ; varies somewhat for sawtooth and square
        jmp (zsaw_timbre_ptr) ; will jump to one of the following blocks

load_next_entry:
        ; Just like loading the first entry, without a sequence reset
        sta zsaw_count ; (3)
        iny ; (2)
        lda (zsaw_ptr), y ; (5)
        ora #$80 ; (2) set the interrupt flag
        sta $4010 ; (4) set the period + interrupt for this sample
        iny ; (2)
        sty zsaw_pos ; (3)
        jmp restart_dmc
.endproc

.proc restart_dmc
        lda #$1F ; (2)
        sta $4015 ; (4)
        ; Now for housekeeping.
        ; First, if NMI asked us to perform OAM DMA, do that here
        bit zsaw_oam_pending
        bpl no_oam_needed
        lda #$00
        sta $2003 ; OAM ADDR
        lda #ZSAW_SHADOW_OAM
        sta $4014 ; OAM DMA
        inc zsaw_oam_pending
no_oam_needed:
        ; At this point it is safe for NMI interrupt the IRQ routine
        inc irq_active
        ; If we need to perform a manual NMI, do that now
        bit zsaw_nmi_pending
        bpl no_nmi_needed
        inc zsaw_nmi_pending
        jsr zsaw_manual_nmi ; this should preserve all registers, including X
no_nmi_needed:
        pla ; (4) restore A and Y
        tay ; (2)
        pla ; (4)
        rti
.endproc

.proc timbre_square_00
        ; For square waves, we alternate between the set volume and
        ; a fixed baseline, $00 in this case
        lda #$80                  ; (2)
        eor zsaw_parity_counter ; (3)
        sta zsaw_parity_counter ; (3)
        bmi odd_phase           
even_phase:
        lda zsaw_volume ; (3)
        jmp done_picking_phase ; (3)
odd_phase:
        lda #0 ; (2)
done_picking_phase:
        sta $4011 ; (4)
        jmp restart_dmc
.endproc

.proc timbre_square_7F
        ; For square waves, we alternate between the set volume and
        ; a fixed baseline, $7F in this case
        lda #$80                  ; (2)
        eor zsaw_parity_counter ; (3)
        sta zsaw_parity_counter ; (3)
        bmi odd_phase           
even_phase:
        lda zsaw_volume ; (3)
        jmp done_picking_phase ; (3)
odd_phase:
        lda #$7F ; (2)
done_picking_phase:
        sta $4011 ; (4)
        jmp restart_dmc
.endproc

.proc timbre_sawtooth
        ; For sawtooth we always write the current volume
        ; (the direction is controlled by which sample is playing)
        lda zsaw_volume ; (3)
        sta $4011 ; (4)
        jmp restart_dmc
.endproc

.proc timbre_triangle
        ; For triangle rather than alter the volume, we alter the direction
        lda #$80                  ; (2)
        eor zsaw_parity_counter ; (3)
        sta zsaw_parity_counter ; (3)
        bmi odd_phase           
even_phase:
        lda #<((all_FF_byte - $C000) >> 6)
        jmp done_picking_phase ; (3)
odd_phase:
        lda #<((all_00_byte - $C000) >> 6)
done_picking_phase:
        sta $4012 ; (4)
        jmp restart_dmc
.endproc

.proc zsaw_nmi
        ; penalty and jitter: 14 cycles
        bit irq_active ; (3)
        bpl safe_to_run_nmi ; (2, 3t)
        dec zsaw_nmi_pending ; (5)
        rti ; (6) exit immediately; IRQ will continue and call NMI when it is done
safe_to_run_nmi:
        jsr zsaw_manual_nmi
        rti
.endproc

.proc zsaw_manual_nmi
        ; preserve registers
        pha
        txa
        pha
        tya
        pha

        bit irq_enabled
        bpl perform_oam_dma
        dec zsaw_oam_pending ; Perform OAM DMA during the IRQ routine
        ; allow interrupts during nmi as early as possible
        cli
        jmp done_with_oam
perform_oam_dma:
        ; do the sprite thing
        lda #$00
        sta $2003
        lda #$02
        sta $4014
done_with_oam:
        jsr ZSAW_NMI_GAME_HANDLER

        ; restore registers
        pla
        tay
        pla
        tax
        pla
        rts
.endproc

zsaw_note_lists:
  .word zsaw_note_period_23
  .word zsaw_note_period_24
  .word zsaw_note_period_25
  .word zsaw_note_period_26
  .word zsaw_note_period_27
  .word zsaw_note_period_28
  .word zsaw_note_period_29
  .word zsaw_note_period_30
  .word zsaw_note_period_31
  .word zsaw_note_period_32
  .word zsaw_note_period_33
  .word zsaw_note_period_34
  .word zsaw_note_period_35
  .word zsaw_note_period_36
  .word zsaw_note_period_37
  .word zsaw_note_period_38
  .word zsaw_note_period_39
  .word zsaw_note_period_40
  .word zsaw_note_period_41
  .word zsaw_note_period_42
  .word zsaw_note_period_43
  .word zsaw_note_period_44
  .word zsaw_note_period_45
  .word zsaw_note_period_46
  .word zsaw_note_period_47
  .word zsaw_note_period_48
  .word zsaw_note_period_49
  .word zsaw_note_period_50
  .word zsaw_note_period_51
  .word zsaw_note_period_52
  .word zsaw_note_period_53
  .word zsaw_note_period_54
  .word zsaw_note_period_55
  .word zsaw_note_period_56
  .word zsaw_note_period_57
  .word zsaw_note_period_58
  .word zsaw_note_period_59
  .word zsaw_note_period_60
  .word zsaw_note_period_61
  .word zsaw_note_period_62
  .word zsaw_note_period_63
  .word zsaw_note_period_64
  .word zsaw_note_period_65
  .word zsaw_note_period_66
  .word zsaw_note_period_67
  .word zsaw_note_period_68
  .word zsaw_note_period_69
  .word zsaw_note_period_70
  .word zsaw_note_period_71
  .word zsaw_note_period_72
  .word zsaw_note_period_73
  .word zsaw_note_period_74
  .word zsaw_note_period_75
  .word zsaw_note_period_76
  .word zsaw_note_period_77
  .word zsaw_note_period_78
  .word zsaw_note_period_79
  .word zsaw_note_period_80
  .word zsaw_note_period_81
  .word zsaw_note_period_82
  .word zsaw_note_period_83
  .word zsaw_note_period_84
  .word zsaw_note_period_85
  .word zsaw_note_period_86
  .word zsaw_note_period_87
  .word zsaw_note_period_88
  .word zsaw_note_period_89
  .word zsaw_note_period_90
  .word zsaw_note_period_91
  .word zsaw_note_period_92
  .word zsaw_note_period_93
  .word zsaw_note_period_94
  .word zsaw_note_period_95
  .word zsaw_note_period_96

zsaw_note_period_23:
; Note: B1, Target Frequency: 30.87, Actual Frequency: 30.87, Tuning Error: 0.00
  .byte $1d, $08, $02, $09, $03, $0a, $03, $0b
  .byte $02, $0c, $03, $0d, $02, $0e, $00
zsaw_note_period_24:
; Note: C2, Target Frequency: 32.70, Actual Frequency: 32.71, Tuning Error: 0.00
  .byte $24, $08, $00
zsaw_note_period_25:
; Note: Cs2, Target Frequency: 34.65, Actual Frequency: 34.64, Tuning Error: 0.01
  .byte $18, $08, $03, $09, $03, $0a, $03, $0b
  .byte $02, $0c, $03, $0d, $02, $0e, $00
zsaw_note_period_26:
; Note: D2, Target Frequency: 36.71, Actual Frequency: 36.71, Tuning Error: 0.00
  .byte $1e, $08, $01, $09, $01, $0b, $01, $0c
  .byte $00
zsaw_note_period_27:
; Note: Ds2, Target Frequency: 38.89, Actual Frequency: 38.89, Tuning Error: 0.00
  .byte $1c, $08, $01, $09, $01, $0b, $02, $0e
  .byte $00
zsaw_note_period_28:
; Note: E2, Target Frequency: 41.20, Actual Frequency: 41.20, Tuning Error: 0.00
  .byte $13, $08, $03, $09, $03, $0a, $01, $0b
  .byte $03, $0c, $03, $0d, $03, $0e, $00
zsaw_note_period_29:
; Note: F2, Target Frequency: 43.65, Actual Frequency: 43.66, Tuning Error: 0.01
  .byte $19, $08, $01, $09, $01, $0a, $01, $0e
  .byte $00
zsaw_note_period_30:
; Note: Fs2, Target Frequency: 46.25, Actual Frequency: 46.24, Tuning Error: 0.01
  .byte $11, $08, $03, $09, $03, $0a, $03, $0c
  .byte $02, $0d, $03, $0e, $00
zsaw_note_period_31:
; Note: G2, Target Frequency: 49.00, Actual Frequency: 49.00, Tuning Error: 0.00
  .byte $0f, $08, $02, $09, $03, $0a, $02, $0b
  .byte $03, $0c, $03, $0d, $02, $0e, $00
zsaw_note_period_32:
; Note: Gs2, Target Frequency: 51.91, Actual Frequency: 51.91, Tuning Error: 0.01
  .byte $0e, $08, $01, $09, $03, $0a, $03, $0b
  .byte $02, $0c, $03, $0d, $03, $0e, $00
zsaw_note_period_33:
; Note: A2, Target Frequency: 55.00, Actual Frequency: 55.00, Tuning Error: 0.00
  .byte $0c, $08, $02, $09, $03, $0a, $02, $0b
  .byte $03, $0c, $03, $0d, $03, $0e, $00
zsaw_note_period_34:
; Note: As2, Target Frequency: 58.27, Actual Frequency: 58.26, Tuning Error: 0.01
  .byte $0c, $08, $02, $09, $01, $0a, $03, $0b
  .byte $03, $0c, $03, $0d, $02, $0e, $00
zsaw_note_period_35:
; Note: B2, Target Frequency: 61.74, Actual Frequency: 61.73, Tuning Error: 0.00
  .byte $0b, $08, $02, $09, $02, $0a, $03, $0b
  .byte $03, $0c, $01, $0d, $02, $0e, $00
zsaw_note_period_36:
; Note: C3, Target Frequency: 65.41, Actual Frequency: 65.42, Tuning Error: 0.01
  .byte $12, $08, $00
zsaw_note_period_37:
; Note: Cs3, Target Frequency: 69.30, Actual Frequency: 69.31, Tuning Error: 0.01
  .byte $0f, $08, $01, $0b, $01, $0c, $02, $0e
  .byte $00
zsaw_note_period_38:
; Note: D3, Target Frequency: 73.42, Actual Frequency: 73.40, Tuning Error: 0.02
  .byte $06, $08, $03, $09, $03, $0a, $03, $0b
  .byte $03, $0c, $01, $0d, $03, $0e, $00
zsaw_note_period_39:
; Note: Ds3, Target Frequency: 77.78, Actual Frequency: 77.79, Tuning Error: 0.01
  .byte $0e, $08, $03, $0e, $00
zsaw_note_period_40:
; Note: E3, Target Frequency: 82.41, Actual Frequency: 82.43, Tuning Error: 0.03
  .byte $0d, $08, $01, $09, $01, $0d, $00
zsaw_note_period_41:
; Note: F3, Target Frequency: 87.31, Actual Frequency: 87.32, Tuning Error: 0.02
  .byte $0b, $08, $01, $09, $02, $0d, $02, $0e
  .byte $00
zsaw_note_period_42:
; Note: Fs3, Target Frequency: 92.50, Actual Frequency: 92.52, Tuning Error: 0.02
  .byte $0b, $08, $01, $09, $02, $0d, $00
zsaw_note_period_43:
; Note: G3, Target Frequency: 98.00, Actual Frequency: 98.04, Tuning Error: 0.04
  .byte $0a, $08, $01, $0a, $02, $0d, $01, $0e
  .byte $00
zsaw_note_period_44:
; Note: Gs3, Target Frequency: 103.83, Actual Frequency: 103.86, Tuning Error: 0.04
  .byte $09, $08, $01, $09, $02, $0a, $00
zsaw_note_period_45:
; Note: A3, Target Frequency: 110.00, Actual Frequency: 109.99, Tuning Error: 0.01
  .byte $01, $08, $02, $09, $03, $0a, $03, $0b
  .byte $03, $0c, $03, $0d, $02, $0e, $00
zsaw_note_period_46:
; Note: As3, Target Frequency: 116.54, Actual Frequency: 116.52, Tuning Error: 0.02
  .byte $03, $09, $03, $0a, $03, $0b, $03, $0c
  .byte $02, $0d, $02, $0e, $00
zsaw_note_period_47:
; Note: B3, Target Frequency: 123.47, Actual Frequency: 123.47, Tuning Error: 0.00
  .byte $01, $08, $03, $09, $02, $0a, $03, $0b
  .byte $03, $0c, $01, $0d, $01, $0e, $00
zsaw_note_period_48:
; Note: C4, Target Frequency: 130.81, Actual Frequency: 130.83, Tuning Error: 0.02
  .byte $09, $08, $00
zsaw_note_period_49:
; Note: Cs4, Target Frequency: 138.59, Actual Frequency: 138.61, Tuning Error: 0.02
  .byte $07, $08, $02, $0a, $00
zsaw_note_period_50:
; Note: D4, Target Frequency: 146.83, Actual Frequency: 146.80, Tuning Error: 0.03
  .byte $03, $0a, $03, $0b, $03, $0c, $03, $0d
  .byte $02, $0e, $00
zsaw_note_period_51:
; Note: Ds4, Target Frequency: 155.56, Actual Frequency: 155.58, Tuning Error: 0.01
  .byte $06, $08, $01, $0a, $01, $0d, $01, $0e
  .byte $00
zsaw_note_period_52:
; Note: E4, Target Frequency: 164.81, Actual Frequency: 164.74, Tuning Error: 0.07
  .byte $01, $09, $02, $0a, $01, $0b, $03, $0c
  .byte $03, $0d, $03, $0e, $00
zsaw_note_period_53:
; Note: F4, Target Frequency: 174.61, Actual Frequency: 174.51, Tuning Error: 0.10
  .byte $01, $09, $01, $0a, $03, $0b, $02, $0c
  .byte $02, $0d, $03, $0e, $00
zsaw_note_period_54:
; Note: Fs4, Target Frequency: 185.00, Actual Frequency: 184.89, Tuning Error: 0.10
  .byte $01, $09, $01, $0a, $03, $0b, $02, $0c
  .byte $02, $0d, $02, $0e, $00
zsaw_note_period_55:
; Note: G4, Target Frequency: 196.00, Actual Frequency: 195.90, Tuning Error: 0.09
  .byte $02, $0a, $03, $0b, $03, $0c, $01, $0d
  .byte $01, $0e, $00
zsaw_note_period_56:
; Note: Gs4, Target Frequency: 207.65, Actual Frequency: 207.53, Tuning Error: 0.12
  .byte $01, $0a, $02, $0b, $02, $0c, $03, $0d
  .byte $03, $0e, $00
zsaw_note_period_57:
; Note: A4, Target Frequency: 220.00, Actual Frequency: 220.20, Tuning Error: 0.20
  .byte $04, $08, $02, $0b, $00
zsaw_note_period_58:
; Note: As4, Target Frequency: 233.08, Actual Frequency: 233.04, Tuning Error: 0.04
  .byte $03, $0a, $03, $0c, $03, $0e, $00
zsaw_note_period_59:
; Note: B4, Target Frequency: 246.94, Actual Frequency: 246.93, Tuning Error: 0.01
  .byte $01, $0a, $03, $0b, $02, $0c, $02, $0d
  .byte $00
zsaw_note_period_60:
; Note: C5, Target Frequency: 261.63, Actual Frequency: 261.36, Tuning Error: 0.27
  .byte $01, $0a, $03, $0c, $03, $0d, $02, $0e
  .byte $00
zsaw_note_period_61:
; Note: Cs5, Target Frequency: 277.18, Actual Frequency: 276.88, Tuning Error: 0.30
  .byte $01, $0b, $02, $0c, $03, $0d, $03, $0e
  .byte $00
zsaw_note_period_62:
; Note: D5, Target Frequency: 293.66, Actual Frequency: 293.60, Tuning Error: 0.07
  .byte $01, $09, $01, $0b, $03, $0c, $01, $0d
  .byte $01, $0e, $00
zsaw_note_period_63:
; Note: Ds5, Target Frequency: 311.13, Actual Frequency: 310.72, Tuning Error: 0.40
  .byte $02, $0b, $02, $0c, $03, $0d, $00
zsaw_note_period_64:
; Note: E5, Target Frequency: 329.63, Actual Frequency: 329.97, Tuning Error: 0.35
  .byte $02, $08, $01, $0a, $01, $0d, $01, $0e
  .byte $00
zsaw_note_period_65:
; Note: F5, Target Frequency: 349.23, Actual Frequency: 349.57, Tuning Error: 0.34
  .byte $01, $08, $01, $0b, $01, $0c, $03, $0e
  .byte $00
zsaw_note_period_66:
; Note: Fs5, Target Frequency: 369.99, Actual Frequency: 370.40, Tuning Error: 0.41
  .byte $01, $08, $01, $0a, $01, $0b, $02, $0e
  .byte $00
zsaw_note_period_67:
; Note: G5, Target Frequency: 392.00, Actual Frequency: 392.49, Tuning Error: 0.50
  .byte $03, $08, $00
zsaw_note_period_68:
; Note: Gs5, Target Frequency: 415.30, Actual Frequency: 415.84, Tuning Error: 0.53
  .byte $01, $09, $01, $0b, $01, $0c, $02, $0e
  .byte $00
zsaw_note_period_69:
; Note: A5, Target Frequency: 440.00, Actual Frequency: 440.40, Tuning Error: 0.40
  .byte $02, $08, $01, $0b, $00
zsaw_note_period_70:
; Note: As5, Target Frequency: 466.16, Actual Frequency: 466.09, Tuning Error: 0.08
  .byte $01, $09, $01, $0a, $01, $0c, $01, $0e
  .byte $00
zsaw_note_period_71:
; Note: B5, Target Frequency: 493.88, Actual Frequency: 494.96, Tuning Error: 1.08
  .byte $02, $08, $01, $0e, $00
zsaw_note_period_72:
; Note: C6, Target Frequency: 523.25, Actual Frequency: 522.71, Tuning Error: 0.54
  .byte $02, $0c, $03, $0e, $00
zsaw_note_period_73:
; Note: Cs6, Target Frequency: 554.37, Actual Frequency: 553.77, Tuning Error: 0.60
  .byte $01, $0a, $01, $0c, $01, $0d, $01, $0e
  .byte $00
zsaw_note_period_74:
; Note: D6, Target Frequency: 587.33, Actual Frequency: 588.74, Tuning Error: 1.41
  .byte $02, $08, $00
zsaw_note_period_75:
; Note: Ds6, Target Frequency: 622.25, Actual Frequency: 621.45, Tuning Error: 0.81
  .byte $01, $09, $01, $0b, $01, $0e, $00
zsaw_note_period_76:
; Note: E6, Target Frequency: 659.26, Actual Frequency: 658.00, Tuning Error: 1.25
  .byte $01, $0b, $02, $0c, $00
zsaw_note_period_77:
; Note: F6, Target Frequency: 698.46, Actual Frequency: 699.13, Tuning Error: 0.67
  .byte $02, $09, $00
zsaw_note_period_78:
; Note: Fs6, Target Frequency: 739.99, Actual Frequency: 740.80, Tuning Error: 0.81
  .byte $01, $09, $01, $0a, $00
zsaw_note_period_79:
; Note: G6, Target Frequency: 783.99, Actual Frequency: 782.24, Tuning Error: 1.75
  .byte $01, $0a, $02, $0e, $00
zsaw_note_period_80:
; Note: Gs6, Target Frequency: 830.61, Actual Frequency: 828.60, Tuning Error: 2.01
  .byte $01, $0a, $01, $0b, $00
zsaw_note_period_81:
; Note: A6, Target Frequency: 880.00, Actual Frequency: 873.91, Tuning Error: 6.09
  .byte $02, $0b, $00
zsaw_note_period_82:
; Note: As6, Target Frequency: 932.33, Actual Frequency: 932.17, Tuning Error: 0.15
  .byte $02, $0d, $01, $0e, $00
zsaw_note_period_83:
; Note: B6, Target Frequency: 987.77, Actual Frequency: 989.92, Tuning Error: 2.15
  .byte $01, $0a, $01, $0d, $00
zsaw_note_period_84:
; Note: C7, Target Frequency: 1046.50, Actual Frequency: 1045.43, Tuning Error: 1.07
  .byte $01, $0a, $01, $0e, $00
zsaw_note_period_85:
; Note: Cs7, Target Frequency: 1108.73, Actual Frequency: 1118.61, Tuning Error: 9.88
  .byte $01, $0b, $01, $0e, $00
zsaw_note_period_86:
; Note: D7, Target Frequency: 1174.66, Actual Frequency: 1177.48, Tuning Error: 2.82
  .byte $01, $08, $00
zsaw_note_period_87:
; Note: Ds7, Target Frequency: 1244.51, Actual Frequency: 1256.86, Tuning Error: 12.36
  .byte $01, $0c, $01, $0e, $00
zsaw_note_period_88:
; Note: E7, Target Frequency: 1318.51, Actual Frequency: 1331.68, Tuning Error: 13.17
  .byte $02, $0d, $00
zsaw_note_period_89:
; Note: F7, Target Frequency: 1396.91, Actual Frequency: 1398.26, Tuning Error: 1.35
  .byte $01, $09, $00
zsaw_note_period_90:
; Note: Fs7, Target Frequency: 1479.98, Actual Frequency: 1434.11, Tuning Error: 45.86
  .byte $01, $0d, $01, $0e, $00
zsaw_note_period_91:
; Note: G7, Target Frequency: 1567.98, Actual Frequency: 1575.50, Tuning Error: 7.52
  .byte $01, $0a, $00
zsaw_note_period_92:
; Note: Gs7, Target Frequency: 1661.22, Actual Frequency: 1575.50, Tuning Error: 85.71
  .byte $01, $0a, $00
zsaw_note_period_93:
; Note: A7, Target Frequency: 1760.00, Actual Frequency: 1747.83, Tuning Error: 12.17
  .byte $01, $0b, $00
zsaw_note_period_94:
; Note: As7, Target Frequency: 1864.66, Actual Frequency: 1747.83, Tuning Error: 116.83
  .byte $01, $0b, $00
zsaw_note_period_95:
; Note: B7, Target Frequency: 1975.53, Actual Frequency: 2110.58, Tuning Error: 135.05
  .byte $01, $0c, $00
zsaw_note_period_96:
; Note: C8, Target Frequency: 2093.00, Actual Frequency: 2110.58, Tuning Error: 17.58
  .byte $01, $0c, $00

