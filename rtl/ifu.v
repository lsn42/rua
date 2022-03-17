// instruction fetch unit
`include "define/const.v"
`include "define/inst.v"

module ifu (
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] pc,
    output reg[`XLEN_WIDTH] inst,
    input wire[`XLEN_WIDTH] rom_data,
    output reg[`XLEN_WIDTH] rom_addr
  );
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      inst <= 0;
      rom_addr <= 0;
    end else begin
      rom_addr <= pc;
      inst <= rom_data;
    end
  end
endmodule
