.ifndef __BHOP_CONFIG
__BHOP_CONFIG = 1

.include "option_util.inc"

; Configuration variables, adjust these to taste for your specific project

; Where should BHOP live?
.if .xmatch(BHOP_PLAYER_SEGMENT, "BHOP_PLAYER_SEGMENT")
.define BHOP_PLAYER_SEGMENT "PRG_8000"
.endif
.if .xmatch(BHOP_RAM_SEGMENT, "BHOP_RAM_SEGMENT")
.define BHOP_RAM_SEGMENT "RAM"
.endif
.if .xmatch(BHOP_ZP_SEGMENT, "BHOP_ZP_SEGMENT")
.define BHOP_ZP_SEGMENT "ZEROPAGE"
.endif

; Note: bhop currently requires just 6 bytes of zeropage. ALL of these bytes
; are temporary, so feel free to allocate them in your scratch region and
; clobber them freely between calls to bhop_play.

; Banking support. Disabled by default, as the relevant
; mapper code is project specific.
__bool_option BHOP_PATTERN_BANKING

.if ::BHOP_PATTERN_BANKING
.ifndef bhop_apply_music_bank
.import bhop_apply_music_bank
.endif
BHOP_PATTERN_SWITCH_ROUTINE = bhop_apply_music_bank
.endif

; When DPCM bank switching is enabled, make sure the following
; routine is exported, preferably from one of your fixed
; code banks. Bhop will place the desired bank number in the
; A register before calling. It does not expect any registers
; or flags to be preserved.

__bool_option BHOP_DPCM_BANKING

.if ::BHOP_DPCM_BANKING
.ifndef bhop_apply_dpcm_bank
.import bhop_apply_dpcm_bank
.endif
BHOP_DPCM_SWITCH_ROUTINE = bhop_apply_dpcm_bank
.endif

; Options for different features that can be disabled to save space

__bool_option BHOP_DELAYED_RELEASE_ENABLED, 1

__bool_option BHOP_PITCH_DETUNE_CLAMP_ENABLED, 1

; Toggle the following flags to enable various expansion channel types

__bool_option BHOP_MMC5_ENABLED

__bool_option BHOP_VRC6_ENABLED
    ; VRC6 variants for compatible mappers
    ; Only enable one of these at a time
    __bool_option BHOP_VRC6_MAPPER24
    __bool_option BHOP_VRC6_RAINBOW

; virtual Z channel audio, mutually exclusive from DPCM sample playback
; concurrent Z-Saw and ZPCM is not supported (yet?).

__bool_option BHOP_ZSAW_ENABLED   ; generates custom waveforms using looping DPCM samples

__bool_option BHOP_ZPCM_ENABLED   ; outputs expansion audio to DPCM via inc $4011
    ; If using an advanced mapper that supports ZPCM, normally the DPCM channel is
    ; suppressed by the ZPCM activity. If you want to play DPCM samples, ZPCM must
    ; be temporarily disabled. Enable this feature if you want bhop to support this
    ; behavior, and provide your project-specific mechanism to temporarily disable
    ; and enable ZPCM updates by exporting the two symbols below. These routines
    ; will accept no arguments, and may clobber any registers.
    __bool_option BHOP_ZPCM_CONFLICT_AVOIDANCE

    .if ::BHOP_ZPCM_CONFLICT_AVOIDANCE
    .import bhop_enable_zpcm, bhop_disable_zpcm
    BHOP_ZPCM_ENABLE_ROUTINE = bhop_enable_zpcm
    BHOP_ZPCM_DISABLE_ROUTINE = bhop_disable_zpcm
    .endif

; The following chips below are not yet implemented
; if you enable them, they will not read nor write any data associated

__bool_option BHOP_N163_ENABLED
__bool_option BHOP_FDS_ENABLED
__bool_option BHOP_S5B_ENABLED
__bool_option BHOP_VRC7_ENABLED

; Toggle to enable multiple expansion audio chips at once
; at the cost of needing a byte in bss to determine which expansion audio types are used

__bool_option BHOP_MULTICHIP

.endif ; __BHOP_CONFIG