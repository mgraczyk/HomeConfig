#!/usr/bin/python3

import matplotlib
matplotlib.use('WebAgg')
import matplotlib.pyplot as plt

import json
import numpy as np

from collections import defaultdict
from operator import itemgetter
from itertools import starmap

class Sweep(object):
    def __init__(self, domainNames, domainValues, data, sliced=tuple(), sort=True):
       self._domainNames = domainNames
       self._domainValues = list(map(np.array, domainValues))
       self._data = np.array(data, dtype=np.float64)
       self._sliced = sliced

       if sort:
           self._sort_data()

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
            dimIdx = self._domainNames.index(dimension)
        except ValueError as e:
            raise ValueError("{} is not in the data set's domain.".format(dimension)) from e

        positions = self._domainValues[dimIdx]

        try:
            pos = positions.searchsorted(name)
        except ValueError as e:
            raise ValueError("{} '{}' is not in the data set".format(dimension, name))
       
        newDNames, newDValues = zip(*(v for i, v in
            enumerate(zip(self._domainNames, self._domainValues))
            if i != dimIdx))

        indexer = [slice(None)]*dimIdx + [pos,Ellipsis]
        sliced = self._sliced + ((dimension, name),)
        return Sweep(newDNames, newDValues, self.data[indexer], sliced, False)

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
        plt.title(self._title_from_sliced())
        plt.xlabel(self._domainNames[0])
        plt.savefig('figure.png')
        #plt.show()

    def values_for_domain(self, dimension):
        try:
            dimIdx = self._domainNames.index(dimension)
        except ValueError as e:
            raise ValueError("{} is not in the data set's domain.".format(dimension)) from e

        return iter(self._domainValues[dimIdx])

    def _title_from_sliced(self):
        return "\n".join(starmap("{} = {}".format, self._sliced))

    def _sort_data(self):
        """ Sorts a multidimensional array based on a list of keys.
            The sort order of dimension i of data is determined by keys[i].
        """

        data = self._data
        keys = self._domainValues
        sortOrders = map(np.argsort, keys)

        colon = slice(None)
        dim = len(keys)
        rest = [Ellipsis] if dim > 1 else []
        for i, indices in enumerate(sortOrders):
            indexer = [colon]*i + [indices] + rest
            data = data[indexer]
            keys[i] = keys[i][indices]

        self._domainValues = keys
        self._data = data

    def ToCsv(self, f, delimiter=",", fmt="%10.5f"):
        header = self.domain_names[1] + "\n" + delimiter.join(map(str, self.domain_values[1]))
        np.savetxt(f, self.data, fmt=fmt, delimiter=delimiter, header=header)

    def ToCsvPath(self, path, *args, **kwargs):
        with open(path, "wb") as f:
            self.ToCsv(f, *args, **kwargs)

    def ToFile(self, f):
        selfDict = {
            "domain_names": self.domain_names,
            "domain_values": [a.tolist() for a in self.domain_values],
            "data": self.data.tolist()
        }

        json.dump(
                selfDict, f,
                separators=(',',':'),
                check_circular=False,
                allow_nan=False)

    @classmethod
    def FromFile(cls, f):
       return cls.FromJs(json.load(f))

    @classmethod
    def FromJs(cls, js):
        try:
            return cls(js["domain_names"], js["domain_values"], js["data"])
        except KeyError as e:
            raise ValueError("Json data set is missing something.") from e
        except Exception as e:
            raise ValueError("Bad data in the data set.") from e
