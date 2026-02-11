module adder_core (
    input  logic clk_i,
    input  logic a,
    input  logic b,
    input logic unused,
    output logic c
  );
  always @(posedge clk_i) c <= a + b;
endmodule
