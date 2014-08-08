#!/usr/bin/python3

import matplotlib
matplotlib.use('WebAgg')
import matplotlib.pyplot as plt

import sys
import re

from collections import defaultdict
from collections import namedtuple

import numpy as np

CommitEvent = namedtuple("CommitEvent", ["time","event", "pc","tid","id"])
PerfEvent = namedtuple("PerfEvent", ["time","event","cnt"])
BranchEvent = namedtuple("BranchEvent", ["time","event","tid","br_pc","next_pc","pred","actual"])

CommitSequence = namedtuple("CommitSequence", ["startTime","counts"])

def get_events(data, eventName):
    if not data[eventName]:
        return []

    minTime = data[eventName][0].time
    maxTime = max(events[-1].time for events in data.values())
    
    seq = np.zeros(maxTime + 1 - minTime)

    for commit in data[eventName]:
        seq[commit.time - minTime] = 1

    retval = CommitSequence(minTime, seq)
    return retval

def get_sequence(data, eventName):
    events = get_events(data, eventName)
    retval = CommitSequence(events.startTime, np.cumsum(events.counts))

    return retval

def get_commit_sequence(data):
    return get_sequence(data, "newpc")

def read_bad_line(line):
        raise ValueError("Read unexpected line:\n\t{}".format(line))

lineRegexs = [
    (re.compile("PKTID:time=(?P<time>\d+):(?P<event>newpc)=(?P<pc>[0-9a-fA-F]+):tid=(?P<tid>\d+):id=(?P<id>\d+).*"), CommitEvent),
    (re.compile("PERF:time=(?P<time>\d+):event=(?P<event>\d+):cnt=(?P<cnt>\d+)"), PerfEvent),
    (re.compile("(?<event>Branch) Info:Time=(?P<time>\d+):Tid=(?P<tid>\d+):Branch PC=(?P<br_pc>0x[0-9a-fA-F]+):Next PC=(?P<next_pc>0x[0-9a-fA-F]+)Predicted Direction=(?P<pred>[01]):Actual Direction=(P<actual>[01])"), BranchEvent),
    (re.compile("(.*)"), read_bad_line)
]

def _get_pktid_data_from_file(fp):
    # Lines look like this:
    #     PKTID:time=39356:newpc=960:tid=0:id=23640:pcycle=37918
    # or this:
    #     PERF:time=39358:event=59:cnt=1:pcycle=37920:id0:0:id3:0:

    events = defaultdict(list)
    for line in fp:
        for reg, eventType in lineRegexs:
            match = reg.match(line)
            if match:
                groups = match.groupdict()
                evt = eventType(**groups)
                events[evt.event].append(evt)
                break


    return events

def get_pktid_data(path):
    with open(path, "r") as fp:
        data = _get_pktid_data_from_file(fp)
    return data

def plot_sequence_spectrum(data, eventName, displayName): 
    seq = get_sequence(data, eventName)
    y = np.abs(-1j * np.fft.fft(seq.counts))
    x = np.array(range(len(y)))
    y = y*x

    xMin = 0
    xMax = len(y)/2
    ySlice = y[xMin:xMax]
    yMin, yMax = np.min(ySlice), np.max(ySlice)
    argmax = np.argmax(ySlice)

    if yMin == yMax:
        yMin -= 1
        yMax += 1

    plt.plot(x, y)
    plt.axis([xMin, xMax, yMin, yMax])
    plt.title("{}s Spectrum: Argmax = {}".format(displayName, argmax))
    plt.xlabel("\\omega")
    plt.ylabel("|FFT()|")
    plt.savefig("{}_spectrum.png".format(displayName))
    plt.close()

def plot_sequence(data, eventName, displayName):
    seq = get_sequence(data, eventName)
    y = seq.counts
    x = np.array(range(seq.startTime, seq.startTime + len(y)))
   
    xMin, xMax = x[0], x[-1]
    yMin, yMax = y[0], y[-1]
    avgSlope = (yMax-yMin)/(xMax-xMin)

    if yMin == yMax:
        yMin -= 1
        yMax += 1

    plt.plot(x, y)
    plt.axis([xMin, xMax, yMin, yMax])
    plt.title("{}s Times: dy/dt = {}".format(displayName, avgSlope))
    plt.xlabel("pcycles")
    plt.ylabel(displayName)
    plt.savefig("{}.png".format(displayName))
    plt.close()

def main():
    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        print("USAGE: {} pktid_log_path".format(sys.argv[0]))

    data = get_pktid_data(path)

    plot_sequence(data, "newpc", "Commit")
    plot_sequence(data, "245", "COPROC_L2_STORE_STALL_CYCLES")
    plot_sequence(data, "248", "COPROC_CORE_VFIFO_FULL_STALL")

if __name__ == "__main__":
    main()
