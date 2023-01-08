        .setcpu "6502"

        .include "../../common/input.inc"
        .include "../../common/nes.inc"
        .include "../../common/player.inc"
        .include "../../common/ppu.inc"
        .include "../../common/word_util.inc"

        .include "../../../bhop/bhop.inc"
        .include "../../../bhop/zsaw.inc"

        .zeropage

        .segment "RAM"
nmi_counter: .byte $00

        .segment "PRG0_8000"
        .export start, bhop_nmi, bhop_music_data

bhop_music_data:
        .include "../music/zsaw_tactus.asm"

.proc wait_for_nmi
        lda nmi_counter
loop:
        cmp nmi_counter
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

        ; z-saw init
        jsr zsaw_init

        ; bhop init
        lda #0 ; song index
        jsr bhop_init

        ; re-enable graphics and NMI
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | OBJ_0000 | BG_0000)
        sta PPUCTRL

        ; setup for measuring performance
        jsr wait_for_nmi ; safety sync

gameloop:
        jsr poll_input
        jsr bhop_play
        jsr wait_for_nmi ; safety sync
        jmp gameloop ; forever

.endproc

.proc bhop_nmi
        ; preserve registers
        pha
        txa
        pha
        tya
        pha

        inc nmi_counter

        ; restore registers
        pla
        tay
        pla
        tax
        pla

        ; all done
        rts
.endproc
