# Golden Returns — PowerShell Setup Scripts

## What these scripts do

The scripts in this folder automatically generate **synthetic training-lab evidence** on a Windows machine. They create fake victim CSVs, fake chat logs, fake UPI screenshots, fake browser histories, fake MySQL dumps, fake router configs, and a benign "malware" stub. **All data is fictional.**

## Which script to run on which system

| System | Run as Administrator | Time required |
|---|---|---|
| AGENT-01 (Rahul, closer) | `powershell -ExecutionPolicy Bypass -File .\01-AGENT-01-Setup.ps1` | ~30 s |
| AGENT-02 (Priya, lead gen) | `.\02-AGENT-02-Setup.ps1` | ~30 s |
| AGENT-03 (Amit, VoIP) | `.\03-AGENT-03-Setup.ps1` | ~30 s |
| AGENT-04 (Sneha, payment) | `.\04-AGENT-04-Setup.ps1` | ~1 min (312 UPI screenshots) |
| AGENT-05 (Vikas, IT) | `.\05-AGENT-05-Setup.ps1` | ~30 s |
| MANAGER-PC (Arjun) | `.\06-MANAGER-Setup.ps1` | ~1 min (487 victims) |
| CRM-SERVER | `.\07-CRM-SERVER-Setup.ps1` | ~1 min |
| PRINTER | `.\08-PRINTER-Setup.ps1` | ~10 s |
| ROUTER | `.\09-ROUTER-Setup.ps1` | ~10 s |
| **Solo study on one machine** | `.\00-Master-Setup.ps1 -Role ALL` | ~3 min |

## Output

Everything is written to `C:\LabEvidence\GoldenReturns\`. The folder structure mirrors the lab diagram in `docs/01-OFFICE-LAYOUT.md`:

```
C:\LabEvidence\GoldenReturns\
├── Agents\Agent01\  (AGENT-01 evidence)
├── Agents\Agent02\  (AGENT-02)
├── Agents\Agent03\  (AGENT-03)
├── Agents\Agent04\  (AGENT-04)
├── Agents\Agent05\  (AGENT-05)
├── Manager\         (MANAGER-PC)
├── CRM\             (CRM-SERVER)
├── Printer\Spool\   (PRINTER)
├── Router\          (ROUTER)
└── HASHES.csv       (MD5 + SHA256 of every generated file)
```

## How the cross-system clues are linked

The scripts use **deterministic seeds** for the same victim IDs, phone numbers, UPI handles, and file references. So:

- VICTIM-047 appears in AGENT-01's `hot_leads_today.txt`, AGENT-04's `payment_followup_template.txt`, MANAGER-PC's `victims_master.csv`, CRM-SERVER's `victims` table, and the `closer_script_old.txt` in AGENT-03's Recycle Bin.
- The mule account `XXXXXXXX4242` appears in MANAGER-PC's `Mule_Accounts_Q4.csv`, AGENT-04's `payment_followup_template.txt`, and the CRM-SERVER `transactions` table.
- The malware stub on AGENT-05 references `passwords.txt` that gets planted on every USB plugged in.
- The router config references the static DHCP reservation for AGENT-05, and the port-forward rule for CRM-SERVER.
- The manager's AnyDesk ID `823 411 902` appears in AGENT-01's system tray stub, MANAGER-PC's `anydesk_session.log`, and the CRM-SERVER's `qwinsta` output.

## How to verify the lab is correctly set up

After running, do:

```powershell
# Check all files are there
Get-ChildItem C:\LabEvidence\GoldenReturns -Recurse | Measure-Object

# Check the hash file
Import-Csv C:\LabEvidence\GoldenReturns\HASHES.csv | Format-Table -AutoSize
```

You should see ~600-800 files (depending on role) and ~1500-2000 hash rows.

## How to clean up

```powershell
Remove-Item C:\LabEvidence\GoldenReturns -Recurse -Force
```

## Safety

- **No network access.** All scripts run offline. The `stub.ps1` malware stub is a no-op unless a USB is plugged in, and even then it only writes a `passwords.txt` to the USB root.
- **No real data.** Every name, phone number, UPI ID, and account number is randomly generated and synthetic.
- **No persistence.** The scripts do not modify registry, scheduled tasks, or startup. The malware stub is a **file only**; it is not installed on the system.
- **Easy cleanup.** Just `Remove-Item C:\LabEvidence\GoldenReturns -Recurse -Force`.

## Running on a non-Windows host

These scripts are **Windows-only** (PowerShell). For macOS / Linux, you can still preview the lab by:
- Reading `docs/00-STORYLINE.md` for the full scenario.
- Reading the pre-baked artifacts in `artifacts/` (CSV/TXT samples).
- Reading the injects in `injects/`.
- Reading the SOP and tool docs in `docs/`.
