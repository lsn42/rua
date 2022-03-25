`timescale 1ps/1ps

`include "define/const.v"
`include "define/inst.v"

`include "rtl/ex.v"
`include "rtl/id.v"
`include "rtl/ifu.v"
`include "rtl/regs.v"
`include "rtl/rom.v"
`include "rtl/pc.v"
`include "rtl/pipeline/dff.v"

module ex_tb();
  reg clk, rst;

  wire[`XLEN_WIDTH] rom_data;
  wire[`XLEN_WIDTH] rom_addr;

  wire[`XLEN_WIDTH] pc;
  wire pc_jump;
  wire[`XLEN_WIDTH] pc_jump_addr;

  wire[`XLEN_WIDTH] ifu_out;
  wire[`XLEN_WIDTH] inst_pc;

  wire[`XLEN_WIDTH] regs_in;
  wire[`REG_ADDR] regs_addr1;
  wire[`REG_ADDR] regs_addr2;
  wire[`REG_ADDR] regs_write_addr;
  wire regs_write_en;
  wire[`XLEN_WIDTH] regs_out1;
  wire[`XLEN_WIDTH] regs_out2;

  rom dut_rom(
        .clk(clk), .rst(rst),
        .addr(rom_addr),
        .out(rom_data));

  pc dut_pc(
       .clk(clk), .rst(rst),
       .jump(pc_jump), .jump_addr(pc_jump_addr),
       .pause(),
       .out(pc));

  ifu dut_ifu(
        .clk(clk), .rst(rst),
        .pc(pc),
        .rom_data(rom_data), .rom_addr(rom_addr),
        .inst(ifu_out), .inst_pc(inst_pc));

  id dut_id(
       .clk(clk), .rst(rst),
       .inst(ifu_out),

       .regs_addr1(regs_addr1), .regs_addr2(regs_addr2),
       .regs_write_en(regs_write_en),
       .regs_write_addr(regs_write_addr),

       .mem_read_en(), .mem_write_en()
     );

  wire[`XLEN_WIDTH] id_ex_inst;
  dff#(`XLEN) dut_dff_id_ex(
       .clk(clk), .rst(rst),
       .d(ifu_out),
       .q(id_ex_inst));

  regs dut_regs(
         .clk(clk), .rst(rst),

         .addr1(regs_addr1), .out1(regs_out1),
         .addr2(regs_addr2), .out2(regs_out2),

         .write_en(regs_write_en), .write_addr(regs_write_addr),
         .write_data(regs_in),

         .mem_read_addr(), .mem_read_data(),

         .mem_write_en(), .mem_write_addr(),
         .mem_write_data()
       );

  ex dut_ex(
       .clk(clk), .rst(rst),
       .inst(id_ex_inst),

       .regs_in1(regs_out1), .regs_in2(regs_out2),
       .regs_write_data(regs_in),

       .pc(pc),
       .pc_jump(pc_jump), .pc_jump_addr(pc_jump_addr),

       .mem_read_addr(), .mem_read_data(),
       .mem_write_en(), .mem_write_addr(),
       .mem_write_data()
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
    $readmemh("./program/mem/hex/fibonacci.byte.mem", dut_rom.data, 0, 5331);
    rst = 1;
    @(posedge clk) rst = 0;
    // pc_jump = `true;
    for (i = 0; i < 10; i = i + 1)begin
      @(posedge clk);
    end
    $finish;
  end
endmodule
