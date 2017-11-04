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
        - 'my::app::decoder'

Decoders operate on the raw string and provide rudimentary key/value pairs for
the other contexts to operate on.  Unlike the contexts, every discovered decoder is run
for every message.

=head2 CONTEXT

Contexts are pluggable and are searched for in the default namespace
C<eris::log::decoder>.  To add your own namespaces, use the C<search_path>
parameter in your config file:

    ---
    contexts:
      search_path:
        - 'my::app::context'

Contexts implement the interface documented in L<eris::role::context>.  There
are 4 major things to consider when implementing a new context.

=over 2

=item B<contextualize_message>

This method is called when the context matches the event data.  This is where
you can implement your own parsing or analysis of the event data.  To add
context to an event, use the L<eris::log>'s C<add_context()> method.  That
context data will be available to future contexts.

=item B<sample_messages>

Return an array of sample messages.  This provides future developers with some
data to use in testing and enhancing your context.

=item B<field>

This specifies the field or fields that a matcher will operate on.  There are
two special fields C<*> and C<_exists_>.  The C<*> is used in conjunction with
a matcher of C<*> to match all messages.  The C<_exists_> operator is used to
check for the existance of a key in the context.  A sample use of this field
specifier is used by the L<eris::log::context::GeoIP> context with an regex
matcher to operate on any event data with field names matching C<'_ip$'>.

=item B<matcher>

Can be C<*>, a string, a regex ref, an array reference, or a code reference.
If C<*> and C<field> is C<*> means match every message.  If a literal string,
or array reference, the literal string is checked against the value of in the
C<field> specified above and returns 1 if they are equivalent.  If a regex
reference, the regex is applied to the value in the specified C<field> and the
context is applied if the regex matches.  A code reference should return 1 if
the event is relevant to the context and 0 if it doesn't apply.

=back

The default C<field> is 'program', and the default matcher is a string with the
value equal to the context's C<name> attribute.  For instance,
L<eris::log::context::sshd> defaults it's name to 'sshd', and since it doesn't
override the field, this context is only applied to events with a 'program' key
with a value of 'sshd'.

=head2 DICTIONARY

=head2 SCHEMA

=cut
