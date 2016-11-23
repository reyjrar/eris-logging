package eris::log::decoders;

use eris::log;
use Moo;
use Time::HiRes qw(gettimeofday tv_interval);
use Types::Standard qw(ArrayRef);
use namespace::autoclean;

with qw(
    eris::role::pluggable
);


########################################################################
# Attributes

########################################################################
# Builders
sub _build_namespace { 'eris::log::decoder' }

########################################################################
# Methods
{
    my $decoders = undef;
    sub decode {
        my ($self,$raw) = @_;

        # Initialize the decoders
        $decoders //= $self->plugins;

        # Create the log entry
        my $log = eris::log->new( raw => $raw );

        # Store the decoded data
        my %t=();
        foreach my $decoder (@{ $decoders }) {
            my $t0 = [gettimeofday];
            my $data = $decoder->decode_message($raw);
            my $decoder_name = $decoder->name;
            if( defined $data && ref $data eq 'HASH' ) {
                $log->set_decoded($decoder_name => $data);
            }
            $t{"decoder::$decoder_name"} = tv_interval($t0);
        }
        $log->add_timing(%t);

        return $log;      # Return the log object
    }
} # end closure

1;
