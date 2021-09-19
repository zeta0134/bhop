TODO - bhop
===========

- [x] Convert remaining struct members to LUTs for performance
  - [x] pattern_ptr
  - [x] status
  - [x] global_duration
  - [x] row_delay_counter
  - [x] base_note
  - [x] base_frequency
  - [x] relative_frequency
  - [x] detuned_frequency
  - [x] channel_volume
  - [x] instrument_volume
  - [x] instrument_duty
  - [x] selected_instrument
  - [x] pitch_effects_active
  - [x] note_delay

- [ ] Implement major effects
  - [x] 4xy vibrato
  - [x] 1xx, 2xx: continuous slide
  - [x] Qxy, Rxy targeted semitone note slide
  - [x] 3xx automatic note slide (portamento)
  - [x] 0xy arpeggio
  - [ ] 7xy tremolo
  - [ ] Axy volume slide

- [x] Implement minor effects
  - [x] Fxx tempo change
  - [x] Sxx delayed note cut
  - [x] Dxx skip to next frame + xx rows

- [x] Work on a tool to redistribute DPCM samples into single banks, with sizes other than 4k*

Dn-FamiTracker now sorta, kinda supports this in a branch


