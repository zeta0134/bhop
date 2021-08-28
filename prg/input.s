        .setcpu "6502"
        .include "nes.inc"



.scope PRG3_E000
        .zeropage
.exportzp ButtonsDown, ButtonsUp, ButtonsHeld
ButtonsThisFrame: .byte $00
ButtonsLastFrame: .byte $00
ButtonsDown: .byte $00
ButtonsUp: .byte $00
ButtonsHeld: .byte $00

        .segment "PRG_E000"
        ;.org $e000

.export poll_input

.macro read_controller controller_port, result_dest
.scope
        ; pulse P1 high to latch buttons
        lda #$01
        sta controller_port
        ; set only lowest bit of result to 1
        sta result_dest
        lsr a ; a is now 0
        sta controller_port
loop:
        lda controller_port ; result in bit 0
        lsr a ; bit0 -> carry
        rol result_dest ; carry -> low bit of result, high bit -> carry
        bcc loop ; triggered when our initialized bit leaves result

.endscope
.endmacro

; Reads button input, currently only for controller P1
; Clobbers: a

.proc poll_input
        lda ButtonsThisFrame
        sta ButtonsLastFrame
read_p1_safely:
        read_controller CONTROLLER_P1, ButtonsThisFrame
reread:
        lda ButtonsThisFrame
        pha
        read_controller CONTROLLER_P1, ButtonsThisFrame
        pla 
        cmp ButtonsThisFrame
        bne reread ; buttons didn't match; DPCM fetch or unusually accurate player
        ; If either UP or LEFT is pressed:
        lda ButtonsThisFrame
        and #(KEY_UP | KEY_LEFT)
        ; shift to produce DOWN and RIGHT
        lsr
        ; invert to produce allowed keys
        eor #$FF
        ; use allowed keys to mask off disallowed D-pad presses:
        and ButtonsThisFrame
        sta ButtonsThisFrame
check_release:
        ; ButtonsThisFrame is already in a
        eor #$FF ; If NOT pressed this frame
        and ButtonsLastFrame ; AND pressed last frame
        sta ButtonsDown ; register a button release
check_down:
        lda ButtonsLastFrame
        eor #$FF ; If NOT pressed last frame
        and ButtonsThisFrame ; AND pressed this frame
        sta ButtonsUp ; register a down press
check_held:
        lda ButtonsThisFrame ; If pressed this frame
        and ButtonsLastFrame ; AND last frame
        sta ButtonsHeld ; register a held button
        rts
.endproc

.endscope