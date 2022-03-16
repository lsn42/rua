`include "../define/const.v"
`include "../define/inst.v"

module alu(
    input wire clk, input wire rst,
    input wire[`XLEN_ADDR] rs1, input wire[`XLEN_ADDR] rs2,
    input wire[`OPCODE_WIDTH] opcode,
    input wire[`FUNCT3_WIDTH] funct3, input wire [`FUNCT7_WIDTH] funct7,
    output reg [`XLEN_ADDR] rd
  );
  always @(* ) begin
    case (opcode)
      `INST_OP_TYPE_R: begin
        case (funct3)
          `INST_FUNCT3_ADD: begin
            rd <= rs1 + rs2;
          end
          `INST_FUNCT3_SUB: begin
            rd <= rs1 - rs2;
          end
          `INST_FUNCT3_SLL: begin
            rd <= rs1 << rs2[4:0];
          end
          `INST_FUNCT3_SLT: begin
            rd <= (rs1 < rs2) ? 1 : 0;
          end
          `INST_FUNCT3_SLTU: begin
            rd <= ($unsigned(rs1) < $unsigned(rs2)) ? 1 : 0;
          end
          `INST_FUNCT3_XOR: begin
            rd <= rs1 ^ rs2;
          end
          `INST_FUNCT3_SRL: begin
            rd <= rs1 >> rs2[4:0];
          end
          `INST_FUNCT3_SRA: begin
            rd <= $signed(rs1) >> rs2[4:0];
          end
          `INST_FUNCT3_OR: begin
            rd <= rs1 | rs2;
          end
          `INST_FUNCT3_AND: begin
            rd <= rs1 & rs2;
          end
        endcase
      end
    endcase
  end
endmodule
