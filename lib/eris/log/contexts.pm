package eris::log::contexts;

use namespace::autoclean;
use Moose;
with qw(
    eris::role::pluggable
);

########################################################################
# Private Variables
my %_lookup = ();

########################################################################
# Attributes
has 'contexts' => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy => 1,
    builder => '_build_contexts',
);

########################################################################
# Builders
sub _build_namespace { 'eris::log::context' }

sub _build_contexts {
    my ($self) = @_;

    #foreach my $p (@{ $self->loader->plugins }) {
        #$_lookup{$p->field} ||= {};
    #}
    return [ $self->loader->plugins ];
}

########################################################################
# Methods
sub contextualize {
    my ($self,$log) = @_;

    foreach my $ctx (@{ $self->contexts }) {
        $ctx->contextualize_message($log);
    }

    $log;      # Return the log object
}

__PACKAGE__->meta->make_immutable;
1;
