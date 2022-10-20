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

; Instruments
ft_inst_0:
	.byte 9
	.byte $01
	.word ft_seq_n163_0
	.byte $08
	.byte $00
	.word ft_waves_1

; Sequences
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
	.byte 2	; frame count
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
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c5, ft_s0p0c0
ft_s0f1:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p1c5, ft_s0p0c0
; Bank 0
ft_s0p0c0:
	.byte $00, $3F

; Bank 0
ft_s0p0c5:
	.byte $E0, $FF, $14, $01, $7E, $01, $14, $01, $7E, $00, $F8, $17, $00, $FF, $18, $03, $7E, $01, $19, $01
	.byte $7E, $01, $19, $00, $7E, $00, $1A, $00, $7E, $02, $1B, $03, $14, $01, $13, $00, $7E, $00, $82, $01
	.byte $12, $7E, $12, $7E, $83, $16, $03, $7E, $01, $17, $01, $7E, $01, $17, $00, $7E, $00, $18, $00, $7E
	.byte $02, $19, $03, $12, $01, $13, $01

; Bank 0
ft_s0p1c5:
	.byte $E0, $FF, $14, $01, $7E, $01, $14, $01, $7E, $00, $F8, $17, $00, $FF, $18, $03, $7E, $01, $19, $01
	.byte $7E, $01, $19, $00, $7E, $00, $1A, $00, $7E, $02, $1B, $03, $14, $01, $13, $00, $7E, $00, $82, $01
	.byte $12, $7E, $12, $7E, $83, $19, $03, $7E, $00, $F8, $1F, $00, $FF, $20, $03, $1E, $00, $7E, $00, $19
	.byte $00, $7E, $02, $1E, $03, $FF, $19, $01, $F8, $17, $00, $F6, $15, $00


; DPCM samples (located at DPCM segment)
