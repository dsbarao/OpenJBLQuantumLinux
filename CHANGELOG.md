# Changelog

## 0.1.0 — 2026-09-17

First usable read-only Linux release for the JBL Quantum 810:

- detect USB device `0ecb:2069` and inspect interfaces/endpoints;
- correlate Game, Chat, and microphone ALSA nodes;
- decode the kernel-exported HID report descriptor;
- monitor and interpret confirmed spontaneous Input Reports;
- read battery Feature Report `0x49` through an allowlisted read-only ioctl;
- emit human-readable and schema-1 JSON battery status;
- display battery percentage through a KDE desktop notification;
- include an optional KDE application launcher;
- include a Plasma 6 panel widget with one-minute refresh and manual update;
- document controlled QuantumENGINE/USBPcap protocol findings.

There is no SET_FEATURE, Output Report, firmware, reset, or arbitrary command
path in this release.
