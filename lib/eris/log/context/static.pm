package eris::log::context::static;
# ABSTRACT: Add static keys/values to every message

use Moo;
use Types::Standard qw(HashRef Maybe);
use namespace::autoclean;
with qw(
    eris::role::context
);

# VERSION

our $SuppressWarnings = 1;

=head1 SYNOPSIS

This context exists to statically add key/value pairs to every message.

=attr field

Set to C<*>

=cut

sub _build_field   { '*' }

=attr matcher

Set to C<*>

This combo causes this to match every message.

=cut

sub _build_matcher { '*' }

=attr fields

A HashRef of keys/values to add to every message. To configure:

    ---
    contexts:
      config:
        static:
          fields:
            dc: DCA1
            env: prod

=cut

has 'fields' => (
    is  => 'rw',
    isa => HashRef,
    default => sub { 'disable loading' },
);

=for Pod::Coverage sample_messages

=cut

sub sample_messages {
    my ($self) = @_;
    #$self->fields({ subject => 'testing', source => 'testing' });
    my @msgs = split /\r?\n/, <<'EOF';
Sep 10 19:59:05 ether sudo:     brad : TTY=pts/5 ; PWD=/home/brad ; USER=root ; COMMAND=/bin/grep -i sudo /var/log/secure
EOF
    return @msgs;
}

=method contextualize_message

If configured, this context just takes the fields specified in it's config and
adds those fields to every message.

=cut

sub contextualize_message {
    my ($self,$log) = @_;
    # Simply add the fields
    $log->add_context(static => $self->fields)
        if $self->fields;
}

=head1 SEE ALSO

L<eris::log::contextualizer>, L<eris::role::context>

=cut

1;
