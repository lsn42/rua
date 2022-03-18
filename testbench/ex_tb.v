`include "rtl/ex.v"
`include "rtl/id.v"
`include "rtl/ifu.v"
`include "rtl/regs.v"
`include "rtl/rom.v"
`include "rtl/pc.v"

module ex_tb();
  reg clk, rst;

  wire[`XLEN_WIDTH] ifu_out;
  wire[`XLEN_WIDTH] pc_ifu;
  wire[`XLEN_WIDTH] ifu_rom_data;
  wire[`XLEN_WIDTH] ifu_rom_addr;

  wire[`XLEN_WIDTH] regs_in;
  wire[`REG_ADDR] regs_addr1;
  wire[`REG_ADDR] regs_addr2;
  wire[`REG_ADDR] regs_write_addr;
  wire regs_write_en;
  wire[`XLEN_WIDTH] regs_out1;
  wire[`XLEN_WIDTH] regs_out2;

  rom rom(.clk(clk), .rst(rst), .addr(ifu_rom_addr), .out(ifu_rom_data));
  pc pc(.clk(clk), .rst(rst), .pause(), .out(pc_ifu));
  ifu ifu(.clk(clk), .rst(rst), .pc(pc_ifu), .inst(ifu_out), .rom_data(ifu_rom_data), .rom_addr(ifu_rom_addr));
  id id(.clk(clk), .rst(rst), .inst(ifu_out), .regs_addr1(regs_addr1), .regs_addr2(regs_addr2), .regs_write_addr(regs_write_addr), .regs_write_en(regs_write_en));
  regs regs(.clk(clk), .rst(rst), .addr1(regs_addr1), .out1(regs_out1), .addr2(regs_addr2), .out2(regs_out2), .write_en(regs_write_en), .write_addr(regs_write_addr), .in(regs_in));
  ex ex(.clk(clk), .rst(rst), .inst(ifu_out), .reg_in1(regs_out1), .reg_in2(regs_out2), .out(regs_in));

  parameter clk_period = 10;
  initial
    clk = 0;
  always#(clk_period / 2) clk = ~clk;

  integer i;

  initial
  begin
    $dumpfile("./wave/ex_tb.vcd");
    $dumpvars;
    $readmemh("./program/hex/regs_1.hex", regs.data, 0, 31);
    $readmemb("./program/bin/addi.bin", rom.data, 0, 1);
    rst = 1;
    @(posedge clk);
    rst = 0;
    for (i = 0; i < 10; i = i + 1)
    begin
      @(posedge clk);
    end
    $finish;
  end
endmodule
