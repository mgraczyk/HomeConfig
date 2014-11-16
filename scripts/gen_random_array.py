#!/usr/bin/env python3

import sys
import argparse

def generate_elements_numpy(length, valMin, valMax):
    return np.random.randint(int(valMin), int(valMax), int(length))

def generate_elements_std(length, valMin, valMax):
    return [int(valMax*random.random()) + valMin for _ in range(length)]

def write_array_text(fp, name, dataType, data):
    fp.write("{} {}[] = {{ ".format(dataType, name))
    fp.write(", ".join(map(str, data)))
    fp.write(" };\n")

def c_style_int(value):
    return int(value, 0)

def get_arg_parser():
    argParser = argparse.ArgumentParser(description='Generates an array of random data',
            formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    argParser.add_argument('-l', '--length', dest='length', type=c_style_int, default=1, help="Number of array elements.")

    argParser.add_argument('-t', '--type', dest='data_type', default="unsigned char",
            help="Array element type.")

    argParser.add_argument('-n', '--name', dest='array_name', default="data",
            help="Array element type.")

    argParser.add_argument('-m', '--min', dest='val_min', type=c_style_int, default=0, help="Minimum data value.")
    argParser.add_argument('-M', '--max', dest='val_max', type=c_style_int, default=256, help="Maximum data value.")

    return argParser

def main():
    args = get_arg_parser().parse_args()
    if args.val_min > args.val_max:
        sys.stderr.write("ERROR: min must be less than or equal to max\n")
        exit(1)

    data = generate_elements(args.length, args.val_min, args.val_max)
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
