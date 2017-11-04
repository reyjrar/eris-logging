package eris::schemas;
# ABSTRACT: Discovery and access for schemas

use Moo;
with qw(
    eris::role::pluggable
);
use Types::Standard qw(HashRef);
use namespace::autoclean;

# VERSION

=head1 SYNOPSIS

    use eris::schemas;
    use eris::contextualizer;

    my $schm = eris::schemas->new();
    my $ctxr = eris::contextualizer->new();

    # Transform each line from STDIN or a file into bulk commands:
    while( <<>> ) {
        my $log = $ctxr->contextualize( $_ );
        print $schm->as_bulk($log);
    }

=cut


=attr namespace

Default namespace is 'eris::schema'

=cut

sub _build_namespace { 'eris::schema' }

=method find()

Takes an instance of an L<eris::log> you want to index into ElasticSearch.

Discover all possible, enabled schemas according to the C<search_path> as configured,
find all schemas matching the passed L<eris::log> object.

Returns a list

=cut

sub find {
    my ($self,$log) = @_;
    my @schemas = ();
    # Otherwise, find the schema's collecting this log
    foreach my $p (@{ $self->plugins }) {
        # Jump out as quickly as possible
        if( $p->match_log($log) ) {
            push @schemas, $p;
            last if $p->final;
        }
    }
    # Return our schemas
    return @schemas;
}

=method as_bulk()

Takes an instance of an L<eris::log> to index into ElasticSearch.

Using the C<find()> method, return a list of the commands necessary to
bulk index the instance of an L<eris::log> object as an array of new-line delimited
JSON.

=cut

sub as_bulk {
    my ($self,$log) = @_;
    # Find the matching schemas
    my @schemas = $self->find($log);
    # Return the bulk strings or the empty list
    return @schemas ? map { $_->as_bulk($log) } @schemas : ();
}

1;
