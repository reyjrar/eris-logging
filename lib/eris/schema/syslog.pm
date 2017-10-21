package eris::schema::syslog;

use Moo;
use namespace::autoclean;
with qw(
    eris::role::schema
);

sub _build_mappings {
    {
        _default_ => {
            _all => { enabled => 'false' },
            dynamic_templates => [
                { geoip_template => {
                    match   => '*_geoip',
                    mapping => {
                        type  => 'object',
                        enable => 'true',
                        dynamic => 'false',
                        properties => {
                            asn         => { type => 'keyword' },
                            city        => { type => 'keyword' },
                            continent   => { type => 'keyword' },
                            country     => { type => 'keyword' },
                            isp         => { type => 'keyword' },
                            location    => { type => 'geopoint', lat_lon => 'true' },
                            postal_code => { type => 'keyword' },
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
                        fields => {
                            raw => {
                                type => 'keyword',
                            },
                        },
                    },
                }},
                { string_template => {
                    match_mapping_type => 'string',
                    mapping => {
                        type         => 'keyword',
                        ignore_above => 256,
                    }
                }},
            ],
            properties => {
                timing => {
                    type => 'nested',
                    dynamic => 'false',
                    properties => {
                        phase => { type => 'keyword', ignore_above => 80 },
                        seconds => { type => 'float' },
                    }
                },
                timestamp => {
                    type       => 'date',
                    format     => 'date_time||date_time_no_millis||epoch_second',
                    index      => 'not_analyzed',
                },
                message => {
                    type => 'text',
                    analyzer => 'whitespace',
                },
                raw => {
                    type  => 'text',
                    index => 'false',
                    norms => 'false',
                },
            }
        }
    }
}

1;
