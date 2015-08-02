package eris::log::decoder::json;

use Const::Fast;
use namespace::autoclean;
use JSON::XS;

use Moose;
with qw(
    eris::role::decoder
);

sub _build_priority { 99; }

# Mappings we need to make
const my %MAP => (
);

sub decode_message {
    my ($self,$msg) = @_;
    my %decoded = ();
    # JSON Docs will start with a '{', check for it.
    my $start = index($msg, '{');
    if( $start >= 0 ) {
        my $json_str = substr($msg, $start);
        eval {
            my $m = decode_json( $json_str );
            die unless defined $m;

            $decoded{content} //= $json_str;
            foreach my $k ( keys %{ $m } ) {
                # Skip empty values
                next unless defined $m->{$k} && length $m->{$k};
                my $dk = exists $MAP{$k} ? $MAP{$k} : lc $k;
                $decoded{$dk} = $m->{$k};
            }
            1;
        }
    }

    keys %decoded ? \%decoded : undef; # Return Decoded
}

__PACKAGE__->meta->make_immutable;
1;
