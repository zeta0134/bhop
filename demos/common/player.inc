.struct MusicTrack
        ModulePtr .word
        BankNumber .byte
        TrackNumber .byte
        TitleStringPtr .word
        ArtistStringPtr .word
.endstruct

.global player_init
.global player_update

; Note: be sure the demo scaffolding defines all of these
.global music_track_count
.global music_track_table
.global player_bank_music
.global player_bank_samples

; This macro helps to make the track list less stupid

.macro music_track module_ptr, bank_number, track_number, title_string, artist_string
.scope
.addr module_ptr
.byte bank_number
.byte track_number
.addr title_str
.addr artist_str
title_str: .asciiz title_string
artist_str: .asciiz artist_string
.endscope
.endmacro
