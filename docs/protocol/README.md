# Protocol research

Early HID protocol mappings are now documented through controlled passive
observations and QuantumENGINE USBPcap comparisons. Linux support remains
read-only; observed vendor writes are documented but are not replayed.

Current consolidated mappings:

- [`lighting.md`](lighting.md): lighting state, zones, segments, RGB, and known
  effect identifiers.
- [`microphone.md`](microphone.md): device versus host-side microphone controls.
- [`ambient-control.md`](ambient-control.md): ANC and TalkThru command/confirmation
  mapping.
- [`audio-processing.md`](audio-processing.md): host-side output DSP controls.

Use `evidence-ledger.md` to index experiments and sanitized artifacts. Keep
raw captures outside Git in `captures/`. Protocol documents must distinguish:

- **Observed:** bytes or descriptors directly measured;
- **Hypothesis:** a proposed meaning not yet validated;
- **Confirmed:** reproduced with controlled changes and negative controls.
