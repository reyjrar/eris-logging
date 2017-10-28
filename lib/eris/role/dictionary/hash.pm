package eris::role::dictionary::hash;
# ABSTRACT: Simple dictionary implementation based off a hash

use Moo::Role;
use namespace::autoclean;

requires qw(hash);
with qw(eris::role::dictionary);

=method lookup($field)

Find the field in the hash, returns a hashref in the format:

    {
       field => $field,
       description => $lookup_hash{$field},
    }

Or if the hash value is a hash reference, we return:

    {
       field => $field,
       %{ $lookup_hash{$field} },
    }

=cut

sub lookup {
    my ($self,$field) = @_;

    my $entry = undef;
    my $dict  = $self->hash;
    if( exists $dict->{$field} ) {
        $entry = {
            field => $field,
            ref $dict->{$field} eq 'HASH' ? %{ $dict->{$field} }
                : ( description => $dict->{$field} ),
        };
    }
    return $entry;
}

=method fields()

Returns the sorted list of keys in the lookup hash

=cut

sub fields {
    my ($self) = @_;
    return [ sort keys %{ $self->hash }  ];
}

1;
