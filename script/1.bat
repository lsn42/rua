c:\msys64\mingw64\bin\riscv64-unknown-elf-gcc.exe -S -o.\program\assembly\fibonacci2.s -march=rv32i -mabi=ilp32 .\program\c\fibonacci.c
c:\msys64\mingw64\bin\riscv64-unknown-elf-objcopy.exe -O binary .\program\elf\fibonacci1.elf -o.\program\bin\fibonacci1.bin
c:\msys64\mingw64\bin\riscv64-unknown-elf-objdump.exe --disassemble-all .\program\elf\fibonacci1.elf > .\program\elf\fibonacci1.elf.dump