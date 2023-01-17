; Collection of helpers and shortcuts for dealing with PPU registers

.macro set_ppuaddr addr
.if (.match (.left (1, {addr}), #))
  lda #>(.right (.tcount ({addr})-1, {addr}))
  sta PPUADDR
  lda #<(.right (.tcount ({addr})-1, {addr}))
  sta PPUADDR
.else
  ; note: we assume this is a target address, and we also assume the target is
  ; stored in LITTLE endian mode, but PPUADDR expects the address in BIG endian
  ; mode, thus the conversion.
  lda addr+1
  sta PPUADDR
  lda addr
  sta PPUADDR
.endif
.endmacro

.import initialize_ppu
.import initialize_palettes