primitive altos_dff_err (q, clk, d);
	output q;
	reg q;
	input clk, d;

	table
		(0x) ? : ? : 0;
		(1x) ? : ? : 1;
	endtable
endprimitive

primitive altos_dff (q, v, clk, d, xcr);
	output q;
	reg q;
	input v, clk, d, xcr;

	table
		*  ?   ? ? : ? : x;
		? (x1) 0 0 : ? : 0;
		? (x1) 1 0 : ? : 1;
		? (x1) 0 1 : 0 : 0;
		? (x1) 1 1 : 1 : 1;
		? (x1) ? x : ? : -;
		? (bx) 0 ? : 0 : -;
		? (bx) 1 ? : 1 : -;
		? (x0) b ? : ? : -;
		? (x0) ? x : ? : -;
		? (01) 0 ? : ? : 0;
		? (01) 1 ? : ? : 1;
		? (10) ? ? : ? : -;
		?  b   * ? : ? : -;
		?  ?   ? * : ? : -;
	endtable
endprimitive

`timescale 1ns/10ps
`celldefine
module DFFHQNx1_ASAP7_75t_R (QN, D, CLK);
	output QN;
	input D, CLK;
	reg notifier;
	wire delayed_D, delayed_CLK;

	// Function
	wire int_fwire_d, int_fwire_IQN, xcr_0;

	not (int_fwire_d, delayed_D);
	altos_dff_err (xcr_0, delayed_CLK, int_fwire_d);
	altos_dff (int_fwire_IQN, notifier, delayed_CLK, int_fwire_d, xcr_0);
	buf (QN, int_fwire_IQN);

	// Timing
	specify
		(posedge CLK => (QN+:!D)) = 0;
		$setuphold (posedge CLK, posedge D, 0, 0, notifier,,, delayed_CLK, delayed_D);
		$setuphold (posedge CLK, negedge D, 0, 0, notifier,,, delayed_CLK, delayed_D);
		$width (posedge CLK &&& D, 0, 0, notifier);
		$width (negedge CLK &&& D, 0, 0, notifier);
		$width (posedge CLK &&& ~D, 0, 0, notifier);
		$width (negedge CLK &&& ~D, 0, 0, notifier);
	endspecify
endmodule
`endcelldefine
 
module t;
    reg CLK = 0;
    reg D = 0;
    reg Q1, Q2, Q3;
    always #5 CLK = ~CLK;
    always #20 D = ~D;

    always @(posedge CLK) Q2 <= ~D;
    always @(posedge CLK) Q3 = ~D;
    
    `ifndef VERILATOR
        always @(edge Q3) #0 $display("Inactive");
    `endif

    DFFHQNx1_ASAP7_75t_R dff (.QN(Q1), .*);

    always @(edge Q1) $display("DFFHQNx1_ASAP7_75t_R    | D=%b Q1=%b Q2=%b Q3=%b", D, Q1, Q2, Q3);
    always @(edge Q2) $display("@(posedge CLK) Q2 <= ~D | D=%b Q1=%b Q2=%b Q3=%b", D, Q1, Q2, Q3);
    always @(edge Q3) $display("@(posedge CLK) Q3 = ~D  | D=%b Q1=%b Q2=%b Q3=%b", D, Q1, Q2, Q3);

    initial begin
        $dumpfile("dff.vcd");
        $dumpvars;
        #1000 $finish;
    end
endmodule
