__BHOP_CONFIG = 1

; Demo-specific config for Rainbow VRC6 ZPCM

; WARNING: This copy of bhop/config.inc is used to override the project
; defaults. Do not rely on any of its contents, as it may be somewhat out of sync
; with the main config located at bhop/config.inc in the project root.

; Where should BHOP live?
.define BHOP_PLAYER_SEGMENT "BHOP"
.define BHOP_RAM_SEGMENT "RAM"
.define BHOP_ZP_SEGMENT "ZEROPAGE"

BHOP_PATTERN_BANKING = 1

.if ::BHOP_PATTERN_BANKING
.import bhop_apply_music_bank
BHOP_PATTERN_SWITCH_ROUTINE = bhop_apply_music_bank
.endif

BHOP_DPCM_BANKING = 1

.if ::BHOP_DPCM_BANKING
.import bhop_apply_dpcm_bank
BHOP_DPCM_SWITCH_ROUTINE = bhop_apply_dpcm_bank
.endif

; Options for different features that can be disabled to save space

BHOP_DELAYED_RELEASE_ENABLED = 1

BHOP_PITCH_DETUNE_CLAMP_ENABLED = 1

BHOP_MMC5_ENABLED = 0

BHOP_VRC6_ENABLED = 1
    ; VRC6 variants for compatible mappers
    ; Only enable one of these at a time
    BHOP_VRC6_MAPPER24 = 0
    BHOP_VRC6_RAINBOW = 1

BHOP_ZSAW_ENABLED = 0

BHOP_ZPCM_ENABLED = 1
    BHOP_ZPCM_CONFLICT_AVOIDANCE = 1

    .if ::BHOP_ZPCM_CONFLICT_AVOIDANCE
    .import bhop_enable_zpcm, bhop_disable_zpcm
    BHOP_ZPCM_ENABLE_ROUTINE = bhop_enable_zpcm
    BHOP_ZPCM_DISABLE_ROUTINE = bhop_disable_zpcm
    .endif

; The following chips below are not yet implemented
; if you enable them, they will not read nor write any data associated

BHOP_N163_ENABLED = 0
BHOP_FDS_ENABLED  = 0
BHOP_S5B_ENABLED  = 0
BHOP_VRC7_ENABLED = 0

; Toggle to enable multiple expansion audio chips at once
; at the cost of needing a byte in bss to declare which expansion audio types are used

BHOP_MULTICHIP = 0
