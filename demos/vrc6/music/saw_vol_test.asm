; Dn-FamiTracker exported music data: Untitled
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

; Instruments
ft_inst_0:
	.byte 4
	.byte $01
	.word ft_seq_vrc6_0

; Sequences
ft_seq_vrc6_0:
	.byte $40, $FF, $00, $01, $3F, $3E, $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $33, $32, $31, $30
	.byte $2F, $2E, $2D, $2C, $2B, $2A, $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C
	.byte $1B, $1A, $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A, $09, $08
	.byte $07, $06, $05, $04, $03, $02, $01, $00

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
	.byte 24	; speed
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
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c7, ft_s0p0c0
; Bank 0
ft_s0p0c0:
	.byte $00, $3F

; Bank 0
ft_s0p0c7:
	.byte $82, $03, $E0, $FF, $25, $FE, $25, $FD, $25, $FC, $25, $FB, $25, $FA, $25, $F9, $25, $F8, $25, $F7
	.byte $25, $F6, $25, $F5, $25, $F4, $25, $F3, $25, $F2, $25, $F1, $25, $83, $7F, $03


; DPCM samples (located at DPCM segment)
