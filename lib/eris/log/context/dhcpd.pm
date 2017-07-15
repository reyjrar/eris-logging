package eris::log::context::dhcpd;

use Const::Fast;
use Moo;
with qw(
    eris::role::context
);
use namespace::autoclean;

sub sample_messages {
    my @msgs = split /\r?\n/, <<'EOF';
Jul  4 17:06:58 10.0.1.1 dhcpd: DHCPDISCOVER from f0:f6:1c:b9:20:57 (Necktie) via igb1
Jul  4 17:06:58 10.0.1.1 dhcpd: DHCPOFFER on 10.0.1.33 to f0:f6:1c:b9:20:57 (Necktie) via igb1
Jul  4 17:06:59 10.0.1.1 dhcpd: DHCPREQUEST for 10.0.1.33 (10.0.1.1) from f0:f6:1c:b9:20:57 (Necktie) via igb1
Jul  4 17:06:59 10.0.1.1 dhcpd: DHCPACK on 10.0.1.33 to f0:f6:1c:b9:20:57 (Necktie) via igb1
EOF
    return @msgs;
}

sub contextualize_message {
    my ($self,$log) = @_;

    local $_ = $log->context->{message};
    my $matched =  /(?>(?<action>DHCPACK) on (?<src_ip>\S+) to (?<src_mac>\S+) (?:\((?<src>[^)]+)\) )?via (?<dev>\S+))/
                || /(?>(?<action>DHCPREQUEST) for (?<src_ip>\S+) (?:\([^)]+\) )?from (?<src_mac>\S+) (?:\((?<src>[^)]+)\) )?via (?<dev>\S+))/
                || /(?>(?<action>DHCPDISCOVER) from (?<src_mac>\S+) (?:\((?<src>[^)]+)\) )?via (?<dev>\S+))/
                || /(?>(?<action>DHCPOFFER) on (?<src_ip>\S+) to (?<src_mac>\S+) (?:\((?<src>[^)]+)\) )?via (?<dev>\S+))/
                || 0;
    if( $matched ) {
        $log->add_context($self->name,{%+});
        $log->add_tags(qw(inventory));
    }
}

1;
