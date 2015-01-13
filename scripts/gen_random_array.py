#!/usr/bin/env python3

import argparse
import math
import sys

def generate_elements_numpy(length, val_min, val_max, float_type):
    if float_type:
      val_range = np.nextafter(val_max - val_min, np.inf)
      return val_range * np.random.rand(length) + val_min
    else:
      return np.random.randint(int(val_min), int(val_max), length)

def generate_elements_std(length, val_min, val_max, float_type):
    values = [
        (math.floor(val_max) + 1)*random.random() + math.ceil(val_min)
        for _ in range(length)]

    if not float_type:
        values = map(int, values)

    return values

def write_array_text(fp, name, dataType, data):
    fp.write("{} {}[] = {{ ".format(dataType, name))
    fp.write(", ".join(map(str, data)))
    fp.write(" };\n")

def c_style_int(value):
    return int(value, 0)

def get_arg_parser():
    argParser = argparse.ArgumentParser(
        description='Generates an array of random data',
formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    argParser.add_argument('-l', '--length', type=c_style_int, default=1,
        help="Number of array elements.")

    argParser.add_argument('-t', '--data_type', default="unsigned char",
        help="Array element type.")

    argParser.add_argument('-n', '--array_name', default="data",
        help="Name of array variable.")

    argParser.add_argument('-m', '--val_min', type=float, default=0,
        help="Minimum data value.")
    argParser.add_argument('-M', '--val_max', type=float, default=255,
        help="Maximum data value.")

    argParser.add_argument('-f', '--float_type', type=bool, default=None,
        help="Maximum data value.")

    return argParser

def main():
    args = get_arg_parser().parse_args()
    if args.val_min > args.val_max:
        sys.stderr.write("ERROR: min must be less than or equal to max\n")
        exit(1)

    if args.float_type is None:
      args.float_type = "float" in args.data_type or "double" in args.data_type

    data = generate_elements(
        args.length, args.val_min, args.val_max, args.float_type)

    write_array_text(sys.stdout, args.array_name, args.data_type, data)

try:
    import numpy as np
    generate_elements = generate_elements_numpy
except ImportError:
    # numpy unavailable
    import random
    np = None
    generate_elements = generate_elements_std

if __name__ == "__main__":
    main()
