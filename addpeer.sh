#!/bin/bash

REQUIRED_PKG="qrencode"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: "$PKG_OK"
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  apt install -y $REQUIRED_PKG
fi

# Check the existing Wireguard configuration file for assigned IP addresses
assigned_ips=($(grep -Po '(\d{1,3}\.){3}\d{1,3}/\d{1,2}' /etc/wireguard/wg0.conf | cut -d '/' -f 1))

# Calculate the available VPN numbers
available_vpn_numbers=$(seq 5 255 | grep -vE $(echo "${assigned_ips[@]}" | tr ' ' '|'))

# Ask for the new peer's name
read -p "What is the name for the new peer? " name_host

# Prompt the user for a VPN number that is not already assigned
read -p "What is the VPN number for the new peer? (between ${available_vpn_numbers:0:1} and ${available_vpn_numbers[-1]}) " vpn_number
while [[ ! "${available_vpn_numbers[@]}" =~ "${vpn_number}" ]]; do
  read -p "VPN number $vpn_number is already assigned or out of range. Please choose a different VPN number. (between ${available_vpn_numbers:0:1} and ${available_vpn_numbers[-1]}) " vpn_number
done

# Calculate the new peer's IP address
ip_address="10.5.5.$vpn_number"

# Create the directory for the new peer
mkdir -p ./$name_host

# Generate the Wireguard configuration file for the new peer
cat > ./$name_host/wg0.conf <<EOF
[Interface]
PrivateKey = $(wg genkey)
Address = $ip_address/32

[Peer]
PublicKey = $(wg pubkey)
Endpoint = 194.78.208.195:51515
AllowedIPs = 10.5.5.1/32
PersistentKeepalive = 21

[Peer]
PublicKey = $(wg pubkey)
Endpoint = 194.78.208.195:8023
AllowedIPs = 10.5.5.2/32
PersistentKeepalive = 21

EOF

# Ask whether the new peer is a PC or mobile
read -p "Is the new peer a PC or mobile? " peer_type

if [[ "$peer_type" == "mobile" ]]; then
  # Add the new peer to the Wireguard configuration file
  echo "[Peer]" >> /etc/wireguard/wg0.conf
  echo "PublicKey = " >> /etc/wireguard/wg0.conf
  echo "Endpoint = 194.78.208.195:8023" >> /etc/wireguard/wg0.conf
  echo "AllowedIPs = $ip_address/32" >> /etc/wireguard/wg0.conf
  echo "PersistentKeepalive = 21" >> /etc/wireguard/wg0.conf
else
  # Add the new peer to the Wireguard configuration file
  echo "[Peer]" >> /etc/wireguard/wg0.conf
  echo "PublicKey = $(wg pubkey)" >> /etc/wireguard/wg0.conf
  echo "AllowedIPs = $ip_address/32" >> /etc/wireguard/wg
