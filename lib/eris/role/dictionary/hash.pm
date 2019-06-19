package eris::role::dictionary::hash;
# ABSTRACT: Simple dictionary implementation based off a hash

use Moo::Role;
use JSON::MaybeXS;
use namespace::autoclean;
with qw(eris::role::dictionary);

# VERSION

=head1 SYNOPSIS

Simplest possible dictionary implementation

    package my::app::dictionary::business;

    use Moo;
    with qw(
        eris::role::dictionary::hash
    );

    sub hash {
        return {
            'customer_id'     => "Our customer ID field",
            'store_id'        => "Our store ID field",
            'price_usd'       => "Object price in USD",
            'transaction_key' => "Transaction Identifier",
        }
    }

=head1 INTERFACE

=head2 hash

Return a HashRef with the field names as keys and a string description of the field.

May also return a HashRef with field names as keys and a HashRef as a value.  Those key/value
pairs will be returned to the C<lookup()> function.

=cut

requires qw(hash);

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
            type  => 'keyword',
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

=method expand_line

Expand a line in a file/DATA section to a workable hash

=cut

sub expand_line {
    my ($self,$line) = @_;

    my ($k,$v);
    if( $line =~ /^{/ ) {
        eval {
            my $field = decode_json($line);
            $k = lc delete $field->{name};
            $v = $field;
        } or do {
            my $err = $@;
            warn "BAD JSON: $err\n\n$line\n";
        };
    }
    else {
        my ($field,$desc) = split /\s+/, $line, 2;
        $k = lc $field;
        $v = $desc;
    }

    return $k ? ( $k => $v ) : ();
}

=head1 SEE ALSO

L<eris::role::dictionary>, L<eris::dictionary>, L<eris::dictionary::cee>


=cut

1;
