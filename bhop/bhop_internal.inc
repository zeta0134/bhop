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

_channel_index .set 0

PULSE_1_INDEX = _channel_index
_channel_index .set (_channel_index+1)

PULSE_2_INDEX = _channel_index
_channel_index .set (_channel_index+1)

TRIANGLE_INDEX = _channel_index
_channel_index .set (_channel_index+1)

NOISE_INDEX = _channel_index
_channel_index .set (_channel_index+1)

.if ::BHOP_ZSAW_ENABLED
ZSAW_INDEX = _channel_index
_channel_index .set (_channel_index+1)
.endif

.if ::BHOP_MMC5_ENABLED
MMC5_PULSE_1_INDEX = _channel_index
_channel_index .set (_channel_index+1)

MMC5_PULSE_2_INDEX = _channel_index
_channel_index .set (_channel_index+1)
.endif

DPCM_INDEX = _channel_index
_channel_index .set (_channel_index+1)

NUM_CHANNELS = _channel_index

; various status flags
CHANNEL_MUTED             = %10000000
CHANNEL_GLOBAL_DURATION   = %01000000
CHANNEL_TRIGGERED         = %00100000
CHANNEL_RELEASED          = %00010000
CHANNEL_SUPPRESSED        = %00001000
CHANNEL_FRESH_DELAYED_CUT = %00000100

SEQUENCE_VOLUME  = %00000001
SEQUENCE_ARP     = %00000010
SEQUENCE_PITCH   = %00000100
SEQUENCE_HIPITCH = %00001000
SEQUENCE_DUTY    = %00010000

; for active effects
PITCH_EFFECT_UP           = %00000001
PITCH_EFFECT_DOWN         = %00000010
PITCH_EFFECT_PORTAMENTO   = %00000100
PITCH_EFFECT_NOTE_UP      = %00001000
PITCH_EFFECT_NOTE_DOWN    = %00010000
PITCH_EFFECT_ARP          = %00100000
PITCH_EFFECT_TRIGGERED    = %10000000

ARP_MODE_ABSOLUTE = $00
ARP_MODE_FIXED =    $01
ARP_MODE_RELATIVE = $02
ARP_MODE_SCHEME =   $03

PITCH_MODE_RELATIVE = $00
PITCH_MODE_ABSOLUTE = $01

MODULE_FLAGS_PATTERN_BANKING = %00000001

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

; note: target bank in A
; MUST assume all registers are clobbered
.macro switch_music_bank
.scope
        cmp current_music_bank
        beq all_done
        sta current_music_bank
        jsr BHOP_PATTERN_SWITCH_ROUTINE
all_done:
.endscope
.endmacro

; Inline collections of utility macros from various sources, collected here
; to reduce the number of individual files needed for the sound driver to be
; included in another project

; =============================================
;   bhop_commands.inc
; =============================================

.enum CommandBytes
    CMD_INSTRUMENT
    CMD_HOLD
    CMD_SET_DURATION
    CMD_RESET_DURATION
    CMD_EFF_SPEED
    CMD_EFF_TEMPO
    CMD_EFF_JUMP
    CMD_EFF_SKIP
    CMD_EFF_HALT
    CMD_EFF_VOLUME
    CMD_EFF_CLEAR
    CMD_EFF_PORTAUP
    CMD_EFF_PORTADOWN
    CMD_EFF_PORTAMENTO
    CMD_EFF_ARPEGGIO
    CMD_EFF_VIBRATO
    CMD_EFF_TREMOLO
    CMD_EFF_PITCH
    CMD_EFF_RESET_PITCH
    CMD_EFF_DUTY
    CMD_EFF_DELAY
    CMD_EFF_SWEEP
    CMD_EFF_DAC
    CMD_EFF_OFFSET
    CMD_EFF_SLIDE_UP
    CMD_EFF_SLIDE_DOWN
    CMD_EFF_VOL_SLIDE
    CMD_EFF_NOTE_CUT
    CMD_EFF_RETRIGGER
    CMD_EFF_DPCM_PITCH
    CMD_EFF_NOTE_RELEASE
    CMD_EFF_LINEAR_COUNTER
    CMD_EFF_GROOVE
    CMD_EFF_DELAYED_VOLUME
    CMD_EFF_TRANSPOSE
    CMD_EFF_VRC7_PATCH
    CMD_EFF_VRC7_PORT
    CMD_EFF_VRC7_WRITE
    CMD_EFF_FDS_MOD_DEPTH
    CMD_EFF_FDS_MOD_RATE_HI
    CMD_EFF_FDS_MOD_RATE_LO
    CMD_EFF_FDS_VOLUME
    CMD_EFF_FDS_MOD_BIAS
    CMD_EFF_N163_WAVE_BUFFER
    CMD_EFF_S5B_ENV_TYPE
    CMD_EFF_S5B_ENV_RATE_HI
    CMD_EFF_S5B_ENV_RATE_LO
    CMD_EFF_S5B_NOISE
.endenum


; =============================================
;   word_util.inc
; =============================================

.macro st16 addr, value
        lda #<value
        sta addr
        lda #>value
        sta addr+1
.endmacro

.macro inc16 addr
.scope
        inc addr
        bne no_carry
        inc addr+1
no_carry:
.endscope
.endmacro

.macro dec16 addr
.scope
        bit addr 
        dec addr
        lda #$FF
        cmp addr
        bne no_carry
        dec addr+1
no_carry:
.endscope
.endmacro

.macro mov16 destination, source
        lda source
        sta destination
        lda source+1
        sta destination+1
.endmacro

; unsigned
.macro add16 addr, value
        lda value
        adc addr
        sta addr
        lda #0
        adc addr+1
        sta addr+1
.endmacro

; for when the value to add is already in a (clobbers a)
.macro add16a addr
        adc addr
        sta addr
        lda #0
        adc addr+1
        sta addr+1
.endmacro

; signed
.macro sadd16 addr, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc addr
        sta addr
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc addr+1
        sta addr+1

.endscope
.endmacro

; same as above, but the value to add is already in a
; (useful in situations where A came from somewhere unusual)
.macro sadd16a addr
.scope
        ; preserve a
        pha
        ; handle the low byte normally
        clc
        adc addr
        sta addr
        ; sign-extend the high bit into the high byte
        pla
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc addr+1
        sta addr+1
.endscope
.endmacro

; signed, with x offset on the addr
.macro sadd16x addr, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc addr, x
        sta addr, x
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc addr+1, x
        sta addr+1, x

.endscope
.endmacro

; signed, with y offset on the addr
.macro sadd16y addr, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc addr, y
        sta addr, y
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc addr+1, y
        sta addr+1, y

.endscope
.endmacro

; add a signed byte, stored in value, to a 16bit word
; whose component bytes are stored in the provided tables, and
; indexed by x
; clobbers a, flags
.macro sadd16_split_x low_table, high_table, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc low_table, x
        sta low_table, x
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc high_table, x
        sta high_table, x
.endscope
.endmacro

; add a signed byte, stored in value, to a 16bit word
; whose component bytes are stored in the provided tables, and
; indexed by y
; clobbers a, flags
.macro sadd16_split_y low_table, high_table, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc low_table, y
        sta low_table, y
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc high_table, y
        sta high_table, y
.endscope
.endmacro

.macro sub16 addr, value
        lda addr
        sbc value
        sta addr
        lda addr+1
        sbc #0
        sta addr+1
.endmacro

