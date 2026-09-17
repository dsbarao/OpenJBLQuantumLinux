# Lighting protocol

Status: mapped from controlled QuantumENGINE USBPcap captures. Global on/off
and a deliberately small set of full-profile solid colors are implemented
through the Linux client's strict allowlist. Arbitrary colors, partial-profile
writes, animation selection, and OpenRGB integration remain out of scope.

## Global state

Feature Report `0x4b` controls the global lighting state:

```text
4b 00  # disabled
4b 01  # enabled
```

Input Report `0x07` confirms the resulting state with the same `00`/`01`
payload.

## Zone header

Observed Feature Report `0x4c` form:

```text
4c ZZ 64 05
```

`ZZ` is the zone index (`00` Logo, `01` Ring). The third byte is an inverse
animation-speed value:

| QuantumENGINE speed | Decimal | Hex |
|---|---:|---:|
| 0.5x | 100 | `64` |
| 1.0x | 75 | `4b` |
| 1.5x | 50 | `32` |
| 2.0x | 25 | `19` |

The final byte remained `05` while the UI showed five segments. It is therefore
a strong segment-count hypothesis, but has not been independently varied.

## Segment definition

Feature Report `0x4d`:

```text
4d ZZ SS RR GG BB EE PP
```

| Field | Meaning | Status |
|---|---|---|
| `ZZ` | zone: `00` Logo, `01` Ring | Confirmed |
| `SS` | zero-based segment index | Confirmed |
| `RR GG BB` | literal RGB color | Confirmed |
| `EE` | effect identifier | Confirmed |
| `PP` | segment position/order parameter | Strong hypothesis |

Confirmed effect identifiers:

| ID | QuantumENGINE label |
|---|---|
| `00` | Breathing (`Respiração`) |
| `01` | Solid |
| `02` | Wave |
| `03` | Glitch (`Falha`) |

All four effects exposed by QuantumENGINE are mapped. Observed five-segment
profiles used position values `00, 02, 04, 06, 08` in segment order.

QuantumENGINE sends complete profiles for both zones when one segment changes.
The application's synchronization switch appears to copy/reapply zone data and
does not expose a distinct device-side synchronization flag.

## Linux solid-color presets

OpenJBLQuantum applies a preset by writing a complete five-segment Solid
profile to both Logo and Ring, followed by global lighting enable. It never
changes one segment in isolation. The allowlisted presets are blue (`#0029ff`),
cyan (`#33ffcc`), magenta (`#ff00cc`), red (`#ff2020`), green (`#20ff66`), and
white (`#ffffff`). The last three use the confirmed literal RGB fields but are
OpenJBLQuantum convenience presets rather than captured vendor defaults.

The widget can target both zones, Logo only, or Ring only. Even for an
independent change, OpenJBLQuantum reconstructs and sends both complete zone
profiles from its confirmed cache. If the other zone is unknown, it refuses
the operation and requires a synchronized preset first rather than guessing.
