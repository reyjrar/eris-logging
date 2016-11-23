package eris::dictionary;

use Moo;
with qw(
    eris::role::pluggable
    MooX::Singleton
);
use namespace::autoclean;

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
    foreach my $p (@{ $self->plugins }) {
        $entry = $p->lookup($field);
        last if defined $entry;
    }
    defined $entry ? $_dict{$field} = $entry : undef;  # Assignment carries Left to Right and is returned;
}

1;
