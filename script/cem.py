# c/assembly -> elf -> mem+disassembly+readelf
import sys
import os
import logging
import subprocess

# logging.basicConfig(level=logging.DEBUG)
logging.basicConfig(level=logging.INFO)

PLATFORM_ARGS = ["-march=rv32i", "-mabi=ilp32"]

OUT_PATH = "./program/temp/out"
ELF_PATH = "./program/bin/"
MEM_PATH = "./program/mem/"

DISASSEMBLY_PATH = "./program/temp/disassembly/"
READELF_PATH = "./program/temp/readelf/"

START_S = "./program/start.S"
START_OUT = "./program/start.o"
LDSCRIPT = "./script/rua.ld"


def run_subprocess(cmd):
    logging.debug("cmd: " + str(cmd))
    if (subprocess.Popen(cmd).wait() != 0):
        exit()


def run_subprocess_save_output(cmd, file):
    logging.debug("cmd: " + str(cmd))
    sp = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    with open(file, "wb") as f:
        f.write(sp.stdout.read())
    if (sp.wait() != 0):
        exit()


if __name__ == "__main__":
    logging.debug("args: "+str(sys.argv))
    file = sys.argv[1]
    name, ext = os.path.splitext(os.path.basename(file))

    for p in (OUT_PATH, ELF_PATH, MEM_PATH, DISASSEMBLY_PATH, READELF_PATH,):
        os.makedirs(p, exist_ok=True)

    if (os.path.samefile(file, START_S)):
        cmd = ["riscv64-unknown-elf-gcc"] + PLATFORM_ARGS +\
            ["-c", "-o", START_OUT, file]
        run_subprocess(cmd)
    else:
        out = os.path.join(OUT_PATH, name+".o")
        elf = os.path.join(ELF_PATH, name+".elf")
        mem = os.path.join(MEM_PATH, name+".mem")
        disassembly = os.path.join(DISASSEMBLY_PATH, name+".riscv")
        readelf = os.path.join(READELF_PATH, name+".readelf.txt")

        # 编译但不链接程序
        cmd = ["riscv64-unknown-elf-gcc"] + PLATFORM_ARGS +\
            ["-c", "-o", out, file]
        run_subprocess(cmd)
        # 链接成elf程序
        cmd = ["riscv64-unknown-elf-gcc"] + PLATFORM_ARGS +\
            ["-nostdlib", "-T", LDSCRIPT, "-o", elf, out, START_OUT]
        run_subprocess(cmd)
        # 使用Xilinx的SDK中的工具将elf转换为mem
        cmd = ["data2mem.bat", "-bd", elf, "-d", "-o", "m", mem]
        run_subprocess(cmd)
        # 反编译生成的elf
        cmd = ["riscv64-unknown-elf-objdump", "--disassemble-all"] +\
            [elf]
        run_subprocess_save_output(cmd, disassembly)
        # 读取elf信息
        cmd = ["readelf", "-hS"] +\
            [elf]
        run_subprocess_save_output(cmd, readelf)
