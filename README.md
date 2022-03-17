# RUA
一定是iStyle的阴谋

rtl/alu.v中:
``` verilog
case(funct3):
`INST_FUNCT3_SLL: begin
  rd <= rs1 << rs2[4:
                    0];
end
```