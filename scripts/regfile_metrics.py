#!/usr/bin/python3

import sys
import os
import json

from operator import itemgetter

from run_sweep import run_sweep
from collect_stats import collect_data_file

def parse_metrics_file(rootDir, filePath):
    with open(filePath, "r") as f:
        return (os.path.basename(rootDir), json.load(f))

def convert_reads_to_rates(results, reads):
    results["RAR"] /= reads
    results["RAW"] /= reads

def convert_writes_to_rates(results, writes):
    results["WAW"] /= writes
    results["WAR"] /= writes

def convert_test_to_rates(metrics):
    writes = metrics["writes"]
    reads = metrics["reads"]

    if reads:
        for results in metrics["conflicts"]:
            convert_reads_to_rates(results, reads)
    if writes:
        for results in metrics["conflicts"]:
            convert_writes_to_rates(results, writes)

def dict_reduce(dicts, op):
    if not dicts:
        return {}
    else:
        baseDict = dicts[0]
        return { k: op(map(itemgetter(k), dicts)) for k in baseDict }

def tests_reduce(tests, op=sum):
    result = {
        "threads" : [{
            "conflicts": [
                dict_reduce(ds, op)
                for ds in zip(*map(itemgetter("conflicts"), ts))
            ],
            "reads": op(map(itemgetter("reads"), ts)),
            "writes": op(map(itemgetter("writes"), ts))
        } for ts in zip(*map(itemgetter("threads"), tests))] }
    return result

def test_reduce(test, op=sum):
    result = {
            "conflicts": [
                dict_reduce(ds, op)
                for ds in zip(*map(itemgetter("conflicts"), ts))
            ],
            "reads": op(map(itemgetter("reads"), ts)),
            "writes": op(map(itemgetter("writes"), ts))
        }
    return result

def test_map(test, op):
    result = {
        "threads" : [{
            "conflicts": [
                { k: op(v) for k,v in conflict.items() }
                for conflict in thread["conflicts"]
            ],
            "reads": op(thread["reads"]),
            "writes": op(thread["writes"])
        } for thread in test["threads"] ] }
    return result

def main():
    if len(sys.argv) < 3:
        print("USAGE {} rundir resultsdir [-r]".format(sys.argv[0]))
        exit(1)

    rundir = sys.argv[1]
    resultsdir = sys.argv[2]

    if len(sys.argv) > 3 and sys.argv[3].startswith("-r"):
        run_sweep(
                testlist="v60_all_apps",
                permutations=None,
                resultsDir=rundir,
                simbin="$Q6SIM",
                timing=False,
                saveAll=True,
                local=True)

    testData = dict(collect_data_file(rundir, "regfile_metrics.json", parse_metrics_file))

    for testMetrics in testData.values():
        for threadMetrics in testMetrics["threads"]:
            convert_test_to_rates(threadMetrics) 

    avg = test_map(tests_reduce(testData.values()), lambda v: v/len(testData))

    json.dump(avg, sys.stdout)
    print()

if __name__ == "__main__":
    main()
