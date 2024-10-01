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

our $version_number = 'v0.5';

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
            "com" => \$compile,
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
    pod2usage(-verbose => 2);
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
    my $simulation_cmd = "make sim ".&pass_simulation_args($simulation);
    system($simulation_cmd);
    exit 0;
}

if($com_n_sim){
    my $run_cmd = "make all ".&pass_compile_args.
                    &pass_simulation_args($com_n_sim);
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
    $simulation_args .= "TESTNAME=$_[0]";
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

__END__
=head1 NAME

musiq.pl - a Perl script to help user compile and run simulation on Questasim

=head1 SYNOPSIS

musiq.pl [--com|--sim|--run] [options]

 Options:
   --help|-h            brief help message
   --version|-v         show script's version number and author
   --com|-c         compile this verification environment and RTL code
   --sim| <testcase>  run simulation with testcase of name <testcase>
   --run|-r <testcase>  compile then simulate with testcase of name <testcase>
   --seed <integer> supply a user defined seed for current simulation
   --uvmv|-u <UVM verbosity> set UVM verbosity of simulation to <UVM verbosity>
   --ts|-t <timescale>   set timescale of both RTL and verification to <timescale>

=head1 EXAMPLES

=head2 to compile

musiq.pl --com

=head2 to run simulation with testcase of name test_example

musiq.pl --sim test_example

=head2 to compile then run simulation with testcase of name test_example

musiq.pl --run test_example

=head2 to run simulation with a chosen seed 1234567890

musiq.pl --sim test_example --seed 1234567890

=head2 to run simulation with a different UVM verbosity other than UVM_MEDIUM

musiq.pl --sim test_example --uvmv UVM_LOW

=head2 to change timescale from default 1ns/100ps to 1ns/1ps

musiq.pl --com --ts 1ns/1ps


=head1 OPTIONS

=over 4

=item B<--help|-h>

Print a brief help message and exits.

=item B<--version|-v>

show script's version number and author and exits

=item B<--com|-c>

compile files listed in env_filelist.f and RTL/rtl_filelist.f and exits. 
comilation results are generated as comp_env.log and comp_rtl.log.

=item B<--sim> <testcase>

only run simulation with testcase of name <testcase>, simulation results are 
stored in an automatically created directory with name includes current time when
starting simulation, simulation seed and testcase name.

=item B<--run|-r> <testcase>

a combination of option --com and --sim.

=item B<--seed> <integer>

user supplies a seed for current simulation.
Used in combination with option --run and --sim. <integer> is a 32bit of integer
number supplied by user. If this option is not used, seed is randomly generated
for every simulation.

=item B<--uvmv|-u> <UVM verbosity>

user defines a UVM verbosity for current simulation, recognized value is
UVM_LOW, UVM_MEDIUM, UVM_HIGH, other strings may work but not guranteed. Default 
UVM verbosity is UVM_MEDIUM.
Used in combination with option --run and --sim.

=item B<--ts|-t> <timescale>

user defines a timescale for both RTL code and verification environment. Default
timescale is 1ns/100ps.
Used in combination with option --com and --run.

=back

=head1 DESCRIPTION

B<This program> will be used to drive Makefile which in turn to drive Questasim,
 user can supply seed, specify which testcase to simulate, whether to only compile
 or only simulation or compile and simulate, 

=cut
