.include "commands.inc"
.include "nes.inc"
.include "word_util.inc"

.macpack longbranch

.scope BHOP

MUSIC_BASE = $A000
SONG_LIST = MUSIC_BASE

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
        effective_volume .byte
        selected_instrument .byte
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
apu_status_shadow: .byte $00

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
        lda SONG_LIST
        sta bhop_ptr
        lda SONG_LIST+1
        sta bhop_ptr+1

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

.proc tick_instruments
tick_pulse1:
        ; we would mute all the channels
        lda #0
        sta apu_status_shadow

        ; completely hacky "let's hear the frequency" thing
        lda pulse1_state + ChannelState::status
        and #CHANNEL_MUTED
        bne tick_pulse2

        lda apu_status_shadow
        ora #%00000001
        sta apu_status_shadow

        ; for now let's use the channel volume? (sure why not)
        lda pulse1_state + ChannelState::channel_volume
        and #$0F
        ora #%00110000 ; set a duty, disable length counter and envelope
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

        lda apu_status_shadow
        ora #%00000010
        sta apu_status_shadow

        ; for now let's use the channel volume? (sure why not)
        lda pulse2_state + ChannelState::channel_volume
        and #$0F
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

        lda apu_status_shadow
        ora #%00000100
        sta apu_status_shadow

        lda #$FF
        sta $4008 ; timers to max

        lda triangle_state + ChannelState::base_frequency
        sta $400A
        lda triangle_state + ChannelState::base_frequency + 1
        sta $400B

cleanup:
        lda apu_status_shadow
        sta $4015

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
        jsr tick_instruments
        ; D:
        rts
.endproc

.endscope


