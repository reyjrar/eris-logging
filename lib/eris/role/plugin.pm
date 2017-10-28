package eris::role::plugin;
# ABSTRACT: Common interface for implementing an eris plugin

=head1 SYNOPSIS

Sprinkled into other plugins in the eris project to set
expectatations for the plugin loaders


    package eris::role::context;

    use Moo::Role;
    with qw( eris::role::plugin );

=cut

use Moo::Role;
use Types::Standard qw(Bool Int Str);

=attr name

The name of the plugin.  Defaults to stripping the plugin namespace from the
object's class name and replacing '::' withn an underscore.

=cut

has name => (
    is  => 'lazy',
    isa => Str,
);

sub _build_name {
    my ($self) = @_;
    my ($class) = ref $self;
    my ($namespace) = $self->namespace;
    # Trim Name Space
    my $name = $class =~ s/^${namsspace}:://r;

    # Replace colons with underscores
    return $name =~ s/::/_/gr;
}

=attr priority

An integer representing the priority ordering of the plugin in loading, lower
priority will appear in the beginning of the plugins list. Defaults to 50.

=cut

has 'priority' => (
    is  => 'lazy',
    isa => Int,
);
sub _build_priority  { 50 }

=attr enabled

Boolean indicating if the plugin is enabled by default.  Defaults
to true.  The L<eris::dictionary::eris::debug> uses this set to false
to prevent it's data from accidentally entering the default schemas.

=cut

has 'enabled' => (
    is => 'lazy',
    isa => Bool,
);
sub _build_enabled   { 1 }

=attr namespace

The primary namespace for these plugins.  This is used to auto_trim it from the
plugin's name for simpler config templates.

This is a B<required> parameter.

=cut

has 'namespace' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

=head1 SEE ALSO

L<eris::role::pluggable>, L<eris::role::context>, L<eris::role::decoder>, L<eris::role::dictionary>
L<eris::role::schema>

=cut

1;
