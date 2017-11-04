package eris::log::context::crond;
# ABSTRACT: Parse crond messages to structured data

use Moo;
with qw(
    eris::role::context
);
use namespace::autoclean;

# VERSION

=head1 SYNOPSIS

Parses the crond execution log file entries into structured data

=attr matcher

Matches 'cron', 'CROND', '/usr/sbin/cron'

=cut

sub _build_matcher {
    [qw(crond cron CROND /usr/sbin/cron)]
}

=for Pod::Coverage sample_messages

=cut

sub sample_messages {
    my @msgs = split /\r?\n/, <<'EOF';
Nov 24 01:00:01 janus CROND[30472]: (root) CMD (/usr/lib64/sa/sa1 1 1)
Nov 24 01:01:01 janus CROND[30689]: (root) CMD (run-parts /etc/cron.hourly)
Nov 24 01:01:01 janus CROND[30690]: (root) CMD (/usr/local/bin/linux_basic_performance_data.sh)
EOF
    return @msgs;
}

=method contextualize_message

Parses the crond log messages specifying what was run into:

    src_user => User executing
    exe      => Full command as run by cron
    file     => Just the executeable without arguments

=cut

sub contextualize_message {
    my ($self,$log) = @_;
    my $str = $log->context->{message};

    my %ctxt = ();
    if( $str =~ / CMD / ) {
        my @parts = map { s/(?:^\()|(?:\)$)//rg } split / CMD /, $str;
        $ctxt{src_user} = $parts[0];
        $ctxt{exe} = $parts[1];
        $ctxt{file} = (split /\s+/, $parts[1])[0];
        $ctxt{action} = 'execute';
    }

    $log->add_context($self->name,\%ctxt) if keys %ctxt;
}

=head1 SEE ALSO

L<eris::log::contextualizer>, L<eris::role::context>

=cut

1;
