package eris::role::plugin;

use Moo::Role;
use Types::Standard qw(Int Str);

########################################################################
# Attributes
has name => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    builder => '_build_name',
);
has 'priority' => (
    is      => 'ro',
    isa     => Int,
    lazy    => 1,
    builder => '_build_priority',
);

########################################################################
# Builders
sub _build_name     { ref $_[0] }
sub _build_priority { 50 }

1;
