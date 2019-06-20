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
    my $self = shift;
    return $_hash if defined $_hash;
    my %data;
    while(<DATA>) {
        chomp;
        my ($field,$def) = $self->expand_line($_);
        next unless $field;
        $data{$field} = $def;
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
{ "name": "time_ms", "type": "double", "description": "Time in millis action took" }
{ "name": "response_ms", "type": "double", "description": "For web requests, total time to send response" }
{ "name": "upstream_ms", "type": "double", "description": "For web requests, total time to get response from upstream service" }
src_user Source username
dst_user Destination username
{ "name": "src_geoip", "type": "object", "description": "GeoIP Data for the source IP", "properties": { "location": { "type": "geo_point" } } }
{ "name": "dst_geoip", "type": "object", "description": "GeoIP Data for the destination IP", "properties": { "location": { "type": "geo_point" } } }
{ "name": "attacks", "type": "object", "enabled": false, "description": "Attacks root node" }
{ "name": "attack_score", "type": "integer", "description": "Total score of all attack detection checks" }
attack_tokens Unique tokens identified in the attack scoring process
attack_types Type of attacks detected
name Name of the event
class Class of the event
