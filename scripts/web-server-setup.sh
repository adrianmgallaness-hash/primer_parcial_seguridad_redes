#!/usr/bin/env bash
set -euo pipefail

# Configuración utilizada para el Web Server del laboratorio.
# Interfaz de laboratorio: ens3
# Red WEB-ZONE: 10.21.39.160/28
# Gateway FortiGate port3: 10.21.39.161
# Web Server: 10.21.39.162

sudo ip link set ens4 down
sudo ip route flush dev ens3
sudo ip addr flush dev ens3
sudo ip addr add 10.21.39.162/28 dev ens3
sudo ip link set ens3 up
sudo ip link set dev ens3 mtu 1500
sudo ip route add default via 10.21.39.161 dev ens3

# Verificaciones
ip addr show ens3
ip route
ping -c 3 10.21.39.161

# Apache debe estar operativo en TCP/80.
sudo systemctl status apache2 --no-pager || true
sudo ss -lntp | grep ':80' || true
curl -I http://localhost/ || true
