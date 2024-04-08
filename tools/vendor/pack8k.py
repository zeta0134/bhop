#!/usr/bin/env python3
"""
ROM bank packer for ca65 

Copyright 2022, 2023 Retrotainment Games

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""
"""What this does:

1. read all MEMORY areas in the linker configuration, looking for
   those with start >= $8000 and start + size <= $2000 (that is,
   those that can be switched into $8000 on an MMC3 or FME-7)
2. add up the sizes of R8_ segments as well as segments already
   in those banks
3. try to fit R8_ segments in the free space, using a first fit
   decreasing algorithm
4. write out the SEGMENT entries
"""
import os, sys, re, argparse, subprocess, bisect
from collections import defaultdict

# Loading linker script #############################################

# this is copied from freebytes.py

lsmajorblocksRE = re.compile(r"""([a-zA-Z]+)\s*\{(.*?)\}""")

def ld65parseint(intval):
    if intval.startswith("$"): return int(intval[1:], 16)
    return int(intval, 10)

def parse_nvpset(nvpset):
    nvpset = [nv.split("=", 1) for nv in nvpset.split(",")]
    nvpset = {k.strip().lower(): v.strip() for k, v in nvpset}
    return nvpset

def parse_lsstatements(contents):
    segs = [line.strip() for line in contents.split(";")]
    segs = [line.split(":", 1) for line in segs if line]
    segs = [(k.strip(), parse_nvpset(v)) for k, v in segs]
    return segs

def ld65_load_linker_script(linkscriptname):
    with open(linkscriptname, "r", encoding="utf-8") as infp:
        lscontents = [line.split("#", 1)[0].split() for line in infp]
    lscontents = " ".join(word for line in lscontents for word in line)
    lscontents = {
        k.upper(): parse_lsstatements(v)
        for k, v in lsmajorblocksRE.findall(lscontents)
    }

    memstartsize = {
        k: (ld65parseint(v["start"]), ld65parseint(v["size"]))
        for k, v in lscontents["MEMORY"]
    }
    segtomem = {k: v["load"] for k, v in lscontents["SEGMENTS"]}
    return lscontents, memstartsize, segtomem

# Measuring segments ################################################

def get_segsizes(filenames):
    """Get the size and alignment of each segment in an object file.

filenames -- an iterable of paths to ca65 object files

Return a list [(filename, [(segment name, size, alignment), ...]), ...]
"""
    # Since 2021-10-09, Ubuntu and Debian oldstable have Python 3.6+
    # Ubuntu 18.04 "bionic" has 3.6 and Debian 10 "buster" has 3.7
    # subprocess.run exists since 3.5 so I can rely on it
    args = ["od65", "--dump-segments"]
    args.extend(filenames)
    compl = subprocess.run(args, capture_output=True, encoding="utf-8")
    filename, filename_order, out = None, [], {}
    for line in compl.stdout.splitlines():
        line = line.rstrip()
        if not line.startswith(" "):
            # new object file
            if not line.endswith(":"):
                raise ValueError("unexpected column 1 line " + line)
            filename = line[:-1]
            if filename in out:
                raise ValueError("duplicate object file " + filename)
            filename_order.append(filename)
            out[filename] = []
            continue
        words = [x.strip() for x in line.split(":")]
        if len(words) != 2:
            raise ValueError("not exactly 1 colon in " + line)
        if words[0] in ('Segments', 'Count'): continue
        if words[0] == 'Index':
            out[filename].append([None, 0, 1])
            continue
        thisseg = out[filename][-1]
        if words[0] == 'Name':
            thisseg[0] = words[1].strip('"')
        elif words[0] == 'Size':
            thisseg[1] = int(words[1])
        elif words[0] == 'Alignment':
            thisseg[2] = int(words[1])

    # Remove segments that never got a size
    out = [
        (filename, [(n, s, a) for n, s, a in out[filename] if s > 0])
        for filename in filename_order
    ]
    return out

# The packer ########################################################

test_prefixes = None # ("TERRAIN", "ACTOR")

def pack_segs(seg_sizes, prefix, bank_sizes, static_segs,
              verbose=False):
    """
seg_sizes -- an iterable ((segname, size, align), ...);
    sizes are summed per segment name
prefix -- segment sizes
bank_sizes -- an iterable ((bankname, size), ...) or a mapping
    {bankname: size, ...} giving how big each packable bank is;
    each bank name must occur only once
static_segs -- mapping from static segment names to bank names

Segments whose name starts with the prefix are added to a list of
pack requests.  Segments whose name is in static_segs reduce the
free space in the corresponding bank.
"""
    bank_sizes = dict(bank_sizes)
    segs_to_pack = {}

    # Remove statically allocated segments from their banks'
    # free space; total pack requests
    segwanted = defaultdict(int)
    for segname, sizeadd, align in seg_sizes:
        # DEBUG: use TERRAIN and ACTOR banks for testing here
        if (test_prefixes and segname in static_segs
            and segname.startswith(test_prefixes)):
            segname = prefix + segname

        if align & (align - 1):
            print("%s: non-power-of_two alignment not supported")

        if segname in static_segs:
            sz = bank_sizes[static_segs[segname]]
            bank_sizes[static_segs[segname]] = sz - sz % align - sizeadd
        elif segname.startswith(prefix):
            sz = segwanted[segname]
            segwanted[segname] = sz - (-sz % align) + sizeadd

    # Fit decreasing: sort wanted segments into increaing order
    # then pop off the largest each time
    segwanted = sorted(segwanted.items(), key=lambda x: x[1])

    # Using best fit decreasing for conservatism during port
    # bisect.* functions don't add key= until Python 3.10
    bank_sizes = [(sz, bankname) for bankname, sz in bank_sizes.items()]
    bank_sizes.sort()
    assignments = []
    if verbose:
        print("Bank sizes at start:", bank_sizes, file=sys.stderr)

    while segwanted:
        # largest segment left to fit
        wanted_seg, wanted_size = segwanted.pop()
        # find and remove the best fit bank
        i = bisect.bisect_left(bank_sizes, (wanted_size, ''))
        if i >= len(bank_sizes):
            total_bank_left = sum(x[0] for x in bank_sizes)
            total_seg_left = wanted_size + sum(x[1] for x in segwanted)
            print("pack8k.py: error: %d banks totaling %d bytes are free\n"
                  "pack8k.py: error: %d segments totaling %d bytes remain unpacked\n"
                  % (len(bank_sizes), total_bank_left,
                     len(segwanted) + 1, total_seg_left), file=sys.stderr)
            if verbose:
                print("bank size space remain", bank_sizes, file=sys.stderr)
            raise IndexError("no bank with %d bytes free" % wanted_size)
        found_size, found_bank = bank_sizes.pop(i)
        if verbose:
            print("%s (%d) in %s (%d)"
                  % (wanted_seg, wanted_size, found_bank, found_size),
                  file=sys.stderr)
        # reinsert the bank without this item
        if found_size > wanted_size:
            bisect.insort_left(bank_sizes, (found_size - wanted_size, found_bank))
        assignments.append((wanted_seg, found_bank, wanted_size))

    bank_sizes = [(bankname, sz) for sz, bankname in bank_sizes]
    return assignments, bank_sizes

def parse_argv(argv):
    p = argparse.ArgumentParser(
        description="Packs ROM segments into 8 KiB banks."
    )
    p.add_argument("module", nargs="+",
                   help="object files included in program")
    p.add_argument("-C", "--config",
                   help="linker config file template "
                   "(must include #pack8k in SEGMENTS)")
    p.add_argument("-P", "--prefix", default="R8_",
                   help="prefix of names of segments to pack (default: R8_)")
    p.add_argument("-o", "--output", default="-",
                   help="output linker config file (default: - for stdout)")
    p.add_argument("-v", "--verbose", action="store_true",
                   help="show work")
    return p.parse_args(argv[1:])

def main(argv=None):
    args = parse_argv(argv or sys.argv)
    
    szs = get_segsizes(args.module)
    szs = [seg_size for filename, filesegs in szs for seg_size in filesegs]
    _, mem, segtomem = ld65_load_linker_script(args.config)
    bank_sizes = {
        bankname: size
        for bankname, (start, size) in mem.items()
        if start >= 0x8000 and start + size <= 0xA000
    }
    static_segs = {
        segname: bankname
        for segname, bankname in segtomem.items()
        if bankname in bank_sizes
    }
    result = pack_segs(szs, args.prefix, bank_sizes, static_segs,
                       verbose=args.verbose)
    assignments, bank_sizes = result

    out, added = [], False
    with open(args.config, "r", encoding="utf-8") as infp:
        for line in infp:
            if line.strip() != '#pack8k':
                out.append(line)
                continue
            out.append("# Begin addition by pack8k.py\n")
            out.extend(
                "%s: load=%s, type=ro, optional=yes;\n" % (segname, bankname)
                for segname, bankname, _ in assignments
            )
            out.append("# End addition by pack8k.py\n")
            added = True
    if not added:
        print("%s: no line #pack8k" % args.config)
        sys.exit(1)

    if args.output == '-':
        sys.stdout.writelines(out)
    else:
        with open(args.output, "w", encoding="utf-8") as outfp:
            outfp.writelines(out)

if __name__=='__main__':
    if 'idlelib' in sys.modules:
        filenames = """
bg main pads ppuclear init mmc3 player
""".split()
        argv = """
./pack8k.py -v -C ../mmc3_4mbit.cfg -o ../mmc3_4mbit_packed.cfg -P R8_
""".split()
        argv.extend("../obj/nes/%s.o" % f for f in filenames)
        main(argv)
    else:
        main()
