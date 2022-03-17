`include "define/const.v"
`include "define/inst.v"

module id(
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] inst
  );
  wire[6: 0] opcode = inst[6: 0];
  wire[2: 0] funct3 = inst[14: 12];
  wire[6: 0] funct7 = inst[31: 25];

  wire[`REG_ADDR] rd = inst[11: 7];
  wire[`REG_ADDR] rs1 = inst[19: 15];
  wire[`REG_ADDR] rs2 = inst[24: 20];

  wire[11: 0] imm12 = inst[31: 20];

  // combinational logic
  // 组合逻辑
  always @(* ) begin
    case (opcode)
      `INST_OP_TYPE_R: begin
      end
    endcase
  end
endmodule
