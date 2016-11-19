package eris::base::types;

use Moose;
use Moose::Util::TypeConstraints;
use YAML;

# Config File to HashRef Conversion
subtype 'eris::type::config',
    as 'HashRef';
coerce  'eris::type::config'
    => from 'Str'
    => via {
        my $file = $_;
        my $config = {};
        if ( -f $file ) {
            eval {
            $config = YAML::LoadFile($file);
            1;
            } or die "unable to parse YAML file: $file, $@";
        }
        return $config;
    };

__PACKAGE__->meta->make_immutable;
1;
