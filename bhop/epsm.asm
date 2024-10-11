; Taken from https://github.com/Perkka2/EPSM/blob/main/Docs/Fiskbit-FallbackHandler.md
; adapted somewhat for more efficient writes when using a known constant

; For quickly writing constant values
.macro _write_epcm_const cmd_const
    lda #cmd_const
.if (cmd_const & $FC) = $00
    ldx #0
    stx epsm_safe_write_byte
    sta $4016
    .byte $01, epsm_safe_write_byte-1       ; ORA (epsm_safe_write_byte-1,X)
.endif
.if (cmd_const & $FC) = $04
    sta $4016
    .byte $05, epsm_safe_write_byte         ; ORA <epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $08
    sta $4016
    .byte $0A                               ; ASL
.endif
.if (cmd_const & $FC) = $0C
    sta $4016
    .byte $0D, epsm_safe_write_byte,   $00  ; ORA <>epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $10
    sta $4016
    .byte $10, $00                          ; BPL #$00
.endif
.if (cmd_const & $FC) = $14
    sta $4016
    .byte $15, epsm_safe_write_byte         ; ORA <epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $18
    sta $4016
    .byte $18                               ; CLC
.endif
.if (cmd_const & $FC) = $1C
    sta $4016
    .byte $1D, epsm_safe_write_byte,   $00  ; ORA <>epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $20
    ldx #0
    stx epsm_safe_write_byte
    sta $4016
    .byte $21, epsm_safe_write_byte-1       ; AND (epsm_safe_write_byte-1,X)
.endif
.if (cmd_const & $FC) = $24
    sta $4016
    .byte $25, epsm_safe_write_byte         ; AND <epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $28
    sta $40162
    .byte $2A                               ; ROL
.endif
.if (cmd_const & $FC) = $2C
    sta $4016
    .byte $2D, epsm_safe_write_byte,   $00  ; AND <>epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $30
    sta $4016
    .byte $30, $00                          ; BMI #$00
.endif
.if (cmd_const & $FC) = $34
    sta $4016
    .byte $35, epsm_safe_write_byte         ; AND <epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $38
    sta $4016
    .byte $38                               ; SEC
.endif
.if (cmd_const & $FC) = $3C
    sta $4016
    .byte $3D, epsm_safe_write_byte,   $00  ; AND <>epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $40
    ldx #0
    stx epsm_safe_write_byte
    sta $4016
    .byte $41, epsm_safe_write_byte-1       ; EOR (epsm_safe_write_byte-1,X)
.endif
.if (cmd_const & $FC) = $44
    sta $4016
    .byte $45, epsm_safe_write_byte         ; EOR <epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $48
    sta $4016
    .byte $4A                               ; LSR
.endif
.if (cmd_const & $FC) = $4C
    sta $4016
    .byte $4D, epsm_safe_write_byte,   $00  ; EOR <>epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $50
    sta $4016
    .byte $50, $00                          ; BVC #$00
.endif
.if (cmd_const & $FC) = $54
    sta $4016
    .byte $55, epsm_safe_write_byte         ; EOR <epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $58
    sta $4016
    .byte $59, $00,                    $00  ; EOR $0000,Y
.endif
.if (cmd_const & $FC) = $5C
    sta $4016
    .byte $5D, epsm_safe_write_byte,   $00  ; EOR <>epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $60
    ldx #0
    stx epsm_safe_write_byte
    sta $4016
    .byte $61, epsm_safe_write_byte-1       ; ADC (epsm_safe_write_byte-1,X)
.endif
.if (cmd_const & $FC) = $64
    sta $4016
    .byte $65, epsm_safe_write_byte         ; ADC <epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $68
    sta $4016
    .byte $6A                               ; ROR
.endif
.if (cmd_const & $FC) = $6C
    sta $4016
    .byte $6D, epsm_safe_write_byte,   $00  ; ADC <>epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $70
    sta $4016
    .byte $70, $00                          ; BVS #$00
.endif
.if (cmd_const & $FC) = $74
    sta $4016
    .byte $75, epsm_safe_write_byte         ; ADC <epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $78
    sta $4016
    .byte $79, $00,                    $00  ; ADC $0000,Y
.endif
.if (cmd_const & $FC) = $7C
    sta $4016
    .byte $7D, epsm_safe_write_byte,   $00  ; ADC <>epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $80
    sta $4016
    .byte $80, $00                          ; NOP #$00 (illegal)
.endif
.if (cmd_const & $FC) = $84
    ; write to safe byte directly, no setup needed
    sta $4016
    .byte $86, epsm_safe_write_byte         ; STX <epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $88
    sta $4016
    .byte $8A                               ; TXA
.endif
.if (cmd_const & $FC) = $8C
    ; write to safe byte directly, no setup needed
    sta $4016
    .byte $8E, epsm_safe_write_byte,   $00  ; STX <>epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $90
    sta $4016
    .byte $90, $00                          ; BCC #$00
.endif
.if (cmd_const & $FC) = $94
    ldx #0 ; write to safe byte + X
    sta $4016
    .byte $95, epsm_safe_write_byte         ; STA <epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $98
    sta $4016
    .byte $98                               ; TYA
.endif
.if (cmd_const & $FC) = $9C
    ldx #0 ; write to safe byte + X
    sta $4016
    .byte $9D, epsm_safe_write_byte,   $00  ; STA <>epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $A0
    sta $4016
    .byte $A2, $00                          ; LDX #$00
.endif
.if (cmd_const & $FC) = $A4
    sta $4016
    .byte $A5, epsm_safe_write_byte         ; LDA <epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $A8
    sta $4016
    .byte $A9, $00                          ; LDA #$00
.endif
.if (cmd_const & $FC) = $AC
    sta $4016
    .byte $AD, epsm_safe_write_byte,   $00  ; LDA <>epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $B0
    sta $4016
    .byte $B0, $00                          ; BCS #$00
.endif
.if (cmd_const & $FC) = $B4
    sta $4016
    .byte $B5, epsm_safe_write_byte         ; LDA <epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $B8
    sta $4016
    .byte $B8                               ; CLV
.endif
.if (cmd_const & $FC) = $BC
    sta $4016
    .byte $BD, epsm_safe_write_byte,   $00  ; LDA <>epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $C0
    sta $4016
    .byte $C0, $00                          ; CPY #$00
.endif
.if (cmd_const & $FC) = $C4
    sta $4016
    .byte $C5, epsm_safe_write_byte         ; CMP <epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $C8
    sta $4016
    .byte $C9, $00                          ; CMP #$00
.endif
.if (cmd_const & $FC) = $CC
    sta $4016
    .byte $CD, epsm_safe_write_byte,   $00  ; CMP <>epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $D0
    sta $4016
    .byte $D0, $00                          ; BNE #$00
.endif
.if (cmd_const & $FC) = $D4
    sta $4016
    .byte $D5, epsm_safe_write_byte         ; CMP <epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $D8
    sta $4016
    .byte $D9, $00,                    $00  ; CMP $0000,Y
.endif
.if (cmd_const & $FC) = $DC
    sta $4016
    .byte $DD, epsm_safe_write_byte,   $00  ; CMP <>epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $E0
    sta $4016
    .byte $E0, $00                          ; CPX #$00
.endif
.if (cmd_const & $FC) = $E4
    sta $4016
    .byte $E4, epsm_safe_write_byte         ; CPX <epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $E8
    sta $4016
    .byte $EA                               ; NOP
.endif
.if (cmd_const & $FC) = $EC
    sta $4016
    .byte $EC, epsm_safe_write_byte,   $00  ; CPX <>epsm_safe_write_byte
.endif
.if (cmd_const & $FC) = $F0
    sta $4016
    .byte $F0, $00                          ; BEQ #$00
.endif
.if (cmd_const & $FC) = $F4
    sta $4016
    .byte $F5, epsm_safe_write_byte         ; SBC <epsm_safe_write_byte,X
.endif
.if (cmd_const & $FC) = $F8
    sta $4016
    .byte $F9, $00,                    $00  ; SBC $0000,Y
.endif
.if (cmd_const & $FC) = $FC
    sta $4016
    .byte $FD, epsm_safe_write_byte,   $00  ; SBC <>epsm_safe_write_byte,X
.endif
.endmacro

; Note: this is a S5B compatibility layer. All the registers
; we care about are in A1=0, so we don't worry about the other
; entire half of the possibility space.
.macro write_epsm_reg_const reg_constant_byte
    _write_epcm_const (((reg_constant_byte & $F0)     ) | $2)
    _write_epcm_const (((reg_constant_byte & $0F) << 4) | $0)
.endmacro

.macro write_epsm_data_const reg_constant_byte
    _write_epcm_const (((reg_constant_byte & $F0)     ) | $A)
    _write_epcm_const (((reg_constant_byte & $0F) << 4) | $0)
.endmacro

; For much less quickly writing arbitrary values

; Each handler is assumed to be 8 bytes for fast dispatch.
.macro write_epsm_value op1, op2, op3
  STA $4016
  .byte op1, op2, op3
  RTS
  BRK
.endmacro

; Array of functions for safe EPSM writes. This is assumed to be page-aligned for fast lookup,
; ordered by value to write, and 8 bytes per entry.
.align 256
epsm_write_handlers:
write_epsm_value $01, epsm_safe_write_byte-1, $60  ; ORA (epsm_safe_write_byte-1,X)
write_epsm_value $05, epsm_safe_write_byte,   $60  ; ORA <epsm_safe_write_byte
write_epsm_value $0A, $60,                    $60  ; ASL
write_epsm_value $0D, epsm_safe_write_byte,   $00  ; ORA <>epsm_safe_write_byte
write_epsm_value $10, $00,                    $60  ; BPL #$00
write_epsm_value $15, epsm_safe_write_byte,   $60  ; ORA <epsm_safe_write_byte,X
write_epsm_value $18, $60,                    $60  ; CLC
write_epsm_value $1D, epsm_safe_write_byte,   $00  ; ORA <>epsm_safe_write_byte,X
write_epsm_value $21, epsm_safe_write_byte-1, $60  ; AND (epsm_safe_write_byte-1,X)
write_epsm_value $25, epsm_safe_write_byte,   $60  ; AND <epsm_safe_write_byte
write_epsm_value $2A, $60,                    $60  ; ROL
write_epsm_value $2D, epsm_safe_write_byte,   $00  ; AND <>epsm_safe_write_byte
write_epsm_value $30, $00,                    $60  ; BMI #$00
write_epsm_value $35, epsm_safe_write_byte,   $60  ; AND <epsm_safe_write_byte,X
write_epsm_value $38, $60,                    $60  ; SEC
write_epsm_value $3D, epsm_safe_write_byte,   $00  ; AND <>epsm_safe_write_byte,X
write_epsm_value $41, epsm_safe_write_byte-1, $60  ; EOR (epsm_safe_write_byte-1,X)
write_epsm_value $45, epsm_safe_write_byte,   $60  ; EOR <epsm_safe_write_byte
write_epsm_value $4A, $60,                    $60  ; LSR
write_epsm_value $4D, epsm_safe_write_byte,   $00  ; EOR <>epsm_safe_write_byte
write_epsm_value $50, $00,                    $60  ; BVC #$00
write_epsm_value $55, epsm_safe_write_byte,   $60  ; EOR <epsm_safe_write_byte,X
write_epsm_value $59, $00,                    $00  ; EOR $0000,Y
write_epsm_value $5D, epsm_safe_write_byte,   $00  ; EOR <>epsm_safe_write_byte,X
write_epsm_value $61, epsm_safe_write_byte-1, $60  ; ADC (epsm_safe_write_byte-1,X)
write_epsm_value $65, epsm_safe_write_byte,   $60  ; ADC <epsm_safe_write_byte
write_epsm_value $6A, $60,                    $60  ; ROR
write_epsm_value $6D, epsm_safe_write_byte,   $00  ; ADC <>epsm_safe_write_byte
write_epsm_value $70, $00,                    $60  ; BVS #$00
write_epsm_value $75, epsm_safe_write_byte,   $60  ; ADC <epsm_safe_write_byte,X
write_epsm_value $79, $00,                    $00  ; ADC $0000,Y
write_epsm_value $7D, epsm_safe_write_byte,   $00  ; ADC <>epsm_safe_write_byte,X
write_epsm_value $80, $00,                    $60  ; NOP #$00 (illegal)
write_epsm_value $86, epsm_safe_write_byte,   $60  ; STX <epsm_safe_write_byte
write_epsm_value $8A, $60,                    $60  ; TXA
write_epsm_value $8E, epsm_safe_write_byte,   $00  ; STX <>epsm_safe_write_byte
write_epsm_value $90, $00,                    $60  ; BCC #$00
write_epsm_value $95, epsm_safe_write_byte,   $60  ; STA <epsm_safe_write_byte,X
write_epsm_value $98, $60,                    $60  ; TYA
write_epsm_value $9D, epsm_safe_write_byte,   $00  ; STA <>epsm_safe_write_byte,X
write_epsm_value $A2, $00,                    $60  ; LDX #$00
write_epsm_value $A5, epsm_safe_write_byte,   $60  ; LDA <epsm_safe_write_byte
write_epsm_value $A9, $00,                    $60  ; LDA #$00
write_epsm_value $AD, epsm_safe_write_byte,   $00  ; LDA <>epsm_safe_write_byte
write_epsm_value $B0, $00,                    $60  ; BCS #$00
write_epsm_value $B5, epsm_safe_write_byte,   $60  ; LDA <epsm_safe_write_byte,X
write_epsm_value $B8, $60,                    $60  ; CLV
write_epsm_value $BD, epsm_safe_write_byte,   $00  ; LDA <>epsm_safe_write_byte,X
write_epsm_value $C0, $00,                    $60  ; CPY #$00
write_epsm_value $C5, epsm_safe_write_byte,   $60  ; CMP <epsm_safe_write_byte
write_epsm_value $C9, $00,                    $60  ; CMP #$00
write_epsm_value $CD, epsm_safe_write_byte,   $00  ; CMP <>epsm_safe_write_byte
write_epsm_value $D0, $00,                    $60  ; BNE #$00
write_epsm_value $D5, epsm_safe_write_byte,   $60  ; CMP <epsm_safe_write_byte,X
write_epsm_value $D9, $00,                    $00  ; CMP $0000,Y
write_epsm_value $DD, epsm_safe_write_byte,   $00  ; CMP <>epsm_safe_write_byte,X
write_epsm_value $E0, $00,                    $60  ; CPX #$00
write_epsm_value $E4, epsm_safe_write_byte,   $60  ; CPX <epsm_safe_write_byte
write_epsm_value $EA, $60,                    $60  ; NOP
write_epsm_value $EC, epsm_safe_write_byte,   $00  ; CPX <>epsm_safe_write_byte
write_epsm_value $F0, $00,                    $60  ; BEQ #$00
write_epsm_value $F5, epsm_safe_write_byte,   $60  ; SBC <epsm_safe_write_byte,X
write_epsm_value $F9, $00,                    $00  ; SBC $0000,Y
write_epsm_value $FD, epsm_safe_write_byte,   $00  ; SBC <>epsm_safe_write_byte,X

; Safely writes the provided value to the EPSM in a way that works around OUT delay.
; Inputs: A = $4016 write value
; Clobbers: A, X, N, V, Z, C, epsm_safe_write_byte
.proc write_to_epsm
    tax
    and #$fc
    asl
    sta bhop_ptr+0
    lda #>epsm_write_handlers
    adc #$00
    sta bhop_ptr+1

    txa
    ldx #$00
    stx epsm_safe_write_byte
    jmp (bhop_ptr)
.endproc

.macro write_epsm_data_byte original_byte
    lda original_byte
    and #$F0
    ora #$0A
    jsr write_to_epsm ; clobbers A, X
    lda original_byte
    .repeat 4
    asl
    .endrepeat
    jsr write_to_epsm ; clobbers A, X
.endmacro

; writes the upper nybble as the constant #0
.macro write_epsm_data_nybble original_byte
    _write_epcm_const $0A ; clobbers A, X
    lda original_byte
    .repeat 4
    asl
    .endrepeat
    jsr write_to_epsm ; clobbers A, X
.endmacro
