#!/usr/bin/env python3
import math, itertools, sys

NTSC_CPU_FREQUENCY_HZ = 1789773
PAL_CPU_FREQUENCY_HZ = 1662607

def midi_frequency(midi_index):
  """ https://en.wikipedia.org/wiki/MIDI_tuning_standard """
  return 440.0 * math.pow(2.0, (midi_index - 69) / 12)

def note_name(midi_index):
    letter_indices = ['C', 'Cs', 'D', 'Ds', 'E', 'F', 'Fs', 'G', 'Gs', 'A', 'As', 'B']
    letter = letter_indices[midi_index % 12]
    octave = str(int(midi_index / 12))
    return letter + octave

def cpu_cycles_needed(midi_frequency, base_frequency_hz):
  return base_frequency_hz / midi_frequency

dpcm_rate_cycles = [None] * 16
dpcm_rate_cycles[0x0] = 428
dpcm_rate_cycles[0x1] = 380
dpcm_rate_cycles[0x2] = 340
dpcm_rate_cycles[0x3] = 320
dpcm_rate_cycles[0x4] = 286
dpcm_rate_cycles[0x5] = 254
dpcm_rate_cycles[0x6] = 226
dpcm_rate_cycles[0x7] = 214
dpcm_rate_cycles[0x8] = 190
dpcm_rate_cycles[0x9] = 160
dpcm_rate_cycles[0xA] = 142
dpcm_rate_cycles[0xB] = 128
dpcm_rate_cycles[0xC] = 106
dpcm_rate_cycles[0xD] = 84
dpcm_rate_cycles[0xE] = 72
dpcm_rate_cycles[0xF] = 54

def total_cycles(dpcm_rate_sequence):
  total = 0
  for rate in dpcm_rate_sequence:
    total += dpcm_rate_cycles[rate]
  return total

def generate_pitch_table():
  pitch_table = []
  for eight in range(0, 300):
    for nine in range(0, 4):
      for a in range(0, 4):
        for b in range(0, 4):
          for c in range(0, 4):
            for d in range(0, 4):
              for e in range(0, 4):
                sequence = [
                  [0x8] * eight,
                  [0x9] * nine,
                  [0xA] * a,
                  [0xB] * b,
                  [0xC] * c,
                  [0xD] * d,
                  [0xE] * e
                ]
                sequence = sum(sequence, [])
                cycles = total_cycles(sequence)
                pitch_table.append({"sequence": sequence, "length": cycles})
  sorted_pitch_table = sorted(pitch_table, key=lambda i: i["length"])
  return sorted_pitch_table

def find_midi_sequences(first_index, last_index, pitch_table, base_frequency_hz):
  midi_sequences = []
  for midi_index in range(first_index, last_index):
    target_frequency = midi_frequency(midi_index)
    target_length = cpu_cycles_needed(midi_frequency(midi_index), base_frequency_hz)
    lower_pitches = [pitch for pitch in pitch_table if pitch["length"] <= target_length]
    higher_pitches = [pitch for pitch in pitch_table if pitch["length"] > target_length]
    lower_sequence = lower_pitches[-1]
    higher_sequence = higher_pitches[0]
    lower_sequence["error"] = abs((base_frequency_hz / lower_sequence["length"]) - target_frequency)
    higher_sequence["error"] = abs((base_frequency_hz / higher_sequence["length"]) - target_frequency)
    candidate_sequences = sorted([lower_sequence, higher_sequence], key=lambda i: i["error"])
    chosen_sequence = candidate_sequences[0]

    actual_frequency = base_frequency_hz / chosen_sequence["length"]
    midi_sequences.append({
      "midi_index": midi_index,
      "target_frequency": target_frequency,
      "actual_frequency": actual_frequency,
      "sequence": chosen_sequence})
  return midi_sequences

def rle(sequence):
  compressed_sequence = []
  count = 1
  current_item = sequence[0]
  for i in range(1, len(sequence)):
    candidate_item = sequence[i]
    if candidate_item == current_item and count < 255:
      count = count + 1
    else:
      compressed_sequence.append(count)
      compressed_sequence.append(current_item)
      count = 1
      current_item = candidate_item
  compressed_sequence.append(count)
  compressed_sequence.append(current_item)
  compressed_sequence.append(0) # end marker
  return compressed_sequence

def ca65_byte_literal(value):
  return "$%02x" % (value & 0xFF)

def ca65_word_literal(value):
  return "$%04x" % (value & 0xFFFF)

def ca65_comment(text):
    return f"; {text}"

def ca65_label(label_name):
    return f"{label_name}:"

def pretty_print_table(raw_bytes, output_file, width=8):
  """ Formats a byte array as a big block of ca65 literals

  Just for style purposes, I'd like to collapse the table so that 
  only so many bytes are printed on each line. This is nicer than one 
  giant line or tons of individual .byte statements.
  """
  formatted_bytes = [ca65_byte_literal(byte) for byte in raw_bytes]
  for table_row in range(0, int(len(formatted_bytes) / width)):
    row_text = ", ".join(formatted_bytes[table_row * width : table_row * width + width])
    print("  .byte %s" % row_text, file=output_file)

  final_row = formatted_bytes[int(len(formatted_bytes) / width) * width : ]
  if len(final_row) > 0:
    final_row_text = ", ".join(final_row)
    print("  .byte %s" % final_row_text, file=output_file)

if __name__ == '__main__':
    if len(sys.argv) != 2:
      print("Usage: blarggsaw_table.py output.asm")
      sys.exit(-1)
    output_filename = sys.argv[1]

    print("Generating pitch table...")
    pitch_table = generate_pitch_table()
    print("Finding ideal dpcm rate sequences for NTSC...")
    midi_sequences = find_midi_sequences(24, 84, pitch_table, 1789773)

    with open(output_filename, "w") as output_file:
      # generate the table of pointers
      print(ca65_label("blarggsaw_note_lists"), file=output_file)
      for midi_sequence in midi_sequences:
        print("  .word blarggsaw_note_period_%s" % midi_sequence["midi_index"], file=output_file)
      print("")
      for midi_sequence in midi_sequences:
        print(ca65_label("blarggsaw_note_period_%s" % midi_sequence["midi_index"]), file=output_file)
        print(ca65_comment("Note: %s, Target Frequency: %.2f, Actual Frequency: %.2f, Tuning Error: %.2f" % (
          note_name(midi_sequence["midi_index"]),
          midi_sequence["target_frequency"],
          midi_sequence["actual_frequency"],
          midi_sequence["sequence"]["error"]
        )), file=output_file)
        pretty_print_table(rle(midi_sequence["sequence"]["sequence"]), output_file)



