// register
`include "define/const.v"
`include "define/inst.v"

module register (
    input wire clk, input wire rst,
    input wire[`REGISTER_ADDR] addr,
    output reg out
  );
  reg[`XLEN - 1: 0] data[`REGISTER_COUNT - 1: 0];
  always @(* )
    begin
      out <= data[addr];
    end
endmodule
