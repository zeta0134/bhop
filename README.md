# bhop

An exceptionally Work-In-Progress attempt to build a new music driver for NES / FamiCom, with eventual feature parity for FamiTracker projects. This will be a brand new driver, built from scratch with the goal of eventually becoming a drop-in replacement for the original. Right now it is complete enough to play many modules, but is still lacking most of the Effects column.

# Project Status

## Implemented
- Bytecode reading, basic module playback, NTSC timing
- Volume, Arpeggio, Pitch, and Duty envelopes
- Effects: `Bxx`
- Register pitch mode

## Notable Missing features
- All other effects
- Hi-pitch column
- PAL timings
- Linear pitch mode
- Grooves

# Goals

## Short-term

- 1:1 feature parity with the official FamiTracker project (0.4.6+) and its more popular forks
- Ability to read exported song data from FamiTracker and play it back with no conversion step
- Full documentation, for ease of contributing
- Reasonably fast performance
- Reasonably small code size
- Support for all 6 FamiCom expansion chips in wide use by chiptuners

## Long-term

- Variants for NSF and Game Engine playback, possibly with feature removal to save on code size / execution time
- Support for new and upcoming homebrew sound chips
- Support for bank switching on mappers other than NSF / iNes31

## Non-Goals

- Bug-for-bug compatability with old FamiTracker versions
- Unusually small ROM sizes; this driver will probably be a little bit chonky. (For a more flexibly tiny music driver check out [Pently](https://github.com/pinobatch/pently)!)
- Support for other 6502 systems

# Usage Notes

If you'd like to hear the project mangle your music in its current state, that's great! I'm here to help. Use the latest cc65 suite, and make sure your assembler is set up to compile all the `.s` files in /prg, and they can access the requisite `.inc` files on path, etc. You'll need every file _except_ `main.s`, which runs the testing harness for this repository.

In `bhop.inc` locate the value for `MUSIC_BASE` and adjust accordingly. Make sure you `.incbin` your exported `music.asm` file at presicely this location; it can be anywhere in ROM or RAM, but the whole of `music.asm` needs to be paged in at once. If your project uses DPCM samples, place those starting at 0xC000; this is hard-coded for the moment. You'll either need a configured segment named DPCM, or you'll need to edit the segment name in "music.asm" so that the sample data ends up in the right place.

Set the song index you want to play in `a` then `jsr bhop_init` to get things ready. In your update function, call `jsr bhop_play` once per frame. If you want to use a different engine speed, you'll need to handle the timing yourself and call `bhop_play` at the appropriate rate. Mind that engine speeds much faster than 120 Hz are highly impractical, and likely to cause lag.

There is no stop function, and testing also suggests that `bhop_init` is bugged, and may not clear the state properly. My apologies, it's _on the TODO list._ Enjoy at your own peril!

(These notes are likely to become out of date quickly, and if nothing else, I'd like to simplify these steps once the project is more stable.)
