#!/usr/bin/python3

import matplotlib
matplotlib.use('WebAgg')
import matplotlib.pyplot as plt

import sys
import json

import numpy as np

from collections import defaultdict
from operator import itemgetter

class Sweep(object):
    def __init__(self, domainNames, domainValues, data, sliced=tuple()):
       self._domainNames = domainNames
       self._domainValues = domainValues
       self._data = np.array(data, np.float64)
       self._sliced = sliced

    @classmethod
    def FromJson(cls, json):
        try:
            return cls(json["domain_names"], json["domain_values"], json["data"])
        except KeyError as e:
            raise ValueError("Json data set is missing something.") from e
        except Exception as e:
            raise ValueError("Bad data in the data set.") from e

    @property
    def domain_names(self):
        return self._domainNames

    @property
    def domain_values(self):
        return self._domainValues

    @property
    def data(self):
        return self._data

    def slice_dimension(self, dimension, name):
        try:
            dimIdx = self.domain_names.index(dimension)
        except ValueError as e:
            raise ValueError("{} is not in the data set's domain.".format(dimension)) from e

        positions = self.domain_values[dimIdx]

        try:
            testPos = positions.index(name)
        except ValueError as e:
            raise ValueError("{} '{}' is not in the data set".format(dimension, name))
       
        newDNames, newDValues = zip(*(v for i, v in
            enumerate(zip(self.domain_names, self.domain_values))
            if i != dimIdx))

        indexer = [slice(None)]*dimIdx + [testPos,Ellipsis]
        sliced = self._sliced + ((dimension, name),)
        return Sweep(newDNames, newDValues, self.data[indexer], sliced)

    def slice_test(self, test):
        return self.slice_dimension("test", test)

    def slice_stat(self, stat):
        return self.slice_dimension("stat", stat)

    def plot(self):
        x = self.domain_values[0]
        y = self.data
       
        xMin, xMax = min(0, min(x)), max(x)
        yMin, yMax = min(y), max(y)

        if yMin == yMax:
            yMin -= 1
            yMax += 1

        plt.plot(x, y)
        plt.axis([xMin, xMax, yMin, yMax])
        plt.title(self._sliced)
        plt.savefig('figure.png')
        #plt.show()

def example(path, test, stat):
    with open(path, "r") as f:
        rawData = json.load(f)

    sweep = Sweep.FromJson(rawData)
    sweep.slice_test(test).slice_stat(stat).plot()

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("USAGE: {} data_file test_name stat_name".format(sys.argv[0]))
        exit(1)
    else:
        example(*sys.argv[1:4])
