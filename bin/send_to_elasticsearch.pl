
#!/usr/bin/env perl
#
use strict;
use warnings;

use App::ElasticSearch::Utilities::HTTPRequest;
use FindBin;
use Getopt::Long::Descriptive;
use JSON::MaybeXS;
use Path::Tiny;
use POE qw(
    Component::Client::HTTP
    Wheel::ReadWrite
    Filter::Line
    Filter::Reference
);
use POSIX qw(strftime);


use lib "$FindBin::RealBin/../lib";
use eris::log::contextualizer;

# Options
my ($opt,$usage) = describe_options('%c - %o',
    [ 'config:s', 'Config file, required.', { required => 1, validate => { "Must be a readable file" => sub { -r $_[0] } } } ],
    [],
    [ 'help',  'Display this help' ],
);
if( $opt->help ) {
    print $usage->text;
    exit 0;
}

# Global
my $eris = eris::log::contextualizer->new(config => $opt->config);

my $http_session = POE::Component::Client::HTTP->spawn(
    Alias   => 'ua',
    Timeout => 60,
);
my $main_session = POE::Session->create(
        inline_states => {
            _start => \&main_start,
            _stop  => \&main_stop,
            stats  => \&main_stats,

            syslog_input => \&syslog_input,
            syslog_error => \&syslog_error,

            # ElasticSearch Stuff
            es_bulk         => \&es_bulk,
            es_bulk_resp    => \&es_bulk_resp,
            es_mapping      => \&es_mapping,
            es_mapping_resp => \&es_mapping_resp,
        },
        heap => {
            es_addr         => 'http://localhost:9200',
            es_mapping_name => 'syslog',
            es_default_type => 'syslog',
            stats           => {},
            bulk_queue      => [],
        },
);

POE::Kernel->run();

sub main_stop {  }

sub main_start {
    my ($kernel,$heap) = @_[KERNEL,HEAP];

    # Set our alias
    $kernel->alias_set('main');

    # Handle to the syslog daemon
    $heap->{io} = POE::Wheel::ReadWrite->new(
        InputHandle  => \*STDIN,
        OutputHandle => \*STDOUT,
        InputEvent   => 'syslog_input',
        InputFilter  => POE::Filter::Line->new(),
        OutputFilter => POE::Filter::Reference->new(),
        ErrorEvent   => 'syslog_error',
    );

    $kernel->delay( stats => 60 );
}

sub main_stats {
    my ($kernel,$heap) = @_;

    my $stats = delete $heap->{stats};
    printf "%s STATS: %s". strftime('%T', localtime), join(', ', map { "$_=$stats->{$_}" } sort keys %{ $stats });

    $heap->{stats} = {};
    $kernel->delay( stats => 60 );
}

sub syslog_input {
    my ($kernel,$heap,$msg) = @_[KERNEL,HEAP,ARG0];

    return unless defined $msg;
    return unless length $msg;

    my $log = $eris->parse($msg);

    my $doc = $log->as_doc;

    my $time = exists $doc->{epoch} ? delete $doc->{epoch} : time;
    $doc->{timestamp} = strftime('%FT%T%z',gmtime($time));

    my $index = sprintf('%s-%s', $heap->{es_mapping_name}, strftime('%Y.%m.%d', gmtime($time)));
    my $type  = exists $doc->{type} ? delete $doc->{type} : $heap->{es_default_type};

    $heap->{stats}{queued} ||= 0;
    $heap->{stats}{queued}++;

    push @{ $heap->{bulk_queue} },
        { index => { _index => $index, type => $type } },
        $doc;
}

sub syslog_error {
    my ($kernel,$heap) = @_[KERNEL,HEAP];
    delete $heap->{io};
}

sub es_mapping {
    my ($kernel,$heap) = @_[KERNEL,HEAP];
    my %mapping = (
        template => "$heap->{es_mapping_name}-*",
        settings => {
            'index.query.default_field' => 'message',
        },
        mappings => {
            _default_ => {
                _all => { enabled => 'false' },
                _source => { compress => 'false' },
                dynamic_templates => [
                    { timing_template => {
                        path_match => 'timing.*',
                        mapping => {
                            type       => 'float',
                            index      => 'not_analyzed',
                            doc_values => 'true',
                        }
                    }},
                    { geoip_template => {
                        match   => '*_geoip',
                        mapping => {
                            type  => 'object',
                            enable => 'true',
                            dynamic => 'false',
                            properties => {
                                city        => { type => 'string', index => 'not_analyzed' },
                                country     => { type => 'string', index => 'not_analyzed' },
                                continent   => { type => 'string', index => 'not_analyzed' },
                                postal_code => { type => 'string', index => 'not_analyzed' },
                                location    => { type => 'geopoint', lat_lon => 'true', 'ignore_malformed' => 'yes' },
                            }
                        },
                    }},
                    { ip_template => {
                        match   => '*_ip',
                        mapping => {
                            type             => 'ip',
                            ignore_malformed => 'true',
                            index            => 'analyzed',
                            doc_values       => 'true',
                        },
                        fields => {
                            raw => {
                                mapping => {
                                    type => 'string',
                                    index => 'not_analyzed',
                                }
                            }
                        }
                    }},
                    { string_template => {
                        match_mapping_type => 'string',
                        mapping => {
                            type         => 'string',
                            index        => 'not_analyzed',
                            ignore_above => 256,
                        }
                    }},
                ],
                properties => {
                    'timestamp' => {
                        type       => 'date',
                        format     => 'dateTime',
                        index      => 'not_analyzed',
                        doc_values => 'true',
                    },
                    message => {
                        type => 'string',
                        index => 'analyzed',
                        ignore_above => 4096,
                        analyzer => 'whitespace',
                    },
                }
            }
        }
    );

    # Build the Request
    my $req = App::ElasticSearch::Utilities::HTTPRequest->new(PUT => sprintf("%s/_template/%s",$heap->{es_addr},$heap->{es_mapping_name}));
    $req->content(\%mapping);

    # Submmit it
    $kernel->post( ua => request => es_mapping_resp => $req );
}

sub es_mapping_resp {
    my ($kernel,$heap,$reqs,$resps) = @_[KERNEL,HEAP,ARG0,ARG1];

    # Get the response object
    my $resp = $resps->[0];

    if( $resp->is_success ) {
        $heap->{es_ready} = 1;
    }
    else {
        printf STDERR "[es_mapping] ERROR: %d HTTP Response, %s", $resp->code, $resp->content ? $resp->content : "failed";
    }
}

sub es_bulk {
    my ($kernel,$heap) = @_[KERNEL,HEAP];

    my $bulk = delete $heap->{bulk_queue};

    if( $heap->{es_ready} ) {
        my $req = App::ElasticSearch::Utilities::HTTPRequest->new(POST => sprintf "%s/_bulk", $heap->{es_addr});
        $req->content($bulk);
        $kernel->post( ua => request => es_bulk_resp => $req );
    }
    else {
        $heap->{stats}{discarded} ||= 0;
        $heap->{stats}{discarded} += scalar( @{$bulk} ) / 2;
    }

    $heap->{bulk_queue} = [];
    $kernel->delay( es_flush => 15 );
}

sub es_bulk_response {
    my ($kernel,$heap,$reqs,$resps) = @_[KERNEL,HEAP,ARG0,ARG1];

    # HTTP::Request Object
    my $req = $reqs->[0];

    # HTTP::Response Object
    my $resp = $resps->[0];

    # Record if this was successful or not
    my $stat = sprintf "bulk_%s", $resp->is_success ? 'success' : 'error';
    $heap->{stats}{$stat} ||= 0;
    $heap->{stats}{$stat}++;
}
