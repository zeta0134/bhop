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

        .segment "PRG0_8000"
        .export start, demo_nmi

.proc MODULE_0
        .include "../music/zsaw_demo_tracks.asm"
.endproc

;                                Address              Bank  Track#                          Title                        Artist
;                               --------               ---     ---   ----------------------------  ----------------------------
song_heat_death: music_track    MODULE_0, <.bank(MODULE_0),      0,        "Heat Death - Smooth",                   "zeta0134"
song_tactus:     music_track    MODULE_0, <.bank(MODULE_0),      1,              "Tactus - Demo",                   "zeta0134"

music_track_table:
        .addr song_heat_death
        .addr song_tactus

music_track_count: .byte 2

; NROM doesn't support banking at all, so stub both of these out
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
