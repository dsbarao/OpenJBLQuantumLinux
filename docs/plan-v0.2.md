# Plan v0.2 — allowlisted read-only status

## Safety gate

- [x] Derive the battery query from captured QuantumENGINE traffic.
- [x] Confirm Feature Report `0x49` against spontaneous Input Report `0x08` at
  two different charge levels (90% and 85%).
- [x] Open hidraw with read access only.
- [x] Expose only Linux `HIDIOCGFEATURE`; add no SET_FEATURE/output-report API.
- [x] Validate report ID, length, and percentage range.
- [x] Provide a dry run that does not open the device.
- [x] Cover parsing and the Linux ioctl request number with hardware-free tests.
- [x] Provide versioned JSON output without adding another device query.

## Initial scope

`openjblquantum status` reads battery Feature Report `0x49` and prints both the
validated percentage and raw two-byte response. Other captured Feature Reports
remain documentation-only until independently mapped and allowlisted.

Hardware validation on CachyOS returned `49 3c`, correctly decoded as 60%.
This is the third independently observed battery level after 90% and 85% in
the controlled captures.

The installed release build was also validated with both human-readable and
schema-1 JSON output. JSON dry-run returned `null` status fields without opening
the device; the live JSON query returned `battery_percent: 60` and
`raw_feature: "49 3c"`.

Device writes, firmware operations, resets, driver detach, and guessed commands
remain out of scope.
