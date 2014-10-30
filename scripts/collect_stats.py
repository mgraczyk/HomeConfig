#!/usr/bin/python3

import sys
import os
import operator

from os.path import isfile, isdir, islink

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

StateFileName = "stats.txt"

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

    @classmethod
    def FromIter(cls, other, defaultFactory):
        ret = Autolist(defaultFactory)
        ret.extend(other)
        return ret

def recursive_autolist():
    return Autolist(recursive_autolist)

class IndexDict(OrderedDict):
    def __missing__(self, key):
        self.__setitem__(key, len(self))
        return len(self) - 1

def parse_func(rootdir, fullPath):
    return {}

def get_datum(path, rootdir, target, processFunc):
    fullPath = os.path.join(path, target)
    if isfile(fullPath):
        return processFunc(rootdir, fullPath)
    else:
        for subdir in os.listdir(path):
            subPath = os.path.join(path, subdir)
            if isdir(subPath) and not (subdir.startswith(".") or islink(subdir)):
                stats = get_datum(subPath, rootdir, target, processFunc)
                if stats:
                    return stats
    return None

def find_data(root, target, processFunc):
    datum = get_datum(root, root, target, processFunc)
    if not datum:
        raise FileNotFoundError("Couldn't find data file in {}.".format(root))
    return datum

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

def deep_replace(tree, pred, newVal):
    try:
        replacements = tuple(i for i, elem in enumerate(tree) if deep_replace(elem, pred, newVal)) 
        for i in replacements:
            tree[i] = newVal
    except TypeError:
        # Don't replace noniterables that pass the predicate
        pass

    return pred(tree)

def smooth_tree(tree):
    for child in tree:
        try:
            smooth_tree(child)
        except Exception as e:
            pass

    childMax = max(map(len, tree))
    for child in tree:
        child.extend([Autolist(type(None))]*(childMax - len(child)))

def parse_values_from_results(passData, dimensions):
    # Two extra for stats and test names
    tree = recursive_autolist()
    domainIdxs = [IndexDict() for i in range(len(dimensions) + 2)]

    stats = []
    # Read all the data.
    # We do this in a roundabout way since we don't know in advance
    # What all of the data points will be.
    for passName, values in passData:
        test, domain = parse_passname(passName, dimensions)
        stats.append(values.keys())
        for stat,value in values.items():
            indices = list(map(getitem, domainIdxs, chain((test, stat), domain)))
            leaf = reduce(getitem, indices[:-1], tree)
            leaf[indices[-1]] = value

    smooth_tree(tree)
    deep_replace(tree, lambda x: issubclass(x.__class__, list) and not x, 0)

    # Return the domain as a numeric type if possible
    domainNames = tuple(chain(("test", "stat"), dimensions))
    domainValues = tuple(map(normalize_type, [d.keys() for d in domainIdxs]))

    return Sweep(domainNames, domainValues, tree)

def collect_data_file(path, target, processFunc):
    data = []
    for subdir in get_immediate_subdirectories(path):
        try: 
            datum = find_data(os.path.join(path, subdir), target, processFunc)
            data.append(datum)
        except Exception as e:
            # Warn but ignore
            print("Couldn't get data for {}: {}".format(subdir, e), file=sys.stderr)
    return data

def collect_stats(path, dimensions):
    passData = collect_data_file(path, StateFileName, parse_func)
    sweep = parse_values_from_results(passData, dimensions)
    return sweep

if __name__ == "__main__":
    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        path = os.getcwd()

    collect_stats(path, sys.argv[2:]).ToFile(sys.stdout)
    print()
