.include "bhop.inc"
.include "bhop_internal.inc"
.include "commands.inc"
.include "nes.inc"
.include "word_util.inc"

.macpack longbranch

.scope BHOP

        .zeropage
; scratch ptr, used for all sorts of indirect reads
bhop_ptr: .word $0000 
; pattern pointers, read repeatedly when updating
; rows in a loop, we'll want access to these to be quick
pattern_ptr: .word $0000
channel_ptr: .word $0000
channel_index: .byte $00

.exportzp bhop_ptr, channel_ptr, pattern_ptr, channel_index

        .segment "RAM"
tempo_counter: .word $0000
tempo_cmp: .word $0000
tempo: .byte $00
row_counter: .byte $00
row_cmp: .byte $00
frame_counter: .byte $00
frame_cmp: .byte $00

song_ptr: .word $0000
frame_ptr: .word $0000

pulse1_state: .tag ChannelState
pulse2_state: .tag ChannelState
triangle_state: .tag ChannelState
noise_state: .tag ChannelState
dpcm_state: .tag ChannelState

shadow_pulse1_freq_hi: .byte $00
shadow_pulse2_freq_hi: .byte $00
scratch_byte: .byte $00

; channel state tables, each 5 bytes in length
sequences_enabled: .res 5
sequences_active: .res 5
volume_sequence_ptr_low: .res 5
volume_sequence_ptr_high: .res 5
volume_sequence_index: .res 5
arpeggio_sequence_ptr_low: .res 5
arpeggio_sequence_ptr_high: .res 5
arpeggio_sequence_index: .res 5
pitch_sequence_ptr_low: .res 5
pitch_sequence_ptr_high: .res 5
pitch_sequence_index: .res 5
hipitch_sequence_ptr_low: .res 5
hipitch_sequence_ptr_high: .res 5
hipitch_sequence_index: .res 5
duty_sequence_ptr_low: .res 5
duty_sequence_ptr_high: .res 5
duty_sequence_index: .res 5

; memory for various effects
effect_note_delay: .res 5

.export effect_note_delay

.export pulse1_state, pulse2_state, triangle_state, noise_state, dpcm_state
.export row_counter, row_cmp, frame_counter, frame_cmp

        .segment "PRG0_8000"
        ; global
        .export bhop_init, bhop_play
        ; internal
        .export load_instrument

.include "midi_lut.inc"

.macro prepare_ptr address
        lda address
        sta bhop_ptr
        lda address+1
        sta bhop_ptr+1
.endmacro

; add a signed byte, stored in value, to a 16bit word
; addressed by (bhop_ptr), y
; this is used in a few places, notably pitch bend effects
; clobbers a, flags
; does *not* clobber y
.macro sadd16_ptr_y ptr, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc (ptr), y
        sta (ptr), y
        iny
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc (ptr), y
        sta (ptr), y
        dey
.endscope
.endmacro

; TODO: I believe the convention is to pick a song here?
; right now lots of stuff is hard coded, that could instead
; be read from the chosen song header

; param: song index (a)
.proc bhop_init
        ; preserve parameters
        pha ; song index

        ; global initialization things
        lda #00
        sta tempo_counter
        sta tempo_counter+1
        sta row_counter
        sta frame_counter

        ; switch to the requested song
        prepare_ptr MUSIC_BASE + FtModuleHeader::song_list

        pla
        asl ; song list is made of words
        tay
        lda (bhop_ptr), y
        sta song_ptr
        iny
        lda (bhop_ptr), y
        sta song_ptr+1

        ; load speed and tempo from the requested song
        prepare_ptr song_ptr
        ldy #SongInfo::speed
        lda (bhop_ptr), y
        tax
        jsr set_speed
        ldy #SongInfo::tempo
        lda (bhop_ptr), y
        sta tempo
        ldy #SongInfo::frame_count
        lda (bhop_ptr), y
        sta frame_cmp
        ldy #SongInfo::pattern_length
        lda (bhop_ptr), y
        sta row_cmp

        ; initialize at the first frame, and prime our pattern pointers
        ldx #0
        jsr jump_to_frame
        jsr load_frame_patterns

        ; initialize every channel's volume to 15 (some songs seem to rely on this)
        lda #$0F
        sta pulse1_state + ChannelState::channel_volume
        sta pulse2_state + ChannelState::channel_volume
        sta triangle_state + ChannelState::channel_volume
        sta noise_state + ChannelState::channel_volume

        ; disable any active effects
        lda #0
        sta pulse1_state   + ChannelState::pitch_effects_active
        sta pulse2_state   + ChannelState::pitch_effects_active
        sta triangle_state + ChannelState::pitch_effects_active
        sta noise_state    + ChannelState::pitch_effects_active
        sta dpcm_state     + ChannelState::pitch_effects_active

        ; clear out special effects
        ldx #5
effect_init_loop:
        dex
        sta effect_note_delay, x
        sta sequences_enabled, x
        sta sequences_active, x
        bne effect_init_loop

        ; finally, enable all channels except DMC
        lda #%00001111
        sta $4015

        rts
.endproc

; speed goes in x
.proc set_speed
        st16 tempo_cmp, $0000
loop:
        add16 tempo_cmp, #150
        dex
        bne loop
        rts
.endproc

; frame number goes in x
.proc jump_to_frame
        ; load the frame pointer list from the song data; we're going to rewrite
        ; frame_ptr here anyway, so use it as temp storage
        prepare_ptr song_ptr
        ldy #SongInfo::frame_list_ptr
        lda (bhop_ptr), y
        sta frame_ptr
        iny
        lda (bhop_ptr), y
        sta frame_ptr+1
        ; now add our target frame number to that
        txa
        clc
        add16a frame_ptr
        ; twice
        txa
        clc
        add16a frame_ptr
        ; now use this to load the actual frame pointer from the list
        prepare_ptr frame_ptr
        ldy #0
        lda (bhop_ptr), y
        sta frame_ptr
        iny
        lda (bhop_ptr), y
        sta frame_ptr+1
        rts
.endproc

.proc load_frame_patterns
        ;initialize all the pattern rows from the current frame pointer
        prepare_ptr frame_ptr
        ldy #0

        lda (bhop_ptr), y
        sta pulse1_state + ChannelState::pattern_ptr
        iny
        lda (bhop_ptr), y
        sta pulse1_state + ChannelState::pattern_ptr + 1
        iny

        lda (bhop_ptr), y
        sta pulse2_state + ChannelState::pattern_ptr
        iny
        lda (bhop_ptr), y
        sta pulse2_state + ChannelState::pattern_ptr + 1
        iny

        lda (bhop_ptr), y
        sta triangle_state + ChannelState::pattern_ptr
        iny
        lda (bhop_ptr), y
        sta triangle_state + ChannelState::pattern_ptr + 1
        iny

        lda (bhop_ptr), y
        sta noise_state + ChannelState::pattern_ptr
        iny
        lda (bhop_ptr), y
        sta noise_state + ChannelState::pattern_ptr + 1
        iny

        lda (bhop_ptr), y
        sta dpcm_state + ChannelState::pattern_ptr
        iny
        lda (bhop_ptr), y
        sta dpcm_state + ChannelState::pattern_ptr + 1
        iny ; unnecessary?

        ; reset all the row counters to 0
        lda #0
        sta pulse1_state + ChannelState::row_delay_counter
        sta pulse2_state + ChannelState::row_delay_counter
        sta triangle_state + ChannelState::row_delay_counter
        sta noise_state + ChannelState::row_delay_counter
        sta dpcm_state + ChannelState::row_delay_counter

        rts
.endproc

.proc tick_frame_counter
        add16 tempo_counter, tempo
        ; have we exceeded the tempo_counter?
        lda tempo_counter+1
        cmp tempo_cmp+1
        bcc done_advancing_rows ; counter is lower than threshold (high byte)
        bne advance_row  ; should be impossible to take, because we only add 255 or less?
        lda tempo_counter
        cmp tempo_cmp
        bcc done_advancing_rows
        ; is either the same or higher; do the thing
advance_row:
        ; first off, have we reached the end of this pattern?
        ; if so, advance to the next frame here:
        lda row_counter
        cmp row_cmp
        bcc no_frame_advance
        jsr advance_frame
        lda #0
        sta row_counter
no_frame_advance:
        jsr advance_pattern_rows
        ; subtract tempo_cmp from tempo_counter
        sec
        lda tempo_counter
        sbc tempo_cmp
        sta tempo_counter
        lda tempo_counter+1
        sbc tempo_cmp+1
        sta tempo_counter+1
        ; advance the row counter
        inc row_counter
        ;lda row_counter
        ;cmp row_cmp
        ;bcc done_advancing_rows
        ; row is equal or greater to max
        ;jsr advance_frame
        ;lda #0
        ;sta row_counter
done_advancing_rows:
        rts
.endproc

; prep: channel_ptr points to channel structure
.proc advance_channel_row
        ldy #ChannelState::row_delay_counter
        lda (channel_ptr), y
        cmp #0
        jne skip

        ; prep the pattern pointer for reading
        ldy #ChannelState::pattern_ptr
        lda (channel_ptr), y
        sta pattern_ptr
        iny
        lda (channel_ptr), y
        sta pattern_ptr+1
        
        ; continue reading bytecode, processing one command at a time,
        ; until a note is encountered. Any note command breaks out of the loop and
        ; signals the end of processing for this row.
bytecode_loop:
        fetch_pattern_byte
        cmp #0 ; needed to set negative flag based on command byte currently in a
        bpl handle_note ; if the low byte is clear, this is some kind of note
        tay ; preserve
        ; check for quick commands
        and #$F0
        cmp #$F0
        beq quick_volume_change
        cmp #$E0
        beq quick_instrument_change
process_extended_command:
        ; it's a *proper* command, restore the full command byte
        tya
        ; now use that to jump into the command procesisng table
        jsr dispatch_command

        ; did we activate a Gxx command? If we did, EXIT NOW.
        ; Do NOT pass Go, do NOT collect $200
        ldy channel_index
        lda effect_note_delay, y
        beq no_note_delay
        jmp cleanup_channel_ptr
no_note_delay:
        jmp bytecode_loop

quick_volume_change:
        tya ; un-preserve
        and #$0F ; a now contains new channel volume
        ldy #ChannelState::channel_volume
        sta (channel_ptr), y
        ; ready to process the next bytecode
        jmp bytecode_loop

quick_instrument_change:
        tya ; un-preserve
        and #$0F ; a now contains instrument index
        ldy #ChannelState::selected_instrument
        sta (channel_ptr), y
        jsr load_instrument
        ; ready to process the next bytecode
        jmp bytecode_loop

handle_note:
        cmp #$00 ; note rest
        beq done_with_bytecode
        cmp #$7F ; note off
        bne note_trigger
        ; a note off immediately mutes the channel
        ldy #ChannelState::status
        lda (channel_ptr), y
        ora #CHANNEL_MUTED
        sta (channel_ptr), y
        jmp done_with_bytecode
note_trigger:
        ; a contains the selected note at this point
        ldy #ChannelState::base_note
        sta (channel_ptr), y
        ; use a to read the LUT and apply base_frequency
        tax
        lda ntsc_period_low, x
        ldy #ChannelState::base_frequency
        sta (channel_ptr), y
        lda ntsc_period_high, x
        iny
        sta (channel_ptr), y

        ; if we do NOT have a portamento affect active, then also write
        ; to relative_frequency
        
        ldy #ChannelState::pitch_effects_active
        lda (channel_ptr), y
        and #($FF - PITCH_EFFECT_PORTAMENTO)
        bne portamento_active

        lda ntsc_period_low, x
        ldy #ChannelState::relative_frequency
        sta (channel_ptr), y
        lda ntsc_period_high, x
        iny
        sta (channel_ptr), y

portamento_active:
        ; finally, set the channel status as triggered
        ; (this will be cleared after effects are processed)
        ldy #ChannelState::status
        lda (channel_ptr), y
        ora #CHANNEL_TRIGGERED
        ; also, un-mute the channel
        and #($FF - CHANNEL_MUTED)
        sta (channel_ptr), y
        ; reset the instrument envelopes to the beginning
        jsr reset_instrument
        ; reset the instrument volume to 0xF (if this instrument has a volume
        ; sequence, this will be immediately overwritten with the first element)
        lda #$F
        ldy #ChannelState::instrument_volume
        sta (channel_ptr), y
        ; fall through to done_with_bytecode
done_with_bytecode:
        ; If we're still in global duration mode at this point,
        ; apply that to the row counter
        ldy #ChannelState::status
        lda (channel_ptr), y
        and #CHANNEL_GLOBAL_DURATION
        beq read_duration_from_pattern

        ldy #ChannelState::global_duration
        lda (channel_ptr), y
        ldy #ChannelState::row_delay_counter
        sta (channel_ptr), y
        jmp cleanup_channel_ptr

read_duration_from_pattern:
        fetch_pattern_byte
        ldy #ChannelState::row_delay_counter
        sta (channel_ptr), y
        ; fall through to channel_cleanup_ptr
cleanup_channel_ptr:
        ; preserve pattern_ptr back to the channel status
        ldy #ChannelState::pattern_ptr
        lda pattern_ptr
        sta (channel_ptr), y
        iny
        lda pattern_ptr+1
        sta (channel_ptr), y

        ; finally done with this channel
        jmp done
skip:
        ; conveniently carry is already set
        ; a contains the counter
        sbc #1 ; decrement that counter
        sta (channel_ptr), y ; write it back to row_delay_counter
done:
        rts
.endproc

.proc advance_pattern_rows
        ; PULSE 1
        lda #<pulse1_state
        sta channel_ptr
        lda #>pulse1_state
        sta channel_ptr+1
        lda #0
        sta channel_index
        jsr advance_channel_row

        ; PULSE 2
        lda #<pulse2_state
        sta channel_ptr
        lda #>pulse2_state
        sta channel_ptr+1
        lda #1
        sta channel_index
        jsr advance_channel_row

        ; TRIANGLE
        lda #<triangle_state
        sta channel_ptr
        lda #>triangle_state
        sta channel_ptr+1
        lda #2
        sta channel_index
        jsr advance_channel_row

        ; NOISE
        lda #<noise_state
        sta channel_ptr
        lda #>noise_state
        sta channel_ptr+1
        lda #3
        sta channel_index
        jsr advance_channel_row
        jsr fix_noise_freq

        ; DPCM
        lda #<dpcm_state
        sta channel_ptr
        lda #>dpcm_state
        sta channel_ptr+1
        lda #4
        sta channel_index
        jsr advance_channel_row

        rts
.endproc

.proc fix_noise_freq
        lda noise_state + ChannelState::status
        cmp #($FF - CHANNEL_TRIGGERED)
        beq done
        lda noise_state + ChannelState::base_note
        sta noise_state + ChannelState::base_frequency
        sta noise_state + ChannelState::relative_frequency
done:
        rts
.endproc

.proc tick_delayed_effects
        ldx channel_index
        lda effect_note_delay, x
        beq done_with_note_delay
        dec effect_note_delay, x
        bne done_with_note_delay
        ; we just decremented the effect counter from 1 -> 0,
        ; so apply a note delay. In this case, tick the bytecode reader
        ; one time:
        jsr advance_channel_row
        ; if this is the noise channel, fix its frequency
        lda channel_index
        cmp #3
        bne done_with_note_delay
        jsr fix_noise_freq
done_with_note_delay:
        rts
.endproc

.proc tick_envelopes_and_effects
        ; PULSE 1
        lda #<pulse1_state
        sta channel_ptr
        lda #>pulse1_state
        sta channel_ptr+1
        lda #0
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr tick_arp_envelope
        jsr tick_pitch_envelope

        ; PULSE 2
        lda #<pulse2_state
        sta channel_ptr
        lda #>pulse2_state
        sta channel_ptr+1
        lda #1
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr tick_arp_envelope
        jsr tick_pitch_envelope

        ; TRIANGLE
        lda #<triangle_state
        sta channel_ptr
        lda #>triangle_state
        sta channel_ptr+1
        lda #2
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_arp_envelope
        jsr tick_pitch_envelope

        ; NOISE
        lda #<noise_state
        sta channel_ptr
        lda #>noise_state
        sta channel_ptr+1
        lda #3
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_noise_arp_envelope
        jsr tick_pitch_envelope

        ; DPCM
        lda #<dpcm_state
        sta channel_ptr
        lda #>dpcm_state
        sta channel_ptr+1
        lda #4
        sta channel_index
        jsr tick_delayed_effects

        rts
.endproc

.proc advance_frame
        inc frame_counter
        lda frame_counter
        cmp frame_cmp
        bcc no_wrap
        lda #0
        sta frame_counter
no_wrap:
        ldx frame_counter
        jsr jump_to_frame
        jsr load_frame_patterns
        rts
.endproc

; Initializes channel state for playback of a particular instrument.
; Loads sequence pointers (if enabled) and clears pointers to begin
; sequence playback from the beginning
; setup: 
;   channel_ptr points to channel structure
;   ChannelState::selected_instrument contains desired instrument index
.proc load_instrument
        prepare_ptr MUSIC_BASE + FtModuleHeader::instrument_list
        ldy #ChannelState::selected_instrument
        lda (channel_ptr), y
        asl ; select one word
        tay

        ; set bhop_ptr to the selected index
        lda (bhop_ptr), y
        tax
        iny
        lda (bhop_ptr), y
        sta bhop_ptr+1
        stx bhop_ptr

        ; bhop_ptr now addresses the selected InstrumentHeader
        ldy #InstrumentHeader::sequences_enabled
        lda (bhop_ptr), y
        ldx channel_index
        sta sequences_enabled, x
        sta scratch_byte ; we'll shift bits out of this later

        ; for every enabled sequence, load the appropriate pointer
        clc
        ldy #InstrumentHeader::sequence_ptr
check_volume:
        lsr scratch_byte
        bcc check_arp

        lda (bhop_ptr), y
        sta volume_sequence_ptr_low, x
        iny
        lda (bhop_ptr), y
        sta volume_sequence_ptr_high, x
        iny

check_arp:
        lsr scratch_byte
        bcc check_pitch

        lda (bhop_ptr), y
        sta arpeggio_sequence_ptr_low, x
        iny
        lda (bhop_ptr), y
        sta arpeggio_sequence_ptr_high, x
        iny

check_pitch:
        lsr scratch_byte
        bcc check_hipitch

        lda (bhop_ptr), y
        sta pitch_sequence_ptr_low, x
        iny
        lda (bhop_ptr), y
        sta pitch_sequence_ptr_high, x
        iny

check_hipitch:
        lsr scratch_byte
        bcc check_duty

        lda (bhop_ptr), y
        sta hipitch_sequence_ptr_low, x
        iny
        lda (bhop_ptr), y
        sta hipitch_sequence_ptr_high, x
        iny

check_duty:
        lsr scratch_byte
        bcc done_loading_sequences

        lda (bhop_ptr), y
        sta duty_sequence_ptr_low, x
        iny
        lda (bhop_ptr), y
        sta duty_sequence_ptr_high, x
        ; no more need to iny

done_loading_sequences:
        jsr reset_instrument
        rts
.endproc

; Re-initializes sequence pointers back to the beginning of their
; respective envelopes
; setup: 
;   channel_index points to the active channel
.proc reset_instrument
        ldy channel_index
        lda #0
        sta volume_sequence_index, y
        sta arpeggio_sequence_index, y
        sta pitch_sequence_index, y
        sta hipitch_sequence_index, y
        sta duty_sequence_index, y

        ; when a sequence ends it terminates itself in sequences_active, so re-initialize
        ; that byte here

        lda sequences_enabled, y
        sta sequences_active, y

        rts
.endproc

; If this channel has a volume envelope active, process that
; envelope. Upon return, instrument_volume will have the current
; element in the sequence.
; setup: 
;   channel_ptr points to channel structure
.proc tick_volume_envelope
        ldy channel_index
        lda sequences_active, y
        and #SEQUENCE_VOLUME
        beq done ; if volume sequence isn't enabled, bail fast

        ; prepare the volume pointer for reading
        lda volume_sequence_ptr_low, y
        sta bhop_ptr
        lda volume_sequence_ptr_high, y
        sta bhop_ptr + 1

        ; read the current sequence byte, and set instrument_volume to this
        lda volume_sequence_index, y
        tax ; stash for later
        ; for reading the sequence, +4
        clc
        adc #4
        tay
        lda (bhop_ptr), y
        ldy #ChannelState::instrument_volume
        sta (channel_ptr), y

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
        and #($FF - SEQUENCE_VOLUME)
        sta sequences_active, y
        rts

end_not_reached:
        ; write the new sequence index (should be in x)
        ldy channel_index
        txa
        sta volume_sequence_index, y

done:
        rts
.endproc

; If this channel has a duty envelope active, process that
; envelope. Upon return, instrument_duty is set
; setup: 
;   channel_ptr points to channel structure
.proc tick_duty_envelope
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
        ; shift this into place before storing
        ror
        ror
        ror
        ; safety
        and #%11000000
        ldy #ChannelState::instrument_duty
        sta (channel_ptr), y

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

; If this channel has an arp envelope active, process that
; envelope. Upon return, base_note and relative_frequency are set
; setup: 
;   channel_ptr points to channel structure
.proc tick_arp_envelope
        ldy channel_index
        lda sequences_active, y
        and #SEQUENCE_ARP
        beq early_exit ; if sequence isn't enabled, bail fast

        ; prepare the arp pointer for reading
        lda arpeggio_sequence_ptr_low, y
        sta bhop_ptr
        lda arpeggio_sequence_ptr_high, y
        sta bhop_ptr + 1

        ; For arps, we need to "reset" the channel if the envelope finishes, so we're doing
        ; the length check first thing

        lda arpeggio_sequence_index, y
        sta scratch_byte
        ; have we reached the end of the sequence?
        ldy #SequenceHeader::length
        lda (bhop_ptr), y
        cmp scratch_byte
        bne end_not_reached
        
        ; this sequence is finished! Disable the sequence flag
        ldy channel_index
        lda sequences_active, y
        and #($FF - SEQUENCE_ARP)
        sta sequences_active, y

        ; now apply the current base note as the channel frequency,
        ; then exit:
        ldy #ChannelState::base_note
        lda (channel_ptr), y
        tax
        lda ntsc_period_low, x
        ldy #ChannelState::relative_frequency
        sta (channel_ptr), y
        lda ntsc_period_high, x
        iny
        sta (channel_ptr), y
early_exit:
        rts

end_not_reached:
        ; read the current sequence byte, and set instrument_volume to this
        ldy channel_index
        lda arpeggio_sequence_index, y
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
        ldy #ChannelState::base_note
        lda (channel_ptr), y
        clc
        adc scratch_byte
        tax
        jmp apply_arp
arp_relative:
        ; arp accumulates an offset each frame, from the previous frame
        ldy #ChannelState::base_note
        lda (channel_ptr), y
        clc
        adc scratch_byte
        sta (channel_ptr), y
        tax
        jmp apply_arp
arp_fixed:
        ; the arp value *is* the note to apply
        lda scratch_byte
        tax
        ; fall through to apply_arp
apply_arp:
        lda ntsc_period_low, x
        ldy #ChannelState::relative_frequency
        sta (channel_ptr), y
        lda ntsc_period_high, x
        iny
        sta (channel_ptr), y

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

; We need a special variant of this just for noise, which uses a different
; means of frequency to base_note mapping
; setup: 
;   channel_ptr points to channel structure
.proc tick_noise_arp_envelope
        ldy channel_index
        lda sequences_active, y
        and #SEQUENCE_ARP
        beq early_exit ; if sequence isn't enabled, bail fast

        ; prepare the arp pointer for reading
        lda arpeggio_sequence_ptr_low, y
        sta bhop_ptr
        lda arpeggio_sequence_ptr_high, y
        sta bhop_ptr + 1

        ; For arps, we need to "reset" the channel if the envelope finishes, so we're doing
        ; the length check first thing

        lda arpeggio_sequence_index, y
        sta scratch_byte
        ; have we reached the end of the sequence?
        ldy #SequenceHeader::length
        lda (bhop_ptr), y
        cmp scratch_byte
        bne end_not_reached
        
        ; this sequence is finished! Disable the sequence flag
        ldy channel_index
        lda sequences_active, y
        and #($FF - SEQUENCE_ARP)
        sta sequences_active, y

        ; now apply the current base note as the channel frequency,
        ; then exit:
        ldy #ChannelState::base_note
        lda (channel_ptr), y
        ldy #ChannelState::relative_frequency
        sta (channel_ptr), y
early_exit:
        rts

end_not_reached:
        ; read the current sequence byte, and set instrument_volume to this
        ldy channel_index
        lda arpeggio_sequence_index, y
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
        ldy #ChannelState::base_note
        lda (channel_ptr), y
        clc
        adc scratch_byte
        tax
        jmp apply_arp
arp_relative:
        ; arp accumulates an offset each frame, from the previous frame
        ldy #ChannelState::base_note
        lda (channel_ptr), y
        clc
        adc scratch_byte
        sta (channel_ptr), y
        tax
        jmp apply_arp
arp_fixed:
        ; the arp value *is* the note to apply
        lda scratch_byte
        tax
        ; fall through to apply_arp
apply_arp:
        txa ; for noise, we'll use the value directly
        ldy #ChannelState::relative_frequency
        sta (channel_ptr), y

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

; If this channel has a pitch envelope active, process that
; envelope. Upon return, relative_pitch is set
; setup: 
;   channel_ptr points to channel structure
.proc tick_pitch_envelope
        ldy channel_index
        lda sequences_active, y
        and #SEQUENCE_PITCH
        beq done ; if sequence isn't enabled, bail fast

        ; prepare the pitch pointer for reading
        lda pitch_sequence_ptr_low, y
        sta bhop_ptr
        lda pitch_sequence_ptr_high, y
        sta bhop_ptr + 1

        ; read the current sequence byte, and set instrument_volume to this        
        lda pitch_sequence_index, y
        tax ; stash for later
        ; for reading the sequence, +4
        clc
        adc #4
        tay
        lda (bhop_ptr), y
        sta scratch_byte

        ; what we do here depends on the mode
        ldy #SequenceHeader::mode
        lda (bhop_ptr), y
        cmp #PITCH_MODE_RELATIVE
        beq relative_pitch_mode
absolute_pitch_mode:
        ; additional guard: if we are currently running an arp
        ; envelope, then temporarily pretend to be in relative_pitch mode
        ; (otherwise we cancel out the arp)
        ldy channel_index
        lda sequences_active, y
        and #SEQUENCE_ARP
        bne relative_pitch_mode

        ; in absolute mode, reset to base_frequency before
        ; performing the addition
        ldy #ChannelState::base_frequency
        lda (channel_ptr), y
        ldy #ChannelState::relative_frequency
        sta (channel_ptr), y
        ldy #ChannelState::base_frequency + 1
        lda (channel_ptr), y
        ldy #ChannelState::relative_frequency + 1
        sta (channel_ptr), y
relative_pitch_mode:
        ; add this data to relative_pitch
        ldy #ChannelState::relative_frequency
        sadd16_ptr_y channel_ptr, scratch_byte

done_applying_pitch:
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
        and #($FF - SEQUENCE_PITCH)
        sta sequences_active, y
        rts

end_not_reached:
        ; write the new sequence index (should still be in x)
        ldy channel_index
        txa
        sta pitch_sequence_index, y

done:
        rts
.endproc

; setup:
;   channel_ptr points to channel structure
;   bhop_ptr points to start of sequence data
;   x - current sequence pointer
; return: new sequence counter in x
; side effects: sequences_active altered
.proc tick_sequence_counter
        ; increment the index we stashed earlier
        inx
        ; have we reached the end of the loop?
        ldy #SequenceHeader::length
        lda (bhop_ptr), y
        sta scratch_byte
        cpx scratch_byte
        bne end_not_reached

end_reached:
        ; Do we have a loop point defined?
        ldy #SequenceHeader::loop_point
        lda (bhop_ptr), y
        cmp #$FF
        beq end_reached_without_loop
        jmp apply_loop_point

end_reached_without_loop:
        ; do nothing, and exit; the calling function will check to see if
        ; the sequence pointer is at the end, and deactivate the sequence
        rts

end_not_reached:
        ; have we reached the release point?
        ldy #SequenceHeader::release_point
        lda (bhop_ptr), y
        sta scratch_byte
        cpx scratch_byte
        bne release_point_not_reached

        ; is there a loop point? if so, jump there
        ldy #SequenceHeader::loop_point
        lda (bhop_ptr), y
        cmp #$FF ; magic value, means there is no loop defined
        beq release_without_loop

apply_loop_point:
        ; a contains our loop point, so jump there and exit
        tax
        rts

release_without_loop:
        ; otherwise, hold position and exit
        dex
        rts

release_point_not_reached:
        ; no jumps needed, so stash our new sequence value and exit
done:
        rts
.endproc

.proc tick_registers
tick_pulse1:
        bit pulse1_state + ChannelState::status
        bmi pulse1_muted

        ; apply the combined channel and instrument volume
        lda pulse1_state + ChannelState::channel_volume
        asl
        asl
        asl
        asl
        ora pulse1_state + ChannelState::instrument_volume
        tax
        lda volume_table, x

        ; add in the duty
        ora pulse1_state + ChannelState::instrument_duty
        ora #%00110000 ; disable length counter and envelope
        sta $4000

        ; disable the sweep unit
        lda #$08
        sta $4001

        lda pulse1_state + ChannelState::relative_frequency
        sta $4002

        ; If we triggered this frame, write unconditionally
        lda pulse1_state + ChannelState::status
        and #CHANNEL_TRIGGERED
        bne write_pulse1

        ; otherwise, to avoid resetting the sequence counter, only
        ; write if the high byte has changed since the last time
        lda pulse1_state + ChannelState::relative_frequency + 1
        cmp shadow_pulse1_freq_hi
        beq tick_pulse2

write_pulse1:
        lda pulse1_state + ChannelState::relative_frequency + 1
        sta shadow_pulse1_freq_hi
        ora #%11111000
        sta $4003
        jmp tick_pulse2
pulse1_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00110000
        sta $4000

tick_pulse2:
        bit pulse2_state + ChannelState::status
        bmi pulse2_muted

        ; apply the combined channel and instrument volume
        lda pulse2_state + ChannelState::channel_volume
        asl
        asl
        asl
        asl
        ora pulse2_state + ChannelState::instrument_volume
        tax
        lda volume_table, x

        ; add in the duty
        ora pulse2_state + ChannelState::instrument_duty
        ora #%00110000 ; set a duty, disable length counter and envelope
        sta $4004

        ; disable the sweep unit
        lda #$08
        sta $4005

        lda pulse2_state + ChannelState::relative_frequency
        sta $4006

        ; If we triggered this frame, write unconditionally
        lda pulse2_state + ChannelState::status
        and #CHANNEL_TRIGGERED
        bne write_pulse2

        ; otherwise, to avoid resetting the sequence counter, only
        ; write if the high byte has changed since the last time
        lda pulse2_state + ChannelState::relative_frequency + 1
        cmp shadow_pulse2_freq_hi
        beq tick_triangle

write_pulse2:
        lda pulse2_state + ChannelState::relative_frequency + 1
        sta shadow_pulse2_freq_hi
        ora #%11111000
        sta $4007
        jmp tick_triangle
pulse2_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00110000
        sta $4004

tick_triangle:
        bit triangle_state + ChannelState::status
        bmi triangle_muted
        ; triangle additionally should mute here if either channel volume,
        ; or instrument volume is zero
        ; (but don't clobber a)
        ldx triangle_state + ChannelState::channel_volume
        beq triangle_muted
        ldx triangle_state + ChannelState::instrument_volume
        beq triangle_muted

        lda #$FF
        sta $4008 ; timers to max

        lda triangle_state + ChannelState::relative_frequency
        sta $400A
        lda triangle_state + ChannelState::relative_frequency + 1
        sta $400B
        jmp tick_noise
triangle_muted:
        ; since triangle has no volume, we'll instead choose to mute it by
        ; setting the length counter to 0 and forcing an immediate reload.
        ; This will delay the mute by up to 1/4 of a frame, but this is the
        ; best we can do without conflicting with the DMC channel
        lda #$80
        sta $4008

tick_noise:
        bit noise_state + ChannelState::status
        bmi noise_muted

        ; apply the combined channel and instrument volume
        lda noise_state + ChannelState::channel_volume
        asl
        asl
        asl
        asl
        ora noise_state + ChannelState::instrument_volume
        tax
        lda volume_table, x

        ora #%00110000 ; disable length counter and envelope
        sta $400C

        ; the low 4 bits of relative_frequency become the
        ; noise period
        lda noise_state + ChannelState::relative_frequency
        and #%00001111
        ; of *course* it's inverted
        sta scratch_byte
        lda #$0F
        sec
        sbc scratch_byte
        sta scratch_byte

        ; the low bit of channel duty becomes mode bit 1
        lda noise_state + ChannelState::instrument_duty
        asl
        and #%10000000 ; safety mask
        ora scratch_byte

        sta $400E

        ; finally, ensure the note is actually playing with a length
        ; counter that is not zero
        lda #%11111000
        sta $400F  
        jmp cleanup
noise_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00110000
        sta $400C

cleanup:
        jsr play_dpcm_samples

        ; clear the triggered flag from every instrument
        lda pulse1_state + ChannelState::status
        and #($FF - CHANNEL_TRIGGERED)
        sta pulse1_state + ChannelState::status

        lda pulse2_state + ChannelState::status
        and #($FF - CHANNEL_TRIGGERED)
        sta pulse2_state + ChannelState::status

        lda triangle_state + ChannelState::status
        and #($FF - CHANNEL_TRIGGERED)
        sta triangle_state + ChannelState::status

        lda noise_state + ChannelState::status
        and #($FF - CHANNEL_TRIGGERED)
        sta noise_state + ChannelState::status

        lda dpcm_state + ChannelState::status
        and #($FF - CHANNEL_TRIGGERED)
        sta dpcm_state + ChannelState::status

        rts
.endproc

.proc play_dpcm_samples
        bit dpcm_state + ChannelState::status
        bmi dpcm_muted

        lda dpcm_state + ChannelState::status
        and #CHANNEL_TRIGGERED
        beq done

        ; using the current note, read the sample table
        prepare_ptr MUSIC_BASE + FtModuleHeader::sample_list
        lda dpcm_state + ChannelState::base_note
        ; if this is the special value $7E, then this is a note release; immediately halt the channel,
        ; but do not set the delta counter
        cmp #$7E
        beq dpcm_muted
        sta scratch_byte
        dec scratch_byte ; notes start at 1, list is indexed at 0
        ; multiply by 3
        lda #0
        clc
        adc scratch_byte
        adc scratch_byte
        adc scratch_byte
        tay
        ; in order, the sample_list should contain:
        ; - LL..RRRR - Loop, playback Rate
        ; - EDDDDDDD - delta Enabled, Delta counter
        ; - nnnnnnnn - iNdex into sample table
        lda (bhop_ptr), y
        iny
        and #%01111111 ; do NOT enable IRQs
        sta $4010      ; write rate and loop enable
        lda (bhop_ptr), y
        iny
        bpl no_delta_set
        sta $4011
no_delta_set:
        lda (bhop_ptr), y
        ; this is the index into the samples table, here it is pre-multiplied
        ; so we can use it directly
        tay
        prepare_ptr MUSIC_BASE + FtModuleHeader::samples
        ; the sample table should contain, in order:
        ; - location byte
        ; - size byte
        ; - bank to switch in (which we'll ignore for now)
        lda (bhop_ptr), y
        iny
        sta $4012
        lda (bhop_ptr), y
        sta $4013
        ; finally, briefly disable the sample channel to set bytes_remaining in the memory
        ; reader to 0, then start it again to initiate playback
        lda #$0F
        sta $4015
        lda #$1F
        sta $4015
done:
        rts

dpcm_muted:
        ; simply disable the channel and exit (whatever is in the sample playback buffer will
        ; finish, up to 8 bits, there is no way to disable this)
        lda #%00001111
        sta $4015

        rts
.endproc

.proc bhop_play
        jsr tick_frame_counter
        jsr tick_envelopes_and_effects
        jsr tick_registers
        ; D:
        rts
.endproc

volume_table:
        .byte $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
        .byte $0, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1
        .byte $0, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $2
        .byte $0, $1, $1, $1, $1, $1, $1, $1, $1, $1, $2, $2, $2, $2, $2, $3
        .byte $0, $1, $1, $1, $1, $1, $1, $1, $2, $2, $2, $2, $3, $3, $3, $4
        .byte $0, $1, $1, $1, $1, $1, $2, $2, $2, $3, $3, $3, $4, $4, $4, $5
        .byte $0, $1, $1, $1, $1, $2, $2, $2, $3, $3, $4, $4, $4, $5, $5, $6
        .byte $0, $1, $1, $1, $1, $2, $2, $3, $3, $4, $4, $5, $5, $6, $6, $7
        .byte $0, $1, $1, $1, $2, $2, $3, $3, $4, $4, $5, $5, $6, $6, $7, $8 
        .byte $0, $1, $1, $1, $2, $3, $3, $4, $4, $5, $6, $6, $7, $7, $8, $9 
        .byte $0, $1, $1, $2, $2, $3, $4, $4, $5, $6, $6, $7, $8, $8, $9, $A 
        .byte $0, $1, $1, $2, $2, $3, $4, $5, $5, $6, $7, $8, $8, $9, $A, $B 
        .byte $0, $1, $1, $2, $3, $4, $4, $5, $6, $7, $8, $8, $9, $A, $B, $C 
        .byte $0, $1, $1, $2, $3, $4, $5, $6, $6, $7, $8, $9, $A, $B, $C, $D 
        .byte $0, $1, $1, $2, $3, $4, $5, $6, $7, $8, $9, $A, $B, $C, $D, $E
        .byte $0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $A, $B, $C, $D, $E, $F

.endscope


