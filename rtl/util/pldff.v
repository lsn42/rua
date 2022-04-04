`ifndef UTIL_PLDFF_V
`define UTIL_PLDFF_V

module pldff #(
    parameter width = 32,
    parameter flush_data = {width{1'b0}}
  )(
    input wire en, input wire clk, input wire rst,
    input wire[width - 1: 0] d, output reg[width - 1: 0] q
  );

  reg [width - 1: 0] _q, s;

  always @(posedge clk or posedge rst) begin
    _q <= d;
    s <= en ? d : s;
  end

  always @(* ) begin
    q = rst ? flush_data : en ? _q : s;
  end

endmodule

`endif
