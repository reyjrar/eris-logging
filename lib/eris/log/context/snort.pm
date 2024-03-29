package eris::log::context::snort;
# ABSTRACT: Parses the Snort and Suricata alert logs

use Moo;
use namespace::autoclean;
with qw(
    eris::role::context
);

# VERSION

=head1 SYNOPSIS

This parses data in the Snort and Suricata alert logs into structured data.

=attr matcher

Matches the literal string 'snort' and 'suricata'

=cut

sub _build_matcher {
    [qw(suricata snort)]
}

=for Pod::Coverage sample_messages

=cut

sub sample_messages {
    my @msgs = split /\r?\n/, <<EOF;
Jul 26 15:50:21 ether suricata: [1:2210045:2] SURICATA STREAM Packet with invalid ack [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 5.22.134.191:15682 -> 99.46.177.250:50673
Jul 26 15:50:21 ether suricata: [1:2210046:2] SURICATA STREAM SHUTDOWN RST invalid ack [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 5.22.134.191:15682 -> 99.46.177.250:50673
Jul 26 15:50:21 ether suricata: [1:2210046:2] SURICATA STREAM SHUTDOWN RST invalid ack [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 141.226.218.88:48038 -> 99.46.177.250:50673
Jul 26 15:50:21 ether suricata: [1:2210045:2] SURICATA STREAM Packet with invalid ack [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 141.226.218.88:48038 -> 99.46.177.250:50673
Jul 26 15:50:21 ether suricata: [1:2010935:2] ET POLICY Suspicious inbound to MSSQL port 1433 [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 183.60.48.25:12216 -> 99.46.177.250:1433
Jul 26 15:50:21 ether suricata: [1:2010935:2] ET POLICY Suspicious inbound to MSSQL port 1433 [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 208.100.26.228:50861 -> 99.46.177.250:1433
Jul 26 15:50:21 ether suricata: [1:2008581:3] ET P2P BitTorrent DHT ping request [Classification: Potential Corporate Privacy Violation] [Priority: 1] {UDP} 99.46.177.250:29902 -> 112.157.21.174:4652
EOF
    return @msgs;
}

=method contextualize_message

Extracts information from the Snort and Suricata alert logs

    name      => rule name
    class     => rule classification
    pri       => rule priority
    proto_app => protocol

And

    src_ip src_port dst_ip dst_port

Tags messages with 'security' and 'ids'.

=cut

sub contextualize_message {
    my ($self,$log) = @_;
    my $str = $log->context->{message};

    $log->add_tags(qw(security ids));

    my %ctxt = ();
    if ( $str =~ /^\[(\S+)\]\s+/g ) {
        $ctxt{id} = (split /:/, $1, 3)[1];
        if ( $str =~ /\G([^\[]+)/gc ) {
            $ctxt{name} = $1;
            $ctxt{name} =~ s/\s+$//;
            if ( $str =~ /(?>\[Classification: ([^\]]+)\])/ )  {
                $ctxt{class} = $1;
            }
            if ( $str =~ /(?>\[Priority: (\d+)\])/ )  {
                $ctxt{pri} = $1;
            }
            if ( $str =~ /(?>\{(\S+)\})/ ) {
                $ctxt{proto_app} = $1;
            }
            if( $str =~ /(?>(\S+):(\d+) -> (\S+):(\d+))/ ) {
                @ctxt{qw(src_ip src_port dst_ip dst_port)} = ($1,$2,$3,$4);
            }
        }
    }

    $log->add_context($self->name,\%ctxt) if keys %ctxt;
}

=head1 SEE ALSO

L<eris::log::contextualizer>, L<eris::role::context>

=cut

1;
