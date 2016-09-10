package eris::log::decoder::syslog;

use Const::Fast;
use Moose;
use Parse::Syslog::Line;

use namespace::autoclean;

with qw(
    eris::role::decoder
);

# Configure Parse::Syslog::Line
$Parse::Syslog::Line::DateTimeCreate = 0;
$Parse::Syslog::Line::EpochCreate    = 1;
$Parse::Syslog::Line::PruneRaw       = 1;
$Parse::Syslog::Line::PruneEmpty     = 1;
@Parse::Syslog::Line::PruneFields    = qw(
    date time date_str message
    preamble facility_int priority_int
);

sub _build_priority { 100; }

# Mappings we need to make
const my %MAP => (
    datetime_str => 'timestamp',
    domain       => 'domain',
    facility     => 'facility',
    host         => 'hostname',
    priority     => 'severity',
    program_name => 'program',
    program_pid  => 'pid',
    content      => 'message',
);

sub decode_message {
    my ($self,$msg) = @_;
    my %decoded = ();
    eval {
        my $m = parse_syslog_line($msg);
        if(defined $m && ref $m) {
            foreach my $k (keys %{ $m }) {
                my $dk = exists $MAP{$k} ? $MAP{$k} : lc $k;
                $decoded{$dk} = $m->{$k};
            }
        }
    };

    keys %decoded ? \%decoded : undef;   #Return the Decoded Content
}

__PACKAGE__->meta->make_immutable;
1;
