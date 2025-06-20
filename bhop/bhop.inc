; These functions will be made available to your programs.
; All other symbols reside in the BHOP scope and, by default,
; will not pollute the global namespace.

.import bhop_init, bhop_play, bhop_pause, bhop_unpause
.import bhop_set_module_bank
.import bhop_set_expansion_flags
.import bhop_mute_channel, bhop_unmute_channel, blarggsaw_irq, zetasaw_irq
