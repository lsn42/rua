// instruction fetch unit
`include "define/const.v"
`include "define/inst.v"

module ifu (
    input wire clk, input wire rst,
    input wire[`XLEN_WIDTH] pc,
    input wire[`XLEN_WIDTH] rom_data, output reg[`XLEN_WIDTH] rom_addr,
    output reg[`XLEN_WIDTH] inst
  );

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      rom_addr <= 0;
      inst <= 0;
    end
    else begin
      rom_addr <= pc;
      inst <= rom_data;
    end
  end
endmodule
