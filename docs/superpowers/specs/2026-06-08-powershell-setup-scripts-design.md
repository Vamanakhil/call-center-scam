# Design: PowerShell Lab Setup Scripts

**Date:** 2026-06-08  
**Scope:** `crime-scences/scripts/` — all roles  
**Target OS:** Windows 10 Pro 22H2 (all machines)

---

## Architecture: Master Orchestrator + Per-Role Modules

```
scripts/
├── 00-Master-Setup.ps1          # Thin orchestrator
├── shared/
│   └── New-FakeData.ps1         # Shared data library + helpers
├── agents/
│   ├── Setup-Agent01.ps1        # Rahul — closer
│   ├── Setup-Agent02.ps1        # Priya — lead generator
│   ├── Setup-Agent03.ps1        # Amit — VoIP caller
│   ├── Setup-Agent04.ps1        # Sneha — payment chaser
│   └── Setup-Agent05.ps1        # Vikas — IT support
├── manager/
│   └── Setup-Manager.ps1        # Arjun — ringleader
├── server/
│   └── Setup-CrmServer.ps1      # XAMPP + MySQL golden_crm
├── printer/
│   └── Setup-Printer.ps1        # Spool share + 18 fake PDFs
└── router/
    └── Setup-Router.ps1         # Router artifact folder
```

**Invocation:** `.\00-Master-Setup.ps1 -Role <name>` where name is one of:
`AGENT-01 | AGENT-02 | AGENT-03 | AGENT-04 | AGENT-05 | MANAGER | CRM-SERVER | PRINTER | ROUTER | ALL`

---

## Shared Library (New-FakeData.ps1)

Provides:
- `$VictimData` — 487 victim records (name, phone, amount, status)
- `$LeadData` — 12,000 lead records (name, phone, heat score, assigned agent)  
- `$TransactionData` — 2,314 transaction rows (victim, amount, UPI ID, date, mule account)
- `$CallLogData` — 891 call log rows (agent, victim, duration, recording filename)
- `$MuleAccounts` — 6 mule bank account details
- `New-SqliteDb` helper — writes a minimal valid Chrome History SQLite file using embedded sqlite3.exe (base64-bundled, Win10 compatible)
- `New-ZipFile` helper — creates ZIP from a hashtable of filename→content
- `Write-SetupLog` — timestamped Write-Host with colour + appends to `C:\GR_LabSetup\setup.log`
- `New-HashReport` — MD5 + SHA256 of every created file → `C:\GR_LabSetup\hashes.csv`

---

## Per-Role Scope

### AGENT-01 (rahul.s)
Creates user profile under `C:\Users\rahul.s\`:
- `Desktop\closer_script.docx` — 12-page call script (rich plain-text body, .docx wrapper via OpenXML bytes)
- `Desktop\hot_leads_today.txt` — 12 victim phone numbers matching victims_master
- `Desktop\Daily_Target.txt` — target note from Arjun
- `Documents\call_notes_2026-04-17.md` — yesterday call notes (3 victims)
- `Documents\Objection_Handling_Cheat_Sheet.pdf` — placeholder bytes with realistic header
- `Downloads\whatsapp_web_session_export.zip` — ZIP containing 12 chat HTML files
- `AppData\...\Chrome\...\History` — valid SQLite with 47 URLs (t.me, goldenreturns.example, drive.google.com)
- `AppData\...\Chrome\...\Login Data` — valid SQLite with 3 saved logins
- Recycle Bin entry: `closer_script_old.docx` moved to `$Recycle.Bin`
- `HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\...` — 3 USB history entries

### AGENT-02 (priya.v)
- `Desktop\leads_apr2026.csv` — 12,000 rows (name, phone, email, heat_score, status)
- `Desktop\Sales_Nav_Renewal.txt`
- `Documents\scraping_scripts\linkedin_scrape.py` — Python script
- `Documents\scraping_scripts\fb_audience_export.json` — 500-row JSON
- `AppData\...\Chrome\...\History` — SQLite with 80 LinkedIn/FB URLs
- Sticky notes SQLite with one note

### AGENT-03 (amit.p)
- `E:\callrecordings\` (or `C:\callrecordings\` if no E:) — 47 × 0-byte WAV stubs named `2026-04-<dd>_<HHMM>_V<NNN>.wav`
- `AppData\Roaming\X-Lite\config.xml` — SIP softphone config
- Recycle Bin: `closer_script_old.docx` (older, more incriminating text)
- `AppData\Roaming\Microsoft\Windows\Recent\victims_master.xlsx.lnk` — LNK file
- Chrome History SQLite with CRM admin URL

### AGENT-04 (sneha.i)
- `Desktop\UPI_Screenshots\` — 312 × 1×1 px PNG stubs named `upi_2026-04-<dd>_<HHMM>.png` (not real UPIs but named realistically)
- `Documents\payment_followup_template.docx`
- `AppData\Roaming\Telegram Desktop\tdata\` — folder with zeroed-out files (simulates deleted session)
- Recycle Bin: `support_chat_export.html`
- LNK to Mule_Accounts_Q4.xlsx

### AGENT-05 (vikas.n)
- `C:\ProgramData\Updater\updater.exe` — benign stub EXE (PowerShell -EncodedCommand wrapper)
- `C:\ProgramData\Updater\stub.ps1` — the script with the TODO comment
- `C:\Users\vikas.n\Documents\stub.ps1` — source copy
- `C:\Users\vikas.n\Documents\pi_ping.py`
- Registry: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\Updater` value
- Scheduled task: `\Updater\DailyTrigger` (XML)
- Hidden USB folder: `C:\GR_LabAssets\HiddenUSB\` simulating contents of the book USB

### MANAGER (arjun.m)
- `D:\Manager\victims_master.xlsx` — 487 rows CSV-in-XLSX (OpenXML)
- `D:\Manager\Mule_Accounts_Q4.xlsx` — 6 mule accounts
- `D:\Manager\Daily_Collection_2026-04-17.xlsx`
- `D:\Manager\vault.veracrypt` — random-bytes file (simulates encrypted container)
- `C:\Users\arjun.m\AppData\Roaming\Telegram Desktop\tdata\` — session files
- `C:\Users\arjun.m\AppData\Local\Microsoft\Outlook\arjun@goldenreturns.example.pst` — empty PST placeholder
- `C:\Users\arjun.m\AppData\Roaming\AnyDesk\ad_sessions.log` — 14-day session log
- Recycle Bin: `complaints_to_ignore.xlsx`
- Edge History SQLite (Telegram web, banking URLs)
- 2 Scheduled tasks: `DailyCollectionReport` (23:00), `DNSFlush` (02:00)
- `C:\GR_LabAssets\ManagerUSBHidden\victims_old.xlsx` — older deleted victim list

### CRM-SERVER
- Downloads XAMPP 8.2.x installer if not present (falls back to local if offline)
- Runs silent install: `xampp-installer.exe --mode unattended`
- Creates MySQL database `golden_crm` with 4 tables
- Populates: victims (487), leads (12,000), transactions (2,314), call_logs (891), users (admin)
- Creates `D:\Backups\old\golden_crm_backup_2026-04-15.sql` (mysqldump output)
- SMB share: `old` → `D:\Backups\old\`
- Firewall rules: allow 80, 443, 3389, 445
- Disables SMB signing (reg key)
- Windows Firewall log at `C:\Windows\System32\LogFiles\Firewall\pfirewall.log`
- Security EVTX with synthetic 4624/4625 events pre-staged as XML

### PRINTER
- `C:\GR_LabAssets\PrinterSpool\` shared as `Spool`
- 18 realistic PDF stubs (filename, size, creation date)
- Printer web UI artifact: text file simulating last-32-job log

### ROUTER
- `C:\GR_LabAssets\RouterEvidence\` with:
  - `running-config.txt` — TP-Link-style config with port-forward + DHCP reservations
  - `dhcp-leases.txt` — all 9 LAN hosts
  - `arp-table.txt`
  - `dns-log.txt` — includes t.me lookups from 192.168.10.50 at 23:47

---

## Non-Functional Requirements

- **Admin check:** exits with clear error if not run as administrator
- **Idempotent:** re-running same role is safe (existing files overwritten, not duplicated)
- **Windows 10 compatible:** no Win11 APIs; PowerShell 5.1
- **Offline-friendly:** only CRM-SERVER needs internet (XAMPP); all others are self-contained
- **Hash report:** every created file hashed MD5+SHA256, saved to `C:\GR_LabSetup\hashes.csv`
- **Setup log:** timestamped progress to `C:\GR_LabSetup\setup.log` and console
- **SQLite:** sqlite3.exe embedded as base64 in shared library, extracted to temp and used via `Invoke-Expression`
- **No external dependencies:** no NuGet, no Chocolatey, no internet except CRM-SERVER XAMPP download
