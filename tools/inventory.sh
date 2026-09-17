#!/usr/bin/env bash
set -u

# Read-only inventory. This script intentionally does not use sudo and never
# opens hidraw or USB device nodes. Individual commands may fail in sandboxes.

echo '# Host'
uname -a
cat /etc/os-release

echo '# Toolchain'
command -v git >/dev/null && git --version || true
command -v rustc >/dev/null && rustc --version || true
command -v cargo >/dev/null && cargo --version || true
command -v python3 >/dev/null && python3 --version || true

echo '# USB topology'
command -v lsusb >/dev/null && lsusb || true
command -v lsusb >/dev/null && lsusb -t || true

echo '# JBL sysfs discovery'
python3 "$(dirname "$0")/detect_quantum.py" || true
python3 "$(dirname "$0")/parse_descriptors.py" || true

echo '# Audio services and devices'
command -v wpctl >/dev/null && wpctl status || true
command -v pactl >/dev/null && pactl info || true
command -v aplay >/dev/null && aplay -l || true
command -v arecord >/dev/null && arecord -l || true
