.ifndef __BHOP_CONFIG
__BHOP_CONFIG = 1

; Configuration variables, adjust these to taste for your specific project

; Where should BHOP live?
.define BHOP_PLAYER_SEGMENT "PRG_8000"
.define BHOP_RAM_SEGMENT "RAM"
.define BHOP_ZP_SEGMENT "ZEROPAGE"

; Note: bhop currently requires just 6 bytes of zeropage. ALL of these bytes
; are temporary, so feel free to allocate them in your scratch region and
; clobber them freely between calls to bhop_play.

; Banking support. Disabled by default, as the relevant
; mapper code is project specific.
BHOP_PATTERN_BANKING = 0

.if ::BHOP_PATTERN_BANKING
.import bhop_apply_music_bank
BHOP_PATTERN_SWITCH_ROUTINE = bhop_apply_music_bank
.endif

; When DPCM bank switching is enabled, make sure the following
; routine is exported, preferably from one of your fixed
; code banks. Bhop will place the desired bank number in the
; A register before calling. It does not expect any registers
; or flags to be preserved.

BHOP_DPCM_BANKING = 0

.if ::BHOP_DPCM_BANKING
.import bhop_apply_dpcm_bank
BHOP_DPCM_SWITCH_ROUTINE = bhop_apply_dpcm_bank
.endif

; Options for different features that can be disabled to save space

BHOP_DELAYED_RELEASE_ENABLED = 1

; Toggle the following flags to enable various expansion channel types

BHOP_MMC5_ENABLED = 0

BHOP_VRC6_ENABLED = 0
    ; VRC6 variants for compatible mappers
    ; Only enable one of these at a time
    BHOP_VRC6_MAPPER24 = 0
    BHOP_VRC6_RAINBOW = 0

; virtual Z channel audio, mutually exclusive from DPCM sample playback
; concurrent Z-Saw and ZPCM is not supported (yet?).

BHOP_ZSAW_ENABLED = 0   ; generates custom waveforms using looping DPCM samples

BHOP_ZPCM_ENABLED = 0   ; outputs expansion audio to DPCM via inc $4011
    ; If using an advanced mapper that supports ZPCM, normally the DPCM channel is
    ; suppressed by the ZPCM activity. If you want to play DPCM samples, ZPCM must
    ; be temporarily disabled. Enable this feature if you want bhop to support this
    ; behavior, and provide your project-specific mechanism to temporarily disable
    ; and enable ZPCM updates by exporting the two symbols below. These routines
    ; will accept no arguments, and may clobber any registers.
    BHOP_ZPCM_CONFLICT_AVOIDANCE = 0

    .if ::BHOP_ZPCM_CONFLICT_AVOIDANCE
    .import bhop_enable_zpcm, bhop_disable_zpcm
    BHOP_ZPCM_ENABLE_ROUTINE = bhop_enable_zpcm
    BHOP_ZPCM_DISABLE_ROUTINE = bhop_disable_zpcm
    .endif

.endif ; __BHOP_CONFIG