// memory
`include "define/const.v"
`include "define/inst.v"

`include "rtl/util/dff.v"

module mem(
    // input: clock, reset
    input wire clk, input wire rst,
    // input: load mode, address and destination register address
    // 输入：加载模式、地址和目的寄存器地址
    input wire[2: 0] load_mode, input wire[`XLEN_WIDTH] load_addr,
    input wire[`REG_ADDR] load_dest_regs_addr,
    // input: store enable, address and data
    // 输入：存储使能、地址和数据
    input wire[1: 0] store_mode, input wire[`XLEN_WIDTH] store_addr,
    input wire[`XLEN_WIDTH] store_data,
    // output: RAM read address
    // 输出：RAM读地址
    output reg[`XLEN_WIDTH] ram_read_addr,
    // output: RAM read address
    // 输入：RAM读数据
    input wire[`XLEN_WIDTH] ram_read_data,
    // output: RAM write mode, address and data
    // 输出：RAM写模式、地址和数据
    output reg[1: 0] ram_write_mode,
    output reg[`XLEN_WIDTH] ram_write_addr, output reg[`XLEN_WIDTH] ram_write_data,
    // output: register write enable, address and data
    // 输出：寄存器写使能、地址和数据
    output reg regs_write_en, output reg[`REG_ADDR] regs_write_addr,
    output reg[`XLEN_WIDTH] regs_write_data,
    // output: unpause signal after loaded data
    // 输出：加载数据后的恢复信号
    output reg unpause_signal
  );

  wire [2: 0] wait_load_mode;
  dff#(3, 3'b111) delay_load_mode(
       .en(`true), .clk(clk), .rst(rst),
       .d(load_mode), .q(wait_load_mode));

  wire [`REG_ADDR] wait_regs_write_addr;
  dff#(5) delay_regs_write_addr(
       .en(`true), .clk(clk), .rst(rst),
       .d(load_dest_regs_addr), .q(wait_regs_write_addr));

  always @(* ) begin

    // 直接传递存储
    ram_write_mode = store_mode;
    ram_write_addr = store_addr;
    ram_write_data = store_data;

    // 加载
    ram_read_addr = load_addr;
    regs_write_en = `true;
    regs_write_addr = wait_regs_write_addr;
    unpause_signal = `true;
    case (wait_load_mode)
      `INST_FUNCT3_LB:
        regs_write_data = $signed(ram_read_data[7: 0]);
      `INST_FUNCT3_LH:
        regs_write_data = $signed(ram_read_data[15: 0]);
      `INST_FUNCT3_LW:
        regs_write_data = ram_read_data;
      `INST_FUNCT3_LBU:
        regs_write_data = $unsigned(ram_read_data[7: 0]);
      `INST_FUNCT3_LHU:
        regs_write_data = $unsigned(ram_read_data[15: 0]);
      default: begin
        regs_write_en = `false;
        regs_write_addr = 0;
        regs_write_data = 0;
        unpause_signal = `false;
      end
    endcase
  end

endmodule
