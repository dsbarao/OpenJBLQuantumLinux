# Initial CachyOS inventory — 2026-09-16

This inventory was collected passively. No USB/HID commands were sent.

## Host and tools

- Distro: CachyOS (Arch-derived rolling release)
- Kernel: `7.2.0-1-cachyos`, x86_64, PREEMPT_DYNAMIC
- Git: `2.55.0`
- Python: `3.14.7`
- Rust/Cargo at project bootstrap: not installed; later installed through
  CachyOS `rustup` with stable Rust 1.98.1
- Kernel modules observed: `snd_usb_audio`; USB tree also reports `usbhid`

The Codex sandbox could not connect to the user's PipeWire socket or initialize
libusb. ALSA kernel metadata later became readable through `/proc/asound` and is
documented below. PipeWire correlation still needs the desktop session.

## Device identity

- Vendor/Product: `0ecb:2069`
- Manufacturer: `Harman International Inc`
- Product: `JBL Quantum810 Wireless`
- USB version/speed: USB 2.0 / 480 Mbit/s
- Device revision: `0100`
- Configuration count: 1
- Bus/device at observation time: `001/002` (not stable identifiers)
- Stable physical port at observation time: `1-3`
- Number of interfaces: 6
- Power: 500 mA, bus-powered

## Interface topology

| Iface | Class/subclass/protocol | Name | Alt | Endpoints | Driver |
|---|---|---|---:|---|---|
| 0 | 01/01/00 Audio Control | Quantum810 Wireless Game | 0 | none | snd-usb-audio |
| 1 | 01/02/00 Audio Streaming | — | 0 | none | snd-usb-audio |
| 1 | 01/02/00 Audio Streaming | — | 1 | `0x01` OUT, isochronous, 512 B, interval 4 | snd-usb-audio |
| 2 | 01/01/00 Audio Control | Quantum810 Wireless Chat | 0 | none | snd-usb-audio |
| 3 | 01/02/00 Audio Streaming | — | 0 | none | snd-usb-audio |
| 3 | 01/02/00 Audio Streaming | — | 1 | `0x02` OUT, isochronous, 512 B, interval 4 | snd-usb-audio |
| 4 | 01/02/00 Audio Streaming | — | 0 | none | snd-usb-audio |
| 4 | 01/02/00 Audio Streaming | — | 1 | `0x81` IN, isochronous, 512 B, interval 4 | snd-usb-audio |
| 5 | 03/00/00 HID | Quantum810 Wireless | 0 | `0x83` IN, interrupt, 64 B, interval 3 | usbhid |

The 347-byte descriptor blob exported read-only by sysfs was parsed to include
inactive alternate settings; sysfs interface directories alone show only the
active alternative. Interface 1 alt 1 was inactive during observation,
interface 3 alt 1 was active, and interface 4 alt 1 was inactive.

## HID mapping

- hidraw node at observation time: `/dev/hidraw0` (not stable)
- Interface: `05`
- HID ID: `0003:00000ECB:00002069`
- HID driver: `hid-generic`
- Physical path: `usb-0000:06:00.1-3/input5`

The HID interface exposes only an interrupt IN endpoint in its active
descriptor. This does **not** prove that feature or control requests are safe;
none were attempted.

## ALSA stream correlation

Kernel `/proc/asound` stream metadata correlates the USB functions as follows:

| ALSA node | Role | USB interface/endpoint | Format |
|---|---|---|---|
| `pcmC2D0p` | Game playback | interface 1 / `0x01 OUT` | stereo S16_LE, 48 kHz |
| `pcmC2D1p` | Chat playback | interface 3 / `0x02 OUT` | stereo S16_LE, 48 kHz |
| `pcmC2D0c` | Microphone capture | interface 4 / `0x81 IN` | mono S16_LE, 16 or 48 kHz |

The ALSA card number (`2` here) is dynamic; the CLI discovers the card through
its sysfs ancestry rather than relying on that number.
