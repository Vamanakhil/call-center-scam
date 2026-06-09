# 17 — Tool: Belkasoft RAM Capturer

## When to use it
- **First action** on a live system, after photographing the screen.
- Captures the **entire physical RAM** to a `.mem` file on an external USB.
- Works on Windows XP through Windows 11 / Server 2022, 32-bit and 64-bit.
- Free, no installation required, runs as Administrator.

## Pre-flight checklist
- [ ] USB stick (NTFS or exFAT) with at least 2× the RAM size of the target system.
- [ ] BelkasoftRAMCapturer.exe (and the 64-bit version) on the USB.
- [ ] The USB is on a write-blocker or is known-clean (the target system must not write to the USB with malware).
- [ ] Photograph the screen before, during, after.

## Step-by-step

1. Plug the USB into the target.
2. Open the USB in Explorer. Double-click `BelkasoftRAMCapturer64.exe` (or `32.exe` on 32-bit).
3. **Run as administrator** (UAC prompt).
4. **Destination path:** browse to the USB, e.g. `E:\EVIDENCE\AGENT-01.mem`.
5. **Free space check:** Belkasoft shows the target free space. Must be > 2× RAM.
6. Click **Capture!**. The button shows a progress bar.
7. **Do not interact with the system** during capture (minimise mouse movement, do not type).
8. Capture duration: ~5 min for 8 GB RAM, ~15 min for 32 GB RAM.
9. When done, Belkasoft shows "Memory dumped successfully" and the SHA1 hash.
10. Open `cmd`, run `Get-FileHash -Algorithm SHA256 E:\EVIDENCE\AGENT-01.mem`. Record on the hash sheet.
11. Compare the SHA1 Belkasoft showed with `Get-FileHash -Algorithm SHA1`. They should match.
12. Move the `.mem` to a working folder for analysis (do not analyse on the original USB — make a copy).

## Expected output
- `AGENT-01.mem` (8.2 GB for an 8 GB system; slightly larger than RAM)
- SHA1 from Belkasoft's own dialog
- SHA256 from `Get-FileHash`

## What to do with the .mem
- **Volatility 2.6 / 3.x** for analysis:
  - `volatility.exe -f AGENT-01.mem imageinfo`
  - `volatility.exe -f AGENT-01.mem --profile=Win10x64 pslist`
  - `volatility.exe -f AGENT-01.mem --profile=Win10x64 netscan`
  - `volatility.exe -f AGENT-01.mem --profile=Win10x64 cmdline`
  - `volatility.exe -f AGENT-01.mem --profile=Win10x64 filescan | grep -i telegram`
  - `volatility.exe -f AGENT-01.mem --profile=Win10x64 dumpfiles -p <PID> -D <out>`
- **strings + grep** for quick triage:
  - `strings -e l AGENT-01.mem | grep -E "https?://" | sort -u | head`
  - `strings -e l AGENT-01.mem | grep -iE "upi|password|@upi" | head`

## Common mistakes
- ❌ Saving the .mem to the same drive you're capturing (you'll fill it up). Always to a separate drive.
- ❌ Skipping the post-capture hash. Hashes are how you prove the RAM was not tampered with later.
- ❌ Letting the system continue to do work during capture (e.g., a screen-saver waking up, antivirus scanning the USB). Lock the workstation with `Win+L` after starting the capture.
- ❌ Using a FAT32 USB (4 GB file limit). NTFS or exFAT.
- ❌ Forgetting to copy the .mem to a working folder before running any analysis on it (analysis tools may modify the file's access time).

## Court admissibility notes
- The .mem + hash is **BSA Sec 63** compliant if accompanied by a signed certificate of the seizing officer.
- Always pair with a contemporaneous photograph of the system tray showing Belkasoft running.
