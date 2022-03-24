# to mem that can be read by readmemb or readmemh
import sys
import os

MEM_OUT = "./program/mem/"


def mem_hex_byte(data: str, fill: int = 0, readable: int = 0):
    count = 0
    r = ""

    if readable > 0:
        for i in data:
            count += 1
            r += "{:0>2s} ".format(hex(i)[2:])
            if not count % readable:
                r += "\n"
        if fill > 0 and count < fill:
            r += "00 "*((readable-count) % readable) + \
                ("\n"if(readable-count) % readable else"")
            r += ("00 "*readable+"\n")*((fill-count)//readable)
    else:
        for i in data:
            count += 1
            r += hex(i)[2:]+" "
        if fill > 0 and count < fill:
            r += "0 "*(fill-count)

    return (r, count)


def mem_bin_byte(data: str, fill: int = 0, readable: int = 0):
    count = 0
    r = ""

    if readable > 0:
        for i in data:
            count += 1
            r += "{:0>8s} ".format(bin(i)[2:])
            if not count % readable:
                r += "\n"
        if fill > 0 and count < fill:
            r += ("0"*8+" ")*((readable-count) % readable) + \
                ("\n"if(readable-count) % readable else"")
            r += (("0"*8+" ")*readable+"\n")*((fill-count)//readable)
    else:
        for i in data:
            count += 1
            r += bin(i)[2:]+" "
        if fill > 0 and count < fill:
            r += "0 "*(fill-count)

    return (r, count)


if __name__ == "__main__":
    type = sys.argv[1]
    format = sys.argv[2]
    fill = sys.argv[3]
    readable = sys.argv[4]
    files = sys.argv[5:]

    for p in (MEM_OUT,):
        os.makedirs(p, exist_ok=True)

    for f in files:
        name, ext = os.path.splitext(os.path.basename(f))
        with open(f, "rb") as ff:
            data = ff.read()
        if type == "hex":
            if format == "byte":
                r = mem_hex_byte(data, int(fill), int(readable))
                with open(os.path.join(MEM_OUT, "hex", name+".byte.mem"), "w") as ff:
                    ff.write(r[0])
                print("{} -> hex byte: {}".format(f, r[1]))
            elif format == "word":
                pass  # TODO: 下次一定写
        elif type == "bin":
            if format == "byte":
                r = mem_bin_byte(data, int(fill), int(readable))
                with open(os.path.join(MEM_OUT, "bin", name+".byte.mem"), "w") as ff:
                    ff.write(r[0])
                print("{} -> bin byte: {}".format(f, r[1]))
            elif format == "word":
                pass
