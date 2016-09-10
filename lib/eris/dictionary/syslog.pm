package eris::dictionary::syslog;

use Moose;
use namespace::autoclean;
with qw(
    eris::role::dictionary
    eris::role::dictionary::hash
);
sub _build_priority { 100; }
my $_hash=undef;
sub hash {
    return $_hash if defined $_hash;
    my %data;
    while(<DATA>) {
        chomp;
        my ($k,$desc) = split /\s+/, $_, 2;
        $data{lc $k} = $desc;
    }
    $_hash = \%data;
}
__PACKAGE__->meta->make_immutable;
1;
__DATA__
source The source of the message
timestamp The timestamp encoded in the message
message Message contents, often truncated to relevance
severity Syslog severity of the message
facility Syslog facility of the message
program The program name or tag that generated the message
hostname The hostname as received by the syslog server
