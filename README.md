# Primer Parcial — Seguridad de Redes con FortiGate

> **Video de demostración:** [AGREGAR ENLACE DEL VIDEO AQUÍ]

Laboratorio de Seguridad de Redes implementado en GNS3 con FortiGate, routers Cisco, switch IOSv y servidores Ubuntu. El objetivo es demostrar segmentación, control de acceso, filtrado de archivos, port-security, servicios de red y salida controlada a Internet.

## Topología

![Topología del laboratorio](images/topology.png)

```text
Internet / Cloud
      |
     R1
   /    \
FortiGate  R3
   |       |
 SW-LAN   Switch1
 /   \      \
PC-   PC-   DB Server
USERS ADMIN
   |
WEB-ZONE (port3)
   |
Web Server
```

## Direccionamiento

| Segmento | Red | Gateway / equipo |
|---|---|---|
| Tránsito R1–FortiGate | 10.21.50.0/30 | R1: 10.21.50.1 / FortiGate: 10.21.50.2 |
| VLAN 10 USERS | 10.21.39.0/25 | FortiGate: 10.21.39.1 |
| VLAN 20 ADMIN | 10.21.39.128/28 | FortiGate: 10.21.39.129 |
| Servidores DB | 10.21.39.144/28 | R3: 10.21.39.145 / DB: 10.21.39.147 |
| WEB-ZONE | 10.21.39.160/28 | FortiGate port3: 10.21.39.161 / WEB: 10.21.39.162 |
| Tránsito R1–R3 | 10.21.60.0/30 | R1: 10.21.60.1 / R3: 10.21.60.2 |

## 1. Microsegmentación del Web Server

El Web Server se ubicó en una zona dedicada conectada directamente al `port3` del FortiGate.

Políticas implementadas:

- `WEB-to-DB-3306`: permite únicamente TCP/3306 hacia el DB Server.
- `WEB-to-UPDATES`: permite HTTP/HTTPS hacia objetos FQDN de actualización de Ubuntu.
- `WEB-to-DNS`: permite DNS únicamente hacia `8.8.8.8`.
- `BLOCK-WEB-OTHER`: bloquea el resto del tráfico iniciado por el Web Server.

Pruebas realizadas:

- `nc -vz 10.21.39.147 3306` → permitido.
- `ping 10.21.39.147` → bloqueado.
- `ping 8.8.8.8` → bloqueado.
- `nc -vz -w 3 8.8.8.8 22` → bloqueado.
- `curl http://archive.ubuntu.com/ubuntu/` → permitido.
- TCP/443 hacia `archive.ubuntu.com` abre correctamente; en el laboratorio se observó timeout durante el handshake TLS completo.
- `curl http://example.com` → bloqueado por `BLOCK-WEB-OTHER`.

![Microsegmentación](images/microsegmentation.png)

## 2. Bloqueo de descargas `.exe`

Se creó el perfil `BLOCK-EXE` y se aplicó a la política `USERS-to-WEB`.

Pruebas:

- `permitido.txt` se descarga completamente.
- `prueba.exe` es detectado como `PE32 executable`.
- La transferencia del `.exe` es interrumpida por FortiGate (`Connection reset by peer`).
- Apache anunciaba `Content-Length: 1400`, pero el cliente solo recibió 1000 bytes antes del bloqueo.
- El evento se registra en los logs del FortiGate.

![Bloqueo de EXE](images/block-exe.png)

## 3. VLANs y trunk 802.1Q

- VLAN 10: `USERS`.
- VLAN 20: `ADMIN`.
- `Gi0/0`: trunk 802.1Q hacia FortiGate.
- `Gi0/1`: access VLAN 10.
- `Gi0/2`: access VLAN 20.
- VLAN 10 utiliza DHCP entregado por FortiGate.

![VLANs y trunk](images/vlan-trunk.png)

## 4. Bloqueo VLAN 10 → DB por TCP/3306

Política explícita `BLOCK-USERS-DB-3306`:

- Origen: VLAN10-USERS.
- Destino: `DB-SERVER` (`10.21.39.147/32`).
- Servicio: MySQL / TCP 3306.
- Acción: DENY.
- Logging habilitado.

Pruebas:

- ICMP hacia el DB responde.
- `nc -vz -w 3 10.21.39.147 3306` falla por timeout.
- HTTP hacia el Web Server sigue permitido.
- FortiGate registra `Deny: policy violation` bajo `BLOCK-USERS-DB-3306`.

![Bloqueo VLAN10 a DB](images/block-db-3306.png)

## 5. Port-Security

Configurado en los puertos de acceso `Gi0/1` y `Gi0/2`:

- Máximo: 2 MAC por puerto.
- Violation mode: `shutdown`.

Se provocó una tercera MAC en `Gi0/1`, obteniendo:

```text
Port Status                : Secure-shutdown
Violation Mode             : Shutdown
Maximum MAC Addresses      : 2
Security Violation Count   : 1
```

El switch también reportó `Gi0/1` como `err-disabled`.

![Port Security](images/port-security.png)

## 6. Servidores

### Web Server

- Ubuntu Server.
- IP: `10.21.39.162/28`.
- Apache2 operativo en TCP/80.

### DB Server

- Ubuntu Server.
- IP: `10.21.39.147/28`.
- MariaDB operativo y escuchando en `0.0.0.0:3306`.

![Servicios](images/servers.png)

## 7. Salida a Internet

FortiGate posee ruta por defecto hacia `10.21.50.1` por `port1` y política `USERS-to-INTERNET` con NAT habilitado.

Desde PC-USUARIOS se comprobó:

- `ping 8.8.8.8` funcional.
- `traceroute 8.8.8.8` pasando por `10.21.39.1`, `10.21.50.1` y la red NAT de VMware.

![NAT e Internet](images/internet-nat.png)

## Estructura del repositorio

```text
primer_parcial_seguridad_redes/
├── README.md
├── configs/
│   ├── R1.txt
│   ├── R3.txt
│   ├── SW-LAN.txt
│   └── FortiGate.txt
├── docs/
│   └── evidencias.md
└── images/
    ├── topology.png
    ├── microsegmentation.png
    ├── block-exe.png
    ├── vlan-trunk.png
    ├── block-db-3306.png
    ├── port-security.png
    ├── servers.png
    └── internet-nat.png
```

## Autor

**Adrian Magallanes Feliz**  
Matrícula: **2025-2139**
