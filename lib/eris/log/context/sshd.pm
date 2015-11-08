package eris::log::context::sshd;

use Const::Fast;
use namespace::autoclean;

use Moose;
with qw(
    eris::role::context
);

sub sample_messages {
    my @msgs = split /\r?\n/, <<EOF;
Jul 26 15:47:32 ether sshd[30700]: Accepted password for canuck from 2.82.66.219 port 54085 ssh2
Jul 26 15:47:32 ether sshd[30700]: pam_unix(sshd:session): session opened for user canuck by (uid=0)
Jul 26 15:50:14 ether sshd[4291]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=43.229.53.60  user=root
Jul 26 15:50:16 ether sshd[4291]: Failed password for root from 43.229.53.60 port 57806 ssh2
Jul 26 15:50:18 ether sshd[4291]: Failed password for root from 43.229.53.60 port 57806 ssh2
Jul 26 15:50:21 ether sshd[4291]: Failed password for root from 43.229.53.60 port 57806 ssh2
Jul 26 15:50:21 ether sshd[4292]: Disconnecting: Too many authentication failures for root
Jul 26 15:50:21 ether sshd[4291]: PAM 2 more authentication failures; logname= uid=0 euid=0 tty=ssh ruser= rhost=43.229.53.60  user=root
Jul 26 15:50:22 ether sshd[4663]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=43.229.53.60  user=root
EOF
    return @msgs;
}

const my %RE => (
    extract_details => qr/(?:Accepted|Failed) (\S+) for (\S+) from (\S+) port (\S+) (\S+)/,
);
const my %F => (
    extract_details => [qw(driver acct src_ip src_port proto)],
);

sub contextualize_message {
    my ($self,$log) = @_;
    my $str = $log->context->{message};

    print "  + sshd is trying to decode: $str\n";

    my %ctxt = ();
    $ctxt{status} = index($str,'Accepted') >= 0 ? 'success'
                  : index($str,'Failed')   >= 0 ? 'failure'
                  : undef;
    if( defined $ctxt{status} ) {
        if( my @data = ($str =~ /$RE{extract_details}/o) ) {
            for(my $i=0; $i < @data; $i++) {
                $ctxt{$F{extract_details}->[$i]} = $data[$i];
            }
        }
    }
    else {
        delete $ctxt{status};
    }

    use Data::Dumper;
    print Dumper \%ctxt;
    $log->add_context($self->name,\%ctxt);
}

__PACKAGE__->meta->make_immutable;
1;
