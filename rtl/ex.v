// execution
`include "define/const.v"
`include "define/inst.v"

module ex(
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] inst, input wire[`XLEN_WIDTH]inst_addr,

    output reg[`REG_ADDR] regs_addr1, output reg[`REG_ADDR] regs_addr2,
    input wire[`XLEN_WIDTH] regs_in1, input wire[`XLEN_WIDTH] regs_in2,
    output reg regs_write_en,
    output reg[`REG_ADDR] regs_write_addr,
    output reg[`XLEN_WIDTH] regs_write_data,

    output reg pc_jump, output reg[`XLEN_WIDTH] pc_jump_addr,

    output reg[`XLEN_WIDTH] mem_read_addr, input wire[`XLEN_WIDTH] mem_read_data,
    output reg mem_write_en, output reg[`XLEN_WIDTH] mem_write_addr,
    output reg[`XLEN_WIDTH] mem_write_data
  );

  wire[6: 0] opcode = inst[6: 0];
  wire[2: 0] funct3 = inst[14: 12];
  wire[6: 0] funct7 = inst[31: 25];
  wire[6: 0] funct12 = inst[31: 20];

  wire[`REG_ADDR] rd = inst[11: 7];
  wire[`REG_ADDR] rs1 = inst[19: 15];
  wire[`REG_ADDR] rs2 = inst[24: 20];

  wire[11: 0] imm_i = inst[31: 20];
  wire[11: 0] imm_s = {inst[31: 25], inst[11: 7]};
  wire[19: 0] imm_u = inst[31: 12];
  wire[11: 0] imm_b = {inst[31], inst[7], inst[30: 25], inst[11: 8]};
  wire[19: 0] imm_j = {inst[31], inst[19: 12], inst[20], inst[30: 21]};

  // TODO: lots of the computation operation done by copilot, still need more carefully check

  always @(* ) begin
    pc_jump = `false;
    regs_addr1 <= 0;
    regs_addr2 <= 0;
    regs_write_en <= `false;
    regs_write_addr <= 0;
    regs_write_data = 0;
    mem_read_addr = 0;
    mem_write_en = `false;
    mem_write_addr = 0;
    mem_write_data = 0;
    case (opcode)
      `INST_OP_TYPE_R: begin
        regs_addr1 <= rs1;
        regs_addr2 <= rs2;
        regs_write_en <= `true;
        regs_write_addr <= rd;
        case (funct3)
          `INST_FUNCT3_ADD, `INST_FUNCT3_SUB: begin
            if (funct7 == `INST_FUNCT7_1) begin // ADD
              regs_write_data = regs_in1 + regs_in2;
            end
            else if (funct7 == `INST_FUNCT7_2) begin // SUB
              regs_write_data = regs_in1 - regs_in2;
            end
          end
          `INST_FUNCT3_SLL: begin
            regs_write_data = regs_in1 << regs_in2[4: 0];
          end
          `INST_FUNCT3_SLT: begin
            regs_write_data = (regs_in1 < regs_in2) ? 1 : 0;
          end
          `INST_FUNCT3_SLTU: begin
            regs_write_data = ($unsigned(regs_in1) << $unsigned(regs_in2))? 1 : 0;
          end
          `INST_FUNCT3_XOR: begin
            regs_write_data = regs_in1 ^ regs_in2;
          end
          `INST_FUNCT3_SRL, `INST_FUNCT3_SRA: begin
            if (funct7 == `INST_FUNCT7_1) begin // SRL
              regs_write_data = regs_in1 >> regs_in2[4: 0];
            end
            else if (funct7 == `INST_FUNCT7_2) begin // SRA
              regs_write_data = $signed(regs_in1) >> regs_in2[4: 0];
            end
          end
          `INST_FUNCT3_OR: begin
            regs_write_data = regs_in1 | regs_in2;
          end
          `INST_FUNCT3_AND: begin
            regs_write_data = regs_in1 & regs_in2;
          end
        endcase
      end
      `INST_OP_TYPE_I_JALR: begin
        regs_addr1 <= rs1;
        regs_write_en <= `true;
        regs_write_addr <= rd;
        regs_write_data = inst_addr + 4;
        pc_jump = `true;
        pc_jump_addr = regs_in1 + $signed(imm_i);
      end
      `INST_OP_TYPE_I_L: begin
        regs_addr1 <= rs1;
        regs_write_en <= `true;
        regs_write_addr <= rd;
        regs_write_data = mem_read_data;
        mem_read_addr = regs_in1 + $signed(imm_i);
      end
      `INST_OP_TYPE_I_I: begin
        regs_addr1 <= rs1;
        regs_write_en <= `true;
        regs_write_addr <= rd;
        case (funct3)
          `INST_FUNCT3_ADDI: begin
            regs_write_data = $signed(regs_in1) + $signed(imm_i);
          end
          `INST_FUNCT3_SLTI: begin
            regs_write_data = (regs_in1 < imm_i) ? 1 : 0;
          end
          `INST_FUNCT3_SLTIU: begin
            regs_write_data = ($unsigned(regs_in1) < $unsigned(imm_i)) ? 1 : 0;
          end
          `INST_FUNCT3_XORI: begin
            regs_write_data = regs_in1 ^ imm_i;
          end
          `INST_FUNCT3_ORI: begin
            regs_write_data = regs_in1 | imm_i;
          end
          `INST_FUNCT3_ANDI: begin
            regs_write_data = regs_in1 & imm_i;
          end
          `INST_FUNCT3_SLLI: begin
            regs_write_data = regs_in1 << imm_i[24: 20];
          end
          `INST_FUNCT3_SRLI, `INST_FUNCT3_SRAI: begin
            if (funct7 == `INST_FUNCT7_1) begin // SRLI
              regs_write_data = regs_in1 >> imm_i[24: 20];
            end
            else if (funct7 == `INST_FUNCT7_2) begin // SRAI
              regs_write_data = regs_in1 << imm_i[24: 20];
            end
          end
        endcase
      end
      `INST_OP_TYPE_I_S: begin
        // SYSTEM CALL
        if (funct12 == `INST_FUNCT12_1) begin // ECALL
          ;
        end
        else if (funct12 == `INST_FUNCT12_2) begin // EBREAK
          ;
        end
      end
      `INST_OP_TYPE_S: begin
        regs_addr1 <= rs1;
        regs_addr2 <= rs2;
        regs_write_data = regs_in1 + $signed(imm_s);
      end
      `INST_OP_TYPE_U_LUI: begin
        regs_write_en <= `true;
        regs_write_addr <= rd;
        regs_write_data = regs_in1 + {imm_u, {12{1'b0}}};
      end
      `INST_OP_TYPE_U_AUIPC: begin
        regs_write_en <= `true;
        regs_write_addr <= rd;
        regs_write_data = inst_addr + {imm_u, {12{1'b0}}};
      end
      `INST_OP_TYPE_B: begin
        regs_addr1 <= rs1;
        regs_addr2 <= rs2;
        case (funct3)
          `INST_FUNCT3_BEQ: begin
            pc_jump = (regs_in1 == regs_in2) ? `true : `false;
          end
          `INST_FUNCT3_BNE: begin
            pc_jump = (regs_in1 != regs_in2) ? `true : `false;
          end
          `INST_FUNCT3_BLT: begin
            pc_jump = ($signed(regs_in1) < $signed(regs_in2)) ? `true : `false;
          end
          `INST_FUNCT3_BGE: begin
            pc_jump = ($signed(regs_in1) >= $signed(regs_in2)) ? `true : `false;
          end
          `INST_FUNCT3_BLTU: begin
            pc_jump = ($unsigned(regs_in1) < $unsigned(regs_in2)) ? `true : `false;
          end
          `INST_FUNCT3_BGEU: begin
            pc_jump = ($unsigned(regs_in1) >= $unsigned(regs_in2)) ? `true : `false;
          end
        endcase
        pc_jump_addr = pc_jump ? $signed(inst_addr) + $signed(imm_b) : 0;
      end
      `INST_OP_TYPE_J_JAL: begin
        regs_write_en <= `true;
        regs_write_addr <= rd;
        regs_write_data <= inst_addr + 4;
        pc_jump = `true;
        pc_jump_addr = $signed(inst_addr) + $signed({imm_j, 1'b0});
      end
    endcase
  end
endmodule
