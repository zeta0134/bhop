; Dn-FamiTracker exported music data: Untitled
;

; Module header
	.word ft_song_list
	.word btm_instrument_list
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

; Song pointer list
ft_song_list:
	.word ft_song_0

; Song info
ft_song_0:
	;.word ft_s0_frames
	.word btm_song0_frames
	.byte 11	; frame count
	.byte 64	; pattern length
	.byte 3	; speed
	.byte 120	; tempo
	.byte 0	; groove position
	.byte 0	; initial bank


;
; Pattern and frame data for all songs below
;

unspecified_empty_pattern:
	.byte $00, $3F

; CHEATY CHEATER
.include "test.txt"

; DPCM samples (located at DPCM segment)
