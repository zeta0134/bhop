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

.macro sub16 addr, value
        lda addr
        sbc value
        sta addr
        lda addr+1
        sbc #0
        sta addr+1
.endmacro

.endif