`include "rtl/alu.v"

`timescale 1ps/1ps

module alu_tb();
  reg clk, rst;
  reg [31: 0] rs1;
  reg [31: 0] rs2;
  reg [6: 0] opcode;
  reg [2: 0] funct3;
  reg [6: 0] funct7;
  wire [31: 0] rd;
  alu dut(.clk(clk), .rst(rst),
          .rs1(rs1), .rs2(rs2),
          .opcode(opcode), .funct3(funct3), .funct7(funct7),
          .rd(rd));

  parameter clk_period = 10;
  initial
    clk = 0;
  always#(clk_period / 2) clk = ~clk;

  initial
  begin
    $dumpfile(".\\wave\\alu_tb.vcd");
    $dumpvars;
    @(posedge clk);
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    rs1 = 114514;
    rs2 = 1919810;
    @(posedge clk);
    $finish;
  end

endmodule
