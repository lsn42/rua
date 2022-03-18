// execution
`include "define/const.v"
`include "define/inst.v"

`include "rtl/alu.v"

module ex(
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] inst,
    input wire[`XLEN_WIDTH] reg_in1, input wire[`XLEN_WIDTH] reg_in2,
    output wire[`XLEN_WIDTH] out
  );
  alu alu(.clk(clk), .rst(rst), .inst(inst), .rs1(reg_in1), .rs2(reg_in2), .rd(out));
endmodule
