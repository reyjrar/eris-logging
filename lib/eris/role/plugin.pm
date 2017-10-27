package eris::role::plugin;

use Moo::Role;
use Types::Standard qw(Bool Int Str);

########################################################################
# Attributes
has name => (
    is      => 'lazy',
    isa     => Str,
);

has 'priority' => (
    is      => 'lazy',
    isa     => Int,
);

has 'enabled' => (
    is => 'lazy',
    isa => Bool,
);

########################################################################
# Builders
sub _build_name     { ref $_[0] }
sub _build_priority { 50 }
sub _build_enabled  { 1 }

1;
