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
	.byte 0
	.byte $11
	.word ft_seq_2a03_0
	.word ft_seq_2a03_4

; Sequences
ft_seq_2a03_0:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_4:
	.byte $01, $FF, $00, $00, $01

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
	.byte 2	; frame count
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
	.word ft_s0f1
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1
ft_s0f1:
	.word ft_s0p1c0, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1
; Bank 0
ft_s0p0c0:
	.byte $E0, $90, $44, $19, $0B, $7F, $03, $90, $84, $1B, $0B, $7F, $03, $90, $C4, $1D, $0B, $7F, $03, $90
	.byte $F4, $1E, $0B, $90, $00, $7F, $03

; Bank 0
ft_s0p0c1:
	.byte $00, $3F

; Bank 0
ft_s0p1c0:
	.byte $E0, $9A, $10, $F0, $25, $0B, $7F, $03, $9A, $20, $F0, $27, $0B, $7F, $03, $9A, $01, $FF, $29, $0B
	.byte $7F, $03, $9A, $12, $FF, $2A, $0B, $7F, $03


; DPCM samples (located at DPCM segment)
