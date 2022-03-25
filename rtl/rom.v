`include "define/const.v"

module rom (
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] addr,
    output reg[`XLEN_WIDTH] out
  );

  reg[`BYTE_WIDTH] data[2 ** 16 - 1: 0];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      out <= 0;
    end
    else begin
      out <= {data[addr + 3], data[addr + 2], data[addr + 1], data[addr]};
    end
  end

endmodule
