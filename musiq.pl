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
#   --seed or -s <32bit interger> -- assign a seed to this simulation, omit this
#                               option to generate random seed
#   --uvmv or -u <UVM_VERBOSITY> -- set UVM_VERBOSITY for this simulation
#   --ts or -t <timescale> -- set timescale, syntax is the same as in Verilog
#   --version or -v -- show this script's version
#   --help or -h -- show this helpful message
use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;

our $version_number = '0.3';

# switch to show help message
my $help = '';
# switch to show version number of this Perl script
my $version = '';
# switch for compilation only
my $compile = '';
# switch for simulation only, and testcase for simulation
my $simulation = '';
# switch to compile then simulate, and testcase for simulation
my $com_n_sim = '';
# switch to supply own seed for simulation
my $seed = '';
# switch to set UVM verbosity
my $uvm_verbosity = '';
# switch to set verilog timescale for simulation
my $timescale = '';

GetOptions ("help" => \$help,
            "version" => \$version,
            "compile" => \$compile,
            "sim=s" => \$simulation,
            "run=s" => \$com_n_sim,
            "seed=i" => \$seed,
            "uvmv=s" => \$uvm_verbosity,
            "ts=s" => \$timescale
            )
or die("Error in command line arguments\n");

if($version){
    &show_version;
    exit 0;
}

if($help){
    print("gaeg\n");
    exit 0;
}

if($compile){
    system("make work");
    my $compile_cmd = "make build ".&pass_compile_args;
    system($compile_cmd);
    print("===================================\n");
    print("Compilation results in comp_rtl.log and comp_env.log\n");
    exit 0;
}

if($simulation){
    my $simulation_cmd = "make sim ".&pass_simulation_args;
    system($simulation_cmd);
    exit 0;
}

if($com_n_sim){
    my $run_cmd = "make all ".&pass_compile_args.&pass_simulation_args;
    system($run_cmd);
    exit 0;
}

sub pass_compile_args{
    my $compile_args = '';
    if ($timescale){
        $compile_args .= "TIMESCALE=$timescale ";
    }
    return $compile_args;
}

sub pass_simulation_args{
    my $simulation_args= '';
    $simulation_args .= "TESTNAME=$simulation ";
    if ($seed){
        $simulation_args .= "SEED=$seed ";
    }
    if ($uvm_verbosity){
        $simulation_args .= "UVM_VERBOSITY=$uvm_verbosity ";
    }
    return $simulation_args;
}

sub show_version{
    print("This is Perl script musiq, short for 
        Makefile Utility for Simulation Implementation with Questasim\n");
    print("Version $version_number\n");
    print("Made at 2024 September 30th, by Penghua Chen\n");
}
