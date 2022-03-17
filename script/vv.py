import sys
import os
import re
import subprocess
import logging

# logging.basicConfig(level=logging.DEBUG)
logging.basicConfig(level=logging.INFO)

if __name__ == "__main__":
    logging.debug("args: "+str(sys.argv))
    func = sys.argv[1]
    files = sys.argv[2:]
    name = (lambda x: x[:x.rfind(".")])(os.path.basename(files[0]))

    if not os.path.exists("./out"):
        os.mkdir("./out")
    if not os.path.exists("./wave"):
        os.mkdir("./wave")
    if not os.path.exists("./wave/gtkw"):
        os.mkdir("./wave/gtkw")

    if (name.rfind("_tb") != -1):
        if (func == "build"):
            cmd = ["iverilog"] +\
                ["-o", os.path.join(".", "out", name+".out")] + files
            logging.debug("cmd: " + str(cmd))
            if (subprocess.Popen(cmd).wait() != 0):
                exit()

            cmd = ["vvp"] + [os.path.join(".", "out", name+".out")]
            logging.debug(cmd)
            subprocess.Popen(cmd).wait()

            cmd = ["gtkwave"] +\
                ["--rcfile", os.path.join(os.path.expanduser("~"), ".gtkwaverc")] +\
                ["-f", os.path.join(".", "wave", name+".vcd")] +\
                ["-a", os.path.join(".", "wave", "gtkw", name+".gtkw")] +\
                ["-7"]
            logging.debug(cmd)
            subprocess.Popen(cmd).wait()

        elif(func == "run"):

            cmd = ["gtkwave"] +\
                ["--rcfile", os.path.join(os.path.expanduser("~"), ".gtkwaverc")] +\
                ["-f", os.path.join(".", "wave", name+".vcd")] +\
                ["-a", os.path.join(".", "wave", "gtkw", name+".gtkw")] +\
                ["-7"]
            logging.debug(cmd)
            subprocess.Popen(cmd).wait()

    else:
        logging.error(str(files)+" may not contain testbench")
