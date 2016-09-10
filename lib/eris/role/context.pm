package eris::role::context;

use Moose::Role;
use namespace::autoclean;

########################################################################
# Interface
requires qw(
    contextualize_message
    sample_messages
);

########################################################################
# Attributes
has name => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_name',
);
has 'field' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_field',
);
has 'matcher' => (
    is      => 'ro',
    isa     => 'Defined',
    lazy    => 1,
    builder => '_build_matcher',
);
has 'priority' => (
    is      => 'ro',
    isa     => 'Int',
    lazy    => 1,
    builder => '_build_priority',
);
########################################################################
# Select our config from the plugin config
around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my %args  = @_;

    my @try = ( $class, (split /::/, $class)[-1] );
    my %cfg = ();
    foreach my $try (@try) {
        print "Trying $try\n";
        if( exists $args{$try} ) {
            %cfg = %{ $args{$try} };
            last;
        }
    }

    $class->$orig(%cfg);
};
########################################################################
# Builders
sub _build_name {
    my ($self) = shift;
    my ($class) = ref $self;
    my @path = split /\:\:/, defined $class ? $class : '';

    die "Bad reference to eris::log::context $class" unless @path > 1;

    return $path[-1];
}
# By default, we look for program and default to use name, so
# if I want to write a context for sshd, I just need to create
# eris::log::context::sshd.
sub _build_priority { 50 }
sub _build_field { 'program'; }
sub _build_matcher { my ($self) = shift; $self->name; }

1;
