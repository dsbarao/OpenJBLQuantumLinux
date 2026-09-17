# Microphone controls

Status: initial controlled captures in progress.

## Host-side controls

QuantumENGINE's DRC toggle (EVT-028), noise-reduction levels (EVT-030),
microphone gain slider (EVT-031), and five-band microphone equalizer (EVT-032)
produce no USB traffic. They are host-side audio controls and should not be
implemented as device protocol writes. A future Linux implementation can use
PipeWire or another DSP layer. The gain slider should map to capture-source
volume rather than a vendor command.

## Device controls

### Sidetone

Feature Report `0x5d` controls the hardware sidetone level:

```text
5d 00  # off
5d 01  # low
5d 02  # medium
5d 03  # high
```

These four values are implemented through the Linux client's strict write
allowlist.

The Portuguese QuantumENGINE UI labels the three levels `Graves`, `Médios`,
and `Agudos`; controlled capture shows these are ordinal sidetone intensities,
not frequency bands.

### Host DSP equalizer

The microphone equalizer exposes 200 Hz, 500 Hz, 2 kHz, 4 kHz, and 6 kHz bands
with a -12 dB to +12 dB range. Changing between Natural and Bright presets
generated no device traffic, confirming host-side DSP.

Physical microphone state is already confirmed on Input Report `0x06`:
`00` muted and `01` active.
