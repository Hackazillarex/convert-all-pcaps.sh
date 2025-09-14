#!/bin/bash
# convert-all-pcaps.sh
# Converts all .pcap/.pcapng files in the current directory to a single Hashcat 22000 file.
# Simple automation script by Hackazillarex

# Change this to the output filename you want
OUTPUT_FILE="all.22000"

# Check that hcxpcapngtool is installed
if ! command -v hcxpcapngtool &>/dev/null; then
    echo "Error: hcxpcapngtool not found. Install hcxtools."
    exit 1
fi

# Check for pcap files
shopt -s nullglob
PCAPS=(*.pcap *.pcapng)
if [ ${#PCAPS[@]} -eq 0 ]; then
    echo "No .pcap or .pcapng files found in the current directory."
    exit 1
fi

echo "Found ${#PCAPS[@]} capture files:"
for f in "${PCAPS[@]}"; do
    echo "  $f"
done

# Convert to 22000
echo "Converting all PCAPs to $OUTPUT_FILE ..."
hcxpcapngtool -o "$OUTPUT_FILE" "${PCAPS[@]}"

# Check result
if [ -f "$OUTPUT_FILE" ]; then
    echo "Conversion successful! Output file: $OUTPUT_FILE"
else
    echo "No valid handshakes found or conversion failed."
fi
