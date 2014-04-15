#!/usr/bin/python3

import pmu_stats

import sys
import os

from collections import defaultdict
from collections import OrderedDict
from collections import namedtuple
from functools import reduce
from itertools import chain
from itertools import repeat
from itertools import starmap
from operator import getitem
from operator import itemgetter

from Sweep import Sweep

import pprint as pp

def get_immediate_subdirectories(dr):
    return (name for name in os.listdir(dr)
            if os.path.isdir(os.path.join(dr, name)))

class Autolist(list):
    def __init__(self, defaultFactory):
        super().__init__(self)

        self._defaultFactory = defaultFactory
        self._isOn = lambda: Control

    def __setitem__(self, key, value):
        try:
            if key >= len(self):
                self.extend(self._defaultFactory() for i in range(key - len(self) + 1))
        except TypeError as e:
            pass

        super().__setitem__(key, value)

    def __getitem__(self, key):
        try:
            if key >= len(self):
                self[key] = self._defaultFactory()
        except TypeError as e:
            pass

        return super().__getitem__(key)

def recursive_autolist():
    return Autolist(recursive_autolist)

class IndexDict(OrderedDict):
    def __missing__(self, key):
        super().__setitem__(key, len(self))
        return len(self) - 1

def get_stats(path):
    PmuStatFileName = "pmu_stats.txt"

    try: 
        return pmu_stats.parse_pmu_file(os.path.join(path, PmuStatFileName))
    except Exception as eOuter:
        # It could be test subdirectory if the test "failed"
        try:
            return pmu_stats.parse_pmu_file(os.path.join(path, "test", PmuStatFileName))
        except Exception as eInner:
            # Show the first error since it will be more meaningful
            raise eInner from eOuter

def parse_passname(passname, dimensions):
    values = []
    rem = passname
    for d in dimensions:
        pos = rem.find(d)
        if pos < 0:
            raise ValueError("Passname {} does not contain dimension {}".format(passname, d))
        if rem[pos-1] != "_":
            raise ValueError("Bad passname {}".format(passname))

        # The value better not have an underscore in it...
        nameEnd = pos + len(d)
        valueEnd = rem.find("_", nameEnd)
        if valueEnd < 0:
            valueEnd = len(rem)
        values.append(rem[nameEnd:valueEnd])

        # Remove leading underscore
        rem = rem[0:pos-1] + rem[valueEnd:]

    return rem, values

def normalize_type(values):
    typePreferences = (lambda x: int(x,0), float)
    for t in typePreferences:
        try:
            return tuple(map(t, values))
        except (SyntaxError, ValueError):
            pass

    return tuple(values)

def parse_values_from_results(passData, dimensions):
    # Two extra for stats and test names
    tree = recursive_autolist()
    domainIdxs = [IndexDict() for i in range(len(dimensions) + 2)]

    # Read all the data.
    # We do this in a roundabout way since we don't know in advance
    # What all of the data points will be.
    for passName, values in passData:
        test, domain = parse_passname(passName, dimensions)
        for stat,value in values.items():
            indices = list(map(getitem, domainIdxs, chain((test, stat), domain)))
            leaf = reduce(getitem, indices[:-1], tree)
            leaf[indices[-1]] = value


    # Return the domain as a numeric type if possible
    domainNames = tuple(chain(("test", "stat"), dimensions))
    domainValues = tuple(map(normalize_type, [d.keys() for d in domainIdxs]))

    return Sweep(domainNames, domainValues, tree)

def collect_stats(path, dimensions):
    passData = []
    for subdir in get_immediate_subdirectories(path):
        try: 
            passData.append((subdir, get_stats(os.path.join(path, subdir))))
        except Exception as e:
            # Warn but ignore
            print("Couldn't get data for {}: {}".format(subdir, e))

    sweep = parse_values_from_results(passData, dimensions)

    return sweep

if __name__ == "__main__":
    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        path = os.getcwd()

    collect_stats(path, sys.argv[2:]).ToFile(sys.stdout)
    print()
