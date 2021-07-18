; Configuration variables, adjust these to taste for your specific project

; To play a module, export "music.asm" from FamiTracker, and
; place it in memory here. Ensure this memory is paged in
; during bhop_init and bhop_play.
MUSIC_BASE = $A000

.import bhop_init, bhop_play
