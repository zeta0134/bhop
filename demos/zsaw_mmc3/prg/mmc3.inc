MMC3_BANK_SELECT = $8000
MMC3_BANK_DATA   = $8001
MMC3_MIRRORING   = $A000
MMC3_RAM_PROTECT = $A001
MMC3_IRQ_LATCH   = $C000
MMC3_IRQ_RELOAD  = $C001
MMC3_IRQ_DISABLE = $E000
MMC3_IRQ_ENABLE  = $E001

; project global
MMC3_BANKING_MODE = %01000000

.macro mmc3_select_bank register_index, bank_number
        lda #(MMC3_BANKING_MODE + register_index) ; CHR_2K_LOW
        sta mmc3_bank_select_shadow
        sta MMC3_BANK_SELECT
        lda bank_number
        sta MMC3_BANK_DATA
.endmacro

.ifndef _MMC3_INC
_MMC3_INC := 1

.import initialize_mmc3
.importzp mmc3_bank_select_shadow

.endif