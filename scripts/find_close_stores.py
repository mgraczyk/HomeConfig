#!/usr/bin/python3

import sys

from collections import defaultdict
from operator import itemgetter
from itertools import chain

def parse_log(storesLogPath):
    storeLog = []
    with open(storesLogPath, "r") as f:
        for line in f:
            store = line.split(",")
            addr = int(store[0], 16)
            pc = int(store[3], 16)
            storeLog.append((addr, int(store[1]), int(store[2]), pc, int(store[4])))

    return storeLog

def findOverlapping(storeLog, threshold):
    storeAddrs = defaultdict(list)

    storeLog.sort(key=itemgetter(4))

    for store in storeLog:
        storeAddrs[store[0]].append(store[1:])

    minDist = { hex(addr):
            min([abs(stores[i][3] - stores[i-1][3]) for i in range(1, len(stores)) if stores[i][1] != stores[i-1][1]] or [threshold+1])
            for addr, stores in storeAddrs.items()}

    return (addr for addr, dist in minDist.items() if dist < threshold)

def main():
    if len(sys.argv) < 2 or "-h" in sys.argv:
        print("USAGE: {} stores_log_path [threshold]".format(sys.argv[0]))
        exit(1)

    threshold = int(sys.argv[2]) if len(sys.argv) > 2 else 20

    storesLogPath = sys.argv[1]

    storeLog = parse_log(storesLogPath)

    addrs = findOverlapping(storeLog, threshold)

    list(map(print, addrs))

if __name__ == "__main__":
    main()
