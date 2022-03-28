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
`include "rtl/util/dff.v"

module rua(
    input wire clk, input wire rst
  );

  wire pause_signal, unpause_signal, pause;
  wire flush_signal, flush;

  wire[`XLEN_WIDTH] ram_addr1, ram_addr2;
  wire[`XLEN_WIDTH] ram_data1, ram_data2;
  wire ram_write_en;
  wire[`XLEN_WIDTH] ram_write_addr;
  wire[`XLEN_WIDTH] ram_write_data;

  wire[`XLEN_WIDTH] pc_out;
  wire pc_jump;
  wire[`XLEN_WIDTH] pc_jump_addr;

  wire[`XLEN_WIDTH] ifu_out;

  wire[`REG_ADDR] regs_addr1, regs_addr2;
  wire[`XLEN_WIDTH] regs_out1, regs_out2;
  wire[`XLEN_WIDTH] operand1;
  wire[`XLEN_WIDTH] operand2;
  wire id_pause;
  wire id_pause_signal;

  wire regs_write_en;
  wire[`XLEN_WIDTH] regs_write_data;
  wire[`REG_ADDR] regs_write_addr;
  wire ex_unpause_signal;

  wire mem_load_en;
  wire[`XLEN_WIDTH] mem_load_addr;
  wire[`REG_ADDR] mem_load_regs_addr;
  wire mem_store_en;
  wire[`XLEN_WIDTH] mem_store_addr;
  wire[`XLEN_WIDTH] mem_store_data;
  wire regs_mem_write_en;
  wire[`REG_ADDR] regs_mem_write_addr;
  wire[`XLEN_WIDTH] regs_mem_write_data;
  wire mem_unpause_signal;

  ctrl ctrl(
    .clk(clk), .rst(rst),
    .pause_signal(pause_signal), .unpause_signal(unpause_signal), .pause(pause),
    .flush_signal(flush_signal), .flush(flush));

  ram ram(
        .clk(clk), .rst(rst),

        .addr1(ram_addr1), .out1(ram_data1),
        .addr2(ram_addr2), .out2(ram_data2),

        .write_en(ram_write_en), .write_addr(ram_write_addr),
        .write_data(ram_write_data));

  pc pc(
       .clk(clk), .rst(rst),
       .jump(pc_jump), .jump_addr(pc_jump_addr),
       .pause(pause),
       .out(pc_out));

  ifu ifu(
        .pc(pc_out),
        .data(ram_data1), .addr(ram_addr1),
        .inst(ifu_out));

  wire[`XLEN_WIDTH] inst_addr_id;
  dff#(`XLEN) dff_inst_addr_id(
       .en(!pause), .clk(clk), .rst(rst),
       .d(pc_out), .q(inst_addr_id));

  id id(
       .inst(ifu_out), .inst_addr(inst_addr_id),

       .regs_addr1(regs_addr1), .regs_data1(regs_out1),
       .regs_addr2(regs_addr2), .regs_data2(regs_out2),

       .operand1(operand1), .operand2(operand2),

       .pause_signal(pause_signal));

  regs regs(
         .clk(clk), .rst(rst),

         .addr1(regs_addr1), .out1(regs_out1),
         .addr2(regs_addr2), .out2(regs_out2),

         .write_en(regs_write_en), .write_addr(regs_write_addr),
         .write_data(regs_write_data),

         .mem_write_en(regs_mem_write_en), .mem_write_addr(regs_mem_write_addr),
         .mem_write_data(regs_mem_write_data));

  wire[`XLEN_WIDTH] inst_ex;
  dff#(`XLEN, `INST_NOP) dff_inst_ex(
       .en(!pause), .clk(clk), .rst(rst),
       .d(ifu_out), .q(inst_ex));

  wire[`XLEN_WIDTH] inst_test;
  dff#(`XLEN, `INST_NOP) dff_inst_test(
       .en(!pause), .clk(clk), .rst(rst),
       .d(inst_ex), .q(inst_test));

  wire[`XLEN_WIDTH] inst_addr_ex;
  dff#(`XLEN) dff_inst_addr_ex(
       .en(!pause), .clk(clk), .rst(rst),
       .d(inst_addr_id), .q(inst_addr_ex));

  wire [`XLEN_WIDTH] operand1_ex;
  dff#(`XLEN) dff_operand1_ex(
       .en(!pause), .clk(clk), .rst(rst),
       .d(operand1), .q(operand1_ex));

  wire [`XLEN_WIDTH] operand2_ex;
  dff#(`XLEN) dff_operand2_ex(
       .en(!pause), .clk(clk), .rst(rst),
       .d(operand2), .q(operand2_ex));

  ex ex(
       .inst(inst_ex), .inst_addr(inst_addr_ex),

       .operand1(operand1_ex), .operand2(operand2_ex),

       .regs_write_en(regs_write_en), .regs_write_addr(regs_write_addr),
       .regs_write_data(regs_write_data),

       .pc_jump(pc_jump), .pc_jump_addr(pc_jump_addr),

       .mem_load_en(mem_load_en), .mem_load_addr(mem_load_addr),
       .mem_load_regs_addr(mem_load_regs_addr),
       .mem_store_en(mem_store_en), .mem_store_addr(mem_store_addr),
       .mem_store_data(mem_store_data),

       .unpause_signal(ex_unpause_signal)
     );

  mem mem(
        .load_en(mem_load_en), .load_addr(mem_load_addr),
        .load_regs_addr(mem_load_regs_addr),

        .store_en(mem_store_en), .store_addr(mem_store_addr),
        .store_data(mem_store_data),

        .ram_read_addr(ram_addr2), .ram_read_data(ram_data2),
        .ram_write_en(ram_write_en),
        .ram_write_addr(ram_write_addr), .ram_write_data(ram_write_data),

        .regs_write_en(regs_mem_write_en), .regs_write_addr(regs_mem_write_addr),
        .regs_write_data(regs_mem_write_data),

        .unpause_signal(mem_unpause_signal)
      );

endmodule
