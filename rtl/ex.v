// execution
`include "define/const.v"
`include "define/inst.v"

module ex(
    // input: instruction and it's address
    // 输入：指令与其地址
    input wire[`XLEN_WIDTH] inst, input wire[`XLEN_WIDTH] inst_addr,
    // input: two operands
    // 输入：两个操作数
    input wire[`XLEN_WIDTH] operand1, input wire[`XLEN_WIDTH] operand2,
    // output: register write enable, address and writing data
    // 输出：寄存器写使能，地址和将写入的数据
    output reg regs_write_en, output reg[`REG_ADDR] regs_write_addr,
    output reg[`XLEN_WIDTH] regs_write_data,
    // output: jump flag and jump address, pause flag
    // 输出：跳转标志和跳转地址，暂停标志
    output reg pc_jump, output reg[`XLEN_WIDTH] pc_jump_addr,
    // output: memory load enable, address and destination register of loaded data
    // 输出：存储器加载使能，地址和加载的数据的目的寄存器
    output reg mem_load_en, output reg[`XLEN_WIDTH] mem_load_addr,
    output reg[`REG_ADDR] mem_load_regs_addr,
    // output: memory store enable, address and storing data
    // 输出：存储器存储使能，地址和将存储的数据
    output reg[1: 0] mem_store_mode, output reg[`XLEN_WIDTH] mem_store_addr,
    output reg[`XLEN_WIDTH] mem_store_data,
    // output: unpause and flush signal according to instruction type
    // 输出：根据指令类型输出的恢复和清洗信号
    output reg unpause_signal, output reg flush_signal
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

  // TODO: lots of the computation operation done by copilot, still need more carefully check

  always @(* ) begin

    // default value
    // 默认值
    regs_write_en = `false;
    regs_write_addr = 0;
    regs_write_data = 0;

    pc_jump = `false;
    pc_jump_addr = 0;

    mem_load_en = `false;
    mem_load_addr = 0;
    mem_load_regs_addr = 0;
    mem_store_mode = 2'b00;
    mem_store_addr = 0;
    mem_store_data = 0;

    unpause_signal = `false;
    flush_signal = `false;

    case (opcode)
      `INST_OP_TYPE_R: begin
        regs_write_en = `true;
        regs_write_addr = rd;
        case (funct3)
          `INST_FUNCT3_ADD_SUB: begin
            if (funct7 == `INST_FUNCT7_1) begin // ADD
              regs_write_data = operand1 + operand2;
            end
            else if (funct7 == `INST_FUNCT7_2) begin // SUB
              regs_write_data = operand1 - operand2;
            end
          end
          `INST_FUNCT3_SLL: begin
            regs_write_data = operand1 << operand2[4: 0];
          end
          `INST_FUNCT3_SLT: begin
            regs_write_data = ($signed(operand1) < $signed(operand2)) ? 1 : 0;
          end
          `INST_FUNCT3_SLTU: begin
            regs_write_data = ($unsigned(operand1) < $unsigned(operand2))? 1 : 0;
          end
          `INST_FUNCT3_XOR: begin
            regs_write_data = operand1 ^ operand2;
          end
          `INST_FUNCT3_SRL_SRA: begin
            if (funct7 == `INST_FUNCT7_1) begin // SRL
              regs_write_data = $unsigned(operand1) >> operand2[4: 0];
            end
            else if (funct7 == `INST_FUNCT7_2) begin // SRA
              regs_write_data = $signed(operand1) >> operand2[4: 0];
            end
          end
          `INST_FUNCT3_OR: begin
            regs_write_data = operand1 | operand2;
          end
          `INST_FUNCT3_AND: begin
            regs_write_data = operand1 & operand2;
          end
        endcase
      end

      `INST_OP_TYPE_I_JALR: begin
        regs_write_en = `true;
        regs_write_addr = rd;
        regs_write_data = inst_addr + 4;
        pc_jump = `true;
        pc_jump_addr = operand1 + operand2;
        unpause_signal = `true;
        flush_signal = `true;
      end

      `INST_OP_TYPE_I_L: begin
        mem_load_en = `true;
        mem_load_addr = operand1 + operand2;
        mem_load_regs_addr = rd;
      end

      `INST_OP_TYPE_I_I: begin
        regs_write_en = `true;
        regs_write_addr = rd;
        case (funct3)
          `INST_FUNCT3_ADDI: begin
            regs_write_data = $signed(operand1) + $signed(operand2);
          end
          `INST_FUNCT3_SLTI: begin
            regs_write_data = ($signed(operand1) < $signed(operand2)) ? 1 : 0;
          end
          `INST_FUNCT3_SLTIU: begin
            // "the immediate is first sign-extended to XLEN bits then treated as an unsigned number"
            regs_write_data = ($unsigned(operand1) < $unsigned(operand2)) ? 1 : 0;
          end
          `INST_FUNCT3_XORI: begin
            regs_write_data = operand1 ^ operand2;
          end
          `INST_FUNCT3_ORI: begin
            regs_write_data = operand1 | operand2;
          end
          `INST_FUNCT3_ANDI: begin
            regs_write_data = operand1 & operand2;
          end
          `INST_FUNCT3_SLLI: begin
            regs_write_data = operand1 << operand2[4: 0];
          end
          `INST_FUNCT3_SRLI_SRAI: begin
            if (funct7 == `INST_FUNCT7_1) begin // SRLI
              regs_write_data = operand1 >> operand2[4: 0];
            end
            else if (funct7 == `INST_FUNCT7_2) begin // SRAI
              regs_write_data = operand1 << operand2[4: 0];
            end
          end
        endcase
      end

      `INST_OP_TYPE_I_S: begin
        // no need to do anything currently
        // 暂时不知道SYSTEM CALL指令如何处理
        if (funct12 == `INST_FUNCT12_1) begin // ECALL
          ;
        end
        else if (funct12 == `INST_FUNCT12_2) begin // EBREAK
          ;
        end
      end

      `INST_OP_TYPE_S: begin
        case (funct3)
          `INST_FUNCT3_SB: begin
            mem_store_mode = 2'b01;
          end
          `INST_FUNCT3_SH: begin
            mem_store_mode = 2'b10;
          end
          `INST_FUNCT3_SW: begin
            mem_store_mode = 2'b11;
          end
        endcase
        mem_store_addr = $signed(operand1) + $signed(imm_s);
        mem_store_data = operand2;
      end

      `INST_OP_TYPE_U_LUI, `INST_OP_TYPE_U_AUIPC: begin
        regs_write_en = `true;
        regs_write_addr = rd;
        regs_write_data = operand1 + operand2;
      end

      `INST_OP_TYPE_B: begin
        case (funct3)
          `INST_FUNCT3_BEQ: begin
            pc_jump = (operand1 == operand2) ? `true : `false;
          end
          `INST_FUNCT3_BNE: begin
            pc_jump = (operand1 != operand2) ? `true : `false;
          end
          `INST_FUNCT3_BLT: begin
            pc_jump = ($signed(operand1) < $signed(operand2)) ? `true : `false;
          end
          `INST_FUNCT3_BGE: begin
            pc_jump = ($signed(operand1) >= $signed(operand2)) ? `true : `false;
          end
          `INST_FUNCT3_BLTU: begin
            pc_jump = ($unsigned(operand1) < $unsigned(operand2)) ? `true : `false;
          end
          `INST_FUNCT3_BGEU: begin
            pc_jump = ($unsigned(operand1) >= $unsigned(operand2)) ? `true : `false;
          end
        endcase
        pc_jump_addr = pc_jump ? $signed(inst_addr) + $signed({imm_b, 1'b0}) : 0;
        flush_signal = pc_jump;
      end

      `INST_OP_TYPE_J_JAL: begin
        regs_write_en = `true;
        regs_write_addr = rd;
        regs_write_data = inst_addr + 4;
        pc_jump = `true;
        pc_jump_addr = $signed(operand1) + $signed(operand2);
        unpause_signal = `true;
        flush_signal = `true;
      end
    endcase
  end

endmodule
