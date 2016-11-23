package eris::base::types;

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
