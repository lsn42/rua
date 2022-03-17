`include "define/const.v"

module rom (
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] addr,
    output reg[`XLEN_WIDTH] out
  );
  reg[`XLEN_WIDTH] data[2 ** 16 - 1: 0];

  always @(posedge clk or posedge rst) begin
    if (rst)
    begin
      out <= 0;
    end else
    begin
      out <= data[addr];
    end
  end

endmodule
