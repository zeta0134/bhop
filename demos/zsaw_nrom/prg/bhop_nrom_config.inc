__BHOP_CONFIG = 1

; Demo-specific config for NROM + ZSAW

; WARNING: This copy of bhop/config.inc is used to override the project
; defaults. Do not rely on any of its contents, as it may be somewhat out of sync
; with the main config located at bhop/config.inc in the project root.

.define BHOP_PLAYER_SEGMENT "PRG0_8000"
.define BHOP_RAM_SEGMENT "RAM"
.define BHOP_ZP_SEGMENT "ZEROPAGE"

BHOP_DPCM_BANKING = 0

.if ::BHOP_DPCM_BANKING
.import bhop_apply_dpcm_bank
BHOP_DPCM_SWITCH_ROUTINE = bhop_apply_dpcm_bank
.endif

BHOP_PATTERN_BANKING = 0

.if ::BHOP_PATTERN_BANKING
.import bhop_apply_music_bank
BHOP_PATTERN_SWITCH_ROUTINE = bhop_apply_music_bank
.endif

BHOP_ZSAW_ENABLED = 1
BHOP_MMC5_ENABLED = 0

; For ZSAW purposes, we need to override that config file as well
__ZSAW_CONFIG = 1

.define ZSAW_ZP_SEGMENT "ZEROPAGE"
.define ZSAW_FIXED_SEGMENT "PRG1_C000"
.define ZSAW_SAMPLES_SEGMENT "PRG1_C000"
ZSAW_SHADOW_OAM = $02
.define ZSAW_NMI_GAME_HANDLER demo_nmi

.globalzp zsaw_oam_pending, zsaw_nmi_pending
.global zsaw_irq, zsaw_nmi
.global zsaw_init, zsaw_play_note, zsaw_silence, zsaw_set_timbre, zsaw_set_volume

.global zsquare_irq

; Because we override the entire config file, we must include all constants
ZSAW_TIMBRE_SAW = 0
ZSAW_TIMBRE_SAW_00 = 0
ZSAW_TIMBRE_SAW_7F = 1
ZSAW_TIMBRE_SQUARE = 2
ZSAW_TIMBRE_SQUARE_00 = 2
ZSAW_TIMBRE_SQUARE_7F = 3
ZSAW_TIMBRE_TRIANGLE = 4

ZSAW_B1  = 0
ZSAW_C2  = 1
ZSAW_CS2 = 2
ZSAW_D2  = 3
ZSAW_DS2 = 4
ZSAW_E2  = 5
ZSAW_F2  = 6
ZSAW_FS2 = 7
ZSAW_G2  = 8
ZSAW_GS2 = 9
ZSAW_A2  = 10
ZSAW_AS2 = 11
ZSAW_B2  = 12
ZSAW_C3  = 13
ZSAW_CS3 = 14
ZSAW_D3  = 15
ZSAW_DS3 = 16
ZSAW_E3  = 17
ZSAW_F3  = 18
ZSAW_FS3 = 19
ZSAW_G3  = 20
ZSAW_GS3 = 21
ZSAW_A3  = 22
ZSAW_AS3 = 23
ZSAW_B3  = 24
ZSAW_C4  = 25
ZSAW_CS4 = 26
ZSAW_D4  = 27
ZSAW_DS4 = 28
ZSAW_E4  = 29
ZSAW_F4  = 30
ZSAW_FS4 = 31
ZSAW_G4  = 32
ZSAW_GS4 = 33
ZSAW_A4  = 34
ZSAW_AS4 = 35
ZSAW_B4  = 36
ZSAW_C5  = 37
ZSAW_CS5 = 38
ZSAW_D5  = 39
ZSAW_DS5 = 40
ZSAW_E5  = 41
ZSAW_F5  = 42
ZSAW_FS5 = 43
ZSAW_G5  = 44
ZSAW_GS5 = 45
ZSAW_A5  = 46
ZSAW_AS5 = 47
ZSAW_B5  = 48
ZSAW_C6  = 49
ZSAW_CS6 = 50
ZSAW_D6  = 51
ZSAW_DS6 = 52
ZSAW_E6  = 53
ZSAW_F6  = 54
ZSAW_FS6 = 55
ZSAW_G6  = 56
ZSAW_GS6 = 57
ZSAW_A6  = 58
ZSAW_AS6 = 59
ZSAW_B6  = 60
ZSAW_C7  = 61
ZSAW_CS7 = 62
ZSAW_D7  = 63
ZSAW_DS7 = 64
ZSAW_E7  = 65
ZSAW_F7  = 66
ZSAW_FS7 = 67
ZSAW_G7  = 68
ZSAW_GS7 = 69
ZSAW_A7  = 70
ZSAW_AS7 = 71
ZSAW_B7  = 72
ZSAW_C8  = 73

ZSAW_MINIMUM_INDEX = ZSAW_B1
ZSAW_MAXIMUM_INDEX = ZSAW_C8