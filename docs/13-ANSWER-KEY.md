# 13 — Answer Key (Instructor Only)

> **Do not hand to trainees before the lab.** This is the instructor's reference for grading and the debrief.

## 1. Cross-system correlation answers

### 1.1 Number of victims defrauded
**487 victims.**
- CRM-SERVER: `SELECT COUNT(*) FROM golden_crm.victims;` → 487.
- MANAGER-PC: `D:\Manager\victims_master.xlsx` → 487 rows.
- AGENT-02: `leads_apr2026.csv` → 12,000 leads, 487 marked "HOT".

### 1.2 Total amount cheated
**Rs 4,37,82,500 (4.37 crore Indian Rupees).**
- CRM-SERVER: `SELECT SUM(amount) FROM golden_crm.transactions WHERE status='CONFIRMED';` → Rs 4,37,82,500.
- MANAGER-PC: `victims_master.xlsx` → sum of `Amount Paid` = Rs 4,37,82,500.
- AGENT-04: `UPI_Screenshots` folder → 312 files summing to the same amount (allow ±Rs 1,000 rounding).

### 1.3 Ringleader
**Arjun Mehta (MANAGER-PC, 192.168.10.50).**
- Holds the mule account in his name (HDFC XXXXXX4242).
- Owns the VeraCrypt container (`E:\` mounted from `D:\Manager\vault.veracrypt`) — contains the "do-not-call" list and `complaints_to_ignore.xlsx`.
- Owns the Telegram C2 channel (`t.me/gr_daily_collect`).
- Owns the daily collection report Task Scheduler.

### 1.4 Mule account rotation
| Week | Bank | Account | IFSC |
|---|---|---|---|
| 01-07 Apr 2026 | HDFC | XXXXXX4242 | HDFC0ANDHERI |
| 08-14 Apr 2026 | ICICI | XXXXXX9191 | ICIC0001234 |
| 15-21 Apr 2026 | Axis | XXXXXX7720 | UTIB0000123 |
| 22-28 Apr 2026 (planned) | Kotak | XXXXXX3344 | KKBK0001234 |

Source: `E:\mule_rota_history.xlsx` (inside VeraCrypt on MANAGER-PC).

### 1.5 Victim → agent mapping
Cross-reference `hot_leads_today.txt` on AGENT-01 with `victims_master.xlsx`:
- VICTIM-011, VICTIM-023, VICTIM-047, VICTIM-052, VICTIM-088, VICTIM-101, VICTIM-122, VICTIM-145, VICTIM-167, VICTIM-189, VICTIM-202, VICTIM-234 → all in Rahul's hot_leads. Each has `closer_id = rahul.s`.
- AGENT-03's call recordings on `E:\callrecordings` have filenames like `2026-04-17_1822_V202.wav` (V202 = VICTIM-202).
- AGENT-04's `payment_followup_template.docx` mentions VICTIM-047 specifically.

### 1.6 Remote access tool
**AnyDesk (ID `823 411 902`).**
- AGENT-01: AnyDesk ID in system tray.
- MANAGER-PC: `AppData\Roaming\AnyDesk\ad_sessions.log` shows last 14 days of connections to `103.41.218.91`.
- CRM-SERVER: 47 failed then 1 successful RDP attempt from `103.41.218.91` (Singapore, AnyDesk relay).
- Router: `relay.anydesk.com` DNS lookup from MANAGER-PC at 23:14 daily.

### 1.7 Malware
**Benign stub `updater.exe` in `C:\ProgramData\Updater\`.**
- Runs from `HKLM\…\Run\Updater` value: `powershell.exe -WindowStyle Hidden -File C:\ProgramData\Updater\stub.ps1`.
- Source: `C:\Users\vikas.n\Documents\stub.ps1`.
- Behaviour: monitors for new USB drives; on detection, copies a `passwords.txt` file to the USB root.
- Stub.ps1 contains comment `# TODO: exfil to telegram when stable` — intent to commit future crime.

### 1.8 Cloud data
- **Google Drive:** folder `Golden_Returns_Marketing_Collateral` (47 files) under AGENT-01's Chrome session.
- **OneDrive:** MANAGER-PC has OneDrive syncing `D:\Manager\` to `arjun@outlook.com` (personal).
- **Telegram Web:** open in all 5 agents.
- **WhatsApp Web:** AGENT-01 (12 chats), AGENT-04 (deleted), MANAGER-PC (Edge, locked).

### 1.9 Deleted evidence (recoverable)
- MANAGER-PC Recycle Bin: `complaints_to_ignore.xlsx` (list of 3 cyber-cell officers who had emailed complaints).
- AGENT-03 Recycle Bin: `closer_script_old.docx` (older, more incriminating version of the script).
- AGENT-04 Telegram session: zeroed-out tdata folder.
- Hidden USB in book: `victims_old.xlsx` (deleted 3 weeks ago).

### 1.10 Exfiltration indicator
- AGENT-05's malware stub planted `passwords.txt` on USB insertion — this is the **exfiltration mechanism** (it tells the criminals the IT guy was there).
- The manager's OneDrive sync log shows `victims_master.xlsx` was uploaded to OneDrive daily at 23:55 — automatic off-site backup of the master list.

## 2. Worksheet expected answers (high-level)

### Worksheet 1 (RAM)
- Image profile: `Win10x64` (or `Win11x64` on MANAGER-PC).
- Top suspicious processes: `Telegram.exe`, `chrome.exe` (12 tabs), `X-Lite.exe` (Amit), `AnyDesk.exe`, `updater.exe` (Vikas).
- Most incriminating RAM string: `complaint se koi fayda nahi, SEBI ko ignore karo` from a recent Telegram chat.

### Worksheet 2 (Processes on AGENT-05)
- `updater.exe` is unsigned (file version 0.0.0.0, no company name).
- Parent process: `explorer.exe`.
- Scheduled task `\Updater\DailyTrigger` runs the stub at 09:00 daily.
- Registry `HKLM\…\Run\Updater` launches at boot.

### Worksheet 3 (Network on CRM-SERVER)
- 7 ESTABLISHED connections — 5 to the 5 agent machines (port 80, HTTP to CRM), 1 to MANAGER-PC (port 445, SMB), 1 to `103.41.218.91:49522` (RDP via AnyDesk).
- 47 DROP entries from `103.41.218.91` in 4 minutes (23:14:22-23:18:09) — classic brute-force pattern.
- DNS query: `relay.anydesk.com` resolves to `103.41.218.91`.

### Worksheet 4 (Browser on AGENT-02)
- 247 visits to `linkedin.com` in last 30 days.
- 84 visits to `facebook.com`.
- 23 visits to `goldenreturns.example/customer` (the victim dashboard).
- Last 10 downloads: 4 LinkedIn CSV exports, 2 LinkedIn search-result CSVs, 1 Facebook Ads audience CSV, 1 Sales Nav trial confirmation, 2 `leads_apr2026_*.csv` (incremental).

### Worksheet 5 (Email on MANAGER-PC)
- 187 emails in Sent folder in last 30 days.
- 42 emails with "UPI" or "@upi" — all are daily collection reports to the Telegram bot or to `arjun.collect@upi` (auto-confirmation).
- 0 emails to SEBI. 3 emails reference "SEBI compliance" — all to `compliance@sebi-fake.example` (typosquatting the real `sebi.gov.in`).
- 5 most recent "Daily Collection" emails: 1 to `gr_daily_collect@googlegroups.com` (Telegram email bridge), 4 to the mule account holders.

### Worksheet 6 (USB)
- 47 USB devices ever plugged in (filtered to last 30 days: 12).
- Serial numbers match: MSL-2026-011 (SanDisk 32GB AGENT-05 desk), MSL-2026-012 (SanDisk 16GB labeled "BACKUP"), MSL-2026-013 (SanDisk 8GB), MSL-2026-014 (SanDisk 64GB in book).
- `passwords.txt` is a 0.5 KB file created by the malware stub on USB insert.

### Worksheet 7 (Deleted files)
- MANAGER-PC Recycle Bin: `complaints_to_ignore.xlsx` (3 officers, A. Desai, R. Kulkarni, M. Singh — note: this is **witness tampering evidence**).
- AGENT-03 Recycle Bin: `closer_script_old.docx` (5-page version with no qualifiers — direct fraud).
- AGENT-04 Recycle Bin: `support_chat_export.html` (the Telegram chat export of victim support, deleted 2 days ago).
- MANAGER-PC VeraCrypt: `mule_rota_history.xlsx`, `victims_to_burn.xlsx`, `private_keys.txt`, `confession_2026-04-17.mp3`.

### Worksheet 8 (Hashing)
- Total files in `E:\EVIDENCE`: 247.
- Highest count by extension: `.log` (87 files, 312 MB).
- All hashes match the FTK Imager log.

### Worksheet 9 (Imaging)
- All 7 disk images created successfully.
- 4 pen drives imaged.
- Total imaging time: 18h 42m.

### Worksheet 10 (Verification)
- All registry hives load successfully.
- USBSTOR entries match USBDeview output.
- VeraCrypt mount succeeds with password `Gr@Vault2026!`.
- PIR draft is ready for the IO.

## 3. Inject scoring (out of 5 each)

| # | Correct decision (5) | Partial (3) | Wrong (0) |
|---|---|---|---|
| 1 | Subdue suspect, photograph every screen, no power action | Photograph some screens, then power off | Yank power cable |
| 2 | Photograph AnyDesk ID, do not disconnect, capture token first | Disconnect without preserving | Right-click Disconnect and lose ID |
| 3 | Photograph alert, hash before Defender acts, image, sandbox | Hash but let Defender quarantine | Let Defender quarantine, no hash, no image |
| 4 | Photograph in situ, image via write-blocker | Pull USB, then photograph | Plug into non-forensic machine |
| 5 | Run mysqldump first, check Recycle Bin, find backup share | Check Recycle Bin only | Believe the manager |
| 6 | Screenshot URL, preserve in RAM, draft Sec 91 to Google | Screenshot only | Close the tab |
| 7 | Image via UFED, do not exceed 5 PIN attempts, bag in Faraday | Try one or two common PINs | Brute-force the PIN |
| 8 | Console cable, copy running-config via TFTP | Try default password | Lock the account |
| 9 | Photograph LCD, pull internal flash, image, collect paper | Photograph LCD only | Clear the jam |
| 10 | Cross-reference browser + USB + CRM logs | Browser only | Accept the denial |
| 11 | Check event log 1074/6008, USN journal | Event log only | Believe the user |
| 12 | Image the USB immediately, image AGENT-05 | Image the USB only | Open passwords.txt on a non-forensic machine |
| 13 | rwinsta 6, photograph, preserve for MLAT | rwinsta all sessions | Kill the manager's session |
| 14 | Power bank in Faraday pouch | Wall power (defeats pouch) | Let the phone die |
| 15 | Image USB before removing, remove via write-blocker | Remove then image | Let Sneha unplug it herself |
| 16 | Photograph, pull HDD, image, check recycle bin | Photograph only | Dismantle without imaging |
| 17 | Do not close the volume, image the live header | Close the volume (loses mount) | Dismount via VeraCrypt |
| 18 | Export each chat, save to evidence USB | Screenshot only | Close the tabs |
| 19 | strings on the .mem, recover incognito URLs | Believe the suspect | Do nothing |
| 20 | Photograph, treat as new seizure site | Photograph only | Open the laptop |

Total: 100 points. Pass: 70. Distinction: 90.

## 4. Common "gotcha" findings the trainees should produce

1. The **same phone number** in the closer script (AGENT-01), the master XLSX (MANAGER-PC), and the CRM DB (CRM-SERVER) — proves the manager coordinated the calls.
2. The **same `mule_rota_history.xlsx`** opened by both MANAGER-PC and AGENT-04 (Windows Recent files) — proves the manager and the payment chaser were coordinating the same file.
3. The **same AnyDesk ID** in the system tray of AGENT-01 and in the AnyDesk log of MANAGER-PC — proves the same remote access was used from two machines.
4. The **same Telegram session** referenced in the browser history of all 5 agents AND in the Telegram Desktop session of MANAGER-PC AND in the deleted Telegram cache of AGENT-04 — proves the entire team was in the same Telegram group.
5. The **same `passwords.txt`** hash appearing on the USB in AGENT-05's desk, on the USB in the book, and on the USB AGENT-05 plugged in during the raid — proves the malware was active.
