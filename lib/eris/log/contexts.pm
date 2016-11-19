package eris::log::contexts;

use List::Util qw(any);
use Moose;
use Ref::Util qw(is_ref is_arrayref is_coderef is_regexpref);
use Time::HiRes qw(gettimeofday tv_interval);
use namespace::autoclean;

with qw(
    eris::role::pluggable
);

########################################################################
# Attributes
has 'contexts' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    lazy    => 1,
    builder => '_build_contexts',
);
has 'plugins_config' => (
    is       => 'ro',
    isa      => 'HashRef',
    init_arg => 'plugins',
    default  => sub {{}},
);
########################################################################
# Builders
sub _build_namespace { 'eris::log::context' }

sub _build_contexts {
    my ($self) = @_;
    return [ sort { $a->priority <=> $b->priority || $a->name cmp $b->name } $self->loader->plugins( %{ $self->plugins_config } ) ];
}

########################################################################
# Methods
my $_lookup;
sub contextualize {
    my ($self,$log) = @_;

    my %t = ();
    foreach my $ctxt ( @{ $self->contexts } ) {
        my $field   = $ctxt->field;
        my $matcher = $ctxt->matcher;
        my $matched;
        # log context maybe updated
        my %c  = %{ $log->context };

        if( $field eq '_exists_' ) {
            # match against the key space
            if( !is_ref($matcher) ) {
                # simplest case string
                $matched = exists $c{$matcher};
            }
            elsif( is_regexpref($matcher) ) {
                # regexp match
                $matched = any { /$matcher/ } keys %c;
            }
            elsif( is_arrayref($matcher) ) {
                # list match
                $matched = any { exists $c{$_} } @{ $matcher };
            }
        }
        elsif( exists $c{$field} ) {
            if( !is_ref($matcher) ) {
                # Simplest case, we're a string
                $matched = $c{$field} eq $matcher;
            }
            elsif( is_regexpref($matcher) ) {
                # regexp match
                $matched = $c{$field} =~ /$matcher/;
            }
            elsif( is_arrayref($matcher) ) {
                # list match
                $matched = any { $c{$field} eq $_ } @{ $matcher };
            }
            elsif( is_coderef($matcher) ) {
                # call the code ref
                eval {
                    $matched = $matcher->( $c{$field} );
                    1;
                } or do {
                    # Catch an exception in the matcher
                    my $err = $@;
                    warn sprintf "[%s] matcher coderef died: %s",
                        $ctxt->name, $err;
                };
            }
        }

        if( $matched ) {
            my $t0 = [gettimeofday];
            $ctxt->contextualize_message($log);
            my $tdiff = tv_interval($t0);
            my $name = sprintf "context::%s", $ctxt->name;
            $t{$name} = $tdiff;
        }
    }

    # Record timing data
    $log->add_timing(%t);

    return $log;      # Return the log object
}

__PACKAGE__->meta->make_immutable;
1;
