; Various structs, constants, and macros for use by the engine.
; This file is not needed by code which simply calls into the
; engine, to avoid polluting the global namespace.

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

PULSE_1_INDEX = 0
PULSE_2_INDEX = 1
TRIANGLE_INDEX = 2
NOISE_INDEX = 3
DPCM_INDEX = 4

; various status flags
CHANNEL_MUTED           = %10000000
CHANNEL_GLOBAL_DURATION = %01000000
CHANNEL_TRIGGERED       = %00100000

SEQUENCE_VOLUME  = %00000001
SEQUENCE_ARP     = %00000010
SEQUENCE_PITCH   = %00000100
SEQUENCE_HIPITCH = %00001000
SEQUENCE_DUTY    = %00010000

; for active effects (mostly unimplemented)
PITCH_EFFECT_ARP          = %00000001
PITCH_EFFECT_UP           = %00000010
PITCH_EFFECT_DOWN         = %00000100
PITCH_EFFECT_PORTAMENTO   = %00001000

ARP_MODE_ABSOLUTE = $00
ARP_MODE_FIXED =    $01
ARP_MODE_RELATIVE = $02
ARP_MODE_SCHEME =   $03

PITCH_MODE_RELATIVE = $00
PITCH_MODE_ABSOLUTE = $01

.struct ChannelState
        selected_instrument .byte
        pitch_effects_active .byte
        note_delay .byte
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

; various RAM and zeropage structures
.importzp bhop_ptr, channel_ptr, pattern_ptr, channel_index
.import pulse1_state, pulse2_state, triangle_state, noise_state, dpcm_state
.import row_counter, row_cmp, frame_counter, frame_cmp
.import channel_status, channel_global_duration, channel_row_delay_counter

.import sequences_enabled
.import sequences_active
.import volume_sequence_ptr_low
.import volume_sequence_ptr_high
.import volume_sequence_index
.import arpeggio_sequence_ptr_low
.import arpeggio_sequence_ptr_high
.import arpeggio_sequence_index
.import pitch_sequence_ptr_low
.import pitch_sequence_ptr_high
.import pitch_sequence_index
.import hipitch_sequence_ptr_low
.import hipitch_sequence_ptr_high
.import hipitch_sequence_index
.import duty_sequence_ptr_low
.import duty_sequence_ptr_high
.import duty_sequence_index

.import effect_note_delay

; various methods, mostly used by commands
.import load_instrument, dispatch_command
