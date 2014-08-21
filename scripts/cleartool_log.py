#!/pkg/qct/software/python/3.3.2c/bin/python

import re
import sys
import subprocess

from subprocess import CalledProcessError
from subprocess import TimeoutExpired

from collections import namedtuple

diffRegex = re.compile('(?P<time>[^\s]*)\s*(?P<committer>\w*)\s*create version\s*"(?P<element>.*?)(?P<version>\d*)"')

ClearCaseLog = namedtuple("ClearCaseLog", ["time", "committer", "element", "version"])

def parseCCHist(cchistPath):
    logs = []
    with open(cchistPath, "r") as f:
        for line in f:
            match = diffRegex.match(line)
            if match:
                groups = match.groupdict()
                logs.append(ClearCaseLog(**groups))

    return logs

def printLog(log):
    firstElement = log.element + log.version

    print("commit:")
    print("Author: {}".format(log.committer))
    print("Date: {}".format(log.time))
    print()
    proc = subprocess.Popen(
            ["cleartool", "diff", "-serial_format", "-pre", firstElement],
            stdout=subprocess.PIPE)
    try:
        output,err = proc.communicate()
        print(output.decode())

        if err:
            print("WARNING: cleartool diff error:")
            print(err.decode())
    except TimeoutExpired as e:
        print("WARNING: cleartool diff timed out")
    print()
    print("="*80)

def printLogs(cchistName):
    logs = parseCCHist(cchistName)
    for log in logs:
        printLog(log) 

def main():
    if len(sys.argv) < 2:
        print("USAGE: {} cleartool_history".format(sys.argv[0]))

    cchistName = sys.argv[1]

    printLogs(cchistName)

if __name__ == "__main__":
    main()
