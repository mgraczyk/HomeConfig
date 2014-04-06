#!/usr/bin/python3

import pmu_stats

import sys
import os
import json
import numpy as np

from collections import defaultdict
from collections import OrderedDict
from collections import namedtuple
from functools import reduce
from itertools import chain
from itertools import repeat
from itertools import starmap
from operator import getitem
from operator import itemgetter

import pprint as pp

def get_immediate_subdirectories(dr):
    return (name for name in os.listdir(dr)
            if os.path.isdir(os.path.join(dr, name)))

class Autolist(list):
    def __init__(self, defaultFactory, filler=None):
        super().__init__(self)

        self._filler = filler
        self._defaultFactory = defaultFactory
        self._isOn = lambda: Control

    def __setitem__(self, key, value):
        try:
            if key >= len(self):
                self.extend([self._filler]*(key - len(self) + 1))
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
    return Autolist(recursive_autolist, None)

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

    return {
        "domain_names": domainNames,
        "domain_values": domainValues,
        "data": tree
    }

def sort_data(keys, data):
    """ Sorts a multidimensional array based on a list of keys.
        The sort order of dimension i of data is determined by keys[i].
    """

    sortOrders = tuple(map(np.argsort, map(np.array, keys)))
    dArr = np.array(data)
    colon = slice(None)
    dim = len(sortOrders)
    for i, indices in enumerate(sortOrders):
        indexer = [colon]*i + [indices,Ellipsis]
        dArr = dArr[indexer]

    keysort = lambda l,i: tuple(l[p] for p in i)
    sortedKeys = tuple(map(keysort, keys, sortOrders))

    return sortedKeys, dArr.tolist()

def collect_stats(path):
    passData = []
    for subdir in get_immediate_subdirectories(path):
        try: 
            passData.append((subdir, get_stats(os.path.join(path, subdir))))
        except Exception as e:
            # Warn but ignore
            print("Couldn't get data for {}: {}".format(subdir, e))

    # Since we read the data in an unspecified order, we need to
    # sort each dimension to get a result that's easier to use
    sweep = parse_values_from_results(passData, ["mmvec_vfifo_depth"])
    sweep["domain_values"], sweep["data"] = sort_data(sweep["domain_values"], sweep["data"])

    return sweep

if __name__ == "__main__":
    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        path = os.getcwd()

    json.dump(
            collect_stats(path), sys.stdout,
            separators=(',',':'),
            check_circular=False,
            allow_nan=False)
    print()
