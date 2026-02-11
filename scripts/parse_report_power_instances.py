#!/usr/bin/python

import sys

if len(sys.argv) < 2:
    raise RuntimeError("requires file name to parse")

internal_power = 0
switching_power = 0
leakage_power = 0
total_power = 0
for file in sys.argv[1:]:
    with open(file) as f:
        skip = True
        for line in f.readlines():
            if not skip:
                splitted = line.split()
                internal_power += float(splitted[0])
                switching_power += float(splitted[1])
                leakage_power += float(splitted[2])
                total_power += float(splitted[3])
            if "--------------------------------------------" in line:
                skip = False

    
print("Internal Power")
print("{0:.2E}".format(internal_power))
print("Switching Power")
print("{0:.2E}".format(switching_power))
print("Leakage Power")
print("{0:.2E}".format(leakage_power))
print("Total Power")
print("{0:.2E}".format(total_power))
