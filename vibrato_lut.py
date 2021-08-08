import math

VIBRATO_DEPTH = [1.0, 1.5, 2.5, 4.0, 5.0, 7.0, 10.0, 12.0, 14.0, 17.0, 22.0, 30.0, 44.0, 64.0, 96.0, 128.0]

# valid index ranges from 0-63
# valid depth ranges from 1-15
def vibrato_offset(index, depth):
  return math.floor(math.sin(2 * math.pi * (index / 64.0)) * VIBRATO_DEPTH[depth])

def ca65_byte_literal(value):
  return "$%02x" % (value & 0xFF)

def pretty_print_table(ca65_byte_literals):
  """ Formats a list of byte strings, 16 per line

  Just for style purposes, I'd like to collapse the table so that 
  only 16 bytes are printed on each line. This is nicer than one 
  giant line or 128 individual .byte statements.
  """
  for table_row in range(0, int(len(ca65_byte_literals) / 16)):
    row_text = ", ".join(ca65_byte_literals[table_row * 16 : table_row * 16 + 16])
    print("  .byte %s" % row_text)

def generate_lookup_table(depth, ca65_byte_converter):
  return [ca65_byte_converter(vibrato_offset(index, depth)) for index in range(0, 16)]

print("%s:" % "vibrato_lut")
for depth in range(0, 16):
  pretty_print_table(generate_lookup_table(depth, ca65_byte_literal))
