        .setcpu "6502"

        .include "bhop.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.scope PRG3_E000
        .zeropage

        .segment "RAM"
nmi_counter: .byte $00

        .segment "PRG1_A000"
        .include "../ftm/yakra.asm"

        .segment "PRG3_E000"
        .export start, nmi, irq

.proc start
        jsr bhop_init

gameloop:
        jmp gameloop ; forever

        .endproc

.proc irq
        ; do nothing
        rti
.endproc

.proc nmi
        ; preserve registers
        pha
        txa
        pha
        tya
        pha

        ; do the sprite thing
        lda #$00
        sta OAMADDR
        lda #$02
        sta OAM_DMA

        inc nmi_counter

        ; restore registers
        pla
        tay
        pla
        tax
        pla

        ; all done
        rti
.endproc

.endscope