// instruction fetch unit
`include "define/const.v"
`include "define/inst.v"

`include "rtl/util/dff.v"

module ifu (
    // input: program counter and flush flag
    // 输入：程序计数器和清洗标志
    input wire[`XLEN_WIDTH] pc, input wire flush,
    // output: address of memory accessing
    // 输出：将访问的存储器地址
    output reg[`XLEN_WIDTH] addr,
    // input: memory return data
    // 输入：存储器返回的数据
    input wire[`XLEN_WIDTH] data,
    // output: instruction fecthed
    // 输出：获取到的指令
    output reg[`XLEN_WIDTH] inst
  );

  always @(* ) begin
    addr = pc;
    if (flush) begin
      inst = `INST_NOP;
    end
    else begin
      inst = data;
    end
  end
endmodule
