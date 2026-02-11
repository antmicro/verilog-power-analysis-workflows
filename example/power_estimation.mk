# Copyright 2026 Antmicro
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

# Configuration for `ibex` design

export VERILATOR_COMMANDLINE=\
	--build --exe \
	--public-flat-rw \
	--x-assign 0 \
	--x-initial 0 \
	--trace-underscore \
	--trace-vcd --trace-structs --trace-params --trace-max-array 1024 \
	-CFLAGS "-std=c++14 -Wall -DTOPLEVEL_NAME=ibex_simple_system" \
	-LDFLAGS "-pthread -lutil -lelf" --unroll-count 72 --timing --timescale 1ns/10ps \
	-Wno-MULTIDRIVEN -Wno-WIDTHEXPAND  -Wno-WIDTHTRUNC -Wno-fatal \
	-Wno-UNOPTFLAT -Wno-PINMISSING -Wno-SPECIFYIGN \
	--build-jobs $$(nproc)


export TRACE2POWER_TOP_SCOPE = TOP.ibex_simple_system.u_top.u_ibex_top.u_ibex_core
export TRACE2POWER_POWER_SCOPE = '$(TRACE2POWER_TOP_SCOPE).cs_registers_i'

export TEST_DIR = $(PWD)/example
export VERILATOR_OUT = $(TEST_DIR)/out/Vibex_simple_system
export SIMULATION_ARGS=\
	-t \
	--meminit=ram,./hello_test/hello_test.elf
export RESULTS_DIR = $(ORFS)/flow/results/asap7/ibex/base
export FLOW_DESIGN_DIR = $(ORFS)/flow/designs/asap7/ibex
export FLOW_SRC_DIR = $(ORFS)/flow/designs/src/ibex
export FLOW_DESIGN_CONFIG = 'designs/asap7/ibex/config.mk'
export DESIGN_SOURCES = $(TEST_DIR)/verilog/ibex_core

export SYNTH_VCD_SCOPE = TOP/ibex_simple_system/u_top/u_ibex_top/u_ibex_core
export SYNTH_DESIGN_NAME := ibex_core
