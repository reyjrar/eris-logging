#!/usr/bin/env perl
# PODNAME: eris-eris-client.pl
# ABSTRACT: Simple wrapper to spawn workers for handling syslog stream
use strict;
use warnings;

use FindBin;
use Hash::Merge::Simple qw(clone_merge);
use Getopt::Long::Descriptive;
use Path::Tiny;

use POE qw(
    Component::Client::eris
    Component::WheelRun::Pool
    Wheel::ReadWrite
    Filter::Line
);

my ($opt,$usage) = describe_options('%c - %o',
    [ 'config:s',   'Eris YAML config file, required', { validate => { "Must be a readable file." => sub { -r $_[0] } } } ],
    [ 'workers|w:i','Number of workers to run, default 4', { default => 4 }  ],
    [],
    [ 'help',  'Display this help' ],
);
if( $opt->help ) {
    print $usage->text;
    exit 0;
}

my $main_session = POE::Session->create(
        inline_states => {
            _start => \&main_start,
            _stop  => \&main_stop,
            stats  => \&main_stats,

            syslog_input  => \&syslog_input,
            syslog_error  => \&syslog_error,
            worker_stdout => \&worker_stdout,
        },
        heap => {
            stats => {},
        },
);

POE::Kernel->run();

sub main_stop {  }

sub main_start {
    my ($kernel,$heap) = @_[KERNEL,HEAP];

    # Startup the Eris Client
    my $eris_session = POE::Component::Client::eris->spawn(
        Subscribe      => 'fullfeed',
        ReturnType     => 'string',
        MessageHandler => sub {
            $kernel->post( pool => dispatch => @_ );
        },
    );

    # Figure out where we're installed
    my $bindir = path( "$FindBin::RealBin" );
    $heap->{workers} = POE::Component::WheelRun::Pool->spawn(
        Alias       => 'pool',
        PoolSize    => $opt->workers,
        Program     => $^X,
        ProgramArgs => [
            '--',
            $bindir->child('eris-es-indexer.pl')->stringify,
            $opt->config ? ('--config', $opt->config ) : (),
        ],
        StdinFilter  => POE::Filter::Line->new(),
        StdoutFilter => POE::Filter::Reference->new(),
        StatsHandler => sub {
            my ($stats) = @_;
            if( is_hashref($stats) ) {
                $heap->{stats} = clone_merge( $stats, $heap->{stats} );
            }
        },
        StdoutHandler => sub {
            $kernel->yield(worker_stdout => @_);
        }
    );

    $kernel->delay(stats => 60);
}

sub main_stats {
    my ($kernel,$heap) = @_[KERNEL,HEAP];

    my $stats = exists $heap->{stats} ? delete $heap->{stats} : {};

    printf "%s STATS: %s\n", strftime("%H:%M",localtime), join(', ', map { sprintf "%s=%s", $_, $stats->{$_} } keys %{ $stats });

    if( exists $heap->{graphite} ) {
        # output to graphite
    }

    # Reschedule ourselves;
    $heap->{stats} = {};
    $kernel->delay( stats => 60 ) unless exists $heap->{_shutdown};
}

sub worker_stdout {
    my ($kernel,$heap,$stats) = @_[KERNEL,HEAP,ARG0];

    # Make sure we have stats
    return unless defined $stats && is_hashref($stats);

    # Aggregate stats from all our workers
    foreach my $s (keys %{ $stats }) {
        $heap->{stats}{$s} ||= 0;
        $heap->{stats}{$s} += $stats->{$s};
    }
}
