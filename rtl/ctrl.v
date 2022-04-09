`include "define/const.v"
`include "define/inst.v"

module ctrl(
    // input: clock, reset
    input wire clk, input wire rst,
    // input: pause, unpause and flush signals from different modules
    // 输入：各模块传递过来的暂停、恢复和清洗的请求信号
    input id_pause_signal,
    input ex_unpause_signal, input ex_flush_signal,
    input mem_unpause_signal,
    // output: output pause and flush signals after judgement
    // 输出：裁定后向各模块发送的暂停、清洗命令
    output reg pause, output reg flush
  );

  always@(* ) begin
    // reset
    // 重置
    if (rst) begin
      pause = `false;
      flush = `false;
    end
    // pause judgement
    // 暂停裁定
    if (ex_unpause_signal | mem_unpause_signal) begin
      pause = `false;
    end
    else if (id_pause_signal) begin
      if (!flush) begin
        pause = `true;
      end
      else begin
        pause = `false;
      end
    end
  end

  always @(posedge clk or posedge rst) begin
    // flush judgement
    // 清洗裁定
    flush <= ex_flush_signal;
  end

endmodule
