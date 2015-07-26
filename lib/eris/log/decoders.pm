package eris::log::decoders;

use namespace::autoclean;
use Moose;
with qw(
    eris::role::pluggable
);


########################################################################
# Attributes
has 'decoders' => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy => 1,
    builder => '_build_decoders',
);

########################################################################
# Builders
sub _build_namespace { 'eris::log::decoder'; }
sub _build_decoders {
    my ($self) = @_;
    return [ sort { $a->priority <=> $b->priority } $self->loader->plugins ];
}

########################################################################
# Methods
sub decode {
    my ($self,$raw) = @_;

    # Create the log entry
    my $log = eris::log->new( raw => $raw );

    # Store the decoded data
    foreach my $decoder (@{ $self->decoders }) {
        my $data = $decoder->decode($raw);

        if( defined $data && ref $data eq 'HASH' ) {
            $log->set_decoded($decoder->name => $data);
        }
    }

    $log;      # Return the log object
}

__PACKAGE__->meta->make_immutable;
1;
