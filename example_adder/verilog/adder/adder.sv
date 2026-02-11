module adder (
    input  logic clk_i,
    input  logic a,
    input  logic b,
    output logic c,
    output logic d
);
  logic unused = 0;
  adder_core core0(.clk_i(clk_i), .a(a), .b(b), .c(c), .unused(unused));
  adder_core core1(.clk_i(clk_i), .a(c), .b(b), .c(d), .unused(unused));
endmodule
