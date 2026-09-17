# Microphone controls

Status: initial controlled captures in progress.

## Host-side controls

QuantumENGINE's DRC toggle produces no USB traffic (EVT-028). It is a host-side
audio-processing feature and should not be implemented as a device protocol
write. A future Linux implementation can use PipeWire or another DSP layer.

## Device controls

The following QuantumENGINE controls remain to be classified:

- microphone gain;
- sidetone (`Tom lateral`): off, low, medium, high;
- noise reduction: off, low, medium, high;
- microphone equalizer.

Physical microphone state is already confirmed on Input Report `0x06`:
`00` muted and `01` active.
