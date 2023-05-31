Wireguard - [How to set up wireguard firewall rules in linux example](https://www.cyberciti.biz/faq/how-to-set-up-wireguard-firewall-rules-in-linux/#Accept_WG_traffi)
---
Files:
 - add-nat-routing.sh - wireguard add nat routing table
 - client_wg0.conf - client example
 - remove-nat-routing.sh - Wireguard Remove nat routing table
Last updates:
- lookup updated for 10.5.5.0/24 hosts on wingarmac.org
- postup and down rules added for IPv6 wireguard wgIPv6.conf
ubcynt version: for IPv6 tunnel into IPv4 for port forwarded server

**add-nat-routing-IPv6.sh**
`
#!/bin/bash

# Define variables
WG_INTERFACE="wgIPv6"
WG_NETWORK="fd00::/64"
EXTERNAL_INTERFACE="enp4s0"
EXTERNAL_IP=$(ip -4 route get 8.8.8.8 | awk '{print $7}')

# Enable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1 > /dev/null

# Enable NAT for the WireGuard interface
ip6tables -t nat -A POSTROUTING -s $WG_NETWORK -o $EXTERNAL_INTERFACE -j MASQUERADE

# Allow traffic from WireGuard interface to external network
ip6tables -A FORWARD -i $WG_INTERFACE -o $EXTERNAL_INTERFACE -j ACCEPT
ip6tables -A FORWARD -i $EXTERNAL_INTERFACE -o $WG_INTERFACE -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Allow traffic to the WireGuard interface from external network
ip6tables -A INPUT -i $EXTERNAL_INTERFACE -p udp --dport 58585 -j ACCEPT

# Allow traffic from the WireGuard interface to the internal network
ip6tables -A FORWARD -i $WG_INTERFACE -s $WG_NETWORK -j ACCEPT
`
**remove-nat-routing-IPv6.sh**
`
#!/bin/bash

# Define variables
WG_INTERFACE="wgIPv6"
WG_NETWORK="fd00::/64"
EXTERNAL_INTERFACE="enp4s0"

# Disable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=0 > /dev/null

# Remove NAT rules for the WireGuard interface
ip6tables -t nat -D POSTROUTING -s $WG_NETWORK -o $EXTERNAL_INTERFACE -j MASQUERADE

# Remove traffic allowance from WireGuard interface to external network
ip6tables -D FORWARD -i $WG_INTERFACE -o $EXTERNAL_INTERFACE -j ACCEPT
ip6tables -D FORWARD -i $EXTERNAL_INTERFACE -o $WG_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# Remove traffic allowance to the WireGuard interface from external network
ip6tables -D INPUT -i $EXTERNAL_INTERFACE -p udp --dport 58585 -j ACCEPT

# Remove traffic allowance from the WireGuard interface to the internal network
ip6tables -D FORWARD -i $WG_INTERFACE -s $WG_NETWORK -j ACCEPT

`
