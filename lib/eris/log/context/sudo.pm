package eris::log::context::sudo;

use Const::Fast;
use Moo;
with qw(
    eris::role::context
);
use namespace::autoclean;

const my %MAP => (
    TTY     => 'dev',
    COMMAND => 'exe',
    PWD     => 'location',
    USER    => 'dst_user',
);

sub sample_messages {
    my @msgs = split /\r?\n/, <<'EOF';
Sep 10 19:59:02 ether sudo:     brad : TTY=pts/5 ; PWD=/home/brad ; USER=root ; COMMAND=/bin/grep -i sudo /var/log/messages
Sep 10 19:59:05 ether sudo:     brad : TTY=pts/5 ; PWD=/home/brad ; USER=root ; COMMAND=/bin/grep -i sudo /var/log/secure
EOF
    return @msgs;
}

sub contextualize_message {
    my ($self,$log) = @_;
    my $str = $log->context->{message};

    my %ctxt = ();

    my ($user,$variables) = split ' : ', $str, 2;
    if( defined $variables ) {
        chomp($variables);
        foreach my $pair (split ' ; ', $variables) {
            my ($k,$v) = split '=', $pair;
            if(exists $MAP{$k}) {
                $ctxt{$MAP{$k}} = $v;
            }
        }
    }
    if( exists $ctxt{exe} ) {
        $ctxt{file} = (split /\s+/, $ctxt{exe})[0];
        $ctxt{action} = 'execute';
    }
    $ctxt{src_user} = $user if $user;

    $log->add_context($self->name,\%ctxt) if keys %ctxt;
}

1;
