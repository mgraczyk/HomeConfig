#!/usr/bin/env python

import argparse
import numpy as np
import soundfile
import sys

def get_arg_parser():
  parser = argparse.ArgumentParser(
      formatter_class=argparse.ArgumentDefaultsHelpFormatter)

  parser.add_argument(
      "ref_path", help="The path to the reference audio file.")

  parser.add_argument(
      "test_path", help="The path to the reference audio file.")

  return parser

def compute_mse(ref, test):
  return np.mean(np.square(ref - test)) / np.mean(np.square(ref))

def main(argv):
  parser = get_arg_parser()
  opts = parser.parse_args(argv[1:])

  with soundfile.SoundFile(opts.ref_path) as ref_file:
    with soundfile.SoundFile(opts.test_path) as test_file:
      mse = compute_mse(ref_file.read(), test_file.read())

  print(mse)

if __name__ == "__main__":
  main(sys.argv)
