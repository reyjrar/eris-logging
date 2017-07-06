package eris::log::context::crond;

use Moo;
with qw(
    eris::role::context
);
use namespace::autoclean;

sub _build_matcher {
    [qw(crond cron CROND /usr/sbin/cron)]
}

sub sample_messages {
    my @msgs = split /\r?\n/, <<'EOF';
Nov 24 01:00:01 janus CROND[30472]: (root) CMD (/usr/lib64/sa/sa1 1 1)
Nov 24 01:01:01 janus CROND[30689]: (root) CMD (run-parts /etc/cron.hourly)
Nov 24 01:01:01 janus CROND[30690]: (root) CMD (/usr/local/bin/linux_basic_performance_data.sh)
EOF
    return @msgs;
}

sub contextualize_message {
    my ($self,$log) = @_;
    my $str = $log->context->{message};

    my %ctxt = ();
    if( $str =~ / CMD / ) {
        my @parts = map { s/^\(//; s/\)$//; $_ } split / CMD /, $str;
        $ctxt{src_user} = $parts[0];
        $ctxt{exe} = $parts[1];
        $ctxt{file} = (split /\s+/, $parts[1])[0];
        $ctxt{action} = 'exec';
    }

    $log->add_context($self->name,\%ctxt) if keys %ctxt;
}

1;
