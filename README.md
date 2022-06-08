# bhop

A Work-In-Progress attempt to build a new music driver for NES / FamiCom, with eventual feature parity for FamiTracker projects. This will be a brand new driver, built from scratch with the goal of eventually becoming a drop-in replacement for the original. Right now it is complete enough to play many modules, but is still lacking several effects, hi-pitch envelopes, and all expansion audio channels.

There is a live demo here: https://rusticnes.reploid.cafe/wasm/?cartridge=bhop.nes
(Use the arrow keys to change tracks. Also check out the [Jam] tab to peek at what the audio channels are doing.)

# Project Status

## Implemented
- Bytecode reading, basic module playback, NTSC configuration
- Volume, Arpeggio, Pitch, and Duty envelopes
- Effects: `0xy`, `1xx`, `2xx`, `3xx`, `4xy`, `700`, `Axy`, `Bxx`, `Fxx`, `Gxx`, `Pxx`, `Qxy`, `Rxy`, `Sxx`, `Yxx`, `Zxx`
- Register pitch mode
- DPCM Sample playback, with rudimentary bank switching support

## Notable Missing features
- All other effects
- Hi-pitch column
- PAL configuration
- Linear pitch mode
- Grooves
- SFX

# Goals

## Short-term

- 1:1 feature parity with the official FamiTracker project (0.4.6+) and its more popular forks
- Ability to read exported song data from FamiTracker and play it back with minimal / no conversion step
- Full documentation, for ease of contributing
- Reasonably fast performance
- Reasonably small code size
- Support for all 6 FamiCom expansion chips in wide use by chiptuners
- Support for bank switching on mappers other than NSF / iNes31

## Long-term

- Variants for NSF and Game Engine playback, possibly with feature removal to save on code size / execution time
- Support for the prototype EPSM expansion audio module, sporting a YMF288
- Support for other new and upcoming homebrew sound chips

## Non-Goals

- Bug-for-bug compatability with old FamiTracker versions
- Unusually small ROM sizes; this driver will probably be a little bit chonky. (For a more flexibly tiny music driver check out [Pently](https://github.com/pinobatch/pently)!)
- Support for other 6502 systems
- At this time, support for assembler suites other than cc65

# Usage Notes

So you'd like to hear my project mangle your music in its current state? That's great! I'm here to help.

## Quickstart guide

First off, export your music using the Dn-FamiTracker UI. Select "Assembly Source" as the format. It defaults to "music.asm" so let's stick with that.

Add the following files to your project structure, and make sure `bhop.s` is set to be compiled and linked by your project:
```
bhop/
|- bhop.inc
|- bhop_internal.inc
|- commands.asm
|- config.inc
|- effects.asm
|- longbranch.inc
|- midi_lut.inc
|- vibrato_lut.inc
|- word_util.inc
bhop.s
music.asm
```

Somewhere in your project, import your music data. Make sure it all fits in memory at once. Export the label, so bhop knows where to find it:
```
bhop_music_data:
  .include "music.asm"
  .export bhop_music_data
```

Double-check `bhop/config.inc` and look over the segment names and other settings. Tweak as required.

To initialize the player and select a song:
```
.include "bhop/bhop.inc"

; ...

lda #[some track number] ; track numbers start at 0
jsr bhop_init
```

You can call this again at any point in in the future to change tracks. (New tracks always start at the beginning for now.)

Finally, about once per frame, call the update routine. Usually you'll want to do this at the end of NMI, but every project is different:
```
nmi:
  ; perform OAM DMA, do PPU activity, etc
  jsr bhop_play
  ; do anything else that isn't timing sensitive
  rti
```

If your project uses banking, make sure both the music player and the page containing `bhop_music_data` are swapped in before calling `bhop_init` or `bhop_play`. Once these routines exit, both may be paged out as needed. Only DPCM samples need to remain banked in throughout playback.

## Sound Effects

The music engine does not include any handling of SFX data. If your game engine needs to play a sound effect, channels may be temporarily muted by their index number:

```
lda #0
jsr bhop_mute_channel ; suppress the first pulse channel. Clobbers a, x, and y
```

After this call, bhop will continue to update this channel in the background, but immediately ceases any and all register writes. Once your SFX is done playing, you can unmute the channel the same way:

```
lda #0
jsr bhop_unmute_channel ; hand control of the first pulse back to bhop. Clobbers a, x, and y
```

This will resume updating the channel immediately, typically continuing whichever note was interrupted, or silencing the channel if there is a rest in the music.
Note that channel suppressions are reset when `bhop_init` is called to switch tracks.

## DPCM Banking

If your project's mapper supports banking the region from $C000 onwards, then you can have bhop automatically switch that bank out on the fly. With some effort, this enables using more than 16kB of DPCM samples during music playback.

Right now there's not an especially ideal way to export DPCM bank allocations, so if you have a lot of samples, expect to tweak some of the data by hand. If you're working with a standard Dn-FamiTracker export, the data looks like this:

```
; DPCM samples list (location, size, bank)
ft_samples:
  .byte 0, 18, 0
  .byte 5, 7, 1
  .byte 7, 15, 2
```

I like to rework this data to reference the sample label instead, so that ca65 will fill in the bank number and offset, like this:

```
; DPCM samples list (location, size, bank)
ft_samples:
  .byte <((ft_sample_0  - $C000) >> 6),  53, <.bank(ft_sample_0)
  .byte <((ft_sample_1  - $C000) >> 6),  59, <.bank(ft_sample_1)
  .byte <((ft_sample_2  - $C000) >> 6),  130, <.bank(ft_sample_2)
```

Once your data is prepared, in `bhop/config.inc` set BHOP_DPCM_BANKING is set to 1, and the procedure name provided works for your project. Tweak to taste:
```
BHOP_DPCM_BANKING = 1
```

Finally, anywhere in your project, fill out the banking function and export it so bhop can see it. The desired DPCM bank will be in the `a` register. For example, here's the function I use to switch out the 8k bank at $C000 on an MMC3, running in PRG Mode 1:

```
; project global
MMC3_BANKING_MODE = %01000000

.proc bhop_apply_dpcm_bank
        pha ; preserve the incoming bank number in a
        lda #(MMC3_BANKING_MODE + $6)
        sta MMC3_BANK_SELECT
        pla ; restore the bank number
        sta MMC3_BANK_DATA
        rts
.endproc
.export bhop_apply_dpcm_bank
```

## Notes

FamiTracker, and thus bhop, assume that DPCM samples are indexed relative to 0xC000. FamiTracker forks *other* than Dn-FamiTracker tend to assume an NSF configuration is in use, and may use an inconvenient bank size; I've seen 12k banks in use, which NSF permits but most standard game mappers do not. If you're using a lot of samples, do double-check the `.asm` output, especially the `ft_samples` table. You will probably need to massage the export data somewhat manually.

Typically you'll call `jsr bhop_play` once per frame for a 60 Hz tick rate on NTSC, or a 50 Hz tick rate on PAL. If you want to use a different engine speed, you'll need to handle the timing yourself and call `bhop_play` at the appropriate rate. Engine speeds faster than 120 Hz are highly impractical for gameplay, and engine speeds much higher than 240 Hz start to become impractical on real NES hardware, though many NSF players can handle this just fine.

There is no need to use just one `music.asm` file. The only requirement is that the start of this data be located at a fixed location in memory. You can easily include several locations on different PRG banks, or even copy the data into RAM if you've got the headroom. This can help to work around music size limitations, especially if you start to run out of instruments on a large project. Make sure to call `bhop_init` every time you switch modules or tracks, especially when banking in new data. If `bhop_play` is ever called with the wrong music data loaded, it can get stuck playing invalid bytecode. This will certainly sound unpleasant, and may crash the program.

There is no stop function; if you need to stop playback, include a silent song in your export data.

Enjoy at your own peril!

(These notes are likely to become out of date quickly, and if nothing else, I'd like to simplify these steps once the project is more stable.)
