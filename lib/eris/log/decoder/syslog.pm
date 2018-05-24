package eris::log::decoder::syslog;
# ABSTRACT: Parse the syslog headers using Parse::Syslog::Line

use Const::Fast;
use Moo;
use Parse::Syslog::Line;
use namespace::autoclean;

with qw(
    eris::role::decoder
);

# VERSION

=head1 SYNOPSIS

Uses L<Parse::Syslog::Line> to parse the raw string as if it were a message
streaming into a syslog server.  This helps capture the meta-data in the syslog
headers.

=cut

# Configure Parse::Syslog::Line
$Parse::Syslog::Line::AutoDetectKeyValues = 1;
$Parse::Syslog::Line::DateTimeCreate      = 0;
$Parse::Syslog::Line::EpochCreate         = 1;
$Parse::Syslog::Line::PruneRaw            = 1;
$Parse::Syslog::Line::PruneEmpty          = 1;
@Parse::Syslog::Line::PruneFields         = qw(
    date time date_str message offset
    preamble facility_int priority_int
);

=attr priority

Defaults to 100, or last.

=cut

sub _build_priority { 100; }

# Mappings we need to make
const my %MAP => (
    datetime_str => 'timestamp',
    domain       => 'domain',
    facility     => 'facility',
    host         => 'hostname',
    priority     => 'severity',
    program_name => 'program',
    program_pid  => 'proc_id',
    program_sub  => 'proc',
    content      => 'message',
);

=method decode_message

Takes a raw string, decodes that message using L<Parse::Syslog::Line> and then
remaps certain keys to "Common Event Expression" field names.

Stashes the decoded UNIX timestamp into the C<_epoch> key.

=cut

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
    return unless exists $decoded{epoch};
    # Stash this in a safe place
    $decoded{_epoch} = delete $decoded{epoch};

    return \%decoded;
}

=head1 SEE ALSO

L<eris::log::decoders>, L<eris::role::decoder>, L<Parse::Syslog::Line>

=cut

1;
