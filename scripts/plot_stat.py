#!/usr/bin/python3

from Sweep import Sweep

import sys

def example(path, test, stat):
    with open(path, "r") as f:
        sweep = Sweep.from_json_file(f)

    sweep.slice_test(test).slice_stat(stat).plot()

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("USAGE: {} data_file test_name stat_name".format(sys.argv[0]))
        exit(1)
    else:
        example(*sys.argv[1:4])
