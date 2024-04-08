#!/usr/bin/env python3
# ld65 .cfg automatic bank allocator for bhop demos
# Persune 2024
# licensed under the Apache License, Version 2.0
#
# a modification of pack8k.py 
# Copyright 2022, 2023 Retrotainment Games
# pack8k is licensed under the Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

VERSION = "0.0.0"

import argparse, subprocess, sys
import pack8k

def parse_argv(argv):
    parser=argparse.ArgumentParser(
        description="ld65 .cfg automatic bank allocator for bhop demos",
        epilog="version " + VERSION)

    parser.add_argument(
        "mapper",
        choices=[
            "nsf"
        ],
        help="mapper type")

    parser.add_argument(
        "out_cfg",
        type=str,
        help="output .cfg file")

    parser.add_argument(
        "in_cfg",
        type=str,
        help="input .cfg file")

    parser.add_argument(
        "obj_files",
        type=str,
        nargs="*",
        help="object files to analyze")

    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="enable verbose messages")
    return parser.parse_args(argv[1:])


def main(argv=None):
    args = parse_argv(argv or sys.argv)

    def segment_pack(addr_start, addr_end, seg_prefix, bank_max_size, banks_start, banks_end, doubling=False, align_dpcm=False):

        seg_assignments = {}
        seg_mem_area = {}
        mult = 2 if doubling else 1

        # first pass: generate fresh memory areas and see which ones get allocated
        for bank in range(banks_start ,banks_end):
            new_bank_name = "PRG_%02X"%(bank*mult)
            if not new_bank_name in mem:
                # print("creating %s..."%new_bank_name)
                mem[new_bank_name] = (addr_start, bank_max_size) # bankname: (start, size)
                seg_mem_area[new_bank_name] = (addr_start, bank_max_size, bank*mult)

        seg_bank_sizes = {
            bankname: size
            for bankname, (start, size) in mem.items()
            if start >= addr_start and start + size <= addr_end
        }

        seg_static_segs = {
            segname: bankname
            for segname, bankname in segtomem.items()
            if bankname in seg_bank_sizes
        }

        seg_assignments, seg_bank_sizes = pack8k.pack_segs(szs, seg_prefix, seg_bank_sizes, seg_static_segs, verbose=args.verbose)

        # clear unused memory areas
        for bankname, _ in seg_mem_area.copy().items():
            if bankname not in list({b:(a,c) for a,b,c in seg_assignments}):
                # print("deleting %s..."%bankname)
                del mem[bankname]
                del seg_mem_area[bankname]

        # second pass: we finally pruned the unneccessary memory areas and segment allocations
        seg_bank_sizes = {
            bankname: size
            for bankname, (start, size) in mem.items()
            if start >= addr_start and start + size <= addr_end
        }

        seg_static_segs = {
            segname: bankname
            for segname, bankname in segtomem.items()
            if bankname in seg_bank_sizes
        }

        seg_assignments, seg_bank_sizes = pack8k.pack_segs(szs, seg_prefix, seg_bank_sizes, seg_static_segs, verbose=args.verbose)
        seg_assignments = [list(tup)+[align_dpcm] for tup in seg_assignments]
        
        return seg_assignments, seg_mem_area

    if args.mapper == "nsf":
        # bank configuration:
        # $8000-$9FFF: 8K fixed bank
        # $A000-$BFFF: 8K bankswitched music data
        # $C000-$DFFF: 8K bankswitched sample data
        # $E000-$FFFF: 8K fixed bank (for TNS-HFC compatibility)
        # to simplify things, we treat two adjacent 4K banks as a singular 8K bank
        bank_count = 128
        bank_max_size = 0x2000
        reserve_banks_start = 2
        reserve_banks_end = 0
        mus_addr_start = 0xA000
        mus_addr_end = 0xC000
        dmc_addr_start = 0xC000
        dmc_addr_end = 0xE000
        double_count = True
    else:
        # TODO: also do this for the other demos
        sys.exit("unknown mapper configuration")

    szs = pack8k.get_segsizes(args.obj_files)
    szs = [seg_size for filename, filesegs in szs for seg_size in filesegs] # segname, sizeadd, align
    _, mem, segtomem = pack8k.ld65_load_linker_script(args.in_cfg)

    mus_assignments, mus_mem_area = segment_pack(mus_addr_start, mus_addr_end, "MUSIC", bank_max_size, reserve_banks_start, bank_count-reserve_banks_end, double_count)
    dmc_assignments, dmc_mem_area = segment_pack(dmc_addr_start, dmc_addr_end, "DPCM", bank_max_size, reserve_banks_start, bank_count-reserve_banks_end, double_count, align_dpcm=True)

    assignments = list(mus_assignments) + list(dmc_assignments)
    mem_area = mus_mem_area | dmc_mem_area

    out, addedseg, addedmem = [], False, False
    with open(args.in_cfg, "r", encoding="utf-8") as infp:
        for line in infp:
            if line.strip() == '#arrmem':
                out.append("    # Begin arranged memory by doctor_fill.py\n")
                out.extend(
                   # PRG_DC:            start = $C000, size = $2000, type = ro, file = %O, fill = yes, fillval = $FF, bank = $DC;
                    "    %s:            start = $%04X, size = $%04X, type = ro, file = %%O, fill = yes, fillval = $FF, bank=$%02X;\n" % (memname, start, size, bank)
                    for memname, (start, size, bank) in mem_area.items()
                )
                out.append("    # End arranged memory by doctor_fill.py\n")
                addedmem = True
                continue
            elif line.strip() == '#arrseg':
                out.append("    # Begin arranged segments by doctor_fill.py\n")
                out.extend(

             # DPCM_1:     load = PRG_84,              type = ro, align=64;
                    "    %-11s load = %s,              type=ro%s;\n" % (segname+":", bankname, ", align=64" if align_dpcm else "")
                    for segname, bankname, _, align_dpcm in assignments
                )
                out.append("    # End arranged segments by doctor_fill.py\n")
                addedseg = True
                continue
            else:
                out.append(line)
    if not addedmem:
        sys.exit("%s: no line #arrmem" % args.in_cfg)
    if not addedseg:
        sys.exit("%s: no line #arrseg" % args.in_cfg)

    with open(args.out_cfg, "w", encoding="utf-8") as outfp:
        outfp.writelines(out)

if __name__=='__main__':
    main(sys.argv)
