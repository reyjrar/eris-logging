package eris::role::pluggable;

use Moose::Role;
use namespace::autoclean;
use Module::Pluggable::Object;

########################################################################
# Attributes
has namespace => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_build_namespace',
);
has search_path => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub { [] },
);
has disabled => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub { [] },
);
has 'loader' => (
    is => 'ro',
    isa => 'Module::Pluggable::Object',
    lazy => 1,
    builder => '_build_loader',
    handles => [qw(plugins)],
);

########################################################################
# Builders
sub _build_loader {
    my ($self) = @_;
    my $loader = Module::Pluggable::Object->new(
            search_path => [ $self->namespace, @{$self->search_path} ],
            except      => $self->disabled,
            instantiate => 'new',
    );
    return $loader;
}

1;
