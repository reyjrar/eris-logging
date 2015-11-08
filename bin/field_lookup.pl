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
use YAML;
use eris::dictionary;

#------------------------------------------------------------------------#
# Path Setup
my $path_base = path("$FindBin::Bin")->parent;

#------------------------------------------------------------------------#
# Argument Parsing
my ($opt,$usage) = describe_options(
    "%c %o <fields to lookup>",
    [],
    [ 'config|c:s', "eris config file", {
        default => $path_base->child('eris.yml')->realpath->canonpath,
        callbacks => { exists => sub { -f shift } }
    }],
);
die $usage->text unless @ARGV;

#------------------------------------------------------------------------#
# Main
my $cfg = YAML::LoadFile($opt->config) || {};
my %args = exists $cfg->{dictionary} && ref $cfg->{dictionary} eq 'HASH' ? %{ $cfg->{dictionary} } : ();
my $dict = eris::dictionary->initialize(%args);

foreach my $field (@ARGV) {
    output({clear=>1,color=>'yellow'}, "Looking up '$field'");
    p( $dict->lookup($field) );
}
