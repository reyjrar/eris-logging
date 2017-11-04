package eris::dictionary;
# ABSTRACT: Global Singleton dictionary object

use Moo;
with qw(
    MooX::Singleton
    eris::role::pluggable
);
use Types::Standard qw(HashRef);
use namespace::autoclean;

# VERSION

=head1 SYNOPSIS

    use eris::dictionary;
    use YAML;

    my $dict = eris::dictionary->new();

    while(<>) {
        chomp;
        foreach my $word (split /\s+/) {
            my $def = $dict->lookup($word);
            print Dump $def if $def;
        }
    }

=cut

=attr namespace

Defaults to C<eris::dictionary>

=cut

sub _build_namespace { 'eris::dictionary' }

=attr fields

HashRef of fields with true/false values indicated whether they exist in the dictionary.

=cut

has fields => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_fields',
);

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

=method lookup

Takes a field name, returns the entry for that field from
the first matching dictionary or undef if nothing is found

=cut

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

=head1 SEE ALSO

L<eris::role::dictionary>, L<eris::dictionary::cee>, L<eris::dictionary::eris>,
L<eris::dictionary::eris::debug>, L<eris::dictionary::syslog>

=cut

1;
