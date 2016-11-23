package eris::log::decoder::json;

use Const::Fast;
use JSON::MaybeXS;
use Moo;
use namespace::autoclean;

with qw(
    eris::role::decoder
);

sub _build_priority { 99; }

sub decode_message {
    my ($self,$msg) = @_;
    my $decoded;
    # JSON Docs will start with a '{', check for it.
    my $start = index($msg, '{');
    if( $start >= 0 ) {
        my $json_str = substr($msg, $start);
        eval {
            $decoded = decode_json( $json_str );
            1;
        };
    }
    return $decoded;
}

1;
