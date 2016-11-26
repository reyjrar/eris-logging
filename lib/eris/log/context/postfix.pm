package eris::log::context::postfix;

use Const::Fast;
use Moo;
use namespace::autoclean;

with qw(
    eris::role::context
);

sub _build_matcher { qr/^postfix/ }

# Constants
const my %MAP => qw(
    from src
    size in_bytes
);

sub sample_messages {
    my @msgs = split /\r?\n/, <<'EOF';
Nov 20 04:22:13 janus postfix/smtpd[19324]: connect from mailer28.promotebusiness.gr[62.38.238.232]
Nov 20 04:22:15 janus postfix/smtpd[19324]: NOQUEUE: reject: RCPT from mailer28.promotebusiness.gr[62.38.238.232]: 450 4.2.0 <brad@divisionbyzero.net>: Recipient address rejected: Greylisted, see http://postgrey.schweikert.ch/help/divisionbyzero.net.html; from=<newsletter@e-telekat.net> to=<brad@divisionbyzero.net> proto=ESMTP helo=<mailer28.promotebusiness.gr>
Nov 20 04:22:15 janus postfix/smtpd[19324]: disconnect from mailer28.promotebusiness.gr[62.38.238.232]
Nov 20 04:25:35 janus postfix/anvil[18199]: statistics: max connection rate 2/60s for (smtp:2600:3c03::f03c:91ff:fe93:c5e8) at Nov 20 04:19:15
Nov 20 04:25:35 janus postfix/anvil[18199]: statistics: max connection count 1 for (smtp:2600:3c03::f03c:91ff:fe93:c5e8) at Nov 20 04:19:14
Nov 20 04:25:35 janus postfix/anvil[18199]: statistics: max cache size 1 at Nov 20 04:19:14
Nov 20 04:28:22 janus postfix/smtpd[20365]: connect from mail.astelecom.ru[83.142.9.162]
Nov 20 04:28:22 janus postfix/smtpd[20365]: NOQUEUE: reject: RCPT from mail.astelecom.ru[83.142.9.162]: 450 4.1.8 <payments@ustreasury.gov>: Sender address rejected: Domain not found; from=<payments@ustreasury.gov> to=<brad@divisionbyzero.net> proto=ESMTP helo=<mail.astelecom.ru>
Nov 20 04:28:22 janus postfix/smtpd[20365]: disconnect from mail.astelecom.ru[83.142.9.162]
Nov 20 04:29:10 janus postfix/smtpd[20365]: connect from unknown[198.52.131.89]
Nov 20 04:29:11 janus postfix/smtpd[20365]: NOQUEUE: reject_warning: RCPT from unknown[198.52.131.89]: 450 4.7.1 Client host rejected: cannot find your reverse hostname, [198.52.131.89]; from=<Christie.Brinkley.Skincare@grieving.thoweam.top> to=<brad@divisionbyzero.net> proto=ESMTP helo=<grieving.thoweam.top>
Nov 20 04:29:12 janus postfix/smtpd[20365]: NOQUEUE: reject: RCPT from unknown[198.52.131.89]: 554 5.7.1 Service unavailable; Client host [198.52.131.89] blocked using zen.spamhaus.org; https://www.spamhaus.org/sbl/query/SBLCSS; from=<Christie.Brinkley.Skincare@grieving.thoweam.top> to=<brad@divisionbyzero.net> proto=ESMTP helo=<grieving.thoweam.top>
Nov 20 04:29:12 janus postfix/smtpd[20365]: disconnect from unknown[198.52.131.89]
Nov 20 06:44:57 janus postfix/smtpd[15590]: connect from localhost[127.0.0.1]
Nov 20 06:44:57 janus postfix/smtpd[15590]: NOQUEUE: reject_warning: RCPT from localhost[127.0.0.1]: 450 4.7.1 <notify.ossec.net>: Helo command rejected: Host not found; from=<ossec@divisionbyzero.net> to=<security@db0.us> proto=SMTP helo=<notify.ossec.net>
Nov 20 06:44:57 janus postfix/smtpd[15590]: A2FE829C1076: client=localhost[127.0.0.1]
Nov 20 06:44:57 janus postfix/cleanup[15611]: A2FE829C1076: message-id=<20161120054457.A2FE829C1076@janus.divisionbyzero.net>
Nov 20 06:44:57 janus opendkim[1390]: A2FE829C1076: DKIM-Signature field added (s=default, d=divisionbyzero.net)
Nov 20 06:44:57 janus postfix/qmgr[13857]: A2FE829C1076: from=<ossec@divisionbyzero.net>, size=1584, nrcpt=1 (queue active)
Nov 20 06:44:57 janus postfix/smtpd[15590]: disconnect from localhost[127.0.0.1]
EOF
    return @msgs;
}

sub contextualize_message {
    my ($self,$log) = @_;
    my $str = $log->context->{message};

    my %ctxt = ();

    my @path = split /\//, $log->context->{program};
    shift @path;
    if( @path ) {
        $ctxt{proc} = join('_', @path);
    }

    if( my @connection = ($str =~ /^((?:dis)?connect) from ([^\[]+)\[([^\]]+)\]/) ) {
        @ctxt{qw(action src src_ip)} = @connection;
    }
    elsif( my @details = ($str =~ /^([A-F0-9]{8,16}): (.*)$/) ) {
        $ctxt{rec_id} = $details[0];
        foreach my $kv ( split /, /, $details[1] ) {
            my ($k,$v) = ($kv =~ /(\w+)=<?([^>]+)>?/);
            $ctxt{$MAP{$k}} = $v if exists $MAP{$k};
        }
    }
    else {
        # Last ditch effort to grab information
        if( my @conn = ($str =~ / (from|to) ([^\[]+)\[([^\]]+)\]/) ) {
            my @fields = shift @conn eq 'from' ? qw(src src_ip) : qw(dst dst_ip);
            @ctxt{@fields} = @conn;
        }
    }

    $log->add_context($self->name,\%ctxt);
}

1;
