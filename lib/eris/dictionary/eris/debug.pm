package eris::dictionary::eris::debug;

use Moo;
use namespace::autoclean;
with qw(
    eris::role::dictionary::hash
);

sub _build_priority { 100 }
sub _build_enabled  { 0   }

sub hash {
    return {
        eris_source  => {
            type => 'keyword',
            description => 'Where the eris system contextualized this message',
        },
        timing => {
            type => 'object',
            description => 'Timing details for each step of the parsing',
        },
        total_time => {
            type => 'double',
            description => 'Total time to construct the log message',
        },
    };
}

1;
