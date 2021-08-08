        .setcpu "6502"

        .include "bhop.inc"
        .include "branch_checks.inc"
        .include "nes.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

.scope PRG3_E000
        .zeropage
ptr: .word $0000
R0: .byte $00 ; scratch bytes
R1: .byte $00

        .segment "RAM"
nmi_counter: .byte $00
performance_counter: .word $0000
baseline_performance: .word $0000
current_performance: .word $0000
lowest_performance: .word $0000
highest_performance: .word $0000

        .segment "PRG1_A000"
        ;.include "../ftm/yakra.asm"
        .include "../ftm/sanctuary.asm"
        ;.include "../ftm/bark.asm"
        ;.include "../ftm/bah.asm"
        ;.include "../ftm/1-1.asm"
        ;.include "../ftm/nary.asm"
        ;.include "../ftm/corneriaz.asm"

        .segment "PRG3_E000"
        .export start, nmi, irq

timing_nametable:
        .incbin "performance_display.nam"

; put the nametable you want to load in ptr, the destination in PPUADDR
.proc load_nametable
; left side
        st16 R0, ($400 + $100 - $1)
        ldy #0
loop:
        lda (ptr), y
        sta PPUDATA
        inc16 ptr
        dec16 R0
        bne loop

        rts
.endproc

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

.proc wait_until_sprite_zero_clears
        lda #%01000000
keep_waiting:
        bit PPUSTATUS
        bne keep_waiting
        rts
.endproc

; this mostly exists to make sure the PPUMASK performance
; indicator is visible, and isn't partially stuck in overscan
.proc burn_a_bunch_of_time
        ldx #$FF
loop:
        .repeat 7
        nop
        .endrep
        dex
        bne loop
        rts
.endproc

; counts approximate cycles until the next NMI occurs,
; starting from the time this function is called
.proc measure_cycles_until_nmi
        lda #0
        sta performance_counter
        sta performance_counter+1
        ldx nmi_counter ; incremented by NMI
loop:
        clc ; 2 cycles
        add16 performance_counter, #29 ; 20 cycles
        cpx nmi_counter ; 4 cycles
        beqnw loop ; 3 cycles (taken, no page cross)
        rts
.endproc

; this should effectively be the maximum number of performance
; units. By subtracting our actual count from this as a base, we
; can measure the unit cost of some segment of code
.proc find_baseline_performance
        jsr wait_for_nmi
        jsr wait_until_sprite_zero_clears
        jsr burn_a_bunch_of_time
        jsr measure_cycles_until_nmi
        lda performance_counter
        sta baseline_performance
        lda performance_counter+1
        sta baseline_performance+1
        ; since we just clobbered our results, initialize them
        lda #0
        sta current_performance
        sta current_performance+1
        sta highest_performance
        sta highest_performance+1
        lda #$FF
        sta lowest_performance
        sta lowest_performance+1
        rts
.endproc

.macro cmp16 word1, word2
.scope
        lda word1+1
        cmp word2+1
        bne done
        lda word1
        cmp word2
done:
        ; flags now has the result of the highest byte
        ; that differed
.endscope
.endmacro

.proc record_performance_metrics
        sec
        lda baseline_performance
        sbc performance_counter
        sta current_performance
        lda baseline_performance + 1
        sbc performance_counter + 1
        sta current_performance + 1

        cmp16 current_performance, lowest_performance
        bcs not_lower
        lda current_performance
        sta lowest_performance
        lda current_performance+1
        sta lowest_performance+1
not_lower:
        cmp16 current_performance, highest_performance
        bcc not_higher
        lda current_performance
        sta highest_performance
        lda current_performance+1
        sta highest_performance+1
not_higher:
        ; all done
        rts
.endproc

nybble_to_ascii_mapping:
        .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $21, $22, $23, $24, $25, $26

; put the byte to display in R0
; set PPUADDR beforehand with the destination
.proc display_hex_byte
        lda R0
        and #$F0
        lsr
        lsr
        lsr
        lsr
        tax
        lda nybble_to_ascii_mapping, x
        sta PPUDATA
        lda R0
        and #$0F
        tax
        lda nybble_to_ascii_mapping, x
        sta PPUDATA
        rts
.endproc

.macro display_hex_word word_addr, ppu_addr
        set_ppuaddr ppu_addr
        lda word_addr+1
        sta R0
        jsr display_hex_byte
        lda word_addr
        sta R0
        jsr display_hex_byte
.endmacro

.proc display_performance_metrics
        display_hex_word current_performance, #$222C
        display_hex_word lowest_performance,  #$226C
        display_hex_word highest_performance, #$22AC
        rts
.endproc

.proc start
        lda #$00
        sta PPUMASK ; disable rendering
        sta PPUCTRL ; and NMI

        ; do init things

        ; bhop init
        lda #0 ; song index
        jsr bhop_init

        ; graphics init
        st16 ptr, timing_nametable
        lda PPUSTATUS ; reset latch
        set_ppuaddr #$2000
        jsr load_nametable

        ; palette init
        set_ppuaddr #$3F00
        lda #$0F
        sta PPUDATA
        lda #$00
        sta PPUDATA
        lda #$10
        sta PPUDATA
        lda #$30
        sta PPUDATA

        ; initialize sprite zero with a non-blank tile, for timing purposes mostly
        lda #1
        sta $0201

        ; re-enable graphics and NMI
        lda #$1E
        sta PPUMASK
        lda #(VBLANK_NMI | OBJ_0000 | BG_0000)
        sta PPUCTRL

        ; setup for measuring performance
        jsr wait_for_nmi ; safety sync
        jsr find_baseline_performance

        ; one final nmi to get the first run of the game loop lined up for timing
        jsr wait_for_nmi
gameloop:
        ; align the gameloop with a sprite zero clear, this erases a lot of timing jitter
        ; from the performance counting function
        jsr wait_until_sprite_zero_clears
        ; wait a fixed amount of time, to put the PPUMASK performance display in the
        ; visible part of the display, not in the overscan region
        jsr burn_a_bunch_of_time
        ; set PPUMASK and run the engine
        debug_color LIGHTGRAY
        jsr bhop_play
        debug_color 0
        ; measure performance; this performs an NMI wait
        jsr measure_cycles_until_nmi
        ; record performance metrics, then loop
        jsr record_performance_metrics
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

        jsr display_performance_metrics

        ; set scroll registers
        lda PPUSTATUS
        set_ppuaddr #$2000
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

.endscope