package eris::role::schema;

use Moo::Role;
use Types::Standard qw(HashRef Int Str);
use namespace::autoclean;

########################################################################
# Interface
#requires qw(mapping);

########################################################################
# Attributes
has 'name' => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_name',
);

has 'index_template' => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_index_template',
);

has 'order' => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_order',
);

has 'settings' => (
    is => 'ro',
    isa => HashRef,
    default => sub {{}},
);

has 'aliases' => (
    is => 'ro',
    isa => HashRef,
    default => sub {{}},
);

has 'mappings' => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_mappings',
);

########################################################################
# Builders
sub _build_name {
    my ($self) = shift;
    my ($class) = ref $self;
    my $guess;
    # Assuming this looks like:
    #  eris::schema::things
    #  com::example::logging::schema::things
    if( $guess = (split /schema::/, $class, 2 )[-1]) {
        $guess =~ s/::/_/g;
    }
    else {
        my @path = split /\:\:/, defined $class ? $class : '';
        $guess = $path[-1];
    }
    die "I can't figure out what you want my name to be for $class, please add a _build_name() sub to specify"
        unless $guess;

    return $guess;
}

sub _build_index_template { join('-', $_[0]->name,'*') }
sub _build_order { 50 }
sub _build_mappings { $_[0]->default_mappings }

########################################################################
# Methods

sub default_mappings {
    {
        '_default_' => {
            _all => { enabled => 'false' },
            dynamic_templates => [
                {
                    "date_template": {
                    "mapping" => {
                        "format"           => "date_time||date_time_no_millis||epoch_second",
                        "index"            => "not_analyzed",
                        "ignore_malformed" => "true",
                        "type"             => "date"
                    },
                    "match" => "*_date"
                    }
                },
                {
                    "ip_template" => {
                    "mapping" => {
                        "ignore_malformed" => "true",
                        "type" => "ip",
                        "fields" => {
                            "raw" => {
                                "index" => "false",
                                "type" => "keyword"
                            }
                        }
                    },
                    "match" => "*_ip"
                    }
                },
                {
                    "bytes_template" => {
                    "mapping" => {
                        "ignore_malformed" => "true",
                        "type" => "long"
                    },
                    "match" => "*_bytes"
                    }
                },
                {
                    "port_template" => {
                    "mapping" => {
                        "ignore_malformed" => "true",
                        "type" => "long"
                    },
                    "match" => "*_port"
                    }
                },
                {
                    "geo_template" => {
                        "mapping" => {
                            "path" => "full",
                            "dynamic" => "true",
                            "type" => "object",
                            "properties" => {
                                "location" => {
                                    "type" => "geo_point"
                                }
                            }
                        },
                    "match" => "*_geoip"
                    }
                },
                {
                    "string_fields" => {
                        "mapping" => {
                            "ignore_above" => 256,
                            "index" => "true",
                            "type" => "keyword",
                            "index_options" => "docs",
                            "doc_values" => "true"
                        },
                        "match_mapping_type" => "string",
                        "match" => "*"
                    }
                }
            ],
            "properties" => {
				'@timestamp' => {
					"format" => "date_time||date_time_no_millis||epoch_second",
					"index" => "not_analyzed",
					"ignore_malformed" => "false",
					"type" => "date"
				},
				'@source' => {
					"ignore_above" => 1024,
					"index" => "true",
					"type" => "keyword",
					"index_options" => "docs",
					"doc_values" => "true"
				},
				'@tags' => {
					"ignore_above" => 128,
					"index" => "true",
					"type" => "keyword",
					"index_options" => "docs",
					"doc_values" => "true"
				},
				'@version' => {
					"ignore_above" => 128,
					"index" => "true",
					"type" => "keyword",
					"index_options" => "docs",
					"doc_values" => "true"
				},
				"message" => {
					"fielddata" => "false",
					"norms" => "false",
					"analyzer" => "whitespace",
					"index" => "analyzed",
					"type" => "text",
					"fields" => {
						"raw" => {
							"index" => "false",
							"type" => "text"
						}
					}
				}
			}
		}
    }
}

1;
