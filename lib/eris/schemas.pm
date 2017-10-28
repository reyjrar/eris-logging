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
    my @schemas = ();
    # Otherwise, find the schema's collecting this log
    foreach my $p (@{ $self->plugins }) {
        # Jump out as quickly as possible
        if( $p->match_log($log) ) {
            push @schemas, $p;
            last if $p->final;
        }
    }
    # Return our schemas
    return @schemas;
}

sub as_bulk {
    my ($self,$log) = @_;
    # Find the matching schemas
    my @schemas = $self->find($log);
    # Return the bulk strings or the empty list
    return @schemas ? map { $_->as_bulk($log) } @schemas : ();
}

1;
