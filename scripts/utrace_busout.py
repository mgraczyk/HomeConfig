#!/usr/bin/python3

import re
from collections import defaultdict

class BusAtype(object):
    def __init__(self):
        self.out = 0
        self.maxout = 0

def fix_aname(traceName):
    if traceName in ("DREAD", "L2FETCH", "IFETCH","L2FETCH_L2F","DCFETCH","L2FETCH_IU"):
        return "READ"
    elif traceName in ("UNKNOWN","EVICTION","DWRITE"):
        return "WRITE"
    else:
        return traceName

def main():
    atypes = defaultdict(BusAtype)
    busRegex = re.compile("BUS(REQ|RSP):TYPE=(\w*?):")

    with open("utrace.log", "r") as f:
        for lnum,line in enumerate(f):
            match = busRegex.search(line)
            if match:
                ttype = match.group(1)
                aname = fix_aname(match.group(2))
                atype = atypes[aname]
                if ttype == "REQ":
                    atype.out += 1
                elif ttype == "RSP":
                    atype.out -= 1

                if atype.out > atype.maxout:
                    atype.maxout = atype.out
                    print('Out["{}"] hits {} line {}'.format(aname, atype.out, lnum))

    assert(all(atype.out == 0 for atype in atypes.values()))
    print("Maxes:")
    [print("{}={}".format(aname,atype.maxout)) for aname,atype in atypes.items()]

if __name__ == "__main__":
    main()
