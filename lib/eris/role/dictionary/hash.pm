package eris::role::dictionary::hash;

use Moose::Role;
use namespace::autoclean;

requires qw(hash);

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

1;
