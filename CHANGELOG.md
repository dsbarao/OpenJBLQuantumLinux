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
- show a battery-shaped panel indicator with headphones, percentage, and
  green/yellow/red charge thresholds;
- detect the USB-C charging connection as `0ecb:206a` and show a cyan charging
  state with a lightning indicator in the Plasma widget;
- add strictly allowlisted USB controls for ambient mode, global lighting, and
  sidetone, exposed as menus in the Plasma widget;
- replace floating control menus with polished in-widget expandable sections
  and keep the panel icon compact by moving the percentage into the detail view;
- reduce the panel indicator to standard icon proportions and refresh charging
  state and battery percentage automatically every five seconds;
- add a read-only user service that caches confirmed HID events and exposes
  current ambient, lighting, microphone, battery, Bluetooth, and Game/Chat
  state to the widget; successful allowlisted commands also update the cache;
- visualize the physical Game/Chat dial as a live Chat-to-Game balance bar in
  the Plasma widget;
- document controlled QuantumENGINE/USBPcap protocol findings.

There is no SET_FEATURE, Output Report, firmware, reset, or arbitrary command
path in this release.
