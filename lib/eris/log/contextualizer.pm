package eris::log::contextualizer;

use eris::base::types;

use Moose;
use namespace::autoclean;
use YAML;

########################################################################
# Attributes
has config => (
    is => 'ro',
    isa => 'eris::type::config',
    required => 1,
    coerce => 1,
);
has contexts => (
    is => 'ro',
    isa => 'eris::log::contexts',
    handles => [qw(contextualize)],
    lazy => 1,
    builder => '_build_contexts',
);
has 'decoders' => {
    is => 'ro',
    isa => 'eris::log::decoders',
    handles => [qw(decode)],
    lazy => 1,
    builder => '_build_decoders',
    handles => [qw(decode)],
}

########################################################################
# Builders
sub _build_decoders {
    my $self = shift;

    return eris::log::decoders->new(
        %{ $self->config->{decoder} },
    );
}
sub _build_contexts {
    my $self = shift;

    return eris::log::contexts->new(
        %{ $self->config->{context} },
    );
}
########################################################################
# Methods
sub parse {
    my ($self,$raw) = @_;

    # Apply the decoders
    my $log = $self->decode($raw);

    # Add context
    $self->contextualize($log);

    # Return the log created
    $log;
}


__PACKAGE__->meta->make_immutable;
1;
