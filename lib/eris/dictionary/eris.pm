package eris::dictionary::eris;

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
eris_source Where the eris system contextualized this message
timestamp The timestamp encoded in the message
message Message contents, often truncated to relevance.
referer For web request, the Referrer, note, mispelled as in the RFC
sld Second-Level Domain, ie what you'd buy on a registrar
filetype File type or Extension
mimetype MIME Type of the file
time_ms Time in millis action took
response_ms For web requests, total time to send response
upstream_ms For web requests, total time to get response from upstream service
