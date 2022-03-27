`timescale 1ps/1ps

`include "define/const.v"
`include "define/inst.v"

`include "rtl/ex.v"
`include "rtl/id.v"
`include "rtl/ifu.v"
`include "rtl/regs.v"
`include "rtl/ram.v"
`include "rtl/mem.v"
`include "rtl/pc.v"
`include "rtl/util/dff.v"

module ex_tb();
  reg clk, rst;

  wire[`XLEN_WIDTH] ram_addr1, ram_addr2;
  wire[`XLEN_WIDTH] ram_data1, ram_data2;
  wire ram_write_en;
  wire[`XLEN_WIDTH] ram_write_addr;
  wire[`XLEN_WIDTH] ram_write_data;

  wire[`XLEN_WIDTH] pc;
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

  wire mem_load_en;
  wire[`XLEN_WIDTH] mem_load_addr;
  wire[`REG_ADDR] mem_load_regs_addr;
  wire mem_store_en;
  wire[`XLEN_WIDTH] mem_store_addr;
  wire[`XLEN_WIDTH] mem_store_data;
  wire regs_mem_write_en;
  wire[`REG_ADDR] regs_mem_write_addr;
  wire[`XLEN_WIDTH] regs_mem_write_data;
  wire mem_pause_signal;

  ram dut_ram(
        .clk(clk), .rst(rst),

        .addr1(ram_addr1), .out1(ram_data1),
        .addr2(ram_addr2), .out2(ram_data2),

        .write_en(ram_write_en), .write_addr(ram_write_addr),
        .write_data(ram_write_data));

  pc dut_pc(
       .clk(clk), .rst(rst),
       .jump(pc_jump), .jump_addr(pc_jump_addr),
       .pause(),
       .out(pc));

  ifu dut_ifu(
        .pc(pc),
        .data(ram_data1), .addr(ram_addr1),
        .inst(ifu_out));

  wire[`XLEN_WIDTH] inst_addr_id;
  dff#(`XLEN) dut_dff_inst_addr_id(
       .clk(clk), .rst(rst),
       .d(pc), .q(inst_addr_id));

  id dut_id(
       .inst(ifu_out), .inst_addr(inst_addr_id),

       .regs_addr1(regs_addr1), .regs_data1(regs_out1),
       .regs_addr2(regs_addr2), .regs_data2(regs_out2),

       .operand1(operand1), .operand2(operand2),

       .pause(), .pause_signal());

  regs dut_regs(
         .clk(clk), .rst(rst),

         .addr1(regs_addr1), .out1(regs_out1),
         .addr2(regs_addr2), .out2(regs_out2),

         .write_en(regs_write_en), .write_addr(regs_write_addr),
         .write_data(regs_write_data),

         .mem_write_en(regs_mem_write_en), .mem_write_addr(regs_mem_write_addr),
         .mem_write_data(regs_mem_write_data));

  wire[`XLEN_WIDTH] inst_ex;
  dff#(`XLEN) dut_dff_inst_ex(
       .clk(clk), .rst(rst),
       .d(ifu_out), .q(inst_ex));

  wire[`XLEN_WIDTH] inst_addr_ex;
  dff#(`XLEN) dut_dff_inst_addr_ex(
       .clk(clk), .rst(rst),
       .d(inst_addr_id), .q(inst_addr_ex));

  wire [`XLEN_WIDTH] operand1_ex;
  dff#(`XLEN) dut_dff_operand1_ex(
       .clk(clk), .rst(rst),
       .d(operand1), .q(operand1_ex));

  wire [`XLEN_WIDTH] operand2_ex;
  dff#(`XLEN) dut_dff_operand2_ex(
       .clk(clk), .rst(rst),
       .d(operand2), .q(operand2_ex));

  ex dut_ex(
       .inst(inst_ex), .inst_addr(inst_addr_ex),

       .operand1(operand1_ex), .operand2(operand2_ex),

       .regs_write_en(regs_write_en), .regs_write_addr(regs_write_addr),
       .regs_write_data(regs_write_data),

       .pc_jump(pc_jump), .pc_jump_addr(pc_jump_addr),

       .mem_load_en(mem_load_en), .mem_load_addr(mem_load_addr),
       .mem_load_regs_addr(mem_load_regs_addr),
       .mem_store_en(mem_store_en), .mem_store_addr(mem_store_addr),
       .mem_store_data(mem_store_data)
     );

  mem dut_mem(
        .load_en(mem_load_en), .load_addr(mem_load_addr),
        .load_regs_addr(mem_load_regs_addr),

        .store_en(mem_store_en), .store_addr(mem_store_addr),
        .store_data(mem_store_data),

        .ram_read_addr(ram_addr2), .ram_read_data(ram_data2),
        .ram_write_en(ram_write_en),
        .ram_write_addr(ram_write_addr), .ram_write_data(ram_write_data),

        .regs_write_en(regs_mem_write_en), .regs_write_addr(regs_mem_write_addr),
        .regs_write_data(regs_mem_write_data),

        .pause_signal(mem_pause_signal)
      );

  parameter clk_period = 10;
  initial
    clk = 1;
  always#(clk_period / 2) clk = ~clk;

  integer i;

  initial begin
    $dumpfile("./wave/ex_tb.vcd");
    $dumpvars;
    $readmemh("./program/mem/hex/empty32.word.mem", dut_regs.data, 0, 31);
    $readmemh("./program/mem/hex/fibonacci.byte.mem", dut_ram.data, 0, 5299);
    rst = 1;
    @(posedge clk) rst = 0;
    for (i = 0; i < 100; i = i + 1) begin
      @(posedge clk);
    end
    $finish;
  end
endmodule
