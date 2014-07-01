#!/usr/bin/python3

import sys
import os

import numpy as np

from Sweep import Sweep
from collect_stats import collect_stats
from collect_stats import smooth_tree
from collect_stats import deep_replace

from itertools import chain

def get_zebu_sweep(path):
    sweep = collect_stats(path, [])

    archData = []
    zebuData = []
    trimmedNames = []

    testNames = list(sweep.values_for_domain("test"))

    test = 0
    while test < len(testNames):
        zebuName = testNames[test]
        zebuSuffix = zebuName.find("_angel_256")
        if zebuSuffix >= 0:
            archName = testNames[test+1]
            archSuffix = archName.find("_archsim")
            if archSuffix >= 0 and zebuName[:zebuSuffix] == archName[:archSuffix]:
                zebuData.append(sweep.slice_test(zebuName).data)
                archData.append(sweep.slice_test(archName).data)
                trimmedNames.append(zebuName[:zebuSuffix])
                test += 1
        test += 1

    newDomainValues = sweep.domain_values[:]
    newDomainValues[sweep.domain_names.index("test")] = trimmedNames

    return Sweep(
            list(chain(["model"], sweep.domain_names)),
            [["iss", "zebu"]] + newDomainValues,
            [archData, zebuData])

if __name__ == "__main__":
    inpath = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    outpath = sys.argv[2] if len(sys.argv) > 2 else os.getcwd()

    sweep = get_zebu_sweep(inpath)

    iss = sweep.slice_dimension("model", "iss")
    zebu = sweep.slice_dimension("model", "zebu")

    result = Sweep(iss.domain_names, iss.domain_values, iss.data/zebu.data)
    iss.ToCsvPath(os.path.join(outpath, "iss.csv"))
    zebu.ToCsvPath(os.path.join(outpath, "zebu.csv"))
    result.ToCsvPath(os.path.join(outpath, "result.csv"))

    with open(os.path.join(outpath, "tests.csv"), "w") as f:
        f.write("\n".join(iss.values_for_domain("test")))

    print()
