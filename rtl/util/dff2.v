`ifndef UTIL_DFF2_V
`define UTIL_DFF2_V

module dff2 #(
    parameter width = 32,
    parameter flush_data = {width{1'b0}}
  )(
    input wire clk, input wire rst, input wire pause,
    input wire[width - 1: 0] d, output reg[width - 1: 0] q
  );
  reg [width - 1: 0] _q;

  always @(posedge clk or posedge rst) begin
    _q <= d;
    if (pause) begin
      q <= _q;
    end
    else begin
      q <= d;
    end
  end

endmodule

`endif
