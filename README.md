# OpenJBLQuantum

Open-source Linux tooling for JBL Quantum headsets, initially focused on the
JBL Quantum 810 wireless dongle. The first milestone is intentionally narrow:
detect the device and document its USB topology without sending data to it.

## Current status

Research scaffold. On the initial CachyOS host, the dongle was detected as
`0ecb:2069` (`Harman International Inc`, `JBL Quantum810 Wireless`). It exposes
five USB Audio-class interfaces and one HID-class interface. See
[`docs/inventory/initial-cachyos.md`](docs/inventory/initial-cachyos.md).

Passive experiments have confirmed Input Reports for headset presence,
noise-control mode, Bluetooth state, microphone mute, and the 15-position
Game/Chat dial. Battery percentage remains a strong hypothesis, not a confirmed
mapping. The evidence ledger links every conclusion to its experiment.

## Safety boundary

The repository currently permits passive discovery only:

- read Linux `sysfs` and udev metadata;
- inspect descriptors already exported by the kernel;
- enumerate ALSA/PipeWire nodes when accessible;
- never open `/dev/hidraw*` or `/dev/bus/usb/*` for writing;
- never issue USB control transfers, HID feature/output reports, resets,
  detach drivers, firmware operations, or guessed commands.

Any future active experiment must first be documented with provenance,
expected bytes, rollback/risk analysis, and explicit opt-in.

## Quick start

```bash
python3 tools/detect_quantum.py
./tools/inventory.sh
```

Both tools are read-only. `inventory.sh` prints to stdout; redirect it into the
ignored `work/` directory if a local snapshot is wanted.

### Rust CLI prerequisite on CachyOS

The `openjblquantum` command does not exist until the project has been compiled
and installed. On CachyOS, install `rustup` from an interactive terminal, then
select the stable toolchain:

```bash
sudo pacman -S --needed rustup
rustup default stable
rustc --version
cargo --version
```

The Rust CLI is a dependency-free skeleton. Run it directly from the repository:

```bash
cargo check
cargo run -- scan
cargo run -- inspect
cargo run -- hid-descriptor
cargo run -- monitor --dry-run
cargo run -- export --format json
```

Only after that succeeds, optionally install the command for the current user:

```bash
cargo install --path .
openjblquantum scan
```

After changing the source, replace an older installed development build with:

```bash
cargo install --path . --force
openjblquantum inspect
```

If Cargo reports a successful install but Fish cannot find the command, add
Cargo's user binary directory to Fish's persistent path and start a new shell:

```fish
fish_add_path $HOME/.cargo/bin
openjblquantum scan
```

For a Bash session already open, update that session with:

```bash
export PATH="$HOME/.cargo/bin:$PATH"
openjblquantum scan
```

`inspect` reports the full standard USB interface/endpoint topology from the
descriptor blob already exported by the kernel and correlates matching ALSA
cards and PCM nodes. `export --format json` emits the same data as structured,
version-friendly JSON.

`hid-descriptor` passively decodes the HID report descriptor already exported
by the kernel. It reports usage pages, Report IDs, directions, and sizes; it
does not open a hidraw device or send a HID request.

`monitor --dry-run` resolves the matching hidraw node by HID identity without
opening it. `monitor` uses a read-only file handle and prints only spontaneous
Input Reports until interrupted with Ctrl-C. It contains no write path and
does not issue HID ioctls or USB control requests. Confirmed report meanings
are appended as annotations while the original bytes remain visible.

If the monitor reports permission denied, install the narrowly scoped udev
rule and reconnect the dongle:

```bash
sudo install -m 0644 packaging/udev/70-openjblquantum.rules /etc/udev/rules.d/70-openjblquantum.rules
sudo udevadm control --reload-rules
```

The rule matches only USB device `0ecb:2069`, HID interface `05`, and uses
systemd-logind's `uaccess` mechanism. It does not use world-writable mode,
create a privileged daemon, or grant access to unrelated hidraw devices.

## Repository layout

- `docs/protocol/`: evidence ledger and protocol hypotheses;
- `docs/reverse-engineering.md`: capture workflow and safety gates;
- `docs/windows-vm-capture.md`: controlled QuantumENGINE/USBPcap workflow;
- `docs/plan-v0.1.md`: milestone definition;
- `tools/`: passive host/device inventory utilities;
- `src/`: future Linux CLI, currently passive sysfs detection only;
- `captures/`: local capture staging; capture files are ignored by Git.

## Confirmed passive mappings

| Report | Values | Meaning |
|---|---|---|
| `0x02` | `00/01/02` | noise control off / ANC / TalkThru |
| `0x03` | `00/01/02` | Bluetooth disconnected / connected / pairing |
| `0x06` | `00/01` | microphone muted / active |
| `0x09` | `00/01` | headset off-disconnected / on-connected |
| `0x10` | `00–06, 08, 0a–10` | Game/Chat balance, normalized -7…+7 |
| `0x2f` | bit 1 | HID Telephony Phone Mute pulse |

Report `0x08` carrying `0x5a` is likely a 90% battery value, but is intentionally
excluded from confirmed mappings until another known charge level is observed.

## Scope

Linux is the development host. A Windows VM with QuantumENGINE,
USBPcap/Wireshark, and controlled USB passthrough is reserved for later
observation of known-good vendor traffic. No protocol claim should be treated
as fact until linked to repeatable evidence.

## Contributing

Do not submit firmware, proprietary binaries, personal identifiers, or raw
captures that may include unrelated USB traffic. Prefer small sanitized byte
sequences with timestamps removed and document hardware/firmware versions.

Licensed under the MIT License.
