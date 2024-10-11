import math

NTSC_CPU_FREQUENCY_HZ = 1789773
PAL_CPU_FREQUENCY_HZ = 1662607
EPSM_S5B_FREQUENCY_HZ = 8000000

def midi_frequency(midi_index):
  """ https://en.wikipedia.org/wiki/MIDI_tuning_standard """
  return 440.0 * math.pow(2.0, (midi_index - 69) / 12)

def pulse_period(cpu_frequency, note_frequency):
  """ Approximate pulse period that produces the desired frequency

  Taken from https://wiki.nesdev.com/w/index.php/APU_Pulse
  16 comes from the length of the pulse sequence counter (8) 
  times two CPU cycles per one APU cycle (2)

  When used as the triangle period, whose sequence is 32 cycles
  long instead of 16, this results in a transposition of one
  octave.
  """
  desired_period = cpu_frequency / (16 * note_frequency) - 1
  integer_period = round(desired_period)
  clamped_period = min(max(integer_period, 0), 2047)
  return clamped_period

def vrc6_pulse_period(cpu_frequency, note_frequency):
  """ Approximate pulse period that produces the desired frequency

  VRC6 is calculated identically to 2A03 pulse, except it uses
  a 12-bit period timer. It can reliably reach the lower octave.

  Taken from https://www.nesdev.org/wiki/VRC6_audio#Pulse_Channels
  """
  desired_period = cpu_frequency / (16 * note_frequency) - 1
  integer_period = round(desired_period)
  clamped_period = min(max(integer_period, 0), 4095)
  return clamped_period

def vrc6_sawtooth_period(cpu_frequency, note_frequency):
  """ Approximate pulse period that produces the desired frequency

  VRC6 is calculated identically to 2A03 pulse, except it uses
  a 12-bit period timer. It can reliably reach the lower octave.

  Taken from https://www.nesdev.org/wiki/VRC6_audio#Pulse_Channels
  """
  desired_period = cpu_frequency / (14 * note_frequency) - 1
  integer_period = round(desired_period)
  clamped_period = min(max(integer_period, 0), 4095)
  return clamped_period

def s5b_pulse_period(cpu_frequency, note_frequency):
  """ Approximate pulse period that produces the desired frequency

  Unlike the 2A03 and VRC6 pulse channels' frequency formulas, the 
  formula for 5B does not add 1 to the period. 

  Note that the frequency formula here "should" use a 32 step period,
  but FamiTracker reuses the pulse table for VRC6, so it ends up sounding
  an octave off. We mimic that here for now.

  Taken from https://www.nesdev.org/wiki/Sunsoft_5B_audio
  """
  desired_period = cpu_frequency / (16 * note_frequency)
  integer_period = round(desired_period)
  clamped_period = min(max(integer_period, 0), 4095)
  return clamped_period

def s5b_epsm_pulse_period(note_frequency):
  """ Approximate pulse period that produces the desired frequency

  The EPSM operates on an 8 MHz clock, independent of the CPU clock
  speed. When driving "S5B" notes using our compatibility shim, it
  needs a separate tuning table. In theory the PAL version would use
  the same table, but no PAL equivalent device has been released.

  Taken from https://www.nesdev.org/wiki/Sunsoft_5B_audio
  """
  desired_period = EPSM_S5B_FREQUENCY_HZ / (32 * note_frequency)
  integer_period = round(desired_period)
  clamped_period = min(max(integer_period, 0), 4095)
  return clamped_period

def ca65_low_byte_literal(value):
  return "$%02x" % (value & 0xFF)

def ca65_high_byte_literal(value):
  return "$%02x" % ((value & 0xFF00) >> 8)

def pretty_print_table(table_name, ca65_byte_literals):
  """ Formats a list of byte strings, 8 per line

  Just for style purposes, I'd like to collapse the table so that 
  only 8 bytes are printed on each line. This is nicer than one 
  giant line or 128 individual .byte statements.
  """
  print("%s:" % table_name)
  for table_row in range(0, int(len(ca65_byte_literals) / 8)):
    row_text = ", ".join(ca65_byte_literals[table_row * 8 : table_row * 8 + 8])
    print("  .byte %s" % row_text)

# Put it all together and write it to stdout
def generate_pulse_lookup_table(base_frequency_hz, ca65_byte_converter):
  return [ca65_byte_converter(pulse_period(base_frequency_hz, midi_frequency(midi_index + 24 - 1))) for midi_index in range(0, 128)]
def generate_vrc6_pulse_lookup_table(base_frequency_hz, ca65_byte_converter):
  return [ca65_byte_converter(vrc6_pulse_period(base_frequency_hz, midi_frequency(midi_index + 24 - 1))) for midi_index in range(0, 128)]
def generate_vrc6_sawtooth_lookup_table(base_frequency_hz, ca65_byte_converter):
  return [ca65_byte_converter(vrc6_sawtooth_period(base_frequency_hz, midi_frequency(midi_index + 24 - 1))) for midi_index in range(0, 128)]
def generate_s5b_pulse_lookup_table(base_frequency_hz, ca65_byte_converter):
  return [ca65_byte_converter(s5b_pulse_period(base_frequency_hz, midi_frequency(midi_index + 24 - 1))) for midi_index in range(0, 128)]
def generate_s5b_epsm_pulse_lookup_table(ca65_byte_converter):
  return [ca65_byte_converter(s5b_epsm_pulse_period(midi_frequency(midi_index + 24 - 1))) for midi_index in range(0, 128)]

pretty_print_table("ntsc_period_low", generate_pulse_lookup_table(NTSC_CPU_FREQUENCY_HZ, ca65_low_byte_literal))
pretty_print_table("ntsc_period_high", generate_pulse_lookup_table(NTSC_CPU_FREQUENCY_HZ, ca65_high_byte_literal))
pretty_print_table("pal_period_low", generate_pulse_lookup_table(PAL_CPU_FREQUENCY_HZ, ca65_low_byte_literal))
pretty_print_table("pal_period_high", generate_pulse_lookup_table(PAL_CPU_FREQUENCY_HZ, ca65_high_byte_literal))

pretty_print_table("vrc6_pulse_period_low", generate_vrc6_pulse_lookup_table(NTSC_CPU_FREQUENCY_HZ, ca65_low_byte_literal))
pretty_print_table("vrc6_pulse_period_high", generate_vrc6_pulse_lookup_table(NTSC_CPU_FREQUENCY_HZ, ca65_high_byte_literal))
pretty_print_table("vrc6_sawtooth_period_low", generate_vrc6_sawtooth_lookup_table(NTSC_CPU_FREQUENCY_HZ, ca65_low_byte_literal))
pretty_print_table("vrc6_sawtooth_period_high", generate_vrc6_sawtooth_lookup_table(NTSC_CPU_FREQUENCY_HZ, ca65_high_byte_literal))

pretty_print_table("rainbow_pal_pulse_period_low", generate_vrc6_pulse_lookup_table(PAL_CPU_FREQUENCY_HZ, ca65_low_byte_literal))
pretty_print_table("rainbow_pal_pulse_period_high", generate_vrc6_pulse_lookup_table(PAL_CPU_FREQUENCY_HZ, ca65_high_byte_literal))
pretty_print_table("rainbow_pal_sawtooth_period_low", generate_vrc6_sawtooth_lookup_table(PAL_CPU_FREQUENCY_HZ, ca65_low_byte_literal))
pretty_print_table("rainbow_pal_sawtooth_period_high", generate_vrc6_sawtooth_lookup_table(PAL_CPU_FREQUENCY_HZ, ca65_high_byte_literal))

pretty_print_table("s5b_ntsc_period_low", generate_s5b_pulse_lookup_table(NTSC_CPU_FREQUENCY_HZ, ca65_low_byte_literal))
pretty_print_table("s5b_ntsc_period_high", generate_s5b_pulse_lookup_table(NTSC_CPU_FREQUENCY_HZ, ca65_high_byte_literal))
pretty_print_table("s5b_pal_period_low", generate_s5b_pulse_lookup_table(PAL_CPU_FREQUENCY_HZ, ca65_low_byte_literal))
pretty_print_table("s5b_pal_period_high", generate_s5b_pulse_lookup_table(PAL_CPU_FREQUENCY_HZ, ca65_high_byte_literal))
pretty_print_table("s5b_epsm_period_low", generate_s5b_epsm_pulse_lookup_table(ca65_low_byte_literal))
pretty_print_table("s5b_epsm_period_high", generate_s5b_epsm_pulse_lookup_table(ca65_high_byte_literal))