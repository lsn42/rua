// program counter
`include "define/const.v"
`include "define/inst.v"
module pc(
    // input: clock, reset
    input wire clk, input wire rst,
    // input: jump flag and jump address, pause flag
    // 输入：跳转标志和跳转地址，暂停标志
    input wire jump, input wire[`XLEN_WIDTH] jump_addr,
    input wire pause,
    // output: program counter output
    // 输出：程序计数器输出
    output reg[`XLEN_WIDTH] out
  );

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      out <= `CPU_START_ADDR;
    end
    else if (jump) begin
      out <= jump_addr;
    end
    else if (pause) begin
      out <= out;
    end
    else begin
      out <= out + 4;
    end
  end
endmodule
