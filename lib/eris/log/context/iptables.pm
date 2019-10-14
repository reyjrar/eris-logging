package eris::log::context::iptables;
# ABSTRACT: Parses iptables messages into structured data.

use Const::Fast;
use Moo;
with qw(
    eris::role::context
);
use namespace::autoclean;

# VERSION

=head1 SYNOPSIS

Parses iptables messages into structured data.

=attr field

Our regex will match the message string

=cut

sub _build_field { 'message' }


=attr matcher

A regex starting with the word 'iptables'

=cut

sub _build_matcher { qr/^iptables\b/ }


=for Pod::Coverage sample_messages

=cut

sub sample_messages {
    my @msgs = split /\r?\n/, <<'EOF';
Dec  4 00:41:19 janus kernel: iptables - ACTION=DROP IN=eth0 OUT= MAC=d4:3d:7e:f8:f4:57:cc:e1:7f:ac:7a:18:08:00 SRC=99.46.177.250 DST=148.251.14.68 LEN=40 TOS=0x02 PREC=0x00 TTL=50 ID=0 DF PROTO=TCP SPT=19219 DPT=993 WINDOW=0 RES=0x00 RST URGP=0
Dec  4 00:41:22 janus kernel: iptables - ACTION=outbound IN= OUT=eth0 SRC=148.251.14.68 DST=194.146.106.106 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=59545 DF PROTO=TCP SPT=43210 DPT=53 WINDOW=14600 RES=0x00 SYN URGP=0
Dec  4 00:41:22 janus kernel: iptables - ACTION=outbound IN= OUT=eth0 SRC=148.251.14.68 DST=74.54.97.59 LEN=68 TOS=0x00 PREC=0xC0 TTL=64 ID=51558 PROTO=ICMP TYPE=3 CODE=10 [SRC=74.54.97.59 DST=148.251.14.68 LEN=40 TOS=0x00 PREC=0x00 TTL=58 ID=13769 DF PROTO=TCP SPT=49602 DPT=993 WINDOW=29200 RES=0x00 SYN URGP=0 ]
EOF
    return @msgs;
}

=method contextualize_message

Parses the iptables log into structured data containing the keys:

    dev       => Physical interface
    src_mac   => Source MAC Address
    src_ip    => Source IP Address
    src_port  => Source Port
    dst_ip    => Destination IP Address
    dst_port  => Destination Port
    proto_app => Protocol
    in_bytes  => Bytes In
    out_bytes => Bytes Out

Tags messages with 'security' and 'firewall'

=cut

const my %map => qw(
    mac src_mac
    proto proto_app
    src src_ip
    dst dst_ip
    spt src_port
    dpt dst_port
    mac src_mac
);

sub contextualize_message {
    my ($self,$log) = @_;

    my ($content,$reference) = split /\[/, $log->context->{message};
    $reference =~ s/\s*\]$// if $reference;
    my %data = ();

    foreach my $token (split /\s+/, $content) {
        my ($k,$v) = split /=/, $token, 2;
        next unless defined $v && length $v;
        my $key = lc $k;
        $key = $map{$key} if exists $map{$key};
        $data{$key} = $v;
    }
    if( keys %data ) {
        my $dir = exists $data{in} ? 'in'
                : exists $data{out} ? 'out'
                : undef;
        if( $dir ) {
            $data{dev} = delete $data{$dir};
            $data{"${dir}_bytes"} = delete $data{len};
        }
        # Override the perceived program
        $data{program} = 'iptables';
        # Add our contextual data
        $log->add_context($self->name,\%data);
        $log->add_tags(qw(security firewall kernel));
    }
}

=head1 SEE ALSO

L<eris::log::contextualizer>, L<eris::role::context>

=cut

1;
