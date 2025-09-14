# convert-all-pcaps.sh

**Simple automation script by Hackazillarex**  

This Bash script automatically converts all `.pcap` or `.pcapng` files in the current directory into a single Hashcat 22000 format file. This is useful for preparing WPA/WPA2 handshake captures from tools like Pwnagotchi or Wireshark for password cracking with Hashcat.

---

## Features

- Automatically detects all `.pcap` and `.pcapng` files in the folder.
- Converts them into a single `all.22000` Hashcat-compatible file.
- Checks for `hcxpcapngtool` installation before running.
- Provides feedback on the number of files found and conversion success.

---

## Requirements

- Linux / macOS with Bash
- [hcxtools](https://github.com/ZerBea/hcxtools) installed (provides `hcxpcapngtool`)

```bash
sudo apt install hcxtools  # Debian/Ubuntu/Kali
Usage

Place all your .pcap or .pcapng handshake files in a single directory.

Copy the script into that directory:

cp convert-all-pcaps.sh /path/to/your/pcap/folder
chmod +x convert-all-pcaps.sh

Run the script:
./convert-all-pcaps.sh


After execution, you should see a file named all.22000 in the same directory (or the name you specified in the script).
