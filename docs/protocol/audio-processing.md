# Output audio processing

## Equalizer

QuantumENGINE exposes a 10-band output equalizer at 31, 62, 125, 250, and
500 Hz and 1, 2, 4, 8, and 16 kHz, each ranging from -12 dB to +12 dB.

Changing from Bass Boost to Flat and back generated no USB traffic (EVT-034).
The equalizer is host-side DSP, not a dongle/headset setting. A Linux
implementation should use PipeWire filters, EasyEffects-compatible processing,
or another host DSP layer rather than vendor USB writes.

Spatial-audio controls remain to be classified.
