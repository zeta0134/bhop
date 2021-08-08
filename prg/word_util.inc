.ifndef _WORD_UTIL_INC
_WORD_UTIL_INC := 1

.macro st16 addr, value
        lda #<value
        sta addr
        lda #>value
        sta addr+1
.endmacro

.macro inc16 addr
.scope
        inc addr
        bne no_carry
        inc addr+1
no_carry:
.endscope
.endmacro

.macro dec16 addr
.scope
        bit addr 
        dec addr
        lda #$FF
        cmp addr
        bne no_carry
        dec addr+1
no_carry:
.endscope
.endmacro

.macro mov16 destination, source
        lda source
        sta destination
        lda source+1
        sta destination+1
.endmacro

; unsigned
.macro add16 addr, value
        lda value
        adc addr
        sta addr
        lda #0
        adc addr+1
        sta addr+1
.endmacro

; for when the value to add is already in a (clobbers a)
.macro add16a addr
        adc addr
        sta addr
        lda #0
        adc addr+1
        sta addr+1
.endmacro

; signed
.macro sadd16 addr, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc addr
        sta addr
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc addr+1
        sta addr+1

.endscope
.endmacro

; same as above, but the value to add is already in a
; (useful in situations where A came from somewhere unusual)
.macro sadd16a addr
.scope
        ; preserve a
        pha
        ; handle the low byte normally
        clc
        adc addr
        sta addr
        ; sign-extend the high bit into the high byte
        pla
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc addr+1
        sta addr+1
.endscope
.endmacro

; signed, with x offset on the addr
.macro sadd16x addr, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc addr, x
        sta addr, x
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc addr+1, x
        sta addr+1, x

.endscope
.endmacro

; signed, with y offset on the addr
.macro sadd16y addr, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc addr, y
        sta addr, y
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc addr+1, y
        sta addr+1, y

.endscope
.endmacro

; add a signed byte, stored in value, to a 16bit word
; whose component bytes are stored in the provided tables, and
; indexed by x
; clobbers a, flags
.macro sadd16_split_x low_table, high_table, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc low_table, x
        sta low_table, x
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc high_table, x
        sta high_table, x
.endscope
.endmacro

; add a signed byte, stored in value, to a 16bit word
; whose component bytes are stored in the provided tables, and
; indexed by y
; clobbers a, flags
.macro sadd16_split_y low_table, high_table, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc low_table, y
        sta low_table, y
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry 
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc high_table, y
        sta high_table, y
.endscope
.endmacro

.macro sub16 addr, value
        lda addr
        sbc value
        sta addr
        lda addr+1
        sbc #0
        sta addr+1
.endmacro

.endif