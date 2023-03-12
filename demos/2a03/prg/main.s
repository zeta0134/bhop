        .setcpu "6502"

        .include "../../common/charmap.inc"
        .include "../../common/nes.inc"
        .include "../../common/player.inc"
        .include "../../common/ppu.inc"
        .include "../../common/word_util.inc"
        .include "../../common/vram_buffer.inc"

        .include "../../../bhop/zsaw.inc"

        .include "mmc3.inc"

        .zeropage

        .segment "RAM"
NmiCounter: .byte $00

        .segment "CHR0"
        .incbin "../../common/bnuuy_bg.chr"
        .segment "CHR1"
        .incbin "../../common/bnuuy_obj.chr"

        .export start, nmi, irq, bhop_music_data
        
bhop_music_data = $A000

        .segment "MUSIC_0"
        .scope MODULE_0
        .include "../music/in_this_together.asm"
        .endscope

        .segment "MUSIC_1"
        .scope MODULE_1
        .include "../music/virus-busting.asm"
        .endscope

        .segment "MUSIC_2"
        .scope MODULE_2
        .include "../music/world-1-1.asm"
        .endscope

        .segment "MUSIC_3"
        .scope MODULE_3
        .include "../music/yakra.asm"
        .endscope

        .segment "MUSIC_4"
        .scope MODULE_4
        .include "../music/nsmb.asm"
        .endscope

        .segment "MUSIC_5"
        .scope MODULE_5
        .include "../music/sanctuary.asm"
        .endscope

        .segment "MUSIC_6"
        .scope MODULE_6
        .include "../music/gato.asm"
        .endscope

        .segment "MUSIC_7"
        .scope MODULE_7
        .include "../music/simian_segue.asm"
        .endscope

        .segment "MUSIC_8"
        .scope MODULE_8
        .include "../music/red_streamer.asm"
        .endscope

        .segment "MUSIC_9"
        .scope MODULE_9
        .include "../music/grooves.asm"
        .endscope

        .segment "CODE"

;                                Bank  Track#                          Title                        Artist
;                                 ---     ---   ----------------------------  ----------------------------
song_itt:       music_track         0,      0,  "Ikenfell - In This Together",           "aivi & surasshu"
song_virus:     music_track         1,      0,        "MMBN. - Virus Busting",              "Yoshino Aoki"
song_smb:       music_track         2,      0, "Super Mario Bros - World 1-1",                "Koji Kondo"
song_yakra:     music_track         3,      0, "Chrono Trigger - Boss Battle",          "Yasunori Mitsuda"
song_nsmb:      music_track         4,      0,   "New Super Mario Bros - 1-1",                "Koji Kondo"
song_sanctuary: music_track         5,      0,        "Earthbound - Guardian",      "K. Suzuki, H. Tanaka"
song_gato:      music_track         6,      0,      "Chrono Trigger - Battle",          "Yasunori Mitsuda"
song_simian:    music_track         7,      0,           "DKC - Simian Segue",           "Eveline Fischer"
song_red:       music_track         8,      0, "PM. OK - Red Streamer Battle",                  "Nintendo"
song_groove1:   music_track         9,      0,              "Test: Grooves 1",                  "zeta0134"
song_groove2:   music_track         9,      1,              "Test: Grooves 2",                  "zeta0134"
song_groove3:   music_track         9,      2,              "Test: Grooves 3",                  "zeta0134"
song_groove4:   music_track         9,      3,              "Test: Grooves 4",                  "zeta0134"

music_track_table:
        ;.addr song_groove1
        ;.addr song_groove2
        ;.addr song_groove3
        ;.addr song_groove4
        ;.addr song_red
        .addr song_itt
        .addr song_virus
        .addr song_smb
        .addr song_yakra
        .addr song_nsmb
        .addr song_sanctuary
        .addr song_gato
        .addr song_simian

;music_track_count: .byte 13
music_track_count: .byte 8

.proc player_bank_music
        pha ; preserve bank number on the stack
        lda #(MMC3_BANKING_MODE + $7)
        sta MMC3_BANK_SELECT
        pla ; restore bank number
        sta MMC3_BANK_DATA
        rts
.endproc

.proc player_bank_samples
        pha ; preserve bank number on the stack
        lda #(MMC3_BANKING_MODE + $6)
        sta MMC3_BANK_SELECT
        pla ; restore bank number
        sta MMC3_BANK_DATA
        rts
.endproc

.proc wait_for_nmi
        lda NmiCounter
loop:
        cmp NmiCounter
        beq loop
        rts
.endproc        

.proc start
        lda #$00
        sta PPUMASK ; disable rendering
        sta PPUCTRL ; and NMI

        ; disable unusual IRQ sources
        lda #%01000000
        sta $4017 ; APU frame counter
        lda #0
        sta $4010 ; DMC DMA

        jsr initialize_mmc3

        ; player init
        jsr player_init

        ; re-enable graphics and NMI
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | OBJ_1000 | BG_0000)
        sta PPUCTRL

        jsr wait_for_nmi ; safety sync

gameloop:
        jsr player_update
        jsr wait_for_nmi ; safety sync
        jmp gameloop ; forever

.endproc

.proc irq
        rti
.endproc

.proc nmi
        ; preserve registers
        pha
        txa
        pha
        tya
        pha

        inc NmiCounter

        jsr vram_zipper

        lda #0
        sta OAMADDR
        lda #$02
        sta OAM_DMA

        lda #(VBLANK_NMI | OBJ_1000 | BG_0000)
        sta PPUCTRL

        lda PPUSTATUS
        lda #0
        sta PPUSCROLL
        sta PPUSCROLL

        ; restore registers
        pla
        tay
        pla
        tax
        pla

        ; all done
        rti
.endproc
