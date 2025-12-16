`timescale 1 ns / 1 ps

module tb;
  logic a = 0;
  logic b = 1;
  logic c, d;
  logic clk_i = 0;
  initial forever #1 clk_i = !clk_i;
  int counter = 0;
  adder adder_ (
      .clk_i(clk_i),
      .a(a),
      .b(b),
      .c(c),
      .d(d)
  );
  always @(negedge clk_i) begin
    a <= a ^ 1;
    $display("%d", d);
    if (++counter > 100) begin
      $finish;
    end
  end

  initial begin
    if ($test$plusargs("trace") != 0) begin
      $dumpfile("sim.vcd");
      $dumpvars();
    end
  end
endmodule
