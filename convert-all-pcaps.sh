#!/usr/bin/env bash
# convert-all-pcaps_debug.sh
# Converts only PCAPs that produce valid 22000 entries; creates per-file logs for debugging.
# By Hackazillarex (improved)

set -euo pipefail
shopt -s nullglob

OUTPUT_FILE="all.22000"

# Check tool
if ! command -v hcxpcapngtool &>/dev/null; then
  echo "Error: hcxpcapngtool not found. Install hcxtools."
  exit 1
fi

# Find pcaps
PCAPS=( *.pcap *.pcapng )
if [ ${#PCAPS[@]} -eq 0 ]; then
  echo "No .pcap or .pcapng files in $(pwd)"
  exit 0
fi

echo "Found ${#PCAPS[@]} capture files:"
for f in "${PCAPS[@]}"; do printf "  %s\n" "$f"; done

# Temp dir for outputs and logs
TMPDIR=$(mktemp -d /tmp/convert-debug.XXXX)
mkdir -p "$TMPDIR"/logs
echo "Debug files in: $TMPDIR"

kept=0
skipped=0

for pcap in "${PCAPS[@]}"; do
  base="${pcap##*/}"
  base="${base%.*}"
  out="$TMPDIR/${base}.22000"
  log="$TMPDIR/logs/${base}.log"

  echo
  echo "Processing: $pcap"
  echo "PCAP: $pcap" >"$log"
  echo "Attempt: plain conversion" >>"$log"

  # Try plain conversion first
  hcxpcapngtool -o "$out" "$pcap" >>"$log" 2>&1 || true

  if [ -s "$out" ]; then
    echo "  -> kept (plain) : $out"
    echo "Kept by plain conversion" >>"$log"
    kept=$((kept+1))
    continue
  fi

  echo "  -> plain produced no output, trying --pmkid fallback" >>"$log"
  # Try PMKID extraction
  hcxpcapngtool -o "$out" --pmkid "$pcap" >>"$log" 2>&1 || true

  if [ -s "$out" ]; then
    echo "  -> kept (pmkid) : $out"
    echo "Kept by pmkid conversion" >>"$log"
    kept=$((kept+1))
    continue
  fi

  # No valid conversion
  echo "  -> No valid handshake found or conversion failed for: $pcap"
  echo "Conversion failed or produced no usable 22000 hash." >>"$log"
  skipped=$((skipped+1))
done

echo
echo "Summary: kept=$kept skipped=$skipped"
echo

# Merge kept files if any
shopt -s nullglob
KEPT=( "$TMPDIR"/*.22000 )
if [ ${#KEPT[@]} -gt 0 ]; then
  echo "Merging ${#KEPT[@]} kept 22000 file(s) into $OUTPUT_FILE"
  # Remove blank lines and duplicate lines
  awk 'NF' "${KEPT[@]}" | sort -u > "$OUTPUT_FILE"
  echo "Merged into: $OUTPUT_FILE (size: $(du -h "$OUTPUT_FILE" | cut -f1))"
else
  echo "No 22000 outputs were created; no $OUTPUT_FILE produced."
fi

echo
echo "Per-file logs are in: $TMPDIR/logs"
echo "Keep them for debugging; remove $TMPDIR when done."

# Do not auto-delete TMPDIR so you can inspect logs

