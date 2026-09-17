# Local capture staging

Raw USB captures are ignored by Git. They may contain serial numbers, host
activity, or proprietary payloads. Keep original captures local and record a
SHA-256 digest in the evidence ledger. Only commit minimal, sanitized excerpts
when redistribution is appropriate and useful.
