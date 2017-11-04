package eris::base::types;
# ABSTRACT: Type for use in the eris libraries

use strict;
use warnings;

# VERSION

=head1 SYNOPSIS

This is eris' type library.

=cut

use Type::Library
    -base,
    -declare => qw(HashRefFromYAML);
use Type::Utils -all;
use Types::Standard -types;
use YAML;

# Config File to HashRef Conversion
declare_coercion "HashRefFromYAML",
    to_type HashRef,
    from Str,
    q|
        my $file = $_;
        my $config = {};
        if ( -f $file ) {
            eval {
                $config = YAML::LoadFile($file);
                1;
            } or die "unable to parse YAML file: $file, $@";
        }
        return $config;
    |;

# Return True
1;
