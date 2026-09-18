# JanBaLinux SonicCore: technical identity

The public software name is **JanBaLinux SonicCore** and its technical
identifier is `janbalinux-soniccore`. The command-line client is `soniccore`;
the daemon executable is `soniccore-daemon`; and the user unit is
`janbalinux-soniccore.service`.

This project was made public before its first release or installation. There
are no deployed users, state files, widgets, desktop entries, D-Bus clients, or
scripts requiring a compatibility transition. The project therefore uses the
new identifiers directly, without legacy aliases or migration code.

## Technical identifiers

| Interface | Identifier |
|---|---|
| Cargo package | `janbalinux-soniccore` |
| CLI | `soniccore` |
| Daemon | `soniccore-daemon` |
| systemd user unit | `janbalinux-soniccore.service` |
| Plasma widget | `org.janbalinux.soniccore` |
| D-Bus name and interface | `org.janbalinux.soniccore.State` |
| D-Bus object path | `/org/janbalinux/soniccore/State` |
| Runtime cache | `$XDG_RUNTIME_DIR/janbalinux-soniccore-state.json` |
| Desktop entry | `janbalinux-soniccore.desktop` |
| udev rule | `70-janbalinux-soniccore.rules` |
| Project website | `https://github.com/dsbarao/JanBaLinux-SonicCore` |

The rebrand does not change HID reports, USB matching, VID/PID values,
allowlists, or protocol behavior. **JBL Quantum 810 Wireless** identifies the
supported hardware, while `QuantumENGINE`, USB strings, captures, fixtures, and
reverse-engineering evidence identify vendor software or observed behavior and
are intentionally preserved.

## License attribution

The `OpenJBLQuantum contributors` copyright line in `LICENSE` is retained as
historical legal attribution. It is not an active technical identifier and the
MIT license text is unchanged.
