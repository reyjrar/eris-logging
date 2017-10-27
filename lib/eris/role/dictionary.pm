package eris::role::dictionary;

use Moo::Role;
use Types::Standard qw(Int Str);
use namespace::autoclean;

########################################################################
# Interface
requires qw(lookup fields);
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
    # If we're official, trim the prefix
    $class =~ s/^eris::dictionary:://;
    # Replace the colons with underscores
    return $class =~ s/::/_/gr;
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
