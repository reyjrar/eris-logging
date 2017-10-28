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
use YAML;

use eris::log::contextualizer;
use eris::schemas;

#------------------------------------------------------------------------#
# Path Setup
my $path_base = path("$FindBin::Bin")->parent;

#------------------------------------------------------------------------#
# Argument Parsing
my ($opt,$usage) = describe_options(
    "%c %o ",
    [ 'sample|s:s', "Sample messages from the specified context" ],
    ['bulk|b',      "Show the bulk output from the schema match instead." ],
    [],
    [ 'config|c:s', "eris config file", {
        callbacks => { exists => sub { -f shift } }
    }],
    [ 'help' => 'Display this message and exit', { shortcircuit => 1 } ],
);
if( $opt->help ) {
    print $usage->text;
    exit 0;
}

#------------------------------------------------------------------------#
# Main
my $cfg  = $opt->config ? YAML::LoadFile($opt->config) : {};
my $ctxr = eris::log::contextualizer->new( config => $cfg );
my $schm = eris::schemas->new( $cfg->{schemas} ? %{ $cfg->{schemas} } : () );

my @sampled = ();
foreach my $c ( @{ $ctxr->contexts->plugins } ) {
    verbose({color=>'magenta'}, sprintf "Loaded context: %s", $c->name);
    if( $opt->sample and lc $opt->sample eq lc $c->name ) {
        push @sampled, $c->sample_messages;
    }
}

if( @sampled ) {
    foreach my $msg ( @sampled ) {
        dump_record($msg);
    }
}
else {
    # Use the Magic Diamond
    while(<>) {
        chomp;
        verbose({color=>'cyan'}, $_);
        dump_record($_);
    }
}

sub dump_record {
    my $msg = shift;
    use eris::schema::syslog;
    my $s = eris::schema::syslog->new();
    my $l = $ctxr->parse($msg);
    if( $opt->bulk ) {
        output({data=>1}, $schm->as_bulk($l));
    }
    else {
        p($l);
    }
}
