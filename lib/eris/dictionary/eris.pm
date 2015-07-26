package eris::dictionary::eris;

use namespace::autoclean;
use Moose;
with qw(
    eris::dictionary
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
message Message contents, often truncated to relevance.
referer For web request, the Referrer, note, mispelled as in the RFC
sld Second-Level Domain, ie what you'd buy on a registrar
filetype File type or Extension
mime_type MIME Type of the file
time_ms Time in millis action took
response_ms For web requests, total time to send response
upstream_ms For web requests, total time to get response from upstream service
