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
    if len(sys.argv) < 2 or "-h" in sys.argv:
        print("USAGE: {} rundir results_path".format(sys.argv[0]))
        exit(1)

    inpath = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    outpath = sys.argv[2] if len(sys.argv) > 2 else os.getcwd() + "/results.csv"

    sweep = get_zebu_sweep(inpath)

    iss = sweep.slice_dimension("model", "iss")
    zebu = sweep.slice_dimension("model", "zebu")

    ratios = Sweep(iss.domain_names, iss.domain_values, iss.data/zebu.data)

    try:
        os.makedirs(os.path.dirname(outpath))
    except FileExistsError:
        pass

    with open(outpath, "wb+") as fp:
        fp.write(b"Test Names\n")
        fp.write(bytes("\n".join(iss.values_for_domain("test")), encoding="ascii"))
        fp.write(b"\n\nISS Results\n")
        iss.ToCsv(fp)
        fp.write(b"\n\nZEBU Results\n")
        zebu.ToCsv(fp)
        fp.write(b"\n\nRatio: ISS/ZEBU\n")
        ratios.ToCsv(fp)

    print()
