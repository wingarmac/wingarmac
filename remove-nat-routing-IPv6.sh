#!/bin/bash
# MAIN DMZ SERVER ONLY (ubserv)
# Define variables
WG_INTERFACE="wgIPv6"
WG_NETWORK="fd00::/64"
EXTERNAL_INTERFACE="enp5s0"

# Disable IPv6 forwarding
echo 0 > /proc/sys/net/ipv6/conf/all/forwarding

# Remove NAT rules for the WireGuard interface
ip6tables -t nat -D POSTROUTING -s $WG_NETWORK -o $EXTERNAL_INTERFACE -j MASQUERADE

# Remove traffic allowance from WireGuard interface to external network
ip6tables -D FORWARD -i $WG_INTERFACE -o $EXTERNAL_INTERFACE -j ACCEPT
ip6tables -D FORWARD -i $EXTERNAL_INTERFACE -o $WG_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# Remove traffic allowance to the WireGuard interface from external network
ip6tables -D INPUT -i $EXTERNAL_INTERFACE -p tcp --dport 80 -j ACCEPT
ip6tables -D INPUT -i $EXTERNAL_INTERFACE -p tcp --dport 443 -j ACCEPT

# Remove traffic allowance from the WireGuard interface to the internal network
ip6tables -D FORWARD -i $WG_INTERFACE -s $WG_NETWORK -j ACCEPT
