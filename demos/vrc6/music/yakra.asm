; Dn-FamiTracker exported music data: yakra.0cc
;

; Module header
	.word ft_song_list
	.word ft_instrument_list
	.word ft_sample_list
	.word ft_samples
	.word ft_groove_list
	.byte 0 ; flags
	.word 3600 ; NTSC speed
	.word 3000 ; PAL speed

; Instrument pointer list
ft_instrument_list:
	.word ft_inst_0
	.word ft_inst_1
	.word ft_inst_2
	.word ft_inst_3
	.word ft_inst_4
	.word ft_inst_5
	.word ft_inst_6
	.word ft_inst_7
	.word ft_inst_8
	.word ft_inst_9
	.word ft_inst_10
	.word ft_inst_11
	.word ft_inst_12
	.word ft_inst_13
	.word ft_inst_14
	.word ft_inst_15
	.word ft_inst_16
	.word ft_inst_17
	.word ft_inst_18
	.word ft_inst_19

; Instruments
ft_inst_0:
	.byte 0
	.byte $11
	.word ft_seq_2a03_0
	.word ft_seq_2a03_4

ft_inst_1:
	.byte 0
	.byte $15
	.word ft_seq_2a03_5
	.word ft_seq_2a03_2
	.word ft_seq_2a03_9

ft_inst_2:
	.byte 0
	.byte $11
	.word ft_seq_2a03_10
	.word ft_seq_2a03_14

ft_inst_3:
	.byte 0
	.byte $00

ft_inst_4:
	.byte 0
	.byte $07
	.word ft_seq_2a03_15
	.word ft_seq_2a03_11
	.word ft_seq_2a03_7

ft_inst_5:
	.byte 0
	.byte $03
	.word ft_seq_2a03_20
	.word ft_seq_2a03_16

ft_inst_6:
	.byte 0
	.byte $03
	.word ft_seq_2a03_25
	.word ft_seq_2a03_21

ft_inst_7:
	.byte 0
	.byte $13
	.word ft_seq_2a03_30
	.word ft_seq_2a03_26
	.word ft_seq_2a03_19

ft_inst_8:
	.byte 0
	.byte $03
	.word ft_seq_2a03_35
	.word ft_seq_2a03_21

ft_inst_9:
	.byte 0
	.byte $17
	.word ft_seq_2a03_5
	.word ft_seq_2a03_31
	.word ft_seq_2a03_2
	.word ft_seq_2a03_4

ft_inst_10:
	.byte 0
	.byte $11
	.word ft_seq_2a03_40
	.word ft_seq_2a03_4

ft_inst_11:
	.byte 0
	.byte $13
	.word ft_seq_2a03_0
	.word ft_seq_2a03_31
	.word ft_seq_2a03_4

ft_inst_12:
	.byte 0
	.byte $15
	.word ft_seq_2a03_0
	.word ft_seq_2a03_12
	.word ft_seq_2a03_29

ft_inst_13:
	.byte 0
	.byte $03
	.word ft_seq_2a03_45
	.word ft_seq_2a03_36

ft_inst_14:
	.byte 0
	.byte $03
	.word ft_seq_2a03_50
	.word ft_seq_2a03_41

ft_inst_15:
	.byte 0
	.byte $07
	.word ft_seq_2a03_35
	.word ft_seq_2a03_11
	.word ft_seq_2a03_7

ft_inst_16:
	.byte 0
	.byte $13
	.word ft_seq_2a03_60
	.word ft_seq_2a03_51
	.word ft_seq_2a03_24

ft_inst_17:
	.byte 0
	.byte $13
	.word ft_seq_2a03_70
	.word ft_seq_2a03_61
	.word ft_seq_2a03_19

ft_inst_18:
	.byte 0
	.byte $15
	.word ft_seq_2a03_75
	.word ft_seq_2a03_2
	.word ft_seq_2a03_9

ft_inst_19:
	.byte 0
	.byte $15
	.word ft_seq_2a03_80
	.word ft_seq_2a03_12
	.word ft_seq_2a03_29

; Sequences
ft_seq_2a03_0:
	.byte $03, $FF, $00, $00, $0F, $0D, $0E
ft_seq_2a03_2:
	.byte $17, $0B, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $01, $01, $FF, $FF
	.byte $FD, $FD, $FF, $FF, $01, $01, $03
ft_seq_2a03_4:
	.byte $01, $FF, $00, $00, $01
ft_seq_2a03_5:
	.byte $0E, $FF, $00, $00, $06, $0A, $09, $0D, $0B, $0C, $0B, $0B, $0C, $0D, $0D, $0D, $0D, $0D
ft_seq_2a03_7:
	.byte $10, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $FF, $FF, $FF, $FF, $01, $01
ft_seq_2a03_9:
	.byte $04, $FF, $00, $00, $01, $00, $00, $00
ft_seq_2a03_10:
	.byte $01, $FF, $00, $00, $04
ft_seq_2a03_11:
	.byte $02, $FF, $00, $01, $26, $23
ft_seq_2a03_12:
	.byte $0C, $02, $00, $00, $00, $00, $FF, $FE, $00, $02, $01, $01, $02, $00, $FE, $FF
ft_seq_2a03_14:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_15:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_16:
	.byte $0C, $FF, $00, $01, $0C, $09, $0A, $0A, $0A, $0B, $0B, $0B, $0C, $0C, $0D, $0D
ft_seq_2a03_19:
	.byte $02, $FF, $00, $00, $01, $00
ft_seq_2a03_20:
	.byte $02, $FF, $00, $00, $0D, $00
ft_seq_2a03_21:
	.byte $02, $FF, $00, $01, $31, $2C
ft_seq_2a03_24:
	.byte $02, $FF, $00, $00, $01, $00
ft_seq_2a03_25:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_26:
	.byte $02, $01, $00, $01, $05, $0C
ft_seq_2a03_29:
	.byte $03, $FF, $00, $00, $02, $00, $01
ft_seq_2a03_30:
	.byte $0A, $FF, $00, $00, $0D, $0D, $0A, $08, $07, $05, $04, $03, $01, $00
ft_seq_2a03_31:
	.byte $03, $01, $00, $02, $00, $07, $F9
ft_seq_2a03_35:
	.byte $03, $FF, $00, $00, $0F, $0F, $00
ft_seq_2a03_36:
	.byte $04, $FF, $00, $02, $00, $FD, $FE, $FF
ft_seq_2a03_40:
	.byte $03, $FF, $00, $00, $0D, $0E, $06
ft_seq_2a03_41:
	.byte $03, $02, $00, $01, $09, $0B, $0C
ft_seq_2a03_45:
	.byte $05, $FF, $00, $00, $0F, $0F, $0F, $0F, $00
ft_seq_2a03_50:
	.byte $39, $FF, $00, $00, $0E, $0C, $0B, $0A, $0A, $09, $08, $08, $07, $07, $06, $06, $05, $05, $05, $05
	.byte $04, $04, $04, $03, $03, $03, $02, $02, $02, $02, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00
ft_seq_2a03_51:
	.byte $02, $01, $00, $01, $0B, $0D
ft_seq_2a03_60:
	.byte $09, $FF, $00, $00, $0C, $09, $08, $07, $05, $04, $03, $03, $00
ft_seq_2a03_61:
	.byte $02, $01, $00, $01, $05, $0C
ft_seq_2a03_70:
	.byte $0E, $FF, $00, $00, $0D, $0D, $0A, $0D, $07, $05, $08, $03, $01, $00, $00, $00, $00, $00
ft_seq_2a03_75:
	.byte $09, $FF, $00, $00, $0C, $0B, $0B, $0C, $0D, $0D, $0D, $0D, $0D
ft_seq_2a03_80:
	.byte $0F, $FF, $00, $00, $0F, $07, $0F, $07, $0F, $07, $0F, $07, $0F, $07, $0F, $07, $0F, $07, $0E

; DPCM instrument list (pitch, sample index)
ft_sample_list:

; DPCM samples list (location, size, bank)
ft_samples:


; Groove list
ft_groove_list:
	.byte $00
; Grooves (size, terms)

; Song pointer list
ft_song_list:
	.word ft_song_0

; Song info
ft_song_0:
	.word ft_s0_frames
	.byte 14	; frame count
	.byte 48	; pattern length
	.byte 4	; speed
	.byte 180	; tempo
	.byte 0	; groove position
	.byte 0	; initial bank


;
; Pattern and frame data for all songs below
;

; Bank 0
ft_s0_frames:
	.word ft_s0f0
	.word ft_s0f1
	.word ft_s0f2
	.word ft_s0f3
	.word ft_s0f4
	.word ft_s0f5
	.word ft_s0f6
	.word ft_s0f7
	.word ft_s0f8
	.word ft_s0f9
	.word ft_s0f10
	.word ft_s0f11
	.word ft_s0f12
	.word ft_s0f13
ft_s0f0:
	.word ft_s0p6c0, ft_s0p10c1, ft_s0p10c2, ft_s0p3c3, ft_s0p0c4
ft_s0f1:
	.word ft_s0p7c0, ft_s0p11c1, ft_s0p11c2, ft_s0p8c3, ft_s0p0c4
ft_s0f2:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f3:
	.word ft_s0p0c0, ft_s0p1c1, ft_s0p2c2, ft_s0p1c3, ft_s0p0c4
ft_s0f4:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f5:
	.word ft_s0p0c0, ft_s0p2c1, ft_s0p8c2, ft_s0p2c3, ft_s0p0c4
ft_s0f6:
	.word ft_s0p1c0, ft_s0p3c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f7:
	.word ft_s0p1c0, ft_s0p4c1, ft_s0p3c2, ft_s0p1c3, ft_s0p0c4
ft_s0f8:
	.word ft_s0p1c0, ft_s0p3c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f9:
	.word ft_s0p1c0, ft_s0p5c1, ft_s0p9c2, ft_s0p2c3, ft_s0p0c4
ft_s0f10:
	.word ft_s0p2c0, ft_s0p6c1, ft_s0p4c2, ft_s0p4c3, ft_s0p0c4
ft_s0f11:
	.word ft_s0p3c0, ft_s0p7c1, ft_s0p5c2, ft_s0p5c3, ft_s0p0c4
ft_s0f12:
	.word ft_s0p4c0, ft_s0p8c1, ft_s0p6c2, ft_s0p6c3, ft_s0p0c4
ft_s0f13:
	.word ft_s0p5c0, ft_s0p9c1, ft_s0p7c2, ft_s0p7c3, ft_s0p0c4
; Bank 0
ft_s0p0c0:
	.byte $82, $00, $E0, $F8, $2C, $E2, $FF, $1B, $E0, $F6, $27, $F1, $2C, $F6, $25, $E2, $FF, $1B, $E0, $F7
	.byte $23, $F1, $25, $F6, $25, $F1, $23, $F5, $27, $E2, $FF, $1B, $E0, $F8, $2D, $E2, $FF, $1E, $E0, $F6
	.byte $28, $E2, $FF, $1E, $E0, $F6, $24, $E2, $FF, $1E, $E0, $F8, $2D, $E2, $FF, $1E, $E0, $F6, $28, $F1
	.byte $2D, $F6, $24, $E2, $FF, $1B, $E0, $F8, $2C, $E2, $FF, $1B, $E0, $F6, $27, $F1, $2C, $F6, $25, $E2
	.byte $FF, $1B, $E0, $F7, $23, $F1, $25, $F6, $25, $F1, $23, $F5, $27, $E2, $FF, $1B, $E0, $F8, $2F, $E2
	.byte $FF, $1C, $E0, $F6, $2A, $E2, $FF, $1C, $E0, $F6, $25, $E2, $FF, $1C, $E0, $F8, $2D, $E2, $FF, $19
	.byte $E0, $F6, $28, $E2, $FF, $19, $E0, $F6, $23, $83, $E2, $FF, $19, $00

; Bank 0
ft_s0p0c1:
	.byte $E2, $FF, $1B, $00, $7F, $02, $E1, $FA, $20, $00, $F1, $00, $00, $FC, $20, $01, $F1, $00, $01, $FA
	.byte $20, $00, $F1, $00, $00, $FC, $27, $04, $FB, $00, $00, $FA, $00, $00, $F9, $00, $00, $F1, $00, $01
	.byte $FA, $20, $00, $F1, $00, $00, $FC, $27, $01, $F1, $00, $01, $FA, $20, $00, $F1, $00, $00, $FC, $27
	.byte $08, $FB, $00, $00, $FA, $00, $00, $F9, $00, $00, $F1, $00, $01, $82, $00, $80, $24, $FA, $27, $F1
	.byte $00, $FB, $28, $83, $F1, $00, $00

; Bank 0
ft_s0p0c2:
	.byte $E4, $14, $00, $E3, $14, $01, $7F, $00, $E4, $14, $01, $E6, $20, $02, $7F, $00, $E4, $14, $00, $7F
	.byte $00, $12, $01, $7F, $01, $12, $01, $E8, $25, $03, $E4, $14, $01, $14, $00, $E3, $14, $01, $7F, $00
	.byte $E4, $14, $01, $E6, $20, $02, $82, $00, $7F, $E4, $14, $7F, $15, $83, $E3, $15, $02, $E4, $15, $00
	.byte $7F, $00, $E6, $12, $03, $E5, $12, $00, $7F, $00

; Bank 0
ft_s0p0c3:
	.byte $E5, $FF, $1D, $03, $1D, $01, $80, $22, $1D, $03, $E5, $1D, $01, $1D, $03, $1D, $01, $E7, $FC, $1D
	.byte $00, $F5, $00, $00, $80, $20, $FF, $1D, $01, $E5, $1D, $01, $1D, $03, $1D, $01, $80, $22, $1D, $03
	.byte $E5, $1D, $01, $1D, $03, $1D, $01, $E7, $FC, $1D, $00, $F5, $00, $00, $80, $20, $FF, $1D, $01, $E5
	.byte $1D, $01

; Bank 0
ft_s0p0c4:
	.byte $00, $2F

; Bank 0
ft_s0p1c0:
	.byte $82, $00, $E0, $F8, $2F, $E2, $FF, $1E, $E0, $F6, $2A, $F1, $2F, $F6, $28, $E2, $FF, $1E, $E0, $F7
	.byte $27, $F1, $28, $F6, $28, $F1, $26, $F5, $2A, $E2, $FF, $1E, $E0, $F8, $30, $E2, $FF, $21, $E0, $F6
	.byte $2B, $E2, $FF, $21, $E0, $F6, $26, $E2, $FF, $21, $E0, $F8, $30, $E2, $FF, $21, $E0, $F6, $2B, $F1
	.byte $30, $F6, $26, $E2, $FF, $1E, $E0, $F8, $2F, $E2, $FF, $1E, $E0, $F6, $2A, $F1, $2F, $F6, $28, $E2
	.byte $FF, $1E, $E0, $F7, $27, $F1, $28, $F6, $28, $F1, $26, $F5, $2A, $E2, $FF, $1E, $E0, $F8, $32, $E2
	.byte $FF, $1F, $E0, $F6, $2D, $E2, $FF, $1F, $E0, $F6, $28, $E2, $FF, $1F, $E0, $F8, $30, $E2, $FF, $1C
	.byte $E0, $F6, $2B, $E2, $FF, $1C, $E0, $F6, $26, $83, $E2, $FF, $1C, $00

; Bank 0
ft_s0p1c1:
	.byte $E1, $FC, $2A, $04, $F1, $00, $00, $FB, $25, $04, $F1, $00, $00, $FB, $28, $02, $F1, $00, $00, $FA
	.byte $27, $02, $F1, $00, $00, $FA, $25, $02, $82, $00, $F1, $00, $80, $24, $FA, $23, $F1, $00, $FA, $23
	.byte $F1, $00, $FB, $25, $F8, $00, $83, $E1, $FC, $27, $08, $FB, $00, $00, $FA, $00, $00, $F9, $00, $00
	.byte $F1, $00, $05

; Bank 0
ft_s0p1c2:
	.byte $E4, $17, $00, $E3, $17, $01, $7F, $00, $E4, $17, $01, $E6, $23, $02, $7F, $00, $E4, $17, $00, $7F
	.byte $00, $15, $01, $7F, $01, $15, $01, $E8, $28, $03, $E4, $17, $01, $17, $00, $E3, $17, $01, $7F, $00
	.byte $E4, $17, $01, $E6, $23, $02, $82, $00, $7F, $E4, $17, $7F, $18, $83, $E3, $18, $02, $E4, $18, $00
	.byte $7F, $00, $E6, $15, $03, $E5, $15, $00, $7F, $00

; Bank 0
ft_s0p1c3:
	.byte $E5, $FF, $1D, $03, $1D, $01, $80, $22, $1D, $03, $E5, $1D, $01, $1D, $03, $1D, $01, $E7, $FC, $1D
	.byte $00, $F5, $00, $00, $80, $20, $FF, $1D, $01, $E5, $1D, $01, $1D, $03, $1D, $01, $80, $22, $1D, $03
	.byte $E5, $1D, $01, $1D, $03, $82, $01, $1D, $E7, $1D, $1D, $83, $1D, $01

; Bank 0
ft_s0p2c0:
	.byte $82, $00, $E0, $F9, $33, $F1, $26, $F7, $2E, $F1, $33, $F7, $29, $F1, $2E, $F9, $33, $F1, $29, $F7
	.byte $2E, $F1, $33, $F7, $29, $F1, $2E, $FA, $32, $FA, $00, $F9, $00, $F8, $00, $F7, $00, $F1, $00, $F9
	.byte $33, $F1, $32, $F7, $2E, $F1, $33, $F7, $29, $F1, $2E, $F9, $32, $F6, $00, $F7, $00, $F8, $00, $F9
	.byte $00, $F1, $00, $F9, $35, $F9, $00, $F8, $00, $F7, $00, $F6, $00, $F1, $00, $F9, $33, $F1, $35, $F8
	.byte $35, $F1, $33, $F8, $33, $F1, $35, $F9, $2E, $F1, $33, $F8, $29, $F1, $2E, $F8, $24, $83, $F1, $29
	.byte $00

; Bank 0
ft_s0p2c1:
	.byte $E1, $FC, $2A, $04, $F1, $00, $00, $FB, $25, $04, $F1, $00, $00, $FB, $28, $02, $F1, $00, $00, $FA
	.byte $27, $02, $F1, $00, $00, $FA, $25, $02, $82, $00, $F1, $00, $80, $24, $FA, $24, $F1, $00, $FA, $24
	.byte $F1, $00, $FB, $25, $F8, $00, $83, $E1, $FC, $27, $07, $FB, $00, $00, $FA, $00, $00, $F9, $00, $00
	.byte $F1, $00, $06

; Bank 0
ft_s0p2c2:
	.byte $E4, $14, $00, $E3, $14, $01, $7F, $00, $E4, $14, $01, $E6, $20, $02, $7F, $00, $E4, $14, $00, $7F
	.byte $00, $12, $01, $7F, $01, $12, $01, $E8, $25, $03, $E4, $14, $01, $14, $00, $E3, $14, $01, $7F, $00
	.byte $E4, $14, $01, $E6, $20, $02, $82, $00, $7F, $E4, $14, $7F, $15, $83, $E3, $15, $02, $E4, $15, $00
	.byte $7F, $00, $E6, $12, $01, $12, $01, $E5, $12, $00, $7F, $00

; Bank 0
ft_s0p2c3:
	.byte $E5, $FF, $1D, $03, $1D, $01, $80, $22, $1D, $03, $E5, $1D, $01, $1D, $03, $1D, $01, $E7, $FC, $1D
	.byte $00, $F5, $00, $00, $80, $20, $FF, $1D, $01, $E5, $1D, $01, $F9, $1D, $03, $82, $01, $F7, $1D, $F9
	.byte $1D, $F7, $1D, $F7, $1D, $83, $F9, $1D, $03, $F7, $1D, $01, $EE, $FF, $1D, $05

; Bank 0
ft_s0p3c0:
	.byte $82, $00, $E0, $F9, $32, $F1, $25, $F7, $2D, $F1, $32, $F7, $28, $F1, $2D, $F9, $32, $F1, $28, $F7
	.byte $2D, $F1, $32, $F7, $28, $F1, $2D, $FA, $31, $FA, $00, $F9, $00, $F8, $00, $F7, $00, $F1, $00, $F9
	.byte $32, $F1, $31, $F7, $2D, $F1, $32, $F7, $28, $F1, $2D, $F9, $31, $F6, $00, $F7, $00, $F8, $00, $F9
	.byte $00, $F1, $00, $F9, $34, $F9, $00, $F8, $00, $F7, $00, $F6, $00, $F1, $00, $F9, $32, $F1, $34, $F8
	.byte $34, $F1, $32, $F8, $32, $F1, $34, $F9, $2D, $F1, $32, $F8, $28, $F1, $2D, $F8, $23, $83, $F1, $28
	.byte $00

; Bank 0
ft_s0p3c1:
	.byte $E1, $FF, $1E, $00, $7F, $02, $FA, $23, $00, $F1, $00, $00, $FC, $23, $01, $F1, $00, $01, $FA, $23
	.byte $00, $F1, $00, $00, $FC, $2A, $04, $FB, $00, $00, $FA, $00, $00, $F9, $00, $00, $F1, $00, $01, $FA
	.byte $23, $00, $F1, $00, $00, $FC, $2A, $01, $F1, $00, $01, $FA, $23, $00, $F1, $00, $00, $FC, $2A, $08
	.byte $FB, $00, $00, $FA, $00, $00, $F9, $00, $00, $F1, $00, $01, $82, $00, $80, $24, $FA, $2A, $F1, $00
	.byte $FB, $2B, $83, $F1, $00, $00

; Bank 0
ft_s0p3c2:
	.byte $E4, $17, $00, $E3, $17, $01, $7F, $00, $E4, $17, $01, $E6, $23, $02, $7F, $00, $E4, $17, $00, $7F
	.byte $00, $15, $01, $7F, $01, $15, $01, $E8, $28, $03, $E4, $17, $01, $17, $00, $E3, $17, $01, $7F, $00
	.byte $E4, $17, $01, $E6, $23, $02, $82, $00, $7F, $E4, $17, $7F, $18, $83, $E3, $18, $02, $E4, $18, $00
	.byte $7F, $00, $E6, $15, $01, $15, $01, $E5, $15, $00, $7F, $00

; Bank 0
ft_s0p3c3:
	.byte $EE, $FF, $1D, $05, $82, $01, $E5, $F8, $1D, $FA, $1D, $FC, $1D, $FF, $1D, $FF, $1D, $FF, $1D, $83
	.byte $E7, $FF, $1D, $03, $E5, $1D, $19

; Bank 0
ft_s0p4c0:
	.byte $82, $00, $E0, $F9, $25, $F1, $23, $F7, $23, $F1, $25, $F7, $25, $F1, $23, $F9, $27, $F1, $25, $F7
	.byte $25, $F1, $27, $F7, $27, $F1, $25, $FA, $28, $F1, $27, $F8, $27, $F1, $28, $F8, $28, $F1, $27, $FA
	.byte $2A, $F1, $28, $F8, $28, $F1, $2A, $F8, $2A, $F1, $28, $FA, $2C, $F1, $2A, $F8, $2A, $F1, $2C, $F8
	.byte $2C, $F1, $2A, $EC, $F9, $2E, $F9, $00, $F8, $00, $F7, $00, $83, $F0, $00, $01, $82, $00, $E0, $FB
	.byte $2F, $F1, $2E, $F9, $2E, $F1, $2F, $F9, $2F, $F1, $2E, $EC, $FB, $31, $FB, $00, $FA, $00, $F9, $00
	.byte $83, $F0, $00, $01

; Bank 0
ft_s0p4c1:
	.byte $E1, $FC, $2D, $04, $F1, $00, $00, $FB, $28, $04, $F1, $00, $00, $FB, $2B, $02, $F1, $00, $00, $FA
	.byte $2A, $02, $F1, $00, $00, $FA, $28, $02, $82, $00, $F1, $00, $80, $24, $FA, $26, $F1, $00, $FA, $26
	.byte $F1, $00, $FB, $28, $F8, $00, $83, $E1, $FC, $2A, $08, $FB, $00, $00, $FA, $00, $00, $F9, $00, $00
	.byte $F1, $00, $05

; Bank 0
ft_s0p4c2:
	.byte $E6, $21, $01, $7F, $01, $82, $00, $E4, $21, $7F, $25, $7F, $27, $7F, $2C, $7F, $83, $E6, $2B, $04
	.byte $82, $00, $7F, $E4, $22, $7F, $EF, $22, $7F, $E3, $22, $7F, $83, $E6, $2B, $04, $7F, $00, $2E, $04
	.byte $7F, $00, $E3, $2B, $00, $22, $00, $E4, $22, $01, $EF, $22, $01, $ED, $26, $00, $E3, $20, $00, $E4
	.byte $20, $01, $EF, $20, $01

; Bank 0
ft_s0p4c3:
	.byte $EE, $FF, $1D, $03, $82, $01, $F8, $1D, $E5, $FD, $1D, $FE, $1D, $FF, $1D, $83, $EE, $1D, $05, $E7
	.byte $1D, $01, $1D, $01, $1D, $01, $EE, $FF, $1D, $05, $FC, $1D, $05, $82, $01, $E5, $FA, $1D, $F6, $1D
	.byte $F6, $1D, $F9, $1D, $F8, $1D, $83, $F8, $1D, $01

; Bank 0
ft_s0p5c0:
	.byte $82, $00, $80, $26, $FD, $33, $F9, $00, $F8, $00, $F7, $00, $83, $F0, $00, $01, $82, $00, $FC, $33
	.byte $F9, $00, $F8, $00, $F7, $00, $83, $F0, $00, $01, $82, $00, $EA, $F6, $29, $F7, $2A, $F8, $2C, $F9
	.byte $2E, $FA, $2F, $FB, $31, $80, $26, $FD, $33, $F9, $00, $F8, $00, $F7, $00, $83, $F0, $00, $01, $82
	.byte $00, $FC, $33, $F9, $00, $F8, $00, $F7, $00, $83, $F0, $00, $01, $82, $00, $EA, $F6, $29, $F7, $2A
	.byte $F8, $2C, $F9, $2E, $FA, $2F, $FB, $31, $80, $26, $F8, $33, $F0, $00, $F9, $33, $F0, $00, $FA, $33
	.byte $F0, $00, $FD, $33, $F9, $00, $F8, $00, $F7, $00, $F0, $00, $83, $86, $03, $00, $00

; Bank 0
ft_s0p5c1:
	.byte $E1, $FC, $2D, $04, $F1, $00, $00, $FB, $28, $04, $F1, $00, $00, $FB, $2B, $02, $F1, $00, $00, $FA
	.byte $2A, $02, $F1, $00, $00, $FA, $28, $02, $82, $00, $F1, $00, $80, $24, $FA, $27, $F1, $00, $FA, $27
	.byte $F1, $00, $FB, $28, $F8, $00, $83, $FC, $2A, $08, $FB, $00, $00, $FA, $00, $00, $F9, $00, $00, $F1
	.byte $00, $05

; Bank 0
ft_s0p5c2:
	.byte $E6, $20, $01, $7F, $01, $82, $00, $E4, $20, $7F, $24, $7F, $26, $7F, $2B, $7F, $83, $E6, $2A, $04
	.byte $82, $00, $7F, $E4, $21, $7F, $EF, $21, $7F, $E3, $21, $7F, $83, $E6, $2A, $04, $7F, $00, $2D, $04
	.byte $7F, $00, $E3, $2B, $00, $21, $00, $E4, $21, $01, $EF, $21, $01, $ED, $26, $00, $E3, $1F, $00, $E4
	.byte $1F, $01, $EF, $1F, $01

; Bank 0
ft_s0p5c3:
	.byte $E7, $FF, $1D, $03, $82, $01, $E5, $FC, $1D, $FC, $1D, $FD, $1D, $FD, $1D, $83, $EE, $FF, $1D, $05
	.byte $E7, $1D, $01, $1D, $01, $1D, $01, $EE, $FF, $1D, $05, $FC, $1D, $05, $82, $01, $E5, $FA, $1D, $F6
	.byte $1D, $F6, $1D, $F9, $1D, $F6, $1D, $83, $F6, $1D, $01

; Bank 0
ft_s0p6c0:
	.byte $82, $00, $E0, $FD, $37, $F1, $00, $FA, $32, $F1, $37, $FB, $2D, $F1, $32, $FB, $2C, $F1, $2D, $FC
	.byte $31, $F1, $2C, $FD, $36, $F1, $31, $FD, $35, $F1, $36, $FA, $30, $F1, $35, $FB, $2B, $F1, $30, $FB
	.byte $2A, $F1, $2B, $FC, $2F, $F1, $2A, $FD, $34, $86, $02, $F1, $2F, $83, $FB, $33, $17

; Bank 0
ft_s0p6c1:
	.byte $80, $24, $F8, $20, $01, $7F, $01, $82, $00, $20, $7F, $20, $7F, $20, $7F, $20, $7F, $E0, $F8, $2D
	.byte $F8, $00, $F7, $00, $F6, $00, $F5, $00, $7F, $80, $24, $F8, $20, $7F, $20, $7F, $20, $7F, $E0, $F7
	.byte $2D, $F4, $00, $F5, $00, $F6, $00, $F7, $00, $7F, $F7, $30, $F7, $00, $F6, $00, $F5, $00, $F4, $00
	.byte $7F, $83, $80, $24, $F8, $1D, $03, $7F, $01, $F8, $20, $03, $7F, $01

; Bank 0
ft_s0p6c2:
	.byte $E4, $1E, $03, $EF, $1E, $01, $E4, $22, $03, $EF, $22, $01, $E4, $21, $03, $EF, $21, $01, $E4, $20
	.byte $03, $EF, $20, $01, $82, $00, $E6, $1B, $9B, $02, $00, $1B, $9B, $02, $00, $1B, $9B, $02, $00, $83
	.byte $20, $03, $7F, $01, $82, $00, $1D, $9B, $02, $00, $1D, $9B, $02, $00, $1D, $9B, $02, $00, $83, $23
	.byte $01, $23, $01, $E8, $23, $01

; Bank 0
ft_s0p6c3:
	.byte $E5, $FF, $1D, $03, $1D, $01, $80, $20, $FC, $1D, $03, $E5, $FF, $1D, $01, $1D, $03, $1D, $01, $80
	.byte $20, $FC, $1D, $03, $82, $01, $E5, $FF, $1D, $E7, $FC, $1D, $FC, $1D, $FC, $1D, $83, $EE, $FF, $1D
	.byte $05, $82, $01, $E7, $FC, $1D, $FC, $1D, $FC, $1D, $FF, $1D, $FF, $1D, $83, $FA, $1D, $01

; Bank 0
ft_s0p7c0:
	.byte $E0, $FC, $33, $01, $F8, $00, $02, $F9, $00, $02, $FA, $00, $03, $82, $05, $EC, $F9, $33, $F8, $00
	.byte $F7, $00, $F6, $00, $83, $F5, $00, $03, $82, $01, $F4, $00, $F3, $00, $F2, $00, $83, $F1, $00, $01

; Bank 0
ft_s0p7c1:
	.byte $80, $24, $F8, $1F, $01, $7F, $01, $82, $00, $1F, $7F, $1F, $7F, $1F, $7F, $1F, $7F, $E0, $F8, $2C
	.byte $F8, $00, $F7, $00, $F6, $00, $F5, $00, $7F, $80, $24, $F8, $1F, $7F, $1F, $7F, $1F, $7F, $E0, $F7
	.byte $2C, $F4, $00, $F5, $00, $F6, $00, $F7, $00, $7F, $F7, $2F, $F7, $00, $F6, $00, $F5, $00, $F4, $00
	.byte $7F, $83, $80, $24, $F8, $1C, $03, $7F, $01, $F8, $1F, $03, $7F, $01

; Bank 0
ft_s0p7c2:
	.byte $82, $00, $ED, $2B, $E3, $9B, $02, $25, $ED, $26, $E3, $9B, $02, $25, $ED, $1F, $7F, $2B, $E3, $9B
	.byte $02, $25, $ED, $26, $E3, $9B, $02, $25, $ED, $1F, $7F, $83, $E8, $25, $03, $EF, $25, $01, $E6, $25
	.byte $03, $7F, $01, $25, $03, $EF, $25, $01, $E8, $25, $05, $82, $00, $E6, $25, $9B, $02, $00, $25, $9B
	.byte $02, $00, $25, $9B, $02, $00, $83, $25, $01, $25, $01, $E8, $25, $01

; Bank 0
ft_s0p7c3:
	.byte $82, $01, $E5, $FF, $1D, $1D, $1D, $1D, $1D, $1D, $83, $EE, $1D, $03, $F7, $1D, $01, $E7, $FF, $1D
	.byte $05, $1D, $03, $E5, $1D, $01, $EE, $1D, $05, $82, $01, $E7, $FD, $1D, $FD, $1D, $FD, $1D, $FE, $1D
	.byte $FF, $1D, $83, $FF, $1D, $01

; Bank 0
ft_s0p8c1:
	.byte $82, $00, $EB, $F8, $1B, $F6, $00, $F4, $00, $F2, $00, $83, $F1, $00, $01, $82, $00, $F9, $1D, $F7
	.byte $00, $F5, $00, $F3, $00, $83, $F1, $00, $01, $82, $00, $FA, $1E, $F8, $00, $F6, $00, $F4, $00, $83
	.byte $F1, $00, $01, $82, $00, $FB, $20, $F9, $00, $F7, $00, $F5, $00, $83, $F1, $00, $01, $82, $00, $E0
	.byte $F8, $25, $F1, $00, $F8, $25, $F1, $00, $F8, $25, $F1, $00, $EC, $F9, $29, $F9, $00, $F8, $00, $F7
	.byte $00, $83, $F0, $00, $01, $82, $00, $E0, $F9, $28, $F1, $00, $F9, $28, $F1, $00, $F9, $28, $F1, $00
	.byte $EC, $FA, $2C, $FA, $00, $F9, $00, $F8, $00, $83, $F0, $00, $01

; Bank 0
ft_s0p8c2:
	.byte $E4, $14, $00, $E3, $14, $01, $7F, $00, $E4, $14, $01, $E6, $20, $02, $7F, $00, $E4, $14, $00, $7F
	.byte $00, $12, $01, $7F, $01, $12, $01, $E8, $25, $03, $E4, $14, $01, $82, $00, $ED, $2B, $E3, $14, $E4
	.byte $14, $7F, $83, $14, $01, $82, $00, $ED, $26, $E3, $20, $E4, $20, $7F, $20, $7F, $ED, $2B, $E3, $15
	.byte $83, $E4, $15, $01, $15, $00, $7F, $00, $12, $04, $7F, $00

; Bank 0
ft_s0p8c3:
	.byte $E5, $FF, $1D, $03, $FF, $1D, $01, $80, $20, $FF, $1D, $03, $E5, $FF, $1D, $01, $FF, $1D, $03, $FF
	.byte $1D, $01, $80, $20, $FF, $1D, $03, $E5, $FF, $1D, $01, $FF, $1D, $03, $FF, $1D, $01, $80, $20, $FF
	.byte $1D, $03, $E5, $FF, $1D, $01, $FF, $1D, $03, $FF, $1D, $01, $80, $20, $FF, $1D, $03, $E5, $FF, $1D
	.byte $01

; Bank 0
ft_s0p9c1:
	.byte $82, $00, $E9, $FF, $22, $FC, $00, $F9, $00, $F6, $00, $83, $F1, $00, $01, $82, $00, $FE, $22, $FB
	.byte $00, $F8, $00, $F5, $00, $83, $F1, $00, $01, $7F, $05, $82, $00, $FF, $22, $FC, $00, $F9, $00, $F6
	.byte $00, $83, $F1, $00, $01, $82, $00, $FE, $22, $FB, $00, $F8, $00, $F5, $00, $83, $F1, $00, $01, $7F
	.byte $05, $82, $00, $FC, $22, $F1, $00, $FC, $22, $F1, $00, $FC, $22, $F1, $00, $FF, $22, $FC, $00, $F9
	.byte $00, $F6, $00, $83, $F0, $00, $01

; Bank 0
ft_s0p9c2:
	.byte $E4, $17, $00, $E3, $17, $01, $7F, $00, $E4, $17, $01, $E6, $23, $02, $7F, $00, $E4, $17, $00, $7F
	.byte $00, $15, $01, $7F, $01, $15, $01, $E8, $28, $03, $E4, $17, $01, $82, $00, $ED, $2B, $E3, $17, $E4
	.byte $17, $7F, $83, $17, $01, $ED, $26, $01, $82, $00, $E4, $17, $7F, $17, $7F, $ED, $2B, $E3, $18, $83
	.byte $E4, $18, $01, $18, $00, $7F, $00, $15, $00, $E3, $15, $02, $E5, $15, $00, $7F, $00

; Bank 0
ft_s0p10c1:
	.byte $82, $00, $80, $24, $FF, $23, $F1, $00, $FE, $28, $F1, $00, $FD, $2B, $F1, $00, $FD, $2A, $F1, $00
	.byte $FE, $26, $F1, $00, $FF, $22, $F1, $00, $FF, $21, $F1, $00, $FE, $26, $F1, $00, $FD, $29, $F1, $00
	.byte $FD, $28, $F1, $00, $FE, $24, $F1, $00, $FF, $21, $F1, $00, $83, $E1, $F9, $20, $17

; Bank 0
ft_s0p10c2:
	.byte $82, $00, $ED, $2B, $7F, $26, $7F, $1F, $7F, $2B, $7F, $26, $7F, $1F, $7F, $2B, $7F, $26, $7F, $1F
	.byte $7F, $83, $E8, $0D, $03, $EF, $0D, $19

; Bank 0
ft_s0p11c1:
	.byte $E1, $FC, $20, $01, $F9, $00, $05, $FA, $00, $03, $82, $05, $F9, $00, $F8, $00, $F7, $00, $F6, $00
	.byte $83, $F5, $00, $03, $82, $01, $F4, $00, $F3, $00, $F2, $00, $83, $F1, $00, $01

; Bank 0
ft_s0p11c2:
	.byte $E4, $20, $02, $7F, $00, $20, $00, $7F, $00, $20, $02, $7F, $00, $20, $00, $7F, $00, $20, $02, $7F
	.byte $00, $20, $00, $7F, $00, $20, $02, $7F, $00, $20, $00, $7F, $00, $20, $02, $7F, $00, $20, $00, $7F
	.byte $00, $20, $02, $7F, $00, $20, $00, $7F, $00, $20, $02, $7F, $00, $20, $00, $7F, $00, $20, $02, $7F
	.byte $00, $20, $00, $7F, $00


; DPCM samples (located at DPCM segment)
