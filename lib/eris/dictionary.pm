package eris::dictionary;

use namespace::autoclean;
use Moose;
with qw(
    eris::role::pluggable
);

########################################################################
# Attributes
has 'vocabulary' => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    builder => '_build_vocabulary',
);

########################################################################
# Builders
sub _build_namespace { 'eris::dictionary' }
sub _build_vocabulary {
    my ($self) = shift;
    my %fields = ();
    foreach my $p (sort { $a->priority <=> $b->priority } $self->loader->plugins ) {
        my $f = $p->fields;
        foreach my $k (keys %{ $f }) {
            $fields{$k} = $f->{$k};
        }
    }
    return \%fields;
}

my $_dict=();
sub BUILD {
    my $self = shift;
    $_dict = $self->vocabulary();
}


########################################################################
# Methods
sub lookup {
    exists $_dict->{$_[1]};     # Does the second arg, ie, the key exist
}

__PACKAGE__->meta->make_immutable;
1;
