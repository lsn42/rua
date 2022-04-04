`include "rtl/util/dff2.v"

`include "define/const.v"
`include "define/inst.v"

module dff_tb();
  reg clk, rst, pause;

  reg[`XLEN_WIDTH] in;

  wire[`XLEN_WIDTH] dff1_out, dff2_out, dff3_out;

  dff2#(`XLEN) dff1(
        .clk(clk), .rst(rst), .pause(pause),
        .d(in), .q(dff1_out));

  dff2#(`XLEN) dff2(
        .clk(clk), .rst(rst), .pause(pause),
        .d(dff1_out), .q(dff2_out));

  dff2#(`XLEN) dff3(
        .clk(clk), .rst(rst), .pause(pause),
        .d(dff2_out), .q(dff3_out));

  parameter clk_period = 10;
  initial
    clk = 1;
  always#(clk_period / 2) clk = ~clk;

  integer i;

  initial begin
    $dumpfile("./wave/dff2_tb.vcd");
    $dumpvars;
    pause = 0;
    rst = 1;
    in = 0;
    @(posedge clk) rst = 0;
    for (i = 0; i < 100 ; i = i + 1) begin
      @(posedge clk) in = i;
      if (i == 10 || i == 11) begin
        pause = ~pause;
      end
    end
    $finish;
  end

endmodule
