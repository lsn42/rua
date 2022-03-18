`include "rtl/alu.v"

`timescale 1ps/1ps

module alu_tb();
  reg clk, rst;
  
  reg [31: 0] inst;
  reg [31: 0] rs1;
  reg [31: 0] rs2;
  wire [31: 0] rd;

  alu dut(.clk(clk), .rst(rst), .inst(inst),
          .rs1(rs1), .rs2(rs2), .rd(rd));

  parameter clk_period = 10;
  initial
    clk = 0;
  always#(clk_period / 2) clk = ~clk;

  initial
  begin
    $dumpfile("./wave/alu_tb.vcd");
    $dumpvars;
    @(posedge clk);
    inst = 32'b0000000_00000_00000_000_00000_0110011;
    rs1 = 32'hCAFEBABE;
    rs2 = 32'hDEADBEEF;
    // rd = 32'hA9AC79AD;
    @(posedge clk);
    $finish;
  end

endmodule
