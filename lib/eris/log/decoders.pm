package eris::log::decoders;

use eris::log;
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
            printf "decoding with %s ..\n", $decoder->name;

            if( defined $data && ref $data eq 'HASH' ) {
                printf " + decoded successfully with %s ..\n", $decoder->name;
                $log->set_decoded($decoder->name => $data);
            }
        }

        $log;      # Return the log object
    }
} # end closure

__PACKAGE__->meta->make_immutable;
1;
