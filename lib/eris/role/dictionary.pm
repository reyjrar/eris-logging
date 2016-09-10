package eris::role::dictionary;

use Moose::Role;
use namespace::autoclean;

requires qw(lookup);

########################################################################
# Attributes
has name => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_name',
);
has priority => (
    is         => 'ro',
    isa        => 'Int',
    lazy_build => 1,
);

########################################################################
# Builders
sub _build_name {
    my ($self) = shift;
    my ($class) = ref $self;
    my @path = split /\:\:/, defined $class ? $class : '';

    die "Bad reference to eris::dictionary $class" unless @path > 1;

    return $path[-1];
}
sub _build_priority  { 50; }


########################################################################
# Method Augmentation
around 'lookup' => sub {
    my $orig = shift;
    my $self = shift;

    my $entry = $self->$orig(@_);
    if( defined $entry && ref $entry eq 'HASH' ) {
        $entry->{from} = $self->name;
    }
    $entry; # return'd
};

1;
