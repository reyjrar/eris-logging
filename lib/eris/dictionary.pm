package eris::dictionary;

use namespace::autoclean;
use MooseX::Singleton;
with qw(
    eris::role::pluggable
);

########################################################################
# Attributes

########################################################################
# Builders
sub _build_namespace { 'eris::dictionary' }

########################################################################
# Methods
my %_dict = ();
sub lookup {
    my ($self,$field) = @_;
    return $_dict{$field} if exists $_dict{$field};

    # Otherwise, lookup
    my $entry;
    foreach my $p (sort { $a->priority <=> $b->priority } $self->loader->plugins ) {
        $entry = $p->lookup($field);
        last if defined $entry;
    }
    defined $entry ? $_dict{$field} = $entry : undef;  # Assignment carries Left to Right and is returned;
}

__PACKAGE__->meta->make_immutable;
1;
