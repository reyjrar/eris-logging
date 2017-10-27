package eris::log;

use Hash::Merge::Simple qw(clone_merge);
use Moo;
use Types::Common::Numeric qw(PositiveNum);
use Types::Standard qw(ArrayRef HashRef Maybe Num Str);
use Ref::Util qw(is_hashref);

use namespace::autoclean;

has raw => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);
has decoded => (
    is      => 'rw',
    isa     => HashRef,
    lazy    => 1,
    default => sub { {} },
);
has context => (
    is      => 'rw',
    isa     => HashRef,
    lazy    => 1,
    default => sub { {} },
);
has complete => (
    is      => 'rw',
    isa     => HashRef[HashRef],
    lazy    => 1,
    default => sub { {} },
);
has timing => (
    is      => 'rw',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);
has tags => (
    is      => 'rw',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);
has total_time => (
    is  => 'rw',
    isa => Maybe[PositiveNum],
);

has 'epoch' => (
    is      => 'rw',
    isa     => Num,
    default => sub { time },
);
has 'type' => (
    is      => 'rw',
    isa     => Str,
    default => sub { 'log' },
);

has 'uuid' => (
    is  => 'rw',
    isa => Maybe[Str],
);

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
    push @{ $self->tags }, $name if $name ne 'raw';

    # Install the context
    $complete->{$name} = exists $complete->{$name} ? clone_merge( $complete->{$name}, $href ) : $href;

    # Check for UUID
    $self->uuid($href->{_id}) if exists $href->{_id};

    # Complete merge
    my $ctx = clone_merge( $self->context, $href );
    $self->context($ctx);
}

sub add_tags {
    my ($self,@tags) = @_;
    my %tags = map { $_ => 1 } @{ $self->tags };

    foreach my $t (@tags) {
        push @{ $self->tags }, $t unless exists $tags{$t};
        $tags{$t} = 1;
    }

    return $self;
}

sub add_timing {
    my ($self,%args) = @_;
    if( exists $args{total} ) {
        $self->total_time( delete $args{total} );
    }
    my $t = $self->timing;
    push @{ $t },
        map { +{ phase => $_, seconds => $args{$_} } }
        keys %args;
    return $self;
}

sub as_doc {
    my ($self,%args) = @_;

    # Default to just the context;
    my $doc = $args{complete} ? $self->complete : $self->context;
    $doc->{timing} = $self->timing;
    $doc->{tags}   = $self->tags;
    $doc->{total_time} = $self->total_time if $self->total_time;
    return $doc;
}
1;
