; Dn-FamiTracker exported music data: tcg_s5b.0cc
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

; Instruments
ft_inst_0:
	.byte 10
	.byte $11
	.word ft_seq_s5b_0
	.word ft_seq_s5b_4

ft_inst_1:
	.byte 10
	.byte $11
	.word ft_seq_s5b_5
	.word ft_seq_s5b_4

ft_inst_2:
	.byte 10
	.byte $13
	.word ft_seq_s5b_10
	.word ft_seq_s5b_1
	.word ft_seq_s5b_9

ft_inst_3:
	.byte 10
	.byte $13
	.word ft_seq_s5b_15
	.word ft_seq_s5b_6
	.word ft_seq_s5b_14

ft_inst_4:
	.byte 10
	.byte $11
	.word ft_seq_s5b_20
	.word ft_seq_s5b_19

ft_inst_5:
	.byte 10
	.byte $11
	.word ft_seq_s5b_25
	.word ft_seq_s5b_24

ft_inst_6:
	.byte 10
	.byte $11
	.word ft_seq_s5b_30
	.word ft_seq_s5b_4

; Sequences
ft_seq_s5b_0:
	.byte $08, $FF, $00, $00, $0D, $0E, $0E, $0D, $0B, $06, $04, $01
ft_seq_s5b_1:
	.byte $05, $FF, $00, $01, $24, $1B, $12, $0D, $0A
ft_seq_s5b_4:
	.byte $01, $FF, $00, $00, $40
ft_seq_s5b_5:
	.byte $07, $FF, $00, $00, $0F, $0E, $0D, $0B, $06, $04, $01
ft_seq_s5b_6:
	.byte $03, $FF, $00, $01, $30, $2C, $28
ft_seq_s5b_9:
	.byte $03, $FF, $00, $00, $DE, $DF, $DF
ft_seq_s5b_10:
	.byte $06, $FF, $00, $00, $0F, $0F, $0E, $0D, $0A, $00
ft_seq_s5b_14:
	.byte $05, $04, $00, $00, $DC, $9D, $DE, $9E, $9F
ft_seq_s5b_15:
	.byte $09, $FF, $00, $00, $0F, $0F, $0F, $0E, $0D, $0B, $01, $01, $00
ft_seq_s5b_19:
	.byte $03, $FF, $00, $00, $9E, $9F, $9F
ft_seq_s5b_20:
	.byte $05, $FF, $00, $00, $0F, $0F, $0E, $0C, $00
ft_seq_s5b_24:
	.byte $03, $FF, $00, $00, $9E, $9F, $9F
ft_seq_s5b_25:
	.byte $05, $03, $00, $00, $0F, $0F, $0E, $0D, $0E
ft_seq_s5b_30:
	.byte $03, $FF, $00, $00, $0F, $0F, $0E

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
	.byte 6	; speed
	.byte 255	; tempo
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
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c5, ft_s0p0c0, ft_s0p0c7, ft_s0p0c0
ft_s0f1:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c5, ft_s0p0c0, ft_s0p0c7, ft_s0p0c0
ft_s0f2:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c5, ft_s0p1c6, ft_s0p0c7, ft_s0p0c0
ft_s0f3:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p1c5, ft_s0p1c6, ft_s0p1c7, ft_s0p0c0
ft_s0f4:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p2c5, ft_s0p2c6, ft_s0p2c7, ft_s0p0c0
ft_s0f5:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p2c5, ft_s0p2c6, ft_s0p2c7, ft_s0p0c0
ft_s0f6:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p2c5, ft_s0p2c6, ft_s0p2c7, ft_s0p0c0
ft_s0f7:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p3c5, ft_s0p2c6, ft_s0p2c7, ft_s0p0c0
; Bank 0
ft_s0p0c0:
	.byte $00, $3F

; Bank 0
ft_s0p0c5:
	.byte $82, $00, $E0, $FD, $50, $FA, $48, $FD, $4F, $FA, $50, $FD, $4B, $FA, $4F, $FD, $48, $FA, $4B, $FD
	.byte $50, $FA, $48, $FD, $4F, $FA, $50, $FD, $4B, $FA, $4F, $FD, $48, $FA, $4B, $FD, $50, $FA, $48, $FD
	.byte $4F, $FA, $50, $FD, $4B, $FA, $4F, $FD, $48, $FA, $4B, $FD, $50, $FA, $48, $FD, $4F, $FA, $50, $FD
	.byte $4B, $FA, $4F, $FD, $48, $FA, $4B, $FD, $50, $FA, $48, $FD, $4D, $FA, $50, $FD, $49, $FA, $4D, $FD
	.byte $46, $FA, $49, $FD, $50, $FA, $46, $FD, $4D, $FA, $50, $FD, $49, $FA, $4D, $FD, $46, $FA, $49, $FD
	.byte $50, $FA, $48, $FD, $4D, $FA, $50, $FD, $49, $FA, $4D, $FD, $46, $FA, $49, $FD, $50, $FA, $46, $FD
	.byte $4D, $FA, $50, $FD, $49, $FA, $4D, $FD, $46, $83, $FA, $49, $00

; Bank 0
ft_s0p0c7:
	.byte $E2, $FE, $3D, $01, $E4, $FD, $3D, $01, $E5, $FD, $3D, $03, $82, $01, $E3, $FE, $3D, $E4, $FD, $3D
	.byte $FC, $3D, $E3, $FE, $3D, $E2, $FE, $3D, $E4, $FD, $3D, $83, $E5, $FD, $3D, $03, $82, $01, $E3, $FE
	.byte $3D, $E4, $FD, $3D, $FC, $3D, $E3, $FE, $3D, $E2, $FE, $3D, $E4, $FD, $3D, $83, $E5, $FD, $3D, $03
	.byte $82, $01, $E3, $FE, $3D, $E4, $FD, $3D, $FC, $3D, $E3, $FE, $3D, $E2, $FE, $3D, $E4, $FD, $3D, $83
	.byte $E5, $FD, $3D, $03, $82, $01, $E3, $FE, $3D, $E4, $FD, $3D, $FC, $3D, $83, $E3, $FE, $3D, $01

; Bank 0
ft_s0p1c5:
	.byte $82, $00, $E0, $FD, $50, $FA, $48, $FD, $4F, $FA, $50, $FD, $4B, $FA, $4F, $FD, $48, $FA, $4B, $FD
	.byte $50, $FA, $48, $FD, $4F, $FA, $50, $FD, $4B, $FA, $4F, $FD, $48, $FA, $4B, $FD, $50, $FA, $48, $FD
	.byte $4F, $FA, $50, $FD, $4B, $FA, $4F, $FD, $48, $FA, $4B, $FD, $50, $FA, $48, $FD, $4F, $FA, $50, $FD
	.byte $4B, $FA, $4F, $FD, $48, $FA, $4B, $FD, $50, $FA, $48, $FD, $4D, $FA, $50, $FD, $49, $FA, $4D, $FD
	.byte $46, $FA, $49, $FD, $50, $FA, $46, $FD, $4D, $FA, $50, $FD, $49, $FA, $4D, $FD, $46, $FA, $49, $E6
	.byte $FE, $54, $50, $4F, $4B, $48, $44, $43, $3F, $3C, $38, $37, $33, $30, $2C, $2B, $83, $27, $00

; Bank 0
ft_s0p1c6:
	.byte $82, $00, $E1, $FD, $55, $FA, $4B, $FD, $54, $FA, $55, $FD, $50, $FA, $54, $FD, $4B, $FA, $50, $FD
	.byte $55, $FA, $4B, $FD, $54, $FA, $55, $FD, $50, $FA, $54, $FD, $4B, $FA, $50, $FD, $55, $FA, $4B, $FD
	.byte $54, $FA, $55, $FD, $50, $FA, $54, $FD, $4B, $FA, $50, $FD, $55, $FA, $4B, $FD, $54, $FA, $55, $FD
	.byte $50, $FA, $54, $FD, $4B, $FA, $50, $FD, $55, $FA, $4B, $FD, $54, $FA, $55, $FD, $50, $FA, $54, $FD
	.byte $4D, $FA, $50, $FD, $55, $FA, $4D, $FD, $54, $FA, $55, $FD, $50, $FA, $54, $FD, $4D, $FA, $50, $FD
	.byte $55, $FA, $4D, $FD, $54, $FA, $55, $FD, $50, $FA, $54, $FD, $4D, $FA, $50, $FD, $55, $FA, $4D, $FD
	.byte $54, $FA, $55, $FD, $50, $FA, $54, $FD, $4D, $83, $FA, $50, $00

; Bank 0
ft_s0p1c7:
	.byte $E2, $FE, $3D, $01, $E4, $FD, $3D, $01, $E5, $FD, $3D, $03, $82, $01, $E3, $FE, $3D, $E4, $FD, $3D
	.byte $FC, $3D, $E3, $FE, $3D, $E2, $FE, $3D, $E4, $FD, $3D, $83, $E5, $FD, $3D, $03, $82, $01, $E3, $FE
	.byte $3D, $E4, $FD, $3D, $FC, $3D, $E3, $FE, $3D, $E2, $FE, $3D, $E4, $FD, $3D, $83, $E5, $FD, $3D, $03
	.byte $E3, $FE, $3D, $01, $E4, $FD, $3D, $01, $FC, $3D, $01, $E3, $FE, $3D, $00, $FE, $3D, $00, $82, $01
	.byte $FE, $3D, $FE, $3D, $FE, $3D, $FE, $3D, $FE, $3D, $FE, $3D, $FE, $3D, $83, $FE, $3D, $01

; Bank 0
ft_s0p2c5:
	.byte $E2, $FE, $3D, $00, $E0, $FA, $48, $00, $E4, $FD, $3D, $01, $E5, $FD, $3D, $03, $E3, $FE, $3D, $01
	.byte $E4, $FD, $3D, $00, $E0, $FA, $50, $00, $E4, $FC, $3D, $01, $E3, $FE, $3D, $01, $E2, $FE, $3D, $00
	.byte $E0, $FA, $48, $00, $E4, $FD, $3D, $01, $E5, $FD, $3D, $03, $E3, $FE, $3D, $01, $82, $00, $E4, $FD
	.byte $3D, $E0, $FA, $50, $E4, $FC, $3D, $E0, $FA, $4F, $E3, $FE, $3D, $E0, $FA, $4B, $E2, $FE, $3D, $E0
	.byte $FA, $48, $83, $E4, $FD, $3D, $01, $E5, $FD, $3D, $03, $E3, $FE, $3D, $01, $E4, $FD, $3D, $00, $E0
	.byte $FA, $50, $00, $E4, $FC, $3D, $01, $E3, $FE, $3D, $01, $E2, $FE, $3D, $00, $E0, $FA, $48, $00, $E4
	.byte $FD, $3D, $01, $E5, $FD, $3D, $03, $E3, $FE, $3D, $01, $82, $00, $E4, $FD, $3D, $E0, $FA, $50, $E4
	.byte $FC, $3D, $E0, $FA, $4D, $E3, $FE, $3D, $83, $E0, $FA, $49, $00

; Bank 0
ft_s0p2c6:
	.byte $82, $00, $E1, $FD, $55, $F8, $4B, $E6, $FE, $33, $E1, $F8, $55, $FD, $50, $F8, $54, $FD, $4B, $F8
	.byte $50, $E6, $FE, $37, $E1, $F8, $4B, $FD, $54, $F8, $55, $FD, $50, $F8, $54, $E6, $FE, $3C, $E1, $F8
	.byte $50, $FD, $55, $F8, $4B, $E6, $FE, $33, $E1, $F8, $55, $FD, $50, $F8, $54, $FD, $4B, $F8, $50, $E6
	.byte $FE, $37, $E1, $F8, $4B, $FD, $54, $F8, $55, $FD, $50, $F8, $54, $FD, $4B, $F8, $50, $FD, $55, $F8
	.byte $4B, $E6, $FE, $35, $E1, $F8, $55, $FD, $50, $F8, $54, $FD, $4D, $F8, $50, $E6, $FE, $38, $E1, $F8
	.byte $4D, $FD, $54, $F8, $55, $FD, $50, $F8, $54, $E6, $FE, $3D, $E1, $F8, $50, $FD, $55, $F8, $4D, $E6
	.byte $FE, $35, $E1, $F8, $55, $FD, $50, $F8, $54, $FD, $4D, $F8, $50, $E6, $FE, $38, $E1, $F8, $4D, $FD
	.byte $54, $F8, $55, $FD, $50, $F8, $54, $FD, $4D, $83, $F8, $50, $00

; Bank 0
ft_s0p2c7:
	.byte $E6, $FF, $20, $01, $82, $00, $FE, $30, $E0, $FA, $50, $E6, $FF, $20, $E0, $FA, $4F, $E6, $FF, $20
	.byte $E0, $FA, $4B, $E6, $FE, $33, $E0, $FA, $48, $83, $E6, $FF, $27, $01, $82, $00, $FF, $2C, $E0, $FA
	.byte $4F, $E6, $FE, $43, $E0, $FA, $4B, $83, $E6, $FF, $20, $01, $82, $00, $FE, $30, $E0, $FA, $50, $E6
	.byte $FF, $20, $E0, $FA, $4F, $E6, $FF, $20, $E0, $FA, $4B, $E6, $FE, $33, $E0, $FA, $48, $82, $01, $E6
	.byte $FF, $25, $FF, $26, $FF, $27, $FF, $1B, $82, $00, $FE, $31, $E0, $FA, $50, $E6, $FF, $1B, $E0, $FA
	.byte $4D, $E6, $FF, $1B, $E0, $FA, $49, $E6, $FE, $35, $E0, $FA, $46, $83, $E6, $FF, $22, $01, $82, $00
	.byte $FF, $27, $E0, $FA, $4D, $E6, $FE, $44, $E0, $FA, $49, $83, $E6, $FF, $1B, $01, $82, $00, $FE, $31
	.byte $E0, $FA, $50, $E6, $FF, $1B, $E0, $FA, $4D, $E6, $FF, $1B, $E0, $FA, $49, $E6, $FE, $35, $E0, $FA
	.byte $46, $83, $E6, $FF, $19, $01, $FF, $1B, $01, $FF, $27, $01

; Bank 0
ft_s0p3c5:
	.byte $E2, $FE, $3D, $00, $E0, $FA, $48, $00, $E4, $FD, $3D, $01, $E5, $FD, $3D, $03, $E3, $FE, $3D, $01
	.byte $E4, $FD, $3D, $00, $E0, $FA, $50, $00, $E4, $FC, $3D, $01, $E3, $FE, $3D, $01, $E2, $FE, $3D, $00
	.byte $E0, $FA, $48, $00, $E4, $FD, $3D, $01, $E5, $FD, $3D, $03, $E3, $FE, $3D, $01, $82, $00, $E4, $FD
	.byte $3D, $E0, $FA, $50, $E4, $FC, $3D, $E0, $FA, $4F, $E3, $FE, $3D, $E0, $FA, $4B, $E2, $FE, $3D, $E0
	.byte $FA, $48, $83, $E4, $FD, $3D, $01, $E5, $FD, $3D, $03, $E3, $FE, $3D, $01, $E4, $FD, $3D, $00, $E0
	.byte $FA, $50, $00, $E4, $FC, $3D, $01, $82, $00, $E3, $FE, $3D, $FE, $3D, $FE, $3D, $E0, $FA, $48, $82
	.byte $01, $E3, $FE, $3D, $FE, $3D, $FE, $3D, $FE, $3D, $82, $00, $FE, $3D, $E0, $FA, $50, $E3, $FE, $3D
	.byte $E0, $FA, $4D, $E3, $FE, $3D, $83, $E0, $FA, $49, $00


; DPCM samples (located at DPCM segment)
