; Dn-FamiTracker exported music data: simian_segue.dnm
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
	.byte $11
	.word ft_seq_2a03_5
	.word ft_seq_2a03_9

ft_inst_2:
	.byte 0
	.byte $11
	.word ft_seq_2a03_10
	.word ft_seq_2a03_4

ft_inst_3:
	.byte 0
	.byte $11
	.word ft_seq_2a03_15
	.word ft_seq_2a03_9

ft_inst_4:
	.byte 0
	.byte $01
	.word ft_seq_2a03_35

ft_inst_5:
	.byte 0
	.byte $01
	.word ft_seq_2a03_20

ft_inst_6:
	.byte 0
	.byte $11
	.word ft_seq_2a03_25
	.word ft_seq_2a03_14

ft_inst_7:
	.byte 0
	.byte $11
	.word ft_seq_2a03_30
	.word ft_seq_2a03_19

ft_inst_8:
	.byte 0
	.byte $03
	.word ft_seq_2a03_35
	.word ft_seq_2a03_1

ft_inst_9:
	.byte 0
	.byte $03
	.word ft_seq_2a03_35
	.word ft_seq_2a03_6

ft_inst_10:
	.byte 0
	.byte $11
	.word ft_seq_2a03_40
	.word ft_seq_2a03_19

ft_inst_11:
	.byte 0
	.byte $03
	.word ft_seq_2a03_35
	.word ft_seq_2a03_11

ft_inst_12:
	.byte 0
	.byte $03
	.word ft_seq_2a03_35
	.word ft_seq_2a03_16

ft_inst_13:
	.byte 0
	.byte $11
	.word ft_seq_2a03_45
	.word ft_seq_2a03_24

ft_inst_14:
	.byte 0
	.byte $03
	.word ft_seq_2a03_50
	.word ft_seq_2a03_21

ft_inst_15:
	.byte 0
	.byte $03
	.word ft_seq_2a03_55
	.word ft_seq_2a03_26

ft_inst_16:
	.byte 0
	.byte $13
	.word ft_seq_2a03_60
	.word ft_seq_2a03_31
	.word ft_seq_2a03_29

ft_inst_17:
	.byte 0
	.byte $03
	.word ft_seq_2a03_35
	.word ft_seq_2a03_41

ft_inst_18:
	.byte 0
	.byte $03
	.word ft_seq_2a03_35
	.word ft_seq_2a03_46

ft_inst_19:
	.byte 0
	.byte $03
	.word ft_seq_2a03_35
	.word ft_seq_2a03_51

; Sequences
ft_seq_2a03_0:
	.byte $0F, $FF, $00, $00, $0F, $0C, $08, $06, $05, $04, $03, $03, $02, $02, $01, $01, $01, $01, $00
ft_seq_2a03_1:
	.byte $02, $FF, $00, $01, $39, $39
ft_seq_2a03_4:
	.byte $03, $FF, $00, $00, $00, $01, $02
ft_seq_2a03_5:
	.byte $3E, $FF, $31, $00, $05, $09, $0B, $0B, $0B, $0A, $09, $0C, $0D, $0D, $0E, $0E, $0E, $0D, $0D, $0C
	.byte $0C, $0B, $0B, $0A, $09, $09, $08, $08, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $05, $05
	.byte $05, $05, $05, $05, $04, $04, $04, $04, $04, $04, $04, $04, $03, $03, $03, $02, $02, $01, $01, $01
	.byte $01, $01, $00, $00, $00, $00
ft_seq_2a03_6:
	.byte $02, $FF, $00, $01, $3D, $3D
ft_seq_2a03_9:
	.byte $02, $FF, $00, $00, $00, $02
ft_seq_2a03_10:
	.byte $0A, $FF, $00, $00, $0F, $0C, $06, $04, $02, $01, $01, $01, $01, $00
ft_seq_2a03_11:
	.byte $02, $FF, $00, $01, $31, $31
ft_seq_2a03_14:
	.byte $01, $FF, $00, $00, $01
ft_seq_2a03_15:
	.byte $09, $FF, $06, $00, $05, $09, $0C, $0A, $04, $03, $02, $01, $00
ft_seq_2a03_16:
	.byte $02, $FF, $00, $01, $36, $36
ft_seq_2a03_19:
	.byte $02, $FF, $00, $00, $01, $01
ft_seq_2a03_20:
	.byte $03, $FF, $00, $00, $0F, $0F, $00
ft_seq_2a03_21:
	.byte $03, $00, $00, $01, $0C, $0E, $0D
ft_seq_2a03_24:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_25:
	.byte $0E, $FF, $07, $00, $07, $0F, $0C, $0B, $05, $03, $02, $01, $01, $01, $00, $00, $00, $00
ft_seq_2a03_26:
	.byte $04, $FF, $00, $01, $0E, $09, $0A, $0A
ft_seq_2a03_29:
	.byte $02, $FF, $00, $00, $00, $01
ft_seq_2a03_30:
	.byte $0C, $FF, $00, $00, $0A, $0F, $08, $06, $04, $02, $01, $01, $00, $00, $00, $00
ft_seq_2a03_31:
	.byte $03, $FF, $00, $01, $0E, $0E, $0D
ft_seq_2a03_35:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_40:
	.byte $12, $FF, $10, $00, $0A, $0F, $08, $06, $06, $05, $04, $03, $03, $03, $03, $03, $03, $02, $01, $01
	.byte $01, $00
ft_seq_2a03_41:
	.byte $02, $FF, $00, $01, $3B, $3B
ft_seq_2a03_45:
	.byte $09, $FF, $00, $00, $0F, $06, $03, $03, $02, $02, $01, $01, $00
ft_seq_2a03_46:
	.byte $02, $FF, $00, $01, $3E, $3E
ft_seq_2a03_50:
	.byte $07, $FF, $00, $00, $07, $0C, $0F, $00, $00, $00, $00
ft_seq_2a03_51:
	.byte $02, $FF, $00, $01, $42, $42
ft_seq_2a03_55:
	.byte $06, $FF, $00, $00, $0F, $09, $03, $01, $01, $00
ft_seq_2a03_60:
	.byte $04, $FF, $00, $00, $0F, $05, $03, $00

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
	.byte 31	; frame count
	.byte 32	; pattern length
	.byte 3	; speed
	.byte 100	; tempo
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
	.word ft_s0f14
	.word ft_s0f15
	.word ft_s0f16
	.word ft_s0f17
	.word ft_s0f18
	.word ft_s0f19
	.word ft_s0f20
	.word ft_s0f21
	.word ft_s0f22
	.word ft_s0f23
	.word ft_s0f24
	.word ft_s0f25
	.word ft_s0f26
	.word ft_s0f27
	.word ft_s0f28
	.word ft_s0f29
	.word ft_s0f30
ft_s0f0:
	.word ft_s0p1c3, ft_s0p11c1, ft_s0p1c3, ft_s0p1c3, ft_s0p0c4
ft_s0f1:
	.word ft_s0p0c0, ft_s0p10c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f2:
	.word ft_s0p1c0, ft_s0p1c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f3:
	.word ft_s0p2c0, ft_s0p2c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f4:
	.word ft_s0p3c0, ft_s0p3c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f5:
	.word ft_s0p4c0, ft_s0p4c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f6:
	.word ft_s0p5c0, ft_s0p5c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f7:
	.word ft_s0p6c0, ft_s0p6c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f8:
	.word ft_s0p7c0, ft_s0p7c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f9:
	.word ft_s0p8c0, ft_s0p8c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f10:
	.word ft_s0p9c0, ft_s0p9c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f11:
	.word ft_s0p3c0, ft_s0p2c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f12:
	.word ft_s0p11c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
ft_s0f13:
	.word ft_s0p12c0, ft_s0p12c1, ft_s0p12c2, ft_s0p0c3, ft_s0p0c4
ft_s0f14:
	.word ft_s0p13c0, ft_s0p13c1, ft_s0p13c2, ft_s0p0c3, ft_s0p0c4
ft_s0f15:
	.word ft_s0p14c0, ft_s0p14c1, ft_s0p14c2, ft_s0p0c3, ft_s0p0c4
ft_s0f16:
	.word ft_s0p15c0, ft_s0p15c1, ft_s0p13c2, ft_s0p0c3, ft_s0p0c4
ft_s0f17:
	.word ft_s0p31c0, ft_s0p17c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f18:
	.word ft_s0p18c0, ft_s0p18c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f19:
	.word ft_s0p19c0, ft_s0p19c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f20:
	.word ft_s0p20c0, ft_s0p20c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f21:
	.word ft_s0p21c0, ft_s0p17c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f22:
	.word ft_s0p17c0, ft_s0p22c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f23:
	.word ft_s0p23c0, ft_s0p23c1, ft_s0p23c2, ft_s0p0c3, ft_s0p0c4
ft_s0f24:
	.word ft_s0p24c0, ft_s0p24c1, ft_s0p23c2, ft_s0p0c3, ft_s0p0c4
ft_s0f25:
	.word ft_s0p20c0, ft_s0p19c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f26:
	.word ft_s0p21c0, ft_s0p20c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4
ft_s0f27:
	.word ft_s0p27c0, ft_s0p27c1, ft_s0p27c2, ft_s0p0c3, ft_s0p0c4
ft_s0f28:
	.word ft_s0p28c0, ft_s0p28c1, ft_s0p28c2, ft_s0p0c3, ft_s0p0c4
ft_s0f29:
	.word ft_s0p27c0, ft_s0p29c1, ft_s0p29c2, ft_s0p0c3, ft_s0p0c4
ft_s0f30:
	.word ft_s0p30c0, ft_s0p30c1, ft_s0p28c2, ft_s0p0c3, ft_s0p0c4
; Bank 0
ft_s0p0c0:
	.byte $E7, $F7, $29, $05, $F4, $22, $05, $F5, $22, $03, $F4, $22, $05, $F4, $22, $05, $F5, $22, $03

; Bank 0
ft_s0p0c1:
	.byte $E7, $F7, $29, $05, $F6, $29, $05, $F8, $2B, $03, $F7, $29, $05, $F6, $29, $05, $F8, $2B, $03

; Bank 0
ft_s0p0c2:
	.byte $EB, $22, $02, $7F, $02, $E5, $32, $01, $E4, $1D, $02, $7F, $00, $E5, $32, $03, $EB, $22, $02, $7F
	.byte $02, $1D, $01, $7F, $01, $94, $03, $E4, $1F, $00, $94, $02, $7F, $00, $EB, $20, $01, $7F, $01

; Bank 0
ft_s0p0c3:
	.byte $82, $01, $80, $20, $FF, $19, $EE, $F3, $19, $F4, $19, $80, $20, $FF, $19, $EF, $FF, $19, $EE, $F3
	.byte $19, $F4, $19, $80, $20, $FF, $19, $FF, $19, $EE, $F3, $19, $EF, $FF, $19, $80, $20, $FF, $19, $EE
	.byte $F4, $19, $EF, $FF, $19, $80, $20, $FF, $19, $83, $EE, $F3, $19, $01

; Bank 0
ft_s0p0c4:
	.byte $96, $40, $00, $1F

; Bank 0
ft_s0p1c0:
	.byte $E0, $F9, $46, $05, $E7, $F4, $22, $04, $94, $01, $E0, $F5, $48, $00, $E2, $F8, $49, $03, $E0, $F9
	.byte $46, $05, $E7, $F4, $22, $04, $94, $01, $E0, $F5, $48, $00, $E2, $F8, $49, $03

; Bank 0
ft_s0p1c1:
	.byte $E7, $F7, $29, $05, $F6, $29, $05, $F8, $2B, $03, $EA, $F7, $2C, $03, $E7, $F8, $2B, $02, $7E, $00
	.byte $F7, $29, $01, $F6, $27, $05

; Bank 0
ft_s0p1c2:
	.byte $EC, $27, $02, $7F, $02, $E5, $37, $01, $E4, $22, $02, $7F, $00, $E5, $37, $03, $EC, $27, $02, $7F
	.byte $02, $22, $01, $7F, $01, $94, $03, $E4, $24, $00, $94, $02, $7F, $00, $EC, $26, $01, $7F, $01

; Bank 0
ft_s0p1c3:
	.byte $00, $1F

; Bank 0
ft_s0p2c0:
	.byte $E0, $F9, $46, $03, $82, $01, $F9, $44, $E7, $F4, $22, $E0, $FA, $41, $F8, $3F, $E7, $F4, $22, $E0
	.byte $F9, $41, $83, $E7, $F4, $22, $05, $F4, $22, $05, $F4, $22, $03

; Bank 0
ft_s0p2c1:
	.byte $E7, $F7, $2C, $05, $F6, $2C, $05, $F8, $2E, $03, $EA, $F7, $2C, $02, $7E, $02, $E7, $F7, $2C, $05
	.byte $F6, $2B, $03

; Bank 0
ft_s0p3c0:
	.byte $E1, $8F, $02, $F8, $2C, $07, $8F, $12, $00, $03, $7E, $03, $8F, $02, $2B, $07, $8F, $12, $00, $03
	.byte $7E, $03

; Bank 0
ft_s0p3c1:
	.byte $E7, $F7, $29, $05, $F6, $29, $05, $F8, $2B, $03, $F7, $29, $05, $F7, $29, $05, $F6, $27, $03

; Bank 0
ft_s0p4c0:
	.byte $E1, $8F, $00, $29, $00, $7E, $04, $29, $01, $7E, $03, $E7, $F4, $22, $03, $F4, $22, $05, $F4, $22
	.byte $05, $F5, $22, $03

; Bank 0
ft_s0p4c1:
	.byte $E7, $F7, $29, $05, $F6, $29, $05, $F8, $2B, $03, $F7, $29, $05, $F7, $29, $05, $F6, $2B, $03

; Bank 0
ft_s0p5c0:
	.byte $E0, $F7, $35, $01, $F8, $3A, $01, $F9, $3C, $01, $FB, $3E, $05, $E7, $F4, $22, $03, $82, $01, $F4
	.byte $22, $E2, $F9, $3C, $E7, $F4, $22, $E2, $F8, $3A, $F9, $3C, $83, $E0, $FA, $3E, $03, $FB, $3A, $01

; Bank 0
ft_s0p5c1:
	.byte $E7, $F7, $29, $05, $F6, $29, $05, $F8, $2B, $03, $EA, $F8, $2C, $03, $E7, $F8, $2B, $02, $7E, $00
	.byte $F7, $29, $01, $F6, $27, $03, $F7, $2B, $01

; Bank 0
ft_s0p6c0:
	.byte $E7, $F4, $27, $03, $82, $00, $E3, $F7, $24, $7E, $F8, $25, $7E, $E1, $F8, $22, $83, $7E, $02, $82
	.byte $00, $E3, $F8, $24, $7E, $F9, $25, $7E, $E1, $F9, $22, $83, $7E, $02, $82, $00, $E3, $F9, $24, $7E
	.byte $F8, $25, $7E, $E1, $F8, $22, $83, $7E, $02, $82, $00, $E3, $F8, $24, $7E, $F7, $25, $83, $7E, $00

; Bank 0
ft_s0p6c1:
	.byte $E7, $F8, $2E, $05, $F7, $2E, $05, $F9, $30, $03, $EA, $F8, $31, $02, $7E, $02, $E7, $F8, $31, $05
	.byte $F7, $30, $03

; Bank 0
ft_s0p7c0:
	.byte $E0, $FA, $35, $01, $F8, $3A, $01, $F9, $3C, $01, $FB, $3E, $05, $E7, $F4, $22, $03, $82, $01, $F4
	.byte $22, $E2, $F9, $3C, $E7, $F4, $22, $E2, $F8, $3A, $FA, $3C, $83, $E0, $FA, $3E, $03, $FB, $3A, $01

; Bank 0
ft_s0p7c1:
	.byte $E1, $F7, $22, $00, $7E, $04, $E7, $F6, $29, $05, $F8, $2B, $03, $EA, $F8, $2C, $03, $E7, $F8, $2B
	.byte $02, $7E, $00, $F7, $29, $01, $F6, $27, $03, $F7, $2B, $01

; Bank 0
ft_s0p8c0:
	.byte $E0, $F9, $44, $03, $82, $01, $F9, $43, $E7, $F4, $27, $E0, $FB, $41, $FA, $3F, $E7, $F4, $27, $E0
	.byte $FB, $3D, $83, $E1, $FA, $2C, $00, $7E, $02, $F9, $2B, $00, $7E, $00, $E7, $F4, $27, $01, $82, $00
	.byte $E1, $FA, $29, $7E, $F9, $27, $7E, $83, $E7, $F4, $27, $01, $E1, $F8, $25, $01

; Bank 0
ft_s0p8c1:
	.byte $E7, $F8, $2E, $05, $F7, $2E, $05, $F9, $30, $01, $E3, $F7, $29, $00, $F8, $2B, $00, $EA, $F8, $31
	.byte $02, $7E, $02, $E7, $F8, $31, $05, $F7, $30, $03

; Bank 0
ft_s0p9c0:
	.byte $E0, $FA, $41, $03, $82, $01, $FA, $3F, $E7, $F4, $27, $E0, $FB, $3D, $FB, $3C, $E7, $F4, $27, $E0
	.byte $FB, $3A, $83, $E1, $FA, $29, $00, $7E, $02, $F9, $27, $00, $7E, $00, $E7, $F4, $27, $01, $82, $00
	.byte $E1, $FA, $25, $7E, $F9, $24, $7E, $83, $E7, $F4, $27, $01, $E1, $F8, $22, $00, $7E, $00

; Bank 0
ft_s0p9c1:
	.byte $E7, $F8, $2E, $05, $F7, $2E, $05, $F9, $30, $01, $E1, $F7, $25, $00, $F8, $27, $00, $E7, $F8, $2E
	.byte $05, $F7, $2C, $05, $F9, $2B, $03

; Bank 0
ft_s0p10c1:
	.byte $ED, $FA, $2E, $05, $E7, $F6, $29, $05, $F8, $2B, $03, $F7, $29, $05, $F6, $29, $05, $F8, $2B, $03

; Bank 0
ft_s0p11c0:
	.byte $E1, $8F, $00, $29, $00, $7E, $04, $29, $01, $7E, $03, $E7, $F4, $22, $03, $F4, $22, $05, $F4, $22
	.byte $05, $F4, $22, $03

; Bank 0
ft_s0p11c1:
	.byte $82, $00, $ED, $F2, $16, $F3, $1A, $F4, $1D, $F4, $20, $F5, $22, $F6, $26, $F7, $29, $83, $86, $02
	.byte $F7, $2C, $18

; Bank 0
ft_s0p12c0:
	.byte $82, $01, $E0, $FA, $35, $E2, $F8, $35, $F7, $35, $F9, $35, $83, $E0, $FA, $35, $03, $FA, $37, $01
	.byte $E2, $FB, $33, $03, $F9, $33, $03, $FA, $33, $01, $E0, $FA, $33, $03, $E2, $F9, $32, $03

; Bank 0
ft_s0p12c1:
	.byte $E0, $F6, $32, $01, $82, $00, $E2, $F4, $32, $7F, $F3, $32, $7F, $F5, $32, $7F, $83, $E0, $F6, $32
	.byte $03, $F6, $32, $01, $E2, $F7, $32, $00, $7F, $02, $F5, $32, $00, $7F, $02, $F6, $32, $00, $7F, $00
	.byte $E0, $F6, $32, $03, $E2, $F5, $32, $00, $7F, $02

; Bank 0
ft_s0p12c2:
	.byte $E8, $22, $01, $82, $00, $22, $7F, $E5, $3A, $7F, $3A, $7F, $83, $E8, $1D, $02, $82, $00, $7F, $E4
	.byte $3A, $7F, $E5, $3A, $7F, $83, $E4, $22, $01, $E8, $22, $00, $7F, $02, $1D, $01, $82, $00, $E4, $3A
	.byte $7F, $94, $03, $1F, $94, $02, $7F, $E8, $20, $83, $7F, $02

; Bank 0
ft_s0p13c0:
	.byte $82, $00, $E6, $FA, $32, $7E, $F7, $32, $7E, $F9, $32, $7E, $F6, $32, $7E, $83, $FB, $32, $01, $7E
	.byte $01, $FA, $33, $00, $7E, $00, $F9, $30, $00, $7E, $02, $F8, $30, $00, $7E, $02, $F8, $30, $00, $7E
	.byte $00, $82, $01, $FA, $30, $7E, $FA, $32, $83, $7E, $01

; Bank 0
ft_s0p13c1:
	.byte $82, $00, $E6, $F8, $29, $7E, $F5, $29, $7F, $F7, $29, $7F, $F4, $29, $7F, $83, $F9, $29, $03, $F8
	.byte $29, $00, $7E, $00, $F7, $29, $00, $7F, $02, $F6, $29, $00, $7F, $02, $F6, $29, $00, $7F, $00, $F8
	.byte $29, $00, $7E, $02, $F8, $29, $00, $7E, $02

; Bank 0
ft_s0p13c2:
	.byte $E4, $22, $02, $7F, $04, $1D, $02, $7F, $04, $22, $02, $7F, $02, $1D, $01, $7F, $01, $94, $03, $1F
	.byte $00, $94, $02, $7F, $00, $20, $01, $7F, $01

; Bank 0
ft_s0p14c0:
	.byte $82, $01, $E0, $FA, $41, $E2, $F8, $41, $F7, $41, $F9, $41, $83, $E0, $FA, $41, $03, $FA, $43, $01
	.byte $E2, $FB, $3F, $03, $F9, $3F, $03, $FA, $3F, $01, $E0, $FA, $3F, $03, $E2, $F9, $3E, $03

; Bank 0
ft_s0p14c1:
	.byte $E0, $F6, $3A, $01, $82, $00, $E2, $F4, $3A, $7F, $F3, $3A, $7F, $F5, $3A, $7F, $83, $E0, $F6, $3A
	.byte $03, $F6, $3A, $01, $E2, $F7, $3A, $00, $7F, $02, $F5, $3A, $00, $7F, $02, $F6, $3A, $00, $7F, $00
	.byte $E0, $F6, $3A, $03, $E2, $F5, $3A, $00, $7F, $02

; Bank 0
ft_s0p14c2:
	.byte $E9, $22, $01, $82, $00, $22, $7F, $E5, $3E, $7F, $3E, $7F, $83, $E9, $1D, $02, $82, $00, $7F, $E4
	.byte $3E, $7F, $E5, $3E, $7F, $83, $E4, $22, $01, $E9, $22, $00, $7F, $02, $1D, $01, $82, $00, $E4, $3E
	.byte $7F, $94, $03, $1F, $94, $02, $7F, $E9, $20, $83, $7F, $02

; Bank 0
ft_s0p15c0:
	.byte $82, $00, $E6, $FA, $32, $7E, $F7, $32, $7E, $F9, $32, $7E, $F6, $32, $7E, $83, $FB, $32, $01, $7E
	.byte $01, $FA, $33, $00, $7E, $00, $F9, $30, $00, $7E, $02, $F8, $30, $00, $7E, $02, $F8, $30, $00, $7E
	.byte $00, $82, $01, $FA, $30, $7E, $FA, $2E, $83, $7E, $01

; Bank 0
ft_s0p15c1:
	.byte $82, $00, $E6, $F8, $29, $7E, $F5, $29, $7F, $F7, $29, $7F, $F4, $29, $7F, $83, $F9, $29, $03, $F8
	.byte $29, $00, $7E, $00, $F7, $29, $00, $7F, $02, $F6, $29, $00, $7F, $02, $82, $00, $F6, $29, $7F, $F8
	.byte $29, $ED, $F2, $13, $F3, $16, $F4, $19, $E6, $F8, $29, $ED, $F6, $1F, $F7, $22, $83, $F8, $25, $00

; Bank 0
ft_s0p17c0:
	.byte $E7, $F3, $33, $05, $F3, $33, $05, $F4, $33, $03, $F3, $33, $05, $F3, $33, $05, $F4, $33, $03

; Bank 0
ft_s0p17c1:
	.byte $E7, $F6, $3A, $05, $F5, $3A, $05, $F7, $3C, $03, $F6, $3A, $05, $F5, $3A, $05, $F7, $3C, $03

; Bank 0
ft_s0p18c0:
	.byte $E0, $F9, $3F, $05, $E7, $F3, $33, $04, $94, $01, $E0, $F5, $41, $00, $E2, $F8, $42, $03, $E0, $F9
	.byte $3F, $05, $E7, $F3, $33, $04, $94, $01, $E0, $F5, $41, $00, $E2, $F8, $42, $03

; Bank 0
ft_s0p18c1:
	.byte $E7, $F7, $3A, $05, $F5, $3A, $05, $F7, $3C, $03, $EA, $F7, $3D, $03, $E7, $F7, $3C, $02, $7E, $00
	.byte $F6, $3A, $01, $F5, $38, $05

; Bank 0
ft_s0p19c0:
	.byte $E0, $F9, $3F, $03, $82, $01, $F9, $3D, $E7, $F3, $33, $E0, $FA, $3A, $F8, $38, $E7, $F3, $33, $E0
	.byte $F9, $3A, $83, $E7, $F3, $33, $05, $F3, $33, $05, $F3, $33, $03

; Bank 0
ft_s0p19c1:
	.byte $E7, $F6, $3D, $05, $F5, $3D, $05, $F7, $3F, $03, $EA, $F6, $3D, $02, $7E, $02, $E7, $F6, $3D, $05
	.byte $F5, $3C, $03

; Bank 0
ft_s0p20c0:
	.byte $E1, $8F, $02, $F8, $25, $07, $8F, $12, $00, $03, $7E, $03, $8F, $02, $24, $07, $8F, $12, $00, $03
	.byte $7E, $03

; Bank 0
ft_s0p20c1:
	.byte $E7, $F6, $3A, $05, $F5, $3A, $05, $F7, $3C, $03, $F6, $3A, $05, $F5, $3A, $05, $F7, $38, $03

; Bank 0
ft_s0p21c0:
	.byte $E1, $8F, $00, $22, $00, $7E, $04, $22, $01, $7E, $03, $E7, $F3, $33, $03, $F3, $33, $05, $F3, $33
	.byte $05, $F3, $33, $03

; Bank 0
ft_s0p22c1:
	.byte $E7, $F6, $3A, $05, $F5, $3A, $05, $F7, $3C, $03, $EA, $F7, $3D, $03, $E7, $F7, $3C, $02, $7E, $00
	.byte $F6, $3A, $01, $F5, $38, $03, $F6, $3C, $01

; Bank 0
ft_s0p23c0:
	.byte $E0, $F9, $35, $00, $E2, $FB, $36, $02, $82, $00, $E3, $F7, $24, $7E, $F8, $25, $7E, $E1, $F8, $22
	.byte $83, $7E, $02, $E2, $FA, $35, $00, $94, $01, $F9, $36, $00, $94, $02, $F8, $35, $01, $FA, $33, $03
	.byte $82, $00, $E3, $F7, $24, $7E, $F8, $25, $7E, $E1, $F8, $22, $83, $7E, $02, $E2, $FA, $31, $03

; Bank 0
ft_s0p23c1:
	.byte $E7, $F5, $3F, $05, $F5, $3F, $05, $82, $00, $E3, $F7, $24, $7E, $F8, $25, $7E, $E1, $F8, $22, $83
	.byte $7E, $04, $E7, $F5, $42, $05, $82, $00, $E3, $F7, $24, $7E, $F8, $25, $83, $7E, $00

; Bank 0
ft_s0p23c2:
	.byte $80, $22, $2C, $02, $7F, $02, $E5, $3C, $01, $E4, $27, $02, $7F, $00, $E5, $3C, $03, $80, $22, $2C
	.byte $02, $7F, $02, $27, $01, $7F, $01, $94, $03, $E4, $29, $00, $94, $02, $7F, $00, $80, $22, $2B, $01
	.byte $7F, $01

; Bank 0
ft_s0p24c0:
	.byte $E2, $F9, $2E, $03, $82, $01, $FA, $31, $E7, $F3, $38, $E2, $FB, $33, $FA, $35, $E7, $F3, $38, $E2
	.byte $FB, $33, $83, $E1, $FA, $2C, $00, $7E, $02, $E3, $F9, $2A, $00, $7E, $00, $E7, $F3, $38, $01, $82
	.byte $00, $E1, $FA, $29, $7E, $E3, $FB, $27, $7E, $83, $E7, $F3, $38, $01, $E3, $FA, $25, $00, $7E, $00

; Bank 0
ft_s0p24c1:
	.byte $E1, $F8, $22, $00, $7E, $04, $E7, $F5, $3F, $05, $F5, $41, $09, $F5, $3D, $05, $F5, $3C, $03

; Bank 0
ft_s0p27c0:
	.byte $82, $01, $E0, $FA, $3A, $E2, $F8, $3A, $F7, $3A, $F9, $3A, $83, $E0, $FA, $3A, $03, $FA, $3C, $01
	.byte $E2, $FB, $38, $03, $F9, $38, $03, $FA, $38, $01, $E0, $FA, $38, $03, $E2, $F9, $37, $03

; Bank 0
ft_s0p27c1:
	.byte $E0, $F6, $37, $01, $82, $00, $E2, $F4, $37, $7F, $F3, $37, $7F, $F5, $37, $7F, $83, $E0, $F6, $37
	.byte $03, $F6, $37, $01, $E2, $F7, $37, $00, $7F, $02, $F5, $37, $00, $7F, $02, $F6, $37, $00, $7F, $00
	.byte $E0, $F6, $37, $03, $E2, $F5, $37, $00, $7F, $02

; Bank 0
ft_s0p27c2:
	.byte $80, $24, $27, $01, $82, $00, $27, $7F, $E5, $3F, $7F, $3F, $7F, $83, $80, $24, $22, $02, $82, $00
	.byte $7F, $E4, $3F, $7F, $E5, $3F, $7F, $83, $E4, $27, $01, $80, $24, $27, $00, $7F, $02, $22, $01, $82
	.byte $00, $E4, $3F, $7F, $94, $03, $24, $94, $02, $7F, $80, $24, $26, $83, $7F, $02

; Bank 0
ft_s0p28c0:
	.byte $82, $00, $E6, $FA, $37, $7E, $F7, $37, $7E, $F9, $37, $7E, $F6, $37, $7E, $83, $FB, $37, $01, $7E
	.byte $01, $FA, $38, $00, $7E, $00, $F9, $35, $00, $7E, $02, $F8, $35, $00, $7E, $02, $F8, $35, $00, $7E
	.byte $00, $82, $01, $FA, $35, $7E, $FA, $37, $83, $7E, $01

; Bank 0
ft_s0p28c1:
	.byte $82, $00, $E6, $F8, $2E, $7E, $F5, $2E, $7F, $F7, $2E, $7F, $F4, $2E, $7F, $83, $F9, $2E, $03, $F8
	.byte $2E, $00, $7E, $00, $F7, $2E, $00, $7F, $02, $F6, $2E, $00, $7F, $02, $F6, $2E, $00, $7F, $00, $F8
	.byte $2E, $00, $7E, $02, $F8, $2E, $00, $7E, $02

; Bank 0
ft_s0p28c2:
	.byte $E4, $27, $02, $7F, $04, $22, $02, $7F, $04, $27, $02, $7F, $02, $22, $01, $7F, $01, $94, $03, $24
	.byte $00, $94, $02, $7F, $00, $26, $01, $7F, $01

; Bank 0
ft_s0p29c1:
	.byte $E0, $F6, $3F, $01, $82, $00, $E2, $F4, $3F, $7F, $F3, $3F, $7F, $F5, $3F, $7F, $83, $E0, $F6, $3F
	.byte $03, $F6, $3F, $01, $E2, $F7, $3F, $00, $7F, $02, $F5, $3F, $00, $7F, $02, $F6, $3F, $00, $7F, $00
	.byte $E0, $F6, $3F, $03, $E2, $F5, $3F, $00, $7F, $02

; Bank 0
ft_s0p29c2:
	.byte $80, $26, $27, $01, $82, $00, $27, $7F, $E5, $43, $7F, $43, $7F, $83, $80, $26, $22, $02, $82, $00
	.byte $7F, $E4, $43, $7F, $E5, $43, $7F, $83, $E4, $27, $01, $80, $26, $27, $00, $7F, $02, $22, $01, $82
	.byte $00, $E4, $43, $7F, $94, $03, $24, $94, $02, $7F, $80, $26, $26, $83, $7F, $02

; Bank 0
ft_s0p30c0:
	.byte $82, $00, $E6, $FA, $37, $7E, $F7, $37, $7E, $F9, $37, $7E, $F6, $37, $7E, $83, $FB, $37, $01, $7E
	.byte $01, $FA, $38, $00, $7E, $00, $F9, $35, $00, $7E, $02, $F8, $35, $00, $7E, $02, $F8, $35, $00, $7E
	.byte $00, $FA, $35, $01, $7E, $01, $FA, $33, $01, $7E, $00, $86, $02, $00, $00

; Bank 0
ft_s0p30c1:
	.byte $82, $00, $E6, $F8, $2E, $7E, $F5, $2E, $7F, $F7, $2E, $7F, $F4, $2E, $7F, $83, $F9, $2E, $03, $F8
	.byte $2E, $00, $7E, $00, $F7, $2E, $00, $7F, $02, $F6, $2E, $00, $7F, $02, $82, $00, $F6, $2E, $7F, $F8
	.byte $2E, $ED, $F3, $1A, $F4, $1D, $F4, $20, $E6, $F8, $2E, $ED, $F6, $26, $F7, $29, $83, $F7, $2C, $00

; Bank 0
ft_s0p31c0:
	.byte $ED, $FA, $27, $05, $E7, $F3, $33, $05, $F4, $33, $03, $F3, $33, $05, $F3, $33, $05, $F4, $33, $03


; DPCM samples (located at DPCM segment)
