`include "define/const.v"

module ram (
    // input: clock, reset
    input wire clk, input wire rst,
    // input: double address input
    // 输入：双口地址
    input wire[`XLEN_WIDTH] addr1, input wire[`XLEN_WIDTH] addr2,
    // output: double data output
    // 输出：双口数据
    output reg[`XLEN_WIDTH] out1, output reg[`XLEN_WIDTH] out2,
    // input: write enable, address and writing data
    // 输入：写使能、地址和将写入的数据
    input wire write_en, input wire[`XLEN_WIDTH] write_addr,
    input wire[`XLEN_WIDTH] write_data
  );

  reg[`BYTE_WIDTH] data[2 ** 16 - 1: 0];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      out1 <= 0;
      out2 <= 0;
    end
    else begin
      if (write_en) begin
        data[write_addr] <= write_data;
      end
      out1 <= {data[addr1 + 3], data[addr1 + 2], data[addr1 + 1], data[addr1]};
      out2 <= {data[addr2 + 3], data[addr2 + 2], data[addr2 + 1], data[addr2]};
    end
  end

endmodule
