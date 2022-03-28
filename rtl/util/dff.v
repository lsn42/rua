`ifndef UTIL_DFF_V
`define UTIL_DFF_V

module dff #(
    parameter width = 32,
    parameter flush_data = {width{1'b0}}
  )(
    input wire en, input wire clk, input wire rst,
    input wire[width - 1: 0] d, output reg[width - 1: 0] q
  );

  always @ (posedge clk or posedge rst) begin
    if (rst) begin
      q = flush_data;
    end
    else if (en) begin
      q = d;
    end
  end

endmodule

`endif
