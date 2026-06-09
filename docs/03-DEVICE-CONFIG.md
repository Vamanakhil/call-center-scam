# 03 — Device Configuration

## 1. Workstations (5 × Agent + 1 × Manager)

All workstations run **Windows 10 Pro 22H2** (or Windows 11 on MANAGER-PC) with the **same local admin password hint** (so trainees can correlate): the hint is a sticky note on the bottom of each keyboard reading `gr123!`.

| Host | User | Local Admin Pwd | Domain | Timezone |
|---|---|---|---|---|
| AGENT-01 | rahul.s | `Gr@2026Agent01` | WORKGROUP | IST |
| AGENT-02 | priya.v | `Gr@2026Agent02` | WORKGROUP | IST |
| AGENT-03 | amit.p | `Gr@2026Agent03` | WORKGROUP | IST |
| AGENT-04 | sneha.i | `Gr@2026Agent04` | WORKGROUP | IST |
| AGENT-05 | vikas.n | `Gr@2026Agent05` | WORKGROUP | IST |
| MANAGER-PC | arjun.m | `Arjun@MGR#2026` | WORKGROUP | IST |

Note: the **default Windows password hint** is `"manager's mobile last 4"` — a social-engineering trap. Real password is above.

## 2. CRM-SERVER

| Setting | Value |
|---|---|
| Hostname | CRM-SERVER |
| OS | Windows Server 2019 Standard (1809) |
| Domain | WORKGROUP |
| Admin user | Administrator / `Gr@Server2026!` |
| Local user `crm_app` | `Gr@Crm2026!` (MySQL login) |
| IP | 192.168.10.100 (static) |
| Subnet | 255.255.255.0 |
| Gateway | 192.168.10.1 |
| DNS | 8.8.8.8, 1.1.1.1 |
| XAMPP path | `C:\xampp\` |
| Apache config | `C:\xampp\apache\conf\httpd.conf` (port 80) |
| MySQL data | `C:\xampp\mysql\data\` |
| CRM web root | `C:\xampp\htdocs\golden_crm\` |
| Database | `golden_crm` |
| DB user | `crm_app` / `Gr@Crm2026!` |
| DB admin | `root` / (empty — XAMPP default, intentional) |
| Shares | `C$`, `D$`, `Victims` (D:\Victims), `Backups` (D:\Backups) |
| Hidden share | `D:\Backups\old\` is shared as `old` (no $ suffix, visible) |
| SMB signing | disabled |
| RDP | enabled (NLA only) |
| Firewall | on, all inbound blocked except 80, 443, 3389, 445 |
| Antivirus | Windows Defender (real-time on) |
| Backup | nightly at 02:00 to `D:\Backups\old\` |

## 3. Manager-PC detail

| Setting | Value |
|---|---|
| Hostname | MANAGER-PC |
| OS | Windows 11 Pro 23H2 |
| User | arjun.m |
| Local admin | `Arjun@MGR#2026` |
| IP | 192.168.10.50 (manual) |
| VeraCrypt | v1.26 (installed) |
| Mounted volume | E: ← D:\Manager\vault.veracrypt (DO NOT close) |
| Telegram Desktop | logged in as `@gr_dispatcher` (synthetic handle) |
| WhatsApp Web | logged in in Edge |
| Outlook | configured for `arjun@goldenreturns.example` (POP3) |
| Browser | Edge (default), Chrome |
| AnyDesk | installed, last connected to 103.41.218.91 |
| Auto-start | `Telegram`, `AnyDesk`, `Outlook`, `VeraCrypt Background Task` |
| Scheduled tasks | `DailyCollectionReport` at 23:00, `DNSFlush` at 02:00 |
| OneDrive | logged in as arjun@outlook.com (personal) |

## 4. Per-agent user-profile artifacts (paths)

All paths assume `C:\Users\<username>\`.

### 4.1 AGENT-01 (rahul.s) — closer

```
C:\Users\rahul.s\
├── Desktop\
│   ├── closer_script.docx            (12-page call script)
│   ├── hot_leads_today.txt           (12 phone numbers)
│   └── Daily_Target.txt              ("Target: 5L / day — Arjun")
├── Documents\
│   ├── call_notes_2026-04-17.md      (yesterday's notes)
│   └── Objection_Handling_Cheat_Sheet.pdf
├── Downloads\
│   ├── whatsapp_web_session_export.zip  (synthetic, contains 12 victim chats)
│   └── closer_script_old.docx        (in Recycle Bin)
├── AppData\Local\Google\Chrome\User Data\Default\
│   ├── History                       (SQLite — visit history)
│   ├── Login Data                    (SQLite — saved passwords)
│   └── Cache\
└── AppData\Roaming\Microsoft\Windows\Recent\
    └── (link files to recently opened documents)
```

### 4.2 AGENT-02 (priya.v) — lead generator

```
C:\Users\priya.v\
├── Desktop\
│   ├── leads_apr2026.csv             (12,000 rows, 487 marked "HOT")
│   └── Sales_Nav_Renewal.txt
├── Documents\
│   ├── scraping_scripts\
│   │   ├── linkedin_scrape.py        (Python)
│   │   └── fb_audience_export.json
│   └── CRM_Leads_Export_2026-04-17