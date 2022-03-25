// instruction fetch unit
`include "define/const.v"
`include "define/inst.v"

module ifu (
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] pc,
    input wire[`XLEN_WIDTH] rom_data, output reg[`XLEN_WIDTH] rom_addr,
    output reg[`XLEN_WIDTH] inst, output reg[`XLEN_WIDTH] inst_pc
  );

  always @(* ) begin
    rom_addr = pc;
    inst = rom_data;
  end

  always @(posedge clk) begin
    inst_pc = pc;
  end
endmodule
