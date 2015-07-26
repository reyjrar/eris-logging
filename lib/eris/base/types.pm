package eris::base::types;

use Moose;

subtype 'eris::type::config' as 'HashRef';
coerce  'eris::type::config'
    => from 'Str'
    => via {
        my $file = $_;
        die "invalid config file: $file" unless -f $file;
        my $config;
        eval {
           $config = Load($file);
           1;
        } or die "unable to parse YAML file: $file, $@";
        return $config;
    };

__PACKAGE__->meta->make_immutable;
1;
