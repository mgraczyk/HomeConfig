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

def normalize_tests(metrics):
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

def test_reduce(test, op=sum):
    result = {
            "conflicts": [
                dict_reduce(ds, op)
                for ds in zip(*map(itemgetter("conflicts"), test))
            ],
            "reads": op(map(itemgetter("reads"), test)),
            "writes": op(map(itemgetter("writes"), test))
        }
    return result

def tests_reduce(tests, op=sum):
    result = {
        "threads" : [
            test_reduce(ts, op)
            for ts in zip(*map(itemgetter("threads"), tests))
        ]
    }
    return result

def thread_map(thread, op):
    return {
            "conflicts": [
                { k: op(v) for k,v in conflict.items() }
                for conflict in thread["conflicts"]
            ],
            "reads": op(thread["reads"]),
            "writes": op(thread["writes"])
        }


def test_map(test, op):
    result = {
        "threads" : [
            thread_map(thread, op)
            for thread in test["threads"] ]
    }
    return result

def main():
    if len(sys.argv) < 2:
        print("USAGE {} rundir [-r]".format(sys.argv[0]))
        exit(1)

    rundir = sys.argv[1]

    if len(sys.argv) > 2 and sys.argv[2].startswith("-r"):
        run_sweep(
                testlist="v60_all_apps",
                permutations=None,
                resultsDir=rundir,
                simbin="$Q6SIM",
                timing=False,
                saveAll=True,
                local=True)

    testData = dict(collect_data_file(rundir, "regfile_metrics.json", parse_metrics_file))

    threadTestCounts = map(sum, zip(
        *((bool(metrics["reads"] and metrics["writes"])
                for metrics in testMetrics["threads"])
            for testMetrics in testData.values())))

    for testMetrics in testData.values():
        for threadMetrics in testMetrics["threads"]:
            normalize_tests(threadMetrics) 

    numTests = len(testData)
    reduced = tests_reduce(testData.values())
    avg = {
        "threads": [thread_map(thread, lambda v: v/tc)
        for tc, thread in zip(threadTestCounts, reduced["threads"])] 
    }

    json.dump(avg, sys.stdout)
    print()

if __name__ == "__main__":
    main()
