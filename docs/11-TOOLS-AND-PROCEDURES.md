# 11 — Tools Overview & Comparison

## Quick-reference table

| Task | Primary tool | Free? | Notes |
|---|---|---|---|
| RAM capture | Belkasoft RAM Capturer | Yes | Fastest, SHA1 in dialog |
| RAM capture (alternative) | Magnet RAM Capture | Yes | Includes pagefile, MD5+SHA1 |
| RAM capture (CLI) | WinPmem (Rekall) | Yes | Scriptable, signed binary |
| Disk image (E01) | FTK Imager 4.7 | Yes | Industry standard |
| Disk image (DD) | `dd` / FTK Imager | Yes | Portable, uncompressed |
| Browser history | BrowserHistoryView (NirSoft) | Yes | All browsers, exports CSV |
| Browser history (alt) | Browser History Examiner | Limited | Recovers deleted URLs from WAL |
| USB history | USBDeview | Yes | VID/PID/Serial/Date |
| Registry parsing | Registry Explorer (EZ) | Yes | Gold standard |
| Malware triage | VirusTotal | Free (limited) | Hash-only submission preferred |
| Hashing (single) | HashCalc / `Get-FileHash` | Yes | PowerShell built-in |
| Hashing (bulk) | PowerShell `Get-ChildItem + Get-FileHash` | Yes | Built-in |
| Email analysis | Kernel OST/PST Viewer / FTK | Both | PST viewer in FTK |
| Disk analysis | Autopsy 4.21 | Yes | Ingest modules |
| Disk analysis (alt) | OSForensics | Limited | Registry viewer, password recovery |
| Network capture | Wireshark / NetworkMiner | Yes | NetworkMiner is passive |
| Password recovery | WebBrowserPassView | Yes | DPAPI decryption |
| Live-system triage | NirSoft suite | Yes | 12 utilities |

## Recommended kit for a 4-officer raid

- **1 × laptop** (FTK Imager, Autopsy, OSForensics, Wireshark, Registry Explorer)
- **1 × bootable USB** (WriteCopier, Helix, or your custom WinPE)
- **1 × write-blocker** (Tableau T8 USB3 or WiebeTech)
- **4 × USB sticks** (write-blocked) pre-loaded with:
  - Belkasoft RAM Capturer (32 + 64)
  - NirSoft suite (BrowserHistoryView, USBDeview, RecentFilesView, WebBrowserPassView, etc.)
  - HashCalc
  - Registry Explorer
  - Process Explorer + Autoruns (Sysinternals)
  - DB Browser for SQLite
  - Wireshark portable
  - The 20 PowerShell scripts from this lab (run on the right system per the script)
- **6 × Faraday bags** (phones)
- **20 × tamper-evident evidence bags** (numbered)
- **DSLR + spare battery + SD card**
- **Bound notebook + pen**
- **Printed forms** (Seizure Memo, Chain of Custody, Hash Sheet, Imaging Log)
- **Marker pen (permanent ink)**

## Per-system procedure summary

| System | First action | Imaging | Hashing | Tools to use |
|---|---|---|---|---|
| **AGENT-01** (workstation) | Belkasoft RAM | FTK Imager E01 | Get-FileHash SHA256 | NirSoft + Registry Explorer + BHE |
| **AGENT-02** (workstation) | Belkasoft RAM | FTK Imager E01 | Get-FileHash | BHE + DB Browser + USBDeview |
| **AGENT-03** (workstation + MicroSD) | Belkasoft RAM | FTK Imager E01 + FTK Imager DD for SD | Get-FileHash | Registry Explorer + NirSoft |
| **AGENT-04** (workstation) | Belkasoft RAM | FTK Imager E01 | Get-FileHash | BrowserHistoryView + RecentFilesView |
| **AGENT-05** (workstation + USBs) | Belkasoft RAM | FTK Imager E01 + DD for each USB | Get-FileHash | Autoruns + Process Explorer + VirusTotal (in sandbox) |
| **MANAGER-PC** (workstation + VeraCrypt + hidden USB) | Belkasoft RAM (DO NOT close VeraCrypt) | FTK Imager E01 + DD for USB | Get-FileHash | VeraCrypt header parser + Registry Explorer + Outlook PST viewer |
| **CRM-SERVER** | `mysqldump` + screenshot + Belkasoft RAM (15-30 min) | FTK Imager E01 × 2 disks | Get-FileHash | Wireshark + Event Viewer + MySQL client |
| **PRINTER** | Photograph LCD + paper | FTK Imager DD of internal flash | Get-FileHash | Web UI screenshot |
| **ROUTER** | Console cable → `copy running-config tftp://` | n/a (text config) | Get-FileHash on .cfg | Web UI screenshot + console |
| **PHONES** | Airplane mode → Faraday bag | Cellebrite UFED (logical + physical) | Get-FileHash on UFED report | Chip-off for locked |

## What to teach in the first 30 minutes of classroom time

1. The 5 forensic principles (legality, completeness, accuracy, verifiability, chain-of-custody).
2. The volatile order (RAM → processes → network → events).
3. The write-blocker (why, how, common models).
4. The hash (why, which algorithm, when).
5. The E01 (what, why not just `dd`).
6. The chain-of-custody form (one line per transfer, signed by both parties).

## What to teach in the next 30 minutes (tool-by-tool)

1. Belkasoft + `Get-FileHash` (RAM + hash).
2. FTK Imager (E01 creation).
3. NirSoft BrowserHistoryView + USBDeview.
4. Registry Explorer (USBSTOR, Run keys).
5. Autopsy (Recent Activity, File Carving).

## What to teach in the last hour (scenario walkthrough)

1. Run the PowerShell scripts on a single Windows lab machine (`-Role ALL`).
2. Walk through the SOP, the worksheets, and the injects.
3. Show the answer key (debrief).
4. Discuss the real-world cases that mirror this scenario (Mango Telecom 2024, HP欺诈案 2023, etc.).
