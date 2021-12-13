; Configuration variables, adjust these to taste for your specific project

; Where should BHOP live?
.define BHOP_PLAYER_SEGMENT "PRG_8000"
.define BHOP_RAM_SEGMENT "RAM"
.define BHOP_ZP_SEGMENT "ZEROPAGE"

.import bhop_music_data, bhop_apply_dpcm_bank

; To play a module, export "music.asm" from FamiTracker, and
; place it in memory here. Ensure this memory is paged in
; during bhop_init and bhop_play.
BHOP_MUSIC_BASE = bhop_music_data

; DPCM banking support. Disabled by default, as the relevant
; mapper code is project specific.
BHOP_DPCM_BANKING = 1
BHOP_DPCM_SWITCH_ROUTINE = bhop_apply_dpcm_bank
