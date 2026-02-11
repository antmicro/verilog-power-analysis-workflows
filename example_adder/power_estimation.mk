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

# Configuration for `adder` design

export VERILATOR_COMMANDLINE=\
	--binary \
	--build \
	--trace-vcd \
	--timescale 1ns/10ps \
	-Wno-MULTIDRIVEN \
	-Wno-WIDTHEXPAND \
	-Wno-SPECIFYIGN \
	-Wno-WIDTHTRUNC \
	-Wno-PINMISSING \
	-j $$(nproc)

export TRACE2POWER_TOP_SCOPE ?= tb.adder_
export TRACE2POWER_POWER_SCOPE ?= '$(TRACE2POWER_TOP_SCOPE).core1'

export TEST_DIR = $(PWD)/example_adder
export VERILATOR_OUT = $(TEST_DIR)/out/Vtb
export SIMULATION_ARGS = '+trace'

export RESULTS_DIR = $(ORFS)/flow/results/asap7/adder/base

export FLOW_DESIGN_DIR = $(ORFS)/flow/designs/asap7/adder
export FLOW_SRC_DIR = $(ORFS)/flow/designs/src/adder
export FLOW_DESIGN_CONFIG = 'designs/asap7/adder/config.mk'
export DESIGN_SOURCES = $(TEST_DIR)/verilog/adder

export SYNTH_DESIGN_NAME = adder
export SYNTH_VCD_SCOPE = tb/adder_
