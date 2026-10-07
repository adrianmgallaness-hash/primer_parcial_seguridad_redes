#!/usr/bin/env bash
# Comandos usados durante la práctica en el DB Server.
# DB Server: 10.21.39.147/28
# Gateway por ens3: 10.21.39.145

# Rutas de retorno agregadas durante el troubleshooting y la microsegmentación.
sudo ip route add 10.21.39.0/25 via 10.21.39.145 dev ens3
sudo ip route add 10.21.39.128/28 via 10.21.39.145 dev ens3
sudo ip route add 10.21.60.0/30 via 10.21.39.145 dev ens3
sudo ip route add 10.21.39.160/28 via 10.21.39.145 dev ens3

# Verificaciones usadas.
ip route
sudo ss -lntp | grep 3306
