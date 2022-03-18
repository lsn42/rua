// register
`include "define/const.v"
`include "define/inst.v"

module regs (
    input wire clk, input wire rst,
    input wire[`REG_ADDR] addr1, output reg[`XLEN_WIDTH] out1,
    input wire[`REG_ADDR] addr2, output reg[`XLEN_WIDTH] out2,
    input wire write_en, input wire[`REG_ADDR] write_addr, input wire[`XLEN_WIDTH] in
  );

  reg[`XLEN_WIDTH] data[`REG_COUNT - 1: 0];

  always @(posedge clk or posedge rst) begin
    if (rst)
    begin
      data[0] <= 0;
    end
  end

  always @(posedge clk) begin
    if (write_en && write_addr != 0)
    begin
      data[write_addr] <= in;
    end
  end
  always @(* )
  begin
    out1 <= data[addr1];
  end
  always @(* )
  begin
    out2 <= data[addr2];
  end
endmodule
