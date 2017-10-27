package eris::role::schema;

use JSON::MaybeXS;
use Moo::Role;
use POSIX qw(strftime);
use Types::Standard qw(Bool HashRef InstanceOf Int Str);
use namespace::autoclean;

########################################################################
# Interface
with qw(
    eris::role::plugin
);
requires qw( match_log );

########################################################################
# Attributes
has 'index_name' => (
    is => 'lazy',
    isa => Str,
);

has 'default_type' => (
    is => 'lazy',
    isa => Str,
);

has 'types' => (
    is => 'lazy',
    isa => HashRef,
);

has 'dictionary' => (
    is => 'lazy',
    isa => InstanceOf["eris::dictionary"],
);

has 'use_dictionary' => (
    is => 'lazy',
    isa => Bool,
);

has 'flatten' => (
    is => 'lazy',
    isa => Bool,
);

########################################################################
# Builders
sub _build_flatten        { 1 }
sub _build_use_dictionary { 1 }
sub _build_dictionary     { eris::dictionary->new() }
sub _build_default_type   { 'log' }

sub _build_index_name {
    my ($self) = @_;
    my $class = ref $self;

    if ( my ($short) = ($class =~ /::schema::(.*)$/) ) {
        return join '-', $short =~ s/::/_/gr, '%Y.%m.%d';
    }
    return;
}
sub _build_types {
    my $self = shift;
    return { $self->default_type => 1 };
}

########################################################################
# Methods
sub as_bulk {
    my ($self,$log) = @_;

    return sprintf "%s\n%s\n",
        map { encode_json($_) }
        {
            index => {
                _index => strftime($self->index_name, gmtime $log->epoch ),
                _type  => exists $self->types->{$log->type} ? $log->type : $self->default_type,
                $log->uuid ? ( _id => $log->uuid ) : (),
            }
        },
        $self->to_document( $log );
}

sub to_document {
    my ($self,$log) = @_;

    # Clone Context or Complete
    my $doc = $log->as_doc( complete => !$self->flatten );
    # Prune Keys using the dictionary
    if( $self->use_dictionary ) {
        foreach my $k ( keys %$doc ) {
            delete $doc->{$k} unless $self->dictionary->lookup( $k );
        }
    }
    return $doc;
}

1;
