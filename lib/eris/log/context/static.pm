package eris::log::context::static;

use Moo;
use Types::Standard qw(HashRef Maybe);
use namespace::autoclean;

with qw(
    eris::role::context
);

our $SuppressWarnings = 1;
# Special Double Diamond Matcher
sub _build_field   { '*' }
sub _build_matcher { '*' }

has 'fields' => (
    is  => 'rw',
    isa => HashRef,
    #isa => Maybe[HashRef],
    default => sub { 'disable loading' },
);

sub sample_messages {
    my ($self) = @_;
    #$self->fields({ subject => 'testing', source => 'testing' });
    my @msgs = split /\r?\n/, <<'EOF';
Sep 10 19:59:05 ether sudo:     brad : TTY=pts/5 ; PWD=/home/brad ; USER=root ; COMMAND=/bin/grep -i sudo /var/log/secure
EOF
    return @msgs;
}

sub contextualize_message {
    my ($self,$log) = @_;
    # Simply add the fields
    $log->add_context(static => $self->fields)
        if $self->fields;
}

__PACKAGE__->meta->make_immutable;
