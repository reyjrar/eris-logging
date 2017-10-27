package eris::role::pluggable;

use List::Util qw(any);
use Moo::Role;
use Types::Standard qw(ArrayRef HashRef InstanceOf Str);
use namespace::autoclean;
use Module::Pluggable::Object;

########################################################################
# Attributes
has namespace => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    builder => '_build_namespace',
);
has search_path => (
    is      => 'ro',
    isa     => ArrayRef[Str],
    lazy    => 1,
    default => sub { [] },
);
has disabled => (
    is      => 'ro',
    isa     => ArrayRef[Str],
    lazy    => 1,
    default => sub { [] },
);
has 'loader' => (
    is      => 'ro',
    isa     => InstanceOf['Module::Pluggable::Object'],
    lazy    => 1,
    builder => '_build_loader',
);
has 'plugins' => (
    is => 'ro',
    isa => ArrayRef,
    lazy => 1,
    builder => '_build_plugins',
);
has 'plugins_config' => (
    is       => 'ro',
    isa      => HashRef,
    default  => sub {{}},
    init_arg => 'config',
);
########################################################################
# Builders
sub _build_loader {
    my ($self) = @_;
    my $loader = Module::Pluggable::Object->new(
        search_path => [ $self->namespace, @{$self->search_path} ],
        except      => $self->disabled,
        require     => 1,
    );
    return $loader;
}

sub _build_plugins {
    my $self = shift;
    my @plugins = ();

    # Make short hand configs possible
    my %config = ();
    my @search = grep { defined && length } ($self->namespace, @{ $self->search_path });
    foreach my $alias ( keys %{ $self->plugins_config } ) {
        # Copy into our local hash
        $config{$alias} = $self->plugins_config->{$alias};
        # If we find our search path as a prefix, skip
        next if any { /^$alias/ } @search;
        foreach my $prefix (@search) {
            my $class = join('::', $prefix, $alias);
            next if exists $config{$class};
            # Copy the config
            $config{$class} = $config{$alias};
        }
    }
    foreach my $class ( $self->loader->plugins ) {
        eval {
            my $opts = $config{$class} || {};
            push @plugins, $class->new(%{ $opts });
            1;
        } or do {
            my $err = $@;
            no strict 'refs';
            my $warn_var = sprintf '%s::SuppressWarnings', $class;
            my $suppress_warnings = eval "$$warn_var" || 0;
            warn $err unless $suppress_warnings;
        };
    }
    return [
        sort { $a->priority <=> $b->priority || $a->name cmp $b->name }
        grep { $_->enabled }
        @plugins
    ];
}
1;
