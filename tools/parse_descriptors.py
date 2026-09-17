#!/usr/bin/env python3
"""Parse standard USB interface/endpoint descriptors from read-only sysfs."""

from __future__ import annotations

import json
from pathlib import Path

USB_ROOT = Path("/sys/bus/usb/devices")
TARGET = (0x0ECB, 0x2069)


def hex_file(path: Path) -> int | None:
    try:
        return int(path.read_text(encoding="ascii").strip(), 16)
    except (OSError, ValueError):
        return None


def iter_descriptors(data: bytes):
    offset = 0
    while offset + 2 <= len(data):
        length, descriptor_type = data[offset], data[offset + 1]
        if length < 2 or offset + length > len(data):
            raise ValueError(f"invalid descriptor length {length} at offset {offset}")
        yield offset, descriptor_type, data[offset : offset + length]
        offset += length


def parse(data: bytes) -> list[dict[str, object]]:
    interfaces: list[dict[str, object]] = []
    current: dict[str, object] | None = None
    for offset, descriptor_type, raw in iter_descriptors(data):
        if descriptor_type == 4 and len(raw) >= 9:
            current = {
                "offset": offset,
                "number": raw[2],
                "alternate_setting": raw[3],
                "declared_endpoints": raw[4],
                "class": f"{raw[5]:02x}",
                "subclass": f"{raw[6]:02x}",
                "protocol": f"{raw[7]:02x}",
                "string_index": raw[8],
                "endpoints": [],
            }
            interfaces.append(current)
        elif descriptor_type == 5 and len(raw) >= 7 and current is not None:
            address = raw[2]
            attributes = raw[3]
            transfer_types = ("control", "isochronous", "bulk", "interrupt")
            endpoint = {
                "offset": offset,
                "address": f"0x{address:02x}",
                "direction": "in" if address & 0x80 else "out",
                "transfer_type": transfer_types[attributes & 0x03],
                "attributes": f"0x{attributes:02x}",
                "max_packet_size": int.from_bytes(raw[4:6], "little") & 0x07FF,
                "interval": raw[6],
            }
            endpoints = current["endpoints"]
            assert isinstance(endpoints, list)
            endpoints.append(endpoint)
    return interfaces


def main() -> int:
    devices = []
    for device in sorted(USB_ROOT.iterdir()):
        if (hex_file(device / "idVendor"), hex_file(device / "idProduct")) != TARGET:
            continue
        blob = (device / "descriptors").read_bytes()
        devices.append({"sysfs": str(device), "descriptor_bytes": len(blob), "interfaces": parse(blob)})
    print(json.dumps({"schema": 1, "devices": devices}, indent=2))
    return 0 if devices else 1


if __name__ == "__main__":
    raise SystemExit(main())
