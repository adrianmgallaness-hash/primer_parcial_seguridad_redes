#!/usr/bin/env bash
# Comandos usados durante la práctica en el Web Server.
# Ubuntu / interfaz de laboratorio: ens3
# WEB-ZONE: 10.21.39.160/28
# Gateway FortiGate: 10.21.39.161
# Web Server: 10.21.39.162

# Desactivar la interfaz NAT auxiliar durante las pruebas de microsegmentación.
sudo ip link set ens4 down

# Mover el Web Server a la WEB-ZONE.
sudo ip route flush dev ens3
sudo ip addr flush dev ens3
sudo ip addr add 10.21.39.162/28 dev ens3
sudo ip link set ens3 up
sudo ip route add default via 10.21.39.161 dev ens3

# DNS usado para resolver los FQDN autorizados de Ubuntu.
sudo resolvectl dns ens3 8.8.8.8
sudo resolvectl domain ens3 ~.

# El MTU se restauró a 1500 después de una prueba temporal de troubleshooting.
sudo ip link set dev ens3 mtu 1500

# Comandos usados para revisar el estado.
ip addr show ens3
ip route
getent hosts archive.ubuntu.com
getent hosts security.ubuntu.com
getent ahostsv4 archive.ubuntu.com
