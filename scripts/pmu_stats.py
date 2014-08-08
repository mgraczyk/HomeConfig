#!/usr/bin/python3

import sys
import json
import re

pmuRe = re.compile("(?:([^:]*):)?([^:]+):([^:]+)")

def parse_pmu_fp(f):
    values = {}
    for num, line in enumerate(f):
        match = pmuRe.search(line.replace(" ", "").replace("\n", ""))
        if match:
            groups = match.groups()
            # Sometimes the first capture group is missing :(
            if len(groups) < 3:
                raise ValueError("Pmu Stat missing data at line " + str(num))
            values[groups[-2]] = int(groups[-1], 0)

    return values

def parse_pmu_file(rootdir, filePath):
    with open(filePath, 'r') as f:
        return (rootdir, parse_pmu_fp(f))

if __name__ == "__main__":
    sys.stdout.write(json.dumps(parse_pmu_fp(sys.stdin), separators=(',',':')))
    print()
