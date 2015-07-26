package eris::role::context::simple;

use namespace::autoclean;
use Moose::Role;
extends 'eris::role::context';

########################################################################
# Interface

########################################################################
# Attributes
has 'target' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_build_target',
);

########################################################################
# By default, we look for program and default to use name, so
# if I want to write a context for sshd, I just need to create
# eris::log::context::sshd.
sub _build_field { 'program'; }
sub _build_target { $self->name; }

1;
