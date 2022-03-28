`include "rtl/util/dff.v"

`include "define/const.v"
`include "define/inst.v"

module dff_tb();
  reg en, clk, rst;

  reg[`XLEN_WIDTH] in;

  wire[`XLEN_WIDTH] dff1_out, dff2_out, dff3_out;

  dff#(`XLEN) dff1(
       .en(en), .clk(clk), .rst(rst),
       .d(in), .q(dff1_out));

  dff#(`XLEN) dff2(
       .en(en), .clk(clk), .rst(rst),
       .d(dff1_out), .q(dff2_out));

  dff#(`XLEN) dff3(
       .en(en), .clk(clk), .rst(rst),
       .d(dff2_out), .q(dff3_out));

  parameter clk_period = 10;
  initial
    clk = 1;
  always#(clk_period / 2) clk = ~clk;

  integer i;

  initial begin
    $dumpfile("./wave/dff_tb.vcd");
    $dumpvars;
    en = 1;
    rst = 1;
    in = 0;
    @(posedge clk) rst = 0;
    for (i = 0; i < 100 ; i = i + 1) begin
      @(posedge clk) in = i;
    end
    $finish;
  end

endmodule
