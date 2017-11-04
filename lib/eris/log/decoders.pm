package eris::log::decoders;
# ABSTRACT: Discovery and access for decoders

use eris::log;
use Time::HiRes qw(gettimeofday tv_interval);
use Types::Standard qw(ArrayRef);

use Moo;
use namespace::autoclean;

with qw(
    eris::role::pluggable
);


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
            my $decoder_name = "decoder::" . $decoder->name;
            if( defined $data && ref $data eq 'HASH' ) {
                # Meta Fields
                foreach my $k (qw(_epoch _schema _type)) {
                    next unless exists $data->{$k};
                    my $meta = $k =~ s/^_//r;
                    ## no critic (ProhibitNoStrict)
                    no strict 'refs';
                    $log->$meta( delete $data->{$k} );
                    ## use critic
                }
                $log->unix_timestamp( delete $data->{epoch} ) if $data->{epoch};
                # Stash the rest of the message
                $log->add_context($decoder_name => $data);
            }
            $t{$decoder_name} = tv_interval($t0);
        }
        $log->add_timing(%t);

        return $log;      # Return the log object
    }
} # end closure

1;
