# Power analysis workflows

Copyright (c) 2025-2026 [Antmicro](https://www.antmicro.com)

Antmicro's demonstration of power analysis workflows with [Verilator](https://github.com/verilator/verilator), [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA) and [trace2power](https://github.com/antmicro/trace2power).

## Introduction

These workflows have been tested on Ubuntu 24.04 and Debian 12.

The following instructions demonstrate the power analysis workflows with Verilator and OpenSTA, using the `ibex` core as an example.

## Prerequisites

These instructions assume that all required projects are located in the same directory. Usually all commands from the snippets expect you to start executing them from the top directory.

The following projects need to be cloned and built:

- [Verilator](https://github.com/verilator/verilator) (tested on commit `38ae4e6`). It can be built by going into the project directory and executing these commands:

<!-- name="build-verilator" -->
```
cd ext/verilator

autoconf
./configure --prefix $(pwd)
make -j $(nproc)

export PATH=$PATH:$(pwd)/bin/
```

Remember to add the `~/dev/verilator/bin/` Verilator binary directory to the `PATH` environmental variable.

- [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) with `Yosys` and `OpenROAD` (tested on commit `0e196c8`). To build `Yosys` and `OpenROAD` in `OpenROAD-flow-scripts` run:

<!-- name="build-openroad" -->
```
cd ext/OpenROAD-flow-scripts

sudo ./tools/OpenROAD/etc/DependencyInstaller.sh -common
./build_openroad.sh -t $(nproc) --local

export PATH=$PATH:$(pwd)/tools/install/OpenROAD/bin/
```

- [trace2power](https://github.com/antmicro/trace2power) (tested on commit `9c2dc78`). To build it, you also need to have [rust](https://www.rust-lang.org/) installed:

<!-- name="build-trace-to-power" -->
```
cd ext/trace2power
cargo build --release

export PATH=$PATH:$(pwd)/target/release/
```

### Process model sources with Yosys and OpenROAD

For power consumption report generation you will need to prepare simulated model sources for `Yosys` synthesis and `OpenROAD` place and route steps in the `OpenROAD-flow-scripts` project directory. The example workflow uses the `asap7` platform. Copy the design contents from  the `example` directory to `OpenROAD-flow-scripts/flow/designs/asap7/ibex/` and `OpenROAD-flow-scripts/flow/designs/src/ibex`:

<!-- name="copy-model-sources" -->
```
mkdir -p ext/OpenROAD-flow-scripts/flow/designs/asap7/ibex/
cp example/design/* ext/OpenROAD-flow-scripts/flow/designs/asap7/ibex/

mkdir -p ext/OpenROAD-flow-scripts/flow/designs/src/ibex/
cp example/verilog/ibex_core/* ext/OpenROAD-flow-scripts/flow/designs/src/ibex/
```

Then go to the `OpenROAD-flow-scripts` project top directory and run the required synthesis and place and route steps:

<!-- name="run-synthesis-steps" -->
```
cd ext/OpenROAD-flow-scripts
make -C flow DESIGN_CONFIG=designs/asap7/ibex/config.mk route
```

Finally, copy the result of synthesis to the relevant example directory, i.e. from `~/dev/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/1_synth.v` to `example/verilog/ibex_core/ibex_core_synth.v`.

## Static power analysis workflow

### Generating SAIF files from trace

From the `example` directory, run verilation and compile the model to an executable with the SAIF trace flag enabled (`--trace-saif`) and then run a simulation with the generated binary:

<!-- name="generate-saif-file" -->
```
export CELL_SOURCES=$(pwd)/ext/asap7sc7p5t_28/Verilog/

cd example/
verilator --build --exe -f post_synthesis.vc --trace-saif --trace-structs --trace-params --trace-max-array 1024 \
    -CFLAGS "-std=c++14 -Wall -DVM_TRACE_FMT_SAIF -DTOPLEVEL_NAME=ibex_simple_system -g" \
    -LDFLAGS "-pthread -lutil -lelf" -Wno-fatal --unroll-count 72 --timing --timescale 1ns/10ps
timeout 5 ./out/Vibex_simple_system -t --meminit=ram,./hello_test/hello_test.elf || true
```

This will generate the `sim.saif` file in the current directory with the SAIF trace output.

### Generating a power consumption report

Copy the SAIF file previously generated from the simulation trace and the `power.tcl` commands file to the synthesis result directory:

<!-- name="copy-required-artifacts" -->
```
cp example/sim.saif ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp saif_example/power.tcl ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
```

For liberty files paths simplicity, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it will be:

<!-- name="export-liberty-path" -->
```
export LIB_DIR=$(pwd)/ext/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory and then run `openroad` with the following commands:

<!-- name="execute-openroad-commands" -->
```
cd ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
openroad power.tcl -exit
```

or you can just execute them manually after running `openroad` in the synthesis results directory:

```
read_liberty $::env(LIB_DIR)/asap7sc7p5t_AO_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_INVBUF_RVT_FF_nldm_220122.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_OA_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SIMPLE_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SEQ_RVT_FF_nldm_220123.lib

read_db 5_route.odb

read_sdc 1_synth.sdc

read_saif -scope TOP/ibex_simple_system/u_top/u_ibex_top/u_ibex_core sim.saif
report_power
```

This will generate a power consumption report that should look like this:

```
Annotated 212 pin activities.
Group                  Internal  Switching    Leakage      Total
                          Power      Power      Power      Power (Watts)
----------------------------------------------------------------
Sequential             4.06e+00   9.64e-02   9.49e-09   4.16e+00  43.9%
Combinational          8.64e-01   7.45e-01   3.43e-08   1.61e+00  17.0%
Clock                  2.65e+00   1.05e+00   1.92e-09   3.70e+00  39.1%
Macro                  0.00e+00   0.00e+00   0.00e+00   0.00e+00   0.0%
Pad                    0.00e+00   0.00e+00   0.00e+00   0.00e+00   0.0%
----------------------------------------------------------------
Total                  7.58e+00   1.89e+00   4.57e-08   9.47e+00 100.0%
                          80.1%      19.9%       0.0%
```

## Peak and glitch power analysis workflow

### Generating VCD files from trace

From the `example` directory, run verilation and compile the model to an executable with the trace flag enabled (`--trace`) and then run a simulation with the generated binary:

<!-- name="generate-vcd-file" -->
```
export CELL_SOURCES=$(pwd)/ext/asap7sc7p5t_28/Verilog/

cd example/
verilator --build --exe -f post_synthesis.vc --trace --trace-structs --trace-params --trace-max-array 1024 \
    -CFLAGS "-std=c++14 -Wall -DTOPLEVEL_NAME=ibex_simple_system -g" \
    -LDFLAGS "-pthread -lutil -lelf" -Wno-fatal --unroll-count 72 --timing --timescale 1ns/10ps
timeout 300 ./out/Vibex_simple_system -t --meminit=ram,./hello_test/hello_test.elf
status=$?
if [ "$status" -eq 124 ]; then
    echo "The simulation was interrupted because the time limit was exceeded."
fi
```

This will generate a `sim.vcd` file in the current directory with the VCD trace output.

### Processing VCD files to base per clock cycle power Tcl scripts

To generate base per clock cycle power Tcl scripts, which will be used to offset the generated total and peak power consumption reports, use `trace2power` to process the previously generated VCD file:

<!-- name="process-empty-vcd-output" -->
```
cd example/
trace2power --clk-freq 200000000 --top ibex_core --limit-scope TOP.ibex_simple_system.u_top.u_ibex_top.u_ibex_core --remove-virtual-pins --export-empty --output base_output sim.vcd
```

### Processing VCD files to per clock cycle total power Tcl scripts

To generate per clock cycle total power Tcl scripts, which will be used to generate power consumption reports, use `trace2power` to process the previously generated VCD file:

<!-- name="process-total-vcd-output" -->
```
cd example/
mkdir -p total_output
trace2power --clk-freq 200000000 --top ibex_core --limit-scope TOP.ibex_simple_system.u_top.u_ibex_top.u_ibex_core --remove-virtual-pins --per-clock-cycle --output total_output sim.vcd
```

### Generating a peak power report

Copy the previously generated Tcl files with the required scripts to the synthesis result directory:

<!-- name="copy-required-peak-power-artifacts" -->
```
cp -r example/total_output ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp example/base_output ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp peak_power_example/peak_power.py ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
```

For liberty files paths simplicity, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it will be:

<!-- name="export-liberty-path" -->
```
export LIB_DIR=$(pwd)/ext/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory and then run the peak power script:

<!-- name="execute-peak-power-script" -->
```
cd ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
python3 peak_power.py --base base_output --total total_output --csv power_analysis.csv
```

This will visualize power consumption over time and output maximum encountered value:

```
...
Processing clock cycle #220
Processing clock cycle #221
Processing clock cycle #222
Processing clock cycle #223
Processing clock cycle #224
Processing clock cycle #225
Processing clock cycle #226
Processing clock cycle #227
Processing clock cycle #228
Maximum power consumption of a single clock cycle is 9.210000047600001 Watts and occurred in clock cycle #180
```

### Processing VCD file to per clock cycle glitch power Tcl scripts

To generate per clock cycle glitch Tcl scripts, which will be used to generate power consumption reports, use `trace2power` to process previously generated VCD file:

<!-- name="process-glitch-vcd-output" -->
```
cd example/
mkdir -p glitch_output
trace2power --clk-freq 200000000 --top ibex_core --limit-scope TOP.ibex_simple_system.u_top.u_ibex_top.u_ibex_core --remove-virtual-pins --per-clock-cycle --only-glitches --clock-name clk_sys --output glitch_output sim.vcd
```

### Generating a peak power with glitches report

Copy the previously generated Tcl files with the required scripts to the synthesis result directory:

<!-- name="copy-required-glitch-power-artifacts" -->
```
cp -r example/total_output ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp -r example/glitch_output ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp example/base_output ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp peak_power_example/peak_power.py ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
```

For liberty files paths simplicity, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it will be:

<!-- name="export-liberty-path" -->
```
export LIB_DIR=$(pwd)/ext/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory and then run the glitch power script:

<!-- name="execute-glitch-power-script" -->
```
cd ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
python3 peak_power.py --base base_output --total total_output --glitch glitch_output --csv power_analysis.csv --cycles 75
```

This will visualize power consumption over time with per clock cycle total/glitch power and output the maximum encountered value:

```
...
Processing clock cycle #220
Processing clock cycle #221
Processing clock cycle #222
Processing clock cycle #223
Processing clock cycle #224
Processing clock cycle #225
Processing clock cycle #226
Processing clock cycle #227
Processing clock cycle #228
Maximum power consumption of a single clock cycle is 9.210000047600001 Watts and occurred in clock cycle #180
```

## Scoped power estimation workflow

Instead of reporting power for a whole design, `trace2power` can limit activity annotation to a single instance with `--limit-scope-power`, so `report_power` reflects only that instance's contribution. This is demonstrated by scoping the `ibex` example down to its `cs_registers_i` submodule.

### Processing model sources with Yosys and OpenROAD

Copy the design contents from the `example` directory to `OpenROAD-flow-scripts/flow/designs/asap7/ibex/` and `OpenROAD-flow-scripts/flow/designs/src/ibex`:

<!-- name="copy-model-sources" -->
```
mkdir -p ext/OpenROAD-flow-scripts/flow/designs/asap7/ibex/
cp example/design/* ext/OpenROAD-flow-scripts/flow/designs/asap7/ibex/

mkdir -p ext/OpenROAD-flow-scripts/flow/designs/src/ibex/
cp example/verilog/ibex_core/* ext/OpenROAD-flow-scripts/flow/designs/src/ibex/
```

Then go to the `OpenROAD-flow-scripts` project top directory and run the required synthesis and place and route steps:

<!-- name="run-synthesis-steps" -->
```
cd ext/OpenROAD-flow-scripts
make -C flow DESIGN_CONFIG=designs/asap7/ibex/config.mk route
```

Finally, copy the result of synthesis to the relevant example directory:

<!-- name="copy-synthesized-netlist-scoped" -->
```
cp ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/1_synth.v example/ibex_core_synth.v
```

### Generating a VCD file from trace

From the `example` directory, build the model to an executable with the VCD trace flags enabled and run a simulation with the generated binary:

<!-- name="generate-vcd-file-scoped" -->
```
export CELL_SOURCES=$(pwd)/ext/asap7sc7p5t_28/Verilog/

cd example/
verilator --build --exe -f post_synthesis.vc \
    --public-flat-rw --x-assign 0 --x-initial 0 --trace-underscore \
    --trace-vcd --trace-structs --trace-params --trace-max-array 1024 \
    -CFLAGS "-std=c++14 -Wall -DTOPLEVEL_NAME=ibex_simple_system" \
    -LDFLAGS "-pthread -lutil -lelf" --unroll-count 72 --timing --timescale 1ns/10ps \
    -Wno-MULTIDRIVEN -Wno-WIDTHEXPAND -Wno-SPECIFYIGN -Wno-WIDTHTRUNC -Wno-fatal \
    -Wno-UNOPTFLAT -Wno-PINMISSING \
    --build-jobs $(nproc)
timeout 300 ./out/Vibex_simple_system -t --meminit=ram,./hello_test/hello_test.elf
status=$?
if [ "$status" -eq 124 ]; then
    echo "The simulation was interrupted because the time limit was exceeded."
fi
```

This will generate a `sim.vcd` file in the current directory with the VCD trace output.

### Generating a scoped power consumption report

Use `trace2power` to process the generated VCD file, limiting power annotation to the `cs_registers_i` instance with `--limit-scope-power`:

<!-- name="generate-scoped-power-tcl" -->
```
cd example/
trace2power --clk-freq 200000000 \
    --limit-scope TOP.ibex_simple_system.u_top.u_ibex_top.u_ibex_core \
    --limit-scope-power TOP.ibex_simple_system.u_top.u_ibex_top.u_ibex_core.cs_registers_i \
    --input-ports-activity --output base_output.tcl sim.vcd
```

Copy the generated Tcl file to the synthesis result directory:

<!-- name="copy-scoped-power-artifacts" -->
```
cp example/base_output.tcl ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
```

To simplify the Liberty file paths, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it would be:

<!-- name="export-liberty-path" -->
```
export LIB_DIR=$(pwd)/ext/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory and then run `openroad` with the `openroad_commands` script, which reads the liberty files, the placed and routed design database (`5_route.odb`), and the scoped `base_output.tcl` activity, then reports power for the whole design (annotated only with `cs_registers_i`'s activity):

<!-- name="execute-scoped-openroad-commands" -->
```
export TEST_DIR=$(pwd)/example
cd ext/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
openroad $TEST_DIR/openroad_commands -exit
cat power_estimation.txt
```

This will generate a power consumption report in the same format as the static workflow above, but with internal/switching power reflecting only `cs_registers_i`'s annotated activity:

```
Group                  Internal  Switching    Leakage      Total
                          Power      Power      Power      Power (Watts)
----------------------------------------------------------------
Sequential             8.78e-02   1.26e-04   1.05e-07   8.79e-02  50.9%
Combinational          5.49e-03   4.62e-03   2.04e-06   1.01e-02   5.9%
Clock                  3.66e-02   3.79e-02   1.35e-08   7.45e-02  43.2%
Macro                  0.00e+00   0.00e+00   0.00e+00   0.00e+00   0.0%
Pad                    0.00e+00   0.00e+00   0.00e+00   0.00e+00   0.0%
----------------------------------------------------------------
Total                  1.30e-01   4.27e-02   2.16e-06   1.73e-01 100.0%
                          75.3%      24.7%       0.0%
```
