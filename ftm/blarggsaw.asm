; Dn-FamiTracker exported music data: blarggsaw.dnm
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

; Instruments
ft_inst_0:
	.byte 0
	.byte $11
	.word ft_seq_2a03_0
	.word ft_seq_2a03_4

ft_inst_1:
	.byte 9
	.byte $01
	.word ft_seq_n163_0
	.byte $10
	.byte $00
	.word ft_waves_1

; Sequences
ft_seq_2a03_0:
	.byte $10, $FF, $00, $00, $0F, $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00
ft_seq_2a03_4:
	.byte $01, $FF, $00, $00, $02
ft_seq_n163_0:
	.byte $10, $FF, $00, $00, $0F, $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00

; N163 waves
ft_waves_1:
	.byte $00, $11, $22, $33, $44, $55, $66, $77, $88, $99, $AA, $BB, $CC, $DD, $EE, $FF

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
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c5, ft_s0p0c1
; Bank 0
ft_s0p0c0:
	.byte $82, $03, $E0, $FF, $25, $27, $29, $2A, $2C, $2E, $30, $31, $83, $7F, $1F

; Bank 0
ft_s0p0c1:
	.byte $00, $3F

; Bank 0
ft_s0p0c5:
	.byte $7F, $1F, $82, $03, $E1, $25, $27, $29, $2A, $2C, $2E, $30, $83, $31, $03


; DPCM samples (located at DPCM segment)
