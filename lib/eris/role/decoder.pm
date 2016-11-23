package eris::role::decoder;

use Moo::Role;
use Types::Standard qw( Str Int );
use namespace::autoclean;

########################################################################
# Attributes
requires 'decode_message';
with qw(
    eris::role::plugin
);

########################################################################
# Attributes

########################################################################
# Builders
sub _build_name {
    my ($self) = shift;
    my ($class) = ref $self;
    my @path = split /\:\:/, defined $class ? $class : '';

    die "Bad reference to eris::role::decoder $class" unless @path > 1;

    return $path[-1];
}

1;
