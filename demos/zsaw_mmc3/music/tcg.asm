; Dn-FamiTracker exported music data: tcg_zsaw.dnm
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

; Instruments
ft_inst_0:
	.byte 0
	.byte $11
	.word ft_seq_2a03_0
	.word ft_seq_2a03_4

ft_inst_1:
	.byte 9
	.byte $11
	.word ft_seq_n163_0
	.word ft_seq_n163_4
	.byte $10
	.byte $00
	.word ft_waves_1

ft_inst_2:
	.byte 0
	.byte $11
	.word ft_seq_2a03_5
	.word ft_seq_2a03_9

ft_inst_3:
	.byte 0
	.byte $11
	.word ft_seq_2a03_10
	.word ft_seq_2a03_9

ft_inst_4:
	.byte 0
	.byte $03
	.word ft_seq_2a03_15
	.word ft_seq_2a03_1

ft_inst_5:
	.byte 0
	.byte $13
	.word ft_seq_2a03_20
	.word ft_seq_2a03_6
	.word ft_seq_2a03_14

ft_inst_6:
	.byte 0
	.byte $13
	.word ft_seq_2a03_25
	.word ft_seq_2a03_11
	.word ft_seq_2a03_19

ft_inst_7:
	.byte 0
	.byte $13
	.word ft_seq_2a03_30
	.word ft_seq_2a03_16
	.word ft_seq_2a03_24

ft_inst_8:
	.byte 0
	.byte $07
	.word ft_seq_2a03_35
	.word ft_seq_2a03_21
	.word ft_seq_2a03_2

ft_inst_9:
	.byte 0
	.byte $03
	.word ft_seq_2a03_35
	.word ft_seq_2a03_26

; Sequences
ft_seq_2a03_0:
	.byte $05, $FF, $00, $00, $09, $0C, $0D, $08, $01
ft_seq_2a03_1:
	.byte $0C, $FF, $00, $01, $0C, $09, $0A, $0A, $0A, $0B, $0B, $0B, $0C, $0C, $0D, $0D
ft_seq_2a03_2:
	.byte $10, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $FF, $FF, $FF, $FF, $01, $01
ft_seq_2a03_4:
	.byte $02, $FF, $00, $00, $02, $01
ft_seq_2a03_5:
	.byte $05, $FF, $00, $00, $0F, $0E, $0D, $02, $01
ft_seq_2a03_6:
	.byte $04, $03, $00, $01, $0B, $0C, $0D, $0E
ft_seq_2a03_9:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_10:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_11:
	.byte $05, $03, $00, $01, $0B, $0C, $0D, $0C, $0B
ft_seq_2a03_14:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_15:
	.byte $02, $FF, $00, $00, $0D, $00
ft_seq_2a03_16:
	.byte $03, $02, $00, $01, $05, $07, $0C
ft_seq_2a03_19:
	.byte $01, $FF, $00, $00, $00
ft_seq_2a03_20:
	.byte $0A, $FF, $00, $00, $0D, $0A, $07, $00, $00, $00, $00, $00, $00, $00
ft_seq_2a03_21:
	.byte $02, $FF, $00, $01, $26, $23
ft_seq_2a03_24:
	.byte $03, $FF, $00, $00, $01, $01, $00
ft_seq_2a03_25:
	.byte $0E, $FF, $00, $00, $0D, $0B, $0A, $0A, $09, $08, $08, $07, $07, $07, $07, $06, $04, $02
ft_seq_2a03_26:
	.byte $02, $FF, $00, $01, $31, $2C
ft_seq_2a03_30:
	.byte $0E, $FF, $00, $00, $0D, $0C, $0C, $0A, $09, $08, $07, $04, $03, $02, $01, $01, $01, $00
ft_seq_2a03_35:
	.byte $03, $FF, $00, $00, $0F, $0F, $00
ft_seq_n163_0:
	.byte $01, $FF, $00, $00, $0F
ft_seq_n163_4:
	.byte $01, $FF, $00, $00, $02

; N163 waves
ft_waves_1:
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $10, $32, $54, $76, $98, $BA, $DC, $FE
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $10, $32, $54, $76, $98, $BA, $DC, $FE
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $EF, $CD, $AB, $89, $67, $45, $23, $01

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
	.byte 8	; frame count
	.byte 64	; pattern length
	.byte 3	; speed
	.byte 130	; tempo
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
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c1, ft_s0p0c4
ft_s0f1:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c1, ft_s0p0c4
ft_s0f2:
	.word ft_s0p0c0, ft_s0p1c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c1, ft_s0p0c4
ft_s0f3:
	.word ft_s0p0c0, ft_s0p3c1, ft_s0p1c2, ft_s0p1c3, ft_s0p1c5, ft_s0p0c4
ft_s0f4:
	.word ft_s0p0c0, ft_s0p2c1, ft_s0p0c2, ft_s0p0c3, ft_s0p2c5, ft_s0p1c4
ft_s0f5:
	.word ft_s0p0c0, ft_s0p2c1, ft_s0p0c2, ft_s0p0c3, ft_s0p2c5, ft_s0p1c4
ft_s0f6:
	.word ft_s0p0c0, ft_s0p2c1, ft_s0p0c2, ft_s0p0c3, ft_s0p2c5, ft_s0p1c4
ft_s0f7:
	.word ft_s0p0c0, ft_s0p2c1, ft_s0p1c2, ft_s0p1c3, ft_s0p2c5, ft_s0p1c4
; Bank 0
ft_s0p0c0:
	.byte $82, $00, $E0, $FA, $44, $F7, $3A, $FA, $43, $F7, $44, $FA, $3F, $F7, $43, $FA, $3C, $F7, $3F, $FA
	.byte $44, $F7, $3C, $FA, $43, $F7, $44, $FA, $3F, $F7, $43, $FA, $3C, $F7, $3F, $FA, $44, $F7, $3C, $FA
	.byte $43, $F7, $44, $FA, $3F, $F7, $43, $FA, $3C, $F7, $3F, $FA, $44, $F7, $3C, $FA, $43, $F7, $44, $FA
	.byte $3F, $F7, $43, $FA, $3C, $F7, $3F, $FA, $44, $F7, $3C, $FA, $41, $F7, $44, $FA, $3D, $F7, $41, $FA
	.byte $3A, $F7, $3D, $FA, $44, $F7, $3A, $FA, $41, $F7, $44, $FA, $3D, $F7, $41, $FA, $3A, $F7, $3D, $FA
	.byte $44, $F7, $3A, $FA, $41, $F7, $44, $FA, $3D, $F7, $41, $FA, $3A, $F7, $3D, $FA, $44, $F7, $3A, $FA
	.byte $41, $F7, $44, $FA, $3D, $F7, $41, $FA, $3A, $83, $F7, $3D, $00

; Bank 0
ft_s0p0c1:
	.byte $7F, $3F

; Bank 0
ft_s0p0c2:
	.byte $E8, $31, $07, $E9, $31, $05, $31, $01, $E8, $31, $07, $E9, $31, $05, $31, $01, $E8, $31, $07, $E9
	.byte $31, $05, $31, $01, $E8, $31, $07, $E9, $31, $05, $31, $01

; Bank 0
ft_s0p0c3:
	.byte $E4, $FB, $1D, $01, $E5, $1D, $01, $E6, $1D, $03, $82, $01, $E7, $1D, $E5, $1D, $1D, $E7, $1D, $E4
	.byte $1D, $E5, $1D, $83, $E6, $1D, $03, $82, $01, $E7, $1D, $E5, $1D, $1D, $E7, $1D, $E4, $1D, $E5, $1D
	.byte $83, $E6, $1D, $03, $82, $01, $E7, $1D, $E5, $1D, $1D, $E7, $1D, $E4, $1D, $E5, $1D, $83, $E6, $1D
	.byte $03, $82, $01, $E7, $1D, $E5, $1D, $1D, $83, $E7, $1D, $01

; Bank 0
ft_s0p0c4:
	.byte $96, $00, $00, $3F

; Bank 0
ft_s0p1c1:
	.byte $82, $00, $E2, $FB, $49, $F5, $41, $FB, $48, $F5, $49, $FB, $44, $F5, $48, $FB, $3F, $F5, $44, $FB
	.byte $49, $F5, $3F, $FB, $48, $F5, $49, $FB, $44, $F5, $48, $FB, $3F, $F5, $44, $FB, $49, $F5, $3F, $FB
	.byte $48, $F5, $49, $FB, $44, $F5, $48, $FB, $3F, $F5, $44, $FB, $49, $F5, $3F, $FB, $48, $F5, $49, $FB
	.byte $44, $F5, $48, $FB, $3F, $F5, $44, $FB, $49, $F5, $3F, $FB, $48, $F5, $49, $FB, $44, $F5, $48, $FB
	.byte $41, $F5, $44, $FB, $49, $F5, $41, $FB, $48, $F5, $49, $FB, $44, $F5, $48, $FB, $41, $F5, $44, $FB
	.byte $49, $F5, $41, $FB, $48, $F5, $49, $FB, $44, $F5, $48, $FB, $41, $F5, $44, $FB, $49, $F5, $41, $FB
	.byte $48, $F5, $49, $FB, $44, $F5, $48, $FB, $41, $83, $F5, $44, $00

; Bank 0
ft_s0p1c2:
	.byte $E8, $31, $07, $E9, $31, $05, $31, $01, $E8, $31, $07, $E9, $31, $05, $31, $01, $E8, $31, $07, $E9
	.byte $31, $05, $82, $01, $31, $31, $31, $31, $31, $31, $31, $31, $83, $31, $01

; Bank 0
ft_s0p1c3:
	.byte $E4, $1D, $01, $E5, $1D, $01, $E6, $1D, $03, $82, $01, $E7, $1D, $E5, $1D, $1D, $E7, $1D, $E4, $1D
	.byte $E5, $1D, $83, $E6, $1D, $03, $82, $01, $E7, $1D, $E5, $1D, $1D, $E7, $1D, $E4, $1D, $E5, $1D, $83
	.byte $E6, $1D, $03, $E7, $1D, $01, $E5, $1D, $01, $1D, $01, $E7, $1D, $00, $1D, $00, $82, $01, $1D, $1D
	.byte $1D, $1D, $1D, $1D, $1D, $83, $1D, $01

; Bank 0
ft_s0p1c4:
	.byte $00, $3F

; Bank 0
ft_s0p1c5:
	.byte $00, $37, $82, $00, $E1, $FC, $3C, $FC, $38, $FD, $37, $FD, $33, $FE, $30, $FE, $2C, $FF, $2B, $83
	.byte $FF, $27, $00

; Bank 0
ft_s0p2c1:
	.byte $82, $00, $E2, $FC, $49, $F6, $44, $FC, $27, $F6, $3F, $FC, $44, $F6, $49, $FC, $3F, $F6, $48, $FC
	.byte $2B, $F6, $44, $FC, $48, $F6, $3F, $FC, $44, $F6, $49, $FC, $37, $F6, $48, $FC, $49, $F6, $44, $FC
	.byte $27, $F6, $3F, $FC, $44, $F6, $49, $FC, $3F, $F6, $48, $FC, $2B, $F6, $44, $FC, $48, $F6, $3F, $FC
	.byte $44, $F6, $49, $FC, $3F, $F6, $48, $FC, $49, $F6, $44, $FC, $29, $F6, $41, $FC, $44, $F6, $49, $FC
	.byte $41, $F6, $48, $FC, $2C, $F6, $44, $FC, $48, $F6, $41, $FC, $44, $F6, $49, $FC, $38, $F6, $48, $FC
	.byte $49, $F6, $44, $FC, $29, $F6, $41, $FC, $44, $F6, $49, $FC, $41, $F6, $48, $FC, $2C, $F6, $44, $FC
	.byte $48, $F6, $41, $FC, $44, $F6, $49, $FC, $41, $83, $F6, $48, $00

; Bank 0
ft_s0p2c5:
	.byte $E1, $20, $01, $82, $00, $30, $7F, $20, $7F, $20, $7F, $33, $7F, $83, $27, $01, $82, $00, $2C, $7F
	.byte $3C, $7F, $83, $20, $01, $82, $00, $30, $7F, $20, $7F, $20, $7F, $33, $7F, $82, $01, $25, $26, $27
	.byte $1B, $82, $00, $31, $7F, $1B, $7F, $1B, $7F, $35, $7F, $83, $22, $01, $82, $00, $27, $7F, $3D, $7F
	.byte $83, $1B, $01, $82, $00, $31, $7F, $1B, $7F, $1B, $7F, $35, $7F, $83, $19, $01, $1B, $01, $27, $00
	.byte $7F, $00

; Bank 0
ft_s0p3c1:
	.byte $82, $00, $E2, $FB, $49, $F5, $41, $FB, $48, $F5, $49, $FB, $44, $F5, $48, $FB, $3F, $F5, $44, $FB
	.byte $49, $F5, $3F, $FB, $48, $F5, $49, $FB, $44, $F5, $48, $FB, $3F, $F5, $44, $FB, $49, $F5, $3F, $FB
	.byte $48, $F5, $49, $FB, $44, $F5, $48, $FB, $3F, $F5, $44, $FB, $49, $F5, $3F, $FB, $48, $F5, $49, $FB
	.byte $44, $F5, $48, $FB, $3F, $F5, $44, $FB, $49, $F5, $3F, $FB, $48, $F5, $49, $FB, $44, $F5, $48, $FB
	.byte $41, $F5, $44, $FB, $49, $F5, $41, $FB, $48, $F5, $49, $FB, $44, $F5, $48, $FB, $41, $F5, $44, $E3
	.byte $FF, $48, $FF, $44, $FF, $43, $FF, $3F, $FF, $3C, $FF, $38, $FF, $37, $FF, $33, $E2, $FB, $49, $F5
	.byte $41, $FB, $48, $F5, $49, $FB, $44, $F5, $48, $FB, $41, $83, $F5, $44, $00


; DPCM samples (located at DPCM segment)
