#!/bin/bash
systemctl stop flnc
#systemctl stop fldns
ip netns delete netns0 2> /dev/null
ip link delete veth0a 2> /dev/null
# TO HTTP
iptables -D PREROUTING -t nat -i $1 -p tcp --dport $2 -j DNAT --to 192.168.56.2:$2 2> /dev/null
# TO HTTPS
#iptables -D PREROUTING -t nat -i $1 -p tcp --dport $3 -j DNAT --to 192.168.56.2:$3 2> /dev/null
iptables -t nat -D POSTROUTING -s 192.168.56.2/24 -o $1 -j MASQUERADE 2> /dev/null
iptables -D FORWARD -o $1 -i veth0a -j ACCEPT 2> /dev/null
iptables -D FORWARD -i $1 -o veth0a -j ACCEPT 2> /dev/null
iptables -D INPUT -i veth0a -j ACCEPT 2> /dev/null
iptables -D INPUT -s 192.168.56.0/24 -j ACCEPT 2> /dev/null
exit 0
