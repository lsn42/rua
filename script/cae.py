# c/assembly -> elf -> disassembly+readelf+mem
import sys
import os
import logging
import subprocess

# logging.basicConfig(level=logging.DEBUG)
logging.basicConfig(level=logging.INFO)

PLATFORM_ARGS = ["-march=rv32i", "-mabi=ilp32"]

ELF_PATH = "./program/bin/"
DISASSEMBLY_PATH = "./program/temp/disassembly/"
READELF_PATH = "./program/temp/readelf/"

if __name__ == "__main__":
    logging.debug("args: "+str(sys.argv))
    file = sys.argv[1]
    name, ext = os.path.splitext(os.path.basename(file))

    for p in (ELF_PATH, DISASSEMBLY_PATH, READELF_PATH,):
        os.makedirs(p, exist_ok=True)

    elf = os.path.join(ELF_PATH, name+".elf")

    cmd = ["riscv64-unknown-elf-gcc"] +\
        PLATFORM_ARGS +\
        ["-o", elf] +\
        [file]
    logging.debug("cmd: " + str(cmd))
    if (subprocess.Popen(cmd).wait() != 0):
        exit()

    cmd = ["riscv64-unknown-elf-objdump"] +\
        ["--disassemble-all"] +\
        [elf]
    logging.debug("cmd: " + str(cmd))
    sp = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    with open(os.path.join(DISASSEMBLY_PATH, name+".riscv"), "wb") as f:
        f.write(sp.stdout.read())
    if (sp.wait() != 0):
        exit()

    cmd = ["readelf"] +\
        ["-hS"] +\
        [elf]
    logging.debug("cmd: " + str(cmd))
    sp = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    with open(os.path.join(READELF_PATH, name+".readelf.txt"), "wb") as f:
        f.write(sp.stdout.read())
    if (sp.wait() != 0):
        exit()

    cmd = ["python", "./script/2mem.py"] +\
        ["hex", "byte", "0", "16"] +\
        [elf]
    logging.debug("cmd: " + str(cmd))
    if (subprocess.Popen(cmd).wait() != 0):
        exit()
