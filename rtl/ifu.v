// instruction fetch unit
`include "define/const.v"
`include "define/inst.v"

`include "rtl/util/dff.v"

module ifu (
    input wire[`XLEN_WIDTH] pc,
    input wire[`XLEN_WIDTH] data, output reg[`XLEN_WIDTH] addr,
    output reg[`XLEN_WIDTH] inst
  );

  always @(* ) begin
    addr = pc;
    inst = data;
  end
  
endmodule
