#! /usr/bin/python3

import matplotlib
from matplotlib import markers
from matplotlib.ticker import MultipleLocator, FormatStrFormatter, IndexFormatter

matplotlib.use('WebAgg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

import os
import sys
import numpy as np

from collect_stats import collect_stats
from run_sweep import run_sweep

from Sweep import Sweep

def create_3d_plot(sweep, stat, normStat):
    norm = sweep.slice_stat(normStat).data
    sweep = sweep.slice_stat(stat)

    fig = plt.figure()
    ax = plt.subplot(111)

    fig.set_size_inches(12,9)

    testIdx = sweep.domain_names.index("test")
    x = np.array(range(len(sweep.domain_values[testIdx])))

    markers = "os^+*"

    data = sweep.data / (norm+1)
    order = data.max(1).argsort()
    data = np.rollaxis(data[order], 1)
    testNames = sweep.domain_values[testIdx][order]
    for i, rangeData in enumerate(data):
        ax.plot(x, rangeData,
                marker=markers[i],
                linestyle='-', label="{} pkt".format(i))
   
    plt.axis([np.amin(x), np.amax(x), np.amin(data), np.amax(data)])
    ax.set_xticks(x)
    ax.set_xticklabels(testNames, rotation=90)
    ax.xaxis.set_minor_locator(MultipleLocator())

    box = ax.get_position()
    ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])

    # Put a legend to the right of the current axis
    ax.legend(loc='center left', bbox_to_anchor=(1, 0.5))

    ax.set_title(stat)
    ax.yaxis.set_label_text("{}/{}".format(stat, normStat))

    # Don't clip labels
    plt.subplots_adjust(bottom=0.4, right=0.8)
    plt.savefig(stat + '.png', dpi=100)
    plt.close()


def create_plots(sweep):
    pairs = (("HVX_REGISTER_RAR_SUPPRESSION", "HVX_REGISTER_READS"),
             ("HVX_REGISTER_RAW_SUPPRESSION", "HVX_REGISTER_READS"),
             ("HVX_REGISTER_WAR_SUPPRESSION", "HVX_REGISTER_WRITES"),
             ("HVX_REGISTER_WAW_SUPPRESSION", "HVX_REGISTER_WRITES"))

    for pair in pairs:
        create_3d_plot(sweep, *pair)
        for p in pair:
            sweep.slice_stat(p).ToCsvPath(p + ".csv")

    testIdx = sweep.domain_names.index("test")
    with open("testnames.csv", "w") as tF:
        for name in sweep.domain_values[testIdx]:
            tF.write(name)
            tF.write("\n")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("USAGE: {} results_path [-r]".format(sys.argv[0]))
        exit(1)

    if "-r" in sys.argv:
        run_sweep("v60_h2_short", (("mmvec_reg_suppression_range", (0,1,2,3,4)),("mmvec_reg_suppression_type", ("V",))), sys.argv[1])

    indep = ["mmvec_reg_suppression_range", "mmvec_reg_suppression_type"]
    sweep = collect_stats(sys.argv[1], indep)

    sweep = sweep.slice_dimension(indep[1], sweep.domain_values[sweep.domain_names.index(indep[1])][0])

    create_plots(sweep)
    sweep.ToFile(sys.stdout)
    print()
