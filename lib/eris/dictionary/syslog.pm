package eris::dictionary::syslog;

use namespace::autoclean;
use Moose;
with qw(
    eris::role::dictionary
);

has fields => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    builder => '_build_fields',
);

sub _build_priority { 100; }

sub _build_fields {
    my %fields = ();
    while(<DATA>) {
        chomp;
        my ($k,$v) = split /\s+/, $_;
        $fields{lc $k} = $v;
    }
    return \%fields;
}

__PACKAGE__->meta->make_immutable;
1;
__DATA__
source The source of the message
timestamp The timestamp encoded in the message
message Message contents, often truncated to relevance.
severity Syslog severity of the message
facility Syslog facility of the message
program The program name or tag that generated the message
