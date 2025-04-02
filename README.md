# Power analysis workflows

Copyright (c) 2025 [Antmicro](https://www.antmicro.com)

Antmicro's demonstration of power analysis workflows with [Verilator](https://github.com/verilator/verilator), [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA) and [trace2power](https://github.com/antmicro/trace2power).

## Introduction

These workflows have been tested on Ubuntu 24.04 and Debian 12.

To demonstrate workflows of power analysis with Verilator and OpenSTA, instructions below and a simple `gcd` example have been prepared.

## Prerequisites

These instructions assumes that all required projects are located in the same directory. Usually all commands from the snippets expect you to start executing them from the top directory.

The following projects need to be cloned and built:

- [Verilator](https://github.com/verilator/verilator). It can be built by going into the project directory and executing these commands:

<!-- name="build-verilator" -->
```
cd verilator

autoconf
./configure --prefix $(pwd)
make -j $(nproc)

export PATH=$PATH:$(pwd)/bin/
```

Remember to add the Verilator binary directory `~/dev/verilator/bin/` to the `PATH` environmental variable.

- [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) with `Yosys` and `OpenROAD`. To build `Yosys` and `OpenROAD` in `OpenROAD-flow-scripts` run:

<!-- name="build-openroad" -->
```
cd OpenROAD-flow-scripts

git submodule update --init --recursive tools/yosys tools/OpenROAD
./tools/OpenROAD/etc/DependencyInstaller.sh -common
./build_openroad.sh -t $(nproc) --local

export PATH=$PATH:$(pwd)/tools/install/OpenROAD/bin/
```

- [trace2power](https://github.com/antmicro/trace2power/tree/72335-peak-power-analysis) from branch `72335-peak-power-analysis` in case of peak power analysis. To build it, you also need to have [rust](https://www.rust-lang.org/) installed:

<!-- name="build-trace-to-power" -->
```
cd trace2power
cargo build --release

export PATH=$PATH:$(pwd)/target/release/
```

- [asap7sc7p5t_28](https://github.com/The-OpenROAD-Project/asap7sc7p5t_28) sources.

### Process model sources with Yosys and OpenROAD

For power consumption report generation you will need to prepare simulated model sources for `Yosys` synthesis and `OpenROAD` place and route step in the `OpenROAD-flow-scripts` project directory. Example workflows uses the `asap7` platform. From the `design` directory, copy `gcd_example` contents to `OpenROAD-flow-scripts/flow/designs/asap7/` and `src/gcd_example` to `OpenROAD-flow-scripts/flow/designs/src/`

<!-- name="copy-model-sources" -->
```
cp -r design/gcd_example OpenROAD-flow-scripts/flow/designs/asap7/
cp -r design/src/gcd_example OpenROAD-flow-scripts/flow/designs/src/
```

Then go to the `OpenROAD-flow-scripts` project top directory and run the `Yosys` synthesis:

<!-- name="run-yosys-synthesis" -->
```
cd OpenROAD-flow-scripts
make -C flow DESIGN_CONFIG=designs/asap7/gcd_example/config.mk synth
```

After that you can run place and route step:

<!-- name="run-place-and-route" -->
```
cd OpenROAD-flow-scripts
make -C flow DESIGN_CONFIG=designs/asap7/gcd_example/config.mk route
```

Finally copy the result of synthesis to relevant example directory, i.e. from `~/dev/OpenROAD-flow-scripts/flow/results/asap7/gcd_example/base/1_synth.v` to `saif_example/gcd.v`.

## Static power analysis workflow

### Generating SAIF file from trace

From the `saif_example` directory, run verilation and compile the model to an executable with the SAIF trace flag enabled `--trace-saif` and then run a simulation with the generated binary:

<!-- name="generate-saif-file" -->
```
export MODEL_SOURCES=$(pwd)/asap7sc7p5t_28/Verilog

cd saif_example/
verilator --cc --exe --build --trace-saif -j -Wno-fatal -timescale 1ns/1ps -I$MODEL_SOURCES gcd.v asap7sc7p5t_SIMPLE_RVT_TT_201020.v asap7sc7p5t_INVBUF_RVT_TT_201020.v asap7sc7p5t_AO_RVT_TT_201020.v asap7sc7p5t_OA_RVT_TT_201020.v asap7sc7p5t_SEQ_RVT_TT_220101.v saif_trace.cpp
./obj_dir/Vgcd
```

This will generate the `simx.saif` file in the current directory with the SAIF trace output.

### Generating power consumption report

Copy previously generated SAIF file from simulation trace and `power.tcl` commands file to the synthesis result directory:

<!-- name="copy-required-artifacts" -->
```
cp saif_example/simx.saif OpenROAD-flow-scripts/flow/results/asap7/gcd_example/base/
cp saif_example/power.tcl OpenROAD-flow-scripts/flow/results/asap7/gcd_example/base/
```

For liberty files paths simplicity, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it will be:

<!-- name="export-liberty-path" -->
```
export LIB_DIR=$(pwd)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory and then run `openroad` with commands:

<!-- name="execute-openroad-commands" -->
```
cd OpenROAD-flow-scripts/flow/results/asap7/gcd_example/base/
openroad power.tcl -exit
```

or you can just execute them manually after running `openroad` in the synthesis results directory:

```
read_liberty $::env(LIB_DIR)/asap7sc7p5t_AO_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_INVBUF_RVT_FF_nldm_220122.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_OA_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SIMPLE_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SEQ_RVT_FF_nldm_220123.lib

read_verilog 6_final.odb

read_sdc 1_synth.sdc

read_saif -scope gcd_tb/gcd simx.saif
report_power
```

This will generate power consumption report that should look like this:

```
Annotated 159 pin activities.
Group                  Internal  Switching    Leakage      Total
                          Power      Power      Power      Power (Watts)
----------------------------------------------------------------
Sequential             1.34e-05   9.00e-07   7.15e-09   1.43e-05  32.9%
Combinational          1.38e-05   1.02e-05   2.66e-08   2.40e-05  55.2%
Clock                  2.43e-06   2.76e-06   4.02e-10   5.19e-06  11.9%
Macro                  0.00e+00   0.00e+00   0.00e+00   0.00e+00   0.0%
Pad                    0.00e+00   0.00e+00   0.00e+00   0.00e+00   0.0%
----------------------------------------------------------------
Total                  2.96e-05   1.39e-05   3.41e-08   4.35e-05 100.0%
                          68.0%      31.9%       0.1%
```

## Peak power analysis workflow

### Generating VCD file from trace

From the `peak_power_example` directory, run verilation and compile the model to an executable with the trace flag enabled `--trace` and then run a simulation with the generated binary:

<!-- name="generate-vcd-file" -->
```
export MODEL_SOURCES=$(pwd)/asap7sc7p5t_28/Verilog

cd peak_power_example/
verilator --cc --exe --build --trace -j -Wno-fatal -timescale 1ns/1ps -I$MODEL_SOURCES gcd.v asap7sc7p5t_SIMPLE_RVT_TT_201020.v asap7sc7p5t_INVBUF_RVT_TT_201020.v asap7sc7p5t_AO_RVT_TT_201020.v asap7sc7p5t_OA_RVT_TT_201020.v asap7sc7p5t_SEQ_RVT_TT_220101.v vcd_trace.cpp
./obj_dir/Vgcd
```

This will generate the `simx.vcd` file in the current directory with the VCD trace output.

### Processing VCD file to per clock cycle TCL scripts

To generate per clock cycle TCL scripts, which will be used to generate power consumption reports, use `trace2power` to process previously generated VCD file:

<!-- name="process-vcd-output" -->
```
cd peak_power_example/
mkdir -p output
trace2power --clk-freq 200000000 --top gcd --limit-scope gcd_tb.gcd --remove-virtual-pins --per-clock-cycle --output output simx.vcd
```

### Generating peak power report

Copy previously generated TCL files with required scripts to the synthesis result directory:

<!-- name="copy-required-peak-power-artifacts" -->
```
cp -r peak_power_example/output OpenROAD-flow-scripts/flow/results/asap7/gcd_example/base/
cp peak_power_example/peak_power.py OpenROAD-flow-scripts/flow/results/asap7/gcd_example/base/
cp peak_power_example/power.tcl OpenROAD-flow-scripts/flow/results/asap7/gcd_example/base/
```

For liberty files paths simplicity, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it will be:

<!-- name="export-liberty-path" -->
```
export LIB_DIR=$(pwd)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory and then run the peak power script:

<!-- name="execute-peak-power-script" -->
```
cd OpenROAD-flow-scripts/flow/results/asap7/gcd_example/base/
python3 peak_power.py --input_dir output
```

This will visualize power consumption over time and output maximum encountered value:

```
...
Processing clock cycle #23
Processing clock cycle #24
Processing clock cycle #25
Processing clock cycle #26
Processing clock cycle #27
Processing clock cycle #28
Processing clock cycle #29
Maximum power consumption of a single clock cycle is 0.000205 Watts and occurred in clock cycle #0
```
