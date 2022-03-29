`include "define/const.v"
`include "define/inst.v"

module ctrl(
    // clk, rst
    input wire clk, input wire rst,
    // pause, unpause, flush signals from different modules
    input id_pause_signal,
    input ex_unpause_signal, input ex_flush_signal,
    input mem_unpause_signal,
    // output pause and flush signals
    output reg pause, output reg flush
  );

  always@(posedge clk or posedge rst) begin
    // rst
    if (rst) begin
      pause <= `false;
    end
    // pause judgement
    if (ex_unpause_signal | mem_unpause_signal) begin
      pause <= `false;
    end
    else if (id_pause_signal) begin
      pause <= `true;
    end
    // flush judgement
    if (ex_flush_signal) begin
      flush <= `true;
      pause <= `false;
    end
    else begin
      flush <= `false;
    end
  end

endmodule
