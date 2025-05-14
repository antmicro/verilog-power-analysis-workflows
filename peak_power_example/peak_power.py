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
import csv


def read_from_file(file_name: str):
    with open(file_name, 'r', encoding="utf8") as file:
        return file.readlines()


def search_for_total_power(report_power: list[str]):
    for line in report_power:
        if line.startswith('Total'):
            match = re.findall(r'\d*\.\d+(?:[eE][-+]?\d+)?', line)
            total_power = float(match[0]) + float(match[1]) + float(match[2])
            return total_power
        
    return 0


parser = argparse.ArgumentParser(
    allow_abbrev=False,
    formatter_class=argparse.RawDescriptionHelpFormatter,
    description="""""")
parser.add_argument('--base', action='store', help='Path to file with base power report')
parser.add_argument('--total', action='store', help='Path to directory with total report for each clock cycle from simulation')
parser.add_argument('--glitch', action='store', help='Path to directory with glitch report for each clock cycle from simulation')
parser.add_argument('--csv', action='store', help='Export results to a CSV file')
parser.set_defaults(stop=True)
args = parser.parse_args()

open_road_command = 'openroad'
open_road_script = 'power.tcl'
result_path = "result"
base_power_result_path = os.path.join(result_path, args.base)
total_power_result_directory = os.path.join(result_path, args.total)

if not os.path.exists(result_path):
    os.makedirs(result_path)

tcl_script = """
read_liberty $::env(LIB_DIR)/sky130_dummy_io.lib
read_liberty $::env(LIB_DIR)/sky130_fd_sc_hd__tt_025C_1v80.lib

read_db 5_route.odb

read_sdc 1_synth.sdc

"""

tcl_script += f"""

source {args.base}
set_pin_activity_and_duty
report_power > {base_power_result_path}

"""

if not os.path.exists(total_power_result_directory):
    os.makedirs(total_power_result_directory)

total_power_files = os.listdir(args.total)
total_power_files = sorted(total_power_files)

tcl_script += f"""
set all_total [glob -directory "{args.total}" -- "*"]
"""
tcl_script += """
foreach f $all_total {
    source "$f"
    set_pin_activity_and_duty
    report_power > "result/$f"
}
"""

if args.glitch:
    glitch_power_result_directory = os.path.join(result_path, args.glitch)
    if not os.path.exists(glitch_power_result_directory):
        os.makedirs(glitch_power_result_directory)

    tcl_script += f"""
set all_glitch [glob -directory "{args.glitch}" -- "*"]
"""
    tcl_script += """
foreach f $all_glitch {
    source "$f"
    set_pin_activity_and_duty
    report_power > "result/$f"
}
    """
    
with open(open_road_script, 'w') as file:
    file.write(tcl_script)

subprocess.run([open_road_command, "-exit", open_road_script], capture_output=True, text=True)

base_report_contents = read_from_file(base_power_result_path)
base_power = search_for_total_power(base_report_contents)

total_power_results = []
clock_cycles_indices = []

peak_power = 0
peak_power_clock_cycle = 0

total_power_result_files = os.listdir(total_power_result_directory)
total_power_result_files = sorted(total_power_result_files)

current_clock_cycle = 0
for file in total_power_result_files:
    clock_cycles_indices.append(current_clock_cycle)
    print(f'Processing clock cycle #{current_clock_cycle}')
    report_contents = read_from_file(os.path.join(total_power_result_directory, file))
    total_power = search_for_total_power(report_contents) - base_power
    if (total_power > peak_power):
        peak_power = total_power
        peak_power_clock_cycle = current_clock_cycle
    total_power_results.append(total_power)
    current_clock_cycle += 1

plt.plot(clock_cycles_indices, total_power_results, marker='o', linestyle='-', color='g')

if args.glitch:
    glitch_power_results = []

    glitch_power_result_files = os.listdir(glitch_power_result_directory)
    glitch_power_result_files = sorted(glitch_power_result_files)

    current_clock_cycle = 0
    for file in glitch_power_result_files:
        print(f'Processing clock cycle #{current_clock_cycle}')
        report_contents = read_from_file(os.path.join(glitch_power_result_directory, file))
        glitch_power = search_for_total_power(report_contents) - base_power
        glitch_power_results.append(glitch_power)
        current_clock_cycle += 1

    plt.plot(clock_cycles_indices, glitch_power_results, marker='o', linestyle='-', color='r')

plt.title("Power consumption over time")
plt.xlabel("Clock cycle")
plt.ylabel("Power consumption (Watts)")
plt.grid(True)

print(f"Maximum power consumption of a single clock cycle is {peak_power} Watts and occurred in clock cycle #{peak_power_clock_cycle}")

plt.savefig('report.png')

if args.csv:
    csv_filename = args.csv

    with open(csv_filename, mode="w", newline="") as file:
        writer = csv.writer(file)

        column_titles = ["Clock cycle index", "Total power"]

        if args.glitch:
            column_titles.append("Glitch power")
        
        writer.writerow(column_titles)
        
        if args.glitch:
            values = list(zip(clock_cycles_indices, total_power_results, glitch_power_results))
        else:
            values = list(zip(clock_cycles_indices, total_power_results))

        writer.writerows(values)