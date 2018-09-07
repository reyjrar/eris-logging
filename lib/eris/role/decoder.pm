package eris::role::decoder;
# ABSTRACT: Role for implementing decoders

use Moo::Role;
use Types::Standard qw( Str Int );
use namespace::autoclean;

# VERSION

=head1 SYNOPSIS

Implement your own decoders, e.g.:

    use Parse::Syslog::Line;
    use Moo;
    with qw( eris::role::decoder );

    sub decode_message {
        my ($self,$msg) = @_;
        return parse_syslog_line($msg);
    }


=head1 INTERFACE

=head2 decode_message

Passed the raw message as received.  Expects a parsed structure in the form of a
C<HashRef> as a return.

=cut

requires 'decode_message';
with qw(
    eris::role::plugin
);

=head1 SEE ALSO

L<eris::log::decoders>, L<eris::log::contextualizer>, L<eris::log::decoders::syslog>,
L<eris::log::decoder::json>

=cut

1;
