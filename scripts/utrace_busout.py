#!/usr/bin/python3

def main():
    with open("utrace.log", "r") as f:
        maxout = 0
        out = 0
        for lnum,line in enumerate(f):
            if "BUSRSP" in line:
                out -= 1
            elif "BUSREQ" in line:
                out += 1
            if out > maxout:
                maxout = out
                print("Out at {} hits {}".format(lnum,out))

        assert(out == 0)

if __name__ == "__main__":
    main()
