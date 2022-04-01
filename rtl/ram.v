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
    // input: write mode(none, byte, 16-bits, word), address and writing data
    // 输入：写入模式（不写、字节、16比特、字）、地址和将写入的数据
    input wire[1: 0] write_mode, input wire[`XLEN_WIDTH] write_addr,
    input wire[`XLEN_WIDTH] write_data
  );

  reg[`BYTE_WIDTH] data[2 ** 16 - 1: 0];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      out1 <= 0;
      out2 <= 0;
    end
    else begin
      case (write_mode)
        2'b00:
          ;
        2'b01: begin
          data[write_addr] <= write_data[7: 0];
        end
        2'b10: begin
          data[write_addr] <= write_data[7: 0];
          data[write_addr + 1] <= write_data[15: 8];
        end
        2'b11: begin
          data[write_addr] <= write_data[7: 0];
          data[write_addr + 1] <= write_data[15: 8];
          data[write_addr + 2] <= write_data[23: 16];
          data[write_addr + 3] <= write_data[31: 24];
        end
      endcase
      out1 <= {data[addr1 + 3], data[addr1 + 2], data[addr1 + 1], data[addr1]};
      out2 <= {data[addr2 + 3], data[addr2 + 2], data[addr2 + 1], data[addr2]};
    end
  end

endmodule
