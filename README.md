# run_xcat

To run xcat, obviously first have it installed, then have a config file for the output you desire. Then run the shell script in the run directory.

The sctipt will run on any operating system that has bash. If no arguments are given the script assumes that xcat, the config file and the output directory are in the current directory. -t will output one header, -o and an integer will output the integer number of headers. the first argument should be the path to xcat, the second argument should be the path to the config file, the third argument should be the path to the output directory and the prifix for the header files. The next two arguments should be the position and orientation of the patient.
