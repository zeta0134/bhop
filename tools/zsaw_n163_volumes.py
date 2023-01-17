#!/usr/bin/env python3
import math

N163_RELATIVE_MIX_DB = 2.18 # against APU pulse at loudest volume

def amplitude_from_db(db):
  return pow(10.0, db / 20.0)

def db_from_amplitude(amplitude):
  return 20.0 * math.log(abs(amplitude), 10)

def dpcm_amplitude(pcm_level):
  if pcm_level == 0:
    return 0.0
  return 159.79 / ((1.0 / (pcm_level / 22638.0)) + 100.0)

def pulse_amplitude(volume_level):
  if volume_level == 0:
    return 0.0
  return 95.88 / ((8128.0 / (volume_level)) + 100.0)

def n163_amplitude(volume_level):
  n163_loudest_volume = pulse_amplitude(15) * amplitude_from_db(N163_RELATIVE_MIX_DB)
  return volume_level * n163_loudest_volume / 15.0;


max_pulse_db = db_from_amplitude(pulse_amplitude(15))

test_results = [
  {"name": "pulse_0x4       ", "result": db_from_amplitude(pulse_amplitude(4))},
  {"name": "pulse_0x8       ", "result": db_from_amplitude(pulse_amplitude(8))},
  {"name": "pulse_0xC       ", "result": db_from_amplitude(pulse_amplitude(12))},
  {"name": "pulse_0xF (base)", "result": db_from_amplitude(pulse_amplitude(15))},

  {"name": "dmc_00_10", "result": db_from_amplitude(dpcm_amplitude(0x10) - dpcm_amplitude(0x00))},
  {"name": "dmc_00_20", "result": db_from_amplitude(dpcm_amplitude(0x20) - dpcm_amplitude(0x00))},
  {"name": "dmc_00_30", "result": db_from_amplitude(dpcm_amplitude(0x30) - dpcm_amplitude(0x00))},
  {"name": "dmc_00_40", "result": db_from_amplitude(dpcm_amplitude(0x40) - dpcm_amplitude(0x00))},
  {"name": "dmc_00_50", "result": db_from_amplitude(dpcm_amplitude(0x50) - dpcm_amplitude(0x00))},
  {"name": "dmc_00_60", "result": db_from_amplitude(dpcm_amplitude(0x60) - dpcm_amplitude(0x00))},
  {"name": "dmc_00_70", "result": db_from_amplitude(dpcm_amplitude(0x70) - dpcm_amplitude(0x00))},
  {"name": "dmc_00_7F", "result": db_from_amplitude(dpcm_amplitude(0x7F) - dpcm_amplitude(0x00))},

  {"name": "dmc_7F_70", "result": db_from_amplitude(dpcm_amplitude(0x70) - dpcm_amplitude(0x7F))},
  {"name": "dmc_7F_60", "result": db_from_amplitude(dpcm_amplitude(0x60) - dpcm_amplitude(0x7F))},
  {"name": "dmc_7F_50", "result": db_from_amplitude(dpcm_amplitude(0x50) - dpcm_amplitude(0x7F))},
  {"name": "dmc_7F_40", "result": db_from_amplitude(dpcm_amplitude(0x40) - dpcm_amplitude(0x7F))},
  {"name": "dmc_7F_30", "result": db_from_amplitude(dpcm_amplitude(0x30) - dpcm_amplitude(0x7F))},
  {"name": "dmc_7F_20", "result": db_from_amplitude(dpcm_amplitude(0x20) - dpcm_amplitude(0x7F))},
  {"name": "dmc_7F_10", "result": db_from_amplitude(dpcm_amplitude(0x10) - dpcm_amplitude(0x7F))},
  {"name": "dmc_7F_00", "result": db_from_amplitude(dpcm_amplitude(0x00) - dpcm_amplitude(0x7F))},
]

print("Max pulse db, for comparison: ", max_pulse_db)

for test_result in test_results:
  print(test_result["name"], ":", max_pulse_db - test_result["result"])
