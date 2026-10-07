#!/usr/bin/env bash
set -euo pipefail

# Archivo permitido para demostrar que HTTP continúa funcionando.
echo "ARCHIVO PERMITIDO - PRUEBA FORTIGATE" | sudo tee /var/www/html/permitido.txt >/dev/null

# Crea un ejecutable PE32 mínimo para que FortiGate lo identifique como .exe real.
python3 - <<'PY'
import struct

p = "/tmp/prueba.exe"

dos = bytearray(0x80)
dos[0:2] = b"MZ"
struct.pack_into("<I", dos, 0x3c, 0x80)

coff = struct.pack("<HHIIIHH", 0x14c, 1, 0, 0, 0, 0xE0, 0x0102)
opt = bytearray(0xE0)
struct.pack_into("<H", opt, 0, 0x10b)

data = dos + b"PE\0\0" + coff + opt
data.extend(b"\0" * 1024)

with open(p, "wb") as f:
    f.write(data)
PY

sudo cp /tmp/prueba.exe /var/www/html/prueba.exe

# Verificaciones
file /var/www/html/prueba.exe
ls -lh /var/www/html/permitido.txt /var/www/html/prueba.exe
curl http://localhost/permitido.txt
