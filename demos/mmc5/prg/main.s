        .setcpu "6502"

        .include "../../common/charmap.inc"
        .include "../../common/nes.inc"
        .include "../../common/player.inc"
        .include "../../common/ppu.inc"
        .include "../../common/word_util.inc"
        .include "../../common/vram_buffer.inc"

        .include "mmc5.inc"

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
        .include "../music/brain_age.asm"
        .endproc


        .segment "CODE"

;                                  Address              Bank  Track#                          Title                        Artist
;                                 --------               ---     ---   ----------------------------  ----------------------------
song_brain_age:     music_track  MODULE_0,  <.bank(MODULE_0),      0,            "Brain Age - Menu",     "M. Hamano, A. Nakatsuka"

music_track_table:
        .addr song_brain_age

music_track_count: .byte 1

.proc player_bank_music
        ora #(MMC5_SELECT_ROM_BANK)
        sta MMC5_MODE_3_PRG_ROM_A000
        rts
.endproc

.proc player_bank_samples
        ora #(MMC5_SELECT_ROM_BANK)
        sta MMC5_MODE_3_PRG_ROM_C000
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

        ; Set up MMC5 PRG banking, with 8k banks
        ; RAM: unused
        ; ROM 0x8000 - bhop driver
        ; ROM 0xA000 - music data for current module
        ; ROM 0xC000 - DPCM sample data
        ; ROM 0xE000 - fixed player code and vectors
        ; Since fixed is already in place and the two data banks are handled
        ; by the player, we only need to set the mode and the bhop bank here:
        lda #MMC5_PRG_MODE_FOUR_8K_BANKS
        sta MMC5_PRG_MODE
        lda #(6 | MMC5_SELECT_ROM_BANK)
        sta MMC5_MODE_3_PRG_ROM_8000

        ; Set up CHR banks. The bhop player uses a single set of fixed 8k tiles due
        ; to NROM compat, and has no need for fancy bank modes or features. Just to
        ; safely support 8x16 sprite mode in the future, we'll set those register here,
        ; even though in 8x8 sprite mode they will be ignored. 
        lda #MMC5_CHR_MODE_ONE_8K_BANK
        sta MMC5_CHR_MODE
        lda #0
        sta MMC5_MODE_0_CHR_ROM_0000
        sta MMC5_MODE_0_BG_ROM_0000 ; only used in 8x16 sprite mode

        ; Set up nametable mirroring. We will match NROM and specify vertical mirroring
        ; using CIRAM, ignoring any of MMC5's fancy features.
        lda #(MMC5_NT_2000_CIRAM_0 | MMC5_NT_2400_CIRAM_1 | MMC5_NT_2800_CIRAM_0 | MMC5_NT_2C00_CIRAM_1)
        sta MMC5_NAMETABLE_MAPPING

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
