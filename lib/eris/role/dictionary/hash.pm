package eris::role::dictionary::hash;

use Moo::Role;
use namespace::autoclean;

requires qw(hash);
with qw(eris::role::dictionary);

sub lookup {
    my ($self,$field) = @_;

    my $entry = undef;
    my $dict  = $self->hash;
    if( exists $dict->{lc $field} ) {
        $entry = {
            field => lc $field,
            description => $dict->{lc $field},
        };
    }
    return $entry;
}

sub fields {
    my ($self) = @_;

    return [ sort keys %{ $self->hash }  ];
}

1;
