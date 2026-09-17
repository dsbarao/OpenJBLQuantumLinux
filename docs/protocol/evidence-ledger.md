# Evidence ledger

| ID | Date | Host/device | Action | Artifact SHA-256 | Result | Status |
|---|---|---|---|---|---|---|
| INV-001 | 2026-09-16 | CachyOS / 0ecb:2069 | Passive sysfs and udev inventory | n/a | USB topology documented | Observed |
| HID-001 | 2026-09-16 | CachyOS / 0ecb:2069 | Read kernel-exported HID report descriptor | `8b4f587e29256e8785ab98532208eaf9db35cf0732ca7e527541152c2c959691` | 553-byte descriptor; report layout documented | Observed |
| EVT-001 | 2026-09-16 | CachyOS / 0ecb:2069 | Headset switched off, then on; read-only hidraw monitor | conversation transcript | `09 00` on shutdown, `09 01` plus state burst on startup | Observed |
| EVT-002 | 2026-09-16 | CachyOS / 0ecb:2069 | Headset switched off only; read-only monitor | conversation transcript | Only `09 00` observed | Confirmed |
| EVT-003 | 2026-09-16 | CachyOS / 0ecb:2069 | Headset switched on only; read-only monitor | conversation transcript | `09 01` followed by repeatable state burst | Confirmed |
| EVT-004 | 2026-09-16 | CachyOS / 0ecb:2069 | Microphone boom raised | conversation transcript | `06 01`, `06 00`, `2f 00` | Observed |
| EVT-005 | 2026-09-16 | CachyOS / 0ecb:2069 | Microphone boom lowered | conversation transcript | `2f 02`, `06 01`, `2f 00` | Observed |
| EVT-006 | 2026-09-16 | CachyOS / 0ecb:2069 | Three slow boom up/down cycles | conversation transcript | Stable alternation confirms `06 00` muted, `06 01` active | Confirmed |
| EVT-007 | 2026-09-16 | CachyOS / 0ecb:2069 | Dedicated microphone mute button pressed twice | conversation transcript | Button converges to same `06 00/01` state as boom | Confirmed |
| EVT-008 | 2026-09-16 | CachyOS / 0ecb:2069 | Main volume wheel moved; hidraw and ALSA compared | `afcdc2b576bcc94c4af2ef19b413c741ab634222d48330149b329afa7f4f0b44` | No HID event or ALSA state change | Confirmed local control |
| EVT-009 | 2026-09-16 | CachyOS / 0ecb:2069 | Game/Chat dial moved Game then Chat; ALSA compared | `afcdc2b576bcc94c4af2ef19b413c741ab634222d48330149b329afa7f4f0b44` | Report `10` absolute range `00` Chat to `10` Game; ALSA unchanged | Confirmed |
| EVT-010 | 2026-09-16 | CachyOS / 0ecb:2069 | Slow Game/Chat sweep from Chat toward Game | conversation transcript | Unit-step values observed; `07/09` absent around center | Observed |
| EVT-011 | 2026-09-16 | CachyOS / 0ecb:2069 | Slow reverse Game/Chat sweep | conversation transcript | Confirms 15 states: `00–06`, `08`, `0a–10` | Confirmed |
| EVT-012 | 2026-09-16 | CachyOS / 0ecb:2069 | USB-C charging cable connected then disconnected | conversation transcript | `08 5a` emitted on each transition; payload unchanged | Strong hypothesis |
| EVT-013 | 2026-09-16 | CachyOS / 0ecb:2069 | Headset power cycle while USB-C charging cable connected | conversation transcript | Startup snapshot unchanged; `08 5a` repeated once | Observed negative |
| EVT-014 | 2026-09-16 | CachyOS / 0ecb:2069 | ANC toggled repeatedly | conversation transcript | Six transitions confirm `02 00` off, `02 01` on | Confirmed |
| EVT-015 | 2026-09-16 | CachyOS / 0ecb:2069 | Bluetooth button short press under monitor | conversation report | No hidraw Input Report observed | Observed negative |
| EVT-016 | 2026-09-16 | CachyOS / 0ecb:2069 | Bluetooth long press, then short press | conversation transcript | `03 02` pairing on; `03 00` pairing off | Confirmed |
| EVT-017 | 2026-09-16 | CachyOS / 0ecb:2069 | Known Bluetooth device connected, then disconnected | conversation transcript | `03 01` connected; `03 00` disconnected | Confirmed |
| EVT-018 | 2026-09-16 | CachyOS / 0ecb:2069 | ANC/TalkThru mode cycled twice | conversation transcript | Confirms `02 00` off, `02 01` ANC, `02 02` TalkThru | Confirmed |
| EVT-019 | 2026-09-16 | CachyOS / 0ecb:2069 | 3.5 mm cable connected to headset then disconnected; other end already on PC | conversation transcript | `02 00` on connect, `02 01` on disconnect; no dedicated jack report | Observed |
| EVT-020 | 2026-09-16 | CachyOS / 0ecb:2069 | 3.5 mm cable cycle with noise control already off | conversation report | No Input Report observed | Confirmed negative |
| EVT-021 | 2026-09-16 | Windows 11 VM / QuantumENGINE / 0ecb:2069 | Stop and restart QuantumENGINE service under USBPcap | `7cd95ebf7ee93272962bd6cfcb9b87c7b2e27f39914d33b591cb39fa7548381a` | Feature-report startup sequence captured; Report `0x49` returned `0x5a` | Observed |
| EVT-022 | 2026-09-16 | Windows 11 VM / QuantumENGINE / 0ecb:2069 | Disable, then enable lighting | `ab3d8fd8f8ed0efb9c7ba9d1c0136f784680a9c417239b6dec8c4ba9e74a7458` | SET_FEATURE `4b 00/01`, followed by Input `07 00/01`; Input `08 55` confirms changing battery percentage | Confirmed |
| EVT-023 | 2026-09-16 | Windows 11 VM / QuantumENGINE / 0ecb:2069 | Enable, then disable light synchronization | `ce1d78f4ab315f8308ae883298720ca9c9c25509f3c429209d465d114fa1bd19` | No dedicated synchronization field observed; application rewrote per-zone `0x4c/0x4d` data | Observed |
| EVT-024 | 2026-09-16 | Windows 11 VM / QuantumENGINE / 0ecb:2069 | Change Logo segment 0 from `#33ffcc` to `#112233`, then restore | `84fadcc0d9f887c54aca58e07b4259628a422f3ac0aa7f886cea154f46e26812` | Report `0x4d` bytes 3–5 are literal RGB; zone and segment indices confirmed | Confirmed |
| EVT-025 | 2026-09-16 | Windows 11 VM / QuantumENGINE / 0ecb:2069 | Change Logo segment 0 from Wave to Solid, then restore | `076255b70b39e4901c6cd064075572240c42b5c75726a84daab3194c79848ed7` | Report `0x4d` effect byte: `01` Solid, `02` Wave | Confirmed |
| EVT-026 | 2026-09-16 | Windows 11 VM / QuantumENGINE / 0ecb:2069 | Change Logo segment 0 from Wave to Breathing, Glitch, then Wave | `ecd103ce4fd66f6917746bbd86193357694c6d651e513c9500ca3371fb2c01a6` | Report `0x4d` effect byte: `00` Breathing, `03` Glitch; return to `02` Wave | Confirmed |
| EVT-027 | 2026-09-16 | Windows 11 VM / QuantumENGINE / 0ecb:2069 | Change Logo animation speed through 1.0x, 1.5x, 2.0x, then 0.5x | `73f515aa206431ddb706d28a0144b884ba1d172c217a9148fb577d606cf1c46e` | Report `0x4c` speed byte: `64`, `4b`, `32`, `19` for 0.5x, 1.0x, 1.5x, 2.0x | Confirmed |
| EVT-028 | 2026-09-16 | Windows 11 VM / QuantumENGINE / 0ecb:2069 | Enable, then disable microphone DRC | `379cae8ec6c14a6aef78ea9385043a95638eea720a6cf5852d6ab7c10fb31bbc` | No USB transfer occurred; DRC is host-side processing | Confirmed negative |
| EVT-029 | 2026-09-16 | Windows 11 VM / QuantumENGINE / 0ecb:2069 | Cycle sidetone through low, medium, high, then off | `fca4f1130775287f8d4f96c1bd438ac0da0e2ac8fcd4aef51b4a405c16f7ce93` | Feature Report `0x5d`: `00` off, `01` low, `02` medium, `03` high | Confirmed |
| EVT-030 | 2026-09-16 | Windows 11 VM / QuantumENGINE / 0ecb:2069 | Cycle microphone noise reduction through low, medium, high, then off | `80fa3c6e5b25dbbfec007855dbfbe4ff90ac02c90e4332fdffe47e895cf7371b` | No USB transfer occurred; noise reduction is host-side processing | Confirmed negative |
