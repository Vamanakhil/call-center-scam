# 04 — Evidence Map

> A single-document reference of **where** each piece of evidence lives and **what tool** unlocks it.

## 1. Evidence by system

### AGENT-01 (Rahul — closer) — 192.168.10.11

| # | Evidence | Path | Type | Tool to extract |
|---|---|---|---|---|
| A1-1 | Closer script | `C:\Users\rahul.s\Desktop\closer_script.docx` | Document | FTK / Word |
| A1-2 | Hot leads list | `C:\Users\rahul.s\Desktop\hot_leads_today.txt` | Text | FTK |
| A1-3 | Daily target note | `C:\Users\rahul.s\Desktop\Daily_Target.txt` | Text | FTK |
| A1-4 | Browser history | `C:\Users\rahul.s\AppData\Local\Google\Chrome\User Data\Default\History` | SQLite | DB Browser / BHE |
| A1-5 | Saved passwords | `…\Login Data` | SQLite (encrypted) | mimikatz / Elcomsoft |
| A1-6 | WhatsApp Web session | `…\Downloads\whatsapp_web_session_export.zip` | Archive | unzip |
| A1-7 | Old closer script (deleted) | `C:\$Recycle.Bin\S-1-5-21-…\closer_script_old.docx` | Recovered | Recuva / Autopsy |
| A1-8 | RAM — open WhatsApp Web tabs | Live memory | RAM | Volatility / strings |
| A1-9 | USB history | `HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR` | Registry | USBDeview / Registry Explorer |

### AGENT-02 (Priya — lead gen) — 192.168.10.22

| # | Evidence | Path | Type | Tool to extract |
|---|---|---|---|---|
| A2-1 | Lead CSV (12k) | `C:\Users\priya.v\Desktop\leads_apr2026.csv` | CSV | FTK |
| A2-2 | LinkedIn scraper | `C:\Users\priya.v\Documents\scraping_scripts\linkedin_scrape.py` | Python | FTK |
| A2-3 | Facebook export | `C:\Users\priya.v\Documents\scraping_scripts\fb_audience_export.json` | JSON | FTK |
| A2-4 | Browser history (LinkedIn, FB) | `…\History` | SQLite | BHE |
| A2-5 | Sales Nav reminder | `C:\Users\priya.v\Desktop\Sales_Nav_Renewal.txt` | Text | FTK |
| A2-6 | RAM — Chrome process memory | Live | RAM | strings |
| A2-7 | Sticky notes | `…\Local\Packages\Microsoft.StickyNotes_8wekyb3d8bbwe\...` | SQLite | FTK |

### AGENT-03 (Amit — VoIP) — 192.168.10.33

| # | Evidence | Path | Type | Tool to extract |
|---|---|---|---|---|
| A3-1 | Call recordings (47) | `E:\callrecordings\` (64 GB MicroSD) | WAV | FTK |
| A3-2 | Softphone config | `C:\Users\amit.p\AppData\Roaming\X-Lite\config.xml` | XML | FTK |
| A3-3 | AnyDesk ID | Desktop icon / registry | Reg | Registry Explorer |
| A3-4 | Old closer script (Recycle Bin) | `C:\$Recycle.Bin\…\closer_script_old.docx` | Recovered | Recuva / Autopsy |
| A3-5 | Recent files (the master victim list) | `…\Roaming\Microsoft\Windows\Recent\victims_master.xlsx.lnk` | LNK | LECmd / Eric Zimmerman |
| A3-6 | Browser history (CRM admin) | `…\History` | SQLite | BHE |

### AGENT-04 (Sneha — payment chaser) — 192.168.10.44

| # | Evidence | Path | Type | Tool to extract |
|---|---|---|---|---|
| A4-1 | UPI screenshots (312) | `C:\Users\sneha.i\Desktop\UPI_Screenshots\` | PNG | FTK |
| A4-2 | Payment follow-up template | `C:\Users\sneha.i\Documents\payment_followup_template.docx` | Document | FTK |
| A4-3 | Telegram Desktop session | `C:\Users\sneha.i\AppData\Roaming\Telegram Desktop\tdata\` | Encrypted | Telegram export / carving |
| A4-4 | Browser history (Telegram web) | `…\History` | SQLite | BHE |
| A4-5 | Mule account list (recents) | `…\Roaming\Microsoft\Windows\Recent\Mule_Accounts_Q4.xlsx.lnk` | LNK | LECmd |
| A4-6 | Deleted Telegram chat export | `C:\$Recycle.Bin\…\support_chat_export.html` | Recovered | Recuva / Autopsy |

### AGENT-05 (Vikas — IT) — 192.168.10.55

| # | Evidence | Path | Type | Tool to extract |
|---|---|---|---|---|
| A5-1 | Malware stub | `C:\ProgramData\Updater\updater.exe` (registry: `HKLM\…\Run\Updater`) | PE | VirusTotal (in sandbox) |
| A5-2 | Stub source | `C:\Users\vikas.n\Documents\stub.ps1` | PS1 | FTK |
| A5-3 | Raspberry Pi script | `C:\Users\vikas.n\Documents\pi_ping.py` | Python | FTK |
| A5-4 | Hidden USB (book) | Inside hollowed-out book | USB | FTK Imager + write-blocker |
| A5-5 | Spare HDD (labeled BACKUP) | In desk drawer | HDD | FTK Imager |
| A5-6 | CRM admin RDP profile | `C:\Users\vikas.n\AppData\Local\Microsoft\Terminal Server Client\…` | RDP files | FTK |
| A5-7 | Registry run keys | `HKLM\…\Run\Updater` | Reg | Registry Explorer |
| A5-8 | Scheduled task | `\Updater\DailyTrigger` | XML | taskschd.msc / Autopsy |
| A5-9 | `passwords.txt` planted on USB | (auto-created on USB insert) | TXT | FTK Imager |
| A5-10 | Browser history (CRM, admin panel) | `…\History` | SQLite | BHE |

### MANAGER-PC (Arjun) — 192.168.10.50

| # | Evidence | Path | Type | Tool to extract |
|---|---|---|---|---|
| M-1 | Master victim list | `D:\Manager\victims_master.xlsx` | XLSX | FTK / Excel |
| M-2 | Mule accounts | `D:\Manager\Mule_Accounts_Q4.xlsx` | XLSX | FTK |
| M-3 | Daily collection report | `D:\Manager\Daily_Collection_2026-04-17.xlsx` | XLSX | FTK |
| M-4 | Telegram session | `C:\Users\arjun.m\AppData\Roaming\Telegram Desktop\tdata\` | Encrypted | Telegram export |
| M-5 | Outlook PST | `C:\Users\arjun.m\AppData\Local\Microsoft\Outlook\arjun@goldenreturns.example.pst` | PST | FTK / pst-viewer |
| M-6 | AnyDesk session logs | `C:\Users\arjun.m\AppData\Roaming\AnyDesk\ad_sessions.log` | Log | FTK |
| M-7 | Browser history (Telegram, banking) | `…\Edge\User Data\Default\History` | SQLite | BHE |
| M-8 | VeraCrypt volume | `D:\Manager\vault.veracrypt` mounted as E: | Volume | FTK (mount E01, do NOT close volume) |
| M-9 | Hidden pen drive | False-bottom drawer | USB | FTK Imager |
| M-10 | OneDrive folder | `C:\Users\arjun.m\OneDrive\` | Cloud | FTK + Section 91 to MS |
| M-11 | Scheduled task: Daily report | `\DailyCollectionReport` | XML | taskschd.msc |
| M-12 | Scheduled task: DNS flush | `\DNSFlush` (2 AM daily) | XML | taskschd.msc |
| M-13 | Recycle Bin: `complaint_list.xlsx` | `C:\$Recycle.Bin\…\` | Recovered | Recuva / Autopsy |
| M-14 | Registry: USB history | `HKLM\…\Enum\USBSTOR` | Reg | USBDeview |

### CRM-SERVER — 192.168.10.100

| # | Evidence | Path | Type | Tool to extract |
|---|---|---|---|---|
| S-1 | MySQL `golden_crm` database | `C:\xampp\mysql\data\golden_crm\` | MySQL | mysqldump / FTK |
| S-2 | `victims` table (487 rows) | (in DB) | SQL | MySQL client |
| S-3 | `leads` table (12,000 rows) | (in DB) | SQL | MySQL client |
| S-4 | `transactions` table (2,314 rows) | (in DB) | SQL | MySQL client |
| S-5 | `call_logs` table (891 rows) | (in DB) | SQL | MySQL client |
| S-6 | `users` table (admin creds) | (in DB) | SQL | MySQL client |
| S-7 | CRM web app source | `C:\xampp\htdocs\golden_crm\` | PHP | FTK |
| S-8 | Hidden backup share | `\\CRM-SERVER\old\golden_crm_backup_2026-04-15.sql` | SQL | SMB copy |
| S-9 | `D:\CRM\uploads\` (call recordings) | SMB share | WAV | FTK |
| S-10 | Security log (Event Viewer) | `C:\Windows\System32\winevt\Logs\Security.evtx` | EVTX | FTK / EvtxECmd |
| S-11 | Firewall log | `C:\Windows\System32\LogFiles\Firewall\pfirewall.log` | Log | FTK |
| S-12 | RAM — running MySQL queries | Live | RAM | Volatility |
| S-13 | RDP session list | `qwinsta` output | CLI | screenshot |
| S-14 | Network connections | `netstat -ano` output | CLI | screenshot |

### PRINTER — 192.168.10.30

| # | Evidence | Path | Type | Tool to extract |
|---|---|---|---|---|
| P-1 | Print spool share | `\\PRINTER\Spool\` | SMB | FTK |
| P-2 | Recent jobs (18) | Spool share | PDF/PS | FTK |
| P-3 | Last 32 jobs on printer flash | n/a (web UI) | Internal | web UI screenshot |
| P-4 | Page count log | n/a (web UI) | Internal | web UI screenshot |

### ROUTER — 192.168.10.1

| # | Evidence | Path | Type | Tool to extract |
|---|---|---|---|---|
| R-1 | Running config | `tftp://<laptop>/running-config` | Text | console cable |
| R-2 | DHCP lease table | web UI | HTML | screenshot |
| R-3 | Port-forward rules | web UI | HTML | screenshot |
| R-4 | DNS resolver cache | `/tmp/dns.log` (if supported) | Text | console cable |
| R-5 | WAN IP / MAC | web UI | HTML | screenshot |

### PHONES (3)

| # | Evidence | Path | Type | Tool to extract |
|---|---|---|---|---|
| PH-1 | Floor phone (basic) | n/a (call logs only) | Phone | screen capture |
| PH-2 | Manager's iPhone (locked) | n/a | Phone | Cellebrite UFED |
| PH-3 | Burner Android (Telegram) | n/a | Phone | Cellebrite UFED / chip-off |

## 2. Cross-system evidence correlation

A trainee who examines **only one machine** will miss 80 % of the picture. The following correlations must be made:

| Finding on A | Confirmed by | Confirms on B |
|---|---|---|
| Browser history `goldenreturns.example/customer` on all 5 agents | CRM-SERVER Apache access log | All 5 agents were CRM users |
| AGENT-01's `closer_script.docx` mentions victim phone `+91 90000 00011` | MANAGER-PC `victims_master.xlsx` row 11 | The number is real, and the script was followed |
| AGENT-02's `leads_apr2026.csv` row 47 (VICTIM-047) | AGENT-04's `payment_followup_template.docx` "VICTIM-047" | Lead was passed from lead-gen to closer to payment chaser |
| AGENT-03's call recording `E:\callrecordings\2026-04-17_1822.wav` (VICTIM-202) | CRM-SERVER `call_logs` row 202 | Recording matches CRM record |
| AGENT-04's UPI screenshot `UPI_Screenshots\upi_2026-04-17_1842.png` (Rs 50,000) | CRM-SERVER `transactions` row 1842 | Payment was logged |
| AGENT-05's RDP profile targets `192.168.10.100` | CRM-SERVER Security log 4624 | IT guy logged into the server at 02:14 |
| MANAGER-PC's `Mule_Accounts_Q4.xlsx` lists HDFC XXXXXX4242 | CRM-SERVER `transactions.beneficiary_account` | 142 transactions went to that account |
| MANAGER-PC's VeraCrypt `E:\mule_rota_history.xlsx` | AGENT-04's `Recent\Mule_Accounts_Q4.xlsx.lnk` | They were coordinating the same file |
| Router DNS lookup `t.me` from 192.168.10.50 at 23:47 | MANAGER-PC scheduled task `DailyCollectionReport` | Manager auto-sent daily report to Telegram at 23:47 |
| AGENT-05's malware stub planted `passwords.txt` on USB | USB image shows `passwords.txt` | Malware was active |

## 3. The "aha" moments (instructor highlights)

1. **AGENT-01's `closer_script.docx`** has a paragraph starting with the phrase `"When the victim says 'I will call SEBI'..."` — that single sentence is enough to prove fraudulent intent.
2. **MANAGER-PC's `E:\complaints_to_ignore.xlsx`** contains the names of three Andheri cyber cell officers who had previously emailed complaints — this is witness-tampering evidence.
3. **AGENT-05's `stub.ps1`** has a comment block `"# TODO: exfil to telegram when stable"` — that is intent to commit a future crime (admissible in some jurisdictions as consciousness of guilt).
4. **CRM-SERVER's `D:\Backups\old\`** has yesterday's full SQL backup including the `victims` table — proving the manager knew about the database and tried to back it up off-site.
5. **The router's `relay.anydesk.com` DNS lookup** at the exact same minute as the RDP brute-force proves the manager was using AnyDesk to remote in.
