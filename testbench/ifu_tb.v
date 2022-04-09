`include "define/const.v"

`include "rtl/ifu.v"
`include "rtl/ram.v"
`include "rtl/ctrl.v"

module ifu_tb();

  reg pause_signal, unpause_signal;
  wire pause;
  reg jump;
  reg [`XLEN_WIDTH] jump_addr;
  wire [`XLEN_WIDTH] addr, data, inst, inst_addr;

  reg clk, rst;

  ifu dut_ifu(
        .clk(clk), .rst(rst),
        .jump(jump), .jump_addr(jump_addr),
        .pause(pause),
        .addr(addr),
        .data(data),
        .inst(inst), .inst_addr(inst_addr));

  ram dut_ram(
        .clk(clk), .rst(rst),
        .addr1(addr), .addr2(),
        .out1(data), .out2(),
        .write_mode(), .write_addr(),
        .write_data());

  ctrl dut_ctrl(
    .clk(clk), .rst(rst),
    .id_pause_signal(pause_signal),
    .ex_unpause_signal(), .ex_flush_signal(),
    .mem_unpause_signal(unpause_signal),
    .pause(pause), .flush()
  );

  parameter clk_period = 10;
  initial begin
    clk = 1;
    rst = 1;
    jump = 0;
    pause_signal = 0;
    unpause_signal = 0;
    jump_addr = 0;
  end
  always#(clk_period / 2) clk = ~clk;

  integer i;

  initial begin
    $dumpfile("./wave/ifu_tb.vcd");
    $dumpvars;
    // $readmemh("./program/mem/empty32.mem", dut.regs.data, 0, 31);
    $readmemh("./program/mem/fibonacci.mem", dut_ram.data, 0, 65535);
    @(posedge clk) rst = 0;
    for (i = 0; i < 100; i = i + 1) begin
      if (i == 0) begin
        pause_signal = 1;
      end
      if (i == 2) begin
        pause_signal = 0;
      end
      // if (i == 4) begin
      //   pause_signal = 1;
      // end
      // if (i == 7) begin
      //   pause_signal = 0;
      // end
      // if (i == 5) begin
      //   jump = 1;
      //   jump_addr = 0;
      // end
      // if (i == 6) begin
      //   jump = 0;
      // end
      @(posedge clk);
    end
    $finish;
  end

endmodule
