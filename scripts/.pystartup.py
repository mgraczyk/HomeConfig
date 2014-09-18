import os
import readline
import atexit

histfile = os.path.join(os.path.expanduser("~"), ".pyhistory")
try:
        readline.read_history_file(histfile)
except IOError:
        pass

atexit.register(readline.write_history_file, histfile)
del os, histfile, atexit, readline
