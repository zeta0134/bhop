; Dn-FamiTracker exported music data: all_instrument_types.0cc
;

; Module header
	.word ft_song_list
	.word ft_instrument_list
	.word ft_sample_list
	.word ft_samples
	.word ft_groove_list
	.byte 0 ; flags
	.word ft_wave_table
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

; Instruments
ft_inst_0:
	.byte 0
	.byte $00

ft_inst_1:
	.byte 4
	.byte $00

ft_inst_2:
	.byte 6
	.byte $70

ft_inst_3:
	.byte 7
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.word $0000
	.byte $00

ft_inst_4:
	.byte 0
	.byte $00

ft_inst_5:
	.byte 9
	.byte $00
	.byte $08
	.byte $00
	.word ft_waves_5

ft_inst_6:
	.byte 10
	.byte $00

; Sequences

; FDS waves
ft_wave_table:
	.byte $00, $01, $02, $03, $04, $05, $06, $10, $13, $15, $17, $17, $31, $31, $30, $17, $17, $17, $16, $16, $16, $15, $15, $15, $24, $23, $23, $23, $23, $23, $22, $22, $22, $22, $22, $0C, $0C, $24, $24, $25, $25, $25, $25, $25, $25, $26, $27, $27, $27, $16, $17, $09, $09, $0A, $22, $0C, $23, $23, $23, $3B, $3C, $3D, $3E, $3F

; N163 waves
ft_waves_5:
	.byte $00, $A9, $9A, $00, $FF, $FF, $56, $FF

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
	.byte 1	; frame count
	.byte 64	; pattern length
	.byte 6	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte 0	; initial bank


;
; Pattern and frame data for all songs below
;

; Bank 0
ft_s0_frames:
	.word ft_s0f0
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c8, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c7, ft_s0p0c10, ft_s0p0c11, ft_s0p0c18, ft_s0p0c1, ft_s0p0c1, ft_s0p0c12, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1
; Bank 0
ft_s0p0c0:
	.byte $E0, $25, $3F

; Bank 0
ft_s0p0c1:
	.byte $00, $3F

; Bank 0
ft_s0p0c7:
	.byte $00, $03, $E1, $29, $3B

; Bank 0
ft_s0p0c8:
	.byte $00, $07, $E4, $2C, $37

; Bank 0
ft_s0p0c10:
	.byte $00, $0B, $E5, $2F, $33

; Bank 0
ft_s0p0c11:
	.byte $00, $0F, $E3, $4B, $2F

; Bank 0
ft_s0p0c12:
	.byte $00, $13, $E2, $FA, $42, $2B

; Bank 0
ft_s0p0c18:
	.byte $00, $17, $E6, $45, $27


; DPCM samples (located at DPCM segment)
