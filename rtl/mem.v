// memory
`include "define/const.v"
`include "define/inst.v"

module mem(
    input wire load_en, input wire[`XLEN_WIDTH] load_addr,
    input wire[`REG_ADDR] load_regs_addr,
    
    input wire store_en, input wire[`XLEN_WIDTH] store_addr,
    input wire[`XLEN_WIDTH] store_data,

    output reg[`XLEN_WIDTH] ram_read_addr, input wire[`XLEN_WIDTH] ram_read_data,
    output reg ram_write_en,
    output reg[`XLEN_WIDTH] ram_write_addr, output reg[`XLEN_WIDTH] ram_write_data,

    output reg regs_write_en, output reg[`REG_ADDR] regs_write_addr,
    output reg[`XLEN_WIDTH] regs_write_data,

    output reg unpause_signal
  );

  always @(* ) begin

    // default value
    ram_read_addr = 0;
    ram_write_en = `false;
    ram_write_addr = 0;
    ram_write_data = 0;
    regs_write_en = `false;
    regs_write_addr = 0;
    regs_write_data = 0;
    unpause_signal = `false;

    if (load_en) begin
      ram_read_addr = load_addr;
      regs_write_en = `true;
      regs_write_addr = load_regs_addr;
      regs_write_data = ram_read_data;
      unpause_signal = `true;
    end
    if (store_en) begin
      ram_write_en = `true;
      ram_write_addr = store_addr;
      ram_write_data = store_data;
    end
  end

endmodule
