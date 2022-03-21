// execution
`include "define/const.v"
`include "define/inst.v"

`include "rtl/alu.v"

module ex(
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] inst,

    input wire[`XLEN_WIDTH] regs_in1, input wire[`XLEN_WIDTH] regs_in2,
    output reg[`XLEN_WIDTH] regs_write_data,

    input wire[`XLEN_WIDTH] pc,
    output reg pc_jump,
    output reg[`XLEN_WIDTH] pc_jump_addr,

    output reg[`XLEN_WIDTH] mem_read_addr, input wire[`XLEN_WIDTH] mem_read_data,
    output reg mem_write_en, output reg[`XLEN_WIDTH] mem_write_addr,
    output reg[`XLEN_WIDTH] mem_write_data
  );

  reg[`XLEN_WIDTH] alu_in1, alu_in2;
  wire[`XLEN_WIDTH] alu_out;

  wire[6: 0] opcode = inst[6: 0];
  wire[2: 0] funct3 = inst[14: 12];
  wire[6: 0] funct7 = inst[31: 25];
  wire[6: 0] funct12 = inst[31: 20];

  wire[11: 0] imm_i = inst[31: 20];
  wire[11: 0] imm_s = {inst[31: 25], inst[11: 7]};
  wire[19: 0] imm_u = inst[31: 12];
  wire[11: 0] imm_b = {inst[31], inst[7], inst[30: 25], inst[11: 8]};
  wire[19: 0] imm_j = {inst[31], inst[19: 12], inst[20], inst[30: 21]};

  alu alu(.inst(inst), .in1(alu_in1), .in2(alu_in2), .out(alu_out));

  always @(* ) begin
    pc_jump = `false;
    mem_read_addr = 0;
    mem_write_en = `false;
    mem_write_addr = 0;
    mem_write_data = 0;
    case (opcode)
      `INST_OP_TYPE_R: begin
        alu_in1 = regs_in1;
        alu_in2 = regs_in2;
        regs_write_data = alu_out;
      end
      `INST_OP_TYPE_I_JALR: begin
        alu_in1 = regs_in1;
        alu_in2 = $signed(imm_i);
        regs_write_data = pc + 4;
        pc_jump = `true;
        pc_jump_addr = alu_out;
      end
      `INST_OP_TYPE_I_L: begin
        alu_in1 = regs_in1;
        alu_in2 = $signed(imm_i);
        regs_write_data = mem_read_data;
        mem_read_addr = 0;
      end
      `INST_OP_TYPE_I_I: begin
        alu_in1 = regs_in1;
        alu_in2 = $signed(imm_i);
        regs_write_data = alu_out;
      end
      `INST_OP_TYPE_I_S: begin
        ; // SYSTEM CALL
      end
      `INST_OP_TYPE_S: begin
        alu_in1 = regs_in1;
        alu_in2 = $signed(imm_s);
        regs_write_data = alu_out;
      end
      `INST_OP_TYPE_U_LUI: begin
        regs_write_data = alu_out;
      end
      `INST_OP_TYPE_U_AUIPC: begin
        alu_in1 = regs_in1;
        alu_in2 = {imm_u, {12{1'b0}}};
        regs_write_data = alu_out;
      end
      `INST_OP_TYPE_B: begin
        alu_in1 = regs_in1;
        alu_in2 = regs_in2;
        pc_jump = alu_out ? `true : `false;
        pc_jump_addr = alu_out? pc + imm_b : 0;
      end
      `INST_OP_TYPE_J_JAL: begin
        pc_jump = `true;
        pc_jump_addr = pc + imm_j;
      end
    endcase
  end
endmodule
