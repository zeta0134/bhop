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

.import bhop_music_data

; To play a module, export "music.asm" from FamiTracker, and
; place it in memory here. Ensure this memory is paged in
; during bhop_init and bhop_play.
BHOP_MUSIC_BASE = bhop_music_data

; Banking support. Disabled by default, as the relevant
; mapper code is project specific.
BHOP_DPCM_BANKING = 0
BHOP_PATTERN_BANKING = 0

; When DPCM bank switching is enabled, make sure the following
; routine is exported, preferably from one of your fixed
; code banks. Bhop will place the desired bank number in the
; A register before calling. It does not expect any registers
; or flags to be preserved.

.if ::BHOP_DPCM_BANKING
.import bhop_apply_dpcm_bank
BHOP_DPCM_SWITCH_ROUTINE = bhop_apply_dpcm_bank
.endif

.if ::BHOP_PATTERN_BANKING
.import bhop_apply_music_bank
BHOP_PATTERN_SWITCH_ROUTINE = bhop_apply_music_bank
.endif

; Toggle the following flags to enable various expansion channel types

BHOP_ZSAW_ENABLED = 0
BHOP_MMC5_ENABLED = 0

.endif ; __BHOP_CONFIG