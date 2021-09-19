; Dn-FamiTracker exported music data: qxy_arp_interactions.0cc
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

; Instruments
ft_inst_0:
	.byte 0
	.byte $02
	.word ft_seq_2a03_1

ft_inst_1:
	.byte 0
	.byte $00

ft_inst_2:
	.byte 0
	.byte $03
	.word ft_seq_2a03_0
	.word ft_seq_2a03_6

ft_inst_3:
	.byte 0
	.byte $00

; Sequences
ft_seq_2a03_0:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_1:
	.byte $0D, $FF, $00, $02, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
ft_seq_2a03_6:
	.byte $02, $FF, $00, $01, $26, $23

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
	.byte 12	; speed
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
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c1, ft_s0p0c1
; Bank 0
ft_s0p0c0:
	.byte $82, $07, $E0, $19, $7F, $E1, $98, $4C, $19, $7F, $E0, $98, $4C, $19, $83, $7F, $17

; Bank 0
ft_s0p0c1:
	.byte $00, $3F

; Bank 0
ft_s0p0c2:
	.byte $00, $2F, $82, $03, $E3, $98, $4C, $25, $7F, $E2, $98, $4C, $25, $83, $7F, $03


; DPCM samples (located at DPCM segment)
