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

# Calculate the largest available VPN number between 5 and 255
largest_available_vpn_number=$(seq 5 255 | grep -vE $(echo "${assigned_ips[@]}" | tr ' ' '|') | tail -n 1)

# Ask for the new peer's name
read -p "What is the name for the new peer? " name_host

# Prompt the user for a VPN number that is not already assigned
read -p "What is the VPN number for the new peer? (between 5 and $largest_available_vpn_number) " vpn_number
while [[ ! $vpn_number =~ ^[0-9]+$ ]] || [[ $vpn_number -lt 5 ]] || [[ $vpn_number -gt $largest_available_vpn_number ]]; do
  read -p "Invalid input. Please enter a number between 5 and $largest_available_vpn_number: " vpn_number
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
PublicKey = $public_key
Endpoint = 194.78.208.195:8023
AllowedIPs = $ip_address/32
PersistentKeepalive = 21

EOF

# Ask whether the new peer is a PC or mobile
read -p "Is the new peer a PC or mobile? " peer_type

if [[ "$peer_type" == "mobile" ]]; then
  # Generate a QR code for the new peer's public key
  qrencode -t ansiutf8 < ./$name_host/wg0.conf

  # Ask the user to transmit the public key
  read -p "Veuillez transmettre votre code public: " public_key

  # Add the new peer to the Wireguard configuration file
  cat >> /etc/wireguard/wg0.conf <<EOF


EOF
else
  # Add the new peer to the Wireguard configuration file
  cat >> /etc/wireguard/wg0.conf <<EOF
[Peer]
PublicKey = $(wg pubkey)
AllowedIPs = $ip_address/32

EOF
fi

# Print the configuration for the new peer
echo "Wireguard configuration for $name_host:"
cat ./$name_host/wg0.conf

#
