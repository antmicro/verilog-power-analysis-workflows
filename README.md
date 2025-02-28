# Static power analysis workflow

Copyright (c) 2025 [Antmicro](https://www.antmicro.com)

Antmicro's demonstration of static power analysis workflow from SAIF trace files with [Verilator](https://github.com/verilator/verilator) and [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA).

## Introduction

This workflow has been tested on Ubuntu 24.04 and Debian 12.

To demonstrate the workflow of static power analysis from SAIF trace files with Verilator and OpenSTA, an [instruction](#workflow) and a simple [example](https://github.com/antmicro/verilator/tree/58f3d66076d5af8c2895f395a4a49deda075a580/examples/saif_example) have been prepared.

## Workflow

### Prerequisites

This instruction assumes that all required projects are located in the same directory. Usually all commands from the snippets expect you to start executing them from the top directory.

The following projects need to be cloned and built:

- [Verilator](https://github.com/antmicro/verilator) (`saif` branch). It can be built by going into the project directory and executing these commands:

<!-- name="build-verilator" -->
```
cd verilator

autoconf
./configure --prefix $(pwd)
make -j $(nproc)

export PATH=$PATH:$(pwd)/bin/
```

Remember to add the Verilator binary directory `~/dev/verilator/bin/` to the `PATH` environmental variable.

- [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA). This dependency requires the [CUDD](https://github.com/davidkebo/cudd) project. Clone the project and then build it by executing:

<!-- name="build-cudd" -->
```
cd cudd/cudd_versions

tar xvfz cudd-3.0.0.tar.gz
cd cudd-3.0.0

./configure --prefix $(pwd)
make -j $(nproc) install

export CUDD_INSTALL_DIR=$(pwd)
```

After that, OpenSTA can be built by executing the following commands from the top directory:

<!-- name="build-open-sta" -->
```
cd OpenSTA

mkdir build && cd build
cmake -DCUDD_DIR=$CUDD_INSTALL_DIR ../
make -j $(nproc)

cd ..
export PATH=$PATH:$(pwd)/app/
```

Keep in mind to add the directory where the `sta` binary is located to the `PATH` environmental variable.

- [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts) with `Yosys`. To build `Yosys` in `OpenROAD-flow-scripts`, you will also need to clone its submodule:

<!-- name="build-yosys" -->
```
cd OpenROAD-flow-scripts

git submodule update --init --recursive tools/yosys
cd tools/yosys
make -j $(nproc) PREFIX=../install/yosys install
```

### Generating SAIF file from trace

From the `examples/saif_example` directory in the `Verilator` project, run verilation and compile the model to an executable with the SAIF trace flag enabled `--trace-saif` and then run a simulation with the generated binary:

<!-- name="generate-saif-file" -->
```
cp -r saif_example verilator/examples/
cd verilator/examples/saif_example/
verilator --cc --exe --build --trace-saif -j -Wno-latch gcd.v saif_trace.cpp
./obj_dir/Vgcd
```

This will generate the `simx.saif` file in the current directory with the SAIF trace output.

### Prepare model sources and run Yosys synthesis

For power consumption report generation you will need to prepare simulated model sources for `Yosys` synthesis in the `OpenROAD-flow-scripts` project directory. This example workflow uses the `asap7` platform. From the `examples/saif_example` directory in the `Verilator` project, copy `saif_trace_example` contents to `OpenROAD-flow-scripts/flow/designs/asap7/` and `src/saif_trace_example` to `OpenROAD-flow-scripts/flow/designs/src/`

<!-- name="copy-model-sources" -->
```
cp -r verilator/examples/saif_example/saif_trace_example OpenROAD-flow-scripts/flow/designs/asap7/
cp -r verilator/examples/saif_example/src/saif_trace_example OpenROAD-flow-scripts/flow/designs/src/
```

Then go to the `OpenROAD-flow-scripts` project top directory and run the `Yosys` synthesis:

<!-- name="run-yosys-synthesis" -->
```
cd OpenROAD-flow-scripts
make -C flow DESIGN_CONFIG=designs/asap7/saif_trace_example/config.mk synth
```

Result of the synthesis will be located in the `~/dev/OpenROAD-flow-scripts/flow/results/asap7/saif_trace_example/base/` directory.

### Generating power consumption report

Copy previously generated SAIF file from simulation trace and `sta` commands file to the synthesis result directory:

<!-- name="copy-required-artifacts" -->
```
cp verilator/examples/saif_example/simx.saif OpenROAD-flow-scripts/flow/results/asap7/saif_trace_example/base/
cp verilator/examples/saif_example/sta_commands OpenROAD-flow-scripts/flow/results/asap7/saif_trace_example/base/
```

For liberty files paths simplicity, you can export the path to their directory as the `LIB_DIR` environmental variable. In this example it will be:

<!-- name="export-liberty-path" -->
```
export LIB_DIR=$(pwd)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/
```

Go to the synthesis results directory and then run `sta` with commands:

<!-- name="execute-sta-commands" -->
```
cd OpenROAD-flow-scripts/flow/results/asap7/saif_trace_example/base/
sta sta_commands
```

or you can just execute them manually after running `sta` in the synthesis results directory:

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

This will generate power consumption report that should look like this:

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
