// instruction fetch unit
`include "define/const.v"
`include "define/inst.v"

`include "rtl/util/dff.v"

module ifu (
    input wire[`XLEN_WIDTH] pc,
    input wire[`XLEN_WIDTH] data, output reg[`XLEN_WIDTH] addr,
    output reg[`XLEN_WIDTH] inst,
    input wire flush
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
