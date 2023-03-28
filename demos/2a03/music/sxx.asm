; Dn-FamiTracker exported music data: extended_sxx.dnm
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
	.byte 0
	.byte $01
	.word ft_seq_2a03_0

; Sequences
ft_seq_2a03_0:
	.byte $0F, $FF, $00, $00, $0F, $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01

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
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1
; Bank 0
ft_s0p0c0:
	.byte $82, $00, $E0, $25, $27, $29, $2A, $82, $01, $2C, $2C, $2C, $2C, $83, $7F, $03, $82, $00, $9B, $02
	.byte $25, $9B, $02, $27, $9B, $02, $29, $9B, $02, $2A, $82, $01, $9B, $02, $2C, $9B, $02, $2C, $9B, $02
	.byte $2C, $9B, $02, $2C, $83, $7F, $03, $82, $00, $9B, $08, $25, $27, $9B, $08, $29, $2A, $82, $01, $9B
	.byte $08, $2C, $9B, $08, $2C, $9B, $08, $2C, $9B, $08, $2C, $83, $7F, $03, $82, $00, $9B, $7F, $25, $27
	.byte $9B, $7F, $29, $2A, $82, $01, $9B, $7F, $2C, $9B, $7F, $2C, $9B, $7F, $2C, $9B, $7F, $2C, $83, $7F
	.byte $03

; Bank 0
ft_s0p0c1:
	.byte $00, $3F


; DPCM samples (located at DPCM segment)
