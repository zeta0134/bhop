.include "commands.inc"
.include "nes.inc"
.include "word_util.inc"

.macpack longbranch

.scope BHOP

MUSIC_BASE = $A000

.struct FtModuleHeader
        song_list .word
        instrument_list .word
        sample_list .word
        samples .word
        groove_list .word
        flags .byte
        ntsc_speed .word
        pal_speed .word
.endstruct

.struct SongInfo
        frame_list_ptr .word
        frame_count .byte
        pattern_length .byte
        speed .byte
        tempo .byte
        groove_position .byte
        initial_bank .byte
.endstruct

; various status flags
CHANNEL_MUTED           = %10000000
CHANNEL_GLOBAL_DURATION = %01000000
CHANNEL_TRIGGERED       = %00100000

SEQUENCE_VOLUME  = %00000001
SEQUENCE_ARP     = %00000010
SEQUENCE_PITCH   = %00000100
SEQUENCE_HIPITCH = %00001000
SEQUENCE_DUTY    = %00010000

.struct ChannelState
        pattern_ptr .word
        status .word
        global_duration .word
        row_delay_counter .byte
        base_note .byte
        base_frequency .byte
        relative_frequency .byte
        detuned_frequency .byte
        channel_volume .byte
        instrument_volume .byte
        instrument_duty .byte
        selected_instrument .byte
        sequences_enabled .byte
        sequences_active .byte
        volume_sequence_ptr .word
        volume_sequence_index .byte
        arpeggio_sequence_ptr .word
        arpeggio_sequence_index .byte
        pitch_sequence_ptr .word
        pitch_sequence_index .byte
        hipitch_sequence_ptr .word
        hipitch_sequence_index .byte
        duty_sequence_ptr .word
        duty_sequence_index .byte
.endstruct

.struct InstrumentHeader
        type .byte
        sequences_enabled .byte
        ; Note: there are 0-5 sequence pointers, based on the
        ; contents of sequences_enabled. This address is used
        ; as a starting point.
        sequence_ptr .word
.endstruct

.struct SequenceHeader
        length .byte
        loop_point .byte ; $FF disables loops
        release_point .byte ; $00 disables release points
        mode .byte ; various meanings depending on sequence type
.endstruct

        .zeropage
; scratch ptr, used for all sorts of indirect reads
bhop_ptr: .word $0000 
; pattern pointers, read repeatedly when updating
; rows in a loop, we'll want access to these to be quick
pattern_ptr: .word $0000
channel_ptr: .word $0000

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

        .segment "PRG0_8000"
        .export bhop_init, bhop_play

.include "midi_lut.inc"

.macro prepare_ptr address
        lda address
        sta bhop_ptr
        lda address+1
        sta bhop_ptr+1
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
        sta dpcm_state + ChannelState::channel_volume

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
        jsr advance_pattern_rows
        ; subtract tempo_cmp from tempo_counter
        sec
        lda tempo_counter
        sbc tempo_cmp
        sta tempo_counter
        lda tempo_counter+1
        sbc tempo_cmp+1
        sta tempo_counter+1
        ; advance the row counter and, if necessary, move to the next frame
        inc row_counter
        lda row_counter
        cmp row_cmp
        bcc done_advancing_rows
        ; row is equal or greater to max
        jsr advance_frame
        lda #0
        sta row_counter
done_advancing_rows:
        rts
.endproc

.macro fetch_pattern_byte
.scope
        ldy #0
        lda (pattern_ptr), y
        inc pattern_ptr
        bne done
        inc pattern_ptr+1
done:
.endscope
.endmacro

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
        jsr handle_extended_command
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

; setup: 
;   channel_ptr points to channel structure
;   pattern_ptr points to byte following command byte
;   a contains command byte
.proc handle_extended_command
        ; TODO: handle this more gracefully, I guess as a jump table?
        ; for now we just have a handful of special cases though

        ; command byte has the high bit set, which is not needed; eliminate it here
        and #$7F

        ; duration commands
        cmp #CommandBytes::CMD_SET_DURATION
        bne not_set_duration
        fetch_pattern_byte
        ldy #ChannelState::global_duration
        sta (channel_ptr), y
        ldy #ChannelState::status
        lda (channel_ptr), y
        ora #CHANNEL_GLOBAL_DURATION
        sta (channel_ptr), y
        jmp done_with_commands

not_set_duration:
        cmp #CommandBytes::CMD_RESET_DURATION
        bne not_reset_duration
        ldy #ChannelState::status
        lda (channel_ptr), y
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta (channel_ptr), y
        jmp done_with_commands

        ; our test song uses Bxx and it's somewhat important that we don't ignore
        ; it, so implement that here
not_reset_duration:
        cmp #CommandBytes::CMD_EFF_JUMP
        bne not_frame_jump
        fetch_pattern_byte
        sta frame_counter ; target frame counter
        lda row_cmp
        sta row_counter ; target row (so we immediately advance)
        ; but we haven't incremented either pointer yet! So decrement them
        ; both by 1, this way when we are done ticking rows, we end up where
        ; we want on the next one
        dec frame_counter ; the effect encodes target+1, we want target...
        dec frame_counter ; ... and one _less_ than target
        dec row_counter
        ; important: new frames expect to begin with global duration disabled;
        ; ordinarily the last note in a frame fixes this, but if we jump mid-way
        ; through a frame, we'll be in an inconsistent state. Fix it *now*, for
        ; *all* channels
        lda pulse1_state + ChannelState::status
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta pulse1_state + ChannelState::status

        lda pulse2_state + ChannelState::status
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta pulse2_state + ChannelState::status

        lda triangle_state + ChannelState::status
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta triangle_state + ChannelState::status

        lda noise_state + ChannelState::status
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta noise_state + ChannelState::status

        lda dpcm_state + ChannelState::status
        and #($FF - CHANNEL_GLOBAL_DURATION)
        sta dpcm_state + ChannelState::status

        sta (channel_ptr), y


        jmp done_with_commands

not_frame_jump:
        ; the following commands aren't handled yet, but we do need to
        ; detect them and intentionally not skip a parameter byte
        cmp #CommandBytes::CMD_HOLD
        beq done_with_commands
        cmp #CommandBytes::CMD_EFF_CLEAR
        beq done_with_commands
        cmp #CommandBytes::CMD_EFF_RESET_PITCH
        beq done_with_commands
        ; for every other command, still ignore it, but read one pattern
        ; byte and throw it away
        fetch_pattern_byte
        ; all done!
done_with_commands:
        rts
.endproc

.proc advance_pattern_rows
        ; PULSE 1
        lda #<pulse1_state
        sta channel_ptr
        lda #>pulse1_state
        sta channel_ptr+1
        jsr advance_channel_row

        ; PULSE 2
        lda #<pulse2_state
        sta channel_ptr
        lda #>pulse2_state
        sta channel_ptr+1
        jsr advance_channel_row

        ; TRIANGLE
        lda #<triangle_state
        sta channel_ptr
        lda #>triangle_state
        sta channel_ptr+1
        jsr advance_channel_row

        rts
.endproc

.proc tick_envelopes
        ; PULSE 1
        lda #<pulse1_state
        sta channel_ptr
        lda #>pulse1_state
        sta channel_ptr+1
        jsr tick_volume_envelope
        jsr tick_duty_envelope

        ; PULSE 2
        lda #<pulse2_state
        sta channel_ptr
        lda #>pulse2_state
        sta channel_ptr+1
        jsr tick_volume_envelope
        jsr tick_duty_envelope

        ; TRIANGLE
        lda #<triangle_state
        sta channel_ptr
        lda #>triangle_state
        sta channel_ptr+1
        jsr tick_volume_envelope

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
        ldy #ChannelState::sequences_enabled
        sta (channel_ptr), y
        tax ; stash

        ; for every enabled sequence, load the appropriate pointer
        clc
        add16 bhop_ptr, #InstrumentHeader::sequence_ptr
        txa ; unstash
check_volume:
        lsr
        bcc check_arp

        tax ; stash
        ldy #0
        lda (bhop_ptr), y
        ldy #ChannelState::volume_sequence_ptr
        sta (channel_ptr), y
        ldy #1
        lda (bhop_ptr), y
        ldy #ChannelState::volume_sequence_ptr + 1
        sta (channel_ptr), y
        clc
        add16 bhop_ptr, #2 ; advance one word
        txa ; unstash
check_arp:
        lsr
        bcc check_pitch

        tax ; stash
        ldy #0
        lda (bhop_ptr), y
        ldy #ChannelState::arpeggio_sequence_ptr
        sta (channel_ptr), y
        ldy #1
        lda (bhop_ptr), y
        ldy #ChannelState::arpeggio_sequence_ptr + 1
        sta (channel_ptr), y
        clc
        add16 bhop_ptr, #2 ; advance one word
        txa ; unstash

check_pitch:
        lsr
        bcc check_hipitch

        tax ; stash
        ldy #0
        lda (bhop_ptr), y
        ldy #ChannelState::pitch_sequence_ptr
        sta (channel_ptr), y
        ldy #1
        lda (bhop_ptr), y
        ldy #ChannelState::pitch_sequence_ptr + 1
        sta (channel_ptr), y
        clc
        add16 bhop_ptr, #2 ; advance one word
        txa ; unstash

check_hipitch:
        lsr
        bcc check_duty

        tax ; stash
        ldy #0
        lda (bhop_ptr), y
        ldy #ChannelState::hipitch_sequence_ptr
        sta (channel_ptr), y
        ldy #1
        lda (bhop_ptr), y
        ldy #ChannelState::hipitch_sequence_ptr + 1
        sta (channel_ptr), y
        clc
        add16 bhop_ptr, #2 ; advance one word
        txa ; unstash

check_duty:
        lsr
        bcc done_loading_sequences

        ; no more need to stash
        ldy #0
        lda (bhop_ptr), y
        ldy #ChannelState::duty_sequence_ptr
        sta (channel_ptr), y
        ldy #1
        lda (bhop_ptr), y
        ldy #ChannelState::duty_sequence_ptr + 1
        sta (channel_ptr), y

done_loading_sequences:
        jsr reset_instrument
        rts
.endproc

; Re-initializes sequence pointers back to the beginning of their
; respective envelopes
; setup: 
;   channel_ptr points to channel structure
.proc reset_instrument
        lda #0
        ldy #ChannelState::volume_sequence_index
        sta (channel_ptr), y
        ldy #ChannelState::arpeggio_sequence_index
        sta (channel_ptr), y
        ldy #ChannelState::pitch_sequence_index
        sta (channel_ptr), y
        ldy #ChannelState::hipitch_sequence_index
        sta (channel_ptr), y
        ldy #ChannelState::duty_sequence_index
        sta (channel_ptr), y

        ; when a sequence ends it terminates itself in sequences_active, so re-initialize
        ; that byte here
        ldy #ChannelState::sequences_enabled
        lda (channel_ptr), y
        ldy #ChannelState::sequences_active
        sta (channel_ptr), y

        rts
.endproc

; If this channel has a volume envelope active, process that
; envelope. Upon return, instrument_volume will have the current
; element in the sequence.
; setup: 
;   channel_ptr points to channel structure
.proc tick_volume_envelope
        ldy #ChannelState::sequences_active
        lda (channel_ptr), y
        and #SEQUENCE_VOLUME
        beq done ; if volume sequence isn't enabled, bail fast

        ; prepare the volume pointer for reading
        ldy #ChannelState::volume_sequence_ptr
        lda (channel_ptr), y
        sta bhop_ptr
        iny
        lda (channel_ptr), y
        sta bhop_ptr + 1

        ; read the current sequence byte, and set instrument_volume to this
        ldy #ChannelState::volume_sequence_index
        lda (channel_ptr), y
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
        ldy #ChannelState::sequences_active
        lda (channel_ptr), y
        and #($FF - SEQUENCE_VOLUME)
        sta (channel_ptr), y
        rts

end_not_reached:
        ; write the new sequence index (should be in x)
        ldy #ChannelState::volume_sequence_index
        txa
        sta (channel_ptr), y

done:
        rts
.endproc

; If this channel has a duty envelope active, process that
; envelope. Upon return, instrument_duty is set
; setup: 
;   channel_ptr points to channel structure
.proc tick_duty_envelope
        ldy #ChannelState::sequences_active
        lda (channel_ptr), y
        and #SEQUENCE_DUTY
        beq done ; if sequence isn't enabled, bail fast

        ; prepare the duty pointer for reading
        ldy #ChannelState::duty_sequence_ptr
        lda (channel_ptr), y
        sta bhop_ptr
        iny
        lda (channel_ptr), y
        sta bhop_ptr + 1

        ; read the current sequence byte, and set instrument_volume to this
        ldy #ChannelState::duty_sequence_index
        lda (channel_ptr), y
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
        ldy #ChannelState::sequences_active
        lda (channel_ptr), y
        and #($FF - SEQUENCE_DUTY)
        sta (channel_ptr), y
        rts

end_not_reached:
        ; write the new sequence index (should still be in x)
        ldy #ChannelState::duty_sequence_index
        txa
        sta (channel_ptr), y

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

.proc tick_instruments
tick_pulse1:
        ; first, check for muted channels and adjust the status register
        ; (this must come first, otherwise writes to individual registers
        ; for new note triggers are ignored)
        lda #0
        bit pulse1_state + ChannelState::status
        bmi pulse1_muted
        ora #%00000001
pulse1_muted:
        bit pulse2_state + ChannelState::status
        bmi pulse2_muted
        ora #%00000010
pulse2_muted:
        bit triangle_state + ChannelState::status
        bmi triangle_muted
        ; triangle additionally should mute here if either channel volume,
        ; or instrument volume is zero
        ; (but don't clobber a)
        ldx triangle_state + ChannelState::channel_volume
        beq triangle_muted
        ldx triangle_state + ChannelState::instrument_volume
        beq triangle_muted
        ora #%00000100
triangle_muted:
        sta $4015

        ; completely hacky "let's hear the frequency" thing
        lda pulse1_state + ChannelState::status
        and #CHANNEL_MUTED
        bne tick_pulse2

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

        lda pulse1_state + ChannelState::base_frequency
        sta $4002

        ; If we triggered this frame, write unconditionally
        lda pulse1_state + ChannelState::status
        and #CHANNEL_TRIGGERED
        bne write_pulse1

        ; otherwise, to avoid resetting the sequence counter, only
        ; write if the high byte has changed since the last time
        lda pulse1_state + ChannelState::base_frequency + 1
        cmp shadow_pulse1_freq_hi
        beq tick_pulse2

write_pulse1:
        lda pulse1_state + ChannelState::base_frequency + 1
        sta shadow_pulse1_freq_hi
        ora #%11111000
        sta $4003

tick_pulse2:
        lda pulse2_state + ChannelState::status
        and #CHANNEL_MUTED
        bne tick_triangle

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

        lda pulse2_state + ChannelState::base_frequency
        sta $4006

        ; If we triggered this frame, write unconditionally
        lda pulse2_state + ChannelState::status
        and #CHANNEL_TRIGGERED
        bne write_pulse2

        ; otherwise, to avoid resetting the sequence counter, only
        ; write if the high byte has changed since the last time
        lda pulse2_state + ChannelState::base_frequency + 1
        cmp shadow_pulse2_freq_hi
        beq tick_triangle

write_pulse2:
        lda pulse2_state + ChannelState::base_frequency + 1
        sta shadow_pulse2_freq_hi
        ora #%11111000
        sta $4007

tick_triangle:
        lda triangle_state + ChannelState::status
        and #CHANNEL_MUTED
        bne cleanup

        lda #$FF
        sta $4008 ; timers to max

        lda triangle_state + ChannelState::base_frequency
        sta $400A
        lda triangle_state + ChannelState::base_frequency + 1
        sta $400B

cleanup:
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

        rts
.endproc

.proc bhop_play
        jsr tick_frame_counter
        jsr tick_envelopes
        jsr tick_instruments
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


