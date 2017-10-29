# ABSTRACT: Eris is the Greek Goddess of Chaos
use strict;
use warnings;
package eris;

our $VERSION = 0.001;

1;
__END__
=pod

=head1 SYNOPSIS

eris exists to transform unstructuted, chaotic log data into structured messages.

Born out of disappointment and regret of existing solutions like Logstash,
fluentd, and their kind, eris aims to make development and debugging of
parsers easy and transparent. The goal is to provide a config that be used to
to index logging data into Elasticsearch while being flexible enough to work
with log files on the system.  This makes it friendly to approach from a
maintenance perspective as we don't need to run a massive app to figure out
how a log message will be restructured.

=head1 DESCRIPTION

eris is structured to allow flexibility, extensibility, and visibility in
every component.

=head1 CONCEPTS

=head2 DECODER

Decoders are pluggable thanks to L<eris::role::pluggable> and they are searched for in the
the default namespace C<eris::log::decoder>.  To add other namespaces, use the C<search_path> paramter
in a config file:

    ---
    decoders:
      search_path:
        - 'my::app::decoders'

Decoders operate on the raw string and provide rudimentary key/value pairs for
the other contexts to operate on.  Unlike the contexts, every discovered decoder is run
for every message.  It's better to use contexts.

=head2 CONTEXT

=head2 DICTIONARY

=head2 SCHEMA


=cut
