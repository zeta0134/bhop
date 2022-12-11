; Dn-FamiTracker exported music data: mimiga-zsaw-lead.dnm
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
	.word 1 ; N163 channels

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
	.word ft_inst_20
	.word ft_inst_21
	.word ft_inst_22
	.word ft_inst_23
	.word ft_inst_24
	.word ft_inst_25
	.word ft_inst_26
	.word ft_inst_27
	.word ft_inst_28

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
	.byte $15
	.word ft_seq_2a03_10
	.word ft_seq_2a03_2
	.word ft_seq_2a03_14

ft_inst_3:
	.byte 0
	.byte $15
	.word ft_seq_2a03_25
	.word ft_seq_2a03_7
	.word ft_seq_2a03_14

ft_inst_4:
	.byte 0
	.byte $11
	.word ft_seq_2a03_15
	.word ft_seq_2a03_29

ft_inst_5:
	.byte 0
	.byte $11
	.word ft_seq_2a03_30
	.word ft_seq_2a03_34

ft_inst_6:
	.byte 0
	.byte $11
	.word ft_seq_2a03_35
	.word ft_seq_2a03_39

ft_inst_7:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_1
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_8:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_6
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_9:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_11
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_10:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_16
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_11:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_21
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_12:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_26
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_13:
	.byte 0
	.byte $05
	.word ft_seq_2a03_45
	.word ft_seq_2a03_2

ft_inst_14:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_31
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_15:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_36
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_16:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_41
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_17:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_46
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_18:
	.byte 0
	.byte $17
	.word ft_seq_2a03_40
	.word ft_seq_2a03_51
	.word ft_seq_2a03_7
	.word ft_seq_2a03_19

ft_inst_19:
	.byte 0
	.byte $07
	.word ft_seq_2a03_45
	.word ft_seq_2a03_56
	.word ft_seq_2a03_2

ft_inst_20:
	.byte 0
	.byte $13
	.word ft_seq_2a03_50
	.word ft_seq_2a03_61
	.word ft_seq_2a03_44

ft_inst_21:
	.byte 0
	.byte $03
	.word ft_seq_2a03_55
	.word ft_seq_2a03_66

ft_inst_22:
	.byte 0
	.byte $03
	.word ft_seq_2a03_60
	.word ft_seq_2a03_71

ft_inst_23:
	.byte 0
	.byte $03
	.word ft_seq_2a03_65
	.word ft_seq_2a03_71

ft_inst_24:
	.byte 0
	.byte $03
	.word ft_seq_2a03_70
	.word ft_seq_2a03_76

ft_inst_25:
	.byte 0
	.byte $03
	.word ft_seq_2a03_55
	.word ft_seq_2a03_66

ft_inst_26:
	.byte 0
	.byte $13
	.word ft_seq_2a03_75
	.word ft_seq_2a03_61
	.word ft_seq_2a03_44

ft_inst_27:
	.byte 9
	.byte $13
	.word ft_seq_n163_15
	.word ft_seq_n163_1
	.word ft_seq_n163_9
	.byte $10
	.byte $00
	.word ft_waves_31

ft_inst_28:
	.byte 9
	.byte $11
	.word ft_seq_n163_20
	.word ft_seq_n163_14
	.byte $10
	.byte $00
	.word ft_waves_31

; Sequences
ft_seq_2a03_0:
	.byte $10, $FF, $00, $00, $05, $05, $05, $04, $04, $04, $03, $03, $03, $02, $02, $02, $01, $01, $01, $01
ft_seq_2a03_1:
	.byte $04, $FF, $00, $01, $2D, $24, $24, $2D
ft_seq_2a03_2:
	.byte $1C, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $01, $01, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $01, $01
ft_seq_2a03_4:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_5:
	.byte $06, $FF, $00, $00, $02, $02, $01, $01, $01, $01
ft_seq_2a03_6:
	.byte $04, $FF, $00, $01, $29, $24, $24, $29
ft_seq_2a03_7:
	.byte $0C, $04, $00, $00, $00, $00, $00, $00, $01, $01, $FF, $FF, $FF, $FF, $01, $01
ft_seq_2a03_9:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_10:
	.byte $23, $FF, $00, $00, $05, $06, $07, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $05, $05, $05
	.byte $04, $04, $04, $04, $04, $04, $04, $04, $04, $03, $03, $03, $03, $03, $03, $03, $03, $03, $02
ft_seq_2a03_11:
	.byte $04, $FF, $00, $01, $30, $2D, $2D, $30
ft_seq_2a03_14:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_15:
	.byte $05, $FF, $00, $00, $09, $0A, $06, $04, $00
ft_seq_2a03_16:
	.byte $04, $FF, $00, $01, $30, $24, $24, $30
ft_seq_2a03_19:
	.byte $04, $FF, $00, $00, $02, $01, $01, $02
ft_seq_2a03_21:
	.byte $04, $FF, $00, $01, $30, $1F, $1F, $30
ft_seq_2a03_25:
	.byte $01, $FF, $00, $00, $03
ft_seq_2a03_26:
	.byte $04, $FF, $00, $01, $2E, $1D, $1D, $2E
ft_seq_2a03_29:
	.byte $01, $FF, $00, $00, $01
ft_seq_2a03_30:
	.byte $0B, $FF, $00, $00, $02, $04, $03, $03, $02, $02, $02, $01, $01, $01, $01
ft_seq_2a03_31:
	.byte $04, $FF, $00, $01, $25, $2E, $2E, $25
ft_seq_2a03_34:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_35:
	.byte $10, $FF, $00, $00, $05, $05, $05, $04, $04, $04, $03, $03, $03, $02, $02, $02, $01, $01, $01, $01
ft_seq_2a03_36:
	.byte $04, $FF, $00, $01, $2E, $22, $22, $2E
ft_seq_2a03_39:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_40:
	.byte $23, $FF, $00, $00, $05, $09, $08, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $05, $05, $05
	.byte $04, $04, $04, $04, $04, $04, $04, $04, $04, $03, $03, $03, $03, $03, $03, $03, $03, $03, $02
ft_seq_2a03_41:
	.byte $04, $FF, $00, $01, $2D, $21, $21, $2D
ft_seq_2a03_44:
	.byte $02, $FF, $00, $00, $01, $00
ft_seq_2a03_45:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_46:
	.byte $04, $FF, $00, $01, $2B, $26, $26, $2B
ft_seq_2a03_50:
	.byte $0E, $FF, $00, $00, $0D, $0D, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00
ft_seq_2a03_51:
	.byte $04, $FF, $00, $01, $29, $23, $23, $29
ft_seq_2a03_55:
	.byte $02, $FF, $00, $00, $0D, $00
ft_seq_2a03_56:
	.byte $02, $FF, $00, $01, $26, $23
ft_seq_2a03_60:
	.byte $05, $03, $00, $00, $07, $02, $01, $00, $00
ft_seq_2a03_61:
	.byte $08, $FF, $00, $01, $05, $0C, $0C, $0C, $0C, $0C, $0C, $0C
ft_seq_2a03_65:
	.byte $06, $FF, $00, $00, $07, $03, $02, $01, $01, $00
ft_seq_2a03_66:
	.byte $0C, $FF, $00, $01, $0C, $09, $0A, $0A, $0A, $0B, $0B, $0B, $0C, $0C, $0D, $0D
ft_seq_2a03_70:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_71:
	.byte $04, $FF, $00, $01, $0C, $09, $0A, $0A
ft_seq_2a03_75:
	.byte $30, $FF, $00, $00, $0D, $0D, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $01, $01, $01
	.byte $01, $02, $02, $02, $02, $02, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $02, $02, $02, $02
	.byte $02, $02, $02, $02, $02, $02, $02, $01, $01, $01, $01, $00
ft_seq_2a03_76:
	.byte $02, $FF, $00, $01, $31, $2C
ft_seq_n163_1:
	.byte $01, $00, $00, $00, $F4
ft_seq_n163_9:
	.byte $01, $FF, $00, $00, $00
ft_seq_n163_14:
	.byte $01, $FF, $00, $00, $02
ft_seq_n163_15:
	.byte $22, $16, $00, $00, $04, $06, $07, $08, $09, $0A, $0B, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0B, $0B
	.byte $0B, $0B, $0A, $09, $08, $07, $06, $06, $05, $04, $04, $04, $05, $06, $06, $07, $07, $07
ft_seq_n163_20:
	.byte $1E, $15, $00, $00, $05, $06, $07, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $05, $05, $05
	.byte $04, $04, $04, $04, $04, $04, $03, $03, $03, $03, $03, $03, $04, $04

; N163 waves
ft_waves_31:
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $10, $32, $54, $76, $98, $BA, $DC, $FE
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $10, $32, $54, $76, $98, $BA, $DC, $FE
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $EF, $CD, $AB, $89, $67, $45, $23, $01
	.byte $88, $99, $AA, $BB, $CC, $DD, $EE, $FF, $77, $66, $55, $44, $33, $22, $11, $00

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
	.byte 64	; pattern length
	.byte 6	; speed
	.byte 240	; tempo
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
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c2, ft_s0p0c2, ft_s0p0c4
ft_s0f1:
	.word ft_s0p3c0, ft_s0p7c1, ft_s0p0c2, ft_s0p0c2, ft_s0p6c5, ft_s0p0c4
ft_s0f2:
	.word ft_s0p4c0, ft_s0p8c1, ft_s0p0c2, ft_s0p0c2, ft_s0p7c5, ft_s0p0c4
ft_s0f3:
	.word ft_s0p5c0, ft_s0p9c1, ft_s0p0c2, ft_s0p0c2, ft_s0p8c5, ft_s0p0c4
ft_s0f4:
	.word ft_s0p6c0, ft_s0p10c1, ft_s0p0c2, ft_s0p0c2, ft_s0p9c5, ft_s0p0c4
ft_s0f5:
	.word ft_s0p3c0, ft_s0p3c1, ft_s0p1c2, ft_s0p0c2, ft_s0p1c5, ft_s0p0c4
ft_s0f6:
	.word ft_s0p4c0, ft_s0p4c1, ft_s0p2c2, ft_s0p0c2, ft_s0p2c5, ft_s0p0c4
ft_s0f7:
	.word ft_s0p5c0, ft_s0p5c1, ft_s0p3c2, ft_s0p0c2, ft_s0p3c5, ft_s0p0c4
ft_s0f8:
	.word ft_s0p6c0, ft_s0p6c1, ft_s0p4c2, ft_s0p0c2, ft_s0p4c5, ft_s0p0c4
ft_s0f9:
	.word ft_s0p7c0, ft_s0p12c1, ft_s0p6c2, ft_s0p1c3, ft_s0p1c5, ft_s0p0c4
ft_s0f10:
	.word ft_s0p9c0, ft_s0p13c1, ft_s0p7c2, ft_s0p1c3, ft_s0p2c5, ft_s0p0c4
ft_s0f11:
	.word ft_s0p10c0, ft_s0p10c0, ft_s0p8c2, ft_s0p1c3, ft_s0p3c5, ft_s0p0c4
ft_s0f12:
	.word ft_s0p11c0, ft_s0p11c0, ft_s0p9c2, ft_s0p2c3, ft_s0p4c5, ft_s0p0c4
ft_s0f13:
	.word ft_s0p8c0, ft_s0p11c1, ft_s0p5c2, ft_s0p0c2, ft_s0p5c5, ft_s0p0c4
; Bank 0
ft_s0p0c0:
	.byte $82, $03, $E0, $FF, $3D, $31, $38, $36, $31, $38, $36, $31, $FF, $3D, $31, $38, $36, $31, $38, $36
	.byte $83, $31, $03

; Bank 0
ft_s0p0c1:
	.byte $7F, $05, $82, $03, $E1, $3D, $3D, $38, $36, $36, $38, $83, $36, $07, $82, $03, $3D, $3D, $38, $36
	.byte $36, $38, $83, $36, $01

; Bank 0
ft_s0p0c2:
	.byte $7F, $3F

; Bank 0
ft_s0p0c4:
	.byte $00, $3F

; Bank 0
ft_s0p1c2:
	.byte $ED, $2E, $07, $31, $07, $2F, $03, $2E, $07, $2E, $03, $35, $07, $31, $03, $35, $0B, $35, $07

; Bank 0
ft_s0p1c3:
	.byte $82, $03, $80, $2A, $19, $80, $2C, $15, $80, $28, $19, $80, $2C, $15, $80, $2E, $15, $80, $2A, $19
	.byte $80, $28, $19, $80, $2C, $15, $80, $2A, $19, $80, $2C, $15, $80, $28, $1B, $80, $2C, $1A, $83, $80
	.byte $2E, $1A, $01, $80, $32, $19, $01, $80, $2C, $1A, $03, $80, $28, $19, $03, $80, $2C, $1A, $03

; Bank 0
ft_s0p1c5:
	.byte $80, $36, $FA, $1E, $0B, $25, $0B, $1E, $07, $1D, $0B, $25, $0B, $1D, $07

; Bank 0
ft_s0p2c2:
	.byte $ED, $34, $17, $36, $03, $34, $03, $33, $1F

; Bank 0
ft_s0p2c3:
	.byte $82, $03, $80, $2A, $19, $80, $2C, $15, $80, $28, $19, $80, $2C, $15, $80, $2E, $15, $80, $2A, $19
	.byte $80, $28, $19, $80, $2C, $15, $80, $2A, $19, $80, $2C, $15, $83, $80, $34, $1B, $17

; Bank 0
ft_s0p2c5:
	.byte $80, $36, $1C, $0B, $25, $0B, $1C, $07, $1B, $0B, $23, $0B, $1B, $07

; Bank 0
ft_s0p3c0:
	.byte $E6, $3D, $03, $E4, $31, $00, $E5, $31, $02, $E4, $2A, $00, $E5, $38, $02, $E4, $31, $00, $E5, $36
	.byte $02, $E6, $31, $03, $E4, $2A, $00, $E5, $38, $02, $E4, $25, $00, $E5, $36, $02, $E4, $2A, $00, $E5
	.byte $31, $02, $E6, $3D, $03, $E4, $31, $00, $E5, $31, $02, $E4, $29, $00, $E5, $3A, $02, $E4, $31, $00
	.byte $E5, $35, $02, $E6, $31, $03, $E4, $29, $00, $E5, $3A, $02, $E4, $25, $00, $E5, $35, $02, $E4, $29
	.byte $00, $E5, $31, $02

; Bank 0
ft_s0p3c1:
	.byte $E2, $2A, $03, $E4, $2E, $00, $E3, $2A, $02, $E7, $2E, $03, $E4, $2E, $00, $E3, $2E, $02, $E2, $2C
	.byte $03, $E8, $2A, $03, $E4, $22, $00, $E3, $2A, $02, $E8, $2A, $03, $E2, $31, $03, $E4, $2E, $00, $E3
	.byte $31, $02, $E7, $2E, $03, $E9, $31, $07, $E4, $25, $00, $E3, $31, $02, $E9, $31, $03, $E4, $25, $00
	.byte $E3, $31, $02

; Bank 0
ft_s0p3c2:
	.byte $ED, $32, $0F, $36, $07, $32, $07, $36, $0D, $38, $01, $3A, $03, $36, $03, $31, $07

; Bank 0
ft_s0p3c5:
	.byte $80, $36, $1A, $0B, $23, $0B, $1A, $07, $19, $0B, $22, $0B, $19, $07

; Bank 0
ft_s0p4c0:
	.byte $E6, $3D, $03, $E4, $31, $00, $E5, $31, $02, $E4, $28, $00, $E5, $38, $02, $E4, $31, $00, $E5, $36
	.byte $02, $E6, $31, $03, $E4, $28, $00, $E5, $38, $02, $E4, $25, $00, $E5, $36, $02, $E4, $28, $00, $E5
	.byte $31, $02, $E6, $3F, $03, $E4, $2F, $00, $E5, $33, $02, $E4, $27, $00, $E5, $3B, $02, $E4, $2F, $00
	.byte $E5, $36, $02, $E6, $33, $03, $E4, $27, $00, $E5, $3B, $02, $E4, $23, $00, $E5, $36, $02, $E4, $27
	.byte $00, $E5, $33, $02

; Bank 0
ft_s0p4c1:
	.byte $E2, $33, $03, $E4, $2C, $00, $E3, $33, $02, $EA, $31, $03, $E4, $2C, $00, $E3, $31, $02, $E2, $36
	.byte $03, $E4, $25, $00, $E3, $36, $02, $EB, $31, $03, $E4, $25, $00, $E3, $31, $02, $E2, $2F, $03, $E4
	.byte $2A, $00, $E3, $2F, $02, $E4, $23, $00, $E3, $2F, $02, $E4, $2A, $00, $E3, $2F, $06, $E4, $23, $00
	.byte $E3, $2F, $02, $EC, $2F, $03, $E4, $23, $00, $E3, $2F, $02

; Bank 0
ft_s0p4c2:
	.byte $ED, $30, $0B, $33, $03, $36, $0F, $31, $17, $2F, $07

; Bank 0
ft_s0p4c5:
	.byte $80, $36, $18, $0B, $20, $0B, $2C, $07, $25, $0B, $20, $0B, $19, $07

; Bank 0
ft_s0p5c0:
	.byte $E6, $3E, $03, $E4, $2F, $00, $E5, $32, $02, $E4, $2A, $00, $E5, $3B, $02, $E4, $2F, $00, $E5, $36
	.byte $02, $E6, $32, $03, $E4, $2A, $00, $E5, $3B, $02, $E4, $26, $00, $E5, $36, $02, $E4, $2A, $00, $E5
	.byte $32, $02, $E6, $3D, $03, $E4, $2E, $00, $E5, $31, $02, $E4, $2A, $00, $E5, $3A, $02, $E4, $2E, $00
	.byte $E5, $36, $02, $E6, $31, $03, $E4, $2A, $00, $E5, $3A, $02, $E4, $25, $00, $E5, $36, $02, $E4, $2A
	.byte $00, $E5, $31, $02

; Bank 0
ft_s0p5c1:
	.byte $E2, $31, $03, $E4, $2A, $00, $E3, $31, $02, $EE, $2F, $03, $E4, $2A, $00, $E3, $2F, $02, $E2, $32
	.byte $03, $E4, $26, $00, $E3, $32, $02, $EF, $2F, $03, $E4, $26, $00, $E3, $2F, $02, $E2, $2E, $03, $E4
	.byte $2A, $00, $E3, $2E, $02, $E4, $25, $00, $E3, $2E, $02, $E4, $2A, $00, $E3, $2E, $06, $E4, $25, $00
	.byte $E3, $2E, $02, $80, $20, $2E, $03, $E4, $25, $00, $E3, $2E, $02

; Bank 0
ft_s0p5c2:
	.byte $ED, $2E, $3F

; Bank 0
ft_s0p5c5:
	.byte $80, $36, $FC, $12, $07, $FB, $00, $0B, $FA, $00, $03, $F9, $00, $03, $F8, $00, $01, $F7, $00, $00
	.byte $7E, $20

; Bank 0
ft_s0p6c0:
	.byte $E6, $3F, $03, $E4, $2C, $00, $E5, $33, $02, $E4, $2A, $00, $E5, $38, $02, $E4, $2C, $00, $E5, $36
	.byte $02, $E6, $33, $03, $E4, $2A, $00, $E5, $38, $02, $E4, $27, $00, $E5, $36, $02, $E4, $2A, $00, $E5
	.byte $33, $02, $E6, $3D, $03, $E4, $2C, $00, $E5, $31, $02, $E4, $29, $00, $E5, $3B, $02, $E4, $2C, $00
	.byte $E5, $38, $02, $E6, $31, $03, $E4, $29, $00, $E5, $3B, $02, $E4, $25, $00, $E5, $38, $02, $E4, $29
	.byte $00, $E5, $31, $02

; Bank 0
ft_s0p6c1:
	.byte $E2, $2E, $03, $E4, $2A, $00, $E3, $2E, $02, $80, $22, $2C, $03, $E4, $2A, $00, $E3, $2C, $02, $E2
	.byte $2C, $03, $E4, $27, $00, $E3, $2C, $02, $80, $24, $2A, $03, $E4, $27, $00, $E3, $2A, $02, $E2, $2A
	.byte $03, $E4, $29, $00, $E3, $2A, $02, $E4, $25, $00, $E3, $2A, $02, $E4, $29, $00, $E3, $2A, $02, $E2
	.byte $29, $03, $E4, $25, $00, $E3, $29, $02, $E4, $23, $00, $E3, $29, $02, $E4, $25, $00, $E3, $29, $02

; Bank 0
ft_s0p6c2:
	.byte $80, $26, $2E, $07, $80, $30, $31, $07, $82, $03, $ED, $2F, $80, $26, $2E, $80, $30, $2E, $ED, $2E
	.byte $83, $80, $26, $35, $07, $80, $30, $31, $03, $ED, $35, $05, $80, $26, $35, $05, $80, $30, $35, $07

; Bank 0
ft_s0p6c5:
	.byte $80, $38, $FC, $36, $07, $3A, $07, $38, $03, $36, $07, $36, $03, $3D, $07, $3A, $03, $3D, $0B, $3D
	.byte $07

; Bank 0
ft_s0p7c0:
	.byte $E2, $91, $81, $F2, $2A, $07, $2E, $07, $2C, $03, $2A, $07, $2A, $03, $31, $07, $2E, $03, $31, $0B
	.byte $31, $07

; Bank 0
ft_s0p7c1:
	.byte $00, $01, $82, $01, $E1, $31, $E4, $2E, $E1, $3D, $E4, $25, $E1, $3D, $E4, $2E, $83, $E1, $38, $03
	.byte $82, $01, $36, $E4, $25, $E1, $36, $E4, $22, $E1, $38, $E4, $25, $83, $E1, $36, $05, $82, $01, $E4
	.byte $2E, $E1, $3D, $E4, $25, $E1, $3D, $E4, $2E, $83, $E1, $3A, $03, $82, $01, $35, $E4, $25, $E1, $31
	.byte $E4, $22, $E1, $3A, $E4, $25, $83, $E1, $35, $01

; Bank 0
ft_s0p7c2:
	.byte $80, $26, $34, $07, $80, $30, $34, $0B, $80, $26, $34, $03, $80, $30, $36, $03, $ED, $34, $03, $80
	.byte $26, $33, $07, $80, $30, $33, $09, $80, $26, $33, $05, $80, $30, $33, $07

; Bank 0
ft_s0p7c5:
	.byte $82, $07, $80, $38, $3F, $3D, $42, $3D, $83, $3B, $17, $3B, $07

; Bank 0
ft_s0p8c0:
	.byte $E0, $92, $FF, $3D, $03, $82, $01, $31, $E1, $3D, $E0, $38, $E1, $31, $E0, $36, $E1, $38, $E0, $31
	.byte $E1, $36, $E0, $38, $E1, $31, $E0, $36, $E1, $38, $E0, $31, $83, $E1, $36, $00, $86, $01, $00, $20

; Bank 0
ft_s0p8c1:
	.byte $00, $03, $82, $01, $E4, $2C, $E1, $3D, $E4, $25, $E1, $3D, $E4, $2C, $83, $E1, $38, $03, $82, $01
	.byte $36, $E4, $25, $E1, $31, $E4, $20, $E1, $38, $E4, $25, $83, $E1, $36, $05, $82, $01, $E4, $2A, $E1
	.byte $3F, $E4, $23, $E1, $33, $E4, $2A, $83, $E1, $3B, $03, $82, $01, $36, $E4, $23, $E1, $33, $E4, $1E
	.byte $E1, $3B, $E4, $23, $83, $E1, $36, $01

; Bank 0
ft_s0p8c2:
	.byte $80, $26, $32, $07, $80, $30, $32, $07, $ED, $36, $03, $80, $26, $36, $03, $80, $30, $32, $07, $80
	.byte $26, $36, $07, $80, $30, $36, $05, $ED, $38, $01, $3A, $01, $80, $26, $3A, $01, $ED, $36, $03, $80
	.byte $30, $31, $07

; Bank 0
ft_s0p8c5:
	.byte $82, $07, $80, $38, $3D, $3B, $3E, $3B, $83, $3A, $17, $3A, $07

; Bank 0
ft_s0p9c0:
	.byte $82, $07, $E2, $F4, $33, $31, $36, $31, $83, $2F, $17, $2F, $07

; Bank 0
ft_s0p9c1:
	.byte $00, $03, $82, $01, $E4, $2A, $E1, $3E, $E4, $26, $E1, $32, $E4, $2A, $83, $E1, $3B, $03, $82, $01
	.byte $36, $E4, $26, $E1, $32, $E4, $23, $E1, $3B, $E4, $26, $83, $E1, $36, $05, $82, $01, $E4, $2A, $E1
	.byte $3D, $E4, $25, $E1, $31, $E4, $2A, $83, $E1, $3A, $03, $82, $01, $36, $E4, $25, $E1, $31, $E4, $22
	.byte $E1, $3A, $E4, $25, $83, $E1, $36, $01

; Bank 0
ft_s0p9c2:
	.byte $80, $26, $30, $07, $82, $03, $80, $30, $30, $ED, $33, $36, $80, $26, $36, $83, $80, $30, $9B, $02
	.byte $2C, $07, $80, $26, $31, $07, $80, $30, $31, $0F, $ED, $2F, $07

; Bank 0
ft_s0p9c5:
	.byte $82, $07, $80, $38, $3A, $38, $38, $36, $83, $36, $0F, $35, $0F

; Bank 0
ft_s0p10c0:
	.byte $82, $07, $E2, $31, $2F, $32, $2F, $83, $2E, $17, $2E, $07

; Bank 0
ft_s0p10c1:
	.byte $00, $03, $82, $01, $E4, $2A, $E1, $3F, $E4, $27, $E1, $33, $E4, $2A, $83, $E1, $38, $03, $82, $01
	.byte $36, $E4, $27, $E1, $33, $E4, $24, $E1, $38, $E4, $27, $83, $E1, $36, $05, $82, $01, $E4, $29, $E1
	.byte $3D, $E4, $25, $E1, $31, $E4, $29, $83, $E1, $3B, $03, $82, $01, $38, $E4, $25, $E1, $31, $E4, $23
	.byte $E1, $3B, $E4, $25, $83, $E1, $38, $01

; Bank 0
ft_s0p11c0:
	.byte $82, $07, $E2, $2E, $2C, $2C, $2A, $83, $2A, $0F, $29, $0F

; Bank 0
ft_s0p11c1:
	.byte $E2, $2A, $3F

; Bank 0
ft_s0p12c1:
	.byte $E2, $2A, $07, $2E, $07, $2C, $03, $2A, $07, $2A, $03, $31, $07, $2E, $03, $31, $0B, $31, $07

; Bank 0
ft_s0p13c1:
	.byte $82, $07, $E2, $33, $31, $36, $31, $83, $2F, $17, $2F, $07


; DPCM samples (located at DPCM segment)
