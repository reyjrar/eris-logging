package eris::dictionary::eris;
# ABSTRACT: Contains fields eris adds to events

use Moo;
use namespace::autoclean;
with qw(
    eris::role::dictionary::hash
);

# VERSION

=head1 SYNOPSIS

This dictionary adds fields the L<eris::log::contextualizer> may add to a document.

=attr priority

Defaults to 100, or near the end

=cut

sub _build_priority { 100; }

=for Pod::Coverage hash

=cut

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

=head1 SEE ALSO

L<eris::dictionary>, L<eris::role::dictionary>

=cut

1;
__DATA__
referer For web request, the Referrer, note, mispelled as in the RFC
sld Second-Level Domain, ie what you'd buy on a registrar
filetype File type or Extension
mimetype MIME Type of the file
time_ms Time in millis action took
response_ms For web requests, total time to send response
upstream_ms For web requests, total time to get response from upstream service
src_user Source username
dst_user Destination username
src_geoip GeoIP Data for the source IP
dst_geoip GeoIP Data for the destination IP
attacks Attacks root node
attack_score Total score of all attack detection checks
attack_triggers Total unique instances of tokens tripping attack checks
name Name of the event
class Class of the event
