; Dn-FamiTracker exported music data: pitch_slide_test.0cc
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
	.byte $08, $FF, $00, $00, $0B, $08, $08, $08, $08, $08, $08, $08
ft_seq_2a03_4:
	.byte $01, $FF, $00, $00, $02

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
	.byte $82, $07, $E0, $8B, $04, $25, $7F, $8C, $04, $25, $7F, $82, $03, $8D, $1F, $25, $19, $25, $31, $25
	.byte $83, $7F, $0B

; Bank 0
ft_s0p0c1:
	.byte $00, $3F

; Bank 0
ft_s0p1c0:
	.byte $82, $07, $E0, $98, $4C, $25, $7F, $99, $4C, $25, $7F, $83, $25, $03, $98, $4C, $00, $07, $19, $03
	.byte $25, $03, $99, $4C, $00, $07, $31, $03


; DPCM samples (located at DPCM segment)
