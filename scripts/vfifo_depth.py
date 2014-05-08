#! /usr/bin/python3

import matplotlib
matplotlib.use('WebAgg')
import matplotlib.pyplot as plt

import sys
import numpy as np
from scipy import optimize
from scipy import signal

from itertools import chain

from collect_stats import collect_stats
from run_sweep import run_sweep
from Sweep import Sweep

def fit_func(x, *p):
    return p[0] + p[1]*x**p[2]

def fit_data(sweep):
    cycles = sweep.slice_stat("COPROC_LOAD_STALL_CYCLES")

    indepVar = "mmvec_vfifo_depth"
    testIdx = cycles.domain_names.index("test")
    x = cycles.domain_values[cycles.domain_names.index(indepVar)]

    center = 10
    start = len(x) - 2*center
    weights = signal.gaussian(2*len(x) - 2*center, 25)[start:]

    fitParams = []
    for testName, testData in zip(sweep.domain_values[testIdx], cycles.data):
        y = testData
        yMin, yMax = np.amin(y), np.amax(y)
        yRange = yMax - yMin

        if yRange < 1000:
            print("Test {} approximately constant. Skipping...".format(testName))
            # don't bother analyzing constant functions
            continue

        pGuess = (yMin, yRange, -1.0)
        popt, pconv = optimize.curve_fit(
                fit_func,
                x, y,
                pGuess,
                weights,
                maxfev=40000)

        xMin, xMax = min(x), max(x)

        xFit = range(xMin, xMax)
        yFit = fit_func(xFit, *popt)

        xMin = min(xMin, 0)
        yMin, yMax = min(chain((yMin,), yFit)), max(chain((yMax,), yFit))

        if yMin == yMax:
            yMin -= 1
            yMax += 1

        err = np.average((weights*(y - fit_func(x, *popt))/popt[1])**2)
        fitParams.append((popt, err))

        plt.plot(x, y, "ro-", xFit, yFit, "b-")
        plt.axis([xMin, xMax, yMin, yMax])
        plt.title(cycles._title_from_sliced())
        plt.xlabel(indepVar)
        plt.savefig(testName + '.png')
        plt.close()

    print("Regression to fit a + bx^c")
    print("Name, a, b, c, error = (w(x)*(y(x) - yfit(x))/b)^2")
    list(map(print, zip(sweep.domain_values[testIdx], fitParams)))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("USAGE: {} results_path [-r]".format(sys.argv[0]))
        exit(1)

    indep = ["mmvec_vfifo_depth"]

    if "-r" in sys.argv:
        run_sweep("v60_h2_short", ((indep[0], chain(range(1,25), (32, 48, 64, 96, 128))),), sys.argv[1])

    sweep = collect_stats(sys.argv[1], indep)

    with open("data.json", "w") as f:
        sweep.ToFile(f)

    fit_data(sweep)
    print()
