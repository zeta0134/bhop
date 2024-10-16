        .setcpu "6502"

        .include "../../common/nes.inc"
        .include "../../../bhop/bhop.inc"
        .include "../../common/word_util.inc"

        .include "nsf.inc"

        .zeropage
CurrentTrack: .res 1
RegionType: .res 1
NonReturnInit: .res 1
TrackPtr: .res 2

ScratchPtr: .res 2
ScratchWord: .res 2
ScratchByte: .res 1

        .segment "RAM"

        .segment "MUSIC_0"
        .proc MODULE_0
        .include "../music/in_this_together.asm"
        ;.include "../music/sxx.asm"
        .endproc

        .segment "MUSIC_1"
        .proc MODULE_1
        .include "../music/virus-busting.asm"
        .endproc

        .segment "MUSIC_2"
        .proc MODULE_2
        .include "../music/world-1-1.asm"
        .endproc

        .segment "MUSIC_3"
        .proc MODULE_3
        .include "../music/yakra.asm"
        .endproc

        .segment "MUSIC_4"
        .proc MODULE_4
        .include "../music/nsmb.asm"
        .endproc

        .segment "MUSIC_5"
        .proc MODULE_5
        .include "../music/sanctuary.asm"
        .endproc

        .segment "MUSIC_6"
        .proc MODULE_6
        .include "../music/gato.asm"
        .endproc

        .segment "MUSIC_7"
        .proc MODULE_7
        .include "../music/simian_segue.asm"
        .endproc
        
        .segment "MUSIC_8"
        .proc MODULE_8
        .include "../music/sotn_stage1.asm"
        .endproc
        
        .segment "MUSIC_9"
        .proc MODULE_9
        .include "../music/tactus.asm"
        .endproc

        .segment "MUSIC_10"
        .proc MODULE_10
        .include "../music/brain_age.asm"
        .endproc

        .segment "MUSIC_11"
        .proc MODULE_11
        .include "../music/in_another_world_(head_in_the_clouds)_vrc6.asm"
        .endproc

        .segment "CODE"

.proc nsf_init
        sta CurrentTrack
        stx RegionType
        sty NonReturnInit

        jsr initialize_current_track_nsf
        rts
.endproc

.export nsf_init

; modified essential handler subroutines from player.s

.macro music_track_nsf module_ptr, bank_number, track_number, expansion_flags
.scope
.addr module_ptr
.byte bank_number
.byte track_number
.byte expansion_flags
.endscope
.endmacro

.struct MusicTrackNSF
        ModulePtr .word
        BankNumber .byte
        TrackNumber .byte
        ExpansionFlags .byte
.endstruct

.proc initialize_current_track_nsf
        lda CurrentTrack
        asl
        tax
        lda music_track_table+0, x
        sta TrackPtr+0
        lda music_track_table+1, x
        sta TrackPtr+1

        ldy #MusicTrackNSF::ExpansionFlags
        lda (TrackPtr), y
        jsr bhop_set_expansion_flags

        ldy #MusicTrackNSF::BankNumber
        lda (TrackPtr), y
        jsr bhop_set_module_bank
        jsr bhop_apply_music_bank

        ldy #MusicTrackNSF::TrackNumber
        lda (TrackPtr), y
        pha ; store the track number and reload it after loading the address for the song
        ldy #MusicTrackNSF::ModulePtr
        lda (TrackPtr), y
        tax ; lo ptr for the module address
        iny
        lda (TrackPtr), y
        tay ; hi ptr for the module address
        pla
        jsr bhop_init
        rts
.endproc

; Banking, needed by bhop.
; Since we don't use player.s, declare the banking function directly

.proc bhop_apply_music_bank
        sta ScratchByte
        inc ScratchByte
        sta NSF_BANK_BLOCK_A000
        lda ScratchByte
        sta NSF_BANK_BLOCK_B000
        rts
.endproc
.export bhop_apply_music_bank

.proc bhop_apply_dpcm_bank
        sta ScratchByte
        inc ScratchByte
        sta NSF_BANK_BLOCK_C000
        lda ScratchByte
        sta NSF_BANK_BLOCK_D000
        rts
.endproc
.export bhop_apply_dpcm_bank


;                                    Address               Bank Track#      NSF Expansion Flags                           Title                        Artist
;                                   --------                ---    ---  -----------------------    ----------------------------  ----------------------------
song_itt:       music_track_nsf     MODULE_0,  <.bank(MODULE_0),     0,                       0;   "Ikenfell - In This Together",           "aivi & surasshu"
song_virus:     music_track_nsf     MODULE_1,  <.bank(MODULE_1),     0,                       0;         "MMBN. - Virus Busting",              "Yoshino Aoki"
song_smb:       music_track_nsf     MODULE_2,  <.bank(MODULE_2),     0,                       0;  "Super Mario Bros - World 1-1",                "Koji Kondo"
song_yakra:     music_track_nsf     MODULE_3,  <.bank(MODULE_3),     0,                       0;  "Chrono Trigger - Boss Battle",          "Yasunori Mitsuda"
song_nsmb:      music_track_nsf     MODULE_4,  <.bank(MODULE_4),     0,                       0;    "New Super Mario Bros - 1-1",                "Koji Kondo"
song_sanctuary: music_track_nsf     MODULE_5,  <.bank(MODULE_5),     0,                       0;         "Earthbound - Guardian",      "K. Suzuki, H. Tanaka"
song_gato:      music_track_nsf     MODULE_6,  <.bank(MODULE_6),     0,                       0;       "Chrono Trigger - Battle",          "Yasunori Mitsuda"
song_simian:    music_track_nsf     MODULE_7,  <.bank(MODULE_7),     0,                       0;            "DKC - Simian Segue",           "Eveline Fischer"
song_sotn_stg1: music_track_nsf     MODULE_8,  <.bank(MODULE_8),     0,                       0; "Shadow of the Ninja - Stage 1", "I. Mizutani, K. Yamanishi"
song_tactus:    music_track_nsf     MODULE_9,  <.bank(MODULE_9),     0, NSF_EXPANSION_FLAG_VRC6;        "Tactus - Shower Groove",                  "zeta0134"
song_brain_age: music_track_nsf     MODULE_10, <.bank(MODULE_10),    0, NSF_EXPANSION_FLAG_MMC5;              "Brain Age - Menu",   "M. Hamano, A. Nakatsuka"
song_iaw:       music_track_nsf     MODULE_11, <.bank(MODULE_11),    1, NSF_EXPANSION_FLAG_VRC6;              "in another world",                   "Persune"

music_track_table:
        .addr song_itt
        .addr song_virus
        .addr song_smb
        .addr song_yakra
        .addr song_nsmb
        .addr song_sanctuary
        .addr song_gato
        .addr song_simian
        .addr song_sotn_stg1
        .addr song_tactus
        .addr song_brain_age
        .addr song_iaw
music_track_table_size := * - music_track_table

track_count = <(music_track_table_size/2)
.export track_count

music_track_count: .byte track_count
