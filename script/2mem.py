# to mem that can be read by readmemb or readmemh
import sys
import os

MEM_OUT = "./program/mem/"


def mem_hex_byte(data, fill=-1):
    count = 0
    data_hex = ""
    for i in data:
        data_hex += hex(i)[2:]+" "
        count += 1
    if fill != -1:
        data_hex += " 00"*(fill-count-1)
    print(count)
    return data_hex


if __name__ == "__main__":
    type = sys.argv[1]
    format = sys.argv[2]
    fill = sys.argv[3]
    files = sys.argv[4:]

    for p in (MEM_OUT,):
        os.makedirs(p, exist_ok=True)

    for f in files:
        name, ext = os.path.splitext(os.path.basename(f))
        with open(f, "rb") as ff:
            data = ff.read()
        if type == "hex":
            if format == "byte":
                with open(os.path.join(MEM_OUT, "hex", name+".byte.mem"), "w") as ff:
                    ff.write(mem_hex_byte(data, int(fill)))
            elif format == "word":
                pass
        elif type == "bin":
            pass
