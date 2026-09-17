# Plan v0.1 — safe detection and topology

## Definition of done

- [x] Reliably detect the Quantum 810 dongle on Linux by VID/PID.
- [x] Report identity, sysfs path, interfaces, active alternate settings, endpoint
  address/direction/type/max-packet/interval, and bound drivers.
- [x] Correlate Game/Chat/microphone functions with ALSA nodes.
- [ ] Correlate the same functions with PipeWire nodes from the desktop session.
- [x] Export a stable, versioned JSON inventory without serial numbers by default.
- [x] Add fixture-based tests that run without hardware.
- [x] Document permissions without granting broad access to unrelated HID devices.
- [x] Publish a sanitized, reproducible initial hardware report.
- [x] Decode kernel-exported HID report structure without active requests.
- [x] Monitor spontaneous Input Reports through a read-only handle.

## Work items

1. [x] Install the Rust toolchain through the user's preferred CachyOS method.
2. [x] Turn the Rust scanner skeleton into the canonical CLI and add fixtures.
3. [x] Parse the raw USB descriptor blob read-only to include every alternate
   setting, not only the currently selected sysfs alternate setting.
4. [ ] Run PipeWire inventory in the user's desktop session.
5. [x] Add a narrowly matched udev rule for read-only monitoring; do not grant
   access to unrelated `hidraw` devices.
6. [ ] Prepare the Windows VM capture checklist for v0.2 research.

## Explicit non-goals for v0.1

- Sending HID output/feature reports or USB control transfers.
- Firmware updates, device resets, driver detach, or interface claiming.
- Implementing EQ, lighting, battery polling, or spatial audio controls.
- Shipping raw captures or vendor binaries.
