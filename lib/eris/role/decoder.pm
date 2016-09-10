package eris::role::decoder;

use Moose::Role;
use namespace::autoclean;

requires 'decode_message';

########################################################################
# Attributes
has name => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_name',
);
has priority => (
    is      => 'ro',
    isa     => 'Int',
    lazy    => 1,
    builder => '_build_priority',
);

########################################################################
# Builders
sub _build_name {
    my ($self) = shift;
    my ($class) = ref $self;
    my @path = split /\:\:/, defined $class ? $class : '';

    die "Bad reference to eris::role::decoder $class" unless @path > 1;

    return $path[-1];
}
sub _build_priority  { 50; }

1;
