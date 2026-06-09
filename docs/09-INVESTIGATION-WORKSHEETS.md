# 09 — Investigation Worksheets

> Hand these to trainees at the start. Each worksheet forces use of a specific tool and produces a specific deliverable.

---

## Worksheet 1 — RAM Capture & Volatile Evidence (30 min)

**System:** AGENT-01 (192.168.10.11) — Tools: Belkasoft RAM Capturer, WinPmem, PowerShell, FTK Imager

1. [ ] Photograph the screen with all open windows before touching anything.
2. [ ] Plug a write-blocked USB containing Belkasoft RAM Capturer into the front panel.
3. [ ] Run the RAM capture. How long did it take?
4. [ ] Calculate SHA256 of the resulting `.mem` file via PowerShell `Get-FileHash`.
5. [ ] `tasklist /v > E:\VOL\AGENT-01_tasklist.txt`
6. [ ] `netstat -ano > E:\VOL\AGENT-01_netstat.txt`
7. [ ] `ipconfig /displaydns > E:\VOL\AGENT-01_dns.txt`
8. [ ] `wevtutil epl Security E:\VOL\AGENT-01_security.evtx`
9. [ ] Open the RAM dump in **Volatility 2.6** and run `imageinfo`. What profile?
10. [ ] Run `pslist` and `netscan`. List the 3 most suspicious processes and why.
11. [ ] `strings -e l winpmem.raw | grep -i telegram` — find the Telegram chat strings.
12. [ ] Hash every volatile file, append to verification sheet.

**Deliverable:** 2-page report — top 5 processes, open network connections, most incriminating RAM string.

---

## Worksheet 2 — Running Process Analysis (20 min)

**System:** AGENT-05 (192.168.10.55) — Tools: Process Explorer, Process Hacker 2, Autoruns, FTK Imager

1. [ ] Process Explorer → list the 5 non-Microsoft processes.
2. [ ] For each, Properties → Verify → Signature. Is it valid?
3. [ ] Find `updater.exe`. Parent process? Start time?
4. [ ] Autoruns → Scheduled Tasks → `\Updater\DailyTrigger`. Screenshot.
5. [ ] Properties of the task. What command and arguments?
6. [ ] Regedit → `HKLM\…\Run` → `Updater` key. Screenshot.
7. [ ] `HKLM\…\Enum\USBSTOR` → last 5 USB devices.
8. [ ] Export the Updater registry key. Hash it.

**Deliverable:** text process-tree diagram of `updater.exe` with timestamps.

---

## Worksheet 3 — Network Connection Analysis (25 min)

**System:** CRM-SERVER (192.168.10.100) — Tools: Wireshark, netstat, CurrPorts, FTK Imager

1. [ ] Photograph all 4 disks in Disk Management (volumes, hidden partitions).
2. [ ] `netstat -ano | findstr ESTABLISHED` — count.
3. [ ] For each remote IP, `nslookup` + `whois`. List IP, PTR, ASN.
4. [ ] Identify the connection from `103.41.218.91:49522`. What service?
5. [ ] `qwinsta` — list all sessions. Is there one for `arjun.m`? From where?
6. [ ] `C:\Windows\System32\LogFiles\Firewall\pfirewall.log` — count DROP entries from `103.41.218.x`.
7. [ ] Security log → Event ID 4625 (failed logon) — how many in last 24h?
8. [ ] 2-minute Wireshark capture. Save as `crm_server_capture.pcap`. What unusual DNS queries?

**Deliverable:** network map of established connections, source IPs, suspected AnyDesk relay.

---

## Worksheet 4 — Browser History Analysis (30 min)

**System:** AGENT-02 (192.168.10.22) — Tools: BrowserHistoryView, DB Browser for SQLite, FTK Imager, OSForensics

1. [ ] Find Chrome `History` file. Copy to evidence USB (do not modify in place).
2. [ ] Open in DB Browser. List the tables.
3. [ ] `SELECT url, title, visit_count, datetime(last_visit_time/1000000 + (strftime('%s','1601-01-01')), 'unixepoch') AS last_visit FROM urls ORDER BY last_visit DESC LIMIT 50;`
4. [ ] Filter to linkedin.com + facebook.com — visits in last 30 days?
5. [ ] Filter to goldenreturns.example — visits, time of day?
6. [ ] `downloads` table — last 10.
7. [ ] `cookies` table — session cookies for CRM domain.
8. [ ] BrowserHistoryView on the same file. Cross-check.
9. [ ] Hash the History file. Append to verification sheet.

**Deliverable:** CSV of top 50 URLs with timestamps.

---

## Worksheet 5 — Email Analysis (25 min)

**System:** MANAGER-PC (192.168.10.50) — Tools: FTK Imager, Kernel OST/PST Viewer, OSForensics

1. [ ] Find the Outlook PST at `C:\Users\arjun.m\AppData\Local\Microsoft\Outlook\arjun@goldenreturns.example.pst`.
2. [ ] Image the profile folder (logical AD1).
3. [ ] Open PST in FTK. List folders.
4. [ ] Export every email in Sent folder. How many?
5. [ ] Emails containing "UPI" or "@upi". How many?
6. [ ] Emails to `compliance@sebi.gov.in` (likely none — but find any that reference SEBI).
7. [ ] Open email "Daily Collection". Sender, recipient, body?
8. [ ] Export headers for 5 most recent sent emails. Originating IPs?
9. [ ] Open in OSForensics → Email Viewer. Verify export.

**Deliverable:** 5 most recent "Daily Collection" emails as .eml + UPI-related email list.

---

## Worksheet 6 — USB Analysis (15 min)

**System:** AGENT-01 (192.168.10.11) + seized pen drives

1. [ ] Run **USBDeview** as administrator. List all USB devices.
2. [ ] Filter to "Connected" / "Disconnected" in the last 30 days.
3. [ ] For each, note: Vendor, Product, Serial, First plug-in, Last plug-in.
4. [ ] Open the registry `HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR`. Compare with USBDeview.
5. [ ] Image the seized pen drive `MSL-2026-011` (SanDisk 32 GB, AGENT-05 desk) with FTK Imager.
6. [ ] Mount the E01 read-only. List files. Note deleted files.
7. [ ] Open `passwords.txt` in a hex editor. What is the file's origin? (AGENT-05's malware stub).
8. [ ] Cross-reference the Serial number from USBDeview with the suspect's statement.

**Deliverable:** USB device timeline + image hash for the seized drive.

---

## Worksheet 7 — Deleted File Recovery (20 min)

**System:** MANAGER-PC (192.168.10.50) + AGENT-03 — Tools: Recuva, Autopsy, FTK Imager

1. [ ] Open the mounted MANAGER-PC image in Autopsy.
2. [ ] Ingest modules: Recent Activity, Hash Lookup, Keyword Search, File Carving, EXIF parser.
3. [ ] Navigate to the `Recycle Bin` ($Recycle.Bin) of `arjun.m`. What files are there?
4. [ ] Recover `complaints_to_ignore.xlsx`. Open in Excel. What does it contain?
5. [ ] On AGENT-03's image, locate the deleted `closer_script_old.docx` in the Recycle Bin.
6. [ ] Compare to the live `closer_script.docx` on AGENT-01. What was removed?
7. [ ] Use the **PhotoRec** carver on the unallocated space of MANAGER-PC. Any USB-resident data?
8. [ ] Document every recovered file in the worksheet.

**Deliverable:** list of all recovered deleted files with paths and hashes.

---

## Worksheet 8 — File Hashing (15 min)

**Tools:** HashCalc, Get-FileHash, FTK Imager

1. [ ] Open HashCalc. Select a seized evidence file.
2. [ ] Calculate MD5, SHA1, SHA256. Record all three.
3. [ ] Repeat with PowerShell: `Get-FileHash -Algorithm SHA256 -Path <file>`.
4. [ ] Verify the two hashes match.
5. [ ] Bulk: hash every file in `E:\EVIDENCE` and export a CSV.
6. [ ] Open the CSV in Excel. Pivot by file extension.
7. [ ] Find the file with the highest count. Is it expected?

**Deliverable:** `HASHES_<timestamp>.csv` and a 1-page summary.

---

## Worksheet 9 — Disk Imaging (60 min)

**Tools:** FTK Imager, write-blocker

1. [ ] Connect the AGENT-02 SSD to the write-blocker.
2. [ ] Open FTK Imager → File → Create Disk Image.
3. [ ] Source: Physical Drive. Select the write-blocked SSD.
4. [ ] Destination: `E:\EVIDENCE\AGENT-02.E01`. Format: E01. Segment: 4 GB. Compression: 6.
5. [ ] Tick "Create directory listing" and "Verify images after they are created".
6. [ ] Click Start. Note the time and ETA.
7. [ ] When done, verify hashes match.
8. [ ] Save the FTK log. Hash it. Append to the verification sheet.
9. [ ] Repeat for AGENT-03 HDD and the 4 seized pen drives.

**Deliverable:** complete imaging log register and the .E01 + .txt log for each.

---

## Worksheet 10 — Evidence Verification & Report (45 min)

**Tools:** Autopsy, OSForensics, your worksheet outputs

1. [ ] Open the AGENT-01 E01 in Autopsy. Run the Recent Activity ingest.
2. [ ] Find the WhatsApp Web session export. How many chats? How many victims?
3. [ ] In OSForensics, open the MANAGER-PC E01. Run Registry Viewer. Open the `SYSTEM` hive.
4. [ ] Find the USBSTOR entries. List the last 5 devices. Match to the seized pen drives.
5. [ ] Open the `SAM` hive. List the local users.
6. [ ] Open the `SOFTWARE` hive. Find the `Updater` Run key. Document the command.
7. [ ] Open the `NTUSER.DAT` for `arjun.m`. Find RecentDocs. List the last 20 files.
8. [ ] Open the VeraCrypt volume. (If mounted.) List the files in `E:\`.
9. [ ] Compile all your findings into a Preliminary Investigation Report (PIR) using the template in `printables/`.

**Deliverable:** a complete Preliminary Investigation Report (PIR) ready for the IO to file.

---

## Cross-system correlation task (for the whole team)

The team must collectively answer these 10 questions and present them in a 15-minute walkthrough:

1. How many **victims** were defrauded? Cite the CRM DB and the master XLSX.
2. What is the **total amount** cheated? Cite the `transactions` table sum and the XLSX sum. They should match.
3. Who is the **ringleader**? Cite the VeraCrypt, the mule account, the Telegram C2.
4. What is the **mule account rotation pattern**? Cite the XLSX and the bank statements (Sec 91).
5. Which **victim** was contacted by which **agent**? Cross-reference `closer_script.docx` phone list with `victims_master.xlsx`.
6. What **remote access** tool was used? Cite AnyDesk log + router DNS + RDP log.
7. What **malware** was deployed? Cite the stub in `C:\ProgramData\Updater\` + the registry key + the scheduled task.
8. What **cloud** data exists? Cite OneDrive + Telegram web + WhatsApp web.
9. What was **deleted**? Cite the Recycle Bin recoveries + the empty Telegram tdata.
10. What is the **exfiltration** indicator? Cite the `passwords.txt` planted on USB + the master `victims_master.xlsx` on MANAGER-PC + the OneDrive sync log.
