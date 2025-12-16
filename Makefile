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

.SUFFIXES:
MAKEFLAGS += -r

# -----------------------------
# User-configurable variables
# -----------------------------
ORFS ?= ext/OpenROAD-flow-scripts
CELL_REPO ?= ext/asap7sc7p5t_28
VERILATOR_REPO ?= ext/verilator
TRACE2POWER_REPO ?= ext/trace2power

OPENROAD_BIN ?= $(ORFS)/tools/install/OpenROAD/bin
TRACE2POWER_TOP_SCOPE ?= TOP.ibex_simple_system.u_top.u_ibex_top.u_ibex_core
TRACE2POWER_POWER_SCOPE ?= '$(TRACE2POWER_TOP_SCOPE).cs_registers_i'
TEST_DIR := $(PWD)/example
VERILATOR_OUT := $(TEST_DIR)/out/Vibex_simple_system
BASE_TCL := $(TEST_DIR)/base_output.tcl

RESULTS_DIR := $(ORFS)/flow/results/asap7/ibex/base


# Verilator
export PATH := $(PATH):$(VERILATOR_REPO)/bin
# trace2power
export PATH := $(PATH):$(TRACE2POWER_REPO)/target/release
# OpenROAD
export PATH := $(PATH):$(OPENROAD_BIN)
# sta
export PATH := $(PATH):$(ORFS)/tools/OpenROAD/build/src/sta

export CELL_SOURCES := $(PWD)/$(CELL_REPO)/Verilog
export LIB_DIR := $(ORFS)/flow/platforms/asap7/lib/NLDM/
export LEF_DIR := $(ORFS)/flow/platforms/asap7/lef
export VCD_FILE := $(TEST_DIR)/sim.vcd
export SYNTH_FILE := $(TEST_DIR)/ibex_core_synth.v


# -----------------------------
# Top-level phony targets
# -----------------------------
.PHONY: all synthesis clean power_base \
    copy_designs simulate power_full sta_full

all: synthesis simulate power_base sta

copy_designs: $(TEST_DIR)/design/* $(TEST_DIR)/verilog/ibex_core/*
	rm -rf $(ORFS)/flow/designs/asap7/ibex/
	mkdir -p $(ORFS)/flow/designs/asap7/ibex/
	cp $(TEST_DIR)/design/* $(ORFS)/flow/designs/asap7/ibex/
	rm -rf $(ORFS)/flow/designs/src/ibex/
	mkdir -p $(ORFS)/flow/designs/src/ibex/
	cp $(TEST_DIR)/verilog/ibex_core/* $(ORFS)/flow/designs/src/ibex/


synthesis: $(RESULTS_DIR)/1_2_yosys.v
.PRECIOUS: $(RESULTS_DIR)/1_2_yosys.v
$(RESULTS_DIR)/1_2_yosys.v: copy_designs
	cd $(ORFS) && make -C flow DESIGN_CONFIG=designs/asap7/ibex/config.mk synth || true
	cp -v $@ $(SYNTH_FILE)


# -----------------------------
# Build + run simulation
# -----------------------------

simulate: $(VCD_FILE)
.PRECIOUS: $(VCD_FILE)
$(VERILATOR_OUT): synthesis $(TEST_DIR)/post_synthesis.vc
	cd $(TEST_DIR) && \
	verilator --build --exe -f post_synthesis.vc \
		--public-flat-rw \
		--x-assign 0 \
		--x-initial 0 \
		--trace-underscore \
		--trace-vcd --trace-structs --trace-params --trace-max-array 1024 \
		-CFLAGS "-std=c++14 -Wall -DTOPLEVEL_NAME=ibex_simple_system" \
		-LDFLAGS "-pthread -lutil -lelf" --unroll-count 72 --timing --timescale 1ns/10ps \
		-Wno-MULTIDRIVEN -Wno-WIDTHEXPAND -Wno-SPECIFYIGN -Wno-WIDTHTRUNC -Wno-fatal \
		-Wno-UNOPTFLAT -Wno-PINMISSING \
		--build-jobs $$(nproc)

$(VCD_FILE): $(VERILATOR_OUT)
	cd $(TEST_DIR) && timeout 5 ./out/Vibex_simple_system -t \
		--meminit=ram,./hello_test/hello_test.elf || true


# ========================================
# Power analysis
# ========================================

power_base: $(VCD_FILE)
	trace2power --clk-freq 200000000  \
		--limit-scope $(TRACE2POWER_TOP_SCOPE) \
		--limit-scope-power $(TRACE2POWER_POWER_SCOPE) \
		--input-ports-activity \
		--output $(BASE_TCL) $(VCD_FILE)
	mkdir -pv $(RESULTS_DIR)
	cp -v $(BASE_TCL) $(RESULTS_DIR)/

sta: power_base $(RESULTS_DIR) $(BASE_TCL)
	cd $(RESULTS_DIR) && openroad $(TEST_DIR)/openroad_commands
	cat $(RESULTS_DIR)/power_estimation.txt

power_full: $(VCD_FILE)
	trace2power --clk-freq 200000000 \
	    --limit-scope $(TRACE2POWER_TOP_SCOPE) \
	    --input-ports-activity \
	    --output $(BASE_TCL) $(VCD_FILE)
	mkdir -pv $(RESULTS_DIR)
	cp -v $(BASE_TCL) $(RESULTS_DIR)/

sta_full: power_full $(RESULTS_DIR) $(BASE_TCL)
	cd $(RESULTS_DIR) && openroad $(TEST_DIR)/openroad_commands
	cat $(RESULTS_DIR)/power_estimation.txt

sta_instances: $(VCD_FILE)
	cd $(RESULTS_DIR) && openroad $(TEST_DIR)/openroad_commands_instances

clean:
	rm -rf $(VERILATOR_OUT) $(TEST_DIR)/out $(VCD_FILE) $(BASE_TCL) $(RESULTS_DIR) $(SYNTH_FILE)

