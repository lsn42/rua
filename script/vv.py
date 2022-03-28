# iverilog -> vvp -> gtkwave
import sys
import os
import subprocess
import logging

# logging.basicConfig(level=logging.DEBUG)
logging.basicConfig(level=logging.INFO)

TESTBENCH_DIR = "./testbench"


def vv(func, name, file):

    if (func == "build"):
        cmd = ["iverilog"] +\
            ["-o", os.path.join(".", "out", name+".out")] + [file]
        logging.debug("cmd: " + str(cmd))
        if (subprocess.Popen(cmd).wait() != 0):
            exit()

        cmd = ["vvp"] + [os.path.join(".", "out", name+".out")]
        logging.debug(cmd)
        subprocess.Popen(cmd).wait()

        cmd = ["gtkwave"] +\
            ["--rcfile", os.path.join(os.path.expanduser("~"), ".gtkwaverc")] +\
            ["-7", "-F", "-o"] +\
            ["-f", os.path.join(".", "wave", name+".vcd")] +\
            ["-a", os.path.join(".", "wave", "gtkw", name+".gtkw")]
        logging.debug(cmd)
        subprocess.Popen(cmd).wait()

    elif(func == "run"):

        cmd = ["gtkwave"] +\
            ["--rcfile", os.path.join(os.path.expanduser("~"), ".gtkwaverc")] +\
            ["-7", "-F", "-o"] +\
            ["-f", os.path.join(".", "wave", name+".vcd")] +\
            ["-a", os.path.join(".", "wave", "gtkw", name+".gtkw")]
        logging.debug(cmd)
        subprocess.Popen(cmd).wait()


if __name__ == "__main__":
    logging.debug("args: "+str(sys.argv))
    func = sys.argv[1]
    file = sys.argv[2]
    name, ext = os.path.splitext(os.path.basename(file))

    for p in ("./out", "./wave", "./wave/gtkw",):
        os.makedirs(p, exist_ok=True)

    if name.rfind("_tb") != -1:
        vv(func, name, file)
    elif ext == ".v" and os.path.isfile(os.path.join(TESTBENCH_DIR, name+"_tb.v")):
        logging.info(
            str(file) + " is not a testbench, but corresponding testbench found.")
        vv(func, name+"_tb", os.path.join(TESTBENCH_DIR, name+"_tb.v"))
    else:
        logging.error(
            str(file) + " is not a testbench, and there is no corresponding testbench")
