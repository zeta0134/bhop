__BHOP_CONFIG = 1 ; should break the build by failing to define directives

; Demo-specific config for NROM + ZSAW

; WARNING: This copy of bhop/config.inc is used to override the project
; defaults. Do not rely on any of its contents, as it may be somewhat out of sync
; with the main config located at bhop/config.inc in the project root.

; Where should BHOP live?
.define BHOP_PLAYER_SEGMENT "BHOP"
.define BHOP_RAM_SEGMENT "RAM"
.define BHOP_ZP_SEGMENT "ZEROPAGE"

.import bhop_music_data

; To play a module, export "music.asm" from FamiTracker, and
; place it in memory here. Ensure this memory is paged in
; during bhop_init and bhop_play.
BHOP_MUSIC_BASE = bhop_music_data

; DPCM banking support. Disabled by default, as the relevant
; mapper code is project specific.
BHOP_DPCM_BANKING = 0

; When DPCM bank switching is enabled, make sure the following
; routine is exported, preferably from one of your fixed
; code banks. Bhop will place the desired bank number in the
; A register before calling. It does not expect any registers
; or flags to be preserved.

.if ::BHOP_DPCM_BANKING
.import bhop_apply_dpcm_bank
BHOP_DPCM_SWITCH_ROUTINE = bhop_apply_dpcm_bank
.endif

BHOP_ZSAW_ENABLED = 1

; For ZSAW purposes, we need to override that config file as well
__ZSAW_CONFIG = 1

; Z-Saw requires 11 bytes in zeropage
.define ZSAW_ZP_SEGMENT "ZEROPAGE"
; interrupt vectors and lookup tables
.define ZSAW_FIXED_SEGMENT "CODE"
.define ZSAW_SAMPLES_SEGMENT "CODE"
; Shadow OAM high page, for OAM DMA
ZSAW_SHADOW_OAM = $02
; Your custom NMI handler, will be called automatically when vblank begins
; Note: 
;   - Do not perform OAM DMA, Z-Saw will handle that for you
;   - Interrupts will be enabled upon entry
;   - DO remember to preserve registers
;   - Return with rts, not rti
.define ZSAW_NMI_GAME_HANDLER demo_nmi

.globalzp zsaw_oam_pending, zsaw_nmi_pending
.global zsaw_irq, zsaw_nmi
.global zsaw_init, zsaw_play_note, zsaw_silence, zsaw_set_timbre, zsaw_set_volume

.global zsquare_irq

; Available timbres; see README for details and limitations
ZSAW_TIMBRE_SAW = 0
ZSAW_TIMBRE_SAW_00 = 0
ZSAW_TIMBRE_SAW_7F = 1
ZSAW_TIMBRE_SQUARE = 2
ZSAW_TIMBRE_SQUARE_00 = 2
ZSAW_TIMBRE_SQUARE_7F = 3
ZSAW_TIMBRE_TRIANGLE = 4

; Music defines, for manually playing notes
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