#!/bin/bash
function get_network_address
{
	chmod +x mask-transform.py
	netmask_broadcast=$(ifconfig wlp2s0 | grep inet | grep -v inet6 | awk '{print $4 " " $6}') #
	local_net=$(./mask-transform.py $netmask_broadcast)
}



cp ip_forward.bak /proc/sys/net/ipv4/ip_forward
iptables-restore < iptables.bak
ip route delete $local_net dev virt0 table 100
ip rule delete iff virt0 lookup 100
sysctl net.ipv4.conf.all.arp_ignore=0

