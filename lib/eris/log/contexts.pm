package eris::log::contexts;

use eris::dictionaries;
use namespace::autoclean;
use Moose;
with qw(
    eris::base::role::pluggable
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
sub _build_namespace { 'eris::log::context' };

sub _build_contexts {
    my ($self) = @_;
    foreach my $p (@{ $self->loader->plugins }) {
        $_lookups{$p->field} ||= {};
    }
}

########################################################################
# Methods
sub contextualize {
    my ($self,$log) = @_;

    #foreach my $decoder (@{ $self->decoders }) {
    #    my $data = $decoder->decode($raw);
    #
    #    if( defined $data && ref $data eq 'HASH' ) {
    #        $log->set_decoded($decoder->name => $data);
    #    }
    #}

    $log;      # Return the log object
}

__PACKAGE__->meta->make_immutable;
1;
