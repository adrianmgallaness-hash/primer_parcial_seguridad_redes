# Comandos de verificación

Este archivo reúne los comandos utilizados para demostrar los requisitos del primer parcial.

## VLAN 10, VLAN 20 y trunk

En `SW-LAN`:

```text
show vlan brief
show interfaces trunk
show running-config | include hostname
```

## Port-Security

```text
show port-security
show port-security interface gi0/1
show port-security interface gi0/2
show port-security address
show interfaces status
```

Resultado observado durante la violación en `Gi0/1`:

```text
Port Status                : Secure-shutdown
Violation Mode             : Shutdown
Maximum MAC Addresses      : 2
Security Violation Count   : 1
```

## Bloqueo VLAN10 hacia DB por TCP/3306

Desde `PC-USUARIOS`:

```bash
ping 10.21.39.147
nc -vz -w 3 10.21.39.147 3306
```

Resultado esperado/verificado:

- ICMP hacia DB: permitido.
- TCP/3306: bloqueado por `BLOCK-USERS-DB-3306`.

## Acceso al Web Server

```bash
curl http://10.21.39.162/
```

## Microsegmentación del Web Server

Desde `web-server`:

```bash
nc -vz -w 3 10.21.39.147 3306
ping 10.21.39.147
getent hosts archive.ubuntu.com
getent hosts security.ubuntu.com
curl -I http://archive.ubuntu.com/ubuntu/
ping 8.8.8.8
nc -vz -w 3 8.8.8.8 22
curl -4 -I --connect-timeout 5 http://example.com
```

Resultados verificados:

- DB TCP/3306: permitido.
- ICMP hacia DB: bloqueado.
- DNS hacia el resolver permitido: funcional.
- HTTP hacia endpoints Ubuntu autorizados: permitido.
- ICMP general: bloqueado.
- SSH general: bloqueado.
- HTTP hacia destinos no autorizados: bloqueado.

> Nota: TCP/443 hacia `archive.ubuntu.com` abre correctamente, pero durante el laboratorio el handshake TLS completo presentó timeout.

## File Filter / bloqueo de `.exe`

Desde `PC-USUARIOS`:

```bash
rm -f permitido.txt prueba.exe
curl -O http://10.21.39.162/permitido.txt
cat permitido.txt
curl -v -O http://10.21.39.162/prueba.exe
ls -lh prueba.exe
```

Resultados verificados:

- `permitido.txt`: descarga completa.
- `prueba.exe`: transferencia interrumpida por FortiGate con `Connection reset by peer`.
- Apache anunció `Content-Length: 1400`; el cliente recibió solo 1000 bytes antes del bloqueo.

## Servicios

En `web-server`:

```bash
sudo systemctl status apache2 --no-pager
sudo ss -lntp | grep ':80'
```

En `db-server`:

```bash
sudo systemctl status mariadb --no-pager
sudo ss -lntp | grep ':3306'
```

## Internet y NAT

Desde `PC-USUARIOS`:

```bash
ping 8.8.8.8
traceroute 8.8.8.8
```

Durante la práctica el traceroute mostró como primeros saltos `10.21.39.1`, `10.21.50.1` y la red NAT de VMware.
