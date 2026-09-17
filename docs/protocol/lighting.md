# Lighting protocol

Status: partially mapped from controlled QuantumENGINE USBPcap captures. These
writes are documentation only and are not implemented by the Linux client.

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

`ZZ` is the zone index (`00` Logo, `01` Ring). The capture UI showed speed
`0.5x` and five segments while the trailing bytes were `64 05`; their exact
semantics require independent speed and segment-count experiments.

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
| `01` | Solid |
| `02` | Wave |

Breathing and Glitch have not yet been mapped. Observed five-segment profiles
used position values `00, 02, 04, 06, 08` in segment order.

QuantumENGINE sends complete profiles for both zones when one segment changes.
The application's synchronization switch appears to copy/reapply zone data and
does not expose a distinct device-side synchronization flag.
