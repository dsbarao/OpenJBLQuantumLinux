# Contributing

OpenJBLQuantum accepts reproducible, safety-scoped research for JBL Quantum
hardware on Linux.

Before submitting a change:

```bash
cargo fmt -- --check
cargo test
cargo clippy --all-targets -- -D warnings
udevadm verify packaging/udev/70-openjblquantum.rules
```

Protocol claims must link to an experiment in `docs/protocol/experiments/` and
distinguish observed facts, hypotheses, and confirmed mappings. Do not commit
raw captures, serial numbers, vendor binaries, firmware, or unrelated USB
traffic. Active output/feature reports require a separately reviewed safety
plan and are outside the current v0.1 scope.
