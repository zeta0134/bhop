; Dn-FamiTracker exported music data: fixed_arp_test.0cc
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

; Instruments
ft_inst_0:
	.byte 0
	.byte $00

ft_inst_1:
	.byte 0
	.byte $03
	.word ft_seq_2a03_0
	.word ft_seq_2a03_1

ft_inst_2:
	.byte 0
	.byte $03
	.word ft_seq_2a03_0
	.word ft_seq_2a03_6

; Sequences
ft_seq_2a03_0:
	.byte $08, $00, $00, $00, $0F, $0F, $0F, $0F, $00, $00, $00, $00
ft_seq_2a03_1:
	.byte $10, $FF, $00, $01, $24, $24, $24, $24, $24, $24, $24, $24, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2B
ft_seq_2a03_6:
	.byte $10, $FF, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $07, $07, $07, $07, $07, $07, $07, $07

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
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c1, ft_s0p0c3, ft_s0p0c1
; Bank 0
ft_s0p0c0:
	.byte $82, $00, $E0, $25, $7F, $2C, $7F, $25, $83, $7F, $02, $E1, $29, $07, $7F, $2F

; Bank 0
ft_s0p0c1:
	.byte $00, $3F

; Bank 0
ft_s0p0c3:
	.byte $00, $1F, $82, $00, $E0, $11, $7F, $18, $7F, $11, $83, $7F, $02, $E2, $15, $07, $7F, $0F


; DPCM samples (located at DPCM segment)
