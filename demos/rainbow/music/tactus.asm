; Dn-FamiTracker exported music data: tactus-vrc6.dnm
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
	.byte 4
	.byte $01
	.word ft_seq_vrc6_0

ft_inst_1:
	.byte 0
	.byte $01
	.word ft_seq_2a03_0

ft_inst_2:
	.byte 0
	.byte $00

ft_inst_3:
	.byte 4
	.byte $01
	.word ft_seq_vrc6_5

ft_inst_4:
	.byte 0
	.byte $03
	.word ft_seq_2a03_50
	.word ft_seq_2a03_41

ft_inst_5:
	.byte 0
	.byte $13
	.word ft_seq_2a03_55
	.word ft_seq_2a03_46
	.word ft_seq_2a03_24

ft_inst_6:
	.byte 0
	.byte $03
	.word ft_seq_2a03_60
	.word ft_seq_2a03_51

ft_inst_7:
	.byte 0
	.byte $13
	.word ft_seq_2a03_65
	.word ft_seq_2a03_56
	.word ft_seq_2a03_29

ft_inst_8:
	.byte 0
	.byte $13
	.word ft_seq_2a03_70
	.word ft_seq_2a03_61
	.word ft_seq_2a03_34

ft_inst_9:
	.byte 0
	.byte $07
	.word ft_seq_2a03_80
	.word ft_seq_2a03_91
	.word ft_seq_2a03_2

ft_inst_10:
	.byte 0
	.byte $03
	.word ft_seq_2a03_85
	.word ft_seq_2a03_76

ft_inst_11:
	.byte 0
	.byte $07
	.word ft_seq_2a03_90
	.word ft_seq_2a03_71
	.word ft_seq_2a03_2

ft_inst_12:
	.byte 0
	.byte $03
	.word ft_seq_2a03_95
	.word ft_seq_2a03_76

ft_inst_13:
	.byte 0
	.byte $03
	.word ft_seq_2a03_100
	.word ft_seq_2a03_81

ft_inst_14:
	.byte 0
	.byte $11
	.word ft_seq_2a03_105
	.word ft_seq_2a03_44

ft_inst_15:
	.byte 0
	.byte $11
	.word ft_seq_2a03_110
	.word ft_seq_2a03_49

ft_inst_16:
	.byte 0
	.byte $15
	.word ft_seq_2a03_115
	.word ft_seq_2a03_12
	.word ft_seq_2a03_54

ft_inst_17:
	.byte 0
	.byte $11
	.word ft_seq_2a03_120
	.word ft_seq_2a03_59

ft_inst_18:
	.byte 4
	.byte $11
	.word ft_seq_vrc6_10
	.word ft_seq_vrc6_4

ft_inst_19:
	.byte 4
	.byte $11
	.word ft_seq_vrc6_5
	.word ft_seq_vrc6_4

; Sequences
ft_seq_2a03_0:
	.byte $10, $FF, $00, $00, $0F, $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00
ft_seq_2a03_2:
	.byte $10, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $FF, $FF, $FF, $FF, $01, $01
ft_seq_2a03_12:
	.byte $01, $FF, $00, $00, $FF
ft_seq_2a03_24:
	.byte $03, $FF, $00, $00, $01, $01, $00
ft_seq_2a03_29:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_34:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_41:
	.byte $0C, $FF, $00, $01, $09, $09, $0A, $0A, $0A, $0B, $0B, $0B, $0C, $0C, $0D, $0D
ft_seq_2a03_44:
	.byte $02, $FF, $00, $00, $00, $01
ft_seq_2a03_46:
	.byte $03, $02, $00, $01, $05, $07, $0C
ft_seq_2a03_49:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_50:
	.byte $02, $FF, $00, $00, $0D, $00
ft_seq_2a03_51:
	.byte $03, $01, $00, $01, $09, $0B, $0C
ft_seq_2a03_54:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_55:
	.byte $0E, $FF, $00, $00, $0F, $0F, $0F, $0E, $0C, $09, $07, $04, $03, $02, $01, $01, $01, $00
ft_seq_2a03_56:
	.byte $04, $03, $00, $01, $0B, $0C, $0D, $0E
ft_seq_2a03_59:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_60:
	.byte $39, $FF, $00, $00, $0F, $0E, $0E, $0C, $0B, $0B, $0A, $0A, $09, $09, $08, $08, $08, $07, $07, $06
	.byte $06, $05, $05, $05, $05, $04, $04, $04, $04, $03, $03, $03, $03, $03, $03, $03, $02, $02, $02, $02
	.byte $02, $02, $02, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00
ft_seq_2a03_61:
	.byte $04, $03, $00, $01, $0B, $0C, $0D, $0C
ft_seq_2a03_65:
	.byte $0A, $FF, $00, $00, $0D, $0A, $07, $00, $00, $00, $00, $00, $00, $00
ft_seq_2a03_70:
	.byte $15, $FF, $00, $00, $0A, $0A, $0A, $0A, $09, $08, $07, $06, $05, $05, $05, $05, $04, $04, $04, $03
	.byte $03, $02, $02, $01, $00
ft_seq_2a03_71:
	.byte $06, $FF, $00, $01, $2A, $22, $1C, $17, $13, $10
ft_seq_2a03_76:
	.byte $03, $FF, $00, $01, $2E, $27, $22
ft_seq_2a03_80:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_81:
	.byte $02, $00, $00, $01, $0B, $0C
ft_seq_2a03_85:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_90:
	.byte $07, $FF, $00, $00, $0F, $0F, $0F, $0F, $0F, $0F, $00
ft_seq_2a03_91:
	.byte $04, $FF, $00, $01, $2A, $22, $1C, $17
ft_seq_2a03_95:
	.byte $04, $FF, $00, $00, $0F, $0F, $0F, $00
ft_seq_2a03_100:
	.byte $01, $FF, $00, $00, $08
ft_seq_2a03_105:
	.byte $18, $FF, $10, $00, $0C, $0D, $0E, $0F, $0F, $0E, $0D, $0C, $0B, $0A, $09, $09, $08, $07, $07, $07
	.byte $02, $02, $01, $01, $01, $01, $01, $00
ft_seq_2a03_110:
	.byte $10, $FF, $00, $00, $0B, $0E, $0F, $0F, $0F, $0E, $0C, $0B, $09, $08, $07, $06, $05, $04, $03, $02
ft_seq_2a03_115:
	.byte $08, $FF, $00, $00, $0A, $0B, $09, $07, $05, $02, $01, $00
ft_seq_2a03_120:
	.byte $1C, $FF, $14, $00, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0E, $0D, $0C, $0C, $0B, $0A, $09, $08
	.byte $07, $07, $06, $05, $03, $02, $02, $01, $01, $01, $00, $00
ft_seq_vrc6_0:
	.byte $18, $FF, $0E, $00, $0F, $0F, $0F, $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $03
	.byte $03, $02, $02, $02, $01, $01, $01, $00
ft_seq_vrc6_4:
	.byte $01, $FF, $00, $00, $02
ft_seq_vrc6_5:
	.byte $19, $FF, $0E, $00, $0F, $0F, $0F, $0F, $0E, $0E, $0D, $0D, $0C, $0C, $0B, $0B, $0A, $0A, $02, $02
	.byte $02, $02, $02, $02, $01, $01, $01, $01, $00
ft_seq_vrc6_10:
	.byte $20, $FF, $15, $00, $0F, $0F, $0E, $0E, $0D, $0D, $0C, $0C, $0B, $0B, $0A, $0A, $09, $09, $08, $08
	.byte $07, $07, $06, $06, $02, $02, $02, $02, $01, $01, $01, $01, $00, $00, $00, $00

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
	.byte 10	; frame count
	.byte 64	; pattern length
	.byte 3	; speed
	.byte 120	; tempo
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
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f1:
	.word ft_s0p1c0, ft_s0p1c1, ft_s0p1c2, ft_s0p0c3, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4, ft_s0p0c4
ft_s0f2:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p2c2, ft_s0p1c3, ft_s0p1c5, ft_s0p1c6, ft_s0p1c7, ft_s0p0c4
ft_s0f3:
	.word ft_s0p1c0, ft_s0p1c1, ft_s0p3c2, ft_s0p0c3, ft_s0p2c5, ft_s0p2c6, ft_s0p2c7, ft_s0p0c4
ft_s0f4:
	.word ft_s0p0c4, ft_s0p0c4, ft_s0p4c2, ft_s0p2c3, ft_s0p3c5, ft_s0p3c6, ft_s0p3c7, ft_s0p0c4
ft_s0f5:
	.word ft_s0p0c4, ft_s0p3c1, ft_s0p4c2, ft_s0p2c3, ft_s0p4c5, ft_s0p4c6, ft_s0p4c7, ft_s0p0c4
ft_s0f6:
	.word ft_s0p4c0, ft_s0p4c1, ft_s0p4c2, ft_s0p2c3, ft_s0p5c5, ft_s0p5c6, ft_s0p5c7, ft_s0p0c4
ft_s0f7:
	.word ft_s0p5c0, ft_s0p5c1, ft_s0p5c2, ft_s0p3c3, ft_s0p6c5, ft_s0p6c6, ft_s0p6c7, ft_s0p0c4
ft_s0f8:
	.word ft_s0p6c0, ft_s0p6c1, ft_s0p6c2, ft_s0p2c3, ft_s0p7c5, ft_s0p7c6, ft_s0p5c7, ft_s0p0c4
ft_s0f9:
	.word ft_s0p7c0, ft_s0p7c1, ft_s0p7c2, ft_s0p2c3, ft_s0p8c5, ft_s0p8c6, ft_s0p8c7, ft_s0p0c4
; Bank 0
ft_s0p0c0:
	.byte $92, $00, $03, $E1, $93, $00, $F9, $23, $00, $7F, $00, $23, $00, $7F, $04, $F5, $23, $00, $7F, $00
	.byte $FA, $23, $03, $F5, $23, $00, $7F, $00, $FA, $23, $03, $7F, $03, $FA, $23, $00, $7F, $00, $F7, $23
	.byte $05, $F9, $24, $00, $7F, $00, $24, $00, $7F, $04, $F5, $24, $00, $7F, $00, $FA, $24, $03, $F5, $24
	.byte $00, $7F, $00, $FA, $24, $07, $FA, $24, $00, $7F, $00, $F7, $24, $01

; Bank 0
ft_s0p0c1:
	.byte $E1, $93, $00, $91, $82, $FC, $1C, $01, $7F, $01, $82, $00, $F9, $28, $7F, $28, $7F, $83, $FC, $1C
	.byte $01, $82, $00, $1C, $7F, $F5, $28, $7F, $83, $FA, $28, $03, $F5, $28, $00, $7F, $00, $FA, $28, $03
	.byte $F9, $1C, $01, $7F, $01, $82, $00, $FA, $28, $7F, $F7, $28, $7F, $83, $E2, $93, $01, $FC, $21, $01
	.byte $7F, $01, $82, $00, $E1, $F9, $28, $7F, $28, $7F, $83, $FC, $1C, $01, $82, $00, $1C, $7F, $F5, $28
	.byte $7F, $83, $FA, $28, $03, $F5, $28, $00, $7F, $00, $FA, $28, $03, $F9, $1C, $01, $7F, $01, $82, $00
	.byte $FA, $28, $7F, $F7, $28, $83, $7F, $00

; Bank 0
ft_s0p0c2:
	.byte $E2, $91, $84, $1C, $01, $7F, $01, $2B, $00, $7F, $00, $2B, $00, $7F, $04, $2B, $00, $7F, $00, $2B
	.byte $01, $7F, $01, $2B, $00, $7F, $00, $2B, $01, $7F, $05, $82, $00, $2B, $7F, $2B, $7F, $83, $15, $01
	.byte $7F, $01, $2D, $00, $7F, $00, $2D, $00, $7F, $04, $2D, $00, $7F, $00, $2D, $01, $7F, $01, $2D, $00
	.byte $7F, $00, $2D, $01, $7F, $05, $2D, $00, $7F, $00, $2D, $01

; Bank 0
ft_s0p0c3:
	.byte $E4, $85, $78, $F8, $15, $03, $E7, $F8, $15, $01, $F6, $15, $01, $E8, $F9, $15, $03, $E7, $F8, $15
	.byte $01, $F6, $15, $01, $E4, $85, $78, $F8, $15, $03, $E7, $F8, $15, $01, $F6, $15, $01, $E8, $F9, $15
	.byte $03, $E7, $F8, $15, $01, $F6, $15, $01, $E4, $85, $78, $F8, $15, $03, $E7, $F8, $15, $01, $F6, $15
	.byte $01, $E8, $F9, $15, $03, $E7, $F8, $15, $01, $F6, $15, $01, $E4, $85, $78, $F8, $15, $03, $E7, $F8
	.byte $15, $01, $F6, $15, $01, $E8, $F9, $15, $03, $E7, $F8, $15, $01, $E8, $F9, $15, $01

; Bank 0
ft_s0p0c4:
	.byte $00, $3F

; Bank 0
ft_s0p1c0:
	.byte $00, $03, $E1, $93, $00, $F9, $26, $00, $7F, $00, $26, $00, $7F, $04, $F5, $26, $00, $7F, $00, $FA
	.byte $26, $03, $F5, $26, $00, $7F, $00, $FA, $26, $03, $7F, $03, $FA, $26, $00, $7F, $00, $F7, $26, $05
	.byte $F9, $24, $00, $7F, $00, $24, $00, $7F, $04, $F5, $24, $00, $7F, $00, $FA, $24, $03, $F5, $23, $00
	.byte $7F, $00, $FA, $23, $03, $7F, $03, $FA, $23, $00, $7F, $00, $F7, $23, $01

; Bank 0
ft_s0p1c1:
	.byte $E1, $93, $00, $FC, $1A, $01, $7F, $01, $82, $00, $F9, $28, $7F, $28, $7F, $83, $FC, $1A, $01, $82
	.byte $00, $1A, $7F, $F5, $28, $7F, $83, $FA, $28, $03, $F5, $28, $00, $7F, $00, $FA, $28, $03, $F9, $1A
	.byte $01, $7F, $01, $82, $00, $FA, $28, $7F, $F7, $28, $7F, $83, $93, $01, $FC, $15, $01, $7F, $01, $82
	.byte $00, $F9, $28, $7F, $28, $7F, $83, $E0, $FC, $15, $01, $82, $00, $15, $7F, $E1, $F5, $28, $7F, $83
	.byte $FA, $28, $01, $FC, $17, $01, $F5, $27, $00, $7F, $00, $FA, $27, $03, $F9, $17, $01, $7F, $01, $82
	.byte $00, $FA, $27, $7F, $F7, $27, $83, $7F, $00

; Bank 0
ft_s0p1c2:
	.byte $E2, $1A, $01, $7F, $01, $2D, $00, $7F, $00, $2D, $00, $7F, $04, $2D, $00, $7F, $00, $2D, $01, $7F
	.byte $01, $2D, $00, $7F, $00, $2D, $01, $7F, $05, $2D, $00, $7F, $00, $2D, $01, $15, $01, $7F, $01, $2D
	.byte $00, $7F, $00, $2D, $00, $7F, $04, $2D, $00, $7F, $00, $2D, $01, $17, $01, $2A, $00, $7F, $00, $2A
	.byte $01, $7F, $05, $2A, $00, $7F, $00, $2A, $01

; Bank 0
ft_s0p1c3:
	.byte $E6, $85, $78, $FF, $11, $03, $82, $00, $E8, $F9, $15, $ED, $F7, $11, $E8, $F7, $15, $ED, $F5, $11
	.byte $83, $E8, $F9, $15, $03, $E7, $F8, $15, $01, $F6, $15, $01, $E4, $85, $78, $F8, $15, $03, $E7, $F8
	.byte $15, $01, $F6, $15, $01, $E8, $F9, $15, $03, $E7, $F8, $15, $01, $F6, $15, $01, $E4, $85, $78, $F8
	.byte $15, $03, $E7, $F8, $15, $01, $F6, $15, $01, $E8, $F9, $15, $03, $E7, $F8, $15, $01, $F6, $15, $01
	.byte $E4, $85, $78, $F8, $15, $03, $E7, $F8, $15, $01, $F6, $15, $01, $E8, $F9, $15, $03, $E7, $F8, $15
	.byte $01, $E8, $F9, $15, $01

; Bank 0
ft_s0p1c5:
	.byte $00, $03, $80, $24, $F7, $1C, $00, $7E, $00, $F5, $1C, $00, $7E, $02, $82, $00, $F7, $1C, $7F, $F5
	.byte $1C, $7E, $83, $F6, $1C, $03, $F5, $1C, $00, $7E, $00, $F6, $1C, $03, $7E, $03, $F7, $1C, $00, $7E
	.byte $00, $F5, $1C, $00, $7E, $02, $82, $00, $F8, $1C, $7F, $F7, $1C, $7E, $F5, $1C, $83, $7E, $02, $82
	.byte $00, $F8, $1C, $7F, $F5, $1C, $7E, $83, $F6, $1C, $03, $F5, $1C, $00, $7E, $00, $F6, $1C, $03, $7E
	.byte $03, $82, $00, $F7, $1C, $7E, $F5, $1C, $83, $7E, $00

; Bank 0
ft_s0p1c6:
	.byte $00, $03, $80, $24, $F8, $1F, $00, $7E, $00, $F6, $1F, $00, $7E, $02, $82, $00, $F7, $1F, $7F, $F6
	.byte $1F, $7E, $83, $F7, $1F, $03, $F6, $1F, $00, $7E, $00, $F7, $1F, $05, $7E, $01, $F8, $1F, $00, $7E
	.byte $00, $F6, $1F, $00, $7E, $02, $82, $00, $F8, $21, $7F, $F8, $21, $7E, $F6, $21, $83, $7E, $02, $82
	.byte $00, $F8, $21, $7F, $F6, $21, $7E, $83, $F7, $21, $03, $F6, $21, $00, $7E, $00, $F7, $21, $05, $7E
	.byte $01, $82, $00, $F8, $21, $7E, $F6, $21, $83, $7E, $00

; Bank 0
ft_s0p1c7:
	.byte $E3, $FF, $10, $1F, $10, $1F

; Bank 0
ft_s0p2c2:
	.byte $E9, $1C, $01, $7F, $01, $82, $00, $E2, $2B, $7F, $2B, $7F, $83, $EB, $01, $03, $E2, $2B, $00, $7F
	.byte $00, $2B, $01, $EB, $01, $01, $E2, $2B, $00, $7F, $00, $2B, $01, $7F, $01, $EB, $01, $03, $82, $00
	.byte $E2, $2B, $7F, $2B, $7F, $83, $E9, $15, $01, $7F, $01, $82, $00, $E2, $2D, $7F, $2D, $7F, $83, $EB
	.byte $01, $03, $E2, $2D, $00, $7F, $00, $2D, $01, $EB, $01, $01, $E2, $2D, $00, $7F, $00, $2D, $01, $7F
	.byte $01, $EB, $01, $03, $E2, $2D, $00, $7F, $00, $2D, $01

; Bank 0
ft_s0p2c3:
	.byte $E6, $85, $78, $FF, $11, $03, $82, $00, $E8, $F9, $15, $ED, $F7, $11, $E8, $F7, $15, $ED, $F5, $11
	.byte $83, $E5, $FC, $11, $03, $E7, $F8, $15, $01, $E4, $F8, $11, $01, $85, $78, $00, $03, $F8, $11, $01
	.byte $E7, $F8, $15, $01, $E5, $FC, $11, $03, $E7, $F8, $15, $01, $E8, $F6, $15, $01, $E4, $85, $78, $F8
	.byte $11, $03, $E7, $F8, $15, $01, $F6, $15, $01, $E5, $FC, $11, $03, $82, $01, $E7, $F8, $15, $E4, $F8
	.byte $11, $85, $78, $00, $E5, $F9, $11, $E4, $F8, $11, $E7, $F6, $15, $83, $E5, $FC, $11, $03, $E4, $F8
	.byte $11, $01, $E5, $FC, $11, $01

; Bank 0
ft_s0p2c5:
	.byte $00, $01, $82, $00, $80, $24, $F6, $1C, $7F, $F7, $1C, $7E, $F5, $1C, $83, $7E, $02, $82, $00, $F6
	.byte $1C, $7F, $F5, $1C, $7E, $83, $F6, $1C, $03, $F5, $1C, $00, $7E, $00, $F6, $1C, $03, $7E, $03, $F7
	.byte $1C, $00, $7E, $00, $F5, $1C, $00, $7E, $02, $82, $00, $F6, $1C, $7F, $F7, $1C, $7E, $F5, $1C, $83
	.byte $7E, $02, $82, $00, $F8, $1C, $7F, $F5, $1C, $7E, $83, $F6, $1C, $03, $F5, $1B, $00, $7E, $00, $F6
	.byte $1B, $03, $7E, $01, $82, $00, $F6, $1B, $7F, $F7, $1B, $7E, $F4, $1B, $83, $7E, $00

; Bank 0
ft_s0p2c6:
	.byte $00, $01, $82, $00, $80, $24, $F6, $21, $7F, $F8, $21, $7E, $F6, $21, $83, $7E, $02, $82, $00, $F6
	.byte $21, $7F, $F6, $21, $7E, $83, $F7, $21, $03, $F6, $21, $00, $7E, $00, $F7, $21, $05, $7E, $01, $F8
	.byte $21, $00, $7E, $00, $F6, $21, $00, $7E, $02, $82, $00, $F6, $21, $7F, $F8, $21, $7E, $F6, $21, $83
	.byte $7E, $02, $82, $00, $F8, $21, $7F, $F6, $21, $7E, $83, $F7, $21, $03, $F6, $23, $00, $7E, $00, $F7
	.byte $23, $05, $82, $00, $F6, $23, $7F, $F8, $23, $7E, $F5, $23, $83, $7E, $00

; Bank 0
ft_s0p2c7:
	.byte $E3, $0E, $1F, $09, $0F, $0B, $0F

; Bank 0
ft_s0p3c1:
	.byte $00, $39, $EE, $92, $FA, $23, $01, $26, $00, $7E, $02

; Bank 0
ft_s0p3c2:
	.byte $E9, $1A, $01, $7F, $01, $82, $00, $E2, $2D, $7F, $2D, $7F, $83, $EB, $01, $03, $E2, $2D, $00, $7F
	.byte $00, $2D, $01, $EB, $01, $01, $E2, $2D, $00, $7F, $00, $2D, $01, $7F, $01, $EB, $01, $03, $E2, $2D
	.byte $00, $7F, $00, $2D, $01, $E9, $15, $01, $7F, $01, $82, $00, $E2, $2D, $7F, $2D, $7F, $83, $EB, $01
	.byte $03, $E2, $2D, $00, $7F, $00, $2D, $01, $E9, $17, $01, $E2, $2A, $00, $7F, $00, $2A, $01, $7F, $01
	.byte $EB, $01, $03, $E2, $2A, $00, $7F, $00, $2A, $01

; Bank 0
ft_s0p3c3:
	.byte $E4, $85, $78, $F8, $15, $03, $E7, $F8, $15, $01, $F6, $15, $01, $E5, $FC, $11, $03, $E7, $F8, $15
	.byte $01, $E4, $F8, $11, $01, $85, $78, $00, $03, $F8, $11, $01, $E7, $F8, $15, $01, $E5, $FC, $11, $03
	.byte $E7, $F8, $15, $01, $E8, $F6, $15, $01, $E4, $85, $78, $F8, $11, $03, $E7, $F8, $15, $01, $F6, $15
	.byte $01, $E5, $FC, $11, $03, $82, $01, $E7, $F8, $15, $E4, $F8, $11, $85, $78, $00, $E5, $F9, $11, $E4
	.byte $F8, $11, $E7, $F6, $15, $83, $E5, $FC, $11, $03, $E4, $F8, $11, $01, $E5, $FC, $11, $01

; Bank 0
ft_s0p3c5:
	.byte $80, $26, $91, $81, $F8, $10, $03, $7E, $03, $1C, $01, $7E, $03, $1C, $01, $7F, $01, $17, $00, $7E
	.byte $00, $1C, $03, $7E, $03, $17, $01, $1A, $00, $7F, $00, $10, $03, $7E, $03, $1C, $01, $7E, $03, $1C
	.byte $01, $7F, $01, $10, $00, $7E, $00, $1C, $03, $15, $00, $17, $01, $7E, $00, $13, $01, $7E, $01

; Bank 0
ft_s0p3c6:
	.byte $80, $26, $91, $82, $FC, $04, $03, $7E, $03, $10, $01, $7E, $03, $10, $01, $7F, $01, $0B, $00, $7E
	.byte $00, $10, $03, $7E, $03, $0B, $01, $0E, $00, $7F, $00, $04, $03, $7E, $03, $10, $01, $7E, $03, $10
	.byte $01, $7F, $01, $04, $00, $7E, $00, $10, $03, $09, $00, $0B, $01, $7E, $00, $07, $01, $7E, $01

; Bank 0
ft_s0p3c7:
	.byte $E0, $FF, $04, $03, $7E, $03, $10, $01, $7E, $03, $10, $01, $7F, $01, $0B, $00, $7E, $00, $10, $03
	.byte $7E, $03, $0B, $01, $0E, $00, $7F, $00, $04, $03, $7E, $03, $10, $01, $7E, $03, $10, $01, $7F, $01
	.byte $04, $00, $7E, $00, $10, $03, $09, $00, $0B, $01, $7E, $00, $07, $01, $7E, $01

; Bank 0
ft_s0p4c0:
	.byte $82, $00, $EF, $91, $82, $F6, $10, $F2, $13, $F6, $12, $F2, $10, $F7, $13, $F2, $12, $F7, $17, $F3
	.byte $13, $F8, $1C, $F3, $17, $F8, $1E, $F4, $1C, $F9, $1F, $F4, $1E, $F9, $23, $F5, $1F, $FA, $28, $F5
	.byte $23, $F9, $23, $F6, $28, $F9, $1F, $F5, $23, $F8, $1E, $F5, $1F, $F8, $1C, $F4, $1E, $F7, $17, $F4
	.byte $1C, $F7, $13, $F3, $17, $F6, $12, $F3, $13, $F6, $10, $F2, $12, $F6, $13, $F2, $10, $F7, $15, $F3
	.byte $13, $F7, $18, $F3, $15, $F8, $1C, $F4, $18, $F8, $1F, $F4, $1C, $F9, $21, $F5, $1F, $F9, $24, $F5
	.byte $21, $FA, $28, $F6, $24, $F9, $24, $F6, $28, $F9, $21, $F5, $24, $F8, $1F, $F5, $21, $F8, $1C, $F4
	.byte $1F, $F7, $18, $F4, $1C, $F7, $15, $F3, $18, $F6, $13, $83, $F3, $15, $00

; Bank 0
ft_s0p4c1:
	.byte $EE, $8F, $06, $28, $01, $8F, $16, $00, $01, $8F, $26, $00, $03, $8F, $00, $2F, $00, $7E, $02, $28
	.byte $00, $7E, $00, $98, $11, $2F, $05, $FA, $2F, $00, $F8, $30, $00, $82, $01, $F7, $2F, $FA, $2D, $7E
	.byte $FA, $2B, $7E, $8F, $06, $2A, $8F, $16, $00, $83, $8F, $26, $00, $0B, $7E, $0B, $8F, $00, $FA, $28
	.byte $01, $7E, $01

; Bank 0
ft_s0p4c2:
	.byte $EB, $01, $07, $EC, $01, $05, $EB, $01, $05, $01, $03, $EC, $01, $07, $EB, $25, $07, $EC, $25, $05
	.byte $EB, $25, $03, $EC, $25, $01, $EB, $25, $03, $EC, $25, $03, $EB, $25, $01, $EC, $25, $01

; Bank 0
ft_s0p4c5:
	.byte $80, $26, $F8, $10, $03, $7E, $03, $1C, $01, $7E, $03, $1C, $01, $7F, $01, $17, $00, $7E, $00, $1C
	.byte $03, $7E, $03, $17, $01, $1A, $00, $7F, $00, $FC, $10, $01, $7E, $01, $FC, $10, $02, $7E, $00, $82
	.byte $01, $1C, $7E, $10, $1C, $83, $7E, $0D, $EE, $F5, $23, $01

; Bank 0
ft_s0p4c6:
	.byte $80, $26, $FC, $04, $03, $7E, $03, $10, $01, $7E, $03, $10, $01, $7F, $01, $0B, $00, $7E, $00, $10
	.byte $03, $7E, $03, $0B, $01, $0E, $00, $7F, $00, $FC, $04, $01, $7E, $01, $FC, $04, $02, $7E, $00, $82
	.byte $01, $10, $7E, $04, $10, $83, $7E, $0F

; Bank 0
ft_s0p4c7:
	.byte $E0, $FF, $04, $03, $7E, $03, $10, $01, $7E, $03, $10, $01, $7F, $01, $0B, $00, $7E, $00, $10, $03
	.byte $7E, $03, $0B, $01, $0E, $00, $7F, $00, $FF, $04, $01, $7E, $01, $FF, $04, $02, $7E, $00, $82, $01
	.byte $E3, $10, $7E, $04, $10, $83, $7E, $0F

; Bank 0
ft_s0p5c0:
	.byte $82, $00, $EF, $F6, $0F, $F2, $12, $F6, $12, $F2, $0F, $F7, $15, $F2, $12, $F7, $17, $F3, $15, $F8
	.byte $1B, $F3, $17, $F8, $1E, $F4, $1B, $F9, $21, $F4, $1E, $F9, $23, $F5, $21, $FA, $27, $F5, $23, $F9
	.byte $23, $F6, $27, $F9, $21, $F5, $23, $F8, $1E, $F5, $21, $F8, $1B, $F4, $1E, $F7, $17, $F4, $1B, $F7
	.byte $15, $F3, $17, $F6, $12, $F3, $15, $83, $EE, $98, $11, $8F, $06, $F9, $23, $01, $8F, $15, $00, $01
	.byte $8F, $25, $00, $02, $7E, $00, $27, $01, $24, $00, $7E, $02, $8F, $06, $23, $01, $8F, $15, $00, $01
	.byte $8F, $25, $00, $05, $7E, $07

; Bank 0
ft_s0p5c1:
	.byte $EE, $8F, $06, $FA, $27, $01, $8F, $16, $00, $01, $8F, $26, $00, $03, $8F, $00, $2D, $00, $7E, $02
	.byte $27, $00, $7E, $00, $2F, $05, $FA, $2D, $00, $F8, $2F, $00, $82, $01, $F7, $2D, $FA, $2B, $7E, $FA
	.byte $2A, $7E, $98, $11, $8F, $06, $F9, $27, $8F, $16, $00, $83, $8F, $26, $00, $02, $7E, $00, $2A, $01
	.byte $28, $00, $7E, $02, $8F, $06, $27, $01, $8F, $16, $00, $01, $8F, $26, $00, $05, $7E, $07

; Bank 0
ft_s0p5c2:
	.byte $EB, $01, $07, $EC, $01, $05, $EB, $01, $05, $01, $03, $EC, $01, $07, $E9, $2D, $07, $EA, $30, $01
	.byte $E2, $2D, $00, $7F, $02, $2A, $03, $EA, $2A, $01, $E9, $2A, $03, $82, $01, $EA, $01, $7F, $EB, $01
	.byte $83, $EC, $01, $01

; Bank 0
ft_s0p5c5:
	.byte $EE, $26, $00, $7E, $02, $80, $24, $F4, $23, $00, $7E, $00, $F8, $23, $01, $F6, $23, $00, $7E, $02
	.byte $82, $00, $F8, $23, $7E, $F6, $23, $7E, $EE, $F5, $28, $7E, $83, $98, $11, $2F, $05, $F5, $2F, $00
	.byte $F3, $30, $00, $82, $01, $F2, $2F, $F5, $2D, $7E, $F5, $2B, $7E, $83, $80, $24, $F4, $24, $00, $7E
	.byte $00, $F8, $24, $01, $F6, $24, $00, $7E, $02, $F8, $24, $00, $7E, $00, $F6, $24, $00, $7E, $10

; Bank 0
ft_s0p5c6:
	.byte $00, $03, $80, $24, $F3, $28, $00, $7E, $00, $F7, $28, $01, $F4, $28, $00, $7E, $02, $F7, $28, $00
	.byte $7E, $00, $F4, $28, $00, $7E, $14, $F3, $28, $00, $7E, $00, $F7, $28, $01, $F4, $28, $00, $7E, $02
	.byte $F7, $28, $00, $7E, $00, $F4, $28, $00, $7E, $10

; Bank 0
ft_s0p5c7:
	.byte $E0, $FF, $04, $03, $7E, $03, $10, $01, $7E, $03, $10, $01, $7F, $01, $E3, $04, $00, $7E, $00, $E0
	.byte $10, $03, $7E, $03, $E3, $04, $01, $7E, $01, $E0, $FF, $09, $03, $7E, $03, $15, $01, $7E, $03, $15
	.byte $01, $7F, $01, $E3, $09, $00, $7E, $00, $E0, $15, $03, $7E, $03, $E3, $09, $01, $7E, $01

; Bank 0
ft_s0p6c0:
	.byte $E1, $93, $00, $8F, $00, $FC, $1C, $07, $FA, $28, $01, $7F, $01, $FC, $1C, $01, $F9, $28, $00, $7F
	.byte $02, $FC, $1C, $01, $FA, $28, $00, $7F, $0A, $FC, $1C, $00, $7F, $02, $FA, $1C, $00, $7F, $02, $F9
	.byte $28, $01, $7F, $01, $FC, $1C, $01, $F9, $28, $00, $7F, $02, $FC, $1C, $01, $F9, $28, $00, $7F, $0A

; Bank 0
ft_s0p6c1:
	.byte $80, $20, $8F, $00, $F6, $34, $03, $F5, $40, $01, $F6, $34, $05, $F6, $34, $03, $F5, $40, $01, $F6
	.byte $34, $0D, $F6, $34, $03, $F6, $34, $03, $F5, $40, $01, $F6, $34, $03, $F5, $40, $01, $F6, $34, $03
	.byte $F5, $40, $01, $F6, $34, $00, $7F, $08

; Bank 0
ft_s0p6c2:
	.byte $EB, $01, $07, $EA, $2B, $01, $7F, $03, $E9, $2B, $00, $7F, $04, $2B, $00, $7F, $02, $EC, $01, $07
	.byte $EB, $01, $07, $EA, $2D, $01, $7F, $03, $E9, $2D, $00, $7F, $02, $EC, $01, $01, $E9, $2D, $00, $7F
	.byte $02, $EC, $01, $03, $EB, $01, $01, $EC, $01, $01

; Bank 0
ft_s0p6c5:
	.byte $EE, $F5, $28, $01, $7E, $01, $80, $24, $F4, $23, $00, $7E, $00, $F8, $23, $01, $F6, $23, $00, $7E
	.byte $02, $82, $00, $F8, $23, $7E, $F6, $23, $7E, $EE, $F5, $27, $7E, $83, $2F, $05, $F5, $2D, $00, $F3
	.byte $2F, $00, $82, $01, $F2, $2D, $F5, $2B, $7E, $F5, $2A, $7E, $83, $80, $24, $F4, $24, $00, $7E, $00
	.byte $F7, $24, $01, $82, $00, $F6, $24, $7E, $F3, $24, $7E, $F7, $24, $7E, $F6, $24, $83, $7E, $04, $F4
	.byte $23, $00, $7E, $00, $F7, $23, $01, $82, $00, $F6, $23, $7E, $F3, $23, $7E, $F7, $23, $7E, $F6, $23
	.byte $83, $7E, $00

; Bank 0
ft_s0p6c6:
	.byte $00, $03, $80, $24, $F3, $27, $00, $7E, $00, $F7, $27, $01, $F4, $27, $00, $7E, $02, $F7, $27, $00
	.byte $7E, $00, $F4, $27, $00, $7E, $14, $F3, $2B, $00, $7E, $00, $F6, $2B, $01, $82, $00, $F4, $2B, $7E
	.byte $F2, $2B, $7E, $F6, $2B, $7E, $F4, $2B, $83, $7E, $04, $F3, $2A, $00, $7E, $00, $F6, $2A, $01, $82
	.byte $00, $F4, $2A, $7E, $F2, $2A, $7E, $F6, $2A, $7E, $F4, $2A, $83, $7E, $00

; Bank 0
ft_s0p6c7:
	.byte $E0, $FF, $0B, $03, $7E, $03, $17, $01, $7E, $03, $17, $01, $7F, $01, $E3, $0B, $00, $7E, $00, $E0
	.byte $17, $03, $7E, $03, $E3, $0B, $01, $7E, $01, $FF, $09, $03, $7E, $03, $15, $01, $7E, $03, $0B, $01
	.byte $7F, $01, $17, $00, $7E, $00, $0B, $03, $7E, $03, $0B, $01, $7E, $01

; Bank 0
ft_s0p7c0:
	.byte $E1, $93, $00, $FC, $17, $07, $FA, $27, $01, $7F, $01, $FC, $17, $01, $F9, $27, $00, $7F, $02, $FC
	.byte $17, $01, $FA, $27, $00, $7F, $0A, $80, $22, $FF, $0B, $0B, $7E, $0D, $E1, $FA, $1A, $01, $F9, $1B
	.byte $00, $7F, $02

; Bank 0
ft_s0p7c1:
	.byte $00, $1F, $EE, $8F, $06, $F8, $1E, $01, $8F, $16, $00, $01, $8F, $16, $00, $03, $7E, $03, $8F, $00
	.byte $00, $0D, $E1, $F8, $1F, $01, $82, $00, $F7, $21, $7F, $22, $83, $86, $01, $7F, $00

; Bank 0
ft_s0p7c2:
	.byte $EB, $01, $07, $EA, $2A, $01, $7F, $03, $E9, $2A, $00, $7F, $04, $2A, $00, $7F, $02, $EC, $01, $07
	.byte $E9, $23, $07, $EC, $01, $05, $EB, $01, $03, $EC, $01, $01, $EB, $01, $03, $EC, $01, $03, $EB, $01
	.byte $01, $EC, $01, $01

; Bank 0
ft_s0p7c5:
	.byte $00, $07, $E1, $93, $02, $F9, $23, $01, $7F, $03, $F8, $23, $00, $7F, $04, $F9, $23, $00, $7F, $12
	.byte $F9, $24, $00, $7F, $04, $F8, $24, $00, $7F, $04, $F9, $24, $00, $7F, $0A

; Bank 0
ft_s0p7c6:
	.byte $80, $26, $FC, $04, $03, $7E, $03, $80, $24, $93, $02, $F7, $1F, $01, $7F, $03, $F6, $1F, $00, $7F
	.byte $04, $F7, $1F, $00, $7F, $0A, $80, $26, $FC, $09, $03, $7E, $03, $80, $24, $93, $02, $F7, $21, $01
	.byte $7F, $03, $F6, $21, $00, $7F, $04, $F7, $21, $00, $7F, $0A

; Bank 0
ft_s0p8c5:
	.byte $00, $07, $E1, $93, $02, $FA, $23, $01, $7F, $03, $F9, $23, $00, $7F, $04, $FA, $23, $00, $7F, $2A

; Bank 0
ft_s0p8c6:
	.byte $80, $26, $FC, $0B, $03, $7E, $03, $80, $24, $93, $02, $F6, $1E, $01, $7F, $03, $F5, $1E, $00, $7F
	.byte $04, $F6, $1E, $00, $7F, $0A, $80, $26, $FC, $0B, $01, $82, $00, $FB, $00, $FA, $00, $F9, $00, $F8
	.byte $00, $83, $F7, $00, $01, $7E, $09, $FC, $0B, $01, $FA, $09, $00, $7E, $02, $82, $01, $FC, $07, $7E
	.byte $FC, $06, $83, $7E, $01

; Bank 0
ft_s0p8c7:
	.byte $E0, $FF, $0B, $03, $7E, $03, $17, $01, $7E, $03, $17, $01, $7F, $01, $E3, $0B, $00, $7E, $00, $E0
	.byte $17, $03, $7E, $01, $E3, $0B, $00, $7E, $00, $17, $01, $7E, $01, $FF, $0B, $01, $82, $00, $FE, $00
	.byte $FD, $00, $FC, $00, $FB, $00, $83, $FA, $00, $01, $7E, $09, $FF, $0B, $01, $FD, $09, $00, $7E, $02
	.byte $82, $01, $FF, $07, $7E, $FF, $06, $83, $7E, $01


; DPCM samples (located at DPCM segment)
