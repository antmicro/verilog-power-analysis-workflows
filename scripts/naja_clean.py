#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12,<3.14"
# dependencies = ["najaeda==0.4.0", "PyYAML==6.0.3"]
# ///

# From https://github.com/The-OpenROAD-Project/megaboom/blame/a275df8109fb00fa51f8185dfd31dca5402606e7/naja_clean.py#L1

# BSD 3-Clause License
# 
# Copyright (c) 2023, The OpenROAD Project
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import argparse
from os import path
import sys
import logging
from najaeda import netlist
import yaml

logging.basicConfig(level=logging.INFO)

parser = argparse.ArgumentParser(description="Clean netlist using NAJAEDA")
parser.add_argument("--libs", type=str, nargs="+", required=True, help="library files")
parser.add_argument("--vars", type=str, help="YAML file with variables")
parser.add_argument("--output", type=str, help="Output cleaned netlist file")
parser.add_argument(
    "dirty_netlists", nargs="+", type=str, help="Input dirty netlist files"
)

args = parser.parse_args()

vars_files = args.vars
cleaned_netlist = args.output
dirty_netlists = args.dirty_netlists

with open(vars_files, "r") as f:
    vars = yaml.safe_load(f)

lib_files = vars["LIB_FILES"].split(" ") + args.libs

# naja will read lib.gz files in the future, for now...
ungzipped_libs = []
for lib_file in lib_files:
    if lib_file.endswith(".gz"):
        import gzip
        import shutil

        ungzipped_file = lib_file[:-3]
        with gzip.open(lib_file, "rb") as f_in:
            with open(ungzipped_file, "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)
        ungzipped_libs.append(ungzipped_file)
    else:
        ungzipped_libs.append(lib_file)
lib_files = ungzipped_libs

print(lib_files)
netlist.load_liberty(lib_files)
top = netlist.load_verilog(dirty_netlists)
netlist.apply_constant_propagation()
netlist.apply_dle()
top.dump_verilog(cleaned_netlist)

