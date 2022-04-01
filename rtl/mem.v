// memory
`include "define/const.v"
`include "define/inst.v"

module mem(
    // input: load enable, address and data
    // 输入：加载使能、地址和数据
    input wire load_en, input wire[`XLEN_WIDTH] load_addr,
    input wire[`REG_ADDR] load_regs_addr,
    // input: store enable, address and data
    // 输入：存储使能、地址和数据
    input wire[1: 0] store_mode, input wire[`XLEN_WIDTH] store_addr,
    input wire[`XLEN_WIDTH] store_data,
    // output: RAM read address
    // 输出：RAM读地址
    output reg[`XLEN_WIDTH] ram_read_addr,
    // output: RAM read address
    // 输出：RAM读数据
    input wire[`XLEN_WIDTH] ram_read_data,
    // output: RAM write enable, address and data
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

  always @(* ) begin

    // default value
    ram_read_addr = 0;
    ram_write_mode = 2'b00;
    ram_write_addr = 0;
    ram_write_data = 0;
    regs_write_en = `false;
    regs_write_addr = 0;
    regs_write_data = 0;
    unpause_signal = `false;

    // 现在是直接传递
    ram_write_mode = store_mode;
    ram_write_addr = store_addr;
    ram_write_data = store_data;

    if (load_en) begin
      ram_read_addr = load_addr;
      regs_write_en = `true;
      regs_write_addr = load_regs_addr;
      regs_write_data = ram_read_data;
      unpause_signal = `true;
    end
  end

endmodule
