# Static power analysis workflow

Copyright (c) 2025 [Antmicro](https://www.antmicro.com)

Antmicro's demonstration of static power analysis workflow from SAIF trace file with [Verilator](https://github.com/verilator/verilator) and [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA).

## Introduction

This workflow was tested on Ubuntu 24.04 and Debian 12.

To demonstrate the workflow of static power analysis from SAIF trace file with Verilator and OpenSTA, we have prepared an [instruction](#workflow) and a simple [example](https://github.com/antmicro/verilator/tree/58f3d66076d5af8c2895f395a4a49deda075a580/examples/saif_example). This project contains a [CI job](https://github.com/antmicro/static-power-verilator-flow/blob/main/.github/workflows/static-power-analysis-flow.yml) which goes step by step through this instruction to generate a power consumption report

## Workflow

### Prerequisites

This example assumes that cloned repositories are located in the `~/dev` directory. You will need to clone and build these projects:

- [Verilator](https://github.com/antmicro/verilator) form the branch `saif`. You can build it with running these commands in the project directory

  ```
  autoconf
  ./configure --prefix $(pwd)
  make -j $(nproc)
  ```

  and then add the binary directory `~/dev/verilator/bin/` to the `PATH` environmental variable.

- [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA). For building instructions, you can refer to the project `README` file or this project [CI job](https://github.com/antmicro/static-power-verilator-flow/blob/18c62566615c45de1b8dc4134f8a752f7546d0a9/.github/workflows/static-power-analysis-flow.yml#L58). Keep in mind to add the directory where the `sta` binary is located to the `PATH` environmental variable.

- [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) with `Yosys`. To build `Yosys` in `OpenROAD-flow-scripts`, you will need to clone it's submodule with

  `git submodule update --init --recursive tools/yosys`

  then go to the `tools/yosys` directory and run

  `make -j $(nproc) PREFIX=~/dev/OpenROAD-flow-scripts/tools/install/yosys install`

### Generating SAIF file from trace

From the `examples/saif_example` directory in the `Verilator` project, run verilation and compile model to an executable with the SAIF trace flag enabled `--trace-saif`:

`verilator --cc --exe --build --trace-saif -j -Wno-latch gcd.v saif_trace.cpp`

Then run a model simulation with the generated binary

`./obj_dir/Vgcd`

This will generate the `simx.saif` file in the current directory with the SAIF trace output.

### Prepare model sources and run Yosys synthesis

For power consumption report generation you will need to prepare simulated model sources for `Yosys` synthesis in the `OpenROAD-flow-scripts` project directory. This example workflow uses the `asap7` platform. From the `examples/saif_example` directory in the `Verilator` project, copy `saif_trace_example` contents to `OpenROAD-flow-scripts/flow/designs/asap7/` and `src/saif_trace_example` to `OpenROAD-flow-scripts/flow/designs/src/`

```
cp -r saif_trace_example ~/dev/OpenROAD-flow-scripts/flow/designs/asap7/
cp -r src/saif_trace_example ~/dev/OpenROAD-flow-scripts/flow/designs/src/
```

Then go to the `OpenROAD-flow-scripts` project top directory and run the `Yosys` synthesis with

`make -C flow DESIGN_CONFIG=designs/asap7/saif_trace_example/config.mk synth`

Result of the synthesis will be located in the `~/dev/OpenROAD-flow-scripts/flow/results/asap7/saif_trace_example/base/` directory.

### Generating power consumption report

Copy previously generated SAIF file from trace to the synthesis result directory with

`cp ~/dev/verilator/examples/saif_example/simx.saif ~/dev/OpenROAD-flow-scripts/flow/results/asap7/saif_trace_example/base/`

For liberty files paths simplicity, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it will be

```
export LIB_DIR=~/dev/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory, run `sta` and then execute commands below

```
read_liberty $::env(LIB_DIR)/asap7sc7p5t_AO_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_INVBUF_RVT_FF_nldm_220122.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_OA_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SIMPLE_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SEQ_RVT_FF_nldm_220123.lib

read_verilog 1_synth.v
link_design gcd

read_sdc 1_synth.sdc

read_saif -scope gcd simx.saif
report_power
```

This will generate power consumption report that should look like this

```
Group                  Internal  Switching    Leakage      Total
                          Power      Power      Power      Power (Watts)
----------------------------------------------------------------
Sequential             5.19e-05   5.18e-06   5.34e-09   5.71e-05  43.5%
Combinational          4.15e-05   3.26e-05   2.17e-08   7.42e-05  56.5%
Clock                  0.00e+00   0.00e+00   0.00e+00   0.00e+00   0.0%
Macro                  0.00e+00   0.00e+00   0.00e+00   0.00e+00   0.0%
Pad                    0.00e+00   0.00e+00   0.00e+00   0.00e+00   0.0%
----------------------------------------------------------------
Total                  9.35e-05   3.78e-05   2.70e-08   1.31e-04 100.0%
                          71.2%      28.8%       0.0%
```