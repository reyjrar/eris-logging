package eris::log::decoders;

use eris::log;
use Moose;
use namespace::autoclean;

with qw(
    eris::role::pluggable
);


########################################################################
# Attributes
has 'decoders' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    lazy    => 1,
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
{
    my $decoders = undef;
    sub decode {
        my ($self,$raw) = @_;

        # Initialize the decoders
        $decoders //= $self->decoders;

        # Create the log entry
        my $log = eris::log->new( raw => $raw );

        # Store the decoded data
        foreach my $decoder (@{ $decoders }) {
            my $data = $decoder->decode_message($raw);
            if( defined $data && ref $data eq 'HASH' ) {
                $log->set_decoded($decoder->name => $data);
            }
        }

        return $log;      # Return the log object
    }
} # end closure

__PACKAGE__->meta->make_immutable;
1;
