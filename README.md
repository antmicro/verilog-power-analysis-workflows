# Power analysis workflows

Copyright (c) 2025 [Antmicro](https://www.antmicro.com)

Antmicro's demonstration of power analysis workflows with [Verilator](https://github.com/verilator/verilator), [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA) and [trace2power](https://github.com/antmicro/trace2power).

## Introduction

These workflows have been tested on Ubuntu 24.04 and Debian 12.

To demonstrate workflows of power analysis with Verilator and OpenSTA, instructions below and a `ibex` example have been prepared.

## Prerequisites

These instructions assumes that all required projects are located in the same directory. Usually all commands from the snippets expect you to start executing them from the top directory.

The following projects need to be cloned and built:

- [Verilator](https://github.com/verilator/verilator) (tested on commit `d0c4cc39`). It can be built by going into the project directory and executing these commands:

<!-- name="build-verilator" -->
```
cd verilator

autoconf
./configure --prefix $(pwd)
make -j $(nproc)

export PATH=$PATH:$(pwd)/bin/
```

Remember to add the Verilator binary directory `~/dev/verilator/bin/` to the `PATH` environmental variable.

- [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) with `Yosys` and `OpenROAD` (tested on commit `f53fbce`). To build `Yosys` and `OpenROAD` in `OpenROAD-flow-scripts` run:

<!-- name="build-openroad" -->
```
cd OpenROAD-flow-scripts

git submodule update --init --recursive tools/yosys tools/OpenROAD
sudo ./tools/OpenROAD/etc/DependencyInstaller.sh -common
./build_openroad.sh -t $(nproc) --local

export PATH=$PATH:$(pwd)/tools/install/OpenROAD/bin/
```

- [trace2power](https://github.com/antmicro/trace2power/tree/72335-peak-power-analysis) from branch `74949-glitch-power` in case of peak and glitch power analysis. To build it, you also need to have [rust](https://www.rust-lang.org/) installed:

<!-- name="build-trace-to-power" -->
```
cd trace2power
cargo build --release

export PATH=$PATH:$(pwd)/target/release/
```

### Process model sources with Yosys and OpenROAD

For power consumption report generation you will need to prepare simulated model sources for `Yosys` synthesis and `OpenROAD` place and route step in the `OpenROAD-flow-scripts` project directory. Example workflows uses the `asap7` platform. Copy design contents from `example` directory to `OpenROAD-flow-scripts/flow/designs/asap7/ibex/` and `OpenROAD-flow-scripts/flow/designs/src/ibex`:

<!-- name="copy-model-sources" -->
```
mkdir -p OpenROAD-flow-scripts/flow/designs/asap7/ibex/
cp example/design/* OpenROAD-flow-scripts/flow/designs/asap7/ibex/

mkdir -p OpenROAD-flow-scripts/flow/designs/src/ibex/
cp example/verilog/ibex_core/* OpenROAD-flow-scripts/flow/designs/src/ibex/
```

Then go to the `OpenROAD-flow-scripts` project top directory and run the required synthesis, place and route steps:

<!-- name="run-synthesis-steps" -->
```
cd OpenROAD-flow-scripts
make -C flow DESIGN_CONFIG=designs/asap7/ibex/config.mk route
```

Finally copy the result of synthesis to relevant example directory, i.e. from `~/dev/OpenROAD-flow-scripts/flow/results/asap7/ibex/base/1_synth.v` to `example/verilog/ibex_core/ibex_core_synth.v`.

## Static power analysis workflow

### Generating SAIF file from trace

From the `example` directory, run verilation and compile the model to an executable with the SAIF trace flag enabled `--trace-saif` and then run a simulation with the generated binary:

<!-- name="generate-saif-file" -->
```
export CELL_SOURCES=$(pwd)/asap7sc7p5t_28/Verilog/

cd example/
verilator --build --exe -f post_synthesis.vc --trace-saif --trace-structs --trace-params --trace-max-array 1024 \
    -CFLAGS "-std=c++14 -Wall -DVM_TRACE_FMT_SAIF -DTOPLEVEL_NAME=ibex_simple_system -g" \
    -LDFLAGS "-pthread -lutil -lelf" -Wno-fatal --unroll-count 72 --timing --timescale 1ns/10ps
./out/Vibex_simple_system -t --meminit=ram,./hello_test/hello_test.elf
```

This will generate the `sim.saif` file in the current directory with the SAIF trace output.

### Generating power consumption report

Copy previously generated SAIF file from simulation trace and `power.tcl` commands file to the synthesis result directory:

<!-- name="copy-required-artifacts" -->
```
cp example/sim.saif OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp saif_example/power.tcl OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
```

For liberty files paths simplicity, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it will be:

<!-- name="export-liberty-path" -->
```
export LIB_DIR=$(pwd)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory and then run `openroad` with commands:

<!-- name="execute-openroad-commands" -->
```
cd OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
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

This will generate power consumption report that should look like this:

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

### Generating VCD file from trace

From the `example` directory, run verilation and compile the model to an executable with the trace flag enabled `--trace` and then run a simulation with the generated binary:

<!-- name="generate-vcd-file" -->
```
export CELL_SOURCES=$(pwd)/asap7sc7p5t_28/Verilog/

cd example/
verilator --build --exe -f post_synthesis.vc --trace --trace-structs --trace-params --trace-max-array 1024 \
    -CFLAGS "-std=c++14 -Wall -DTOPLEVEL_NAME=ibex_simple_system -g" \
    -LDFLAGS "-pthread -lutil -lelf" -Wno-fatal --unroll-count 72 --timing --timescale 1ns/10ps
./out/Vibex_simple_system -t --meminit=ram,./hello_test/hello_test.elf
```

This will generate the `sim.vcd` file in the current directory with the VCD trace output.

### Processing VCD file to base per clock cycle power TCL scripts

To generate base per clock cycle power TCL scripts, which will be used to offset generated total and peak power consumption reports, use `trace2power` to process previously generated VCD file:

<!-- name="process-empty-vcd-output" -->
```
cd example/
trace2power --clk-freq 200000000 --top ibex_core --limit-scope TOP.ibex_simple_system.u_top.u_ibex_top.u_ibex_core --remove-virtual-pins --export-empty --output base_output sim.vcd
```

### Processing VCD file to per clock cycle total power TCL scripts

To generate per clock cycle total power TCL scripts, which will be used to generate power consumption reports, use `trace2power` to process previously generated VCD file:

<!-- name="process-total-vcd-output" -->
```
cd example/
mkdir -p total_output
trace2power --clk-freq 200000000 --top ibex_core --limit-scope TOP.ibex_simple_system.u_top.u_ibex_top.u_ibex_core --remove-virtual-pins --per-clock-cycle --output total_output sim.vcd
```

### Generating peak power report

Copy previously generated TCL files with required scripts to the synthesis result directory:

<!-- name="copy-required-peak-power-artifacts" -->
```
cp -r example/total_output OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp example/base_output OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp peak_power_example/peak_power.py OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
```

For liberty files paths simplicity, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it will be:

<!-- name="export-liberty-path" -->
```
export LIB_DIR=$(pwd)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory and then run the peak power script:

<!-- name="execute-peak-power-script" -->
```
cd OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
python3 peak_power.py --base base_output --total total_output --csv power_analysis.csv --cycles 50
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

### Processing VCD file to per clock cycle glitch power TCL scripts

To generate per clock cycle glitch TCL scripts, which will be used to generate power consumption reports, use `trace2power` to process previously generated VCD file:

<!-- name="process-glitch-vcd-output" -->
```
cd example/
mkdir -p glitch_output
trace2power --clk-freq 200000000 --top ibex_core --limit-scope TOP.ibex_simple_system.u_top.u_ibex_top.u_ibex_core --remove-virtual-pins --per-clock-cycle --only-glitches --clock-name clk_sys --output glitch_output sim.vcd
```

### Generating peak power with glitches report

Copy previously generated TCL files with required scripts to the synthesis result directory:

<!-- name="copy-required-glitch-power-artifacts" -->
```
cp -r example/total_output OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp -r example/glitch_output OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp example/base_output OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
cp peak_power_example/peak_power.py OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
```

For liberty files paths simplicity, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it will be:

<!-- name="export-liberty-path" -->
```
export LIB_DIR=$(pwd)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory and then run the glitch power script:

<!-- name="execute-glitch-power-script" -->
```
cd OpenROAD-flow-scripts/flow/results/asap7/ibex/base/
python3 peak_power.py --base base_output --total total_output --glitch glitch_output --csv power_analysis.csv --cycles 50
```

This will visualize power consumption over time with per clock cycle total/glitch power and output maximum encountered value:

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