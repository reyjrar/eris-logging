package eris::dictionary::eris::debug;
# ABSTRACT: Debugging data in the event

use Moo;
use namespace::autoclean;
with qw(
    eris::role::dictionary::hash
);

# VERSION

=head1 SYNOPSIS

Dictionary containing the timing and raw data.  Enable this dictionary on
a schema if you'd like to evaluate the parser performance.


=attr priority

Defaults to 100 to try to load last

=cut

sub _build_priority { 100 }

=attr enabled

Defaults to false, or disabled, set:

    ---
    dictionary:
      config:
        eris_debug: { enabled: 1 }

=cut

sub _build_enabled  { 0 }

=for Pod::Coverage hash

=cut

sub hash {
    return {
        eris_source  => {
            type => 'keyword',
            description => 'Where the eris system contextualized this message',
        },
        timing => {
            type => 'object',
            description => 'Timing details for each step of the parsing',
            properties => {
                phase => { type => 'keyword' },
                seconds => { type => 'float' },
            }
        },
        total_time => {
            type => 'double',
            description => 'Total time to construct the log message',
        },
    };
}

=head1 SEE ALSO

L<eris::dictionary>, L<eris::role::dictionary>

=cut

1;
