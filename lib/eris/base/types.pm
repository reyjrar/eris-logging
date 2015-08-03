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
        die "invalid config file: $file" unless -f $file;
        my $config;
        eval {
           $config = YAML::LoadFile($file);
           1;
        } or die "unable to parse YAML file: $file, $@";
        return $config;
    };

# Config File for Targets
subtype 'eris::type::target',
    as 'CodeRef';
coerce 'eris::type::target'
    => from 'Str'
    => via {
        my $target = lc shift;
        return sub { my $local = lc shift; $target eq $local }
    };
coerce 'eris::type::target'
    => from 'RegexpRef'
    => via {
        my $target = shift;
        return sub { my $local = shift; $local =~ /$target/o };
    };


__PACKAGE__->meta->make_immutable;
1;
