; Dn-FamiTracker exported music data: blarggsong.dnm
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

; Instruments
ft_inst_0:
	.byte 9
	.byte $01
	.word ft_seq_n163_0
	.byte $08
	.byte $00
	.word ft_waves_1

ft_inst_1:
	.byte 0
	.byte $11
	.word ft_seq_2a03_5
	.word ft_seq_2a03_9

ft_inst_2:
	.byte 0
	.byte $03
	.word ft_seq_2a03_10
	.word ft_seq_2a03_1

ft_inst_3:
	.byte 0
	.byte $03
	.word ft_seq_2a03_15
	.word ft_seq_2a03_6

ft_inst_4:
	.byte 0
	.byte $03
	.word ft_seq_2a03_30
	.word ft_seq_2a03_21

ft_inst_5:
	.byte 0
	.byte $13
	.word ft_seq_2a03_35
	.word ft_seq_2a03_26
	.word ft_seq_2a03_19

ft_inst_6:
	.byte 0
	.byte $03
	.word ft_seq_2a03_40
	.word ft_seq_2a03_31

ft_inst_7:
	.byte 0
	.byte $03
	.word ft_seq_2a03_45
	.word ft_seq_2a03_36

; Sequences
ft_seq_2a03_1:
	.byte $03, $FF, $00, $01, $28, $22, $1C
ft_seq_2a03_5:
	.byte $0A, $FF, $01, $00, $0F, $04, $04, $03, $03, $02, $02, $01, $01, $00
ft_seq_2a03_6:
	.byte $02, $FF, $00, $01, $35, $31
ft_seq_2a03_9:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_10:
	.byte $05, $FF, $00, $00, $0F, $0F, $0F, $00, $00
ft_seq_2a03_15:
	.byte $03, $FF, $00, $00, $0F, $0F, $00
ft_seq_2a03_19:
	.byte $03, $FF, $00, $00, $01, $01, $00
ft_seq_2a03_21:
	.byte $0C, $FF, $00, $01, $07, $04, $0A, $0A, $0A, $0B, $0B, $0B, $0C, $0C, $0D, $0D
ft_seq_2a03_26:
	.byte $03, $02, $00, $01, $05, $07, $0C
ft_seq_2a03_30:
	.byte $03, $FF, $00, $00, $09, $04, $00
ft_seq_2a03_31:
	.byte $04, $FF, $00, $01, $0C, $0B, $0B, $0C
ft_seq_2a03_35:
	.byte $0E, $FF, $00, $00, $0F, $0F, $0F, $0E, $0C, $09, $07, $04, $03, $02, $01, $01, $01, $00
ft_seq_2a03_36:
	.byte $05, $03, $00, $01, $0C, $09, $0A, $0B, $0C
ft_seq_2a03_40:
	.byte $06, $FF, $00, $00, $0F, $06, $04, $02, $01, $00
ft_seq_2a03_45:
	.byte $05, $03, $00, $00, $0F, $09, $06, $06, $04
ft_seq_n163_0:
	.byte $10, $FF, $06, $00, $0F, $0F, $0F, $0E, $0D, $0C, $03, $03, $03, $02, $02, $02, $01, $01, $01, $00

; N163 waves
ft_waves_1:
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE

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
	.byte 4	; frame count
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
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c5, ft_s0p0c4
ft_s0f1:
	.word ft_s0p1c0, ft_s0p1c1, ft_s0p0c2, ft_s0p0c3, ft_s0p1c5, ft_s0p0c4
ft_s0f2:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c5, ft_s0p0c4
ft_s0f3:
	.word ft_s0p1c0, ft_s0p1c1, ft_s0p2c2, ft_s0p2c3, ft_s0p1c5, ft_s0p0c4
; Bank 0
ft_s0p0c0:
	.byte $00, $0F, $E1, $FD, $30, $03, $33, $01, $7E, $05, $31, $01, $7E, $0D, $2E, $01, $7E, $05, $31, $01
	.byte $7E, $05, $30, $01, $7E, $01

; Bank 0
ft_s0p0c1:
	.byte $00, $0F, $E1, $FB, $2C, $03, $30, $01, $7E, $05, $2E, $01, $7E, $0D, $2A, $01, $7E, $05, $2E, $01
	.byte $7E, $05, $2C, $01, $7E, $01

; Bank 0
ft_s0p0c2:
	.byte $E2, $25, $07, $E3, $25, $07, $E2, $25, $05, $25, $01, $E3, $25, $07, $E2, $25, $07, $E3, $25, $07
	.byte $E2, $25, $05, $25, $01, $E3, $25, $07

; Bank 0
ft_s0p0c3:
	.byte $E4, $FF, $11, $03, $E6, $FC, $11, $01, $FA, $11, $01, $E5, $FF, $11, $03, $82, $01, $E6, $FC, $11
	.byte $E7, $FC, $11, $E4, $FF, $11, $E6, $FC, $11, $FA, $11, $E4, $FF, $11, $83, $E5, $FF, $11, $03, $E6
	.byte $FC, $11, $01, $E7, $FA, $11, $01, $E4, $FF, $11, $03, $E6, $FC, $11, $01, $FA, $11, $01, $E5, $FF
	.byte $11, $03, $82, $01, $E6, $FC, $11, $E7, $FC, $11, $E4, $FF, $11, $E6, $FC, $11, $FA, $11, $E4, $FF
	.byte $11, $83, $E5, $FF, $11, $03, $E6, $FC, $11, $01, $E7, $FA, $11, $01

; Bank 0
ft_s0p0c4:
	.byte $00, $3F

; Bank 0
ft_s0p0c5:
	.byte $E0, $FF, $14, $01, $7E, $01, $14, $01, $7E, $00, $F8, $17, $00, $FF, $18, $03, $7E, $01, $19, $01
	.byte $7E, $01, $19, $00, $7E, $00, $1A, $00, $7E, $02, $1B, $03, $14, $01, $13, $00, $7E, $00, $82, $01
	.byte $12, $7E, $12, $7E, $83, $16, $03, $7E, $01, $17, $01, $7E, $01, $17, $00, $7E, $00, $18, $00, $7E
	.byte $02, $19, $03, $12, $01, $13, $01

; Bank 0
ft_s0p1c0:
	.byte $00, $0F, $E1, $FD, $30, $03, $33, $01, $7E, $05, $31, $01, $7E, $0D, $35, $01, $7E, $05, $31, $01
	.byte $7E, $05, $33, $01, $7E, $01

; Bank 0
ft_s0p1c1:
	.byte $00, $0F, $E1, $FB, $2C, $03, $30, $01, $7E, $05, $2E, $01, $7E, $0D, $31, $01, $7E, $05, $2E, $01
	.byte $7E, $05, $30, $01, $7E, $01

; Bank 0
ft_s0p1c5:
	.byte $E0, $FF, $14, $01, $7E, $01, $14, $01, $7E, $00, $F8, $17, $00, $FF, $18, $03, $7E, $01, $19, $01
	.byte $7E, $01, $19, $00, $7E, $00, $1A, $00, $7E, $02, $1B, $03, $14, $01, $13, $00, $7E, $00, $82, $01
	.byte $12, $7E, $12, $7E, $83, $19, $03, $7E, $00, $F8, $1F, $00, $FF, $20, $03, $1E, $00, $7E, $00, $19
	.byte $00, $7E, $02, $1E, $03, $FF, $19, $01, $F8, $17, $00, $F6, $15, $00

; Bank 0
ft_s0p2c2:
	.byte $E2, $25, $07, $E3, $25, $07, $E2, $25, $05, $25, $01, $E3, $25, $07, $E2, $25, $07, $E3, $25, $07
	.byte $E2, $25, $05, $25, $01, $E3, $25, $03, $25, $01, $25, $01

; Bank 0
ft_s0p2c3:
	.byte $E4, $FF, $11, $03, $E6, $FC, $11, $01, $FA, $11, $01, $E5, $FF, $11, $03, $82, $01, $E6, $FC, $11
	.byte $E7, $FC, $11, $E4, $FF, $11, $E6, $FC, $11, $FA, $11, $E4, $FF, $11, $83, $E5, $FF, $11, $03, $E6
	.byte $FC, $11, $01, $E7, $FA, $11, $01, $E4, $FF, $11, $03, $E6, $FC, $11, $01, $FA, $11, $01, $E5, $FF
	.byte $11, $03, $82, $01, $E6, $FC, $11, $E7, $FC, $11, $E4, $FF, $11, $E6, $FC, $11, $E7, $FA, $11, $83
	.byte $E6, $FC, $11, $00, $FA, $11, $00, $E5, $FF, $11, $03, $FF, $11, $01, $FC, $11, $01


; DPCM samples (located at DPCM segment)
