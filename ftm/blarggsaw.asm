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
	.word 1 ; N163 channels

; Instrument pointer list
ft_instrument_list:
	.word ft_inst_0

; Instruments
ft_inst_0:
	.byte 9
	.byte $11
	.word ft_seq_n163_5
	.word ft_seq_n163_9
	.byte $10
	.byte $00
	.word ft_waves_0

; Sequences
ft_seq_n163_5:
	.byte $18, $FF, $0E, $00, $0F, $0F, $0F, $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $03
	.byte $03, $02, $02, $02, $01, $01, $01, $00
ft_seq_n163_9:
	.byte $01, $FF, $00, $00, $04

; N163 waves
ft_waves_0:
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $10, $32, $54, $76, $98, $BA, $DC, $FE
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $10, $32, $54, $76, $98, $BA, $DC, $FE
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $EF, $CD, $AB, $89, $67, $45, $23, $01
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $EF, $CD, $AB, $89, $67, $45, $23, $01
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $EF, $CD, $AB, $89, $67, $45, $23, $01
	.byte $10, $32, $54, $76, $98, $BA, $DC, $FE, $EF, $CD, $AB, $89, $67, $45, $23, $01

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
	.byte 112	; pattern length
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
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c5, ft_s0p0c0
ft_s0f1:
	.word ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p0c0, ft_s0p1c5, ft_s0p0c0
; Bank 0
ft_s0p0c0:
	.byte $00, $6F

; Bank 0
ft_s0p0c5:
	.byte $E0, $01, $03, $82, $01, $03, $05, $06, $08, $0A, $0C, $83, $0D, $03, $82, $01, $0F, $11, $12, $14
	.byte $16, $18, $83, $19, $03, $82, $01, $1B, $1D, $1E, $20, $22, $24, $83, $25, $03, $82, $01, $27, $29
	.byte $2A, $2C, $2E, $30, $83, $31, $03, $82, $01, $33, $35, $36, $38, $3A, $3C, $83, $3D, $03, $82, $01
	.byte $3F, $41, $42, $44, $46, $48, $83, $49, $03, $7E, $03, $7F, $07

; Bank 0
ft_s0p1c5:
	.byte $82, $01, $E0, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41
	.byte $42, $43, $44, $45, $46, $47, $48, $83, $49, $03, $7E, $03, $7F, $37


; DPCM samples (located at DPCM segment)
