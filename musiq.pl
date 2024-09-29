#! /usr/bin/perl
# Makefile Utility for Simulation Implementation with Questasim,
# short for musiq, pronounced as music.

# usage: 
#   musiq.pl <sim|com|run> <UVM_TESTNAME> <options>
#
#   musiq.pl sim <UVM_TESTNAME> -- to run testcase with name of <UVM_TESTNAME> 
#   musiq.pl com -- to compile both RTL and verification code
#   musiq.pl run <UVM_TESTNAME> -- to compile code then run testcase
#
#   <options>:
#   -seed <32bit interger> -- assign a seed to this simulation, omit this
#                               option to generate random seed
#   -uvmv <UVM_VERBOSITY> -- set UVM_VERBOSITY for this simulation
#   -ts <timescale> -- set timescale, syntax is the same as in Verilog
