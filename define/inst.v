// R type instruction, used for computation, total count: 9
// R型指令，用于计算，共9条
`define INST_OP_TYPE_R 7'b0110011
`define INST_FUNCT3_ADD_SUB 3'b000
`define INST_FUNCT3_SLL 3'b001
`define INST_FUNCT3_SLT 3'b010
`define INST_FUNCT3_SLTU 3'b011
`define INST_FUNCT3_XOR 3'b100
`define INST_FUNCT3_SRL_SRA 3'b101
`define INST_FUNCT3_OR 3'b110
`define INST_FUNCT3_AND 3'b111


// I type instruction
// I型指令

// JALR
`define INST_OP_TYPE_I_JALR 7'b1100111

// load, total count: 5
// 加载，共5条
`define INST_OP_TYPE_I_L 7'b0000011
`define INST_FUNCT3_LB 3'b000
`define INST_FUNCT3_LH 3'b001
`define INST_FUNCT3_LW 3'b010
`define INST_FUNCT3_LBU 3'b100
`define INST_FUNCT3_LHU 3'b101

// computation(register-immediate), total count: 6
// 计算（寄存器-立即数），共6条
`define INST_OP_TYPE_I_I 7'b0010011
`define INST_FUNCT3_ADDI 3'b000
`define INST_FUNCT3_SLTI 3'b010
`define INST_FUNCT3_SLTIU 3'b011
`define INST_FUNCT3_XORI 3'b100
`define INST_FUNCT3_ORI  3'b110
`define INST_FUNCT3_ANDI 3'b111
`define INST_FUNCT3_SLLI 3'b001
`define INST_FUNCT3_SRLI_SRAI 3'b101

// system call
`define INST_OP_TYPE_I_S 7'b1110111


// S type instruction, used for store, total count: 3
// S型指令，用于存储，共3条
`define INST_OP_TYPE_S 7'b0100011
`define INST_FUNCT3_SB 3'b000
`define INST_FUNCT3_SH 3'b001
`define INST_FUNCT3_SW 3'b010


// U type instruction, total count: 2
// U型指令，共2条
`define INST_OP_TYPE_U_LUI 7'b0110111
`define INST_OP_TYPE_U_AUIPC 7'b0010111


// B type instruction, used for branch, total count: 6
// B型指令，用于跳转，共6条
`define INST_OP_TYPE_B 7'b1100011
`define INST_FUNCT3_BEQ 3'b000
`define INST_FUNCT3_BNE 3'b001
`define INST_FUNCT3_BLT 3'b100
`define INST_FUNCT3_BGE 3'b101
`define INST_FUNCT3_BLTU 3'b110
`define INST_FUNCT3_BGEU 3'b111


// J type instruction, used for jump, total count: 1
// J型指令，用于跳转，共1条
`define INST_OP_TYPE_J_JAL 7'b1101111


// two type of funct7
`define INST_FUNCT7_1 7'b0000000
`define INST_FUNCT7_2 7'b0100000


// two type of funct12
`define INST_FUNCT12_1 12'b000000000000
`define INST_FUNCT12_2 12'b000000000001