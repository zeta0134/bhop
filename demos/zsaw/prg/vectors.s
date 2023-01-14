        .include "../../common/nes.inc"

.import zsaw_irq, zsaw_nmi

        .segment "PRG0_8000"

.macro spinwait_for_vblank
.scope
loop:
        bit PPUSTATUS
        bpl loop
.endscope
.endmacro

.macro clear_page ADDR
.scope
        ldy #0
        lda #0
loop:
        dey
        sta ADDR,y
        bne loop
.endscope
.endmacro

        .import start, nmi, irq
reset:
        sei            ; Disable interrupts
        cld            ; make sure decimal mode is off (not that it does anything)
        ldx #$ff       ; initialize stack
        txs

        ; Wait for the PPU to finish warming up
        spinwait_for_vblank
        spinwait_for_vblank

        ; Initialize main memory
        clear_page $0000
        clear_page $0100
        clear_page $0200
        clear_page $0300
        clear_page $0400
        clear_page $0500
        clear_page $0600
        clear_page $0700

        ; Jump to main
        jmp start

        .importzp GameloopCounter, LastNmi
        ;
        ; Labels nmi/reset/irq are part of prg3_e000.s
        ;
        .segment "VECTORS"
        .addr zsaw_nmi
        .addr reset
        .addr zsaw_irq