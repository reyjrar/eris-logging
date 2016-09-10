package eris::log;

use Hash::Merge::Simple qw(clone_merge);
use Moose;
use Ref::Util qw(is_hashref);

use eris::dictionary;

use namespace::autoclean;

has raw => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);
has decoded => (
    is      => 'rw',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { {} },
);
has context => (
    is      => 'rw',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { {} },
);
has complete => (
    is      => 'rw',
    isa     => 'HashRef[HashRef]',
    lazy    => 1,
    default => sub { {} },
);
has timing => (
    is      => 'rw',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { {} },
);
has tags => (
    is      => 'rw',
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub { [] },
);

my $dict;

sub set_decoded {
    my ($self,$name,$href) = @_;
    my $d = $self->decoded;

    return unless is_hashref($href);

    # Store the results
    foreach my $k (keys %{ $href }) {
        $d->{$k} = $href->{$k};
    }
    $self->add_context( "decoder::" . $name, $href);
}

{
    my %in_dict = ();
    sub add_context {
        my ($self,$name,$href) = @_;
        my $complete = $self->complete;

        unless( defined $href
                && is_hashref($href)
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
            if( !exists $in_dict{$k} ) {
                $in_dict{$k} = $dict->lookup($k);
            }
            next unless $in_dict{$k};

            $ok{$k} = $href->{$k};
        }
        my $ctx = clone_merge( $self->context, \%ok );
        $self->context($ctx);
    }
}
__PACKAGE__->meta->make_immutable;
1;
