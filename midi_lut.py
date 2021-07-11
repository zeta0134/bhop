import math

ntsc_frequency_hz = 1789773
pal_frequency_hz = 1662607

def midi_frequency(midi_index):
  return 440.0 * math.pow(2.0, (midi_index - 69) / 12)

def pulse_period(cpu_frequency, note_frequency):
  return int(cpu_frequency / (16 * note_frequency) - 1)

# here we want a "low byte" and a "high byte" table, and we'd like
# the formatting to be pleasant

def ca65_low_byte(value):
  return "$%02x" % (value & 0xFF)

def ca65_high_byte(value):
  return "$%02x" % ((value & 0xFF00) >> 8)

def pretty_print_table(table_name, formatted_byte_array):
  print("%s:" % table_name)
  for table_row in range(0, int(len(formatted_byte_array) / 8)):
    row_text = ", ".join(formatted_byte_array[table_row * 8 : table_row * 8 + 8])
    print("  .byte %s" % row_text)

ntsc_low_byte_table = [ca65_low_byte(pulse_period(ntsc_frequency_hz, midi_frequency(midi_index))) for midi_index in range(0, 128)]
ntsc_high_byte_table = [ca65_low_byte(pulse_period(ntsc_frequency_hz, midi_frequency(midi_index))) for midi_index in range(0, 128)]

pal_low_byte_table = [ca65_low_byte(pulse_period(ntsc_frequency_hz, midi_frequency(midi_index))) for midi_index in range(0, 128)]
pal_high_byte_table = [ca65_low_byte(pulse_period(ntsc_frequency_hz, midi_frequency(midi_index))) for midi_index in range(0, 128)]

pretty_print_table("ntsc_period_low", ntsc_low_byte_table)
pretty_print_table("ntsc_period_high", ntsc_low_byte_table)
pretty_print_table("pal_period_low", ntsc_low_byte_table)
pretty_print_table("pal_period_high", ntsc_low_byte_table)
