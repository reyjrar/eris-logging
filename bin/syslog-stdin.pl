#!/usr/bin/env perl
# ABSTRACT: Simple wrapper to spawn workers for handling syslog stream
use strict;
use warnings;

use FindBin;
use Hash::Merge::Simple qw(clone_merge);
use Getopt::Long::Descriptive;
use Path::Tiny;

use POE qw(
    Component::WheelRun::Pool
    Wheel::ReadWrite
    Filter::Line
);

my ($opt,$usage) = describe_options('%c - %o',
    [ 'config:s', 'Eris YAML config file, required', { required => 1, validate => { "Must be a readable file." => sub { -r $_[0] } } } ],
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

    # Handle to the syslog daemon
    $heap->{io} = POE::Wheel::ReadWrite->new(
        InputHandle  => \*STDIN,
        OutputHandle => \*STDERR,
        InputFilter  => POE::Filter::Line->new(),
        OutputFilter => POE::Filter::Line->new(),
        InputEvent   => 'syslog_input',
        ErrorEvent   => 'syslog_error',
    );

    my $bindir = path( "$FindBin::RealBin" );
    my $libdir = $bindir->parent->child('lib');

    $heap->{workers} = POE::Component::WheelRun::Pool->spawn(
        Alias       => 'pool',
        Program     => $^X,
        ProgramArgs => [
            sprintf('-I%s',$libdir->stringify),
            '--',
            $bindir->child('send_to_elasticsearch.pl')->stringify,
            '--config', $opt->config,
        ],
        StdioFilter => POE::Filter::Line->new(),
        StatsHandler => sub {
            my ($stats) = @_;
            if( is_hashref($stats) ) {
                $heap->{stats} = clone_merge( $stats, $heap->{stats} );
            }
        }
    );

    $kernel->delay(stats => 60);
}

sub main_stats {
    my ($kernel,$heap) = @_;

    my $stats = exists $heap->{stats} ? delete $heap->{stats} : {};

    if( exists $heap->{graphite} ) {
        # output to graphite
    }

    # Reschedule ourselves;
    $heap->{stats} = {};
    $kernel->delay( stats => 60 );
}

sub worker_stdout {
    my ($kernel,$heap,$out) = @_[KERNEL,HEAP,ARG0];
}

sub syslog_input {
    my ($kernel,$heap,$msg) = @_[KERNEL,HEAP,ARG0];
    $kernel->post( pool => dispatch => $msg );
}
