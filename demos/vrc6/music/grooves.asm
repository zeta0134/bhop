; Dn-FamiTracker exported music data: grooves.dnm
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
	.byte $00

; Sequences

; DPCM instrument list (pitch, sample index)
ft_sample_list:

; DPCM samples list (location, size, bank)
ft_samples:


; Groove list
ft_groove_list:
	.byte $00
; Grooves (size, terms)
	.byte $06, $06, $00, $01
	.byte $04, $04, $00, $05
	.byte $04, $02, $04, $02, $00, $09

; Song pointer list
ft_song_list:
	.word ft_song_0
	.word ft_song_1
	.word ft_song_2
	.word ft_song_3

; Song info
ft_song_0:
	.word ft_s0_frames
	.byte 1	; frame count
	.byte 16	; pattern length
	.byte 0	; speed
	.byte 150	; tempo
	.byte 1	; groove position
	.byte 0	; initial bank

ft_song_1:
	.word ft_s1_frames
	.byte 1	; frame count
	.byte 16	; pattern length
	.byte 0	; speed
	.byte 150	; tempo
	.byte 5	; groove position
	.byte 0	; initial bank

ft_song_2:
	.word ft_s2_frames
	.byte 1	; frame count
	.byte 16	; pattern length
	.byte 0	; speed
	.byte 150	; tempo
	.byte 9	; groove position
	.byte 0	; initial bank

ft_song_3:
	.word ft_s3_frames
	.byte 1	; frame count
	.byte 64	; pattern length
	.byte 0	; speed
	.byte 150	; tempo
	.byte 1	; groove position
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
	.byte $82, $00, $E0, $25, $27, $25, $27, $83, $7F, $0B

; Bank 0
ft_s0p0c1:
	.byte $00, $0F

; Bank 0
ft_s1_frames:
	.word ft_s1f0
ft_s1f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1
; Bank 0
ft_s2_frames:
	.word ft_s2f0
ft_s2f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1
; Bank 0
ft_s3_frames:
	.word ft_s3f0
ft_s3f0:
	.word ft_s3p0c0, ft_s3p0c1, ft_s3p0c1, ft_s3p0c1, ft_s3p0c4
; Bank 0
ft_s3p0c0:
	.byte $82, $00, $E0, $25, $27, $25, $27, $83, $7F, $0B, $82, $00, $25, $27, $25, $27, $83, $7F, $0B, $82
	.byte $00, $25, $27, $25, $27, $83, $7F, $1B

; Bank 0
ft_s3p0c1:
	.byte $00, $3F

; Bank 0
ft_s3p0c4:
	.byte $A0, $01, $00, $0F, $A0, $05, $00, $0F, $A0, $09, $00, $1F


; DPCM samples (located at DPCM segment)
