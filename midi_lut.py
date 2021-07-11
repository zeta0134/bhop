import math

NTSC_CPU_FREQUENCY_HZ = 1789773
PAL_CPU_FREQUENCY_HZ = 1662607

# https://en.wikipedia.org/wiki/MIDI_tuning_standard
def midi_frequency(midi_index):
  return 440.0 * math.pow(2.0, (midi_index - 69) / 12)

# Taken from https://wiki.nesdev.com/w/index.php/APU_Pulse
# 16 comes from the length of the pulse sequence counter (8) 
#   times two CPU cycles per one APU cycle (2)
# When used as the triangle period, whose sequence is 32 cycles
#   long instead of 16, this results in a transposition of one
#   octave.
def pulse_period(cpu_frequency, note_frequency):
  return int(cpu_frequency / (16 * note_frequency) - 1)

# Formatters for ca65 byte literals
def ca65_low_byte(value):
  return "$%02x" % (value & 0xFF)

def ca65_high_byte(value):
  return "$%02x" % ((value & 0xFF00) >> 8)

# Just for style purposes, I'd like to collapse the table so that 
#   only 8 bytes are printed on each line. This is nicer than one 
#   giant line or 128 individual .byte statements.
def pretty_print_table(table_name, ca65_byte_literals):
  print("%s:" % table_name)
  for table_row in range(0, int(len(ca65_byte_literals) / 8)):
    row_text = ", ".join(ca65_byte_literals[table_row * 8 : table_row * 8 + 8])
    print("  .byte %s" % row_text)

# Put it all together and write it to stdout
def generate_lookup_table(base_frequency_hz, ca65_byte_converter):
  return [ca65_byte_converter(pulse_period(base_frequency_hz, midi_frequency(midi_index))) for midi_index in range(0, 128)]

pretty_print_table("ntsc_period_low", generate_lookup_table(NTSC_CPU_FREQUENCY_HZ, ca65_low_byte))
pretty_print_table("ntsc_period_high", generate_lookup_table(NTSC_CPU_FREQUENCY_HZ, ca65_high_byte))
pretty_print_table("pal_period_low", generate_lookup_table(PAL_CPU_FREQUENCY_HZ, ca65_low_byte))
pretty_print_table("pal_period_high", generate_lookup_table(PAL_CPU_FREQUENCY_HZ, ca65_high_byte))