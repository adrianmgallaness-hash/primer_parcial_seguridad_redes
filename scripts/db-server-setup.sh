#!/usr/bin/env bash
set -euo pipefail

# Configuración utilizada para el DB Server del laboratorio.
# Interfaz de laboratorio: ens3
# Red de servidores DB: 10.21.39.144/28
# Gateway R3: 10.21.39.145
# DB Server: 10.21.39.147

sudo ip route flush dev ens3
sudo ip addr flush dev ens3
sudo ip addr add 10.21.39.147/28 dev ens3
sudo ip link set ens3 up

# Rutas de retorno hacia las redes del laboratorio.
sudo ip route replace 10.21.39.0/25 via 10.21.39.145 dev ens3
sudo ip route replace 10.21.39.128/28 via 10.21.39.145 dev ens3
sudo ip route replace 10.21.39.160/28 via 10.21.39.145 dev ens3
sudo ip route replace 10.21.60.0/30 via 10.21.39.145 dev ens3

# ens4 se utilizó solamente como NAT auxiliar durante la instalación de paquetes.
sudo ip link set ens4 up || true

# Verificaciones
ip addr show ens3
ip route
sudo systemctl status mariadb --no-pager || true
sudo ss -lntp | grep ':3306' || true
