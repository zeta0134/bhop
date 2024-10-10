    .include "s5b.inc"

.proc initialize_s5b
    ; Initialize CHR to an NROM-like layout, which will
    ; suit bhop's purposes just fine
    s5b_command #S5B_COMMAND_CHR_0000, #0
    s5b_command #S5B_COMMAND_CHR_0400, #1
    s5b_command #S5B_COMMAND_CHR_0800, #2
    s5b_command #S5B_COMMAND_CHR_0C00, #3
    s5b_command #S5B_COMMAND_CHR_1000, #4
    s5b_command #S5B_COMMAND_CHR_1400, #5
    s5b_command #S5B_COMMAND_CHR_1800, #6
    s5b_command #S5B_COMMAND_CHR_1C00, #7

    ; Set PRG ROM initial banks; bhop goes in 8000, data and samples
    ; will be switched by the engine
    s5b_command #S5B_COMMAND_PRG_8000, #$1E ; second to last
    s5b_command #S5B_COMMAND_PRG_A000, #0
    s5b_command #S5B_COMMAND_PRG_C000, #1

    ; Enable PRG RAM (though we don't need to use it)
    s5b_command #S5B_COMMAND_PRG_6000, #S5B_RAM_SELECT

    ; Setup vertical mirroring, matching the NROM build's configuration
    s5b_command #S5B_COMMAND_MIRRORING, #S5B_MIRRORING_VERTICAL

    ; This build does not use IRQs, so ensure they are disabled
    s5b_command #S5B_COMMAND_IRQ_CONTROL, #0

    rts
.endproc