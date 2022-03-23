`include "define/const.v"
`include "define/inst.v"

module id(
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] inst,

    output reg[`REG_ADDR] regs_addr1, output reg[`REG_ADDR] regs_addr2,
    output reg regs_write_en,
    output reg[`REG_ADDR] regs_write_addr,

    output reg mem_read_en, output reg mem_write_en
  );

  wire[6: 0] opcode = inst[6: 0];
  wire[2: 0] funct3 = inst[14: 12];
  wire[6: 0] funct7 = inst[31: 25];

  wire[`REG_ADDR] rd = inst[11: 7];
  wire[`REG_ADDR] rs1 = inst[19: 15];
  wire[`REG_ADDR] rs2 = inst[24: 20];

  // combinational logic
  // 组合逻辑
  always @(* ) begin
    regs_addr1 <= 0;
    regs_addr2 <= 0;
    regs_write_en <= `false;
    regs_write_addr <= 0;
    case (opcode)
      `INST_OP_TYPE_R: begin
        regs_addr1 <= rs1;
        regs_addr2 <= rs2;
        regs_write_en <= `true;
        regs_write_addr <= rd;
      end
      `INST_OP_TYPE_I_JALR,
      `INST_OP_TYPE_I_I,
      `INST_OP_TYPE_I_S: begin
        regs_addr1 <= rs1;
        regs_write_en <= `true;
        regs_write_addr <= rd;
      end
      `INST_OP_TYPE_I_L:begin
        regs_addr1 <= rs1;
        regs_write_en <= `true;
        regs_write_addr <= rd;
        mem_read_en <= `true;
      end
      `INST_OP_TYPE_S: begin
        regs_addr1 <= rs1;
        regs_addr2 <= rs2;
        mem_write_en <= `true;
      end
      `INST_OP_TYPE_U_LUI,
      `INST_OP_TYPE_U_AUIPC: begin
        regs_write_en <= `true;
        regs_write_addr <= rd;
      end
      `INST_OP_TYPE_B: begin
        regs_addr1 <= rs1;
        regs_addr2 <= rs2;
      end
      `INST_OP_TYPE_J_JAL: begin
        regs_write_addr <= rd;
      end
    endcase
  end
endmodule
