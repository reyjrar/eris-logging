package eris::log::context::postfix;

use Const::Fast;
use Moose;

use namespace::autoclean;
with qw(
    eris::role::context
);

sub sample_messages {
    my @msgs = split /\r?\n/, <<EOF;
EOF
    return @msgs;
}

sub contextualize_message {
    my ($self,$log) = @_;
    my $str = $log->context->{message};

    my %ctxt = ();
    if( defined $ctxt{status} ) {
    }
    else {
        delete $ctxt{status};
    }

    $log->add_context($self->name,\%ctxt);
}

__PACKAGE__->meta->make_immutable;
1;
