package eris::role::dictionary;
# ABSTRACT: Interface for implementing a dictionary object

use Moo::Role;
use Types::Standard qw(Int Str);
use namespace::autoclean;

# VERSION

=head1 INTERFACE

=head2 lookup()

Takes a field name, returns undef for not found or
a HashRef with the following keys:

    {
        field => 'field_name',
        description => 'This is what this field means to users',
    }

=head2 fields()

Returns the list of all fields in the dictionary.

=cut

requires qw(lookup fields);
with qw(
    eris::role::plugin
);

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

=head1 SEE ALSO

L<eris::dictionary>, L<eris::role::plugin>, L<eris::dictionary::cee>,
L<eris::dictionary::eris>, L<eris::dictionary::syslog>

=cut

1;
