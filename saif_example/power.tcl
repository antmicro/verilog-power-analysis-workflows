read_liberty $::env(LIB_DIR)/sky130_dummy_io.lib
read_liberty $::env(LIB_DIR)/sky130_fd_sc_hd__tt_025C_1v80.lib

read_db 5_route.odb

read_sdc 1_synth.sdc

read_saif -scope TOP/ibex_simple_system/u_top/u_ibex_top/u_ibex_core sim.saif
report_power