package eris::schemas;

use Moo;
with qw(
    eris::role::pluggable
);
use Types::Standard qw(HashRef);
use namespace::autoclean;

########################################################################
# Attributes
has fields => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_fields',
);

########################################################################
# Builders
sub _build_namespace { 'eris::schema' }

########################################################################
# Methods
sub find {
    my ($self,$log) = @_;
    # Otherwise, find the first match
    foreach my $p (@{ $self->plugins }) {
        # Jump out as quickly as possible
        return $p if $p->match_log($log);
    }
    # Empty return
    return;
}

sub as_bulk {
    my ($self,$log) = @_;
    # Find the first matching schema
    my $schema = $self->find($log);
    # Return the bulk string or the empty list
    return $schema ? $schema->as_bulk($log) : ();
}

1;
