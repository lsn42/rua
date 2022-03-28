`include "define/const.v"
`include "define/inst.v"

module ctrl(
    input wire clk, input wire rst,
    input pause_signal, input unpause_signal, output reg pause,
    input flush_signal, output reg flush
  );

  always@(* ) begin
    if (pause_signal) begin
      pause = `true;
    end
  end

  always@(posedge clk or posedge rst) begin
    if (rst )begin
      pause = `false;
    end
    else begin
      if (!pause_signal && unpause_signal) begin
        pause = `false;
      end
    end
  end

endmodule
