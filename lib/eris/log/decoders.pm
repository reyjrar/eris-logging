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

# VERSION

=head1 SYNOPSIS

Finds all available and configured decoders, returns an L<eris::log> instance from the raw string.

    use Data::Printer;
    use eris::log::decoders;

    my $dec = eris::decoders->new();

    while(<<>>) {
        p( $dec->decode($_) );
    }


=attr namespace

Defaults to 'eris::log::decoder' to add more, configure your C<search_path>

    ---
    decoders:
      search_path:
        - 'my::app::decoders'

=cut

sub _build_namespace { 'eris::log::decoder' }

=method decode

Takes a raw string and returns a decoded L<eris::log> instance.

Stores the raw message in the C<raw> attribute of the L<eris::log> instance.

Every decoder discovered in the C<namespace> and C<search_path> are then passed
the raw string to their C<decode_message()> method.  The returned HashRef is recorded
in the new L<eris::log> instance.

The timing of the decoding and each individual decoder is recorded with the
L<eris::log> C<add_timing()> method.  This data is available when the
L<eris::dictionary::eris::debug> is enabled.  When adding new decoders, it's
recommended to enable this dictionary for understanding the performance of the
decoder in real world situations.

=cut

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
            my $decoder_name = "decoder_" . $decoder->name;
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

=head1 SEE ALSO

L<eris::log::contextualizer>, L<eris::role::decoder>, L<eris::log>,
L<eris::log::decoder::syslog>, L<eris::log::decoder::json>

=cut

1;
