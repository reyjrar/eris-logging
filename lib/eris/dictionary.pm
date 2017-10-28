package eris::dictionary;

use Moo;
with qw(
    MooX::Singleton
    eris::role::pluggable
);
use Types::Standard qw(HashRef);
use namespace::autoclean;

########################################################################
# Attributes
has fields => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_fields',
);

########################################################################
# Builders
sub _build_namespace { 'eris::dictionary' }
sub _build_fields {
    my ($self) = @_;

    my %complete = ();
    foreach my $p ( @{ $self->plugins } ) {
        foreach my $f ( @{ $p->fields } ) {
            if( exists $complete{$f} ) {
                warn sprintf "Duplicated field '%s' in dictionaies, %s authoratitive, %s conflicting.",
                    $f,
                    $complete{$f},
                    $p->name;
                    next;
            }
            $complete{$f} = $p->name;
        }
    }

    return \%complete;
}

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
