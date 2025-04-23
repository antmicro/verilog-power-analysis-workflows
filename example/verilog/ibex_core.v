module ibex_core (
	clk_i,
	rst_ni,
	hart_id_i,
	boot_addr_i,
	instr_req_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_addr_o,
	instr_rdata_i,
	instr_err_i,
	data_req_o,
	data_gnt_i,
	data_rvalid_i,
	data_we_o,
	data_be_o,
	data_addr_o,
	data_wdata_o,
	data_rdata_i,
	data_err_i,
	dummy_instr_id_o,
	dummy_instr_wb_o,
	rf_raddr_a_o,
	rf_raddr_b_o,
	rf_waddr_wb_o,
	rf_we_wb_o,
	rf_wdata_wb_ecc_o,
	rf_rdata_a_ecc_i,
	rf_rdata_b_ecc_i,
	ic_tag_req_o,
	ic_tag_write_o,
	ic_tag_addr_o,
	ic_tag_wdata_o,
	ic_tag_rdata_i,
	ic_data_req_o,
	ic_data_write_o,
	ic_data_addr_o,
	ic_data_wdata_o,
	ic_data_rdata_i,
	ic_scr_key_valid_i,
	ic_scr_key_req_o,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	irq_fast_i,
	irq_nm_i,
	irq_pending_o,
	debug_req_i,
	crash_dump_o,
	double_fault_seen_o,
	rvfi_valid,
	rvfi_order,
	rvfi_insn,
	rvfi_trap,
	rvfi_halt,
	rvfi_intr,
	rvfi_mode,
	rvfi_ixl,
	rvfi_rs1_addr,
	rvfi_rs2_addr,
	rvfi_rs3_addr,
	rvfi_rs1_rdata,
	rvfi_rs2_rdata,
	rvfi_rs3_rdata,
	rvfi_rd_addr,
	rvfi_rd_wdata,
	rvfi_pc_rdata,
	rvfi_pc_wdata,
	rvfi_mem_addr,
	rvfi_mem_rmask,
	rvfi_mem_wmask,
	rvfi_mem_rdata,
	rvfi_mem_wdata,
	rvfi_ext_pre_mip,
	rvfi_ext_post_mip,
	rvfi_ext_nmi,
	rvfi_ext_nmi_int,
	rvfi_ext_debug_req,
	rvfi_ext_debug_mode,
	rvfi_ext_rf_wr_suppress,
	rvfi_ext_mcycle,
	rvfi_ext_mhpmcounters,
	rvfi_ext_mhpmcountersh,
	rvfi_ext_ic_scr_key_valid,
	rvfi_ext_irq_valid,
	fetch_enable_i,
	alert_minor_o,
	alert_major_internal_o,
	alert_major_bus_o,
	core_busy_o
);
	reg _sv2v_0;
	parameter [0:0] PMPEnable = 1'b0;
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumRegions = 4;
	localparam [95:0] ibex_pkg_PmpCfgRst = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
	parameter [95:0] PMPRstCfg = ibex_pkg_PmpCfgRst;
	localparam [543:0] ibex_pkg_PmpAddrRst = 544'h0;
	parameter [543:0] PMPRstAddr = ibex_pkg_PmpAddrRst;
	localparam [2:0] ibex_pkg_PmpMseccfgRst = 3'b000;
	parameter [2:0] PMPRstMsecCfg = ibex_pkg_PmpMseccfgRst;
	parameter [31:0] MHPMCounterNum = 0;
	parameter [31:0] MHPMCounterWidth = 40;
	parameter [0:0] RV32E = 1'b0;
	parameter integer RV32M = 32'sd2;
	parameter integer RV32B = 32'sd0;
	parameter [0:0] BranchTargetALU = 1'b0;
	parameter [0:0] WritebackStage = 1'b0;
	parameter [0:0] ICache = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	localparam [31:0] ibex_pkg_BUS_SIZE = 32;
	parameter [31:0] BusSizeECC = ibex_pkg_BUS_SIZE;
	localparam [31:0] ibex_pkg_ADDR_W = 32;
	localparam [31:0] ibex_pkg_IC_LINE_SIZE = 64;
	localparam [31:0] ibex_pkg_IC_LINE_BYTES = 8;
	localparam [31:0] ibex_pkg_IC_NUM_WAYS = 2;
	localparam [31:0] ibex_pkg_IC_SIZE_BYTES = 4096;
	localparam [31:0] ibex_pkg_IC_NUM_LINES = (ibex_pkg_IC_SIZE_BYTES / ibex_pkg_IC_NUM_WAYS) / ibex_pkg_IC_LINE_BYTES;
	localparam [31:0] ibex_pkg_IC_INDEX_W = $clog2(ibex_pkg_IC_NUM_LINES);
	localparam [31:0] ibex_pkg_IC_LINE_W = 3;
	localparam [31:0] ibex_pkg_IC_TAG_SIZE = ((ibex_pkg_ADDR_W - ibex_pkg_IC_INDEX_W) - ibex_pkg_IC_LINE_W) + 1;
	parameter [31:0] TagSizeECC = ibex_pkg_IC_TAG_SIZE;
	parameter [31:0] LineSizeECC = ibex_pkg_IC_LINE_SIZE;
	parameter [0:0] BranchPredictor = 1'b0;
	parameter [0:0] DbgTriggerEn = 1'b0;
	parameter [31:0] DbgHwBreakNum = 1;
	parameter [0:0] ResetAll = 1'b0;
	localparam signed [31:0] ibex_pkg_LfsrWidth = 32;
	localparam [31:0] ibex_pkg_RndCnstLfsrSeedDefault = 32'hac533bf4;
	parameter [31:0] RndCnstLfsrSeed = ibex_pkg_RndCnstLfsrSeedDefault;
	localparam [159:0] ibex_pkg_RndCnstLfsrPermDefault = 160'h1e35ecba467fd1b12e958152c04fa43878a8daed;
	parameter [159:0] RndCnstLfsrPerm = ibex_pkg_RndCnstLfsrPermDefault;
	parameter [0:0] SecureIbex = 1'b0;
	parameter [0:0] DummyInstructions = 1'b0;
	parameter [0:0] RegFileECC = 1'b0;
	parameter [31:0] RegFileDataWidth = 32;
	parameter [0:0] MemECC = 1'b0;
	parameter [31:0] MemDataWidth = (MemECC ? 39 : 32);
	parameter [31:0] DmBaseAddr = 32'h1a110000;
	parameter [31:0] DmAddrMask = 32'h00000fff;
	parameter [31:0] DmHaltAddr = 32'h1a110800;
	parameter [31:0] DmExceptionAddr = 32'h1a110808;
	input wire clk_i;
	input wire rst_ni;
	input wire [31:0] hart_id_i;
	input wire [31:0] boot_addr_i;
	output wire instr_req_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	output wire [31:0] instr_addr_o;
	input wire [MemDataWidth - 1:0] instr_rdata_i;
	input wire instr_err_i;
	output wire data_req_o;
	input wire data_gnt_i;
	input wire data_rvalid_i;
	output wire data_we_o;
	output wire [3:0] data_be_o;
	output wire [31:0] data_addr_o;
	output wire [MemDataWidth - 1:0] data_wdata_o;
	input wire [MemDataWidth - 1:0] data_rdata_i;
	input wire data_err_i;
	output wire dummy_instr_id_o;
	output wire dummy_instr_wb_o;
	output wire [4:0] rf_raddr_a_o;
	output wire [4:0] rf_raddr_b_o;
	output wire [4:0] rf_waddr_wb_o;
	output wire rf_we_wb_o;
	output wire [RegFileDataWidth - 1:0] rf_wdata_wb_ecc_o;
	input wire [RegFileDataWidth - 1:0] rf_rdata_a_ecc_i;
	input wire [RegFileDataWidth - 1:0] rf_rdata_b_ecc_i;
	output wire [1:0] ic_tag_req_o;
	output wire ic_tag_write_o;
	output wire [ibex_pkg_IC_INDEX_W - 1:0] ic_tag_addr_o;
	output wire [TagSizeECC - 1:0] ic_tag_wdata_o;
	input wire [(ibex_pkg_IC_NUM_WAYS * TagSizeECC) - 1:0] ic_tag_rdata_i;
	output wire [1:0] ic_data_req_o;
	output wire ic_data_write_o;
	output wire [ibex_pkg_IC_INDEX_W - 1:0] ic_data_addr_o;
	output wire [LineSizeECC - 1:0] ic_data_wdata_o;
	input wire [(ibex_pkg_IC_NUM_WAYS * LineSizeECC) - 1:0] ic_data_rdata_i;
	input wire ic_scr_key_valid_i;
	output wire ic_scr_key_req_o;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [14:0] irq_fast_i;
	input wire irq_nm_i;
	output wire irq_pending_o;
	input wire debug_req_i;
	output wire [159:0] crash_dump_o;
	output wire double_fault_seen_o;
	output wire rvfi_valid;
	output wire [63:0] rvfi_order;
	output wire [31:0] rvfi_insn;
	output wire rvfi_trap;
	output wire rvfi_halt;
	output wire rvfi_intr;
	output wire [1:0] rvfi_mode;
	output wire [1:0] rvfi_ixl;
	output wire [4:0] rvfi_rs1_addr;
	output wire [4:0] rvfi_rs2_addr;
	output wire [4:0] rvfi_rs3_addr;
	output wire [31:0] rvfi_rs1_rdata;
	output wire [31:0] rvfi_rs2_rdata;
	output wire [31:0] rvfi_rs3_rdata;
	output wire [4:0] rvfi_rd_addr;
	output wire [31:0] rvfi_rd_wdata;
	output wire [31:0] rvfi_pc_rdata;
	output wire [31:0] rvfi_pc_wdata;
	output wire [31:0] rvfi_mem_addr;
	output wire [3:0] rvfi_mem_rmask;
	output wire [3:0] rvfi_mem_wmask;
	output wire [31:0] rvfi_mem_rdata;
	output wire [31:0] rvfi_mem_wdata;
	output reg [31:0] rvfi_ext_pre_mip;
	output reg [31:0] rvfi_ext_post_mip;
	output wire rvfi_ext_nmi;
	output wire rvfi_ext_nmi_int;
	output wire rvfi_ext_debug_req;
	output wire rvfi_ext_debug_mode;
	output wire rvfi_ext_rf_wr_suppress;
	output wire [63:0] rvfi_ext_mcycle;
	output wire [319:0] rvfi_ext_mhpmcounters;
	output wire [319:0] rvfi_ext_mhpmcountersh;
	output wire rvfi_ext_ic_scr_key_valid;
	output wire rvfi_ext_irq_valid;
	localparam signed [31:0] ibex_pkg_IbexMuBiWidth = 4;
	input wire [3:0] fetch_enable_i;
	output wire alert_minor_o;
	output wire alert_major_internal_o;
	output wire alert_major_bus_o;
	output wire [3:0] core_busy_o;
	localparam [31:0] PMPNumChan = 3;
	localparam [0:0] DataIndTiming = SecureIbex;
	localparam [0:0] PCIncrCheck = SecureIbex;
	localparam [0:0] ShadowCSR = 1'b0;
	wire dummy_instr_id;
	wire instr_valid_id;
	wire instr_new_id;
	wire [31:0] instr_rdata_id;
	wire [31:0] instr_rdata_alu_id;
	wire [15:0] instr_rdata_c_id;
	wire instr_is_compressed_id;
	wire instr_perf_count_id;
	wire instr_bp_taken_id;
	wire instr_fetch_err;
	wire instr_fetch_err_plus2;
	wire illegal_c_insn_id;
	wire [31:0] pc_if;
	wire [31:0] pc_id;
	wire [31:0] pc_wb;
	wire [67:0] imd_val_d_ex;
	wire [67:0] imd_val_q_ex;
	wire [1:0] imd_val_we_ex;
	wire data_ind_timing;
	wire dummy_instr_en;
	wire [2:0] dummy_instr_mask;
	wire dummy_instr_seed_en;
	wire [31:0] dummy_instr_seed;
	wire icache_enable;
	wire icache_inval;
	wire icache_ecc_error;
	wire pc_mismatch_alert;
	wire csr_shadow_err;
	wire instr_first_cycle_id;
	wire instr_valid_clear;
	wire pc_set;
	wire nt_branch_mispredict;
	wire [31:0] nt_branch_addr;
	wire [2:0] pc_mux_id;
	wire [1:0] exc_pc_mux_id;
	wire [6:0] exc_cause;
	wire instr_intg_err;
	wire lsu_load_err;
	wire lsu_load_err_raw;
	wire lsu_store_err;
	wire lsu_store_err_raw;
	wire lsu_load_resp_intg_err;
	wire lsu_store_resp_intg_err;
	wire expecting_load_resp_id;
	wire expecting_store_resp_id;
	wire lsu_addr_incr_req;
	wire [31:0] lsu_addr_last;
	wire [31:0] branch_target_ex;
	wire branch_decision;
	wire ctrl_busy;
	wire if_busy;
	wire lsu_busy;
	wire [4:0] rf_raddr_a;
	wire [31:0] rf_rdata_a;
	wire [4:0] rf_raddr_b;
	wire [31:0] rf_rdata_b;
	wire rf_ren_a;
	wire rf_ren_b;
	wire [4:0] rf_waddr_wb;
	wire [31:0] rf_wdata_wb;
	wire [31:0] rf_wdata_fwd_wb;
	wire [31:0] rf_wdata_lsu;
	wire rf_we_wb;
	wire rf_we_lsu;
	wire rf_ecc_err_comb;
	wire [4:0] rf_waddr_id;
	wire [31:0] rf_wdata_id;
	wire rf_we_id;
	wire rf_rd_a_wb_match;
	wire rf_rd_b_wb_match;
	wire [6:0] alu_operator_ex;
	wire [31:0] alu_operand_a_ex;
	wire [31:0] alu_operand_b_ex;
	wire [31:0] bt_a_operand;
	wire [31:0] bt_b_operand;
	wire [31:0] alu_adder_result_ex;
	wire [31:0] result_ex;
	wire mult_en_ex;
	wire div_en_ex;
	wire mult_sel_ex;
	wire div_sel_ex;
	wire [1:0] multdiv_operator_ex;
	wire [1:0] multdiv_signed_mode_ex;
	wire [31:0] multdiv_operand_a_ex;
	wire [31:0] multdiv_operand_b_ex;
	wire multdiv_ready_id;
	wire csr_access;
	wire [1:0] csr_op;
	wire csr_op_en;
	wire [11:0] csr_addr;
	wire [31:0] csr_rdata;
	wire [31:0] csr_wdata;
	wire illegal_csr_insn_id;
	wire lsu_we;
	wire [1:0] lsu_type;
	wire lsu_sign_ext;
	wire lsu_req;
	wire lsu_rdata_valid;
	wire [31:0] lsu_wdata;
	wire lsu_req_done;
	wire id_in_ready;
	wire ex_valid;
	wire lsu_resp_valid;
	wire lsu_resp_err;
	wire instr_req_int;
	wire instr_req_gated;
	wire instr_exec;
	wire en_wb;
	wire [1:0] instr_type_wb;
	wire ready_wb;
	wire rf_write_wb;
	wire outstanding_load_wb;
	wire outstanding_store_wb;
	wire dummy_instr_wb;
	wire nmi_mode;
	wire [17:0] irqs;
	wire csr_mstatus_mie;
	wire [31:0] csr_mepc;
	wire [31:0] csr_depc;
	wire [(PMPNumRegions * 34) - 1:0] csr_pmp_addr;
	wire [(PMPNumRegions * 6) - 1:0] csr_pmp_cfg;
	wire [2:0] csr_pmp_mseccfg;
	wire [0:2] pmp_req_err;
	wire data_req_out;
	wire csr_save_if;
	wire csr_save_id;
	wire csr_save_wb;
	wire csr_restore_mret_id;
	wire csr_restore_dret_id;
	wire csr_save_cause;
	wire csr_mtvec_init;
	wire [31:0] csr_mtvec;
	wire [31:0] csr_mtval;
	wire csr_mstatus_tw;
	wire [1:0] priv_mode_id;
	wire [1:0] priv_mode_lsu;
	wire debug_mode;
	wire debug_mode_entering;
	wire [2:0] debug_cause;
	wire debug_csr_save;
	wire debug_single_step;
	wire debug_ebreakm;
	wire debug_ebreaku;
	wire trigger_match;
	wire instr_id_done;
	wire instr_done_wb;
	wire perf_instr_ret_wb;
	wire perf_instr_ret_compressed_wb;
	wire perf_instr_ret_wb_spec;
	wire perf_instr_ret_compressed_wb_spec;
	wire perf_iside_wait;
	wire perf_dside_wait;
	wire perf_mul_wait;
	wire perf_div_wait;
	wire perf_jump;
	wire perf_branch;
	wire perf_tbranch;
	wire perf_load;
	wire perf_store;
	wire illegal_insn_id;
	wire unused_illegal_insn_id;
	localparam [3:0] ibex_pkg_IbexMuBiOff = 4'b1010;
	localparam [3:0] ibex_pkg_IbexMuBiOn = 4'b0101;
	generate
		if (SecureIbex) begin : g_core_busy_secure
			localparam [31:0] NumBusySignals = 3;
			localparam [31:0] NumBusyBits = ibex_pkg_IbexMuBiWidth * NumBusySignals;
			wire [NumBusyBits - 1:0] busy_bits_buf;
			prim_buf #(.Width(NumBusyBits)) u_fetch_enable_buf(
				.in_i({ibex_pkg_IbexMuBiWidth {ctrl_busy, if_busy, lsu_busy}}),
				.out_o(busy_bits_buf)
			);
			genvar _gv_i_1;
			for (_gv_i_1 = 0; _gv_i_1 < ibex_pkg_IbexMuBiWidth; _gv_i_1 = _gv_i_1 + 1) begin : g_core_busy_bits
				localparam i = _gv_i_1;
				if (ibex_pkg_IbexMuBiOn[i] == 1'b1) begin : g_pos
					assign core_busy_o[i] = |busy_bits_buf[i * NumBusySignals+:NumBusySignals];
				end
				else begin : g_neg
					assign core_busy_o[i] = ~|busy_bits_buf[i * NumBusySignals+:NumBusySignals];
				end
			end
		end
		else begin : g_core_busy_non_secure
			assign core_busy_o = ((ctrl_busy || if_busy) || lsu_busy ? ibex_pkg_IbexMuBiOn : ibex_pkg_IbexMuBiOff);
		end
	endgenerate
	localparam [31:0] ibex_pkg_PMP_I = 0;
	localparam [31:0] ibex_pkg_PMP_I2 = 1;
	ibex_if_stage #(
		.DmHaltAddr(DmHaltAddr),
		.DmExceptionAddr(DmExceptionAddr),
		.DummyInstructions(DummyInstructions),
		.ICache(ICache),
		.ICacheECC(ICacheECC),
		.BusSizeECC(BusSizeECC),
		.TagSizeECC(TagSizeECC),
		.LineSizeECC(LineSizeECC),
		.PCIncrCheck(PCIncrCheck),
		.ResetAll(ResetAll),
		.RndCnstLfsrSeed(RndCnstLfsrSeed),
		.RndCnstLfsrPerm(RndCnstLfsrPerm),
		.BranchPredictor(BranchPredictor),
		.MemECC(MemECC),
		.MemDataWidth(MemDataWidth)
	) if_stage_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.boot_addr_i(boot_addr_i),
		.req_i(instr_req_gated),
		.instr_req_o(instr_req_o),
		.instr_addr_o(instr_addr_o),
		.instr_gnt_i(instr_gnt_i),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_rdata_i(instr_rdata_i),
		.instr_bus_err_i(instr_err_i),
		.instr_intg_err_o(instr_intg_err),
		.ic_tag_req_o(ic_tag_req_o),
		.ic_tag_write_o(ic_tag_write_o),
		.ic_tag_addr_o(ic_tag_addr_o),
		.ic_tag_wdata_o(ic_tag_wdata_o),
		.ic_tag_rdata_i(ic_tag_rdata_i),
		.ic_data_req_o(ic_data_req_o),
		.ic_data_write_o(ic_data_write_o),
		.ic_data_addr_o(ic_data_addr_o),
		.ic_data_wdata_o(ic_data_wdata_o),
		.ic_data_rdata_i(ic_data_rdata_i),
		.ic_scr_key_valid_i(ic_scr_key_valid_i),
		.ic_scr_key_req_o(ic_scr_key_req_o),
		.instr_valid_id_o(instr_valid_id),
		.instr_new_id_o(instr_new_id),
		.instr_rdata_id_o(instr_rdata_id),
		.instr_rdata_alu_id_o(instr_rdata_alu_id),
		.instr_rdata_c_id_o(instr_rdata_c_id),
		.instr_is_compressed_id_o(instr_is_compressed_id),
		.instr_bp_taken_o(instr_bp_taken_id),
		.instr_fetch_err_o(instr_fetch_err),
		.instr_fetch_err_plus2_o(instr_fetch_err_plus2),
		.illegal_c_insn_id_o(illegal_c_insn_id),
		.dummy_instr_id_o(dummy_instr_id),
		.pc_if_o(pc_if),
		.pc_id_o(pc_id),
		.pmp_err_if_i(pmp_req_err[ibex_pkg_PMP_I]),
		.pmp_err_if_plus2_i(pmp_req_err[ibex_pkg_PMP_I2]),
		.instr_valid_clear_i(instr_valid_clear),
		.pc_set_i(pc_set),
		.pc_mux_i(pc_mux_id),
		.nt_branch_mispredict_i(nt_branch_mispredict),
		.exc_pc_mux_i(exc_pc_mux_id),
		.exc_cause(exc_cause),
		.dummy_instr_en_i(dummy_instr_en),
		.dummy_instr_mask_i(dummy_instr_mask),
		.dummy_instr_seed_en_i(dummy_instr_seed_en),
		.dummy_instr_seed_i(dummy_instr_seed),
		.icache_enable_i(icache_enable),
		.icache_inval_i(icache_inval),
		.icache_ecc_error_o(icache_ecc_error),
		.branch_target_ex_i(branch_target_ex),
		.nt_branch_addr_i(nt_branch_addr),
		.csr_mepc_i(csr_mepc),
		.csr_depc_i(csr_depc),
		.csr_mtvec_i(csr_mtvec),
		.csr_mtvec_init_o(csr_mtvec_init),
		.id_in_ready_i(id_in_ready),
		.pc_mismatch_alert_o(pc_mismatch_alert),
		.if_busy_o(if_busy)
	);
	assign perf_iside_wait = id_in_ready & ~instr_valid_id;
	generate
		if (SecureIbex) begin : g_instr_req_gated_secure
			assign instr_req_gated = instr_req_int & (fetch_enable_i == ibex_pkg_IbexMuBiOn);
			assign instr_exec = fetch_enable_i == ibex_pkg_IbexMuBiOn;
		end
		else begin : g_instr_req_gated_non_secure
			wire unused_fetch_enable;
			assign unused_fetch_enable = ^fetch_enable_i[3:1];
			assign instr_req_gated = instr_req_int & fetch_enable_i[0];
			assign instr_exec = fetch_enable_i[0];
		end
	endgenerate
	ibex_id_stage #(
		.RV32E(RV32E),
		.RV32M(RV32M),
		.RV32B(RV32B),
		.BranchTargetALU(BranchTargetALU),
		.DataIndTiming(DataIndTiming),
		.WritebackStage(WritebackStage),
		.BranchPredictor(BranchPredictor),
		.MemECC(MemECC)
	) id_stage_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.ctrl_busy_o(ctrl_busy),
		.illegal_insn_o(illegal_insn_id),
		.instr_valid_i(instr_valid_id),
		.instr_rdata_i(instr_rdata_id),
		.instr_rdata_alu_i(instr_rdata_alu_id),
		.instr_rdata_c_i(instr_rdata_c_id),
		.instr_is_compressed_i(instr_is_compressed_id),
		.instr_bp_taken_i(instr_bp_taken_id),
		.branch_decision_i(branch_decision),
		.instr_first_cycle_id_o(instr_first_cycle_id),
		.instr_valid_clear_o(instr_valid_clear),
		.id_in_ready_o(id_in_ready),
		.instr_exec_i(instr_exec),
		.instr_req_o(instr_req_int),
		.pc_set_o(pc_set),
		.pc_mux_o(pc_mux_id),
		.nt_branch_mispredict_o(nt_branch_mispredict),
		.nt_branch_addr_o(nt_branch_addr),
		.exc_pc_mux_o(exc_pc_mux_id),
		.exc_cause_o(exc_cause),
		.icache_inval_o(icache_inval),
		.instr_fetch_err_i(instr_fetch_err),
		.instr_fetch_err_plus2_i(instr_fetch_err_plus2),
		.illegal_c_insn_i(illegal_c_insn_id),
		.pc_id_i(pc_id),
		.ex_valid_i(ex_valid),
		.lsu_resp_valid_i(lsu_resp_valid),
		.alu_operator_ex_o(alu_operator_ex),
		.alu_operand_a_ex_o(alu_operand_a_ex),
		.alu_operand_b_ex_o(alu_operand_b_ex),
		.imd_val_q_ex_o(imd_val_q_ex),
		.imd_val_d_ex_i(imd_val_d_ex),
		.imd_val_we_ex_i(imd_val_we_ex),
		.bt_a_operand_o(bt_a_operand),
		.bt_b_operand_o(bt_b_operand),
		.mult_en_ex_o(mult_en_ex),
		.div_en_ex_o(div_en_ex),
		.mult_sel_ex_o(mult_sel_ex),
		.div_sel_ex_o(div_sel_ex),
		.multdiv_operator_ex_o(multdiv_operator_ex),
		.multdiv_signed_mode_ex_o(multdiv_signed_mode_ex),
		.multdiv_operand_a_ex_o(multdiv_operand_a_ex),
		.multdiv_operand_b_ex_o(multdiv_operand_b_ex),
		.multdiv_ready_id_o(multdiv_ready_id),
		.csr_access_o(csr_access),
		.csr_op_o(csr_op),
		.csr_addr_o(csr_addr),
		.csr_op_en_o(csr_op_en),
		.csr_save_if_o(csr_save_if),
		.csr_save_id_o(csr_save_id),
		.csr_save_wb_o(csr_save_wb),
		.csr_restore_mret_id_o(csr_restore_mret_id),
		.csr_restore_dret_id_o(csr_restore_dret_id),
		.csr_save_cause_o(csr_save_cause),
		.csr_mtval_o(csr_mtval),
		.priv_mode_i(priv_mode_id),
		.csr_mstatus_tw_i(csr_mstatus_tw),
		.illegal_csr_insn_i(illegal_csr_insn_id),
		.data_ind_timing_i(data_ind_timing),
		.lsu_req_o(lsu_req),
		.lsu_we_o(lsu_we),
		.lsu_type_o(lsu_type),
		.lsu_sign_ext_o(lsu_sign_ext),
		.lsu_wdata_o(lsu_wdata),
		.lsu_req_done_i(lsu_req_done),
		.lsu_addr_incr_req_i(lsu_addr_incr_req),
		.lsu_addr_last_i(lsu_addr_last),
		.lsu_load_err_i(lsu_load_err),
		.lsu_load_resp_intg_err_i(lsu_load_resp_intg_err),
		.lsu_store_err_i(lsu_store_err),
		.lsu_store_resp_intg_err_i(lsu_store_resp_intg_err),
		.expecting_load_resp_o(expecting_load_resp_id),
		.expecting_store_resp_o(expecting_store_resp_id),
		.csr_mstatus_mie_i(csr_mstatus_mie),
		.irq_pending_i(irq_pending_o),
		.irqs_i(irqs),
		.irq_nm_i(irq_nm_i),
		.nmi_mode_o(nmi_mode),
		.debug_mode_o(debug_mode),
		.debug_mode_entering_o(debug_mode_entering),
		.debug_cause_o(debug_cause),
		.debug_csr_save_o(debug_csr_save),
		.debug_req_i(debug_req_i),
		.debug_single_step_i(debug_single_step),
		.debug_ebreakm_i(debug_ebreakm),
		.debug_ebreaku_i(debug_ebreaku),
		.trigger_match_i(trigger_match),
		.result_ex_i(result_ex),
		.csr_rdata_i(csr_rdata),
		.rf_raddr_a_o(rf_raddr_a),
		.rf_rdata_a_i(rf_rdata_a),
		.rf_raddr_b_o(rf_raddr_b),
		.rf_rdata_b_i(rf_rdata_b),
		.rf_ren_a_o(rf_ren_a),
		.rf_ren_b_o(rf_ren_b),
		.rf_waddr_id_o(rf_waddr_id),
		.rf_wdata_id_o(rf_wdata_id),
		.rf_we_id_o(rf_we_id),
		.rf_rd_a_wb_match_o(rf_rd_a_wb_match),
		.rf_rd_b_wb_match_o(rf_rd_b_wb_match),
		.rf_waddr_wb_i(rf_waddr_wb),
		.rf_wdata_fwd_wb_i(rf_wdata_fwd_wb),
		.rf_write_wb_i(rf_write_wb),
		.en_wb_o(en_wb),
		.instr_type_wb_o(instr_type_wb),
		.instr_perf_count_id_o(instr_perf_count_id),
		.ready_wb_i(ready_wb),
		.outstanding_load_wb_i(outstanding_load_wb),
		.outstanding_store_wb_i(outstanding_store_wb),
		.perf_jump_o(perf_jump),
		.perf_branch_o(perf_branch),
		.perf_tbranch_o(perf_tbranch),
		.perf_dside_wait_o(perf_dside_wait),
		.perf_mul_wait_o(perf_mul_wait),
		.perf_div_wait_o(perf_div_wait),
		.instr_id_done_o(instr_id_done)
	);
	assign unused_illegal_insn_id = illegal_insn_id;
	ibex_ex_block #(
		.RV32M(RV32M),
		.RV32B(RV32B),
		.BranchTargetALU(BranchTargetALU)
	) ex_block_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.alu_operator_i(alu_operator_ex),
		.alu_operand_a_i(alu_operand_a_ex),
		.alu_operand_b_i(alu_operand_b_ex),
		.alu_instr_first_cycle_i(instr_first_cycle_id),
		.bt_a_operand_i(bt_a_operand),
		.bt_b_operand_i(bt_b_operand),
		.multdiv_operator_i(multdiv_operator_ex),
		.mult_en_i(mult_en_ex),
		.div_en_i(div_en_ex),
		.mult_sel_i(mult_sel_ex),
		.div_sel_i(div_sel_ex),
		.multdiv_signed_mode_i(multdiv_signed_mode_ex),
		.multdiv_operand_a_i(multdiv_operand_a_ex),
		.multdiv_operand_b_i(multdiv_operand_b_ex),
		.multdiv_ready_id_i(multdiv_ready_id),
		.data_ind_timing_i(data_ind_timing),
		.imd_val_we_o(imd_val_we_ex),
		.imd_val_d_o(imd_val_d_ex),
		.imd_val_q_i(imd_val_q_ex),
		.alu_adder_result_ex_o(alu_adder_result_ex),
		.result_ex_o(result_ex),
		.branch_target_o(branch_target_ex),
		.branch_decision_o(branch_decision),
		.ex_valid_o(ex_valid)
	);
	localparam [31:0] ibex_pkg_PMP_D = 2;
	assign data_req_o = data_req_out & ~pmp_req_err[ibex_pkg_PMP_D];
	assign lsu_resp_err = lsu_load_err | lsu_store_err;
	ibex_load_store_unit #(
		.MemECC(MemECC),
		.MemDataWidth(MemDataWidth)
	) load_store_unit_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.data_req_o(data_req_out),
		.data_gnt_i(data_gnt_i),
		.data_rvalid_i(data_rvalid_i),
		.data_bus_err_i(data_err_i),
		.data_pmp_err_i(pmp_req_err[ibex_pkg_PMP_D]),
		.data_addr_o(data_addr_o),
		.data_we_o(data_we_o),
		.data_be_o(data_be_o),
		.data_wdata_o(data_wdata_o),
		.data_rdata_i(data_rdata_i),
		.lsu_we_i(lsu_we),
		.lsu_type_i(lsu_type),
		.lsu_wdata_i(lsu_wdata),
		.lsu_sign_ext_i(lsu_sign_ext),
		.lsu_rdata_o(rf_wdata_lsu),
		.lsu_rdata_valid_o(lsu_rdata_valid),
		.lsu_req_i(lsu_req),
		.lsu_req_done_o(lsu_req_done),
		.adder_result_ex_i(alu_adder_result_ex),
		.addr_incr_req_o(lsu_addr_incr_req),
		.addr_last_o(lsu_addr_last),
		.lsu_resp_valid_o(lsu_resp_valid),
		.load_err_o(lsu_load_err_raw),
		.load_resp_intg_err_o(lsu_load_resp_intg_err),
		.store_err_o(lsu_store_err_raw),
		.store_resp_intg_err_o(lsu_store_resp_intg_err),
		.busy_o(lsu_busy),
		.perf_load_o(perf_load),
		.perf_store_o(perf_store)
	);
	ibex_wb_stage #(
		.ResetAll(ResetAll),
		.WritebackStage(WritebackStage),
		.DummyInstructions(DummyInstructions)
	) wb_stage_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.en_wb_i(en_wb),
		.instr_type_wb_i(instr_type_wb),
		.pc_id_i(pc_id),
		.instr_is_compressed_id_i(instr_is_compressed_id),
		.instr_perf_count_id_i(instr_perf_count_id),
		.ready_wb_o(ready_wb),
		.rf_write_wb_o(rf_write_wb),
		.outstanding_load_wb_o(outstanding_load_wb),
		.outstanding_store_wb_o(outstanding_store_wb),
		.pc_wb_o(pc_wb),
		.perf_instr_ret_wb_o(perf_instr_ret_wb),
		.perf_instr_ret_compressed_wb_o(perf_instr_ret_compressed_wb),
		.perf_instr_ret_wb_spec_o(perf_instr_ret_wb_spec),
		.perf_instr_ret_compressed_wb_spec_o(perf_instr_ret_compressed_wb_spec),
		.rf_waddr_id_i(rf_waddr_id),
		.rf_wdata_id_i(rf_wdata_id),
		.rf_we_id_i(rf_we_id),
		.dummy_instr_id_i(dummy_instr_id),
		.rf_wdata_lsu_i(rf_wdata_lsu),
		.rf_we_lsu_i(rf_we_lsu),
		.rf_wdata_fwd_wb_o(rf_wdata_fwd_wb),
		.rf_waddr_wb_o(rf_waddr_wb),
		.rf_wdata_wb_o(rf_wdata_wb),
		.rf_we_wb_o(rf_we_wb),
		.dummy_instr_wb_o(dummy_instr_wb),
		.lsu_resp_valid_i(lsu_resp_valid),
		.lsu_resp_err_i(lsu_resp_err),
		.instr_done_wb_o(instr_done_wb)
	);
	generate
		if (SecureIbex) begin : g_check_mem_response
			assign lsu_load_err = lsu_load_err_raw & (outstanding_load_wb | expecting_load_resp_id);
			assign lsu_store_err = lsu_store_err_raw & (outstanding_store_wb | expecting_store_resp_id);
			assign rf_we_lsu = lsu_rdata_valid & (outstanding_load_wb | expecting_load_resp_id);
		end
		else begin : g_no_check_mem_response
			assign lsu_load_err = lsu_load_err_raw;
			assign lsu_store_err = lsu_store_err_raw;
			assign rf_we_lsu = lsu_rdata_valid;
			wire unused_expecting_load_resp_id;
			wire unused_expecting_store_resp_id;
			assign unused_expecting_load_resp_id = expecting_load_resp_id;
			assign unused_expecting_store_resp_id = expecting_store_resp_id;
		end
	endgenerate
	assign dummy_instr_id_o = dummy_instr_id;
	assign dummy_instr_wb_o = dummy_instr_wb;
	assign rf_raddr_a_o = rf_raddr_a;
	assign rf_waddr_wb_o = rf_waddr_wb;
	assign rf_we_wb_o = rf_we_wb;
	assign rf_raddr_b_o = rf_raddr_b;
	generate
		if (RegFileECC) begin : gen_regfile_ecc
			wire [1:0] rf_ecc_err_a;
			wire [1:0] rf_ecc_err_b;
			wire rf_ecc_err_a_id;
			wire rf_ecc_err_b_id;
			prim_secded_inv_39_32_enc regfile_ecc_enc(
				.data_i(rf_wdata_wb),
				.data_o(rf_wdata_wb_ecc_o)
			);
			prim_secded_inv_39_32_dec regfile_ecc_dec_a(
				.data_i(rf_rdata_a_ecc_i),
				.data_o(),
				.syndrome_o(),
				.err_o(rf_ecc_err_a)
			);
			prim_secded_inv_39_32_dec regfile_ecc_dec_b(
				.data_i(rf_rdata_b_ecc_i),
				.data_o(),
				.syndrome_o(),
				.err_o(rf_ecc_err_b)
			);
			assign rf_rdata_a = rf_rdata_a_ecc_i[31:0];
			assign rf_rdata_b = rf_rdata_b_ecc_i[31:0];
			assign rf_ecc_err_a_id = (|rf_ecc_err_a & rf_ren_a) & ~(rf_rd_a_wb_match & rf_write_wb);
			assign rf_ecc_err_b_id = (|rf_ecc_err_b & rf_ren_b) & ~(rf_rd_b_wb_match & rf_write_wb);
			assign rf_ecc_err_comb = instr_valid_id & (rf_ecc_err_a_id | rf_ecc_err_b_id);
		end
		else begin : gen_no_regfile_ecc
			wire unused_rf_ren_a;
			wire unused_rf_ren_b;
			wire unused_rf_rd_a_wb_match;
			wire unused_rf_rd_b_wb_match;
			assign unused_rf_ren_a = rf_ren_a;
			assign unused_rf_ren_b = rf_ren_b;
			assign unused_rf_rd_a_wb_match = rf_rd_a_wb_match;
			assign unused_rf_rd_b_wb_match = rf_rd_b_wb_match;
			assign rf_wdata_wb_ecc_o = rf_wdata_wb;
			assign rf_rdata_a = rf_rdata_a_ecc_i;
			assign rf_rdata_b = rf_rdata_b_ecc_i;
			assign rf_ecc_err_comb = 1'b0;
		end
	endgenerate
	wire [31:0] crash_dump_mtval;
	assign crash_dump_o[159-:32] = pc_id;
	assign crash_dump_o[127-:32] = pc_if;
	assign crash_dump_o[95-:32] = lsu_addr_last;
	assign crash_dump_o[63-:32] = csr_mepc;
	assign crash_dump_o[31-:32] = crash_dump_mtval;
	assign alert_minor_o = icache_ecc_error;
	assign alert_major_internal_o = (rf_ecc_err_comb | pc_mismatch_alert) | csr_shadow_err;
	assign alert_major_bus_o = (lsu_load_resp_intg_err | lsu_store_resp_intg_err) | instr_intg_err;
	assign csr_wdata = alu_operand_a_ex;
	ibex_cs_registers #(
		.DbgTriggerEn(DbgTriggerEn),
		.DbgHwBreakNum(DbgHwBreakNum),
		.DataIndTiming(DataIndTiming),
		.DummyInstructions(DummyInstructions),
		.ShadowCSR(ShadowCSR),
		.ICache(ICache),
		.MHPMCounterNum(MHPMCounterNum),
		.MHPMCounterWidth(MHPMCounterWidth),
		.PMPEnable(PMPEnable),
		.PMPGranularity(PMPGranularity),
		.PMPNumRegions(PMPNumRegions),
		.PMPRstCfg(PMPRstCfg),
		.PMPRstAddr(PMPRstAddr),
		.PMPRstMsecCfg(PMPRstMsecCfg),
		.RV32E(RV32E),
		.RV32M(RV32M),
		.RV32B(RV32B)
	) cs_registers_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.hart_id_i(hart_id_i),
		.priv_mode_id_o(priv_mode_id),
		.priv_mode_lsu_o(priv_mode_lsu),
		.csr_mtvec_o(csr_mtvec),
		.csr_mtvec_init_i(csr_mtvec_init),
		.boot_addr_i(boot_addr_i),
		.csr_access_i(csr_access),
		.csr_addr_i(csr_addr),
		.csr_wdata_i(csr_wdata),
		.csr_op_i(csr_op),
		.csr_op_en_i(csr_op_en),
		.csr_rdata_o(csr_rdata),
		.irq_software_i(irq_software_i),
		.irq_timer_i(irq_timer_i),
		.irq_external_i(irq_external_i),
		.irq_fast_i(irq_fast_i),
		.nmi_mode_i(nmi_mode),
		.irq_pending_o(irq_pending_o),
		.irqs_o(irqs),
		.csr_mstatus_mie_o(csr_mstatus_mie),
		.csr_mstatus_tw_o(csr_mstatus_tw),
		.csr_mepc_o(csr_mepc),
		.csr_mtval_o(crash_dump_mtval),
		.csr_pmp_cfg_o(csr_pmp_cfg),
		.csr_pmp_addr_o(csr_pmp_addr),
		.csr_pmp_mseccfg_o(csr_pmp_mseccfg),
		.csr_depc_o(csr_depc),
		.debug_mode_i(debug_mode),
		.debug_mode_entering_i(debug_mode_entering),
		.debug_cause_i(debug_cause),
		.debug_csr_save_i(debug_csr_save),
		.debug_single_step_o(debug_single_step),
		.debug_ebreakm_o(debug_ebreakm),
		.debug_ebreaku_o(debug_ebreaku),
		.trigger_match_o(trigger_match),
		.pc_if_i(pc_if),
		.pc_id_i(pc_id),
		.pc_wb_i(pc_wb),
		.data_ind_timing_o(data_ind_timing),
		.dummy_instr_en_o(dummy_instr_en),
		.dummy_instr_mask_o(dummy_instr_mask),
		.dummy_instr_seed_en_o(dummy_instr_seed_en),
		.dummy_instr_seed_o(dummy_instr_seed),
		.icache_enable_o(icache_enable),
		.csr_shadow_err_o(csr_shadow_err),
		.ic_scr_key_valid_i(ic_scr_key_valid_i),
		.csr_save_if_i(csr_save_if),
		.csr_save_id_i(csr_save_id),
		.csr_save_wb_i(csr_save_wb),
		.csr_restore_mret_i(csr_restore_mret_id),
		.csr_restore_dret_i(csr_restore_dret_id),
		.csr_save_cause_i(csr_save_cause),
		.csr_mcause_i(exc_cause),
		.csr_mtval_i(csr_mtval),
		.illegal_csr_insn_o(illegal_csr_insn_id),
		.double_fault_seen_o(double_fault_seen_o),
		.instr_ret_i(perf_instr_ret_wb),
		.instr_ret_compressed_i(perf_instr_ret_compressed_wb),
		.instr_ret_spec_i(perf_instr_ret_wb_spec),
		.instr_ret_compressed_spec_i(perf_instr_ret_compressed_wb_spec),
		.iside_wait_i(perf_iside_wait),
		.jump_i(perf_jump),
		.branch_i(perf_branch),
		.branch_taken_i(perf_tbranch),
		.mem_load_i(perf_load),
		.mem_store_i(perf_store),
		.dside_wait_i(perf_dside_wait),
		.mul_wait_i(perf_mul_wait),
		.div_wait_i(perf_div_wait)
	);
	generate
		if (PMPEnable) begin : g_pmp
			wire [31:0] pc_if_inc;
			wire [101:0] pmp_req_addr;
			wire [5:0] pmp_req_type;
			wire [5:0] pmp_priv_lvl;
			assign pc_if_inc = pc_if + 32'd2;
			assign pmp_req_addr[68+:34] = {2'b00, pc_if};
			assign pmp_req_type[4+:2] = 2'b00;
			assign pmp_priv_lvl[4+:2] = priv_mode_id;
			assign pmp_req_addr[34+:34] = {2'b00, pc_if_inc};
			assign pmp_req_type[2+:2] = 2'b00;
			assign pmp_priv_lvl[2+:2] = priv_mode_id;
			assign pmp_req_addr[0+:34] = {2'b00, data_addr_o[31:0]};
			assign pmp_req_type[0+:2] = (data_we_o ? 2'b01 : 2'b10);
			assign pmp_priv_lvl[0+:2] = priv_mode_lsu;
			ibex_pmp #(
				.DmBaseAddr(DmBaseAddr),
				.DmAddrMask(DmAddrMask),
				.PMPGranularity(PMPGranularity),
				.PMPNumChan(PMPNumChan),
				.PMPNumRegions(PMPNumRegions)
			) pmp_i(
				.csr_pmp_cfg_i(csr_pmp_cfg),
				.csr_pmp_addr_i(csr_pmp_addr),
				.csr_pmp_mseccfg_i(csr_pmp_mseccfg),
				.debug_mode_i(debug_mode),
				.priv_mode_i(pmp_priv_lvl),
				.pmp_req_addr_i(pmp_req_addr),
				.pmp_req_type_i(pmp_req_type),
				.pmp_req_err_o(pmp_req_err)
			);
		end
		else begin : g_no_pmp
			wire [1:0] unused_priv_lvl_ls;
			wire [(PMPNumRegions * 34) - 1:0] unused_csr_pmp_addr;
			wire [(PMPNumRegions * 6) - 1:0] unused_csr_pmp_cfg;
			wire [2:0] unused_csr_pmp_mseccfg;
			assign unused_priv_lvl_ls = priv_mode_lsu;
			assign unused_csr_pmp_addr = csr_pmp_addr;
			assign unused_csr_pmp_cfg = csr_pmp_cfg;
			assign unused_csr_pmp_mseccfg = csr_pmp_mseccfg;
			assign pmp_req_err[ibex_pkg_PMP_I] = 1'b0;
			assign pmp_req_err[ibex_pkg_PMP_I2] = 1'b0;
			assign pmp_req_err[ibex_pkg_PMP_D] = 1'b0;
		end
	endgenerate
	localparam signed [31:0] RVFI_STAGES = (WritebackStage ? 2 : 1);
	reg rvfi_stage_valid [0:RVFI_STAGES - 1];
	reg [63:0] rvfi_stage_order [0:RVFI_STAGES - 1];
	reg [31:0] rvfi_stage_insn [0:RVFI_STAGES - 1];
	reg rvfi_stage_trap [0:RVFI_STAGES - 1];
	reg rvfi_stage_halt [0:RVFI_STAGES - 1];
	reg rvfi_stage_intr [0:RVFI_STAGES - 1];
	reg [1:0] rvfi_stage_mode [0:RVFI_STAGES - 1];
	reg [1:0] rvfi_stage_ixl [0:RVFI_STAGES - 1];
	reg [4:0] rvfi_stage_rs1_addr [0:RVFI_STAGES - 1];
	reg [4:0] rvfi_stage_rs2_addr [0:RVFI_STAGES - 1];
	reg [4:0] rvfi_stage_rs3_addr [0:RVFI_STAGES - 1];
	reg [31:0] rvfi_stage_rs1_rdata [0:RVFI_STAGES - 1];
	reg [31:0] rvfi_stage_rs2_rdata [0:RVFI_STAGES - 1];
	reg [31:0] rvfi_stage_rs3_rdata [0:RVFI_STAGES - 1];
	reg [4:0] rvfi_stage_rd_addr [0:RVFI_STAGES - 1];
	reg [31:0] rvfi_stage_rd_wdata [0:RVFI_STAGES - 1];
	reg [31:0] rvfi_stage_pc_rdata [0:RVFI_STAGES - 1];
	reg [31:0] rvfi_stage_pc_wdata [0:RVFI_STAGES - 1];
	reg [31:0] rvfi_stage_mem_addr [0:RVFI_STAGES - 1];
	reg [3:0] rvfi_stage_mem_rmask [0:RVFI_STAGES - 1];
	reg [3:0] rvfi_stage_mem_wmask [0:RVFI_STAGES - 1];
	reg [31:0] rvfi_stage_mem_rdata [0:RVFI_STAGES - 1];
	reg [31:0] rvfi_stage_mem_wdata [0:RVFI_STAGES - 1];
	wire rvfi_instr_new_wb;
	wire rvfi_intr_d;
	reg rvfi_intr_q;
	reg rvfi_set_trap_pc_d;
	reg rvfi_set_trap_pc_q;
	reg [31:0] rvfi_insn_id;
	reg [4:0] rvfi_rs1_addr_d;
	reg [4:0] rvfi_rs1_addr_q;
	reg [4:0] rvfi_rs2_addr_d;
	reg [4:0] rvfi_rs2_addr_q;
	reg [4:0] rvfi_rs3_addr_d;
	reg [31:0] rvfi_rs1_data_d;
	reg [31:0] rvfi_rs1_data_q;
	reg [31:0] rvfi_rs2_data_d;
	reg [31:0] rvfi_rs2_data_q;
	reg [31:0] rvfi_rs3_data_d;
	wire [4:0] rvfi_rd_addr_wb;
	reg [4:0] rvfi_rd_addr_q;
	reg [4:0] rvfi_rd_addr_d;
	wire [31:0] rvfi_rd_wdata_wb;
	reg [31:0] rvfi_rd_wdata_d;
	reg [31:0] rvfi_rd_wdata_q;
	wire rvfi_rd_we_wb;
	reg [3:0] rvfi_mem_mask_int;
	reg [31:0] rvfi_mem_rdata_d;
	reg [31:0] rvfi_mem_rdata_q;
	reg [31:0] rvfi_mem_wdata_d;
	reg [31:0] rvfi_mem_wdata_q;
	reg [31:0] rvfi_mem_addr_d;
	reg [31:0] rvfi_mem_addr_q;
	wire rvfi_trap_id;
	wire rvfi_trap_wb;
	reg rvfi_irq_valid;
	wire [63:0] rvfi_stage_order_d;
	wire rvfi_id_done;
	wire rvfi_wb_done;
	wire new_debug_req;
	wire new_nmi;
	wire new_nmi_int;
	wire new_irq;
	reg [17:0] captured_mip;
	reg captured_nmi;
	reg captured_nmi_int;
	reg captured_debug_req;
	reg captured_valid;
	reg [17:0] rvfi_ext_stage_pre_mip [0:RVFI_STAGES + 0];
	reg [17:0] rvfi_ext_stage_post_mip [0:RVFI_STAGES - 1];
	reg rvfi_ext_stage_nmi [0:RVFI_STAGES + 0];
	reg rvfi_ext_stage_nmi_int [0:RVFI_STAGES + 0];
	reg rvfi_ext_stage_debug_req [0:RVFI_STAGES + 0];
	reg rvfi_ext_stage_debug_mode [0:RVFI_STAGES - 1];
	reg [63:0] rvfi_ext_stage_mcycle [0:RVFI_STAGES - 1];
	reg [319:0] rvfi_ext_stage_mhpmcounters [0:RVFI_STAGES - 1];
	reg [319:0] rvfi_ext_stage_mhpmcountersh [0:RVFI_STAGES - 1];
	reg rvfi_ext_stage_ic_scr_key_valid [0:RVFI_STAGES - 1];
	reg rvfi_ext_stage_irq_valid [0:RVFI_STAGES + 0];
	wire rvfi_stage_valid_d [0:RVFI_STAGES - 1];
	assign rvfi_valid = rvfi_stage_valid[RVFI_STAGES - 1];
	assign rvfi_order = rvfi_stage_order[RVFI_STAGES - 1];
	assign rvfi_insn = rvfi_stage_insn[RVFI_STAGES - 1];
	assign rvfi_trap = rvfi_stage_trap[RVFI_STAGES - 1];
	assign rvfi_halt = rvfi_stage_halt[RVFI_STAGES - 1];
	assign rvfi_intr = rvfi_stage_intr[RVFI_STAGES - 1];
	assign rvfi_mode = rvfi_stage_mode[RVFI_STAGES - 1];
	assign rvfi_ixl = rvfi_stage_ixl[RVFI_STAGES - 1];
	assign rvfi_rs1_addr = rvfi_stage_rs1_addr[RVFI_STAGES - 1];
	assign rvfi_rs2_addr = rvfi_stage_rs2_addr[RVFI_STAGES - 1];
	assign rvfi_rs3_addr = rvfi_stage_rs3_addr[RVFI_STAGES - 1];
	assign rvfi_rs1_rdata = rvfi_stage_rs1_rdata[RVFI_STAGES - 1];
	assign rvfi_rs2_rdata = rvfi_stage_rs2_rdata[RVFI_STAGES - 1];
	assign rvfi_rs3_rdata = rvfi_stage_rs3_rdata[RVFI_STAGES - 1];
	assign rvfi_rd_addr = rvfi_stage_rd_addr[RVFI_STAGES - 1];
	assign rvfi_rd_wdata = rvfi_stage_rd_wdata[RVFI_STAGES - 1];
	assign rvfi_pc_rdata = rvfi_stage_pc_rdata[RVFI_STAGES - 1];
	assign rvfi_pc_wdata = rvfi_stage_pc_wdata[RVFI_STAGES - 1];
	assign rvfi_mem_addr = rvfi_stage_mem_addr[RVFI_STAGES - 1];
	assign rvfi_mem_rmask = rvfi_stage_mem_rmask[RVFI_STAGES - 1];
	assign rvfi_mem_wmask = rvfi_stage_mem_wmask[RVFI_STAGES - 1];
	assign rvfi_mem_rdata = rvfi_stage_mem_rdata[RVFI_STAGES - 1];
	assign rvfi_mem_wdata = rvfi_stage_mem_wdata[RVFI_STAGES - 1];
	assign rvfi_rd_addr_wb = rf_waddr_wb;
	assign rvfi_rd_wdata_wb = (rf_we_wb ? rf_wdata_wb : rf_wdata_lsu);
	assign rvfi_rd_we_wb = rf_we_wb | rf_we_lsu;
	localparam [31:0] ibex_pkg_CSR_MEIX_BIT = 11;
	localparam [31:0] ibex_pkg_CSR_MFIX_BIT_HIGH = 30;
	localparam [31:0] ibex_pkg_CSR_MFIX_BIT_LOW = 16;
	localparam [31:0] ibex_pkg_CSR_MSIX_BIT = 3;
	localparam [31:0] ibex_pkg_CSR_MTIX_BIT = 7;
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_ext_pre_mip = 1'sb0;
		rvfi_ext_pre_mip[ibex_pkg_CSR_MSIX_BIT] = rvfi_ext_stage_pre_mip[RVFI_STAGES][17];
		rvfi_ext_pre_mip[ibex_pkg_CSR_MTIX_BIT] = rvfi_ext_stage_pre_mip[RVFI_STAGES][16];
		rvfi_ext_pre_mip[ibex_pkg_CSR_MEIX_BIT] = rvfi_ext_stage_pre_mip[RVFI_STAGES][15];
		rvfi_ext_pre_mip[ibex_pkg_CSR_MFIX_BIT_HIGH:ibex_pkg_CSR_MFIX_BIT_LOW] = rvfi_ext_stage_pre_mip[RVFI_STAGES][14-:15];
		rvfi_ext_post_mip = 1'sb0;
		rvfi_ext_post_mip[ibex_pkg_CSR_MSIX_BIT] = rvfi_ext_stage_post_mip[RVFI_STAGES - 1][17];
		rvfi_ext_post_mip[ibex_pkg_CSR_MTIX_BIT] = rvfi_ext_stage_post_mip[RVFI_STAGES - 1][16];
		rvfi_ext_post_mip[ibex_pkg_CSR_MEIX_BIT] = rvfi_ext_stage_post_mip[RVFI_STAGES - 1][15];
		rvfi_ext_post_mip[ibex_pkg_CSR_MFIX_BIT_HIGH:ibex_pkg_CSR_MFIX_BIT_LOW] = rvfi_ext_stage_post_mip[RVFI_STAGES - 1][14-:15];
	end
	assign rvfi_ext_nmi = rvfi_ext_stage_nmi[RVFI_STAGES];
	assign rvfi_ext_nmi_int = rvfi_ext_stage_nmi_int[RVFI_STAGES];
	assign rvfi_ext_debug_req = rvfi_ext_stage_debug_req[RVFI_STAGES];
	assign rvfi_ext_debug_mode = rvfi_ext_stage_debug_mode[RVFI_STAGES - 1];
	assign rvfi_ext_mcycle = rvfi_ext_stage_mcycle[RVFI_STAGES - 1];
	assign rvfi_ext_mhpmcounters = rvfi_ext_stage_mhpmcounters[RVFI_STAGES - 1];
	assign rvfi_ext_mhpmcountersh = rvfi_ext_stage_mhpmcountersh[RVFI_STAGES - 1];
	assign rvfi_ext_ic_scr_key_valid = rvfi_ext_stage_ic_scr_key_valid[RVFI_STAGES - 1];
	assign rvfi_ext_irq_valid = rvfi_ext_stage_irq_valid[RVFI_STAGES];
	assign rvfi_id_done = instr_id_done | (id_stage_i.controller_i.rvfi_flush_next & id_stage_i.controller_i.id_exception_o);
	generate
		if (WritebackStage) begin : gen_rvfi_wb_stage
			wire unused_instr_new_id;
			assign unused_instr_new_id = instr_new_id;
			assign rvfi_stage_valid_d[0] = (rvfi_id_done & ~dummy_instr_id) | (rvfi_stage_valid[0] & ~rvfi_wb_done);
			assign rvfi_stage_valid_d[1] = rvfi_wb_done;
			reg rvfi_instr_new_wb_q;
			assign rvfi_instr_new_wb = rvfi_instr_new_wb_q | (rvfi_stage_valid[0] & rvfi_stage_trap[0]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					rvfi_instr_new_wb_q <= 0;
				else
					rvfi_instr_new_wb_q <= rvfi_id_done;
			assign rvfi_trap_id = id_stage_i.controller_i.id_exception_o & ~(id_stage_i.ebrk_insn & id_stage_i.controller_i.ebreak_into_debug);
			assign rvfi_trap_wb = id_stage_i.controller_i.exc_req_lsu;
			assign rvfi_wb_done = rvfi_stage_valid[0] & (instr_done_wb | rvfi_stage_trap[0]);
		end
		else begin : gen_rvfi_no_wb_stage
			assign rvfi_stage_valid_d[0] = rvfi_id_done & ~dummy_instr_id;
			assign rvfi_instr_new_wb = instr_new_id;
			assign rvfi_trap_id = (id_stage_i.controller_i.exc_req_d | id_stage_i.controller_i.exc_req_lsu) & ~(id_stage_i.ebrk_insn & id_stage_i.controller_i.ebreak_into_debug);
			assign rvfi_trap_wb = 1'b0;
			assign rvfi_wb_done = instr_done_wb;
		end
	endgenerate
	assign rvfi_stage_order_d = (dummy_instr_id ? rvfi_stage_order[0] : rvfi_stage_order[0] + 64'd1);
	assign new_debug_req = debug_req_i & ~debug_mode;
	assign new_nmi = (irq_nm_i & ~nmi_mode) & ~debug_mode;
	assign new_nmi_int = (id_stage_i.controller_i.irq_nm_int & ~nmi_mode) & ~debug_mode;
	assign new_irq = ((irq_pending_o & (csr_mstatus_mie || (priv_mode_id == 2'b00))) & ~nmi_mode) & ~debug_mode;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			captured_valid <= 1'b0;
			captured_mip <= 1'sb0;
			captured_nmi <= 1'b0;
			captured_nmi_int <= 1'b0;
			captured_debug_req <= 1'b0;
			rvfi_irq_valid <= 1'b0;
		end
		else begin
			if ((~instr_valid_id & (((new_debug_req | new_irq) | new_nmi) | new_nmi_int)) & ((~captured_valid | (new_debug_req & ~captured_debug_req)) | ((new_nmi & ~captured_nmi) & ~captured_debug_req))) begin
				captured_valid <= 1'b1;
				captured_nmi <= irq_nm_i;
				captured_nmi_int <= id_stage_i.controller_i.irq_nm_int;
				captured_mip <= cs_registers_i.mip;
				captured_debug_req <= debug_req_i;
			end
			if ((((~instr_valid_id & ~new_debug_req) & ((new_irq | new_nmi) | new_nmi_int)) & ready_wb) & ~captured_valid)
				rvfi_irq_valid <= 1'b1;
			else
				rvfi_irq_valid <= 1'b0;
			if (if_stage_i.instr_valid_id_d)
				captured_valid <= 1'b0;
		end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rvfi_ext_stage_pre_mip[0] <= 1'sb0;
			rvfi_ext_stage_nmi[0] <= 1'sb0;
			rvfi_ext_stage_nmi_int[0] <= 1'sb0;
			rvfi_ext_stage_debug_req[0] <= 1'sb0;
		end
		else if ((if_stage_i.instr_valid_id_d & if_stage_i.instr_new_id_d) | rvfi_irq_valid) begin
			rvfi_ext_stage_pre_mip[0] <= (instr_valid_id | ~captured_valid ? cs_registers_i.mip : captured_mip);
			rvfi_ext_stage_nmi[0] <= (instr_valid_id | ~captured_valid ? irq_nm_i : captured_nmi);
			rvfi_ext_stage_nmi_int[0] <= (instr_valid_id | ~captured_valid ? id_stage_i.controller_i.irq_nm_int : captured_nmi_int);
			rvfi_ext_stage_debug_req[0] <= (instr_valid_id | ~captured_valid ? debug_req_i : captured_debug_req);
		end
	genvar _gv_i_2;
	generate
		for (_gv_i_2 = 0; _gv_i_2 < (RVFI_STAGES + 1); _gv_i_2 = _gv_i_2 + 1) begin : g_rvfi_irq_valid
			localparam i = _gv_i_2;
			if (i == 0) begin : g_rvfi_irq_valid_first_stage
				always @(posedge clk_i or negedge rst_ni)
					if (!rst_ni)
						rvfi_ext_stage_irq_valid[i] <= 1'b0;
					else
						rvfi_ext_stage_irq_valid[i] <= rvfi_irq_valid;
			end
			else begin : g_rvfi_irq_valid_other_stages
				always @(posedge clk_i or negedge rst_ni)
					if (!rst_ni)
						rvfi_ext_stage_irq_valid[i] <= 1'b0;
					else
						rvfi_ext_stage_irq_valid[i] <= rvfi_ext_stage_irq_valid[i - 1];
			end
		end
	endgenerate
	genvar _gv_i_3;
	localparam [1:0] ibex_pkg_CSR_MISA_MXL = 2'd1;
	generate
		for (_gv_i_3 = 0; _gv_i_3 < RVFI_STAGES; _gv_i_3 = _gv_i_3 + 1) begin : g_rvfi_stages
			localparam i = _gv_i_3;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni) begin
					rvfi_stage_halt[i] <= 1'sb0;
					rvfi_stage_trap[i] <= 1'sb0;
					rvfi_stage_intr[i] <= 1'sb0;
					rvfi_stage_order[i] <= 1'sb0;
					rvfi_stage_insn[i] <= 1'sb0;
					rvfi_stage_mode[i] <= 2'b11;
					rvfi_stage_ixl[i] <= ibex_pkg_CSR_MISA_MXL;
					rvfi_stage_rs1_addr[i] <= 1'sb0;
					rvfi_stage_rs2_addr[i] <= 1'sb0;
					rvfi_stage_rs3_addr[i] <= 1'sb0;
					rvfi_stage_pc_rdata[i] <= 1'sb0;
					rvfi_stage_pc_wdata[i] <= 1'sb0;
					rvfi_stage_mem_rmask[i] <= 1'sb0;
					rvfi_stage_mem_wmask[i] <= 1'sb0;
					rvfi_stage_valid[i] <= 1'sb0;
					rvfi_stage_rs1_rdata[i] <= 1'sb0;
					rvfi_stage_rs2_rdata[i] <= 1'sb0;
					rvfi_stage_rs3_rdata[i] <= 1'sb0;
					rvfi_stage_rd_wdata[i] <= 1'sb0;
					rvfi_stage_rd_addr[i] <= 1'sb0;
					rvfi_stage_mem_rdata[i] <= 1'sb0;
					rvfi_stage_mem_wdata[i] <= 1'sb0;
					rvfi_stage_mem_addr[i] <= 1'sb0;
					rvfi_ext_stage_pre_mip[i + 1] <= 1'sb0;
					rvfi_ext_stage_post_mip[i] <= 1'sb0;
					rvfi_ext_stage_nmi[i + 1] <= 1'sb0;
					rvfi_ext_stage_nmi_int[i + 1] <= 1'sb0;
					rvfi_ext_stage_debug_req[i + 1] <= 1'sb0;
					rvfi_ext_stage_debug_mode[i] <= 1'sb0;
					rvfi_ext_stage_mcycle[i] <= 1'sb0;
					rvfi_ext_stage_mhpmcounters[i] <= {10 {1'sb0}};
					rvfi_ext_stage_mhpmcountersh[i] <= {10 {1'sb0}};
					rvfi_ext_stage_ic_scr_key_valid[i] <= 1'sb0;
				end
				else begin
					rvfi_stage_valid[i] <= rvfi_stage_valid_d[i];
					if (i == 0) begin
						if (rvfi_id_done) begin
							rvfi_stage_halt[i] <= 1'sb0;
							rvfi_stage_trap[i] <= rvfi_trap_id;
							rvfi_stage_intr[i] <= rvfi_intr_d;
							rvfi_stage_order[i] <= rvfi_stage_order_d;
							rvfi_stage_insn[i] <= rvfi_insn_id;
							rvfi_stage_mode[i] <= {priv_mode_id};
							rvfi_stage_ixl[i] <= ibex_pkg_CSR_MISA_MXL;
							rvfi_stage_rs1_addr[i] <= rvfi_rs1_addr_d;
							rvfi_stage_rs2_addr[i] <= rvfi_rs2_addr_d;
							rvfi_stage_rs3_addr[i] <= rvfi_rs3_addr_d;
							rvfi_stage_pc_rdata[i] <= pc_id;
							rvfi_stage_pc_wdata[i] <= (pc_set ? branch_target_ex : pc_if);
							rvfi_stage_mem_rmask[i] <= rvfi_mem_mask_int;
							rvfi_stage_mem_wmask[i] <= (data_we_o ? rvfi_mem_mask_int : 4'b0000);
							rvfi_stage_rs1_rdata[i] <= rvfi_rs1_data_d;
							rvfi_stage_rs2_rdata[i] <= rvfi_rs2_data_d;
							rvfi_stage_rs3_rdata[i] <= rvfi_rs3_data_d;
							rvfi_stage_rd_addr[i] <= rvfi_rd_addr_d;
							rvfi_stage_rd_wdata[i] <= rvfi_rd_wdata_d;
							rvfi_stage_mem_rdata[i] <= rvfi_mem_rdata_d;
							rvfi_stage_mem_wdata[i] <= rvfi_mem_wdata_d;
							rvfi_stage_mem_addr[i] <= rvfi_mem_addr_d;
							rvfi_ext_stage_debug_mode[i] <= debug_mode;
							rvfi_ext_stage_mcycle[i] <= cs_registers_i.mcycle_counter_i.counter_val_o;
							rvfi_ext_stage_ic_scr_key_valid[i] <= cs_registers_i.cpuctrlsts_ic_scr_key_valid_q;
							begin : sv2v_autoblock_1
								reg signed [31:0] k;
								for (k = 0; k < 10; k = k + 1)
									begin
										rvfi_ext_stage_mhpmcounters[i][(9 - k) * 32+:32] <= cs_registers_i.mhpmcounter[k + 3][31:0];
										rvfi_ext_stage_mhpmcountersh[i][(9 - k) * 32+:32] <= cs_registers_i.mhpmcounter[k + 3][63:32];
									end
							end
						end
						if (rvfi_id_done | rvfi_ext_stage_irq_valid[i]) begin
							rvfi_ext_stage_pre_mip[i + 1] <= rvfi_ext_stage_pre_mip[i];
							rvfi_ext_stage_post_mip[i] <= cs_registers_i.mip;
							rvfi_ext_stage_nmi[i + 1] <= rvfi_ext_stage_nmi[i];
							rvfi_ext_stage_nmi_int[i + 1] <= rvfi_ext_stage_nmi_int[i];
							rvfi_ext_stage_debug_req[i + 1] <= rvfi_ext_stage_debug_req[i];
						end
					end
					else begin
						if (rvfi_wb_done) begin
							rvfi_stage_halt[i] <= rvfi_stage_halt[i - 1];
							rvfi_stage_trap[i] <= rvfi_stage_trap[i - 1] | rvfi_trap_wb;
							rvfi_stage_intr[i] <= rvfi_stage_intr[i - 1];
							rvfi_stage_order[i] <= rvfi_stage_order[i - 1];
							rvfi_stage_insn[i] <= rvfi_stage_insn[i - 1];
							rvfi_stage_mode[i] <= rvfi_stage_mode[i - 1];
							rvfi_stage_ixl[i] <= rvfi_stage_ixl[i - 1];
							rvfi_stage_rs1_addr[i] <= rvfi_stage_rs1_addr[i - 1];
							rvfi_stage_rs2_addr[i] <= rvfi_stage_rs2_addr[i - 1];
							rvfi_stage_rs3_addr[i] <= rvfi_stage_rs3_addr[i - 1];
							rvfi_stage_pc_rdata[i] <= rvfi_stage_pc_rdata[i - 1];
							rvfi_stage_pc_wdata[i] <= rvfi_stage_pc_wdata[i - 1];
							rvfi_stage_mem_rmask[i] <= rvfi_stage_mem_rmask[i - 1];
							rvfi_stage_mem_wmask[i] <= rvfi_stage_mem_wmask[i - 1];
							rvfi_stage_rs1_rdata[i] <= rvfi_stage_rs1_rdata[i - 1];
							rvfi_stage_rs2_rdata[i] <= rvfi_stage_rs2_rdata[i - 1];
							rvfi_stage_rs3_rdata[i] <= rvfi_stage_rs3_rdata[i - 1];
							rvfi_stage_mem_wdata[i] <= rvfi_stage_mem_wdata[i - 1];
							rvfi_stage_mem_addr[i] <= rvfi_stage_mem_addr[i - 1];
							rvfi_stage_rd_addr[i] <= rvfi_rd_addr_d;
							rvfi_stage_rd_wdata[i] <= rvfi_rd_wdata_d;
							rvfi_stage_mem_rdata[i] <= rvfi_mem_rdata_d;
							rvfi_ext_stage_debug_mode[i] <= rvfi_ext_stage_debug_mode[i - 1];
							rvfi_ext_stage_mcycle[i] <= rvfi_ext_stage_mcycle[i - 1];
							rvfi_ext_stage_ic_scr_key_valid[i] <= rvfi_ext_stage_ic_scr_key_valid[i - 1];
							rvfi_ext_stage_mhpmcounters[i] <= rvfi_ext_stage_mhpmcounters[i - 1];
							rvfi_ext_stage_mhpmcountersh[i] <= rvfi_ext_stage_mhpmcountersh[i - 1];
						end
						if (rvfi_wb_done | rvfi_ext_stage_irq_valid[i]) begin
							rvfi_ext_stage_pre_mip[i + 1] <= rvfi_ext_stage_pre_mip[i];
							rvfi_ext_stage_post_mip[i] <= rvfi_ext_stage_post_mip[i - 1];
							rvfi_ext_stage_nmi[i + 1] <= rvfi_ext_stage_nmi[i];
							rvfi_ext_stage_nmi_int[i + 1] <= rvfi_ext_stage_nmi_int[i];
							rvfi_ext_stage_debug_req[i + 1] <= rvfi_ext_stage_debug_req[i];
						end
					end
				end
		end
	endgenerate
	always @(*) begin
		if (_sv2v_0)
			;
		if (instr_first_cycle_id) begin
			rvfi_mem_addr_d = alu_adder_result_ex;
			rvfi_mem_wdata_d = lsu_wdata;
		end
		else begin
			rvfi_mem_addr_d = rvfi_mem_addr_q;
			rvfi_mem_wdata_d = rvfi_mem_wdata_q;
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		if (lsu_resp_valid)
			rvfi_mem_rdata_d = rf_wdata_lsu;
		else
			rvfi_mem_rdata_d = rvfi_mem_rdata_q;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rvfi_mem_addr_q <= 1'sb0;
			rvfi_mem_rdata_q <= 1'sb0;
			rvfi_mem_wdata_q <= 1'sb0;
		end
		else begin
			rvfi_mem_addr_q <= rvfi_mem_addr_d;
			rvfi_mem_rdata_q <= rvfi_mem_rdata_d;
			rvfi_mem_wdata_q <= rvfi_mem_wdata_d;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		case (lsu_type)
			2'b00: rvfi_mem_mask_int = 4'b1111;
			2'b01: rvfi_mem_mask_int = 4'b0011;
			2'b10: rvfi_mem_mask_int = 4'b0001;
			default: rvfi_mem_mask_int = 4'b0000;
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		if (instr_is_compressed_id)
			rvfi_insn_id = {16'b0000000000000000, instr_rdata_c_id};
		else
			rvfi_insn_id = instr_rdata_id;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		if (instr_first_cycle_id) begin
			rvfi_rs1_data_d = (rf_ren_a ? multdiv_operand_a_ex : {32 {1'sb0}});
			rvfi_rs1_addr_d = (rf_ren_a ? rf_raddr_a : {5 {1'sb0}});
			rvfi_rs2_data_d = (rf_ren_b ? multdiv_operand_b_ex : {32 {1'sb0}});
			rvfi_rs2_addr_d = (rf_ren_b ? rf_raddr_b : {5 {1'sb0}});
			rvfi_rs3_data_d = 1'sb0;
			rvfi_rs3_addr_d = 1'sb0;
		end
		else begin
			rvfi_rs1_data_d = rvfi_rs1_data_q;
			rvfi_rs1_addr_d = rvfi_rs1_addr_q;
			rvfi_rs2_data_d = rvfi_rs2_data_q;
			rvfi_rs2_addr_d = rvfi_rs2_addr_q;
			rvfi_rs3_data_d = multdiv_operand_a_ex;
			rvfi_rs3_addr_d = rf_raddr_a;
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rvfi_rs1_data_q <= 1'sb0;
			rvfi_rs1_addr_q <= 1'sb0;
			rvfi_rs2_data_q <= 1'sb0;
			rvfi_rs2_addr_q <= 1'sb0;
		end
		else begin
			rvfi_rs1_data_q <= rvfi_rs1_data_d;
			rvfi_rs1_addr_q <= rvfi_rs1_addr_d;
			rvfi_rs2_data_q <= rvfi_rs2_data_d;
			rvfi_rs2_addr_q <= rvfi_rs2_addr_d;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		if (rvfi_rd_we_wb) begin
			rvfi_rd_addr_d = rvfi_rd_addr_wb;
			if (rvfi_rd_addr_wb == 5'b00000)
				rvfi_rd_wdata_d = 1'sb0;
			else
				rvfi_rd_wdata_d = rvfi_rd_wdata_wb;
		end
		else if (rvfi_instr_new_wb) begin
			rvfi_rd_addr_d = 1'sb0;
			rvfi_rd_wdata_d = 1'sb0;
		end
		else begin
			rvfi_rd_addr_d = rvfi_rd_addr_q;
			rvfi_rd_wdata_d = rvfi_rd_wdata_q;
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rvfi_rd_addr_q <= 1'sb0;
			rvfi_rd_wdata_q <= 1'sb0;
		end
		else begin
			rvfi_rd_addr_q <= rvfi_rd_addr_d;
			rvfi_rd_wdata_q <= rvfi_rd_wdata_d;
		end
	generate
		if (WritebackStage) begin : g_rvfi_rf_wr_suppress_wb
			reg rvfi_stage_rf_wr_suppress_wb;
			wire rvfi_rf_wr_suppress_wb;
			assign rvfi_rf_wr_suppress_wb = ((instr_done_wb & ~rf_we_wb_o) & outstanding_load_wb) & lsu_load_resp_intg_err;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					rvfi_stage_rf_wr_suppress_wb <= 1'b0;
				else if (rvfi_wb_done)
					rvfi_stage_rf_wr_suppress_wb <= rvfi_rf_wr_suppress_wb;
			assign rvfi_ext_rf_wr_suppress = rvfi_stage_rf_wr_suppress_wb;
		end
		else begin : g_rvfi_no_rf_wr_suppress_wb
			assign rvfi_ext_rf_wr_suppress = 1'b0;
		end
	endgenerate
	assign rvfi_intr_d = (instr_first_cycle_id ? rvfi_set_trap_pc_q : rvfi_intr_q);
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_set_trap_pc_d = rvfi_set_trap_pc_q;
		if ((pc_set && (pc_mux_id == 3'd2)) && ((exc_pc_mux_id == 2'd0) || (exc_pc_mux_id == 2'd1)))
			rvfi_set_trap_pc_d = 1'b1;
		else if (rvfi_set_trap_pc_q && rvfi_id_done)
			rvfi_set_trap_pc_d = 1'b0;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rvfi_set_trap_pc_q <= 1'b0;
			rvfi_intr_q <= 1'b0;
		end
		else begin
			rvfi_set_trap_pc_q <= rvfi_set_trap_pc_d;
			rvfi_intr_q <= rvfi_intr_d;
		end
	initial _sv2v_0 = 0;
endmodule
