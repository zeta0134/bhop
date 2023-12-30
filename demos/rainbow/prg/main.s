        .setcpu "6502"

        .include "../../common/charmap.inc"
        .include "../../common/nes.inc"
        .include "../../common/player.inc"
        .include "../../common/ppu.inc"
        .include "../../common/word_util.inc"
        .include "../../common/vram_buffer.inc"

        .include "../../../bhop/zsaw.inc"

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
        .include "../music/tactus.asm"
        .endproc
        .proc MODULE_1
        .include "../music/saw_vol_test.asm"
        .endproc

        .segment "CODE"

;                                Address               Bank   Track#                          Title                        Artist
;                               --------                ---      ---   ----------------------------  ----------------------------
song_tactus:    music_track     MODULE_0,  <.bank(MODULE_0),       0,      "Tactus - Shower Groove",                   "zeta0134"
song_sawvol:    music_track     MODULE_1,  <.bank(MODULE_1),       0,           "Sawtooth Vol Test",                          "-"

music_track_table:
        .addr song_tactus
        .addr song_sawvol

music_track_count: .byte 2

.proc player_bank_music
        rts
.endproc

.proc player_bank_samples
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
