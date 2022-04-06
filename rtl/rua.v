`timescale 1ps/1ps

`include "define/const.v"
`include "define/inst.v"

`include "rtl/ctrl.v"
`include "rtl/ex.v"
`include "rtl/id.v"
`include "rtl/ifu.v"
`include "rtl/regs.v"
`include "rtl/ram.v"
`include "rtl/mem.v"
`include "rtl/pc.v"
`include "rtl/util/pldff.v"

module rua(
    input wire clk, input wire rst
  );
  // ctrl
  wire pause, flush;

  // ram
  wire[`XLEN_WIDTH] ram_addr1, ram_addr2;
  wire[`XLEN_WIDTH] ram_data1, ram_data2;
  wire[1: 0] ram_write_mode;
  wire[`XLEN_WIDTH] ram_write_addr;
  wire[`XLEN_WIDTH] ram_write_data;

  // pc/ifu
  wire[`XLEN_WIDTH] pc_out;
  wire pc_jump;
  wire[`XLEN_WIDTH] pc_jump_addr;
  wire[`XLEN_WIDTH] ifu_out;

  // id
  wire[`REG_ADDR] regs_addr1, regs_addr2;
  wire[`XLEN_WIDTH] regs_out1, regs_out2;
  wire[`XLEN_WIDTH] operand1;
  wire[`XLEN_WIDTH] operand2;
  wire id_pause_signal;

  // ex
  wire regs_write_en;
  wire[`XLEN_WIDTH] regs_write_data;
  wire[`REG_ADDR] regs_write_addr;
  wire ex_unpause_signal;
  wire ex_flush_signal;

  // mem
  wire[2: 0] mem_load_mode;
  wire[`XLEN_WIDTH] mem_load_addr;
  wire[`REG_ADDR] mem_load_regs_addr;
  wire[1: 0] mem_store_mode;
  wire[`XLEN_WIDTH] mem_store_addr;
  wire[`XLEN_WIDTH] mem_store_data;
  wire regs_mem_write_en;
  wire[`REG_ADDR] regs_mem_write_addr;
  wire[`XLEN_WIDTH] regs_mem_write_data;
  wire mem_unpause_signal;

  ctrl ctrl(
         // input: clock, reset
         .clk(clk), .rst(rst),
         // input: pause, unpause and flush signals from different modules
         // 输入：各模块传递过来的暂停、恢复和清洗的请求信号
         .id_pause_signal(id_pause_signal),
         .ex_unpause_signal(ex_unpause_signal), .ex_flush_signal(ex_flush_signal),
         .mem_unpause_signal(mem_unpause_signal),
         // output: output pause and flush signals after judgement
         // 输出：裁定后向各模块发送的暂停、清洗命令
         .pause(pause), .flush(flush));

  ram ram(
        // input: clock, reset
        .clk(clk), .rst(rst),
        // input: double address input
        // 输入：双口地址
        .addr1(ram_addr1), .addr2(ram_addr2),
        // output: double data output
        // 输出：双口数据
        .out1(ram_data1), .out2(ram_data2),
        // input: write enable, address and writing data
        // 输入：写使能、地址和将写入的数据
        .write_mode(ram_write_mode), .write_addr(ram_write_addr),
        .write_data(ram_write_data));

//   pc pc(
//        // input: clock, reset
//        .clk(clk), .rst(rst),
//        // input: jump flag and jump address, pause flag
//        // 输入：跳转标志和跳转地址，暂停标志
//        .jump(pc_jump), .jump_addr(pc_jump_addr), .pause(pause),
//        // output: program counter output
//        // 输出：程序计数器输出
//        .out(pc_out));
wire[`XLEN_WIDTH] ifu_inst_addr;
  ifu ifu(
       .clk(clk), .rst(rst),
        // input: program counter and flush flag
        // 输入：程序计数器和清洗标志
        .flush(flush),
       .jump(pc_jump), .jump_addr(pc_jump_addr), .pause(pause),
        // output: address of memory accessing
        // 输出：将访问的存储器地址
        .addr(ram_addr1),
        // input: memory return data
        // 输入：存储器返回的数据
        .data(ram_data1),
        // output: instruction fecthed
        // 输出：获取到的指令
        .inst(ifu_out),
        .inst_addr(ifu_inst_addr));

//   wire[`XLEN_WIDTH] inst_addr_id;
//   dff#(`XLEN) dff_inst_addr_id(
//        .en(!pause), .clk(clk), .rst(rst),
//        .d(pc_out), .q(inst_addr_id));

  id id(
       // input: instruction and it's address
       // 输入：指令与其地址
       .inst(ifu_out), .inst_addr(ifu_inst_addr),
       // output: double address of registers that are accessing, decode from instruction
       // 输出：从指令中获取的两个将要访问的寄存器的地址
       .regs_addr1(regs_addr1), .regs_addr2(regs_addr2),
       // input: double data from registers
       // 输入：来自两个寄存器的数据
       .regs_data1(regs_out1), .regs_data2(regs_out2),
       // output: two preprocessed operands by decoding immediates from
       // instruction or acquire from registers
       // 输出：根据指令中的立即数或从寄存器中获取的两个与处理好的操作数
       .operand1(operand1), .operand2(operand2),
       // output: pause and flush signal according to instruction type
       // 输出：根据指令类型输出暂停和清洗信号
       .pause_signal(id_pause_signal));

  regs regs(
         // input: clock, reset
         .clk(clk), .rst(rst),
         // input: double address input
         // 输入：双口地址
         .addr1(regs_addr1), .addr2(regs_addr2),
         // output: double data output
         // 输出：双口数据
         .out1(regs_out1), .out2(regs_out2),
         // input: write enable, address and writing data
         // 输入：写使能、地址和将写入的数据
         .write_en(regs_write_en), .write_addr(regs_write_addr),
         .write_data(regs_write_data),
         // input: write enable, address and writing data
         // 输入：来自存储器的写使能、地址和将写入的数据
         .mem_write_en(regs_mem_write_en), .mem_write_addr(regs_mem_write_addr),
         .mem_write_data(regs_mem_write_data));

  wire[`XLEN_WIDTH] inst_ex;
  pldff#(`XLEN, `INST_NOP) dff_inst_ex(
       .en(`true), .clk(clk), .rst(rst | flush),
       .d(ifu_out), .q(inst_ex));

  wire[`XLEN_WIDTH] inst_addr_ex;
  pldff#(`XLEN) dff_inst_addr_ex(
       .en(`true), .clk(clk), .rst(rst | flush),
       .d(ifu_inst_addr), .q(inst_addr_ex));

  wire [`XLEN_WIDTH] operand1_ex;
  pldff#(`XLEN) dff_operand1_ex(
       .en(`true), .clk(clk), .rst(rst | flush),
       .d(operand1), .q(operand1_ex));

  wire [`XLEN_WIDTH] operand2_ex;
  pldff#(`XLEN) dff_operand2_ex(
       .en(`true), .clk(clk), .rst(rst | flush),
       .d(operand2), .q(operand2_ex));

  ex ex(
       // input: instruction and it's address
       // 输入：指令与其地址
       .inst(inst_ex), .inst_addr(inst_addr_ex),
       // input: two operands
       // 输入：两个操作数
       .operand1(operand1_ex), .operand2(operand2_ex),
       // output: register write enable, address and writing data
       // 输出：寄存器写使能，地址和将写入的数据
       .regs_write_en(regs_write_en), .regs_write_addr(regs_write_addr),
       .regs_write_data(regs_write_data),
       // output: jump flag and jump address, pause flag
       // 输出：跳转标志和跳转地址，暂停标志
       .pc_jump(pc_jump), .pc_jump_addr(pc_jump_addr),
       // output: memory load enable, address and destination register of loaded data
       // 输出：存储器加载使能，地址和加载的数据的目的寄存器
       .mem_load_mode(mem_load_mode), .mem_load_addr(mem_load_addr),
       .mem_load_regs_addr(mem_load_regs_addr),
       // output: memory store enable, address and storing data
       // 输出：存储器存储使能，地址和将存储的数据
       .mem_store_mode(mem_store_mode), .mem_store_addr(mem_store_addr),
       .mem_store_data(mem_store_data),
       // output: unpause and flush signal according to instruction type
       // 输出：根据指令类型输出的恢复和清洗信号
       .unpause_signal(ex_unpause_signal), .flush_signal(ex_flush_signal)
     );

  mem mem(
         // input: clock, reset
         .clk(clk), .rst(rst),
        // input: load enable, address and data
        // 输入：加载使能、地址和数据
        .load_mode(mem_load_mode), .load_addr(mem_load_addr),
        .load_regs_addr(mem_load_regs_addr),
        // input: store enable, address and data
        // 输入：存储使能、地址和数据
        .store_mode(mem_store_mode), .store_addr(mem_store_addr),
        .store_data(mem_store_data),
        // output: RAM read address
        // 输出：RAM读地址
        .ram_read_addr(ram_addr2),
        // output: RAM read address
        // 输出：RAM读地址
        .ram_read_data(ram_data2),
        // output: RAM write enable, address and data
        // 输出：RAM写使能、地址和数据
        .ram_write_mode(ram_write_mode),
        .ram_write_addr(ram_write_addr), .ram_write_data(ram_write_data),
        // output: register write enable, address and data
        // 输出：寄存器写使能、地址和数据
        .regs_write_en(regs_mem_write_en), .regs_write_addr(regs_mem_write_addr),
        .regs_write_data(regs_mem_write_data),
        // output: unpause signal after loaded data
        // 输出：加载数据后的恢复信号
        .unpause_signal(mem_unpause_signal)
      );

//   wire mem_unpause_signal_wait_for_regs;
//   pldff#(1) dff_mem_unpause_signal_wait_for_regs(
//        .en(`true), .clk(clk), .rst(rst),
//        .d(mem_unpause_signal), .q(mem_unpause_signal_wait_for_regs));

endmodule
