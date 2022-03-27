// register
`include "define/const.v"
`include "define/inst.v"

module regs (
    input wire clk, input wire rst,

    input wire[`REG_ADDR] addr1, output reg[`XLEN_WIDTH] out1,
    input wire[`REG_ADDR] addr2, output reg[`XLEN_WIDTH] out2,

    input wire write_en, input wire[`REG_ADDR] write_addr,
    input wire[`XLEN_WIDTH] write_data,

    input wire[`REG_ADDR] mem_read_addr, output reg[`XLEN_WIDTH] mem_read_data,

    input wire mem_write_en, input wire[`REG_ADDR] mem_write_addr,
    input wire[`XLEN_WIDTH] mem_write_data
  );

  reg[`XLEN_WIDTH] data[`REG_COUNT - 1: 0];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      data[0] <= 0;
    end
    else if (write_en && write_addr != 0) begin
      data[write_addr] <= write_data;
    end
    else if (mem_write_en && mem_write_addr != 0) begin
      data[mem_write_addr] <= mem_write_data;
    end
  end

  always @(* ) begin
    if (write_en && write_addr == addr1) begin
      out1 = write_data;
    end
    else begin
      out1 <= data[addr1];
    end
  end
  always @(* ) begin
    if (write_en && write_addr == addr2) begin
      out2 = write_data;
    end
    else begin
      out2 <= data[addr2];
    end
  end
  always @(* ) begin
    mem_read_data <= data[mem_read_addr];
  end
endmodule
