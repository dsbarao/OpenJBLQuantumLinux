# JanBaLinux SonicCore: identity and compatibility

The public software name is **JanBaLinux SonicCore**. Its short description is
“Open-source gaming headset control and audio platform for Linux.” The first
supported device is **JBL Quantum 810 Wireless**; that hardware name does not
identify the software brand. The README describes the future platform direction.

This change updates presentation and documentation only. It does not add
features, change HID reports or allowlists, change VID/PID matching, install
anything, or migrate existing user state.

## Existing installations

Continue using the documented commands and installation/update helpers. The
launcher and Plasma widget are now listed as **JanBaLinux SonicCore**. The
widget's device label and headset photograph still identify the actual hardware;
the generic `audio-headphones` application icon and lighting icons remain valid.

The following implementation identifiers are deliberately retained. They are
compatibility interfaces, not the project's public brand.

| Identifier | Locations / purpose | Breakage avoided |
|---|---|---|
| `openjblquantum` | Cargo package in `Cargo.toml` and `Cargo.lock`, default binary, CLI usage, README commands, scripts, launcher, service, widget | Broken shell commands, Cargo upgrades/uninstalls, and executable references |
| `openjblquantum-state.service` | Packaged unit and `$HOME/.config/systemd/user/` | Lost enablement, duplicate daemons, stale installation/removal targets |
| `org.openjblquantum.battery` | Plasma package directory, plugin ID, installation/removal helpers | Lost panel instances, widget settings, or in-place package upgrades |
| `openjblquantum-battery.desktop` | Packaged launcher and `$HOME/.local/share/applications/` | Broken pinned launchers or duplicate menu entries |
| `org.openjblquantum.State`, `/org/openjblquantum/State` | D-Bus service, interface, object path in Rust and QML | Lost state-change signals between existing daemon/widget versions |
| `$XDG_RUNTIME_DIR/openjblquantum-state.json` | Runtime cache in `src/state.rs` | Lost confirmed state, including per-zone colors used for safe complete profiles |
| `70-openjblquantum.rules` | Packaged and system-wide udev rule, installation/removal documentation | Duplicate rules, stale privileged files, or changed device access |
| `openjblquantum-usb-power` | Internal watcher thread name | Unnecessary changes to diagnostic identifiers during a presentation-only update |

Versions, JSON schemas, dependency versions, and protocol behavior are unchanged.
There is one Cargo package; no additional crates, AppStream metadata, GitHub
Actions workflows, release scripts, or screenshots were present in the audited
tracked tree. The existing PNG is device artwork, not a project logo.

## Other retained references

- The current project URL is `https://github.com/dsbarao/OpenJBLQuantumLinux`,
  retained in Plasma metadata until a remote rename is explicitly authorized.
- `win11-openjblquantum-baseline.img` in the VM capture guide is an existing
  baseline path; renaming it in instructions could misidentify a recovery image.
- The original `OpenJBLQuantum contributors` copyright notice in `LICENSE`
  remains as historical attribution. The MIT license text is unchanged.
- `JBL`, `Quantum`, `Quantum 810`, and `Quantum810` remain where they identify
  the supported headset, literal USB/interface strings, fixture and detection
  names, Rust device identifiers, udev matching context, or hardware search
  keywords. Literal USB strings are not normalized to the marketing spelling.
- `QuantumENGINE` and `Quantum Spatial` identify the vendor software and modes
  observed during reverse engineering. Capture hashes, bytes, report IDs,
  experiment results, and hardware evidence are preserved.
- The evidence ledger's references to our CLI/widget now use the current public
  name; those entries describe the same historical experiments and results.

## TODO: migration for a future major version

Before changing any compatibility identifier, design and validate a coordinated
migration covering:

1. A new Cargo package/binary name with a transition alias for existing CLI
   callers and reliable upgrade/uninstall handling.
2. Service enablement migration that stops the previous instance before starting
   its replacement and prevents two readers from owning the HID event stream.
3. Plasma plugin identity and panel configuration migration, plus desktop file
   replacement that preserves pinned launchers.
4. D-Bus transition compatibility and cache migration that preserves confirmed
   values and schema semantics; never invent missing hardware state.
5. Explicit replacement/removal of the old privileged udev rule, retaining the
   exact device/interface match and access policy.
6. Upgrade, rollback, mixed-version interoperability, and uninstall checks.

Do not rename these identifiers piecemeal. No migration is needed for this
presentation-only rebranding.

## Repository name

The recommended future repository name is `JanBaLinux-SonicCore`, matching the
independent public identity. Repository naming is separate from installed
identifiers. After an authorized rename, update the project website URL and
local Git remote, then review external links and integrations. This change does
not rename the remote repository, change its settings, push, or create a release.
