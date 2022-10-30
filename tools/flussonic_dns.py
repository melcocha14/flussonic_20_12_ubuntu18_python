#!/usr/bin/env python3
import dns.resolver
import scapy.all as scapy
import netifaces as ni
import sys
sys.tracebacklimit = 0

def handle_packet_fn(iface, spoof_ip, spoof_domains):
    def handle_packet(packet):
        ip = packet.getlayer(scapy.IP)
        udp = packet.getlayer(scapy.UDP)

        # Ignore packets containing data we aren't interested
        # in.
        if hasattr(packet, 'qd') and packet.qd is not None:
            queried_host = packet.qd.qname[:-1].decode("utf-8")
            if queried_host is None:
                print("queried_host is None, dropping request")
                return
            #Handing possible exceptions and spoofing them out
            skipwords = "local"
            skipwordss = "arpa"
            if skipwords in queried_host:
                resolved_ip = spoof_ip
            if skipwordss in queried_host:
                resolved_ip = queried_host

            # If the queried_host is one of the domains we want
            # to spoof, return the spoof_ip.
            if queried_host in spoof_domains:
                print("Spoofing DNS request for %s by %s"
                        % (queried_host, ip.src))
                resolved_ip = spoof_ip
            # Else use dns.resolver to make a real DNS "A record"
            # request, and return the result of that.
            else:
                print("Forwarding DNS request for %s by %s" %
                        (queried_host, ip.src))
                try:
                   a_records = dns.resolver.resolve(queried_host, 'A')
                   resolved_ip = a_records[0].address
                except dns.resolver.NXDOMAIN:
                   resolved_ip = spoof_ip
                except dns.resolver.NoAnswer:
                   resolved_ip = spoof_ip
                except dns.resolver.NoNameservers:
                   resolved_ip = spoof_ip

            # Build the DNS answer
            dns_answer = scapy.DNSRR(
                rrname=queried_host + ".",
                ttl=330,
                type="A",
                rclass="IN",
                rdata=resolved_ip)
            # Build the DNS response by constructing the IP
            # packet, the UDP "datagram" that goes inside the
            # packet, and finally the DNS response that goes
            # inside the datagram.
            dns_response = \
                scapy.IP(src=ip.dst, dst=ip.src) / \
                scapy.UDP(
                    sport=udp.dport,
                    dport=udp.sport
                ) / \
                scapy.DNS(
                    id = packet[scapy.DNS].id,
                    qr = 1,
                    aa = 0,
                    rcode = 0,
                    qd = packet.qd,
                    an = dns_answer
                )

            print("Resolved DNS request for %s to %s for %s" %
                    (queried_host, resolved_ip, ip.src))

            # Use scapy to send our response back to your phone.
            scapy.send(dns_response, iface=iface)
        else:
            print("Ignoring unrecognized packet from %s" % ip.src)

    return handle_packet


def _get_local_ip(iface):
    ni.ifaddresses(iface)
    return ni.ifaddresses(iface)[ni.AF_INET][0]['addr']


def run(iface, local_ip, sniff_filter, spoof_domains):
    print("Interface:\t\t\t%s" % iface)
    print("Resolving to IP:\t\t%s" % local_ip)
    print("Spoof domains:\t\t%s" % ', '.join(spoof_domains))
    print("BPF sniff filter:\t\t%s" % sniff_filter)
    print("")
    print("Waiting for DNS requests...")
    print("(Make sure the device you are targeting is set to use"\
            "your local IP (%s) as its DNS server)" % local_ip)

    scapy.sniff(iface=iface,
                filter=sniff_filter,
                prn=handle_packet_fn(iface, local_ip, spoof_domains))


IFACE= 'veth0a'
local_ip = _get_local_ip(IFACE)
client_ip = '192.168.56.2'

# SPOOF_DOMAINS
SPOOF_DOMAINS = ['license4.erlyvideo.org', 'license4.erlyvideo.org', 'license4-1.erlyvideo.org', 'license4-2.erlyvideo.org', 'license4-3.erlyvideo.org', 'license4-4.erlyvideo.org', 'apt.flussonic.com', 'my.retroview.local']
SNIFF_FILTER = ("udp port 53 && dst %s && src %s" %
    (local_ip, client_ip))

run(IFACE, local_ip, SNIFF_FILTER, SPOOF_DOMAINS)
