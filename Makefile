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

## Requires design-specific variable declarations found in `power_estimation.mk`
## For details refer to README


# ---------------------------------------
# Directories to used submodules
# ---------------------------------------

CELL_REPO ?= $(PWD)/ext/asap7sc7p5t_28
ORFS ?= $(PWD)/ext/OpenROAD-flow-scripts
TRACE2POWER_REPO ?= $(PWD)/ext/trace2power
VERILATOR_ROOT ?= $(PWD)/ext/verilator


# -------------------------------------
# Executables required for workflow run
# -------------------------------------

# Verilator
export PATH := $(PATH):$(VERILATOR_ROOT)/bin
# trace2power
export PATH := $(PATH):$(TRACE2POWER_REPO)/target/release
# OpenROAD
export PATH := $(PATH):$(ORFS)/tools/install/OpenROAD/bin


# ---------------------------------------
# Environment variables needed in scripts
# ---------------------------------------

export BASE_TCL = $(TEST_DIR)/base_output.tcl
export CELL_SOURCES = $(PWD)/$(CELL_REPO)/Verilog
export LEF_DIR = $(ORFS)/flow/platforms/asap7/lef
export LIB_DIR = $(ORFS)/flow/platforms/asap7/lib/NLDM
export SYNTH_CLEAN = $(TEST_DIR)/verilog/synth_clean.v
export VCD_FILE = $(TEST_DIR)/sim.vcd


# ---------------------------------------
# Result files
# ---------------------------------------

POWER_ESTIMATION_FULL = $(RESULTS_DIR)/power_estimation_full.txt
POWER_ESTIMATION_INSTANCES = $(RESULTS_DIR)/power_estimation_instances.txt
POWER_ESTIMATION_SCOPED = $(RESULTS_DIR)/power_estimation_scoped.txt
SYNTH_DIRTY = $(RESULTS_DIR)/1_2_yosys.v



# -----------------------------
# Top-level phony targets
# -----------------------------

.PHONY: all synthesis clean power_scoped \
    simulate power_full power_instances

all: synthesis simulate power_scoped power_full power_instances


# -----------------------------
# Synthesis
# -----------------------------

# For power consumption report generation you will need to prepare simulated
# model sources for `Yosys` synthesis and `OpenROAD` place and route steps in
# the `OpenROAD-flow-scripts` project directory.
#
# The example workflow uses the `asap7` platform.
#
# Copy the design contents from the example directory to OpenROAD-flow-scripts
# design directory.

synthesis: $(SYNTH_CLEAN)
.PRECIOUS: $(SYNTH_DIRTY) $(SYNTH_CLEAN)
$(SYNTH_DIRTY): $(TEST_DIR)/design/* $(DESIGN_SOURCES)/*
	rm -rf $(FLOW_DESIGN_DIR)
	mkdir -p $(FLOW_DESIGN_DIR)
	cp $(TEST_DIR)/design/* $(FLOW_DESIGN_DIR)/
	rm -rf $(FLOW_SRC_DIR)
	mkdir -p $(FLOW_SRC_DIR)
	cp $(DESIGN_SOURCES)/* $(FLOW_SRC_DIR)/
	cd $(ORFS) && make -C flow DESIGN_CONFIG=$(FLOW_DESIGN_CONFIG) synth



# -----------------------------
# Cleaning with najeda clean
# -----------------------------

$(SYNTH_CLEAN): $(SYNTH_DIRTY)
	# TODO emit lib files with ORFS print-LIB_FILES and feed them to naja
	./scripts/naja_clean.py \
		--libs '/home/bchmiel/Documents/@projects/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SEQ_RVT_FF_nldm_220123.lib' \
		--vars naja_asap7_stdcell_config.yaml \
		$(SYNTH_DIRTY) \
		--output $(SYNTH_CLEAN)

# -----------------------------
# Verilation and simulation run
# -----------------------------

simulate: $(VCD_FILE)
.PRECIOUS: $(VCD_FILE)
$(VERILATOR_OUT): $(SYNTH_CLEAN) $(TEST_DIR)/post_synthesis.vc
	cd $(TEST_DIR) && \
	verilator $(VERILATOR_COMMANDLINE) $(SYNTH_CLEAN) -f $(TEST_DIR)/post_synthesis.vc

$(VCD_FILE): $(VERILATOR_OUT)
	cd $(TEST_DIR) && timeout 5 $(VERILATOR_OUT) $(SIMULATION_ARGS) || true


# -----------------------------
# Scoped power analysis
# -----------------------------

power_scoped: $(POWER_ESTIMATION_SCOPED)
$(POWER_ESTIMATION_SCOPED): $(VCD_FILE)
	trace2power --clk-freq 200000000  \
		--limit-scope $(TRACE2POWER_TOP_SCOPE) \
		--limit-scope-power $(TRACE2POWER_POWER_SCOPE) \
		--input-ports-activity \
		--output $(BASE_TCL) $(VCD_FILE)
	cd $(RESULTS_DIR) && POWER_ESTIMATION=$@ openroad $(TEST_DIR)/openroad_commands
	cat $@


# -----------------------------
# Full power analysis
# -----------------------------

power_full: $(POWER_ESTIMATION_FULL)
$(POWER_ESTIMATION_FULL): $(VCD_FILE)
	trace2power --clk-freq 200000000 \
	    --limit-scope $(TRACE2POWER_TOP_SCOPE) \
	    --input-ports-activity \
	    --output $(BASE_TCL) $(VCD_FILE)
	cd $(RESULTS_DIR) && POWER_ESTIMATION=$@ openroad $(TEST_DIR)/openroad_commands
	cat $@


# -------------------------------------
# Power analysis with OpenSTA instances
# -------------------------------------

power_instances: $(POWER_ESTIMATION_INSTANCES)
$(POWER_ESTIMATION_INSTANCES): $(VCD_FILE)
	cd $(RESULTS_DIR) && POWER_ESTIMATION=$@ openroad $(TEST_DIR)/openroad_commands_instances
	cat $@
	python3 scripts/parse_report_power_instances.py $@

clean:
	rm -rf $(VERILATOR_OUT) $(TEST_DIR)/out $(VCD_FILE) $(BASE_TCL) $(RESULTS_DIR) $(SYNTH_CLEAN) $(SYNTH_DIRTY)

