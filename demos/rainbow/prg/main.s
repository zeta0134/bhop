        .setcpu "6502"

        .include "../../common/charmap.inc"
        .include "../../common/nes.inc"
        .include "../../common/player.inc"
        .include "../../common/ppu.inc"
        .include "../../common/word_util.inc"
        .include "../../common/vram_buffer.inc"

        .include "../../../bhop/bhop.inc"

        .include "rainbow.inc"

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
        
        .proc MODULE_2
        .include "../music/zpcm_vol_test.asm"
        .endproc

        .segment "CODE"

;                                Address               Bank   Track#                          Title                        Artist
;                               --------                ---      ---   ----------------------------  ----------------------------
song_tactus:    music_track     MODULE_0,  <.bank(MODULE_0),       0,      "Tactus - Shower Groove",                   "zeta0134"
song_sawvol:    music_track     MODULE_1,  <.bank(MODULE_1),       0,           "Sawtooth Vol Test",                          "-"
song_zpcmvol:   music_track     MODULE_2,  <.bank(MODULE_2),       0,               "ZPCM Vol Test",                          "-"

music_track_table:
        .addr song_tactus
        .addr song_sawvol
        .addr song_zpcmvol

music_track_count: .byte 3

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

        ; perform exactly one OAM DMA here
        lda #0
        sta OAMADDR
        lda #$02
        sta OAM_DMA

        ; RAINBOW init
        ; setup ZPCM mode
        lda #%00000100
        sta MAP_SND_EXP_CTRL
        ; setup CPU-based IRQ every 128 cycles, matching Rainbow demo
        lda #128
        sta MAP_CPU_IRQ_LATCH_LO
        lda #0
        sta MAP_CPU_IRQ_LATCH_HI
        ; actually turn those on
        lda #%00000011 ; enable / repeat on acknowledge
        sta MAP_CPU_IRQ_CONTROL
        cli

gameloop:
        jsr player_update

        ; disable DPCM entirely, which works around a minor bug with the MUTED
        ; status. If we don't do this, bhop writes 0x00 to the PCM level every tick,
        ; which interferes with the zpcm test

        ; it's easier to do this here than to try to inject it into the shared
        ; player; it's not like we're doing anything else in the game loop
        lda #7 ; DPCM index
        jsr bhop_mute_channel

        jsr wait_for_nmi
        jmp gameloop ; forever

.endproc

.proc irq
        inc $4011 ; copy in zpcm value
        sta MAP_CPU_IRQ_ACK ; acknowledge CPU IRQ, which should re-enable automatically
        rti
.endproc

.proc nmi
        cli ; it's fine, let these happen
        ; preserve registers
        pha
        txa
        pha
        tya
        pha

        inc NmiCounter

        jsr vram_zipper

        ;lda #0
        ;sta OAMADDR
        ;lda #$02
        ;sta OAM_DMA

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
