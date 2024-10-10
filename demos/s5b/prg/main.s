        .setcpu "6502"

        .include "../../common/charmap.inc"
        .include "../../common/nes.inc"
        .include "../../common/player.inc"
        .include "../../common/ppu.inc"
        .include "../../common/word_util.inc"
        .include "../../common/vram_buffer.inc"

        .include "../../../bhop/zsaw.inc"

        .include "s5b.inc"

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
        .include "../music/tcg_s5b.asm"
        .endproc

        .segment "CODE"

;                                Address               Bank   Track#         Title (limit 28 chars)       Artist (limit 28 chars)
;                               --------                ---      ---   ----------------------------  ----------------------------
song_tcg:       music_track     MODULE_0,  <.bank(MODULE_0),      0,  "Pokemon TCG - Diary",        "Ichiro Shimakura"

music_track_table:
        .addr song_tcg

music_track_count: .byte 1

; Music bank in A
.proc player_bank_music
        pha ; preserve bank number on the stack
        lda #S5B_COMMAND_PRG_A000
        sta S5B_COMMAND_REG
        pla
        sta S5B_COMMAND_DATA
        rts
.endproc

; Sample bank in A
.proc player_bank_samples
        pha ; preserve bank number on the stack
        lda #S5B_COMMAND_PRG_C000
        sta S5B_COMMAND_REG
        pla
        sta S5B_COMMAND_DATA
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

        jsr initialize_s5b

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
