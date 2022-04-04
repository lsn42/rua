`include "rtl/util/pldff.v"

`include "define/const.v"
`include "define/inst.v"

module dff_tb();
  reg clk, rst, pause;

  reg[`XLEN_WIDTH] in;

  wire[`XLEN_WIDTH] dff1_out, dff2_out, dff3_out;

  pldff#(`XLEN) dff1(
       .en(!pause), .clk(clk), .rst(rst),
       .d(in), .q(dff1_out));

  pldff#(`XLEN) dff2(
       .en(!pause), .clk(clk), .rst(rst),
       .d(dff1_out), .q(dff2_out));

  pldff#(`XLEN) dff3(
       .en(!pause), .clk(clk), .rst(rst),
       .d(dff2_out), .q(dff3_out));

  parameter clk_period = 10;
  initial
    clk = 1;
  always#(clk_period / 2) clk = ~clk;

  integer i;

  initial begin
    $dumpfile("./wave/pldff_tb.vcd");
    $dumpvars;
    pause = 0;
    rst = 1;
    in = 0;
    @(posedge clk) rst = 0;
    for (i = 0; i < 100 ; i = i + 1) begin
      @(posedge clk) in = i;
      if (i == 10) begin
        rst = ~rst;
      end
      if (i == 11) begin
        rst = ~rst;
      end
    end
    $finish;
  end

endmodule
