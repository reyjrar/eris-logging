package eris::log::contextualizer;

use Moose;
use Time::HiRes qw(gettimeofday tv_interval);

use eris::base::types;
use eris::log::contexts;
use eris::log::decoders;
use eris::dictionary;

use namespace::autoclean;

########################################################################
# Attributes
has config => (
    is       => 'ro',
    isa      => 'eris::type::config',
    required => 1,
    coerce   => 1,
);
has contexts => (
    is      => 'ro',
    isa     => 'eris::log::contexts',
    handles => [qw(contextualize)],
    lazy    => 1,
    builder => '_build_contexts',
);
has 'decoders' => (
    is      => 'ro',
    isa     => 'eris::log::decoders',
    handles => [qw(decode)],
    lazy    => 1,
    builder => '_build_decoders',
    handles => [qw(decode)],
);
has 'dictionary' => (
    is      => 'ro',
    isa     => 'eris::dictionary',
    lazy    => 1,
    builder => '_build_dictionary',
);

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
sub _build_dictionary {
    my $self = shift;
    return eris::log::dictionary->new(
        %{ $self->config->{dictionary} },
    );
}
########################################################################
# Methods
sub parse {
    my ($self,$raw) = @_;

    # Apply the decoders
    my $t0 = [gettimeofday];
    my $log = $self->decode($raw);
    my $tdiff = tv_interval($t0);
    $log->timing->{decoders} = $tdiff;

    # Add context
    $t0 = [gettimeofday];
    $self->contextualize($log);
    $tdiff = tv_interval($t0);
    $log->timing->{contexts} = $tdiff;

    # Return the log created
    $log;
}


__PACKAGE__->meta->make_immutable;
1;
