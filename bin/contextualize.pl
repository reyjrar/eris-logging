#!/usr/bin/env perl
# PODNAME: contextualize.pl
# ABSTRACT: Utility for testing the logging contextualizer
use strict;
use warnings;

use CLI::Helpers qw(:output);
use Data::Printer;
use FindBin;
use Getopt::Long::Descriptive;
use Path::Tiny;
use Time::HiRes qw(gettimeofday tv_interval);
use eris::log::contextualizer;

#------------------------------------------------------------------------#
# Path Setup
my $path_base = path("$FindBin::Bin")->parent;

#------------------------------------------------------------------------#
# Argument Parsing
my ($opt,$usage) = describe_options(
    "%c %o ",
    [],
    [ 'config|c:s', "eris config file", {
        default => $path_base->child('eris.yml')->realpath->canonpath,
        callbacks => { exists => sub { -f shift } }
    }],
);

#------------------------------------------------------------------------#
# Main
my $ctxr = eris::log::contextualizer->new(
    config => $opt->config,
);

while(<>) {
    chomp;
    verbose({color=>'cyan'}, $_);
    my $t0 = [gettimeofday];
    my $l = $ctxr->parse($_);
    my $tdiff = tv_interval($t0);
    p($l);
    output({color=>'cyan'}, sprintf "Took %0.6fs total.", $tdiff);
}
