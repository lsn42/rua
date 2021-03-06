`include "rtl/rua.v"

module rua_tb();

  reg clk, rst;

  rua dut(.clk(clk), .rst(rst));

  parameter clk_period = 10;
  initial
    clk = 1;
  always#(clk_period / 2) clk = ~clk;

  integer i;

  initial begin
    $dumpfile("./wave/rua_tb.vcd");
    $dumpvars;
    $readmemh("./program/mem/empty32.mem", dut.regs.data, 0, 31);
    $readmemh("./program/mem/fibonacci.mem", dut.ram.data, 0, 65535);
    rst = 1;
    @(posedge clk) rst = 0;
    for (i = 0; i < 100; i = i + 1) begin
      @(posedge clk);
    end
    $finish;
  end

endmodule
