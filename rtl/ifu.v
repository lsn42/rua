// instruction fetch unit
`include "define/const.v"
`include "define/inst.v"

`include "rtl/util/dff.v"

module ifu (
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] pc,
    input wire[`XLEN_WIDTH] rom_data, output reg[`XLEN_WIDTH] rom_addr,
    output reg[`XLEN_WIDTH] inst
  );

  always @(* ) begin
    rom_addr = pc;
    inst = rom_data;
  end
  
endmodule
