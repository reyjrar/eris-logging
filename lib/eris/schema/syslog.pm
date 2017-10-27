package eris::schema::syslog;

use Moo;
use eris::dictionary;
use Types::Standard qw(InstanceOf);

use namespace::autoclean;
with qw(
    eris::role::schema
);

# Match *EVERYTHING*
sub match_log { 1; }

1;
