# Microphone controls

Status: initial controlled captures in progress.

## Host-side controls

QuantumENGINE's DRC toggle produces no USB traffic (EVT-028). It is a host-side
audio-processing feature and should not be implemented as a device protocol
write. A future Linux implementation can use PipeWire or another DSP layer.

## Device controls

### Sidetone

Feature Report `0x5d` controls the hardware sidetone level:

```text
5d 00  # off
5d 01  # low
5d 02  # medium
5d 03  # high
```

The Portuguese QuantumENGINE UI labels the three levels `Graves`, `Médios`,
and `Agudos`; controlled capture shows these are ordinal sidetone intensities,
not frequency bands.

### Remaining controls

The following QuantumENGINE controls remain to be classified:

- microphone gain;
- noise reduction: off, low, medium, high;
- microphone equalizer.

Physical microphone state is already confirmed on Input Report `0x06`:
`00` muted and `01` active.
