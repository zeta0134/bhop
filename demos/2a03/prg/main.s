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

        .export start, nmi, irq

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

        .segment "CODE"

;                                Address               Bank   Track#                          Title                        Artist
;                               --------                ---      ---   ----------------------------  ----------------------------
song_itt:       music_track     MODULE_0,  <.bank(MODULE_0),      0,  "Ikenfell - In This Together",           "aivi & surasshu"
song_virus:     music_track     MODULE_1,  <.bank(MODULE_1),      0,        "MMBN. - Virus Busting",              "Yoshino Aoki"
song_smb:       music_track     MODULE_2,  <.bank(MODULE_2),      0, "Super Mario Bros - World 1-1",                "Koji Kondo"
song_yakra:     music_track     MODULE_3,  <.bank(MODULE_3),      0, "Chrono Trigger - Boss Battle",          "Yasunori Mitsuda"
song_nsmb:      music_track     MODULE_4,  <.bank(MODULE_4),      0,   "New Super Mario Bros - 1-1",                "Koji Kondo"
song_sanctuary: music_track     MODULE_5,  <.bank(MODULE_5),      0,        "Earthbound - Guardian",      "K. Suzuki, H. Tanaka"
song_gato:      music_track     MODULE_6,  <.bank(MODULE_6),      0,      "Chrono Trigger - Battle",          "Yasunori Mitsuda"
song_simian:    music_track     MODULE_7,  <.bank(MODULE_7),      0,           "DKC - Simian Segue",           "Eveline Fischer"

music_track_table:
        .addr song_itt
        .addr song_virus
        .addr song_smb
        .addr song_yakra
        .addr song_nsmb
        .addr song_sanctuary
        .addr song_gato
        .addr song_simian

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
