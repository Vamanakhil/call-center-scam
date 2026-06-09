# Golden Returns — Cyber Crime First Responder Training Lab

```
╔══════════════════════════════════════════════════════════════════════╗
║  ⚠  LAW ENFORCEMENT TRAINING USE ONLY  ·  ALL DATA IS SYNTHETIC  ⚠  ║
╚══════════════════════════════════════════════════════════════════════╝
```

A **production-grade, hands-on training lab** for DSP trainees, cyber cell officers, and digital forensics investigators. Trainees raid a simulated Ponzi-scheme call centre, seize 9 devices, perform live RAM capture and disk imaging, and reconstruct the full fraud operation from cross-system digital evidence.

Built for Indian cyber cells. All legal references are India-specific (IT Act 2008, BSA 2023, CrPC/BNSS 2023).

---

## The Scenario

**Golden Returns Wealth Management Pvt. Ltd.** is a fake investment firm operating as a boiler-room call centre. They promised 3–8% weekly returns on "AI-driven forex" products. In reality, not a single trade was ever placed.

A retired school teacher lost ₹14.3 lakh. The complaint traced a UPI transfer to a mule account. A warrant was issued. The team has **45 minutes** to secure the scene and extract evidence before the suspects' lawyer is tipped off.

```
┌─────────────────────────────────────────────────────────────────────┐
│  192.168.10.0/24 — Golden Returns Office LAN                        │
│                                                                      │
│  AGENT-01 .11   AGENT-02 .22   AGENT-03 .33   AGENT-04 .44        │
│  (Rahul)        (Priya)         (Amit)          (Sneha)             │
│  Closer         Lead Gen        VoIP Caller     Payment Chaser      │
│                                                                      │
│  AGENT-05 .55   MANAGER-PC .50  CRM-SERVER .100                    │
│  (Vikas)        (Arjun)         MySQL + XAMPP                       │
│  IT / Malware   Ringleader      487 victims · 12k leads             │
│                                                                      │
│  PRINTER .30    ROUTER .1                                           │
│  18 evidence    TP-Link · RDP forward → CRM                         │
│  PDFs printed   DNS log · DHCP · ARP                                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## What trainees learn

- First-responder scene management (SOP, live RAM vs. power-off decision)
- Volatile evidence capture order (RAM → netstat → processes → clipboard → mapped drives)
- Forensic disk imaging with FTK Imager (E01, hash verification)
- Chrome History SQLite analysis, Telegram tdata carving, deleted file recovery
- Cross-system evidence correlation — a finding on one machine proves guilt on another
- Malware stub analysis (registry Run key + scheduled task persistence)
- VeraCrypt live volume preservation
- MySQL database seizure and SQL evidence extraction
- Indian legal sections: IT Act 69, CrPC 91, BSA 63, Section 91 preservation requests

---

## Folder structure

```
crime-scences/
├── docs/                        # 30 training documents
│   ├── 00-STORYLINE.md          # Full scenario backstory
│   ├── 01-OFFICE-LAYOUT.md      # Physical scene map
│   ├── 02-NETWORK-DIAGRAM.md    # LAN topology
│   ├── 03-DEVICE-CONFIG.md      # Hostnames, IPs, credentials
│   ├── 04-EVIDENCE-MAP.md       # What to find, where, which tool
│   ├── 09-INVESTIGATION-WORKSHEETS.md
│   ├── 10-INJECT-EVENTS.md      # 20 trainer-injected events
│   ├── 12-INSTRUCTOR-GUIDE.md   # Day-of-lab schedule
│   ├── 13-ANSWER-KEY.md         # Expected findings (instructor only)
│   ├── 15-SOP-FIRST-RESPONDER.md
│   └── 16–29 *.md               # Real-tool SOPs (FTK, Autopsy, Belkasoft, etc.)
│
├── scripts/                     # PowerShell setup scripts
│   ├── 00-Master-Setup.ps1      # ← Run this on each machine
│   ├── shared/
│   │   └── New-FakeData.ps1     # Shared data library (487 victims, 12k leads…)
│   ├── agents/                  # Setup-Agent01.ps1 → Setup-Agent05.ps1
│   ├── manager/                 # Setup-Manager.ps1
│   ├── server/                  # Setup-CrmServer.ps1 (XAMPP + MySQL)
│   ├── printer/                 # Setup-Printer.ps1
│   └── router/                  # Setup-Router.ps1
│
├── injects/                     # 20 instructor inject cards (print these)
├── artifacts/                   # Pre-baked sample evidence files
├── printables/                  # Forms: chain of custody, evidence labels, etc.
└── docs/superpowers/specs/      # Design documents
```

---

## Requirements

**Lab machines (all Windows 10 Pro)**

| What | Minimum |
|---|---|
| OS | Windows 10 Pro 22H2 |
| PowerShell | 5.1 (built-in) |
| RAM | 4 GB |
| Disk | 20 GB free |
| Network | All machines on same LAN (192.168.10.0/24) |
| Internet | Only CRM-SERVER needs it (downloads XAMPP ~170 MB) |

**Trainer laptop** — any OS, just to serve this repo

**Physical props** (optional but recommended)
- 4× USB pen drives (one hidden in a hollowed book)
- 1× Faraday bag + 3× locked phones (use old phones)
- Tamper-evident bags, evidence tape, numbered seals
- DSLR camera for scene photography

---

## Quick start — deploy to all machines

### 1. Copy the scripts folder to a USB drive

Plug the USB into each lab machine. Open **PowerShell as Administrator**:

```powershell
# Allow scripts to run (one-time per machine)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# Navigate to the USB (change E: to your drive letter)
cd E:\scripts

# Run for this machine's role
.\00-Master-Setup.ps1 -Role AGENT-01
```

### 2. One command per machine

| Machine | User account to create first | Run this |
|---|---|---|
| AGENT-01 | `rahul.s` | `.\00-Master-Setup.ps1 -Role AGENT-01` |
| AGENT-02 | `priya.v` | `.\00-Master-Setup.ps1 -Role AGENT-02` |
| AGENT-03 | `amit.p` | `.\00-Master-Setup.ps1 -Role AGENT-03` |
| AGENT-04 | `sneha.i` | `.\00-Master-Setup.ps1 -Role AGENT-04` |
| AGENT-05 | `vikas.n` | `.\00-Master-Setup.ps1 -Role AGENT-05` |
| MANAGER-PC | `arjun.m` | `.\00-Master-Setup.ps1 -Role MANAGER` |
| CRM-SERVER | `Administrator` | `.\00-Master-Setup.ps1 -Role CRM-SERVER` ⚠️ 15 min |
| PRINTER | any admin | `.\00-Master-Setup.ps1 -Role PRINTER` |
| ROUTER | any admin | `.\00-Master-Setup.ps1 -Role ROUTER` |
| Solo study | any admin | `.\00-Master-Setup.ps1 -Role ALL` |

> **Create the user account before running the script** — the script places evidence files under that user's profile (`C:\Users\rahul.s\`, etc.)
>
> ```powershell
> net user rahul.s Gr@2026Agent01 /add
> net localgroup Administrators rahul.s /add
> ```
> Then log out and back in as that user, then run the setup script.

### 3. Verify

```powershell
# Check what was created and its hashes
Import-Csv C:\GR_LabSetup\hashes.csv | Format-Table Role, FilePath, SHA256 -AutoSize

# Check the log
Get-Content C:\GR_LabSetup\setup.log | Select-Object -Last 20
```

Script ends with **DONE** (green) = all good. **DONE_WITH_CONCERNS** = check the log. **BLOCKED** = check the log, fix and rerun.

### 4. Verify the database (CRM-SERVER only)

```powershell
C:\xampp\mysql\bin\mysql.exe -u root golden_crm -e `
  "SELECT 'victims' as tbl, COUNT(*) as n FROM victims
   UNION SELECT 'leads', COUNT(*) FROM leads
   UNION SELECT 'transactions', COUNT(*) FROM transactions
   UNION SELECT 'call_logs', COUNT(*) FROM call_logs;"
```

Expected: `487 · 12000 · 2314 · 891`

---

## Recommended deployment order

```
CRM-SERVER first  →  takes ~15 min, download runs in background
MANAGER-PC        →  5 min
AGENT-01 to 05   →  run all 5 in parallel (~4 min each)
PRINTER + ROUTER  →  2 min each, run on any spare machine
```

---

## Static IP setup (Windows 10)

**Control Panel → Network → Change adapter settings → Right-click → Properties → IPv4**

| Machine | IP Address | Subnet Mask | Default Gateway |
|---|---|---|---|
| AGENT-01 | 192.168.10.11 | 255.255.255.0 | 192.168.10.1 |
| AGENT-02 | 192.168.10.22 | 255.255.255.0 | 192.168.10.1 |
| AGENT-03 | 192.168.10.33 | 255.255.255.0 | 192.168.10.1 |
| AGENT-04 | 192.168.10.44 | 255.255.255.0 | 192.168.10.1 |
| AGENT-05 | 192.168.10.55 | 255.255.255.0 | 192.168.10.1 |
| MANAGER-PC | 192.168.10.50 | 255.255.255.0 | 192.168.10.1 |
| CRM-SERVER | 192.168.10.100 | 255.255.255.0 | 192.168.10.1 |

---

## Offline deployment (no internet)

1. Download [sqlite3.exe](https://www.sqlite.org/download.html) (Windows x86) and place it at `scripts\shared\sqlite3.exe`
2. Download [XAMPP 8.2.x](https://www.apachefriends.org/download.html) and place the installer at `C:\Temp\xampp-installer.exe` on the CRM-SERVER before running the script
3. Everything else works offline

---

## Tools trainees will use during the exercise

All free, all Windows:

| Tool | Purpose | Download |
|---|---|---|
| FTK Imager | Disk imaging, RAM preview, logical export | exterro.com |
| Belkasoft RAM Capturer | Live RAM dump | belkasoft.com |
| WinPmem | CLI RAM capture | github.com/Velocidex/WinPmem |
| Autopsy | Full forensic analysis | sleuthkit.org |
| Registry Explorer | Hive analysis | ericzimmerman.github.io |
| Browser History Examiner | Chrome/Firefox SQLite | forenx.com |
| NirSoft Suite | USBDeview, BrowserHistoryView, etc. | nirsoft.net |
| DB Browser for SQLite | Manual SQLite inspection | sqlitebrowser.org |
| Wireshark | PCAP analysis | wireshark.org |
| HashCalc / Get-FileHash | MD5 + SHA256 verification | built-in PS / slavasoft.com |

---

## Legal references (India)

| Section | Applicability |
|---|---|
| IT Act 2000 §43, §65, §66, §66C, §66D | Computer offences, fraud, impersonation |
| IT Act 2000 §69 | Interception / monitoring order |
| CrPC §91 / BNSS 2023 equivalent | Production of documents / preservation requests |
| CrPC §165 | Search warrant |
| BSA 2023 §63 (formerly IEA §65B) | Certificate for electronic evidence admissibility |

---

## Cross-system evidence map (spoiler — instructor only)

The key correlations that prove the full conspiracy:

1. **AGENT-01 closer_script.docx** → contains exact victim phone → **MANAGER-PC victims_master.xlsx** row → same victim in **CRM-SERVER transactions** table
2. **AGENT-03 call recording** `2026-04-17_1822_V202.wav` → **CRM-SERVER call_logs** row 202
3. **AGENT-04 UPI screenshot** `upi_20260417_1842.png` (₹50,000) → **CRM-SERVER transactions** row 1842
4. **AGENT-05 registry Run key** → `updater.exe` → stub.ps1 → `# TODO: exfil to telegram when stable` (future crime intent)
5. **MANAGER-PC VeraCrypt E:\** (password on sticky note under keyboard: `Gr@Vault2026!`) → contains `mule_rota_history.xlsx` + `confession_2026-04-17.mp3`
6. **Router DNS log** → `t.me` from `192.168.10.50` at 23:47 every night → MANAGER-PC scheduled task `DailyCollectionReport`
7. **Printer job log** entry 032 → `Mule_Accounts_Q4.pdf` printed by `arjun.m` at 18:44 on the day of the raid

---

## Disclaimer

All victim names, phone numbers, UPI IDs, bank accounts, Telegram handles, company names, and transaction data in this lab are **entirely synthetic and fictional**. This lab is for **law enforcement training only**. Do not deploy on production networks.

The "malware" stub on AGENT-05 (`updater.exe`) is **benign** — it only creates a `passwords.txt` file on detected USB insertion. It performs no real exfiltration. Safe to run in a sandboxed training environment.
