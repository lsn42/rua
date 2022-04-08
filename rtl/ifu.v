// instruction fetch unit
`include "define/const.v"
`include "define/inst.v"

`include "rtl/util/dff.v"

module ifu (
    // input: clock, reset
    input wire clk, input wire rst,
    // input: jump flag and jump address, pause flag
    // 输入：跳转标志和跳转地址，暂停标志
    input wire pause, input wire jump, input wire[`XLEN_WIDTH] jump_addr,
    // output: address of memory accessing
    // 输出：将访问的存储器地址
    output reg[`XLEN_WIDTH] addr,
    // input: memory return data
    // 输入：存储器返回的数据
    input wire[`XLEN_WIDTH] data,
    // output: instruction fecthed and it's address
    // 输出：获取到的指令
    output reg[`XLEN_WIDTH] inst, output wire[`XLEN_WIDTH] inst_addr
  );

  reg[`XLEN_WIDTH] pc;

  dff#(`XLEN) delay_inst_addr(
         .en(`true), .clk(clk), .rst(rst),
         .d(addr), .q(inst_addr));

  // PC change rule
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      pc <= `CPU_START_ADDR;
    end
    else if (jump) begin
      pc <= jump_addr;
    end
    else if (pause) begin
      pc <= pc;
    end
    else begin
      pc <= pc + 4;
    end
  end

  always @(* ) begin
    addr = pc;
    inst = data;
  end
endmodule
