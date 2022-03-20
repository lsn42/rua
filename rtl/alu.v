`include "define/const.v"
`include "define/inst.v"

module alu(
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] inst,
    input wire[`XLEN_WIDTH] in1, input wire[`XLEN_WIDTH] in2,
    output reg [`XLEN_WIDTH] out
  );
  wire[6: 0] opcode = inst[6: 0];
  wire[2: 0] funct3 = inst[14: 12];
  wire[6: 0] funct7 = inst[31: 25];
  wire[6: 0] funct12 = inst[31: 20];

  // TODO: lots of the operation done by copilot, still need more carefully check

  // combinational logic
  // 组合逻辑
  always @(* ) begin
    out <= 0;
    case (opcode)
      `INST_OP_TYPE_R: begin
        case (funct3)
          `INST_FUNCT3_ADD_SUB: begin
            if (funct7 == `INST_FUNCT7_1) begin // ADD
              out <= in1 + in2;
            end
            else if (funct7 == `INST_FUNCT7_2) begin // SUB
              out <= in1 - in2;
            end
          end
          `INST_FUNCT3_SLL: begin
            out <= in1 << in2[4: 0];
          end
          `INST_FUNCT3_SLT: begin
            out <= (in1 < in2) ? 1 : 0;
          end
          `INST_FUNCT3_SLTU: begin
            out <= ($unsigned(in1) << $unsigned(in2))? 1 : 0;
          end
          `INST_FUNCT3_XOR: begin
            out <= in1 ^ in2;
          end
          `INST_FUNCT3_SRL_SRA: begin
            if (funct7 == `INST_FUNCT7_1) begin // SRL
              out <= in1 >> in2[4: 0];
            end
            else if (funct7 == `INST_FUNCT7_2) begin // SRA
              out <= $signed(in1) >> in2[4: 0];
            end
          end
          `INST_FUNCT3_OR: begin
            out <= in1 | in2;
          end
          `INST_FUNCT3_AND: begin
            out <= in1 & in2;
          end
        endcase
      end
      `INST_OP_TYPE_I_JALR: begin
        out <= in1 + $signed(in2[31: 20]);
      end
      `INST_OP_TYPE_I_L: begin
        out <= in1 + $signed(in2[31: 20]);
      end
      `INST_OP_TYPE_I_I: begin
        case (funct3)
          `INST_FUNCT3_ADDI: begin
            out <= in1 + in2;
          end
          `INST_FUNCT3_SLTI: begin
            out <= (in1 < in2) ? 1 : 0;
          end
          `INST_FUNCT3_SLTIU: begin
            out <= ($unsigned(in1) < $unsigned(in2)) ? 1 : 0;
          end
          `INST_FUNCT3_XORI: begin
            out <= in1 ^ in2;
          end
          `INST_FUNCT3_ORI: begin
            out <= in1 | in2;
          end
          `INST_FUNCT3_ANDI: begin
            out <= in1 & in2;
          end
          `INST_FUNCT3_SLLI: begin
            out <= in1 << in2[24: 20];
          end
          `INST_FUNCT3_SRLI_SRAI: begin
            if (funct7 == `INST_FUNCT7_1) begin // SRLI
              out <= in1 >> in2[24: 20];
            end
            else if (funct7 == `INST_FUNCT7_2) begin // SRAI
              out <= in1 << in2[24: 20];
            end
          end
        endcase
      end
      `INST_OP_TYPE_I_S: begin
        if (funct12 == `INST_FUNCT12_1) begin // ECALL
          ;
        end
        else if (funct12 == `INST_FUNCT12_2) begin // EBREAK
          ;
        end
      end
      `INST_OP_TYPE_S: begin
        out <= in1 + $signed({in2[31: 25], in2[11: 7]});
      end
      `INST_OP_TYPE_U_LUI: begin
        out <= {in2[31: 12], {12{1'b0}}};
      end
      `INST_OP_TYPE_U_AUIPC: begin
        out <= in1 + {in2[31: 12], {12{1'b0}}};
      end
      `INST_OP_TYPE_B: begin
        case (funct3)
          `INST_FUNCT3_BEQ: begin
            out <= (in1 == in2) ? `true : `false;
          end
          `INST_FUNCT3_BNE: begin
            out <= (in1 != in2) ? `true : `false;
          end
          `INST_FUNCT3_BLT: begin
            out <= ($signed(in1) < $signed(in2)) ? `true : `false;
          end
          `INST_FUNCT3_BGE: begin
            out <= ($signed(in1) >= $signed(in2)) ? `true : `false;
          end
          `INST_FUNCT3_BLTU: begin
            out <= ($unsigned(in1) < $unsigned(in2)) ? `true : `false;
          end
          `INST_FUNCT3_BGEU: begin
            out <= ($unsigned(in1) >= $unsigned(in2)) ? `true : `false;
          end
        endcase
      end
      `INST_OP_TYPE_J_JAL: begin
        out <= in1 + 4;
      end
    endcase
  end
endmodule
