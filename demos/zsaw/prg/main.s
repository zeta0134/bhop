        .setcpu "6502"

        .include "nes.inc"
        .include "ppu.inc"
        .include "word_util.inc"
        .include "zeropage.inc"

        .zeropage

        .segment "RAM"
nmi_counter: .byte $00

        .segment "PRG0_8000"
        .export start, bhop_nmi, bhop_music_data

bhop_music_data:
        .include "../music/zsaw_tactus.asm"

.proc start

gameloop:
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
        rti
.endproc
