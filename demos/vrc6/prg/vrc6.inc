VRC6_PRG_SELECT_AT_8000 := $8000
VRC6_PRG_SELECT_AT_C000 := $C000

; There are about a bajillion other, very sillt
; ways that VRC6 can configure its CHR banks and
; nametable selection. For demo producing purposes,
; none of these other modes are useful
VRC6_PPU_BANKING_STYLE := $B003
VRC6_PPU_STYLE_VERTICAL = %11000000
VRC6_PPU_STYLE_HORIZ    = %11000100
                         ; 7 bit  0
                         ; --------
                         ; W.PNMMDD
                         ; | ||||||
                         ; | ||||++- PPU banking mode 0: 8x 1k banks
                         ; | ||++--- Mirroring mode: 0: vertical, 1: horizontal
                         ; | |+------ 0: Nametables come from CIRAM
                         ; | +------- CHR A10 is 1: subject to [mirroring mode above]
                         ; +--------- PRG RAM enable

VRC6_CHR_SELECT_R0 := $D000
VRC6_CHR_SELECT_R1 := $D001
VRC6_CHR_SELECT_R2 := $D002
VRC6_CHR_SELECT_R3 := $D003
VRC6_CHR_SELECT_R4 := $E000
VRC6_CHR_SELECT_R5 := $E001
VRC6_CHR_SELECT_R6 := $E002
VRC6_CHR_SELECT_R7 := $E003


.global initialize_vrc6

