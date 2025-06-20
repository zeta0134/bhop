.include "bhop/config.inc"
.if ::BHOP_ZSAW_ENABLED
.include "bhop/zsaw.asm"
.endif

BHOP_VER_MAJ = $00
BHOP_VER_MIN = $00

.scope BHOP
.include "bhop/bhop_internal.inc"
.include "bhop/longbranch.inc"

.include "bhop/commands.asm"
.include "bhop/effects.asm"

        .segment BHOP_ZP_SEGMENT
; scratch ptr, used for all sorts of indirect reads
bhop_ptr: .word $0000
; pattern pointers, read repeatedly when updating
; rows in a loop, we'll want access to these to be quick
pattern_ptr: .word $0000
channel_index: .byte $00
scratch_byte: .byte $00

        .segment BHOP_RAM_SEGMENT
music_header_ptr: .word $0000
tempo_counter: .word $0000
tempo_cmp: .word $0000
tempo: .byte $00
row_counter: .byte $00
row_cmp: .byte $00
frame_counter: .byte $00
frame_cmp: .byte $00

module_flags: .byte $00

.if ::BHOP_MULTICHIP
expansion_flags: .byte $00
.endif

.if ::BHOP_ZSAW_ENABLED
zsaw_relative_note: .byte $00
.endif

.if ::BHOP_PATTERN_BANKING
module_bank: .byte $00
current_music_bank: .byte $00
.endif
song_ptr: .word $0000
frame_ptr: .word $0000

shadow_pulse1_freq_hi: .byte $00
shadow_pulse2_freq_hi: .byte $00
.if ::BHOP_MMC5_ENABLED
shadow_mmc5_pulse1_freq_hi: .byte $00
shadow_mmc5_pulse2_freq_hi: .byte $00
.endif

; channel state tables
channel_pattern_ptr_low: .res BHOP::NUM_CHANNELS
channel_pattern_ptr_high: .res BHOP::NUM_CHANNELS
.if ::BHOP_PATTERN_BANKING
channel_pattern_bank: .res BHOP::NUM_CHANNELS
.endif
channel_status: .res BHOP::NUM_CHANNELS
channel_rstatus: .res BHOP::NUM_CHANNELS
channel_global_duration: .res BHOP::NUM_CHANNELS
channel_row_delay_counter: .res BHOP::NUM_CHANNELS
channel_base_note: .res BHOP::NUM_CHANNELS
channel_relative_note_offset:  .res BHOP::NUM_CHANNELS
channel_base_frequency_low: .res BHOP::NUM_CHANNELS
channel_base_frequency_high: .res BHOP::NUM_CHANNELS
channel_relative_frequency_low: .res BHOP::NUM_CHANNELS
channel_relative_frequency_high: .res BHOP::NUM_CHANNELS
channel_detuned_frequency_low: .res BHOP::NUM_CHANNELS
channel_detuned_frequency_high: .res BHOP::NUM_CHANNELS
channel_volume: .res BHOP::NUM_CHANNELS
channel_tremolo_volume: .res BHOP::NUM_CHANNELS
channel_duty: .res BHOP::NUM_CHANNELS
channel_instrument_volume: .res BHOP::NUM_CHANNELS
channel_instrument_duty: .res BHOP::NUM_CHANNELS
channel_selected_instrument: .res BHOP::NUM_CHANNELS
channel_pitch_effects_active: .res BHOP::NUM_CHANNELS

channel_volume_mode: .res BHOP::NUM_CHANNELS

; DPCM status
dpcm_status: .byte $00

; sequence state tables
sequences_enabled: .res BHOP::NUM_CHANNELS
sequences_active: .res BHOP::NUM_CHANNELS
volume_sequence_ptr_low: .res BHOP::NUM_CHANNELS
volume_sequence_ptr_high: .res BHOP::NUM_CHANNELS
volume_sequence_index: .res BHOP::NUM_CHANNELS
arpeggio_sequence_ptr_low: .res BHOP::NUM_CHANNELS
arpeggio_sequence_ptr_high: .res BHOP::NUM_CHANNELS
arpeggio_sequence_index: .res BHOP::NUM_CHANNELS
pitch_sequence_ptr_low: .res BHOP::NUM_CHANNELS
pitch_sequence_ptr_high: .res BHOP::NUM_CHANNELS
pitch_sequence_index: .res BHOP::NUM_CHANNELS
hipitch_sequence_ptr_low: .res BHOP::NUM_CHANNELS
hipitch_sequence_ptr_high: .res BHOP::NUM_CHANNELS
hipitch_sequence_index: .res BHOP::NUM_CHANNELS
duty_sequence_ptr_low: .res BHOP::NUM_CHANNELS
duty_sequence_ptr_high: .res BHOP::NUM_CHANNELS
duty_sequence_index: .res BHOP::NUM_CHANNELS

; memory for various effects
effect_note_delay: .res BHOP::NUM_CHANNELS
effect_cut_delay: .res BHOP::NUM_CHANNELS
.if ::BHOP_DELAYED_RELEASE_ENABLED
effect_release_delay: .res BHOP::NUM_CHANNELS
.endif
effect_skip_target: .byte $00

; Oxx
groove_index: .byte $00
groove_position: .byte $00

; Wxx
effect_dpcm_pitch: .byte $00

; Xxx
effect_retrigger_period: .byte $00
effect_retrigger_counter: .byte $00

; Yxx
effect_dpcm_offset: .byte $00

; Zxx
effect_dac_buffer: .byte $00


        .segment BHOP_PLAYER_SEGMENT
        ; global
        .export bhop_init, bhop_play, bhop_mute_channel, bhop_unmute_channel, bhop_set_module_bank, bhop_set_expansion_flags

.include "bhop/midi_lut.inc"

.macro prepare_ptr address
        lda address
        sta bhop_ptr
        lda address+1
        sta bhop_ptr+1
.endmacro

.macro prepare_ptr_with_fixed_offset address, offset
        prepare_ptr address
        ldy #offset
        lda (bhop_ptr), y
        pha
        iny
        lda (bhop_ptr), y
        sta bhop_ptr+1
        pla
        sta bhop_ptr
.endmacro

; add a signed byte, stored in value, to a 16bit word
; addressed by (bhop_ptr), y
; this is used in a few places, notably pitch bend effects
; clobbers a, flags
; does *not* clobber y
.macro sadd16_ptr_y ptr, value
.scope
        ; handle the low byte normally
        clc
        lda value
        adc (ptr), y
        sta (ptr), y
        iny
        ; sign-extend the high bit into the high byte
        lda value
        and #$80 ;extract the high bit
        beq positive
        lda #$FF ; the high bit was high, so set high byte to 0xFF, then add that plus carry
        ; note: unless a signed overflow occurred, carry will usually be *set* in this case
positive:
        ; the high bit was low; a contains #$00, so add that plus carry
        adc (ptr), y
        sta (ptr), y
        dey
.endscope
.endmacro

.proc bhop_set_module_bank
.if ::BHOP_PATTERN_BANKING
        sta module_bank
.endif
        rts
.endproc


; param:    expansion audio flags of module (a)
;           format is the same as NSF expansion audio flags    
.proc bhop_set_expansion_flags
.if ::BHOP_MULTICHIP
        sta expansion_flags
.endif
        rts
.endproc

; param: song index (a)
;        Low byte pointer to the music data (x)
;        High byte pointer to the music data (y)
.proc bhop_init
        ; preserve parameters
        pha ; song index

        ; initialize bhop_ptr with the song header
        stx music_header_ptr
        sty music_header_ptr+1

.if ::BHOP_PATTERN_BANKING
        lda module_bank
        sta current_music_bank
        jsr BHOP_PATTERN_SWITCH_ROUTINE
.endif

        ; global initialization things
        lda #00
        sta tempo_counter
        sta tempo_counter+1
        sta row_counter
        sta frame_counter
        sta groove_index

        ; switch to the requested song
        prepare_ptr_with_fixed_offset music_header_ptr, FtModuleHeader::song_list

        pla
        asl ; song list is made of words
        tay
        lda (bhop_ptr), y
        sta song_ptr
        iny
        lda (bhop_ptr), y
        sta song_ptr+1

.if ::BHOP_PATTERN_BANKING
        ; load the module flags from the header before changing the pointer
        prepare_ptr music_header_ptr
        ldy #FtModuleHeader::flags
        lda (bhop_ptr), y
        sta module_flags
.endif

        ; load speed and tempo from the requested song
        prepare_ptr song_ptr
        ldy #SongInfo::speed
        lda (bhop_ptr), y
        beq song_uses_groove
song_uses_speed:
        tax
        jsr set_speed
song_uses_groove:
        ldy #SongInfo::groove_position
        lda (bhop_ptr), y
        sta groove_index
        sta groove_position
        ldy #SongInfo::tempo
        lda (bhop_ptr), y
        sta tempo
        ldy #SongInfo::frame_count
        lda (bhop_ptr), y
        sta frame_cmp
        ldy #SongInfo::pattern_length
        lda (bhop_ptr), y
        sta row_cmp

        ; If this song has grooves enabled, then apply the first groove right away
        jsr update_groove
        ; Now, to work around an off-by-one startup condition with when advance_pattern_rows
        ; gets called for the first time, reset the groove position
        lda groove_index
        sta groove_position

        ; initialize at the first frame, and prime our pattern pointers
        ldx #0
        jsr jump_to_frame
        jsr load_frame_patterns

        ; initialize every channel's volume to 15 (some songs seem to rely on this)
        lda #$0F
        sta channel_volume + PULSE_1_INDEX
        sta channel_volume + PULSE_2_INDEX
        sta channel_volume + TRIANGLE_INDEX
        sta channel_volume + NOISE_INDEX
        .if ::BHOP_ZSAW_ENABLED
        sta channel_volume + ZSAW_INDEX
        .endif
        .if ::BHOP_MMC5_ENABLED
        lda #$0F
        sta channel_volume + MMC5_PULSE_1_INDEX
        sta channel_volume + MMC5_PULSE_2_INDEX
        .endif
        .if ::BHOP_VRC6_ENABLED
        lda #$0F
        sta channel_volume + VRC6_PULSE_1_INDEX
        sta channel_volume + VRC6_PULSE_2_INDEX
        lda #$3F
        sta channel_volume + VRC6_SAWTOOTH_INDEX
        .endif

        ; disable any active effects
        lda #0
        sta channel_pitch_effects_active + PULSE_1_INDEX
        sta channel_pitch_effects_active + PULSE_2_INDEX
        sta channel_pitch_effects_active + TRIANGLE_INDEX
        sta channel_pitch_effects_active + NOISE_INDEX
        sta channel_pitch_effects_active + DPCM_INDEX
        .if ::BHOP_ZSAW_ENABLED
        sta channel_pitch_effects_active + ZSAW_INDEX
        .endif
        .if ::BHOP_MMC5_ENABLED
        sta channel_pitch_effects_active + MMC5_PULSE_1_INDEX
        sta channel_pitch_effects_active + MMC5_PULSE_2_INDEX
        .endif
        .if ::BHOP_VRC6_ENABLED
        sta channel_pitch_effects_active + VRC6_PULSE_1_INDEX
        sta channel_pitch_effects_active + VRC6_PULSE_2_INDEX
        sta channel_pitch_effects_active + VRC6_SAWTOOTH_INDEX
        .endif

        ; reset every channel's status
        lda #(CHANNEL_MUTED)
        sta channel_status + PULSE_1_INDEX
        sta channel_status + PULSE_2_INDEX
        sta channel_status + TRIANGLE_INDEX
        sta channel_status + NOISE_INDEX
        sta channel_status + DPCM_INDEX
        .if ::BHOP_ZSAW_ENABLED
        sta channel_status + ZSAW_INDEX
        .endif
        .if ::BHOP_MMC5_ENABLED
        sta channel_status + MMC5_PULSE_1_INDEX
        sta channel_status + MMC5_PULSE_2_INDEX
        .endif
        .if ::BHOP_VRC6_ENABLED
        sta channel_status + VRC6_PULSE_1_INDEX
        sta channel_status + VRC6_PULSE_2_INDEX
        sta channel_status + VRC6_SAWTOOTH_INDEX
        .endif
        
        ; reset DPCM status
        lda #$FF
        sta effect_dac_buffer

        ; DPCM is disabled by default
        lda #0
        sta dpcm_status

        ; clear out special effects
        lda #0
        ldx #NUM_CHANNELS
effect_init_loop:
        dex
        sta effect_note_delay, x
        sta sequences_enabled, x
        sta sequences_active, x
        sta channel_tuning, x
        sta channel_vibrato_settings, x
        sta channel_vibrato_accumulator, x
        sta channel_volume_slide_settings, x
        sta channel_tremolo_settings, x
        sta channel_duty, x
        bne effect_init_loop

        sta effect_skip_target
        sta effect_dpcm_offset

        sta effect_retrigger_period
        sta effect_retrigger_counter

        ; initialize registers

        ; if using virtual Z channels, enable by default
        .if ::BHOP_ZSAW_ENABLED
        ; if Z-Saw happens to be playing, silence it
        jsr zsaw_silence
        ; Now fully re-initialize Z-Saw just in case
        jsr zsaw_init
        jsr zsaw_enable
        .endif

        .if ::BHOP_ZPCM_ENABLED
        jsr zpcm_enable
        .endif

        jsr init_2a03

.if ::BHOP_MMC5_ENABLED
        jsr init_mmc5
.endif

.if ::BHOP_VRC6_ENABLED
        jsr init_vrc6
.endif

        ; enable any expansion audio chips here, if they can be disabled
        .if ::BHOP_VRC6_ENABLED
        jsr bhop_vrc6_init
        .endif

        rts
.endproc

; speed goes in x
.proc set_speed
        st16 tempo_cmp, $0000
loop:
        clc
        add16 tempo_cmp, #150
        dex
        bne loop
        rts
.endproc

.proc update_groove
        lda groove_index
        beq done

        prepare_ptr_with_fixed_offset music_header_ptr, FtModuleHeader::groove_list

        ldy groove_position
        lda (bhop_ptr), y
        bne apply_groove
reached_end_of_groove:
        ldy groove_index
        lda (bhop_ptr), y
apply_groove:
        iny
        sty groove_position
        tax
        jsr set_speed

done:
        rts
.endproc

; frame number goes in x
.proc jump_to_frame
        ; load the frame pointer list from the song data; we're going to rewrite
        ; frame_ptr here anyway, so use it as temp storage
        prepare_ptr song_ptr
        ldy #SongInfo::frame_list_ptr
        lda (bhop_ptr), y
        sta frame_ptr
        iny
        lda (bhop_ptr), y
        sta frame_ptr+1
        ; now add our target frame number to that
        txa
        clc
        add16a frame_ptr
        ; twice
        txa
        clc
        add16a frame_ptr
        ; now use this to load the actual frame pointer from the list
        prepare_ptr frame_ptr
        ldy #0
        lda (bhop_ptr), y
        sta frame_ptr
        iny
        lda (bhop_ptr), y
        sta frame_ptr+1
        rts
.endproc

.proc load_frame_patterns
        ;initialize all the pattern rows from the current frame pointer
        prepare_ptr frame_ptr
        ldy #0

        ; Pulse 1
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+PULSE_1_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+PULSE_1_INDEX
        iny

        ; Pulse 2
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+PULSE_2_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+PULSE_2_INDEX
        iny

        ; Triangle
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+TRIANGLE_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+TRIANGLE_INDEX
        iny

        ; Noise
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+NOISE_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+NOISE_INDEX
        iny

        .if ::BHOP_ZSAW_ENABLED
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+ZSAW_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+ZSAW_INDEX
        iny
        .endif

        .if ::BHOP_MMC5_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_MMC5
            beq skip_mmc5
            .endif
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+MMC5_PULSE_1_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+MMC5_PULSE_1_INDEX
        iny

        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+MMC5_PULSE_2_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+MMC5_PULSE_2_INDEX
        iny
            .if ::BHOP_MULTICHIP
skip_mmc5:
            .endif
        .endif

        .if ::BHOP_VRC6_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_VRC6
            beq skip_vrc6
            .endif
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+VRC6_PULSE_1_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+VRC6_PULSE_1_INDEX
        iny

        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+VRC6_PULSE_2_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+VRC6_PULSE_2_INDEX
        iny

        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+VRC6_SAWTOOTH_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+VRC6_SAWTOOTH_INDEX
        iny
            .if ::BHOP_MULTICHIP
skip_vrc6:
            .endif
        .endif

        .if ::BHOP_N163_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_N163
            beq skip_n163
            .endif
        ; TODO: implement N163
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
            .if ::BHOP_MULTICHIP
skip_n163:
            .endif
        .endif

        .if ::BHOP_FDS_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_FDS
            beq skip_fds
            .endif
        ; TODO: implement FDS
        iny
        iny
            .if ::BHOP_MULTICHIP
skip_fds:
            .endif
        .endif

        .if ::BHOP_S5B_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_S5B
            beq skip_s5b
            .endif
        ; TODO: implement S5B
        iny
        iny
        iny
        iny
        iny
        iny
            .if ::BHOP_MULTICHIP
skip_s5b:
            .endif
        .endif

        .if ::BHOP_VRC7_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_VRC7
            beq skip_vrc7
            .endif
        ; TODO: implement VRC7
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
            .if ::BHOP_MULTICHIP
skip_vrc7:
            .endif
        .endif

        ; DPCM
        lda (bhop_ptr), y
        sta channel_pattern_ptr_low+DPCM_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_ptr_high+DPCM_INDEX
        iny

.if ::BHOP_PATTERN_BANKING
        lda module_flags
        and #MODULE_FLAGS_PATTERN_BANKING
        beq banking_not_enabled

        lda (bhop_ptr), y
        sta channel_pattern_bank+PULSE_1_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_bank+PULSE_2_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_bank+TRIANGLE_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_bank+NOISE_INDEX
        iny

        .if ::BHOP_ZSAW_ENABLED
        lda (bhop_ptr), y
        sta channel_pattern_bank+ZSAW_INDEX
        iny
        .endif

        .if ::BHOP_MMC5_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_MMC5
            beq skip_mmc5_bank
            .endif
        lda (bhop_ptr), y
        sta channel_pattern_bank+MMC5_PULSE_1_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_bank+MMC5_PULSE_2_INDEX
        iny
            .if ::BHOP_MULTICHIP
skip_mmc5_bank:
            .endif
        .endif

        .if ::BHOP_VRC6_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_VRC6
            beq skip_vrc6_bank
            .endif
        lda (bhop_ptr), y
        sta channel_pattern_bank+VRC6_PULSE_1_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_bank+VRC6_PULSE_2_INDEX
        iny
        lda (bhop_ptr), y
        sta channel_pattern_bank+VRC6_SAWTOOTH_INDEX
        iny
            .if ::BHOP_MULTICHIP
skip_vrc6_bank:
            .endif
        .endif

        .if ::BHOP_N163_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_N163
            beq skip_n163_bank
            .endif
        ; TODO: implement N163
        iny
        iny
        iny
        iny
        iny
        iny
        iny
        iny
            .if ::BHOP_MULTICHIP
skip_n163_bank:
            .endif
        .endif

        .if ::BHOP_FDS_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_FDS
            beq skip_fds_bank
            .endif
        ; TODO: implement FDS
        iny
            .if ::BHOP_MULTICHIP
skip_fds_bank:
            .endif
        .endif

        .if ::BHOP_S5B_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_S5B
            beq skip_s5b_bank
            .endif
        ; TODO: implement S5B
        iny
        iny
        iny
            .if ::BHOP_MULTICHIP
skip_s5b_bank:
            .endif
        .endif

        .if ::BHOP_VRC7_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_VRC7
            beq skip_vrc7_bank
            .endif
        ; TODO: implement VRC7
        iny
        iny
        iny
        iny
        iny
        iny
            .if ::BHOP_MULTICHIP
skip_vrc7_bank:
            .endif
        .endif

        lda (bhop_ptr), y
        sta channel_pattern_bank+DPCM_INDEX
        iny
        jmp done_with_banks
banking_not_enabled:
        ; this song doesn't use pattern banking, so it doesn't have valid bank
        ; data here. Default all patterns to the module bank instead.
        lda module_bank
        sta channel_pattern_bank + PULSE_1_INDEX
        sta channel_pattern_bank + PULSE_2_INDEX
        sta channel_pattern_bank + TRIANGLE_INDEX
        sta channel_pattern_bank + NOISE_INDEX

        .if ::BHOP_ZSAW_ENABLED
        sta channel_pattern_bank + ZSAW_INDEX
        .endif

        .if ::BHOP_MMC5_ENABLED
            .if ::BHOP_MULTICHIP
            pha
            lda expansion_flags
            and #EXPANSION_MMC5
            beq skip_mmc5_bank_disable
            pla
            .endif
        sta channel_pattern_bank + MMC5_PULSE_1_INDEX
        sta channel_pattern_bank + MMC5_PULSE_2_INDEX
            .if ::BHOP_MULTICHIP
            jmp done_mmc5_bank_disable
skip_mmc5_bank_disable:
            pla
done_mmc5_bank_disable:
            .endif
        .endif

        .if ::BHOP_VRC6_ENABLED
            .if ::BHOP_MULTICHIP
            pha
            lda expansion_flags
            and #EXPANSION_VRC6
            beq skip_vrc6_bank_disable
            pla
            .endif
        sta channel_pattern_bank + VRC6_PULSE_1_INDEX
        sta channel_pattern_bank + VRC6_PULSE_2_INDEX
        sta channel_pattern_bank + VRC6_SAWTOOTH_INDEX
            .if ::BHOP_MULTICHIP
            jmp done_vrc6_bank_disable
skip_vrc6_bank_disable:
            pla
done_vrc6_bank_disable:
            .endif
        .endif

        sta channel_pattern_bank + DPCM_INDEX
done_with_banks:
.endif

        ; reset all the row counters to 0
        lda #0
        sta channel_row_delay_counter + PULSE_1_INDEX
        sta channel_row_delay_counter + PULSE_2_INDEX
        sta channel_row_delay_counter + TRIANGLE_INDEX
        sta channel_row_delay_counter + NOISE_INDEX

        .if ::BHOP_ZSAW_ENABLED
        sta channel_row_delay_counter + ZSAW_INDEX
        .endif

        .if ::BHOP_MMC5_ENABLED
            .if ::BHOP_MULTICHIP
            pha
            lda expansion_flags
            and #EXPANSION_MMC5
            beq skip_mmc5_row_reset
            pla
            .endif
        sta channel_row_delay_counter + MMC5_PULSE_1_INDEX
        sta channel_row_delay_counter + MMC5_PULSE_2_INDEX
            .if ::BHOP_MULTICHIP
            jmp done_mmc5_row_reset
skip_mmc5_row_reset:
            pla
done_mmc5_row_reset:
            .endif
        .endif

        .if ::BHOP_VRC6_ENABLED
            .if ::BHOP_MULTICHIP
            pha
            lda expansion_flags
            and #EXPANSION_VRC6
            beq skip_vrc6_row_reset
            pla
            .endif
        sta channel_row_delay_counter + VRC6_PULSE_1_INDEX
        sta channel_row_delay_counter + VRC6_PULSE_2_INDEX
        sta channel_row_delay_counter + VRC6_SAWTOOTH_INDEX
            .if ::BHOP_MULTICHIP
            jmp done_vrc6_row_reset
skip_vrc6_row_reset:
            pla
done_vrc6_row_reset:
            .endif
        .endif

        sta channel_row_delay_counter + DPCM_INDEX

        rts
.endproc

.proc tick_frame_counter
        clc
        add16 tempo_counter, tempo
        ; have we exceeded the tempo_counter?
        lda tempo_counter+1
        cmp tempo_cmp+1
        bcc done_advancing_rows ; counter is lower than threshold (high byte)
        bne advance_row  ; should be impossible to take, because we only add 255 or less?
        lda tempo_counter
        cmp tempo_cmp
        bcc done_advancing_rows
        ; is either the same or higher; do the thing
advance_row:
        ; Dxx command processing: do we have a skip requested?
        lda effect_skip_target
        beq no_skip_requested
        ; we'll skip right away, so advance the frame pointer and load
        ; the next frame:
        jsr advance_frame
        lda #0
        sta row_counter
        dec effect_skip_target
        ; if the target is 00 at this point, we're done with the Dxx effect.
        ; Process the next row normally.
        beq no_frame_advance
        ; Otherwise, we now need to continually skip entire rows in a loop
dxx_loop:
        jsr skip_pattern_rows
        inc row_counter
        dec effect_skip_target
        bne dxx_loop
        ; now, finally we are done with the dxx command. Process the next
        ; row normally:
        jmp no_frame_advance

no_skip_requested:
        ; first off, have we reached the end of this pattern?
        ; if so, advance to the next frame here:
        lda row_counter
        cmp row_cmp
        bcc no_frame_advance
        jsr advance_frame
        lda #0
        sta row_counter
no_frame_advance:
        ; subtract tempo_cmp from tempo_counter
        sec
        lda tempo_counter
        sbc tempo_cmp
        sta tempo_counter
        lda tempo_counter+1
        sbc tempo_cmp+1
        sta tempo_counter+1
        ; process the bytecode for the next pattern row
        jsr advance_pattern_rows
        ; advance the row counter *after* running the bytecode
        inc row_counter
done_advancing_rows:
        rts
.endproc

; prep:
; - channel_index is set to desired channel
.proc advance_channel_row
        ; see CChannelHandler::PlayNote() in Dn-FT
        ; check first if we still have lingering delay from the previous row
        ldx channel_index
        lda effect_note_delay, x
        beq skip_handle_delay
        ; see CChannelHandler::HandleDelay() in Dn-FT
        ; if so, advance one row to sync
        lda #0
        sta effect_note_delay, x
        jsr advance_channel_row
skip_handle_delay:
        ldx channel_index ; the recursive call may have clobbered X
        lda channel_row_delay_counter, x
        cmp #0
        jne skip

.if ::BHOP_PATTERN_BANKING
        ; swap in the bank this pattern data lives in
        lda channel_pattern_bank, x
        switch_music_bank
        ; that clobbered all registers, so reload X before continuing
        ldx channel_index
.endif

        ; prep the pattern pointer for reading
        lda channel_pattern_ptr_low, x
        sta pattern_ptr
        lda channel_pattern_ptr_high, x
        sta pattern_ptr+1

        ; implementation note: x now holds channel_index, and lots of this code
        ; assumes it will not be clobbered. Take care when refactoring.

        ; continue reading bytecode, processing one command at a time,
        ; until a note is encountered. Any note command breaks out of the loop and
        ; signals the end of processing for this row.
bytecode_loop:
        fetch_pattern_byte
        cmp #0 ; needed to set negative flag based on command byte currently in a
        bpl handle_note ; if the high bit is clear, this is some kind of note
        tay ; preserve
        ; check for quick commands
        and #$F0
        cmp #$F0
        beq quick_volume_change
        cmp #$E0
        beq quick_instrument_change
process_extended_command:
        ; it's a *proper* command, restore the full command byte
        tya
        ; now use that to jump into the command procesisng table
        jsr dispatch_command

        ; did we activate a Gxx command? If we did, EXIT NOW.
        ; Do NOT pass Go, do NOT collect $200
        ldx channel_index ; un-clobber, since we don't know what dispatch_command did to x
        lda effect_note_delay, x
        beq no_note_delay
        jmp cleanup_channel_ptr
no_note_delay:
        jmp bytecode_loop

quick_volume_change:
        tya ; un-preserve
        and #$0F ; a now contains new channel volume
        sta channel_volume, x
        ; ready to process the next bytecode
        jmp bytecode_loop

quick_instrument_change:
        tya ; un-preserve
        and #$0F ; a now contains instrument index
        sta channel_selected_instrument, x

.if ::BHOP_PATTERN_BANKING
        ; Instruments live in the module bank, so we need to swap that in before processing them
        lda module_bank
        switch_music_bank
.endif
        jsr load_instrument
.if ::BHOP_PATTERN_BANKING
        ; And now we need to switch back to the pattern bank before continuing
        ldx channel_index
        lda channel_pattern_bank, x
        switch_music_bank
        ldx channel_index ; un-clobber
.endif
        ; ready to process the next bytecode
        jmp bytecode_loop

handle_note:
        cmp #$00 ; note rest
        jeq done_with_bytecode
        cmp #$7F ; note off
        bne check_release
        ; a note off immediately mutes the channel
        lda channel_status, x
        ora #CHANNEL_MUTED
        sta channel_status, x
        ; we also clear the delayed cut/release; this *is* a cut, it wins
        lda #0
        sta effect_cut_delay, x
.if ::BHOP_DELAYED_RELEASE_ENABLED
        sta effect_release_delay, x
.endif
        jmp done_with_bytecode
check_release:
        cmp #$7E
        bne note_trigger
        lda channel_status, x
        ora #CHANNEL_RELEASED
        sta channel_status, x
.if ::BHOP_PATTERN_BANKING
        ; Instruments live in the module bank, so we need to swap that in before processing them
        lda module_bank
        switch_music_bank
.endif      
        jsr apply_release
.if ::BHOP_PATTERN_BANKING
        ; And now we need to switch back to the pattern bank before continuing
        ldx channel_index
        lda channel_pattern_bank, x
        switch_music_bank
        ldx channel_index ; un-clobber
.endif
.if ::BHOP_DELAYED_RELEASE_ENABLED
        ; clear delayed release if any
        lda #0
        sta effect_release_delay, x
.endif
        jmp done_with_bytecode
note_trigger:
        ; a contains the selected note at this point
        sta channel_base_note, x
        ; use a to read the LUT and apply base_frequency
        jsr set_channel_base_frequency

        ; if portamento is active AND we are not currently muted,
        ; then skip writing the relative frequency

        lda channel_status, x
        and #CHANNEL_MUTED
        bne write_relative_frequency

        lda channel_pitch_effects_active, x
        and #PITCH_EFFECT_PORTAMENTO
        bne portamento_active

write_relative_frequency:
        lda channel_base_frequency_low, x
        sta channel_relative_frequency_low, x
        lda channel_base_frequency_high, x
        sta channel_relative_frequency_high, x

        .if ::BHOP_ZSAW_ENABLED
        ; for Z-Saw only, we initialize the relative frequency here as a note index,
        ; since it does not do pitch bends

        cpx #ZSAW_INDEX
        bne portamento_active
        lda channel_base_note, x
        sta zsaw_relative_note
        .endif

portamento_active:
        ; if we have a delayed note cut queued up, cancel it. A new note takes priority,
        ; and we don't want the unexpired cut to silence it inappropriately.
        lda channel_rstatus, x
        and #ROW_FRESH_DELAYED_CUT
        bne preserve_fresh_cut
        lda #0
        sta effect_cut_delay, x
preserve_fresh_cut:
.if ::BHOP_DELAYED_RELEASE_ENABLED
        ; ditto with delayed release
        lda channel_rstatus, x
        and #ROW_FRESH_DELAYED_RELEASE
        bne preserve_release_delay
        lda #0
        sta effect_release_delay, x
preserve_release_delay:
.endif
        ; finally, set the channel status as triggered
        ; (this will be cleared after effects are processed)
        lda channel_rstatus, x
        ora #ROW_TRIGGERED
        sta channel_rstatus, x
        ; also, un-mute  and un-release the channel
        lda channel_status, x
        and #($FF - (CHANNEL_MUTED | CHANNEL_RELEASED))
        sta channel_status, x
        cpx #DPCM_INDEX
        bne skip_sample_trigger
        ; see CDPCMChan::triggerSample() in Dn-FT
        jsr trigger_sample
        jsr queue_sample
skip_sample_trigger:
        lda channel_rstatus, x
        and #ROW_HOLD_INSTRUMENT
        beq init_instrument
        lda channel_rstatus, x
        and #($FF - ROW_TRIGGERED)
        sta channel_rstatus, x
        bne done_with_bytecode
init_instrument:
        ; reset the instrument envelopes to the beginning
        jsr reset_instrument ; clobbers a, y
        ; reset the instrument volume to 0xF (if this instrument has a volume
        ; sequence, this will be immediately overwritten with the first element)
        lda #$F
        sta channel_instrument_volume, x
        lda #0
        sta channel_volume_mode, x
        ; reset the instrument duty to the channel_duty (again, this will usually
        ; be overwritten by the instrument sequence)
        lda channel_duty, x
        sta channel_instrument_duty, x
        ; fall through to done_with_bytecode
done_with_bytecode:
        ; If we're still in global duration mode at this point,
        ; apply that to the row counter
        ldx channel_index
        lda channel_status, x
        and #CHANNEL_GLOBAL_DURATION
        beq read_duration_from_pattern

        lda channel_global_duration, x
        sta channel_row_delay_counter, x
        jmp cleanup_channel_ptr

read_duration_from_pattern:
        fetch_pattern_byte ; does not clobber x
        sta channel_row_delay_counter, x
        ; fall through to channel_cleanup_ptr
cleanup_channel_ptr:
        ; preserve pattern_ptr back to the channel status
        ldx channel_index
        lda pattern_ptr
        sta channel_pattern_ptr_low, x
        lda pattern_ptr+1
        sta channel_pattern_ptr_high, x

        ; finally done with this channel
        jmp done
skip:
        ; conveniently carry is already set
        ; a contains the counter
        sbc #1 ; decrement that counter
        sta channel_row_delay_counter, x
done:
        rts
.endproc

; if for whatever reason (usually Dxx with xx >= 0) we need to skip a channel
; row and *not* apply *any* of the bytecode, this is the way to go. Note that we
; still need to process the bytecode mostly normally, and apply duration changes
; and whatnot.
.proc skip_channel_row
        ldx channel_index
        lda channel_row_delay_counter, x
        cmp #0
        jne skip

        ; prep the pattern pointer for reading
        lda channel_pattern_ptr_low, x
        sta pattern_ptr
        lda channel_pattern_ptr_high, x
        sta pattern_ptr+1

        ; implementation note: x now holds channel_index, and lots of this code
        ; assumes it will not be clobbered. Take care when refactoring.

        ; continue reading bytecode, processing one command at a time,
        ; until a note is encountered. Any note command breaks out of the loop and
        ; signals the end of processing for this row.
bytecode_loop:
        fetch_pattern_byte
        cmp #0 ; needed to set negative flag based on command byte currently in a
        bpl handle_note ; if the high bit is clear, this is some kind of note
        tay ; preserve
        ; check for quick commands
        and #$F0
        cmp #$F0
        beq quick_volume_change
        cmp #$E0
        beq quick_instrument_change
process_extended_command:
        ; it's a *proper* command, restore the full command byte
        tya
        ; instead of applying the command, we just need to skip over it; unfortunately
        ; not all commands have a parameter byte, so we need to handle special cases. Note
        ; that the global duration affecting commands will NOT be skipped here!
        jsr skip_command
        ; note that we ignore Gxx commands, which means unlike the main loop above, we
        ; don't need to check if we enabled them here. (We didn't.)
        jmp bytecode_loop

quick_volume_change:
        ; do nothing
        jmp bytecode_loop

quick_instrument_change:
        ; also do nothing
        jmp bytecode_loop

handle_note:
        ; we don't care what kind of note this is, we're ignoring it. Proceed to be done
        ; processing bytecode for this row.
done_with_bytecode:
        ; If we're still in global duration mode at this point,
        ; apply that to the row counter
        ldx channel_index
        lda channel_status, x
        and #CHANNEL_GLOBAL_DURATION
        beq read_duration_from_pattern

        lda channel_global_duration, x
        sta channel_row_delay_counter, x
        jmp cleanup_channel_ptr

read_duration_from_pattern:
        fetch_pattern_byte ; does not clobber x
        sta channel_row_delay_counter, x
        ; fall through to channel_cleanup_ptr
cleanup_channel_ptr:
        ; preserve pattern_ptr back to the channel status
        ldx channel_index
        lda pattern_ptr
        sta channel_pattern_ptr_low, x
        lda pattern_ptr+1
        sta channel_pattern_ptr_high, x

        ; finally done with this channel
        jmp done
skip:
        ; conveniently carry is already set
        ; a contains the counter
        sbc #1 ; decrement that counter
        sta channel_row_delay_counter, x
done:
        rts
.endproc

.proc advance_pattern_rows
        ; PULSE 1
        lda #PULSE_1_INDEX
        sta channel_index
        jsr advance_channel_row

        ; PULSE 2
        lda #PULSE_2_INDEX
        sta channel_index
        jsr advance_channel_row

        ; TRIANGLE
        lda #TRIANGLE_INDEX
        sta channel_index
        jsr advance_channel_row

        ; NOISE
        lda #NOISE_INDEX
        sta channel_index
        jsr advance_channel_row
        jsr fix_noise_freq

        .if ::BHOP_ZSAW_ENABLED
        ; Z-Saw
        lda #ZSAW_INDEX
        sta channel_index
        jsr advance_channel_row
        .endif

        .if ::BHOP_MMC5_ENABLED
        ; MMC5
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_MMC5
            beq skip_mmc5
            .endif
        lda #MMC5_PULSE_1_INDEX
        sta channel_index
        jsr advance_channel_row

        lda #MMC5_PULSE_2_INDEX
        sta channel_index
        jsr advance_channel_row
            .if ::BHOP_MULTICHIP
skip_mmc5:
            .endif
        .endif

        .if ::BHOP_VRC6_ENABLED
        ; VRC6
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_VRC6
            beq skip_vrc6
            .endif
        lda #VRC6_PULSE_1_INDEX
        sta channel_index
        jsr advance_channel_row

        lda #VRC6_PULSE_2_INDEX
        sta channel_index
        jsr advance_channel_row

        lda #VRC6_SAWTOOTH_INDEX
        sta channel_index
        jsr advance_channel_row
            .if ::BHOP_MULTICHIP
skip_vrc6:
            .endif
        .endif

        ; DPCM
        lda #DPCM_INDEX
        sta channel_index
        ; reset retrigger period and Wxx upon new row
        lda #0
        sta effect_retrigger_period
        lda #$FF
        sta effect_dpcm_pitch
        jsr advance_channel_row

.if ::BHOP_PATTERN_BANKING
        ; Now that we're done with patterns, restore the module bank before continuing
        lda module_bank
        switch_music_bank
.endif

        ; Every time we update the pattern rows, also advance the groove sequence if enabled
        jsr update_groove

        rts
.endproc

.proc skip_pattern_rows
        ; PULSE 1
        lda #PULSE_1_INDEX
        sta channel_index
        jsr skip_channel_row

        ; PULSE 2
        lda #PULSE_2_INDEX
        sta channel_index
        jsr skip_channel_row

        ; TRIANGLE
        lda #TRIANGLE_INDEX
        sta channel_index
        jsr skip_channel_row

        ; NOISE
        lda #NOISE_INDEX
        sta channel_index
        jsr skip_channel_row

        .if ::BHOP_ZSAW_ENABLED
        ; Z-Saw
        lda #ZSAW_INDEX
        sta channel_index
        jsr skip_channel_row
        .endif

        .if ::BHOP_MMC5_ENABLED
        ; MMC5
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_MMC5
            beq skip_mmc5
            .endif
        lda #MMC5_PULSE_1_INDEX
        sta channel_index
        jsr skip_channel_row

        lda #MMC5_PULSE_2_INDEX
        sta channel_index
        jsr skip_channel_row
            .if ::BHOP_MULTICHIP
skip_mmc5:
            .endif
        .endif

        .if ::BHOP_VRC6_ENABLED
        ; VRC6
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_VRC6
            beq skip_vrc6
            .endif
        lda #VRC6_PULSE_1_INDEX
        sta channel_index
        jsr skip_channel_row

        lda #VRC6_PULSE_2_INDEX
        sta channel_index
        jsr skip_channel_row

        lda #VRC6_SAWTOOTH_INDEX
        sta channel_index
        jsr skip_channel_row
            .if ::BHOP_MULTICHIP
skip_vrc6:
            .endif
        .endif

        ; DPCM
        lda #DPCM_INDEX
        sta channel_index
        jsr skip_channel_row

        rts
.endproc

.proc tick_delayed_effects
        ; Gxx: delayed pattern row
        ldx channel_index
        lda effect_note_delay, x
        beq done_with_note_delay
        dec effect_note_delay, x
        bne done_with_note_delay
        ; we just decremented the effect counter from 1 -> 0,
        ; so apply a note delay. In this case, tick the bytecode reader
        ; one time:
        jsr advance_channel_row
.if ::BHOP_PATTERN_BANKING
        ; That might have clobbered the module bank, so restore it before continuing
        lda module_bank
        switch_music_bank
.endif
        ; if this is the noise channel, fix its frequency
        lda channel_index
        cmp #3
        bne done_with_note_delay
        jsr fix_noise_freq
done_with_note_delay:
        ; Sxx: delayed note cut
        ldx channel_index
        lda effect_cut_delay, x
        beq done_with_cut_delay
        dec effect_cut_delay, x
        bne done_with_cut_delay
        ; apply a note cut, immediately silencing this channel and cancel delayed release
.if ::BHOP_DELAYED_RELEASE_ENABLED
        lda #0
        sta effect_release_delay, x
.endif
        lda channel_status, x
        ora #CHANNEL_MUTED
        sta channel_status, x
        jne done_with_delays
done_with_cut_delay:
.if ::BHOP_DELAYED_RELEASE_ENABLED
        lda effect_release_delay, x
        beq done_with_delays
        dec effect_release_delay, x
        bne done_with_delays
        ; note release
        lda channel_status, x
        ora #CHANNEL_RELEASED
        sta channel_status, x
.if ::BHOP_PATTERN_BANKING
        ; Instruments live in the module bank, so we need to swap that in before processing them
        lda module_bank
        switch_music_bank
.endif      
        jsr apply_release
.if ::BHOP_PATTERN_BANKING
        ; And now we need to switch back to the pattern bank before continuing
        ldx channel_index
        lda channel_pattern_bank, x
        switch_music_bank
        ldx channel_index ; un-clobber
.endif
.endif
done_with_delays:
        rts
.endproc

.macro initialize_detuned_frequency
        ldx channel_index
        lda channel_relative_frequency_low, x
        sta channel_detuned_frequency_low, x
        lda channel_relative_frequency_high, x
        sta channel_detuned_frequency_high, x
.endmacro

.proc tick_envelopes_and_effects
        ; PULSE 1
        lda #PULSE_1_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        ; the order of pitch updates matters a lot to match FT behavior
        jsr update_arp
        jsr update_pitch_effects
        jsr update_volume_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning

        ; PULSE 2
        lda #PULSE_2_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr update_arp
        jsr update_pitch_effects
        jsr update_volume_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning

        ; TRIANGLE
        lda #TRIANGLE_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr update_arp
        jsr update_pitch_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning

        ; NOISE
        lda #NOISE_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr update_volume_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr tick_noise_arp_envelope
        jsr tick_pitch_envelope

        ; DPCM
        lda #DPCM_INDEX
        sta channel_index
        jsr tick_delayed_effects

.if ::BHOP_ZSAW_ENABLED
        ; Z-Saw
        lda #ZSAW_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr update_volume_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope_zsaw
        jsr update_arp_zsaw
        jsr tick_arp_envelope_zsaw
.endif

.if ::BHOP_MMC5_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_MMC5
            jeq skip_mmc5
            .endif
        lda #MMC5_PULSE_1_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr update_arp
        jsr update_pitch_effects
        jsr update_volume_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning

        lda #MMC5_PULSE_2_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr update_arp
        jsr update_pitch_effects
        jsr update_volume_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning
            .if ::BHOP_MULTICHIP
skip_mmc5:
            .endif
.endif

.if ::BHOP_VRC6_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_VRC6
            jeq skip_vrc6
            .endif
        lda #VRC6_PULSE_1_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr update_arp
        jsr update_pitch_effects
        jsr update_volume_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning

        lda #VRC6_PULSE_2_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr update_arp
        jsr update_pitch_effects
        jsr update_volume_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning

        lda #VRC6_SAWTOOTH_INDEX
        sta channel_index
        jsr tick_delayed_effects
        jsr tick_volume_envelope
        jsr tick_duty_envelope
        jsr update_arp
        jsr update_pitch_effects
        jsr update_volume_effects
        jsr tick_arp_envelope
        jsr tick_pitch_envelope
        initialize_detuned_frequency
        jsr update_vibrato
        jsr update_tuning
            .if ::BHOP_MULTICHIP
skip_vrc6:
            .endif
.endif

        rts
.endproc

.proc advance_frame
        inc frame_counter
        lda frame_counter
        cmp frame_cmp
        bcc no_wrap
        lda #0
        sta frame_counter
no_wrap:
        ldx frame_counter
        jsr jump_to_frame
        jsr load_frame_patterns
        rts
.endproc

; Initializes channel state for playback of a particular instrument.
; Loads sequence pointers (if enabled) and clears pointers to begin
; sequence playback from the beginning
; setup:
;   channel_index points to desired channel
;   channel_selected_instrument[channel_index] contains desired instrument index
.proc load_instrument
        prepare_ptr_with_fixed_offset music_header_ptr, FtModuleHeader::instrument_list
        ldx channel_index
        lda channel_selected_instrument, x
        asl ; select one word
        tay

        ; set bhop_ptr to the selected index
        lda (bhop_ptr), y
        tax
        iny
        lda (bhop_ptr), y
        sta bhop_ptr+1
        stx bhop_ptr

        ; bhop_ptr now addresses the selected InstrumentHeader
        ldy #InstrumentHeader::sequences_enabled
        lda (bhop_ptr), y
        ldx channel_index
        sta sequences_enabled, x
        sta scratch_byte ; we'll shift bits out of this later

        ; for every enabled sequence, load the appropriate pointer
        clc
        ldy #InstrumentHeader::sequence_ptr
check_volume:
        lsr scratch_byte
        bcc check_arp

        lda (bhop_ptr), y
        sta volume_sequence_ptr_low, x
        iny
        lda (bhop_ptr), y
        sta volume_sequence_ptr_high, x
        iny

check_arp:
        lsr scratch_byte
        bcc check_pitch

        lda (bhop_ptr), y
        sta arpeggio_sequence_ptr_low, x
        iny
        lda (bhop_ptr), y
        sta arpeggio_sequence_ptr_high, x
        iny

check_pitch:
        lsr scratch_byte
        bcc check_hipitch

        lda (bhop_ptr), y
        sta pitch_sequence_ptr_low, x
        iny
        lda (bhop_ptr), y
        sta pitch_sequence_ptr_high, x
        iny

check_hipitch:
        lsr scratch_byte
        bcc check_duty

        lda (bhop_ptr), y
        sta hipitch_sequence_ptr_low, x
        iny
        lda (bhop_ptr), y
        sta hipitch_sequence_ptr_high, x
        iny

check_duty:
        lsr scratch_byte
        bcc done_loading_sequences

        lda (bhop_ptr), y
        sta duty_sequence_ptr_low, x
        iny
        lda (bhop_ptr), y
        sta duty_sequence_ptr_high, x
        ; no more need to iny

done_loading_sequences:
        jsr reset_instrument
        rts
.endproc

; Re-initializes sequence pointers back to the beginning of their
; respective envelopes
; setup:
;   channel_index points to the active channel
.proc reset_instrument
        ldy channel_index
        lda #0
        sta volume_sequence_index, y
        sta arpeggio_sequence_index, y
        sta pitch_sequence_index, y
        sta hipitch_sequence_index, y
        sta duty_sequence_index, y

        ; when a sequence ends it terminates itself in sequences_active, so re-initialize
        ; that byte here

        lda sequences_enabled, y
        sta sequences_active, y

        rts
.endproc

; If this channel has a volume envelope active, process that
; envelope. Upon return, instrument_volume will have the current
; element in the sequence.
; setup:
;   channel_index points to channel structure
.proc tick_volume_envelope
        ldy channel_index
        lda sequences_active, y
        and #SEQUENCE_VOLUME
        beq done ; if volume sequence isn't enabled, bail fast

        ; prepare the volume pointer for reading
        lda volume_sequence_ptr_low, y
        sta bhop_ptr
        lda volume_sequence_ptr_high, y
        sta bhop_ptr + 1

.if ::BHOP_VRC6_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_VRC6
            beq skip_vrc6
            .endif
        ; grab and stash the mode byte, which some expansion instruments need
        ldy #SequenceHeader::mode
        lda (bhop_ptr), y
        ldy channel_index
        sta channel_volume_mode, y
            .if ::BHOP_MULTICHIP
skip_vrc6:
            .endif
.endif

        ; read the current sequence byte, and set instrument_volume to this
        lda volume_sequence_index, y
        tax ; stash for later
        ; for reading the sequence, +4
        clc
        adc #4
        tay
        lda (bhop_ptr), y
        ldy channel_index
        sta channel_instrument_volume, y

        ; tick the sequence counter and exit
        jsr tick_sequence_counter

        ; have we reached the end of the sequence?
        ldy #SequenceHeader::length
        lda (bhop_ptr), y
        sta scratch_byte
        cpx scratch_byte
        bne end_not_reached

        ; this sequence is finished! Disable the sequence flag and exit
        ldy channel_index
        lda sequences_active, y
        and #($FF - SEQUENCE_VOLUME)
        sta sequences_active, y
        rts

end_not_reached:
        ; write the new sequence index (should be in x)
        ldy channel_index
        txa
        sta volume_sequence_index, y

done:
        rts
.endproc

; If this channel has a duty envelope active, process that
; envelope. Upon return, instrument_duty is set
; setup:
;   channel_index points to channel structure
.proc tick_duty_envelope
        ldy channel_index
        lda sequences_active, y
        and #SEQUENCE_DUTY
        beq done ; if sequence isn't enabled, bail fast

        ; prepare the duty pointer for reading
        lda duty_sequence_ptr_low, y
        sta bhop_ptr
        lda duty_sequence_ptr_high, y
        sta bhop_ptr + 1

        ; read the current sequence byte, and set instrument_volume to this
        lda duty_sequence_index, y
        tax ; stash for later
        ; for reading the sequence, +4
        clc
        adc #4
        tay
        lda (bhop_ptr), y
        ldy channel_index
        sta channel_instrument_duty, y

        ; tick the sequence counter and exit
        jsr tick_sequence_counter

        ; have we reached the end of the sequence?
        ldy #SequenceHeader::length
        lda (bhop_ptr), y
        sta scratch_byte
        cpx scratch_byte
        bne end_not_reached

        ; this sequence is finished! Disable the sequence flag and exit
        ldy channel_index
        lda sequences_active, y
        and #($FF - SEQUENCE_DUTY)
        sta sequences_active, y
        rts

end_not_reached:
        ; write the new sequence index (should still be in x)
        ldy channel_index
        txa
        sta duty_sequence_index, y

done:
        rts
.endproc

; If this channel has an arp envelope active, process that
; envelope. Upon return, base_note and relative_frequency are set
; setup:
;   channel_index, channel_index points to channel structure
.proc tick_arp_envelope
        ldx channel_index
        lda sequences_active, x
        and #SEQUENCE_ARP
        beq early_exit ; if sequence isn't enabled, bail fast

        ; prepare the arp pointer for reading
        lda arpeggio_sequence_ptr_low, x
        sta bhop_ptr
        lda arpeggio_sequence_ptr_high, x
        sta bhop_ptr + 1

        ; For fixed arps, we need to "reset" the channel if the envelope finishes, so we're doing
        ; the length check first thing

        lda arpeggio_sequence_index, x
        sta scratch_byte
        ; have we reached the end of the sequence?
        ldy #SequenceHeader::length
        lda (bhop_ptr), y
        cmp scratch_byte
        bne end_not_reached

        ; this sequence is finished! Disable the sequence flag
        lda sequences_active, x
        and #($FF - SEQUENCE_ARP)
        sta sequences_active, x

        ; is this a fixed arp?
        ldy #SequenceHeader::mode
        lda (bhop_ptr), y
        cmp #ARP_MODE_FIXED
        bne early_exit

        ; apply the current base note as the channel frequency,
        ; then exit:
        lda channel_base_note, x
        jsr set_channel_relative_frequency

early_exit:
        rts

end_not_reached:
        ; read the current sequence byte, and set instrument_volume to this
        lda arpeggio_sequence_index, x
        pha ; stash for later
        ; for reading the sequence, +4
        clc
        adc #4
        tay
        lda (bhop_ptr), y
        sta scratch_byte ; will affect the note, depending on mode
        clc

        ; what we actually *do* with the arp byte depends on the mode
        ldy #SequenceHeader::mode
        lda (bhop_ptr), y
        cmp #ARP_MODE_ABSOLUTE
        beq arp_absolute
        cmp #ARP_MODE_RELATIVE
        beq arp_relative
        cmp #ARP_MODE_FIXED
        beq arp_fixed
        ; ARP SCHEME, unimplemented! for now, treat this just like absolute
arp_absolute:
        ; arp is an offset from base note to apply each frame
        lda channel_base_note, x
        clc
        adc scratch_byte
        jmp apply_arp
arp_relative:
        ; were we just triggered? if so, reset the relative offset
        lda channel_rstatus, x
        and #ROW_TRIGGERED
        beq not_triggered
        lda #0
        sta channel_relative_note_offset, x
not_triggered:
        ; arp accumulates an offset each frame, from the previous frame
        lda channel_relative_note_offset, x
        clc
        adc scratch_byte
        sta channel_relative_note_offset, x
        ; this offset is then applied to base_note
        lda channel_base_note, x
        clc
        adc channel_relative_note_offset, x
        ; stuff that result in y, and apply it
        jmp apply_arp
arp_fixed:
        ; the arp value +1 is the note to apply
        lda scratch_byte
        clc
        adc #1
        ; fall through to apply_arp
apply_arp:
        jsr set_channel_relative_frequency

done_applying_arp:
        pla ; unstash the sequence counter
        tax ; move into x, which tick_sequence_counter expects

        ; tick the sequence counter and exit
        jsr tick_sequence_counter

        ; write the new sequence index (should still be in x)
        ldy channel_index
        txa
        sta arpeggio_sequence_index, y

done:
        rts
.endproc

; If this channel has a pitch envelope active, process that
; envelope. Upon return, relative_pitch is set
; setup:
;   channel_index points to channel structure
.proc tick_pitch_envelope
        ldy channel_index
        lda sequences_active, y
        and #SEQUENCE_PITCH
        jeq done ; if sequence isn't enabled, bail fast

        ; prepare the pitch pointer for reading
        lda pitch_sequence_ptr_low, y
        sta bhop_ptr
        lda pitch_sequence_ptr_high, y
        sta bhop_ptr + 1

        ; read the current sequence byte, and set instrument_volume to this
        lda pitch_sequence_index, y
        tax ; stash for later
        ; for reading the sequence, +4
        clc
        adc #4
        tay
        lda (bhop_ptr), y
        sta scratch_byte

        ; what we do here depends on the mode
        ldy #SequenceHeader::mode
        lda (bhop_ptr), y
        cmp #PITCH_MODE_RELATIVE
        beq relative_pitch_mode
absolute_pitch_mode:
        ; additional guard: if we are currently running an arp
        ; envelope, then temporarily pretend to be in relative_pitch mode
        ; (otherwise we cancel out the arp)
        ldy channel_index
        lda sequences_active, y
        and #SEQUENCE_ARP
        bne relative_pitch_mode

        ; in absolute mode, reset to base_frequency before
        ; performing the addition
        lda channel_base_frequency_low, y
        sta channel_relative_frequency_low, y
        lda channel_base_frequency_high, y
        sta channel_relative_frequency_high, y
relative_pitch_mode:
        ; add this data to relative_pitch
        ldy channel_index
        sadd16_split_y channel_relative_frequency_low, channel_relative_frequency_high, scratch_byte
        ; clamp pitch within range
        clamp_detune_pitch_split_y channel_relative_frequency_low, channel_relative_frequency_high

done_applying_pitch:
        ; tick the sequence counter and exit
        jsr tick_sequence_counter

        ; have we reached the end of the sequence?
        ldy #SequenceHeader::length
        lda (bhop_ptr), y
        sta scratch_byte
        cpx scratch_byte
        bne end_not_reached

        ; this sequence is finished! Disable the sequence flag and exit
        ldy channel_index
        lda sequences_active, y
        and #($FF - SEQUENCE_PITCH)
        sta sequences_active, y
        rts

end_not_reached:
        ; write the new sequence index (should still be in x)
        ldy channel_index
        txa
        sta pitch_sequence_index, y

done:
        rts
.endproc

; setup:
;   channel_index points to channel structure
;   bhop_ptr points to start of sequence data
;   x - current sequence pointer
; return: new sequence counter in x
; side effects: sequences_active altered
.proc tick_sequence_counter
        ; increment the index we stashed earlier
        inx
        ; have we reached the end of the loop?
        ldy #SequenceHeader::length
        lda (bhop_ptr), y
        sta scratch_byte
        cpx scratch_byte
        bne end_not_reached

end_reached:
        ; Do we have a loop point defined?
        ldy #SequenceHeader::loop_point
        lda (bhop_ptr), y
        cmp #$FF
        beq end_reached_without_loop
        ; Is this loop point *after* the release point?
        ldy #SequenceHeader::release_point
        cmp (bhop_ptr), y ; A=loop point, M=release point
        bcc end_reached_without_loop
        jmp apply_loop_point

end_reached_without_loop:
        ; do nothing, and exit; the calling function will check to see if
        ; the sequence pointer is at the end, and deactivate the sequence
        rts

end_not_reached:
        ; have we reached the release point?
        ldy #SequenceHeader::release_point
        lda (bhop_ptr), y
        sta scratch_byte
        cpx scratch_byte
        bne release_point_not_reached
        
        ; are we released?
        ldy channel_index
        lda channel_status, y
        and #CHANNEL_RELEASED
        bne done

        ; is there a loop point?
        ldy #SequenceHeader::loop_point
        lda (bhop_ptr), y
        cmp #$FF ; magic value, means there is no loop defined
        beq release_without_loop
        ; is the loop point *before* the release point?
        cmp scratch_byte ; A=loop point, M=release point
        bcs release_without_loop

apply_loop_point:
        ; a contains our loop point, so jump there and exit
        tax
        rts

release_without_loop:
        ; otherwise, hold position and exit
        dex
        rts

release_point_not_reached:
        ; no jumps needed, so stash our new sequence value and exit
done:
        rts
.endproc

.macro release_sequence sequence_type, sequence_ptr_low, sequence_ptr_high, pitch_sequence_index
.scope
        lda sequences_active, x
        and #sequence_type
        beq done_with_sequence ; if sequence isn't enabled, bail fast

        ; prepare the pitch pointer for reading
        lda sequence_ptr_low, x
        sta bhop_ptr
        lda sequence_ptr_high, x
        sta bhop_ptr + 1

        ; do we have a release point enabled?
        ldy #SequenceHeader::release_point
        lda (bhop_ptr), y
        beq done_with_sequence
        ; set the sequence index to the release point immediately
        ; (it will be ticked *past* this point on the next cycle)
        sec
        sbc #1
        sta pitch_sequence_index, x
done_with_sequence:
.endscope
.endmacro

; If this channel has any envelopes, and those envelopes
; have a release point, jump to it immediately
; setup:
;   channel_index points to channel structure
;   x contains channel_index
.proc apply_release
        ; note: channel_index is conveniently already in X
release_sequence SEQUENCE_VOLUME, volume_sequence_ptr_low, volume_sequence_ptr_high, volume_sequence_index
release_sequence SEQUENCE_PITCH, pitch_sequence_ptr_low, pitch_sequence_ptr_high, pitch_sequence_index
release_sequence SEQUENCE_ARP, arpeggio_sequence_ptr_low, arpeggio_sequence_ptr_high, arpeggio_sequence_index
release_sequence SEQUENCE_DUTY, duty_sequence_ptr_low, duty_sequence_ptr_high, duty_sequence_index
        rts
.endproc

.proc tick_registers
tick_pulse1:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + PULSE_1_INDEX
        bne tick_pulse2
        bmi pulse1_muted

        ; add in the duty
        lda channel_instrument_duty + PULSE_1_INDEX
        ror
        ror
        ror
        and #%11000000
        sta scratch_byte
        
        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + PULSE_1_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + PULSE_1_INDEX
        tax
        lda volume_table, x
        ora #%00110000 ; disable length counter and envelope
        ora scratch_byte
        sta $4000

        ; disable the sweep unit
        lda #$08
        sta $4001

        lda channel_detuned_frequency_low + PULSE_1_INDEX
        sta $4002

        ; If we triggered this frame, write unconditionally
        lda channel_rstatus + PULSE_1_INDEX
        and #ROW_TRIGGERED
        bne write_pulse1

        ; otherwise, to avoid resetting the sequence counter, only
        ; write if the high byte has changed since the last time
        lda channel_detuned_frequency_high + PULSE_1_INDEX
        cmp shadow_pulse1_freq_hi
        beq tick_pulse2

write_pulse1:
        lda channel_detuned_frequency_high + PULSE_1_INDEX
        sta shadow_pulse1_freq_hi
        ora #%11111000
        sta $4003
        jmp tick_pulse2
pulse1_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00110000
        sta $4000

tick_pulse2:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + PULSE_2_INDEX
        bne tick_triangle
        bmi pulse2_muted

        ; add in the duty
        lda channel_instrument_duty + PULSE_2_INDEX
        ror
        ror
        ror
        and #%11000000
        sta scratch_byte

        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + PULSE_2_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + PULSE_2_INDEX
        tax
        lda volume_table, x
        ora #%00110000 ; disable length counter and envelope
        ora scratch_byte
        sta $4004

        ; disable the sweep unit
        lda #$08
        sta $4005

        lda channel_detuned_frequency_low + PULSE_2_INDEX
        sta $4006

        ; If we triggered this frame, write unconditionally
        lda channel_rstatus + PULSE_2_INDEX
        and #ROW_TRIGGERED
        bne write_pulse2

        ; otherwise, to avoid resetting the sequence counter, only
        ; write if the high byte has changed since the last time
        lda channel_detuned_frequency_high + PULSE_2_INDEX
        cmp shadow_pulse2_freq_hi
        beq tick_triangle

write_pulse2:
        lda channel_detuned_frequency_high + PULSE_2_INDEX
        sta shadow_pulse2_freq_hi
        ora #%11111000
        sta $4007
        jmp tick_triangle
pulse2_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00110000
        sta $4004

tick_triangle:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + TRIANGLE_INDEX
        bne tick_noise
        bmi triangle_muted

        ; triangle additionally should mute here if either channel volume,
        ; or instrument volume is zero
        ; (but don't clobber a)
        ldx channel_volume + TRIANGLE_INDEX
        beq triangle_muted
        ldx channel_instrument_volume + TRIANGLE_INDEX
        beq triangle_muted

        lda #$FF
        sta $4008 ; timers to max

        lda channel_detuned_frequency_low + TRIANGLE_INDEX
        sta $400A
        lda channel_detuned_frequency_high + TRIANGLE_INDEX
        sta $400B
        jmp tick_noise
triangle_muted:
        ; since triangle has no volume, we'll instead choose to mute it by
        ; setting the length counter to 0 and forcing an immediate reload.
        ; This will delay the mute by up to 1/4 of a frame, but this is the
        ; best we can do without conflicting with the DMC channel
        lda #$80
        sta $4008

tick_noise:
        lda #CHANNEL_SUPPRESSED
        bit channel_status + NOISE_INDEX
        bne tick_dpcm
        bmi noise_muted

        ; apply the combined channel and instrument volume
        lda channel_tremolo_volume + NOISE_INDEX
        asl
        asl
        asl
        asl
        ora channel_instrument_volume + NOISE_INDEX
        tax
        lda volume_table, x

        ora #%00110000 ; disable length counter and envelope
        sta $400C

        ; the low 4 bits of relative_frequency become the
        ; noise period
        lda channel_relative_frequency_low + NOISE_INDEX
        ; of *course* it's inverted
        sta scratch_byte
        lda #$10
        sec
        sbc scratch_byte
        and #%00001111
        sta scratch_byte

        ; the low bit of channel duty becomes mode bit 1
        lda channel_instrument_duty + NOISE_INDEX
        ror
        ror
        and #%10000000 ; safety mask
        ora scratch_byte

        sta $400E

        ; finally, ensure the note is actually playing with a length
        ; counter that is not zero
        lda #%11111000
        sta $400F
        jmp tick_dpcm
noise_muted:
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00110000
        sta $400C

tick_dpcm:
        jsr play_dpcm_samples

.if ::BHOP_ZSAW_ENABLED
        jsr play_zsaw
.endif

.if ::BHOP_MMC5_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_MMC5
            beq skip_mmc5
            .endif
        jsr play_mmc5
            .if ::BHOP_MULTICHIP
skip_mmc5:
            .endif
.endif

.if ::BHOP_VRC6_ENABLED
            .if ::BHOP_MULTICHIP
            lda expansion_flags
            and #EXPANSION_VRC6
            beq skip_vrc6
            .endif
        jsr play_vrc6
            .if ::BHOP_MULTICHIP
skip_vrc6:
            .endif
.endif

cleanup:
        rts
.endproc

.proc play_dpcm_samples
        lda channel_status + DPCM_INDEX
        and #CHANNEL_SUPPRESSED
        jne done

        ; Xxx handling; see CDPCMChan::RefreshChannel() in Dn-FT
        ; decrement effect_retrigger_counter while effect_retrigger_counter != zero
        lda effect_retrigger_period
        beq next
        dec effect_retrigger_counter

        ; if retrigger counter is decremented to 0 at this point
        ; then time to trigger the sample again
        lda effect_retrigger_counter
        bne next
        lda effect_retrigger_period
        sta effect_retrigger_counter
        
        ; trigger_sample without resetting effect_retrigger_counter via queue_sample
        jsr trigger_sample
next:

        ; handle note cut and note release
        ; see CDPCMChan::RefreshChannel() in Dn-FT 
        lda channel_status + DPCM_INDEX
        and #(CHANNEL_MUTED | CHANNEL_RELEASED)
        jne dpcm_muted

        ; check if channel is enabled in the first place
        lda dpcm_status
        and #DPCM_ENABLED
        jeq done

        ; make arrangements to write to the specific registers
        lda channel_rstatus + DPCM_INDEX
        and #ROW_TRIGGERED
        jeq check_for_inactive

        ; We're about to trigger a DPCM sample,
        ; so silence virtual Z channels.
        ; DPCM will always have higher priority
        .if ::BHOP_ZSAW_ENABLED
        jsr zsaw_disable
        .elseif ::BHOP_ZPCM_ENABLED
        jsr zpcm_disable
        .endif

        ; using the current note, read the sample table
        prepare_ptr_with_fixed_offset music_header_ptr, FtModuleHeader::sample_list
        lda channel_base_note + DPCM_INDEX

        sta scratch_byte
        dec scratch_byte ; notes start at 1, list is indexed at 0
        ; multiply by 3
        lda #0
        clc
        adc scratch_byte
        adc scratch_byte
        adc scratch_byte
        tay
        ; in order, the sample_list should contain:
        ; - LL..RRRR - Loop, playback Rate
        ; - EDDDDDDD - delta Enabled, Delta counter
        ; - nnnnnnnn - iNdex into sample table
        lda (bhop_ptr), y
        iny
        sta scratch_byte
        lda effect_dpcm_pitch ; check for Wxx
        bmi skip_pitch ; != -1? then Wxx takes precedence
        lda scratch_byte
        and #$F0
        ora effect_dpcm_pitch
        sta scratch_byte
skip_pitch:
        lda scratch_byte
        and #%01111111 ; do NOT enable IRQs
        sta $4010      ; write rate and loop enable
        lda (bhop_ptr), y
        iny
        sta scratch_byte
        lda effect_dac_buffer ; check for Zxx
        bpl skip_dac ; != -1? then it was already written
        lda scratch_byte
        bmi skip_dac
        sta $4011
skip_dac:
        lda #$FF
        sta effect_dac_buffer

        lda (bhop_ptr), y
        ; this is the index into the samples table, here it is pre-multiplied
        ; so we can use it directly
        ; save the y value since it is scratched by the prepare_ptr
        pha
        prepare_ptr_with_fixed_offset music_header_ptr, FtModuleHeader::samples
        pla
        tay
        ; the sample table should contain, in order:
        ; - location byte
        ; - size byte
        ; - bank to switch in

        lda (bhop_ptr), y
        ; cheaper to just do this unconditionally
        clc
        adc effect_dpcm_offset
        sta $4012
        iny

        lda (bhop_ptr), y
        sta $4013

.if ::BHOP_DPCM_BANKING
        iny
        lda (bhop_ptr), y
        jsr BHOP_DPCM_SWITCH_ROUTINE
.endif

        ; finally, briefly disable the sample channel to set bytes_remaining in the memory
        ; reader to 0, then start it again to initiate playback
        lda #$0F
        sta $4015
        lda #$1F
        sta $4015

done:
        rts

dpcm_muted:
        ; Only take action if virtual Z channels are disabled...
        .if ::BHOP_ZSAW_ENABLED .or ::BHOP_ZPCM_ENABLED
        lda dpcm_status
            .if ::BHOP_ZSAW_ENABLED
            and #DPCM_ZSAW_ENABLED
            .elseif ::BHOP_ZPCM_ENABLED
            and #DPCM_ZPCM_ENABLED
            .endif
        bne done
        .endif
        ; simply disable the channel and exit (whatever is in the sample playback buffer will
        ; finish, up to 8 bits, there is no way to disable this)
        lda #%00001111
        sta $4015

        lda channel_status + DPCM_INDEX
        and #CHANNEL_MUTED
        bne dpcm_cut
        lda channel_status + DPCM_INDEX
        and #($FF - CHANNEL_RELEASED) ; release release note if note released
        sta channel_status + DPCM_INDEX
        jmp dpcm_release
dpcm_cut:
        lda #0 ; regain full volume for TN
        sta $4011
dpcm_release:
        lda dpcm_status
        and #($FF - (DPCM_ENABLED))
        sta dpcm_status

check_for_inactive:
        ; Only take action if virtual Z channels are disabled...
        .if ::BHOP_ZSAW_ENABLED .or ::BHOP_ZPCM_ENABLED

        ; See if that DPCM playback has finished:
        lda $4015
        and #%00010000
        bne done

        ; If it has, enable virtual Z channels
        ; to initiate playback on the next tick
            .if ::BHOP_ZSAW_ENABLED
            jsr zsaw_enable
            .elseif ::BHOP_ZPCM_ENABLED
            jsr zpcm_enable
            .endif
        .endif

        rts
.endproc

.if ::BHOP_ZPCM_ENABLED
; request to disable ZPCM
.proc zpcm_disable
        ; check if ZPCM is already disabled first
        lda dpcm_status
        and #DPCM_ZPCM_ENABLED
        beq done

        .if ::BHOP_ZPCM_CONFLICT_AVOIDANCE
        jsr BHOP_ZPCM_DISABLE_ROUTINE
        .endif
        
        ; set status flag
        lda dpcm_status
        and #($FF - (DPCM_ZPCM_ENABLED))
        sta dpcm_status
done:
        rts
.endproc

; request to enable ZPCM
.proc zpcm_enable
        ; check if ZPCM is already enabled first
        lda dpcm_status
        and #DPCM_ZPCM_ENABLED
        bne done

        .if ::BHOP_ZPCM_CONFLICT_AVOIDANCE
        jsr BHOP_ZPCM_ENABLE_ROUTINE
        .endif
        
        ; set status flag
        lda dpcm_status
        ora #DPCM_ZPCM_ENABLED
        sta dpcm_status
done:
        rts
.endproc
.endif

.if ::BHOP_ZSAW_ENABLED
; request to disable Z-Saw
.proc zsaw_disable
        ; check if Z-Saw is already disabled first
        lda dpcm_status
        and #DPCM_ZSAW_ENABLED
        beq done
        jsr zsaw_silence
        
        ; set status flag
        lda dpcm_status
        and #($FF - (DPCM_ZSAW_ENABLED))
        sta dpcm_status
done:
        rts
.endproc

; request to enable Z-Saw
.proc zsaw_enable
        ; check if ZPCM is already enabled first
        lda dpcm_status
        and #DPCM_ZSAW_ENABLED
        bne done
        ; do nothing, will play on the next tick
        
        ; set status flag
        lda dpcm_status
        ora #DPCM_ZSAW_ENABLED
        sta dpcm_status
done:
        rts
.endproc
.endif

; resets the retrigger logic upon a new DPCM sample note
.proc trigger_sample
        .if ::BHOP_ZPCM_ENABLED
        .if .not ::BHOP_ZPCM_CONFLICT_AVOIDANCE
        ; since we don't have any means to disable ZPCM,
        ; avoid playing samples altogether when ZPCM is enabled
        lda dpcm_status
        and #DPCM_ZPCM_ENABLED
        beq next
        rts
next:
        .endif
        .endif

        lda dpcm_status
        ora #DPCM_ENABLED
        sta dpcm_status
        lda channel_rstatus + DPCM_INDEX
        ora #ROW_TRIGGERED
        sta channel_rstatus + DPCM_INDEX
        rts
.endproc

; If effect_retrigger_period != 0, this initializes retriggering. Otherwise reset effect_retrigger_counter.
.proc queue_sample
        lda effect_retrigger_period
        beq reset_counter
        sta effect_retrigger_counter
        inc effect_retrigger_counter
        rts
reset_counter:
        lda #0
        sta effect_retrigger_counter
        rts
.endproc

.proc bhop_play
.if ::BHOP_PATTERN_BANKING
        lda module_bank
        sta current_music_bank
        jsr BHOP_PATTERN_SWITCH_ROUTINE
.endif

        ; clear the volatile status
        lda #0
.repeat BHOP::NUM_CHANNELS, i
        sta channel_rstatus + i
.endrepeat

        jsr tick_frame_counter
        jsr tick_envelopes_and_effects
        jsr tick_registers
        ; :D
        rts
.endproc

; channel index in A
.proc bhop_mute_channel
        tax
        lda #(CHANNEL_SUPPRESSED)
        ora channel_status, x
        sta channel_status, x
        ; if this is a pulse channel, make sure our next update
        ; after we un-mute writes a new frequency value
check_pulse_1:
        cpx #0
        bne check_pulse_2
        lda #$FF
        sta shadow_pulse1_freq_hi
check_pulse_2:
        cpx #1
        bne done
        lda #$FF
        sta shadow_pulse2_freq_hi
done:
        rts
.endproc

.proc init_2a03
        ; if the channel is muted, little else matters, but ensure
        ; we set the volume to 0
        lda #%00110000
        sta $4000
        sta $4004
        sta $400C

        ; since triangle has no volume, we'll instead choose to mute it by
        ; setting the length counter to 0 and forcing an immediate reload.
        ; This will delay the mute by up to 1/4 of a frame, but this is the
        ; best we can do without conflicting with the DMC channel
        lda #$80
        sta $4008

        ; disable unusual IRQ sources
        lda #%01000000
        sta $4017 ; APU frame counter
        lda #0
        sta $4010 ; DMC DMA
        sta $4011 ; regain full volume for TN

        ; disable DPCM channel
        lda #%00001111
        sta $4015
        rts
.endproc

; channel index in A
.proc bhop_unmute_channel
        tax
        lda #($FF - CHANNEL_SUPPRESSED)
        and channel_status, x
        sta channel_status, x
        rts
.endproc

.include "bhop/util.asm"
.include "bhop/2a03_noise.asm"
.if ::BHOP_ZSAW_ENABLED
.include "bhop/2a03_zsaw.asm"
.endif
.if ::BHOP_MMC5_ENABLED
.include "bhop/mmc5.asm"
.endif
.if ::BHOP_VRC6_ENABLED
.include "bhop/vrc6.asm"
.endif


volume_table:
        .byte $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
        .byte $0, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1
        .byte $0, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $2
        .byte $0, $1, $1, $1, $1, $1, $1, $1, $1, $1, $2, $2, $2, $2, $2, $3
        .byte $0, $1, $1, $1, $1, $1, $1, $1, $2, $2, $2, $2, $3, $3, $3, $4
        .byte $0, $1, $1, $1, $1, $1, $2, $2, $2, $3, $3, $3, $4, $4, $4, $5
        .byte $0, $1, $1, $1, $1, $2, $2, $2, $3, $3, $4, $4, $4, $5, $5, $6
        .byte $0, $1, $1, $1, $1, $2, $2, $3, $3, $4, $4, $5, $5, $6, $6, $7
        .byte $0, $1, $1, $1, $2, $2, $3, $3, $4, $4, $5, $5, $6, $6, $7, $8
        .byte $0, $1, $1, $1, $2, $3, $3, $4, $4, $5, $6, $6, $7, $7, $8, $9
        .byte $0, $1, $1, $2, $2, $3, $4, $4, $5, $6, $6, $7, $8, $8, $9, $A
        .byte $0, $1, $1, $2, $2, $3, $4, $5, $5, $6, $7, $8, $8, $9, $A, $B
        .byte $0, $1, $1, $2, $3, $4, $4, $5, $6, $7, $8, $8, $9, $A, $B, $C
        .byte $0, $1, $1, $2, $3, $4, $5, $6, $6, $7, $8, $9, $A, $B, $C, $D
        .byte $0, $1, $1, $2, $3, $4, $5, $6, $7, $8, $9, $A, $B, $C, $D, $E
        .byte $0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $A, $B, $C, $D, $E, $F


.if ::BHOP_PITCH_DETUNE_CLAMP_ENABLED
channel_min_frequency_low:
        ; PULSE_1_INDEX
        .byte <FREQUENCY_MIN_2A03
        ; PULSE_2_INDEX
        .byte <FREQUENCY_MIN_2A03
        ; TRIANGLE_INDEX
        .byte <FREQUENCY_MIN_2A03
        ; NOISE_INDEX
        .byte 0
.if ::BHOP_ZSAW_ENABLED
        ; ZSAW_INDEX
        .byte 0     ; Z-Saw doesn't support pitch bends
.endif
.if ::BHOP_MMC5_ENABLED
        ; MMC5_PULSE_1_INDEX
        .byte <FREQUENCY_MIN_2A03
        ; MMC5_PULSE_2_INDEX
        .byte <FREQUENCY_MIN_2A03
.endif
.if ::BHOP_VRC6_ENABLED
        ; VRC6_PULSE_1_INDEX
        .byte <FREQUENCY_MIN_VRC6
        ; VRC6_PULSE_2_INDEX
        .byte <FREQUENCY_MIN_VRC6
        ; VRC6_SAWTOOTH_INDEX
        .byte <FREQUENCY_MIN_VRC6
.endif
        ; DPCM_INDEX
        .byte 0

channel_min_frequency_high:
        ; PULSE_1_INDEX
        .byte >FREQUENCY_MIN_2A03
        ; PULSE_2_INDEX
        .byte >FREQUENCY_MIN_2A03
        ; TRIANGLE_INDEX
        .byte >FREQUENCY_MIN_2A03
        ; NOISE_INDEX
        .byte 0
.if ::BHOP_ZSAW_ENABLED
        ; ZSAW_INDEX
        .byte 0     ; Z-Saw doesn't support pitch bends
.endif
.if ::BHOP_MMC5_ENABLED
        ; MMC5_PULSE_1_INDEX
        .byte >FREQUENCY_MIN_2A03
        ; MMC5_PULSE_2_INDEX
        .byte >FREQUENCY_MIN_2A03
.endif
.if ::BHOP_VRC6_ENABLED
        ; VRC6_PULSE_1_INDEX
        .byte >FREQUENCY_MIN_VRC6
        ; VRC6_PULSE_2_INDEX
        .byte >FREQUENCY_MIN_VRC6
        ; VRC6_SAWTOOTH_INDEX
        .byte >FREQUENCY_MIN_VRC6
.endif
        ; DPCM_INDEX
        .byte 0

channel_max_frequency_low:
        ; PULSE_1_INDEX
        .byte <FREQUENCY_MAX_2A03
        ; PULSE_2_INDEX
        .byte <FREQUENCY_MAX_2A03
        ; TRIANGLE_INDEX
        .byte <FREQUENCY_MAX_2A03
        ; NOISE_INDEX
        .byte $FF
.if ::BHOP_ZSAW_ENABLED
        ; ZSAW_INDEX
        .byte $FF   ; Z-Saw doesn't support pitch bends
.endif
.if ::BHOP_MMC5_ENABLED
        ; MMC5_PULSE_1_INDEX
        .byte <FREQUENCY_MAX_2A03
        ; MMC5_PULSE_2_INDEX
        .byte <FREQUENCY_MAX_2A03
.endif
.if ::BHOP_VRC6_ENABLED
        ; VRC6_PULSE_1_INDEX
        .byte <FREQUENCY_MAX_VRC6
        ; VRC6_PULSE_2_INDEX
        .byte <FREQUENCY_MAX_VRC6
        ; VRC6_SAWTOOTH_INDEX
        .byte <FREQUENCY_MAX_VRC6
.endif
        ; DPCM_INDEX
        .byte $FF

channel_max_frequency_high:
        ; PULSE_1_INDEX
        .byte >FREQUENCY_MAX_2A03
        ; PULSE_2_INDEX
        .byte >FREQUENCY_MAX_2A03
        ; TRIANGLE_INDEX
        .byte >FREQUENCY_MAX_2A03
        ; NOISE_INDEX
        .byte $7F
.if ::BHOP_ZSAW_ENABLED
        ; ZSAW_INDEX
        .byte $7F   ; Z-Saw doesn't support pitch bends
.endif
.if ::BHOP_MMC5_ENABLED
        ; MMC5_PULSE_1_INDEX
        .byte >FREQUENCY_MAX_2A03
        ; MMC5_PULSE_2_INDEX
        .byte >FREQUENCY_MAX_2A03
.endif
.if ::BHOP_VRC6_ENABLED
        ; VRC6_PULSE_1_INDEX
        .byte >FREQUENCY_MAX_VRC6
        ; VRC6_PULSE_2_INDEX
        .byte >FREQUENCY_MAX_VRC6
        ; VRC6_SAWTOOTH_INDEX
        .byte >FREQUENCY_MAX_VRC6
.endif
        ; DPCM_INDEX
        .byte $7F
.endif

.endscope


