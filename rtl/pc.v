// program counter
`include "define/const.v"
`include "define/inst.v"
module pc(
    input wire clk, input wire rst,
    input wire pause,
    output reg[`XLEN - 1: 0] out
  );

  always @(posedge clk or posedge rst)
    begin
      if (rst)
        begin
          out <= `CPU_START_ADDR;
        end
      else if (pause)
        begin
          out <= out;
        end
      else
        begin
          out <= out + 4;
        end
    end
endmodule
