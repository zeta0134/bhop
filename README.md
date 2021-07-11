# bhop

An exceptionally Work-In-Progress attempt to build a new music driver for NES / FamiCom, with eventual feature parity for FamiTracker projects. So new there isn't *any* code yet. This will be a brand new driver, built from scratch with the goal of eventually becoming a drop-in replacement for the original.

## Short-term Goals

- 1:1 feature parity with the official FamiTracker project (0.4.6+) and its more popular forks
- Ability to read exported song data from FamiTracker and play it back with no conversion step
- Full documentation, for ease of contributing
- Reasonably fast performance
- Reasonably small code size
- Support for all 6 FamiCom expansion chips in wide use by chiptuners

## Long-term Goals

- Variants for NSF and Game Engine playback, possibly with feature removal to save on code size / execution time
- Support for new and upcoming homebrew sound chips
- Support for bank switching on mappers other than NSF / iNes31

## Non-Goals

- Bug-for-bug compatability with old FamiTracker versions
- Unusually small ROM sizes; this driver will probably be a little bit chonky. (For a more flexibly tiny music driver check out [Pently](https://github.com/pinobatch/pently)!)
- Support for other 6502 systems

