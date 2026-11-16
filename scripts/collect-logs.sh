#!/bin/bash
# Collect first-boot logs from a qqcandy device.
# Usage: ./collect-logs.sh [output-dir]
set -e

OUT="${1:-qqcandy-logs-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$OUT"

adb wait-for-device
adb root >/dev/null 2>&1 || true
adb wait-for-device

adb shell dmesg                              > "$OUT/dmesg.txt" 2>&1 || true
adb logcat -d                                > "$OUT/logcat.txt" 2>&1 || true
adb shell getprop                            > "$OUT/getprop.txt" 2>&1 || true
adb shell 'cat /proc/cmdline'                > "$OUT/cmdline.txt" 2>&1 || true
adb shell 'ls -l /dev/block/by-name'         > "$OUT/by-name.txt" 2>&1 || true
adb shell 'lpdump /dev/block/by-name/super'  > "$OUT/lpdump.txt" 2>&1 || true
adb shell 'cat /proc/partitions'             > "$OUT/partitions.txt" 2>&1 || true
adb shell 'dumpsys display'                  > "$OUT/display.txt" 2>&1 || true
adb shell 'dumpsys fingerprint'              > "$OUT/fingerprint.txt" 2>&1 || true
adb shell 'getevent -pl'                     > "$OUT/getevent.txt" 2>&1 || true
adb shell 'lsmod'                            > "$OUT/lsmod.txt" 2>&1 || true

echo "logs written to $OUT"
echo "--- denial summary ---"
grep -iE 'avc: denied|failed to start|init:.*error' "$OUT/logcat.txt" "$OUT/dmesg.txt" 2>/dev/null | head -50 || true
