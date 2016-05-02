package eris::log;

use Moose;
use namespace::autoclean;
use eris::dictionary;
use Hash::Merge::Simple qw(clone_merge);

has raw => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);
has decoded => (
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    default => sub { {} },
);
has context => (
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    default => sub { {} },
);
has complete => (
    is => 'rw',
    isa => 'HashRef[HashRef]',
    lazy => 1,
    default => sub { {} },
);
has timing => (
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    default => sub { {} },
);
has tags => (
    is => 'rw',
    isa => 'ArrayRef',
    lazy => 1,
    default => sub { [] },
);

my $dict;

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
    my $complete = $self->complete;

    unless( defined $href
            && ref $href
            && ref $href eq 'HASH'
            && scalar keys %$href
    ) {
        return;
    }

    # Tag the message
    push @{ $self->tags }, $name;

    # Install the context
    $complete->{$name} = $href;

    # Grab our dictionary
    $dict ||= eris::dictionary->new;

    # Complete merge
    my %ok = ();
    foreach my $k (keys %{ $href }) {
        my $entry = $dict->lookup($k);

        if( !defined $entry ) {
            print " Field[$k] is not defined in the dictionary.\n";
            next;
        }
        $ok{$k} = $href->{$k};
    }
    my $ctx = clone_merge( $self->context, \%ok );
    $self->context($ctx);
}

__PACKAGE__->meta->make_immutable;
1;
