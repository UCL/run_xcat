# Copyright University College London 2019
# Author: Alexander Whitehead, Institute of Nuclear Medicine, UCL
# For internal research only.


import sys
from scipy import stats


def get_prefix(path):
    prefix_array = path.split('/')
    prefix = prefix_array[-1]

    return prefix


def load_array(path, prefix):
    signal_array = []

    with open(path + prefix, 'r') as file:
        for line in file:
            line = line.rstrip()

            signal_array.append(float(line))

    return signal_array


def write_array(path, prefix, array):
    with open(path + prefix + "_nifty_reg_resp", 'w') as file:
        for item in array:
            file.write("%s\n" % item)


def process_signals(path):
    prefix = get_prefix(path)

    path_array = path.split(prefix)
    path = path_array[0]

    signal_array = load_array(path, prefix)

    signal_array = stats.zscore(signal_array)

    write_array(path, prefix, signal_array)


process_signals(sys.argv[1])
