#!/usr/bin/python

import sys
import re
import json
import operator

from collections import defaultdict
from collections import namedtuple
from itertools import repeat

BranchEvent = namedtuple("BranchEvent", ["actual", "prediction"])

UnknownBranch = BranchEvent("X", "X")

# iss branch events look like:
# PCYC=5684:T0:PC=00000d2c:BRANCH:EVENT=P:RESULT=N:JUMP_PA=d30
utraceBranchRe = re.compile("PCYC=(\d*):T(\d*):PC=([0-9a-fA-F]*):BRANCH:EVENT=(.*):RESULT=(.*):JUMP_PA=([0-9a-fA-F]*)")
pktidBranchRe = re.compile("Branch Info:Time=(?P<time>\d+):Tid=(?P<tid>\d+):Branch PC=(?P<br_pc>0x[0-9a-fA-F]+):Next PC=(?P<next_pc>0x[0-9a-fA-F]+)Predicted Direction=(?P<pred>[01]):Actual Direction=(P<actual>[01])")

def get_iss_branches(uarchtrace):
    directions = defaultdict(list)
    predictions = defaultdict(list)

    for line in uarchtrace:
        match = utraceBranchRe.match(line)
        if match:
            groups = match.groups()
            result = groups[4]
            addr = hex(int(groups[5], 16))
            if groups[3] == "C":
                directions[addr].append(result)
            elif groups[3] == "P":
                predictions[addr].append(result)


    branches = { addr: list(map(BranchEvent, d, predictions[addr]))
            for addr,d in directions.items() }
    return branches

def rtl_direction_to_letter(direction):
    return "T" if int(direction) else "N"

def get_rtl_branches(pktidLog):
    branches = {}

    for line in pktidLog:
        match = pktidBranchRe.match(line)
        if match:
            groups = match.groupdict()
            addr = hex(int(groups["br_pc"], 16))
            actual = rtl_direction_to_letter(groups["actual"])
            prediction = rtl_direction_to_letter(groups["pred"])
            branches[addr].append(BranchEvent(actual, prediction))

    return branches

def get_golden_branches(issBranches):
    return { addr: list(BranchEvent(br.actual, br.actual) for br in brs) for addr,brs in issBranches.items() }

def gen_branch_trace(uarchtracePath, pktidPath):
    with open(uarchtracePath, "r") as f:
        issEvents = get_iss_branches(f)
        rtlEvents = get_rtl_branches(f)
    golden = get_golden_branches(issEvents)

    return { "iss": issEvents, "rtl": rtlEvents, "golden": golden }

def print_readable(fp, branchData):
    addrs = reduce(operator.or_, (set(v.keys()) for v in branchData.values()))

    infoSorted = list(sorted(branchData.items(), key=operator.itemgetter(0)))

    # No in order traversal?
    for addr in sorted(addrs):
        fp.write("addr," + addr + "\n")
        for name, allEvents in infoSorted:
            addrEvents = allEvents.get(addr) or (UnknownBranch,)
            fp.write(name + ",")
            fp.write(",".join(e.prediction for e in addrEvents))
            fp.write("\n")

        fp.write("\n")

def main():
    if len(sys.argv) >= 3:
        uarchtracePath = sys.argv[1]
        pktidPath = sys.argv[2]
    else:
        print("USAGE: {} uarchtrace pktid_log".format(sys.argv[0]))
        exit(1)
  
    branchData = gen_branch_trace(uarchtracePath, pktidPath)
    print_readable(sys.stdout, branchData)

if __name__ == "__main__":
    main()
