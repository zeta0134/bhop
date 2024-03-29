; Note: very, very incomplete.

; === PRG BANKING ===

MMC5_PRG_MODE = $5100
MMC5_PRG_MODE_ONE_32K_BANK = $0
MMC5_PRG_MODE_TWO_16K_BANKS = $1
MMC5_PRG_MODE_ONE_16K_BANK_AND_2_8K_BANKS = $2
MMC5_PRG_MODE_FOUR_8K_BANKS = $3

MMC5_PRG_RAM_BANK = $5113

MMC5_MODE_0_PRG_ROM_BANK = $5117

MMC5_MODE_1_PRG_ROM_8000 = $5115
MMC5_MODE_1_PRG_ROM_C000 = $5117

MMC5_MODE_2_PRG_ROM_8000 = $5115
MMC5_MODE_2_PRG_ROM_C000 = $5116
MMC5_MODE_2_PRG_ROM_E000 = $5117

MMC5_MODE_3_PRG_ROM_8000 = $5114
MMC5_MODE_3_PRG_ROM_A000 = $5115
MMC5_MODE_3_PRG_ROM_C000 = $5116
MMC5_MODE_3_PRG_ROM_E000 = $5117

MMC5_SELECT_RAM_BANK = %00000000
MMC5_SELECT_ROM_BANK = %10000000

; === CHR BANKING ===

MMC5_CHR_MODE = $5101
MMC5_CHR_MODE_ONE_8K_BANK = $0
MMC5_CHR_MODE_TWO_4K_BANKS = $1
MMC5_CHR_MODE_FOUR_2K_BANKS = $2
MMC5_CHR_MODE_EIGHT_1K_BANKS = $3

MMC5_MODE_0_CHR_ROM_0000 = $5127

MMC5_MODE_1_CHR_ROM_0000 = $5123
MMC5_MODE_1_CHR_ROM_1000 = $5127

MMC5_MODE_2_CHR_ROM_0000 = $5121
MMC5_MODE_2_CHR_ROM_0800 = $5123
MMC5_MODE_2_CHR_ROM_1000 = $5125
MMC5_MODE_2_CHR_ROM_1800 = $5127

MMC5_MODE_3_CHR_ROM_0000 = $5120
MMC5_MODE_3_CHR_ROM_0400 = $5121
MMC5_MODE_3_CHR_ROM_0800 = $5122
MMC5_MODE_3_CHR_ROM_0C00 = $5123
MMC5_MODE_3_CHR_ROM_1000 = $5124
MMC5_MODE_3_CHR_ROM_1400 = $5125
MMC5_MODE_3_CHR_ROM_1800 = $5126
MMC5_MODE_3_CHR_ROM_1C00 = $5127

MMC5_MODE_0_BG_ROM_0000 = $512B ; whole table

MMC5_MODE_1_BG_ROM_0000 = $512B
MMC5_MODE_1_BG_ROM_1000 = $512B

MMC5_MODE_2_BG_ROM_0000 = $5129
MMC5_MODE_2_BG_ROM_0800 = $512B
MMC5_MODE_2_BG_ROM_1000 = $5129
MMC5_MODE_2_BG_ROM_1800 = $512B

MMC5_MODE_3_BG_ROM_0000 = $5128
MMC5_MODE_3_BG_ROM_0400 = $5129
MMC5_MODE_3_BG_ROM_0800 = $512A
MMC5_MODE_3_BG_ROM_0C00 = $512B
MMC5_MODE_3_BG_ROM_1000 = $5128
MMC5_MODE_3_BG_ROM_1400 = $5129
MMC5_MODE_3_BG_ROM_1800 = $512A
MMC5_MODE_3_BG_ROM_1C00 = $512B

; === Nametable Mapping ===

MMC5_NAMETABLE_MAPPING = $5105
MMC5_FILL_MODE_TILE = $5106
MMC5_FILL_MODE_PALETTE = $5107

MMC5_NT_CIRAM_0      = 0
MMC5_NT_CIRAM_1      = 1
MMC5_NT_EXTENDED_RAM = 2
MMC5_NT_FILL_MODE    = 3

MMC5_NT_2000_CIRAM_0      = (MMC5_NT_CIRAM_0      << 0)
MMC5_NT_2000_CIRAM_1      = (MMC5_NT_CIRAM_1      << 0)
MMC5_NT_2000_EXTENDED_RAM = (MMC5_NT_EXTENDED_RAM << 0)
MMC5_NT_2000_FILL_MODE    = (MMC5_NT_FILL_MODE    << 0)

MMC5_NT_2400_CIRAM_0      = (MMC5_NT_CIRAM_0      << 2)
MMC5_NT_2400_CIRAM_1      = (MMC5_NT_CIRAM_1      << 2)
MMC5_NT_2400_EXTENDED_RAM = (MMC5_NT_EXTENDED_RAM << 2)
MMC5_NT_2400_FILL_MODE    = (MMC5_NT_FILL_MODE    << 2)

MMC5_NT_2800_CIRAM_0      = (MMC5_NT_CIRAM_0      << 4)
MMC5_NT_2800_CIRAM_1      = (MMC5_NT_CIRAM_1      << 4)
MMC5_NT_2800_EXTENDED_RAM = (MMC5_NT_EXTENDED_RAM << 4)
MMC5_NT_2800_FILL_MODE    = (MMC5_NT_FILL_MODE    << 4)

MMC5_NT_2C00_CIRAM_0      = (MMC5_NT_CIRAM_0      << 6)
MMC5_NT_2C00_CIRAM_1      = (MMC5_NT_CIRAM_1      << 6)
MMC5_NT_2C00_EXTENDED_RAM = (MMC5_NT_EXTENDED_RAM << 6)
MMC5_NT_2C00_FILL_MODE    = (MMC5_NT_FILL_MODE    << 6)

; === AUDIO ===
; (also very incomplete)

MMC5_PCM_MODE = $5010

MMC5_PCM_IRQ_ENABLED = %10000000
MMC5_PCM_READ_MODE   = %00000001
MMC5_PCM_WRITE_MODE  = %00000000

MMC5_RAW_PCM = $5011

