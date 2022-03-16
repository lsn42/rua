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

    if (re.match(".*_tb(_.+)?$", name)):
        if (func == "build"):
            cmd = ["iverilog"] + ["-y", "./rtl"] + \
                ["-o", os.path.join(".", "out", name+".out")] + files
            logging.debug("cmd: " + str(cmd))
            if (subprocess.Popen(cmd).wait() != 0):
                exit()

            cmd = ["vvp"] + [os.path.join(".", "out", name+".out")]
            logging.debug(cmd)
            subprocess.Popen(cmd).wait()

        elif(func == "buildrun"):

            cmd = ["iverilog"] + ["-y", "./rtl"] + \
                ["-o", os.path.join(".", "out", name+".out")] + files
            logging.debug(cmd)
            if (subprocess.Popen(cmd).wait() != 0):
                exit()

            cmd = ["vvp"] + [os.path.join(".", "out", name+".out")]
            logging.debug(cmd)
            subprocess.Popen(cmd).wait()

            cmd = ["gtkwave"] + [os.path.join(".", "wave", name+".vcd")] + \
                ["--rcfile",
                    os.path.join(os.path.expanduser("~"), ".gtkwaverc")]
            logging.debug(cmd)
            subprocess.Popen(cmd).wait()
    else:
        logging.info("may not be a testbench")
