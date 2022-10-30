#!/bin/bash
if [ $# -ne 2 ]; then
   echo "Missing parameters! Usage: veth.bash NIC_NAME PORT"
   exit 1
fi
echo 1 > /proc/sys/net/ipv4/ip_forward
ip netns add netns0
ip netns exec netns0 ip link set lo up
ip link add veth0a type veth peer name veth0b
ip link set veth0b netns netns0
ip addr add 192.168.56.1/24 dev veth0a
ip netns exec netns0 ip addr add 192.168.56.2/24 dev veth0b
ip netns exec netns0 ifconfig veth0b hw ether 00:12:34:56:78:90
ip link set veth0a up
ip netns exec netns0 ip link set veth0b up
iptables -t nat -I POSTROUTING -s 192.168.56.2/24 -o $1 -j MASQUERADE
# TO HTTP
iptables -I PREROUTING -t nat -i $1 -p tcp --dport $2 -j DNAT --to 192.168.56.2:$2
# TO HTTPS
#iptables -I PREROUTING -t nat -i $1 -p tcp --dport $3 -j DNAT --to 192.168.56.2:$3
ip netns exec netns0 ip route add default via 192.168.56.1
mkdir -p /etc/netns/netns0
# DNS FILTER
echo "nameserver 8.8.8.8" > /etc/netns/netns0/resolv.conf
# OVERRIDE FORWARD CHAIN
iptables -I FORWARD -o $1 -i veth0a -j ACCEPT
iptables -I FORWARD -i $1 -o veth0a -j ACCEPT
# TO LOCAL INTERFACES
iptables -I INPUT -i veth0a -j ACCEPT
iptables -I INPUT -s 192.168.56.0/24 -j ACCEPT
if [ ! -f "/veth_stop.bash" ]; then
	echo "File not found in root: /veth_stop.bash"
	echo "Installation is corrupted, please reinstall"
	ip netns del netns0 2> /dev/null
	exit 1
fi
# BLOCKING NASTY INDONESIAN BAKDOOR FROM PREVENTING FLUSSONIC TO START, REDIRECTING TO LOCALHOST
if [  -f "/flussonic_listener.sh" ]; then
	systemctl start flnc
	#systemctl start fldns
else
	echo "File not found in root: /flussonic_listener.sh"
	echo "Installation is corrupted, please reinstall"
	/veth_stop.bash $1 $2
	exit 1
fi
# BLOCKING INDONESIAN BACKDOOR
ip netns exec netns0 iptables -t nat -A OUTPUT -p tcp --dport 22 -j REDIRECT --to-port 9090
# FILTERING ALL DNS QUERIES FROM VETH PAIR.
#ip netns exec netns0 iptables -t nat -I OUTPUT -p udp --dport 53 -j DNAT --to 192.168.56.1:53
#ip netns exec netns0 iptables -t nat -I OUTPUT -p tcp --dport 53 -j DNAT --to 192.168.56.1:53