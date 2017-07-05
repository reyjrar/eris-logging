package eris::log::context::pfSense::filterlog;

use Moo;
with qw(
    eris::role::context
);
use Text::CSV_XS;
use Types::Standard qw(InstanceOf);
use namespace::autoclean;

has 'parser' => (
    is      => 'ro',
    isa     => InstanceOf['Text::CSV_XS'],
    lazy    => 1,
    builder => '_build_parser',
    handles => {
        csv_parse  => 'parse',
        csv_fields => 'fields',
    },
);
sub _build_parser {
    return Text::CSV_XS->new();
}

sub _build_matcher { 'filterlog' }

sub sample_messages {
    my @msgs = split /\r?\n/, <<'EOF';
2017-07-05T03:39:15+02:00 pfsense.home.db0.us filterlog: 99,16777216,,1770009028,igb1,match,pass,in,4,0x0,,64,55471,0,DF,17,udp,67,10.0.1.10,10.0.1.1,53515,53,47
2017-07-05T03:40:01+02:00 pfsense.home.db0.us filterlog: 5,16777216,,1000000103,igb0,match,block,in,4,0x0,,114,31734,0,none,17,udp,145,87.110.147.77,99.46.177.250,1024,26818,125
2017-07-05T03:40:38+02:00 pfsense.home.db0.us filterlog: 57,16777216,,11000,igb0,match,block,in,6,0x00,0x00000,64,UDP,17,158,fe80::de7f:a4ff:fe04:bac9,fe80::208:a2ff:fe0b:76ac,41442,546,158
EOF
    return @msgs;
}

my %fields;

sub contextualize_message {
    my ($self,$log) = @_;
    my $str = $log->context->{message};

    %fields = (
        base => [qw( rule_id subrule_id anchor rec_id dev proc action direction ipver )],
        ipv4 => [qw( TOS ECN TTL id offset flags proto_id proto )],
        ipv6 => [qw( class label TTL proto_app proto_id )],
        ip   => [qw(length src_ip dst_ip)],
        tcp_or_udp => [qw(src_port dst_port proto_bytes)],
    ) unless keys %fields;

    eval {
        $self->csv_parse($str);
    };

    my @fields = $self->csv_fields;
    if( @fields > @{ $fields{base} } ) {
        my %ctxt = ( service => 'firewall' );
        $log->add_tags('pfSense');
        @ctxt{@{ $fields{base} }} = splice @fields, 0, scalar(@{ $fields{base} });
        my $ipv = sprintf "ipv%d", $ctxt{ipver} || 0;
        if ( exists $fields{$ipv} ) {
            @ctxt{@{ $fields{$ipv} }} = splice @fields, 0, scalar(@{ $fields{$ipv} });
            @ctxt{ @{ $fields{ip} } } = splice @fields, 0, scalar(@{ $fields{ip} });
            if( $ctxt{proto_app} ) {
                $ctxt{proto_app} = lc $ctxt{proto_app};
                if( ( $ctxt{proto_app} eq 'udp' || $ctxt{proto_app} eq 'tcp' ) ) {
                    @ctxt{ @{ $fields{tcp_or_udp} } } = splice @fields, 0, scalar(@{ $fields{tcp_or_udp} });
                }
            }
            if( $ctxt{direction} and $ctxt{length} ) {
                $ctxt{"$ctxt{direction}_bytes"} = $ctxt{length};
            }
        }
        $log->add_context($self->name,\%ctxt);
    }
}

1;

