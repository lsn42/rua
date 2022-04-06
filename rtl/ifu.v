// instruction fetch unit
`include "define/const.v"
`include "define/inst.v"

`include "rtl/util/pldff.v"

module ifu (
    // input: clock, reset
    input wire clk, input wire rst,
    // input: jump flag and jump address, pause flag
    // 输入：跳转标志和跳转地址，暂停标志
    input wire jump, input wire[`XLEN_WIDTH] jump_addr,
    input wire pause, input wire flush,
    // input: program counter and flush flag
    // 输入：程序计数器和清洗标志
    // output: address of memory accessing
    // 输出：将访问的存储器地址
    output reg[`XLEN_WIDTH] addr,
    // input: memory return data
    // 输入：存储器返回的数据
    input wire[`XLEN_WIDTH] data,
    // output: instruction fecthed
    // 输出：获取到的指令
    output reg[`XLEN_WIDTH] inst,
    output wire[`XLEN_WIDTH] inst_addr
  );

  reg[`XLEN_WIDTH] pc;

  reg[`XLEN_WIDTH] _addr, s;

  pldff#(`XLEN) dff_inst_addr(
         .en(!pause), .clk(clk), .rst(rst | flush),
         .d(pc), .q(inst_addr));

  // PC change
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
    // _inst = data;
    s <= pause ? s : _addr;
  end

  // select
  always @(* ) begin
    _addr = pc;
    // _inst = data;
    // s = pause ? s : _inst;
    if (flush) begin
      inst = `INST_NOP;
    end
    // else if (pause) begin
    //   inst = s;
    // end
    else begin
      inst = data;
    end
    if (pause) begin
      addr = s;
    end
    else begin
      addr = _addr;
    end
  end
endmodule
