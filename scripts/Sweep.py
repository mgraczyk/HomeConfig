import matplotlib
matplotlib.use('WebAgg')
import matplotlib.pyplot as plt

import json
import numpy as np

from bisect import bisect_left
from collections import defaultdict
from itertools import starmap
from itertools import chain
from operator import itemgetter
from operator import getitem

def binary_search(a, x, lo=0, hi=None):
    hi = hi if hi is not None else len(a)
    pos = bisect_left(a,x,lo,hi)
    return pos if pos < hi and a[pos] is x else None

class Sweep(object):
  def __init__(self, domainNames, domainValues, data, sliced=(), sort=True):
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

    pos = binary_search(positions, name)
    if pos is None:
      raise ValueError("The data set does not contain any {} called '{}'.".format(dimension, name))
     
    newDNames, newDValues = zip(*(v for i, v in
      enumerate(zip(self._domainNames, self._domainValues))
      if i != dimIdx))

    indexer = [slice(None)]*dimIdx + [pos,Ellipsis]
    sliced = self._sliced + ((dimension, name),)
    return Sweep(newDNames, newDValues, self.data[indexer], sliced, False)

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

  def to_csv(self, f, delimiter=",", fmt="%10.5f"):
    header = self.domain_names[1] + "\n" + delimiter.join(map(str, self.domain_values[1]))
    np.savetxt(f, self.data, fmt=fmt, delimiter=delimiter, header=header)

  def to_csv_path(self, path, append=False, *args, **kwargs):
    mode = "wb" + ("+" if append else "")
    with open(path, mode) as f:
      self.to_csv(f, *args, **kwargs)

  def to_file(self, f):
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
  def from_structured(cls, structured, domain_names, default=float("nan")):
    """ 
      Convert structed hierarchical data into a Sweep.
    """
    domain_names = list(domain_names)
    domain_values = [None] * len(domain_names)
    empty_set = frozenset()
    empty_dict = {}

    data = []

    out_trees = [data]
    in_trees = [structured]
    for depth in range(len(domain_names)):
      is_last_iter = depth == len(domain_names) - 1
      filler = default if is_last_iter else None

      subkeys = empty_set.union(*map(set, map(_get_keys, in_trees)))

      # Move down a level
      # TODO(mgraczyk) Should we sort everything on the way down?
      domain_values[depth] = tuple(subkeys)
      in_trees = [
          _get_or_default(subtree, subkey, filler)
          for subtree in in_trees
          for subkey in subkeys]

      if not is_last_iter:
        out_trees = list(out_trees)
        for out_tree in out_trees:
          out_tree.extend([] for _ in subkeys)
        out_trees = chain.from_iterable(out_trees)
      else:
        count = len(subkeys)
        start = 0
        for out_tree in out_trees:
          end = start + count
          out_tree.extend(in_trees[start:end])
          start += count

    sweep = Sweep(domain_names, domain_values, data)
    return sweep

  @classmethod
  def from_json_file(cls, f):
     """ 
       Load a sweep from a 
     """
     return cls.from_json(json.load(f))

  @classmethod
  def from_json(cls, js):
    try:
      return cls(js["domain_names"], js["domain_values"], js["data"])
    except KeyError as e:
      raise ValueError("Json data set is missing something.") from e
    except Exception as e:
      raise ValueError("Bad data in the data set.") from e

def _get_keys(collection):
  if collection is None:
    return ()

  try:
    return collection.iterkeys()
  except AttributeError:
    pass

  try:
    return range(len(collection))
  except AttributeError:
    pass

  raise TypeError("Cannot get keys for " + repr(key_haver))

def _get_or_default(collection, key, default):
  if collection is not None:
    if isinstance(collection, dict):
      # Check for key in case of defaultdict or something similar
      if key in collection:
        return collection[key]
    else:
      try:
        return collection[key]
      except (TypeError, IndexError):
        pass

  return default
