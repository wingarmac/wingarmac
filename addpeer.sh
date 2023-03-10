#!/bin/bash

# Ask for the new peer's name
read -p "What is the name for the new peer? " name_host

# Ask for the new peer's VPN number
read -p "What is the VPN number for the new peer? (between 5 and 255) " vpn_number

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
AllowedIPs = 0.0.0.0/0
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
[Peer]
PublicKey = $public_key
Endpoint = 194.78.208.195:8023
AllowedIPs = $ip_address/32
PersistentKeepalive = 21

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

# Print the updated Wireguard configuration file
echo "Updated Wireguard configuration file:"
cat /etc/wireguard/wg0.conf
