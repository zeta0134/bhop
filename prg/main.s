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
        ;.include "../ftm/yakra.asm"
        ;.include "../ftm/sanctuary.asm"
        .include "../ftm/bark.asm"

        .segment "PRG3_E000"
        .export start, nmi, irq

.proc wait_for_nmi
        lda nmi_counter
loop:
        cmp nmi_counter
        beq loop
        rts
.endproc

.macro debug_color flags
        lda #(BG_ON | OBJ_ON | BG_CLIP | OBJ_CLIP | flags)
        sta PPUMASK
.endmacro

.proc burn_a_bunch_of_time
        ldx #$FF
loop:
        .repeat 4
        nop
        .endrep
        dex
        bne loop
        rts
.endproc

.proc start
        lda #$00
        sta PPUMASK ; disable rendering
        sta PPUCTRL ; and NMI

        ; do init things; right now that's just the music engine
        lda #0 ; song index
        jsr bhop_init

        ; re-enable graphics and NMI
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | OBJ_1000 | BG_0000)
        sta PPUCTRL

gameloop:
        jsr wait_for_nmi
        jsr burn_a_bunch_of_time
        debug_color TINT_R
        jsr bhop_play
        debug_color 0
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