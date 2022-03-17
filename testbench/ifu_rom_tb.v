`include "define/const.v"
`include "define/inst.v"

`include "rtl/pc.v"
`include "rtl/ifu.v"
`include "rtl/rom.v"

module ifu_rom_tb ();
  reg clk, rst;

  wire[`XLEN_WIDTH] ifu_out;
  wire[`XLEN_WIDTH] pc_ifu;
  wire[`XLEN_WIDTH] ifu_rom_data;
  wire[`XLEN_WIDTH] ifu_rom_addr;

  pc pc(.clk(clk), .rst(rst), .out(pc_ifu));
  ifu ifu(.clk(clk), .rst(rst), .pc(pc_ifu), .inst(ifu_out), .rom_data(ifu_rom_data), .rom_addr(ifu_rom_addr));
  rom rom(.clk(clk), .rst(rst), .addr(ifu_rom_addr), .out(ifu_rom_data));

  parameter clk_period = 10;
  initial
    clk = 0;
  always#(clk_period / 2) clk = ~clk;

  initial
  begin
    $dumpfile("./wave/ifu_rom_tb.vcd");
    $dumpvars;
    $readmemh("./hex/test.hex", rom.data, 0, 31);
    rst = 1;
    @(posedge clk);
    rst = 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    $finish;
  end
endmodule
