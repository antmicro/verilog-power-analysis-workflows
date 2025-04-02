#!/usr/bin/env python3

# Copyright 2025 Antmicro
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

import argparse
import re
import subprocess
import os
import matplotlib.pyplot as plt


def read_from_file(file_name: str):
    with open(file_name, 'r', encoding="utf8") as file:
        return file.readlines()


def search_for_total_power(report_power: list[str]):
    for line in report_power:
        match = re.match(r'Total\s+(([\w\.\-]+\s+)+)', line)
        if match:
            total_power = match.group(2).replace(' ', '')
            return float(total_power)
        
    return 0


parser = argparse.ArgumentParser(
    allow_abbrev=False,
    formatter_class=argparse.RawDescriptionHelpFormatter,
    description="""""")
parser.add_argument('--input_dir', action='store', help='Path to directory with trace report for each clock cycle from simulation')
parser.set_defaults(stop=True)
args = parser.parse_args()

open_road_command = 'openroad'
open_road_script = 'power.tcl'
result_directory = 'result'

files = os.listdir(args.input_dir)
files = sorted(files)

tcl_script = """
read_liberty $::env(LIB_DIR)/asap7sc7p5t_AO_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_INVBUF_RVT_FF_nldm_220122.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_OA_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SIMPLE_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SEQ_RVT_FF_nldm_220123.lib

read_db 6_final.odb

read_sdc 1_synth.sdc
"""

for file in files:
    tcl_script += f"""
source {args.input_dir + file}
set_pin_activity_and_duty
report_power > result/{file}
"""
    
with open(open_road_script, 'w') as file:
    file.write(tcl_script)

subprocess.run([open_road_command, "-exit", open_road_script], capture_output=True, text=True)

power_results = []
clock_cycles_indices = []

peak_power = 0
peak_power_clock_cycle = 0

result_files = os.listdir(result_directory)
result_files = sorted(result_files)

current_clock_cycle = 0
for file in result_files:
    clock_cycles_indices.append(current_clock_cycle)
    print(f'Processing clock cycle #{current_clock_cycle}')
    report_contents = read_from_file(result_directory + "/" + file)
    total_power = search_for_total_power(report_contents)
    if (total_power > peak_power):
        peak_power = total_power
        peak_power_clock_cycle = current_clock_cycle
    power_results.append(total_power)
    current_clock_cycle += 1

plt.plot(clock_cycles_indices, power_results, marker='o', linestyle='-', color='g')

plt.title("Power consumption over time")
plt.xlabel("Clock cycle")
plt.ylabel("Power consumption (Watts)")
plt.grid(True)

print(f"Maximum power consumption of a single clock cycle is {peak_power} Watts and occurred in clock cycle #{peak_power_clock_cycle}")

plt.savefig('report.png')