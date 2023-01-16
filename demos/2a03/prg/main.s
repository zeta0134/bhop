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

        .export start, demo_nmi, bhop_music_data
        
bhop_music_data = $A000

        .segment "MUSIC_0"
        .scope MODULE_0
        .include "../music/yakra.asm"
        .endscope

        .segment "CODE"

;                            Bank  Track#                          Title                        Artist
;                             ---     ---   ----------------------------  ----------------------------
song_yakra: music_track         0,      0, "Chrono Trigger - Boss Battle",          "Yasunori Mitsuda"

music_track_table:
        .addr song_yakra

music_track_count: .byte 1

; NROM doesn't support banking at all, so stub both of these out
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

        ; z-saw init
        jsr zsaw_init

        ; player init
        jsr player_init

        ; re-enable graphics and NMI
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | OBJ_1000 | BG_0000)
        sta PPUCTRL

        ; todo: setup for measuring performance?
        jsr wait_for_nmi ; safety sync

gameloop:
        jsr player_update
        jsr wait_for_nmi ; safety sync
        jmp gameloop ; forever

.endproc

.proc demo_nmi
        ; preserve registers
        pha
        txa
        pha
        tya
        pha

        inc NmiCounter

        jsr vram_zipper

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
        rts
.endproc
