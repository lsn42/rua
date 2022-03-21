`include "rtl/alu.v"

`timescale 1ps/1ps

module alu_tb();
  reg clk, rst;

  reg [31: 0] inst;
  reg [31: 0] a;
  reg [31: 0] b;
  wire [31: 0] c;

  alu dut(.inst(inst), .in1(a), .in2(b), .out(c));

  parameter clk_period = 10;
  initial
    clk = 0;
  always#(clk_period / 2) clk = ~clk;

  initial begin
    $dumpfile("./wave/alu_tb.vcd");
    $dumpvars;
    inst = 32'b0000000_00000_00000_000_00000_0110011;
    a = 32'hCAFEBABE;
    b = 32'hDEADBEEF;
    // c = 32'hA9AC79AD;
    @(posedge clk);
    $finish;
  end

endmodule
