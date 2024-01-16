
NSF_REGION_NTSC = %00
NSF_REGION_PAL  = $01
NSF_REGION_DUAL = $10

NSF_EXPANSION_VRC6 = 0
NSF_EXPANSION_VRC7 = 0 
NSF_EXPANSION_FDS  = 0
NSF_EXPANSION_MMC5 = 0
NSF_EXPANSION_N163 = 0
NSF_EXPANSION_5B   = 0
NSF_EXPANSION_VT02 = 0
NSF_EXPANSION_FLAGS = NSF_EXPANSION_VRC6 << 0 | NSF_EXPANSION_VRC7 << 1 | NSF_EXPANSION_FDS << 2 | NSF_EXPANSION_MMC5 << 3 | NSF_EXPANSION_N163 << 4 | NSF_EXPANSION_5B << 5 | NSF_EXPANSION_VT02 << 6

NSF_BANK_BLOCK_8000 = $5FF8
NSF_BANK_BLOCK_9000 = $5FF9
NSF_BANK_BLOCK_A000 = $5FFA
NSF_BANK_BLOCK_B000 = $5FFB
NSF_BANK_BLOCK_C000 = $5FFC
NSF_BANK_BLOCK_D000 = $5FFD
NSF_BANK_BLOCK_E000 = $5FFE
NSF_BANK_BLOCK_F000 = $5FFF

NSF2_FEATURE_IRQ                    = 0
NSF2_FEATURE_NO_RETURN_INIT         = 0
NSF2_FEATURE_NO_PLAY_SUBROUTINE     = 0
NSF2_FEATURE_MANDATORY_NSFE_CHUNK   = 1
NSF2_FEATURE_FLAGS = NSF2_FEATURE_IRQ << 4 | NSF2_FEATURE_NO_RETURN_INIT << 5 | NSF2_FEATURE_NO_PLAY_SUBROUTINE << 6 | NSF2_FEATURE_MANDATORY_NSFE_CHUNK << 7