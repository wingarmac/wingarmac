#!/bin/bash
# MAIN DMZ SERVER ONLY (ubserv)
# Define variables
WG_INTERFACE="wgIPv6"
WG_NETWORK="fd00::/64"
EXTERNAL_INTERFACE="enp5s0"
EXTERNAL_IP=$(ip -6 route get 2001:4860:4860::8888 | awk '{print $7}')

# Enable IPv6 forwarding
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

# Enable NAT for the WireGuard interface
ip6tables -t nat -A POSTROUTING -s $WG_NETWORK -o $EXTERNAL_INTERFACE -j MASQUERADE

# Allow traffic from WireGuard interface to external network
ip6tables -A FORWARD -i $WG_INTERFACE -o $EXTERNAL_INTERFACE -j ACCEPT
ip6tables -A FORWARD -i $EXTERNAL_INTERFACE -o $WG_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow traffic to the WireGuard interface from external network
ip6tables -A INPUT -i $EXTERNAL_INTERFACE -p tcp --dport 80 -j ACCEPT
ip6tables -A INPUT -i $EXTERNAL_INTERFACE -p tcp --dport 443 -j ACCEPT

# Allow traffic from the WireGuard interface to the internal network
ip6tables -A FORWARD -i $WG_INTERFACE -s $WG_NETWORK -j ACCEPT
