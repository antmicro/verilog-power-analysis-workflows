read_liberty $::env(LIB_DIR)/asap7sc7p5t_AO_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_INVBUF_RVT_FF_nldm_220122.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_OA_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SIMPLE_RVT_FF_nldm_211120.lib.gz
read_liberty $::env(LIB_DIR)/asap7sc7p5t_SEQ_RVT_FF_nldm_220123.lib

read_db 5_route.odb

read_sdc 1_synth.sdc

read_saif -scope TOP/ibex_simple_system/u_top/u_ibex_top/u_ibex_core sim.saif
report_power