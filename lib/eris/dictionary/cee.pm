package eris::dictionary::cee;

use namespace::autoclean;
use Moose;
with qw(
    eris::role::dictionary
);

has fields => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    builder => '_build_fields',
);

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
acct Account Username
acct_domain Account Domain
acct_fullname Account Fullname
acct_id Account User ID
boot_id Producer Boot ID
dev Device Name
dev_links Device Node Links
dev_node Device Node
driver System Kernel Driver Name
dst Destination Hostname
dst_ip Destination IP Address
dst_mac Destination MAC Address
dst_port Destination Port Nummber
dst_prefix_len Destination IP Address Prefix Length
exe Binary process exe path
file File Name
in_bytes Inbound (Ingress) Bytes
in_pkts  Inbound (Ingress) Packet Count
out_bytes Outbound (Egress) Bytes
out_pkts  Outbound (Egress) Packet Count
p_ip Producer IP address
p_mac Producer MAC address
proc Process Name
proc_egid Process Effective Group ID
proc_euid Process Effectice User ID
proc_gid Process Group ID
proc_uid Process User ID
proc_id Process ID
prod Product Name
proto_app Network Application Protocol Name
rcv_time Event Record Receive Time
rec_id Event Record ID
rec_time Event Record Time
sess User Session ID
src Source Hostname
src_ip Source IP Address
src_mac Source MAC Address
src_port Source Port Nummber
src_prefix_len Source IP Address Prefix Length
subsystem System Kernel Subsystem
action Primary action taken
crit Event Criticality
domain Environment or domain
id Event ID
object Type of object
p_app  Producing application
p_proc Producing process
p_proc_id Producing Process ID
p_sys Producing system
pri Priority of the Event
schema Schema covered by event
schema_ver Version of the Schema
service Service involved
status Result of the action
subject type of object initiated
tags Freeform tags for the event
time Time of the event
