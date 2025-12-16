export PLATFORM               = asap7

export DESIGN_NICKNAME        = adder
export DESIGN_NAME            = adder

export VERILOG_FILES = $(sort $(wildcard $(DESIGN_HOME)/src/adder/*.sv))

export SYNTH_HDL_FRONTEND = slang

export SDC_FILE              = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION       =  20
export REMOVE_ABC_BUFFERS = 1

export SYNTH_HIER_SEPARATOR = _
export SYNTH_HIERARCHICAL=1
export SYNTH_MINIMUM_KEEP_SIZE=0
