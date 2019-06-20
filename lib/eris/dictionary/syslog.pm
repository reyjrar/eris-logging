package eris::dictionary::syslog;
# ABSTRACT: Contains fields extracted from syslog messages

use Moo;
use namespace::autoclean;
with qw(
    eris::role::dictionary::hash
);

# VERSION

=head1 SYNOPSIS

This dictionary contains elements extracted from the syslog header and
meta-data.


=attr priority

Defaults to 90, or towards the end.

=cut

sub _build_priority { 90; }

=for Pod::Coverage hash

=cut

my $_hash=undef;
sub hash {
    my $self = shift;
    return $_hash if defined $_hash;
    my %data;
    while(<DATA>) {
        chomp;
        my ($field,$def) = $self->expand_line($_);
        $data{$field} = $def;
    }
    $_hash = \%data;
}

=head1 SEE ALSO

L<eris::dictionary>, L<eris::role::dictionary>

=cut

1;
__DATA__
{ "name": "timestamp", "type": "date", "description": "The timestamp encoded in the message" }
{ "name": "message", "type": "text", "description": "Message contents, often truncated to relevance" }
severity Syslog severity of the message
facility Syslog facility of the message
program The program name or tag that generated the message
hostname The hostname as received by the syslog server
