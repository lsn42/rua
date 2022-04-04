`ifndef UTIL_DFF2_V
`define UTIL_DFF2_V
`include "define/const.v"
`include "rtl/util/dff.v"

module dff2 #(
    parameter width = 32,
    parameter flush_data = {width{1'b0}}
  )(
    input wire clk, input wire rst, input wire pause, input wire flush,
    input wire[width - 1: 0] d, output reg[width - 1: 0] q
  );
  reg [width - 1: 0] s;

  wire[width - 1: 0] _q;
  dff#(width, flush_data) dff(.en(!pause), .clk(clk), .rst(rst | flush), .d(d), .q(_q));

  always @(posedge clk or posedge rst) begin
    if (!pause) begin
      s <= d;
    end
  end

  always @(* ) begin
    if (pause) begin
      q = s;
    end
    else begin
      q = _q;
    end
  end

endmodule

`endif
