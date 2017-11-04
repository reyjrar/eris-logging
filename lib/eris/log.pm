package eris::log;
# ABSTRACT: Structured log or event object implementation

use Hash::Merge::Simple qw(clone_merge);
use Moo;
use Types::Common::Numeric qw(PositiveNum);
use Types::Standard qw(ArrayRef HashRef Maybe Num Str);
use Ref::Util qw(is_hashref);

use namespace::autoclean;

# VERSION

=head1 SYNOPSIS

=attr raw

The unstructured log or event as passed to the contextualizer.

=cut

has raw => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

=attr decoded

Hash of hashes built by the L<eris::log::decoders->decode()> step.

=cut

has decoded => (
    is      => 'rw',
    isa     => HashRef,
    lazy    => 1,
    default => sub { {} },
);

=attr context

Flattened hash built by the L<eris::log::contexts->contextualize> step.
Contexts are called in order by priority.  As each context runs, it's possible
to clobber the context key of a previous context.  This represents the final
state of the flattened namespace for the structured event.

=cut

has context => (
    is      => 'rw',
    isa     => HashRef,
    lazy    => 1,
    default => sub { {} },
);

=attr complete

Also populated by the L<eris::log::contexts->contextualize> step, but uses a
first level key of the context name to preserve where information orignated
and protect duplicate keys.

=cut

has complete => (
    is      => 'rw',
    isa     => HashRef[HashRef],
    lazy    => 1,
    default => sub { {} },
);

=attr timing

ArrayRef storing hash references representing the time each step of the
contextualizer took while turning the unstructured event into a structured
one.

    [
        { phase => 'context::sshd', seconds => 0.0003  },
    ]

Add new timings using the L<add_timings> method like:

    $log->add_timing( thing => 0.212 );

=cut

has timing => (
    is      => 'rw',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

=attr tags

ArrayRef of tags to index with the doc.  Add new tags with the L<add_tags>
method.

=cut

has tags => (
    is      => 'rw',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

=attr total_time

Stores the time the entire process took as a single element.

=cut

has total_time => (
    is  => 'rw',
    isa => Maybe[PositiveNum],
);

=attr epoch

B<Required>: The numeric representation of the time since the UNIX Epoch.  Can
be an integer or float.  This is required to index the log in the right time.

=cut

has 'epoch' => (
    is      => 'rw',
    isa     => Num,
    default => sub { time },
);

=attr type

Provided to override the type in the schema if being sent to Elasticsearch.

You probably shouldn't use this just set a default_type in your schema.
Elastic's official docs recommend a single type per index.

=cut

has 'type' => (
    is      => 'rw',
    isa     => Str,
    default => sub { 'log' },
);

=attr uuid

Optional GUID reperesentation.  If set will be passed along to Elasticsearch as
the document B<_id>, otherwise Elasticsearch will autogenerate it.

Unless you know what you're doing, you probably shouldn't set this in your
contexts or schemas.

=cut

has 'uuid' => (
    is  => 'rw',
    isa => Maybe[Str],
);

=method add_context

Takes two parameters: context name as a string, a hash reference containing the context to add

Use this to add add context data in your own L<eris::role::context> plugins:


    sub contextualize_message {
        my ($self,$log) = @_;

        $log->add_context( $self->name, { static_key => "static values are shocking" } )l
    }

=cut

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

=method add_tags

Takes a list of string tags to add to the object.  Deduplicates and adds new
tags to the object.

=cut

sub add_tags {
    my ($self,@tags) = @_;
    my %tags = map { $_ => 1 } @{ $self->tags };

    foreach my $t (@tags) {
        push @{ $self->tags }, $t unless exists $tags{$t};
        $tags{$t} = 1;
    }

    return $self;
}

=method add_timing

Takes a hash of timing data to add to the timing store.  This is called by the
L<eris::log::contexts>, L<eris::log::decoders>, and
L<eris::log::contextualizer> automatically.  You probably never need to call
this method yourself.

=cut

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

=method as_doc

Arguments parsed from a hash:

=over 2

=item B<complete>

Boolean, default false.  If set to true, the document is sourced for the
C<eris::log> complete event with the context namespaces as first level keys is
returned.  By default the C<eris::log> context hash is returned which is a
merged set of keys from all contexts.

=back

=cut

sub as_doc {
    my ($self,%args) = @_;

    # Default to just the context;
    my $doc = $args{complete} ? $self->complete : $self->context;
    $doc->{timing} = $self->timing;
    $doc->{tags}   = $self->tags;
    $doc->{total_time} = $self->total_time if $self->total_time;
    return $doc;
}

=head1 SEE ALSO

L<eris::log::contextualizer>, L<eris::log::decoders>, L<eris::log::contexts>

=cut

1;
