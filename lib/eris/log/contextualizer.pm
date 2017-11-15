package eris::log::contextualizer;
# ABSTRACT: Primary interface to the eris log parsing library

use Moo;
use Time::HiRes qw(gettimeofday tv_interval);
use Types::Standard qw( HashRef InstanceOf );

use eris::log::contexts;
use eris::log::decoders;

use namespace::autoclean;

# VERSION

=head1 SYNOPSIS

This objects wraps the decoders and contexts to fully annotate an L<eris::log>
instance.

    use Data::Printer;
    use eris::contextualizer;

    my $ctxr = eris::contextualizer->new();

    while( <<>> ) {
        p( $ctxr->parse($_) )
    }

=attr config

The configuration as a hash reference.

A YAML Representation of the root namespaces for the configuration:

    ---
    contexts: {}
    decoders: {}
    schemas: {}

=cut

has config => (
    is       => 'ro',
    isa      => HashRef,
    default  => sub { +{} },
);


=attr contexts

An instance of an L<eris::log::contexts> object.  Passed
the configuration specified in the C<contexts> root key of
the config or an empty HashRef

=cut

has contexts => (
    is      => 'ro',
    isa     => InstanceOf['eris::log::contexts'],
    handles => [qw(contextualize)],
    lazy    => 1,
    builder => '_build_contexts',
);
sub _build_contexts {
    my $self = shift;
    return eris::log::contexts->new(
        %{ $self->config->{contexts} || {} },
    );
}

=attr decoders

An instance of an L<eris::log::decoders> object. Passed
the configuration specified in the C<decoders> root key of
the config or an empty HashRef

=cut

has 'decoders' => (
    is      => 'ro',
    isa     => InstanceOf['eris::log::decoders'],
    handles => [qw(decode)],
    lazy    => 1,
    builder => '_build_decoders',
    handles => [qw(decode)],
);
sub _build_decoders {
    my $self = shift;
    return eris::log::decoders->new(
        %{ $self->config->{decoders} || {} },
    );
}

=method parse

Takes a raw string.

Builds the list of decoders and contexts, passes the raw string to
the L<eris::log::decoders>, which returns an instance of an L<eris::log> object.

Then calls L<eris::log::contexts>, passing that L<eris::log> instance to each.

This method wraps this process w/timing data that's added with the
L<eris::log>'s C<add_timing> method.  This data is available when the
L<eris::dictionary::eris::debug> is enabled.  This can be helpful for examining
parser performance.

=cut

sub parse {
    my ($self,$raw) = @_;

    # Apply the decoders
    my %t=();
    my $t0 = [gettimeofday];
    my $log = $self->decode($raw);
    $log->add_context( raw => { raw => $raw } );
    my $tdiff = tv_interval($t0);
    $t{decoders} = $tdiff;

    # Add context
    my $t1 = [gettimeofday];
    $self->contextualize($log);
    my $t2 = [gettimeofday];

    # Record timings
    $t{contexts} = tv_interval( $t1, $t2 );
    $t{total}    = tv_interval( $t0, $t2 );
    $log->add_timing(%t);

    # Return the log created
    return $log;
}

=head1 SEE ALSO

L<eris::log>, L<eris::log::decoders>, L<eris::log::contexts>

=cut

1;
