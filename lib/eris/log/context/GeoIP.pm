package eris::log::context::GeoIP;

use Const::Fast;
use GeoIP2::Database::Reader;
use Moose;

use namespace::autoclean;
with qw(
    eris::role::context
);

has 'geo_db' => (
    is      => 'ro',
    isa     => 'Str',
    default => '/tmp/GeoLite2-City.mmdb',
);
has 'geo_lookup' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_geo_lookup',
);
has 'warnings' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

# Config this object
sub _build_priority { 100 }
sub _build_field { '_exists_' }
sub _build_matcher { qr/_ip$/ }
sub _build_geo_lookup {
    my ($self) = @_;

    my $g;
    eval {
        $g = GeoIP2::Database::Reader->new(
            file => $self->geo_db,
            locales => [ 'en' ],
        );
        1;
    } or do {
        my $err = $@;
        warn sprintf "Failed loading GeoIP Database '%s' with error: %s",
            $self->geo_db,
            $err;
    };
    return $g;
}

sub sample_messages {
    my @msgs = split /\r?\n/, <<EOF;
EOF
    return @msgs;
}

sub contextualize_message {
    my ($self,$log) = @_;

    my $geo = $self->geo_lookup;
    return unless $geo;

    my %add = ();
    my $ctxt = $log->context;

    foreach my $f ( grep /_ip$/, keys %{ $ctxt } ) {
        eval {
            my $city = $self->geo_lookup->city( ip => $ctxt->{$f} );
            $add{"${f}_city"}  = $city->city->name;
            $add{"${f}_country"}  = $city->country->iso_code;
            my $loc = $city->location();
            $add{"${f}_location"} = join(',', $loc->latitude, $loc->longitude);
        } or do {
            my $err = $@;
            warn sprintf "Geo lookup failed on %s: %s", $ctxt->{$f}, $err;
        };
    }

    $log->add_context($self->name,\%add) if keys %add;
}

__PACKAGE__->meta->make_immutable;
1;
