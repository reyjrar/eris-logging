#!/usr/bin/env perl
# PODNAME: eris-context.pl
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
        callbacks => { exists => sub { -f shift } }
    }],
);

#------------------------------------------------------------------------#
# Main
my $ctxr = eris::log::contextualizer->new( $opt->config ? (config => $opt->config) : () );

foreach my $c ( @{ $ctxr->contexts->plugins } ) {
    verbose({color=>'magenta'}, sprintf "Loaded context: %s", $c->name);
}

while(<>) {
    chomp;
    verbose({color=>'cyan'}, $_);
    my $t0 = [gettimeofday];
    my $l = $ctxr->parse($_);
    my $tdiff = tv_interval($t0);
    p($l);
    output({color=>'cyan'}, sprintf "Took %0.6fs total.", $tdiff);
}
