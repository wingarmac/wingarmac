#!/bin/bash

set -e

KEYRING_DIR="/etc/apt/trusted.gpg.d"
KEYRING_FILES="$KEYRING_DIR/*.gpg"

if ! [ "$(ls -A $KEYRING_FILES)" ]; then
  echo "No keyring files found in $KEYRING_DIR"
  exit 1
fi

echo "Migrating keyring file $KEYRING_FILES"
apt-key --keyring $KEYRING_FILES migrate
