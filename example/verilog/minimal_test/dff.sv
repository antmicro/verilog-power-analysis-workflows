primitive prim_comb (q, clk, d);
    output q;
    input clk, d;

    table
        0 0 : 0 ;
        0 1 : 1 ;
        1 0 : 0 ;
        1 1 : 1 ;
    endtable
endprimitive

primitive prim_seq (q, clk, d);
    output q;
    reg q;
    input clk, d;

    table
        (01) 0 : ? : 0 ;
        (01) 1 : ? : 1 ;
        (10) 0 : ? : 0 ;
        (10) 1 : ? : 1 ;
    endtable
endprimitive

module cell_comb (QN, D, CLK);
    output reg QN;
    input D, CLK;

    prim_comb (QN, CLK, D);
endmodule

module cell_seq (QN, D, CLK);
    output reg QN;
    input D, CLK;

    prim_seq (QN, CLK, D);
endmodule
 
integer log_fd;

module t;
    reg CLK = 0;
    reg D = 0;
    reg Q1, Q2, Q3, Q4;
    always #5 CLK = ~CLK;
    always #20 D = ~D;

    initial begin
        log_fd = $fopen("logs", "w");
    end

    final begin
        $fclose(log_fd);
    end

    always @(posedge CLK) Q3 <= D;
    always @(posedge CLK) Q4 = D;
    
    `ifndef VERILATOR
        always @(posedge CLK) #0 $display("Inactive");
    `endif

    cell_comb comb (.QN(Q1), .*);
    cell_seq seq (.QN(Q2), .*);

    always @(posedge Q1)
    begin
        $fwrite(log_fd, "Q1\n");
        $fflush(log_fd);
        $display("UDP comb               | D=%b Q1=%b Q2=%b Q3=%b Q4=%b", D, Q1, Q2, Q3, Q4);
    end

    always @(posedge Q2)
    begin
        $fwrite(log_fd, "Q2\n");
        $fflush(log_fd);
        $display("UDP seq                | D=%b Q1=%b Q2=%b Q3=%b Q4=%b", D, Q1, Q2, Q3, Q4);
    end

    always @(posedge Q3)
    begin
        $fwrite(log_fd, "Q3\n\n");
        $fflush(log_fd);
        $display("@(posedge CLK) Q2 <= D | D=%b Q1=%b Q2=%b Q3=%b Q4=%b\n----------------", D, Q1, Q2, Q3, Q4);
    end

    always @(posedge Q4)
    begin
        $fwrite(log_fd, "Q4\n");
        $fflush(log_fd);
        $display("@(posedge CLK) Q3 = D  | D=%b Q1=%b Q2=%b Q3=%b Q4=%b", D, Q1, Q2, Q3, Q4);
    end

    initial begin
        #200 $finish;
    end
endmodule