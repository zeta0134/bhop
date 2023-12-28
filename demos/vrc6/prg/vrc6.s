.include "vrc6.inc"

.proc initialize_vrc6
	; use vertical mirroring, normal CIRAM nametables, and all 8 1k banks
	; this also enables access to PRGRAM if present
	lda #VRC6_PPU_STYLE_VERTICAL
	sta VRC6_PPU_BANKING_STYLE

	; map the first 8 1k banks sequentially in memory. For our demo we don't need
	; anything more complicated than this
	lda #0
	sta VRC6_CHR_SELECT_R0
	lda #1
	sta VRC6_CHR_SELECT_R1
	lda #2
	sta VRC6_CHR_SELECT_R2
	lda #3
	sta VRC6_CHR_SELECT_R3
	lda #4
	sta VRC6_CHR_SELECT_R4
	lda #5
	sta VRC6_CHR_SELECT_R5
	lda #6
	sta VRC6_CHR_SELECT_R6
	lda #7
	sta VRC6_CHR_SELECT_R7

	; map the non-fixed program memory into place, so we have a solid 32k
	; of memory at start

	

	rts
.endproc