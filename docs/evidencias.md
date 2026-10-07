# Checklist de evidencias

Antes de entregar el repositorio, subir las capturas a `images/` con estos nombres para que el `README.md` las muestre automáticamente.

## Archivos requeridos

- `topology.png`
  - Topología completa en GNS3.

- `microsegmentation.png`
  - Políticas `WEB-to-DB-3306`, `WEB-to-UPDATES`, `WEB-to-DNS`, `BLOCK-WEB-OTHER`.
  - Idealmente acompañada de una captura de pruebas permitidas/bloqueadas.

- `block-exe.png`
  - `permitido.txt` descargado correctamente.
  - `prueba.exe` interrumpido por FortiGate.
  - Log del bloqueo en Forward Traffic o File Filter.

- `vlan-trunk.png`
  - `show vlan brief`.
  - `show interfaces trunk`.

- `block-db-3306.png`
  - `nc -vz -w 3 10.21.39.147 3306` bloqueado desde PC-USUARIOS.
  - Log `BLOCK-USERS-DB-3306` con `Deny: policy violation`.

- `port-security.png`
  - `show port-security interface gi0/1` con `Secure-shutdown`.
  - `Security Violation Count: 1`.
  - `show interfaces status` con `Gi0/1 err-disabled`.

- `servers.png`
  - Apache2 activo / puerto 80 escuchando.
  - MariaDB activo / `0.0.0.0:3306` escuchando.

- `internet-nat.png`
  - Política `USERS-to-INTERNET` con NAT habilitado.
  - `ping 8.8.8.8` exitoso.
  - `traceroute 8.8.8.8` funcional.

## Evidencias ya demostradas durante la práctica

- Bloqueo VLAN10 → DB TCP/3306.
- Log del bloqueo en FortiGate.
- Descarga permitida de `permitido.txt`.
- Bloqueo parcial/interrupción de `prueba.exe` por File Filter.
- Violación real de port-security con tercera MAC.
- NAT e Internet funcional desde PC-USUARIOS.
- Microsegmentación Web → DB TCP/3306 permitida y otros destinos bloqueados.

## Pendiente de revisar antes del video

1. Confirmar hostname final del switch como `SW-LAN` (durante las pruebas aparecía `Switch#`).
2. Agregar el enlace del video al inicio de `README.md`.
3. Subir todas las capturas con los nombres exactos indicados arriba.
4. Si se desea, reemplazar los resúmenes de `configs/` por la salida completa de `show running-config` / backup del FortiGate.
