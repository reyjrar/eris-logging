package eris::role::dictionary;

use Moo::Role;
use Types::Standard qw(Int Str);
use namespace::autoclean;

########################################################################
# Interface
requires qw(lookup);
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

    die "Bad reference to eris::dictionary $class" unless @path > 1;

    return $path[-1];
}


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
