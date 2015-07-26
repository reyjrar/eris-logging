package eris::log;

use Moose;
use namespace::autoclean;

has raw => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);
has decoded => {
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    default => sub { {} },
}
has context => {
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    default => sub { {} },
}
has context_full => {
    is => 'rw',
    isa => 'HashRef[HashRef]',
    lazy => 1,
    default => sub { {} },
}

sub set_decoded {
    my ($self,$name,$href) = @_;
    my $d = $self->decoded;

    # Store the results
    foreach my $k (keys %{ $href }) {
        $d->{$k} = $href->{$k};
    }
    $self->add_context( "decoder::" . $name, $href);
}

sub add_context {
    my ($self,$name,$href) = @_;
}

__PACKAGE__->meta->make_immutable;
1;
