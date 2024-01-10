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
	.word ft_inst_1
	.word ft_inst_2

; Instruments
ft_inst_0:
	.byte 0
	.byte $11
	.word ft_seq_2a03_0
	.word ft_seq_2a03_4

ft_inst_1:
	.byte 4
	.byte $11
	.word ft_seq_vrc6_0
	.word ft_seq_vrc6_4

ft_inst_2:
	.byte 4
	.byte $01
	.word ft_seq_vrc6_5

; Sequences
ft_seq_2a03_0:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_4:
	.byte $01, $FF, $00, $00, $02
ft_seq_vrc6_0:
	.byte $01, $FF, $00, $00, $0F
ft_seq_vrc6_4:
	.byte $01, $FF, $00, $00, $07
ft_seq_vrc6_5:
	.byte $01, $FF, $00, $00, $0F

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
	.byte 6	; frame count
	.byte 64	; pattern length
	.byte 6	; speed
	.byte 120	; tempo
	.byte 0	; groove position
	.byte 0	; initial bank


;
; Pattern and frame data for all songs below
;

; Bank 0
ft_s0_frames:
	.word ft_s0f0
	.word ft_s0f1
	.word ft_s0f2
	.word ft_s0f3
	.word ft_s0f4
	.word ft_s0f5
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1
ft_s0f1:
	.word ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p1c5, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1
ft_s0f2:
	.word ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p1c7, ft_s0p0c1
ft_s0f3:
	.word ft_s0p2c0, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1
ft_s0f4:
	.word ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p2c5, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1
ft_s0f5:
	.word ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p0c1, ft_s0p2c7, ft_s0p0c1
; Bank 0
ft_s0p0c0:
	.byte $E0, $FF, $31, $02, $7F, $00, $FE, $31, $02, $7F, $00, $FD, $31, $02, $7F, $00, $FC, $31, $02, $7F
	.byte $00, $FB, $31, $02, $7F, $00, $FA, $31, $02, $7F, $00, $F9, $31, $02, $7F, $00, $F8, $31, $02, $7F
	.byte $00, $F7, $31, $02, $7F, $00, $F6, $31, $02, $7F, $00, $F5, $31, $02, $7F, $00, $F4, $31, $02, $7F
	.byte $00, $F3, $31, $02, $7F, $00, $F2, $31, $02, $7F, $00, $F1, $31, $02, $7F, $00, $F0, $31, $02, $7F
	.byte $00

; Bank 0
ft_s0p0c1:
	.byte $00, $3F

; Bank 0
ft_s0p1c5:
	.byte $E1, $FF, $31, $02, $7F, $00, $FE, $31, $02, $7F, $00, $FD, $31, $02, $7F, $00, $FC, $31, $02, $7F
	.byte $00, $FB, $31, $02, $7F, $00, $FA, $31, $02, $7F, $00, $F9, $31, $02, $7F, $00, $F8, $31, $02, $7F
	.byte $00, $F7, $31, $02, $7F, $00, $F6, $31, $02, $7F, $00, $F5, $31, $02, $7F, $00, $F4, $31, $02, $7F
	.byte $00, $F3, $31, $02, $7F, $00, $F2, $31, $02, $7F, $00, $F1, $31, $02, $7F, $00, $F0, $31, $02, $7F
	.byte $00

; Bank 0
ft_s0p1c7:
	.byte $E2, $FF, $31, $02, $7F, $00, $FE, $31, $02, $7F, $00, $FD, $31, $02, $7F, $00, $FC, $31, $02, $7F
	.byte $00, $FB, $31, $02, $7F, $00, $FA, $31, $02, $7F, $00, $F9, $31, $02, $7F, $00, $F8, $31, $02, $7F
	.byte $00, $F7, $31, $02, $7F, $00, $F6, $31, $02, $7F, $00, $F5, $31, $02, $7F, $00, $F4, $31, $02, $7F
	.byte $00, $F3, $31, $02, $7F, $00, $F2, $31, $02, $7F, $00, $F1, $31, $02, $7F, $00, $F0, $31, $02, $7F
	.byte $00

; Bank 0
ft_s0p2c0:
	.byte $E0, $FF, $19, $02, $7F, $00, $FE, $19, $02, $7F, $00, $FD, $19, $02, $7F, $00, $FC, $19, $02, $7F
	.byte $00, $FB, $19, $02, $7F, $00, $FA, $19, $02, $7F, $00, $F9, $19, $02, $7F, $00, $F8, $19, $02, $7F
	.byte $00, $F7, $19, $02, $7F, $00, $F6, $19, $02, $7F, $00, $F5, $19, $02, $7F, $00, $F4, $19, $02, $7F
	.byte $00, $F3, $19, $02, $7F, $00, $F2, $19, $02, $7F, $00, $F1, $19, $02, $7F, $00, $F0, $19, $02, $7F
	.byte $00

; Bank 0
ft_s0p2c5:
	.byte $E1, $FF, $19, $02, $7F, $00, $FE, $19, $02, $7F, $00, $FD, $19, $02, $7F, $00, $FC, $19, $02, $7F
	.byte $00, $FB, $19, $02, $7F, $00, $FA, $19, $02, $7F, $00, $F9, $19, $02, $7F, $00, $F8, $19, $02, $7F
	.byte $00, $F7, $19, $02, $7F, $00, $F6, $19, $02, $7F, $00, $F5, $19, $02, $7F, $00, $F4, $19, $02, $7F
	.byte $00, $F3, $19, $02, $7F, $00, $F2, $19, $02, $7F, $00, $F1, $19, $02, $7F, $00, $F0, $19, $02, $7F
	.byte $00

; Bank 0
ft_s0p2c7:
	.byte $E2, $FF, $19, $02, $7F, $00, $FE, $19, $02, $7F, $00, $FD, $19, $02, $7F, $00, $FC, $19, $02, $7F
	.byte $00, $FB, $19, $02, $7F, $00, $FA, $19, $02, $7F, $00, $F9, $19, $02, $7F, $00, $F8, $19, $02, $7F
	.byte $00, $F7, $19, $02, $7F, $00, $F6, $19, $02, $7F, $00, $F5, $19, $02, $7F, $00, $F4, $19, $02, $7F
	.byte $00, $F3, $19, $02, $7F, $00, $F2, $19, $02, $7F, $00, $F1, $19, $02, $7F, $00, $F0, $19, $02, $7F
	.byte $00


; DPCM samples (located at DPCM segment)
