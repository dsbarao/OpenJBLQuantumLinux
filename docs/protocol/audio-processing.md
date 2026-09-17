# Output audio processing

## Equalizer

QuantumENGINE exposes a 10-band output equalizer at 31, 62, 125, 250, and
500 Hz and 1, 2, 4, 8, and 16 kHz, each ranging from -12 dB to +12 dB.

Changing from Bass Boost to Flat and back generated no USB traffic (EVT-034).
The equalizer is host-side DSP, not a dongle/headset setting. A Linux
implementation should use PipeWire filters, EasyEffects-compatible processing,
or another host DSP layer rather than vendor USB writes.

## Spatial audio

Disabling and re-enabling spatial audio with DTS Headphone:X v2.0 selected
generated no USB traffic (EVT-035). The enable switch controls a host-side
spatial-processing chain; the headset receives the resulting audio stream and
does not store this state. Selection between DTS and Quantum Spatial remains to
be tested separately.
