module adder (
    input  logic clk_i,
    input  logic a,
    input  logic b,
    input logic unused,
    output logic c,
    output logic d
);
  adder_core core0(.clk_i(clk_i), .a(a), .b(b), .c(c), .unused(unused));
  adder_core core1(.clk_i(clk_i), .a(c), .b(b), .c(d), .unused(unused));
endmodule

module adder_core (
    input  logic clk_i,
    input  logic a,
    input  logic b,
    input logic unused,
    output logic c
  );
  always @(posedge clk_i) c <= a + b;
endmodule
