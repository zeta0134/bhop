.scope BHOP
.include "bhop/config.inc"
.include "bhop/bhop_internal.inc"
.include "bhop/longbranch.inc"

NUM_CHANNELS = 5 ;  note: this might change with expansion support

.include "bhop/commands.asm"
.include "bhop/effects.asm"        

        .segment BHOP_ZP_SEGMENT
; scratch ptr, used for all sorts of indirect reads
bhop_ptr: .word $0000 
; pattern pointers, read repeatedly when updating
; rows in a loop, we'll want access to these to be quick
pattern_ptr: .word $0000
channel_index: .byte $00
scratch_byte: .byte $00

        .segment BHOP_RAM_SEGMENT
tempo_counter: .word $0000
tempo_cmp: .word $0000
tempo: .byte $00
row_counter: .byte $00
row_cmp: .byte $00
frame_counter: .byte $00
frame_cmp: .byte $00

song_ptr: .word $0000
frame_ptr: .word $0000

shadow_pulse1_freq_hi: .byte $00
shadow_pulse2_freq_hi: .byte $00

; channel state tables
channel_pattern_ptr_low: .res BHOP::NUM_CHANNELS
channel_pattern_ptr_high: .res BHOP::NUM_CHANNELS
channel_status: .res BHOP::NUM_CHANNELS
channel_global_duration: .res BHOP::NUM_CHANNELS
channel_row_delay_counter: .res BHOP::NUM_CHANNELS
channel_base_note: .res BHOP::NUM_CHANNELS
channel_relative_note_offset:  .res BHOP::NUM_CHANNELS
channel_base_frequency_low: .res BHOP::NUM_CHANNELS
channel_base_frequency_high: .res BHOP::NUM_CHANNELS
channel_relative_frequency_low: .res BHOP::NUM_CHANNELS
channel_relative_frequency_high: .res BHOP::NUM_CHANNELS
channel_detuned_frequency_low: .res BHOP::NUM_CHANNELS
channel_detuned_frequency_high: .res BHOP::NUM_CHANNELS
channel_volume: .res BHOP::NUM_CHANNELS
channel_tremolo_volume: .res BHOP::NUM_CHANNELS
channel_duty: .res BHOP::NUM_CHANNELS
channel_instrument_volume: .res BHOP::NUM_CHANNELS
channel_instrument_duty: .res BHOP::NUM_CHANNELS
channel_selected_instrument: .res BHOP::NUM_CHANNELS
channel_pitch_effects_active: .res BHOP::NUM_CHANNELS

; sequence state tables
sequences_enabled: .res BHOP::NUM_CHANNELS
sequences_active: .res BHOP::NUM_CHANNELS
volume_sequence_ptr_low: .res BHOP::NUM_CHANNELS
volume_sequence_ptr_high: .res BHOP::NUM_CHANNELS
volume_sequence_index: .res BHOP::NUM_CHANNELS
arpeggio_sequence_ptr_low: .res BHOP::NUM_CHANNELS
arpeggio_sequence_ptr_high: .res BHOP::NUM_CHANNELS
arpeggio_sequence_index: .res BHOP::NUM_CHANNELS
pitch_sequence_ptr_low: .res BHOP::NUM_CHANNELS
pitch_sequence_ptr_high: .res BHOP::NUM_CHANNELS
pitch_sequence_index: .res BHOP::NUM_CHANNELS
hipitch_sequence_ptr_low: .res BHOP::NUM_CHANNELS
hipitch_sequence_ptr_high: .res BHOP::NUM_CHANNELS
hipitch_sequence_index: .res BHOP::NUM_CHANNELS
duty_sequence_ptr_low: .res BHOP::NUM_CHANNELS
duty_sequence_ptr_high: .res BHOP::NUM_CHANNELS
duty_sequence_index: .res BHOP::NUM_CHANNELS

; memory for various effects
effect_note_delay: .res BHOP::NUM_CHANNELS
effect_cut_delay: .res BHOP::NUM_CHANNELS
effect_skip_target: .byte $00


        .segment BHOP_PLAYER_SEGMENT
        ; global
        .export bhop_init, bhop_play

.include "bhop/midi_lut.inc"

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
        prepare_ptr BHOP_MUSIC_BASE + FtModuleHeader::song_list

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
        sta channel_volume + PULSE_1_INDEX
        sta channel_volume + PULSE_2_INDEX
        sta channel_volume + TRIANGLE_INDEX
        sta channel_volume + NOISE_INDEX

        ; disable any active effects
        lda #0
        sta channel_pitch_effects_active + PULSE_1_INDEX
        sta channel_pitch_effects_active + PULSE_2_INDEX
        sta channel_pitch_effects_active + TRIANGLE_INDEX
        sta channel_pitch_effects_active + NOISE_INDEX
        sta channel_pitch_effects_active + DPCM_INDEX

        ; reset every channel's status
        lda #(CHANNEL_MUTED)
        sta channel_status + PULSE_1_INDEX
        sta channel_status + PULSE_2_INDEX
        sta channel_status + TRIANGLE_INDEX
        sta channel_status + NOISE_INDEX
        sta channel_status + DPCM_INDEX

        ; clear out special effects
        lda #0
        ldx #NUM_CHANNELS
effect_init_loop:
        dex
        sta effect_note_delay, x
        sta sequences_enabled, x
        sta sequences_active, x
        sta channel_tuning, x
        sta channel_vibrato_settings, x
        sta channel_vibrato_accumulator, x
        sta channel_volume_slide_settings, x
        sta channel_tremolo_settings, x
        sta channel_duty, x
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
        clc
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

        ; Pulse 1
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+0
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+0
        iny

        ; Pulse 2
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+1
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+1
        iny

        ; Triangle
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+2
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+2
        iny

        ; Noise
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+3
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+3
        iny

        ; DPCM
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+4
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+4
        iny

        ; reset all the row counters to 0
        lda #0
        sta channel_row_delay_counter + PULSE_1_INDEX
        sta channel_row_delay_counter + PULSE_2_INDEX
        sta channel_row_delay_counter + TRIANGLE_INDEX
        sta channel_row_delay_counter + NOISE_INDEX
        sta channel_row_delay_counter + DPCM_INDEX

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
        ; Dxx command processing: do we have a skip requested?
        lda effect_skip_target
        beq no_skip_requested
        ; we'll skip right away, so advance the frame pointer and load
        ; the next frame:
        jsr advance_frame
        lda #0
        sta row_counter
        dec effect_skip_target
        ; if the target is 00 at this point, we're done with the Dxx effect.
        ; Process the next row normally.
        beq no_frame_advance
        ; Otherwise, we now need to continually skip entire rows in a loop
dxx_loop:
        jsr skip_pattern_rows
        inc row_counter
        dec effect_skip_target
        bne dxx_loop
        ; now, finally we are done with the dxx command. Process the next
        ; row normally:
        jmp no_frame_advance

no_skip_requested:
        ; first off, have we reached the end of this pattern?
        ; if so, advance to the next frame here:
        lda row_counter
        cmp row_cmp
        bcc no_frame_advance
        jsr advance_frame
        lda #0
        sta row_counter
no_frame_advance:
        ; subtract tempo_cmp from tempo_counter
        sec
        lda tempo_counter
        sbc tempo_cmp
        sta tempo_counter
        lda tempo_counter+1
        sbc tempo_cmp+1
        sta tempo_counter+1
        ; process the bytecode for the next pattern row
        jsr advance_pattern_rows
        ; advance the row counter *after* running the bytecode
        inc row_counter
done_advancing_rows:
        rts
.endproc

; prep: 
; - channel_index is set to desired channel
.proc advance_channel_row
        ldx channel_index
        lda channel_row_delay_counter, x
        cmp #0
        jne skip

        ; prep the pattern pointer for reading
        lda channel_pattern_ptr_low, x
        sta pattern_ptr
        lda channel_pattern_ptr_high, x
        sta pattern_ptr+1

        ; implementation note: x now holds channel_index, and lots of this code
        ; assumes it will not be clobbered. Take care when refactoring.
        
        ; continue reading bytecode, processing one command at a time,
        ; until a note is encountered. Any note command breaks out of the loop and
        ; signals the end of processing for this row.
bytecode_loop:
        fetch_pattern_byte
        cmp #0 ; needed to set negative flag based on command byte currently in a
        bpl handle_note ; if the high bit is clear, this is some kind of note
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
        ldx channel_index ; un-clobber, since we don't know what dispatch_command did to x
        lda effect_note_delay, x
        beq no_note_delay
        jmp cleanup_channel_ptr
no_note_delay:
        jmp bytecode_loop

quick_volume_change:
        tya ; un-preserve
        and #$0F ; a now contains new channel volume
        sta channel_volume, x
        ; ready to process the next bytecode
        jmp bytecode_loop

quick_instrument_change:
        tya ; un-preserve
        and #$0F ; a now contains instrument index
        sta channel_selected_instrument, x
        jsr load_instrument
        ; ready to process the next bytecode
        jmp bytecode_loop

handle_note:
        cmp #$00 ; note rest
        beq done_with_bytecode
        cmp #$7F ; note off
        bne check_release
        ; a note off immediately mutes the channel
        lda channel_status, x
        ora #CHANNEL_MUTED
        sta channel_status, x
        jmp done_with_bytecode
check_release:
        cmp #$7E
        bne note_trigger
        lda channel_status, x
        ora #CHANNEL_RELEASED
        sta channel_status, x
        jsr apply_release
        jmp done_with_bytecode
note_trigger:
        ; a contains the selected note at this point
        sta channel_base_note, x
        ; use a to read the LUT and apply base_frequency
        tay
        lda ntsc_period_low, y
        sta channel_base_frequency_low, x
        lda ntsc_period_high, y
        sta channel_base_frequency_high, x

        ; if portamento is active AND we are not currently muted,
        ; then skip writing the relative frequency
        
        lda channel_status, x
        and #CHANNEL_MUTED
        bne write_relative_frequency

        lda channel_pitch_effects_active, x
        and #PITCH_EFFECT_PORTAMENTO
        bne portamento_active

write_relative_frequency:
        lda channel_base_frequency_low, x
        sta channel_relative_frequency_low, x
        lda channel_base_frequency_high, x
        sta channel_relative_frequency_high, x

portamento_active:
        ; finally, set the channel status as triggered
        ; (this will be cleared after effects are processed)
        lda channel_status, x
        ora #CHANNEL_TRIGGERED
        ; also, un-mute  and un-release the channel
        and #($FF - (CHANNEL_MUTED | CHANNEL_RELEASED))
        sta channel_status, x
        ; reset the instrument envelopes to the beginning
        jsr reset_instrument ; clobbers a, y
        ; reset the instrument volume to 0xF (if this instrument has a volume
        ; sequence, this will be immediately overwritten with the first element)
        lda #$F
        sta channel_instrument_volume, x
        ; reset the instrument duty to the channel_duty (again, this will usually
        ; be overwritten by the instrument sequence)
        lda channel_duty, x
        sta channel_instrument_duty, x
        ; fall through to done_with_bytecode
done_with_bytecode:
        ; If we're still in global duration mode at this point,
        ; apply that to the row counter
        ldx channel_index
        lda channel_status, x
        and #CHANNEL_GLOBAL_DURATION
        beq read_duration_from_pattern

        lda channel_global_duration, x
        sta channel_row_delay_counter, x
        jmp cleanup_channel_ptr

read_duration_from_pattern:
        fetch_pattern_byte ; does not clobber x
        sta channel_row_delay_counter, x
        ; fall through to channel_cleanup_ptr
cleanup_channel_ptr:
        ; preserve pattern_ptr back to the channel status
        ldx channel_index
        lda pattern_ptr
        sta channel_pattern_ptr_low, x
        lda pattern_ptr+1
        sta channel_pattern_ptr_high, x

        ; finally done with this channel
        jmp done
skip:
        ; conveniently carry is already set
        ; a contains the counter
        sbc #1 ; decrement that counter
        sta channel_row_delay_counter, x
done:
        rts
.endproc

; if for whatever reason (usually Dxx with xx >= 0) we need to skip a channel
; row and *not* apply *any* of the bytecode, this is the way to go. Note that we
; still need to process the bytecode mostly normally, and apply duration changes
; and whatnot.
.proc skip_channel_row
        ldx channel_index
        lda channel_row_delay_counter, x
        cmp #0
        jne skip

        ; prep the pattern pointer for reading
        lda channel_pattern_ptr_low, x
        sta pattern_ptr
        lda channel_pattern_ptr_high, x
        sta pattern_ptr+1

        ; implementation note: x now holds channel_index, and lots of this code
        ; assumes it will not be clobbered. Take care when refactoring.
        
        ; continue reading bytecode, processing one command at a time,
        ; until a note is encountered. Any note command breaks out of the loop and
        ; signals the end of processing for this row.
bytecode_loop:
        fetch_pattern_byte
        cmp #0 ; needed to set negative flag based on command byte currently in a
        bpl handle_note ; if the high bit is clear, this is some kind of note
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
        ; instead of applying the command, we just need to skip over it; unfortunately
        ; not all commands have a parameter byte, so we need to handle special cases. Note
        ; that the global duration affecting commands will NOT be skipped here!
        jsr skip_command
        ; note that we ignore Gxx commands, which means unlike the main loop above, we
        ; don't need to check if we enabled them here. (We didn't.)
        jmp bytecode_loop

quick_volume_change:
        ; do nothing
        jmp bytecode_loop

quick_instrument_change:
        ; also do nothing
        jmp bytecode_loop

handle_note:
        ; we don't care what kind of note this is, we're ignoring it. Proceed to be done
        ; processing bytecode for this row.
done_with_bytecode:
        ; If we're still in global duration mode at this point,
        ; apply that to the row counter
        ldx channel_index
        lda channel_status, x
        and #CHANNEL_GLOBAL_DURATION
        beq read_duration_from_pattern

        lda channel_global_duration, x
        sta channel_row_delay_counter, x
        jmp cleanup_channel_ptr

read_duration_from_pattern:
        fetch_pattern_byte ; does not clobber x
        sta channel_row_delay_counter, x
        ; fall through to channel_cleanup_ptr
cleanup_channel_ptr:
        ; preserve pattern_ptr back to the channel status
        ldx channel_index
        lda pattern_ptr
        sta channel_pattern_ptr_low, x
        lda pattern_ptr+1
        sta channel_pattern_ptr_high, x

        ; finally done with this channel
        jmp done
skip:
        ; conveniently carry is already set
        ; a contains the counter
        sbc #1 ; decrement that counter
        sta channel_row_delay_counter, x
done:
        rts
.endproc

.proc advance_pattern_rows
        ; PULSE 1
        lda #PULSE_1_INDEX
        sta channel_index
        jsr advance_channel_row

        ; PULSE 2
        lda #PULSE_2_INDEX
        sta channel_index
        jsr advance_channel_row

        ; TRIANGLE
        lda #TRIANGLE_INDEX
        sta channel_index
        jsr advance_channel_row

        ; NOISE
        lda #NOISE_INDEX
        sta channel_index
        jsr advance_channel_row
        jsr fix_noise_freq

        ; DPCM
        lda #DPCM_INDEX
        sta channel_index
        jsr advance_channel_row

        rts
.endproc

.proc skip_pattern_rows
        ; PULSE 1
        lda #PULSE_1_INDEX
        sta channel_index
        jsr skip_channel_row

        ; PULSE 2
        lda #PULSE_2_INDEX
        sta channel_index
        jsr skip_channel_row

        ; TRIANGLE
        lda #TRIANGLE_INDEX
        sta channel_index
        jsr skip_channel_row

        ; NOISE
        lda #NOISE_INDEX
        sta channel_index
        jsr skip_channel_row

        ; DPCM
        lda #DPCM_INDEX
        sta channel_index
        jsr skip_channel_row

        rts
.endproc

.proc fix_noise_freq
        lda channel_status + NOISE_INDEX
        cmp #($FF - CHANNEL_TRIGGERED)
        beq done
        lda channel_base_note + NOISE_INDEX
        sta channel_base_frequency_low + NOISE_INDEX
        sta channel_relative_frequency_low + NOISE_INDEX
done:
        rts
.endproc

.proc tick_delayed_effects
        ; Gxx: delayed pattern row
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
        ; Sxx: delayed note cut
        ldx channel_index
        lda effect_cut_delay, x
        beq done_with_cut_delay
        dec effect_cut_delay, x
        bne done_with_cut_delay
        ; apply a note cut, immediately silencing this channel
        lda channel_status, x
        ora #CHANNEL_MUTED
        sta channel_status, x
done_with_cut_delay:
        rts
.endproc

.macro initialize_detuned_frequency
        ldx channel_index
        lda channel_relative_frequency_low, x
        sta channel_detuned_frequency_low, x
        lda channel_relative_frequency_high, x
        sta channel_detuned_frequency_high, x
.endmacro

.proc tick_envelopes_and_effects
        ; PULSE 1
        lda #PULSE_1_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        ; the order of pitch updates matters a lot to match FT behavior
        jsr update_arp
        jsr update_pitch_effects
        jsr update_volume_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning

        ; PULSE 2
        lda #PULSE_2_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr update_arp
        jsr update_pitch_effects
        jsr update_volume_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning

        ; TRIANGLE
        lda #TRIANGLE_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr update_arp
        jsr update_pitch_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning

        ; NOISE
        lda #NOISE_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr update_volume_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr tick_noise_arp_envelope
        jsr tick_pitch_envelope

        ; DPCM
        lda #DPCM_INDEX
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
;   channel_index points to desired channel
;   channel_selected_instrument[channel_index] contains desired instrument index
.proc load_instrument
        prepare_ptr BHOP_MUSIC_BASE + FtModuleHeader::instrument_list
        ldx channel_index
        lda channel_selected_instrument, x
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
;   channel_index points to channel structure
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
        ldy channel_index
        sta channel_instrument_volume, y

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
;   channel_index points to channel structure
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

; If this channel has an arp envelope active, process that
; envelope. Upon return, base_note and relative_frequency are set
; setup: 
;   channel_index, channel_index points to channel structure
.proc tick_arp_envelope
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
        tay
        lda ntsc_period_low, y
        sta channel_relative_frequency_low, x
        lda ntsc_period_high, y
        sta channel_relative_frequency_high, x
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
        lda ntsc_period_low, y
        sta channel_relative_frequency_low, x
        lda ntsc_period_high, y
        sta channel_relative_frequency_high, x

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
;   channel_index points to channel structure
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

        ; For arps, we need to "reset" the channel if the envelope finishes, so we're doing
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

; If this channel has a pitch envelope active, process that
; envelope. Upon return, relative_pitch is set
; setup: 
;   channel_index points to channel structure
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
        lda channel_base_frequency_low, y
        sta channel_relative_frequency_low, y
        lda channel_base_frequency_high, y
        sta channel_relative_frequency_high, y
relative_pitch_mode:
        ; add this data to relative_pitch
        ldy channel_index
        sadd16_split_y channel_relative_frequency_low, channel_relative_frequency_high, scratch_byte

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
;   channel_index points to channel structure
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
        ; Is this loop point *after* the release point?
        ldy #SequenceHeader::release_point
        cmp (bhop_ptr), y ; A=loop point, M=release point
        bcc end_reached_without_loop
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

        ; is there a loop point?
        ldy #SequenceHeader::loop_point
        lda (bhop_ptr), y
        cmp #$FF ; magic value, means there is no loop defined
        beq release_without_loop
        ; is the loop point *before* the release point?
        cmp scratch_byte ; A=loop point, M=release point
        bcs release_without_loop

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

.macro release_sequence sequence_type, sequence_ptr_low, sequence_ptr_high, pitch_sequence_index
.scope
        lda sequences_active, x
        and #sequence_type
        beq done_with_sequence ; if sequence isn't enabled, bail fast

        ; prepare the pitch pointer for reading
        lda sequence_ptr_low, x
        sta bhop_ptr
        lda sequence_ptr_high, x
        sta bhop_ptr + 1

        ; do we have a release point enabled?
        ldy #SequenceHeader::release_point
        lda (bhop_ptr), y
        beq done_with_sequence
        ; set the sequence index to the release point immediately
        ; (it will be ticked *past* this point on the next cycle)
        sta pitch_sequence_index, x
done_with_sequence:
.endscope
.endmacro

; If this channel has any envelopes, and those envelopes
; have a release point, jump to it immediately
; setup: 
;   channel_index points to channel structure
;   x contains channel_index
.proc apply_release
        ; note: channel_index is conveniently already in X
release_sequence SEQUENCE_VOLUME, volume_sequence_ptr_low, volume_sequence_ptr_high, volume_sequence_index
release_sequence SEQUENCE_PITCH, pitch_sequence_ptr_low, pitch_sequence_ptr_high, pitch_sequence_index
release_sequence SEQUENCE_ARP, arpeggio_sequence_ptr_low, arpeggio_sequence_ptr_high, arpeggio_sequence_index
release_sequence SEQUENCE_DUTY, duty_sequence_ptr_low, duty_sequence_ptr_high, duty_sequence_index
        rts
.endproc

.proc tick_registers
tick_pulse1:
        bit channel_status + PULSE_1_INDEX
        bmi pulse1_muted

        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + PULSE_1_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + PULSE_1_INDEX
        tax
        lda volume_table, x

        ; add in the duty
        ora channel_instrument_duty + PULSE_1_INDEX
        ora #%00110000 ; disable length counter and envelope
        sta $4000

        ; disable the sweep unit
        lda #$08
        sta $4001

        lda channel_detuned_frequency_low + PULSE_1_INDEX
        sta $4002

        ; If we triggered this frame, write unconditionally
        lda channel_status + PULSE_1_INDEX
        and #CHANNEL_TRIGGERED
        bne write_pulse1

        ; otherwise, to avoid resetting the sequence counter, only
        ; write if the high byte has changed since the last time
        lda channel_detuned_frequency_high + PULSE_1_INDEX
        cmp shadow_pulse1_freq_hi
        beq tick_pulse2

write_pulse1:
        lda channel_detuned_frequency_high + PULSE_1_INDEX
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
        bit channel_status + PULSE_2_INDEX
        bmi pulse2_muted

        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + PULSE_2_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + PULSE_2_INDEX
        tax
        lda volume_table, x

        ; add in the duty
        ora channel_instrument_duty + PULSE_2_INDEX
        ora #%00110000 ; set a duty, disable length counter and envelope
        sta $4004

        ; disable the sweep unit
        lda #$08
        sta $4005

        lda channel_detuned_frequency_low + PULSE_2_INDEX
        sta $4006

        ; If we triggered this frame, write unconditionally
        lda channel_status + PULSE_2_INDEX
        and #CHANNEL_TRIGGERED
        bne write_pulse2

        ; otherwise, to avoid resetting the sequence counter, only
        ; write if the high byte has changed since the last time
        lda channel_detuned_frequency_high + PULSE_2_INDEX
        cmp shadow_pulse2_freq_hi
        beq tick_triangle

write_pulse2:
        lda channel_detuned_frequency_high + PULSE_2_INDEX
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
        bit channel_status + TRIANGLE_INDEX
        bmi triangle_muted
        ; triangle additionally should mute here if either channel volume,
        ; or instrument volume is zero
        ; (but don't clobber a)
        ldx channel_volume + TRIANGLE_INDEX
        beq triangle_muted
        ldx channel_instrument_volume + TRIANGLE_INDEX
        beq triangle_muted

        lda #$FF
        sta $4008 ; timers to max

        lda channel_detuned_frequency_low + TRIANGLE_INDEX
        sta $400A
        lda channel_detuned_frequency_high + TRIANGLE_INDEX
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
        bit channel_status + NOISE_INDEX
        bmi noise_muted

        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + NOISE_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + NOISE_INDEX
        tax
        lda volume_table, x

        ora #%00110000 ; disable length counter and envelope
        sta $400C

        ; the low 4 bits of relative_frequency become the
        ; noise period
        lda channel_relative_frequency_low + NOISE_INDEX
        ; of *course* it's inverted
        sta scratch_byte
        lda #$10
        sec
        sbc scratch_byte
        and #%00001111
        sta scratch_byte

        ; the low bit of channel duty becomes mode bit 1
        lda channel_instrument_duty + NOISE_INDEX
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
        lda channel_status + PULSE_1_INDEX
        and #($FF - CHANNEL_TRIGGERED)
        sta channel_status + PULSE_1_INDEX

        lda channel_status + PULSE_2_INDEX
        and #($FF - CHANNEL_TRIGGERED)
        sta channel_status + PULSE_2_INDEX

        lda channel_status + TRIANGLE_INDEX
        and #($FF - CHANNEL_TRIGGERED)
        sta channel_status + TRIANGLE_INDEX

        lda channel_status + NOISE_INDEX
        and #($FF - CHANNEL_TRIGGERED)
        sta channel_status + NOISE_INDEX

        lda channel_status + DPCM_INDEX
        and #($FF - CHANNEL_TRIGGERED)
        sta channel_status + DPCM_INDEX

        rts
.endproc

.proc play_dpcm_samples
        lda channel_status + DPCM_INDEX
        and #(CHANNEL_MUTED | CHANNEL_RELEASED)
        bne dpcm_muted

        lda channel_status + DPCM_INDEX
        and #CHANNEL_TRIGGERED
        beq done

        ; using the current note, read the sample table
        prepare_ptr BHOP_MUSIC_BASE + FtModuleHeader::sample_list
        lda channel_base_note + DPCM_INDEX

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
        prepare_ptr BHOP_MUSIC_BASE + FtModuleHeader::samples
        ; the sample table should contain, in order:
        ; - location byte
        ; - size byte
        ; - bank to switch in
        lda (bhop_ptr), y
        iny
        sta $4012
        lda (bhop_ptr), y
        sta $4013

.if BHOP::BHOP_DPCM_BANKING
        iny
        lda (bhop_ptr), y
        jsr BHOP_DPCM_SWITCH_ROUTINE
.endif

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


