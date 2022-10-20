; Credit to blargg for the idea and original implementation, and to PinoBatch
; for helping me to understand the technique in greater detail.
; Tables and IRQ routine referenced from http://slack.net/~ant/misc/nes-saw/
; (I'm planning to expand these later to support lower notes than the original proof of concept)

.export blarggsaw_irq

.segment BHOP_ZP_SEGMENT

table_entry: .res 1
table_pos: .res 1
saw_volume: .res 1


.segment BHOP_PLAYER_SEGMENT

blarggsaw_irq:  
      pha                     ; save A and X
      txa
      pha
      ldx   table_pos         ; next period entry
      lda   blarggsaw_note_periods,x
      bmi   mid_wave
      lda   saw_volume        ; beginning of new saw
      sta   $4011
      ldx   table_entry
      lda   blarggsaw_note_periods,x
      ora   #$80              ; (first entry's high bit isn't set)
mid_wave:
      sta   $4010             ; set DMC period
      inx
      stx   table_pos
      pla                     ; restore X
      tax
      lda   #$1F              ; restart DMC as late as possible
      sta   $4015
      pla                     ; restore A
      rti

blarggsaw_note_offsets:     ; offset into note_periods for a given MIDI note
      .byte $00,$06,$0C,$12,$18,$1E,$23,$29,$2E,$34,$39,$3D,$42,$47,$4D,$53
      .byte $57,$5B,$5F,$63,$67,$6A,$6D,$70,$74,$77,$7B,$7E,$81,$84,$87,$8A
      .byte $8D,$90,$93,$96,$9A,$9D,$A0,$A3,$A6,$A9

blarggsaw_note_periods:     ; set of DMC periods for a particular note
                  ; high bit cleared in first entries
      .byte $00,$80,$80,$80,$80,$8A
      .byte $00,$80,$80,$82,$82,$88
      .byte $00,$80,$81,$84,$84,$86
      .byte $00,$80,$80,$81,$8B,$8B
      .byte $00,$80,$80,$86,$89,$8A
      .byte $00,$80,$80,$83,$8C
      .byte $00,$80,$80,$89,$8D,$8D
      .byte $00,$80,$81,$89,$8B
      .byte $00,$80,$82,$8D,$8D,$8E
      .byte $00,$80,$86,$88,$8D
      .byte $00,$80,$82,$8D
      .byte $00,$82,$87,$8A,$8D
      .byte $00,$80,$8B,$8D,$8E
      .byte $00,$86,$89,$8C,$8D,$8E
      .byte $00,$85,$8C,$8D,$8E,$8E
      .byte $00,$83,$8C,$8C
      .byte $00,$88,$89,$8B
      .byte $00,$87,$8B,$8D
      .byte $01,$87,$8B,$8D
      .byte $00,$88,$8E,$8E
      .byte $01,$85,$8D
      .byte $01,$87,$8D
      .byte $00,$8B,$8D
      .byte $03,$8B,$8D,$8E
      .byte $01,$8C,$8D
      .byte $05,$8B,$8D,$8E
      .byte $08,$88,$8B
      .byte $07,$89,$8C
      .byte $06,$8A,$8D
      .byte $07,$8A,$8E
      .byte $06,$8C,$8E
      .byte $08,$8C,$8D
      .byte $08,$8D,$8D
      .byte $0B,$8C,$8C
      .byte $0A,$8C,$8E
      .byte $0D,$8E,$8E,$8E
      .byte $0B,$8D,$8E
      .byte $0B,$8E,$8E
      .byte $0D,$8D,$8D
      .byte $0D,$8D,$8E
      .byte $0D,$8E,$8E
      .byte $0E,$8E,$8E
      .byte $00

; TODO: perhaps be less stupid about this

.align 64

all_00_byte: .byte $00

.align 64

all_ff_byte: .byte $FF