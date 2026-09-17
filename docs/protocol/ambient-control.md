# Ambient sound control

Status: command and confirmation values confirmed through controlled
QuantumENGINE capture and implemented through the Linux client's strict
allowlist.

## Command

Feature Report `0x46` selects the device mode:

```text
46 00  # ambient control off
46 01  # ANC
46 02  # TalkThru
```

## Confirmation and physical changes

Input Report `0x02` publishes the resulting mode with the same values:

```text
02 00  # off
02 01  # ANC
02 02  # TalkThru
```

The Input Report is emitted both after QuantumENGINE commands and after use of
the physical headset control. EVT-033 observed command-to-confirmation delays
of approximately 71 ms for ANC and 463–497 ms for TalkThru/off.
