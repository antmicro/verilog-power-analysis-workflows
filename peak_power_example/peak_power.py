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

open_sta_command = 'sta'
open_sta_script = 'power.tcl'
input_trace_file = 'input_trace'
power_report_file = 'output_power'

files = os.listdir(args.input_dir)
files = sorted(files)

power_results = []
clock_cycles_indices = []

current_clock_cycle = 0
for file in files:
    clock_cycles_indices.append(current_clock_cycle)
    print(f'Processing clock cycle no. {current_clock_cycle}')
    current_clock_cycle += 1

    os.symlink(args.input_dir + "/" + file, input_trace_file)
    subprocess.run([open_sta_command, "-exit", open_sta_script], capture_output=False, text=True)
    report_contents = read_from_file(power_report_file)
    total_power = search_for_total_power(report_contents)
    power_results.append(total_power)
    os.remove(input_trace_file)

plt.plot(clock_cycles_indices, power_results, marker='o', linestyle='-', color='g')

plt.title("Power consumption over time")
plt.xlabel("Clock cycle")
plt.ylabel("Power consumption (Watts)")
plt.grid(True)

plt.savefig('report.png')