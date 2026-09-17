#!/usr/bin/env python3
"""Passively detect supported JBL USB devices through Linux sysfs.

This script never opens a USB device node or hidraw node. It reads only files
already exported by the kernel under /sys/bus/usb/devices.
"""

from __future__ import annotations

import json
from pathlib import Path

USB_ROOT = Path("/sys/bus/usb/devices")
SUPPORTED = {("0ecb", "2069"): "JBL Quantum 810 wireless dongle"}


def read_text(path: Path) -> str | None:
    try:
        return path.read_text(encoding="ascii", errors="replace").strip()
    except (FileNotFoundError, PermissionError, OSError):
        return None


def endpoint_data(interface: Path) -> list[dict[str, str | None]]:
    fields = ("bEndpointAddress", "bmAttributes", "wMaxPacketSize", "bInterval", "direction", "type")
    return [
        {"name": endpoint.name, **{field: read_text(endpoint / field) for field in fields}}
        for endpoint in sorted(interface.glob("ep_*"))
        if endpoint.is_dir()
    ]


def device_data(device: Path) -> dict[str, object]:
    interface_fields = (
        "bInterfaceNumber", "bAlternateSetting", "bNumEndpoints",
        "bInterfaceClass", "bInterfaceSubClass", "bInterfaceProtocol", "interface",
    )
    interfaces = []
    for interface in sorted(device.parent.glob(f"{device.name}:*")):
        interfaces.append({
            "sysfs": str(interface),
            **{field: read_text(interface / field) for field in interface_fields},
            "endpoints": endpoint_data(interface),
        })
    return {
        "sysfs": str(device),
        "vendor_id": read_text(device / "idVendor"),
        "product_id": read_text(device / "idProduct"),
        "manufacturer": read_text(device / "manufacturer"),
        "product": read_text(device / "product"),
        "bcd_device": read_text(device / "bcdDevice"),
        "speed_mbps": read_text(device / "speed"),
        "interfaces": interfaces,
    }


def main() -> int:
    matches = []
    for device in sorted(USB_ROOT.iterdir()):
        key = (read_text(device / "idVendor"), read_text(device / "idProduct"))
        if key in SUPPORTED:
            matches.append({"model": SUPPORTED[key], **device_data(device)})
    print(json.dumps({"schema": 1, "devices": matches}, indent=2, ensure_ascii=False))
    return 0 if matches else 1


if __name__ == "__main__":
    raise SystemExit(main())
