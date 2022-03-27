// instruction decode
`include "define/const.v"
`include "define/inst.v"

module id(
    input wire[`XLEN_WIDTH] inst, input wire[`XLEN_WIDTH] inst_addr,

    output reg[`REG_ADDR] regs_addr1, input wire[`XLEN_WIDTH] regs_data1,
    output reg[`REG_ADDR] regs_addr2, input wire[`XLEN_WIDTH] regs_data2,

    output reg[`XLEN_WIDTH] operand1, output reg[`XLEN_WIDTH] operand2,

    input wire pause, output reg pause_signal
  );

  // instruction identification
  // 指令识别
  wire[6: 0] opcode = inst[6: 0];
  wire[2: 0] funct3 = inst[14: 12];
  wire[6: 0] funct7 = inst[31: 25];
  wire[6: 0] funct12 = inst[31: 20];

  // the address of register source and destination
  // 源寄存器和目的寄存器的地址
  wire[`REG_ADDR] rs1 = inst[19: 15];
  wire[`REG_ADDR] rs2 = inst[24: 20];
  wire[`REG_ADDR] rd = inst[11: 7];

  // seperate different kinds of immediate from instruction
  // 从指令中分割不同种类的立即数
  wire[11: 0] imm_i = inst[31: 20];
  wire[11: 0] imm_s = {inst[31: 25], inst[11: 7]};
  wire[19: 0] imm_u = inst[31: 12];
  wire[11: 0] imm_b = {inst[31], inst[7], inst[30: 25], inst[11: 8]};
  wire[19: 0] imm_j = {inst[31], inst[19: 12], inst[20], inst[30: 21]};

  // combinational logic
  // 组合逻辑
  always @(* ) begin
    // TODO: pause

    // default value
    // 默认值
    regs_addr1 = 0;
    regs_addr2 = 0;
    operand1 = 0;
    operand2 = 0;
    pause_signal = `false;

    case (opcode)
      `INST_OP_TYPE_R: begin
        regs_addr1 = rs1;
        regs_addr2 = rs2;
        operand1 = regs_data1;
        operand2 = regs_data2;
      end
      `INST_OP_TYPE_I_JALR: begin
        regs_addr1 = rs1;
        operand1 = regs_data1;
        operand2 = $signed(imm_i);
        pause_signal = `true;
      end
      `INST_OP_TYPE_I_I: begin
        regs_addr1 = rs1;
        operand1 = regs_data1;
        // SLLI/SRLI/SRAL won't affect by sign extension
        // SLLI/SRLI/SRAL不会受符号扩展影响
        operand2 = $signed(imm_i);
      end
      `INST_OP_TYPE_I_L: begin
        regs_addr1 = rs1;
        operand1 = regs_data1;
        // SLLI/SRLI/SRAL won't affect by sign extension
        // SLLI/SRLI/SRAL不会受符号扩展影响
        operand2 = $signed(imm_i);
        pause_signal = `true;
      end
      `INST_OP_TYPE_I_S: begin
        // no need to do anything currently
        // 暂时不知道SYSTEM CALL指令如何处理
        ;
      end
      `INST_OP_TYPE_S: begin
        regs_addr1 = rs1;
        regs_addr2 = rs2;
        operand1 = regs_data1;
        operand2 = regs_data2;
      end
      `INST_OP_TYPE_U_LUI,
      `INST_OP_TYPE_U_AUIPC: begin
        operand1 = inst_addr;
        operand2 = {imm_u, {12{1'b0}}};
      end
      `INST_OP_TYPE_B: begin
        regs_addr1 = rs1;
        regs_addr2 = rs2;
        operand1 = regs_data1;
        operand2 = regs_data2;
        pause_signal = `true;
      end
      `INST_OP_TYPE_J_JAL: begin
        operand1 = inst_addr;
        operand2 = $signed({imm_j, 1'b0});
        pause_signal = `true;
      end
    endcase
  end

endmodule
