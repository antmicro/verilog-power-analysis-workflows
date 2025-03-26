# # read_vcd_activities gcd
# read_liberty sky130hd_tt.lib.gz
# read_verilog gcd_sky130hd.v
# link_design gcd
# read_sdc gcd_sky130hd.sdc
# read_spef gcd_sky130hd.spef

# source input_trace
# set_pin_activity_and_duty

# report_activity_annotation
# report_power > output_power

read_liberty $::env(LIB_DIR)/asap7sc7p5t_AO_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_INVBUF_RVT_FF_nldm_220122.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_OA_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SIMPLE_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SEQ_RVT_FF_nldm_220123.lib

read_verilog 1_synth.v
link_design gcd

read_sdc 1_synth.sdc

source input_trace
set_pin_activity_and_duty

report_activity_annotation
report_power > output_power