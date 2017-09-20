#!/bin/bash

cd /etc/openvpn

# permet de faire passer les DNS par le VPN et donc d'avoir encore internet ...
./update-resolv-conf  "$@"

# configuration et lancement de transmission : adresse vpn etc.
./cfg_transmission.sh "$@"


