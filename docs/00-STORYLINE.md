# 00 — Storyline: Golden Returns Wealth Management

## 1. The company

**Golden Returns Wealth Management Pvt. Ltd.** is a fictitious investment-advisory firm registered at:

> 3rd Floor, Kuber Complex, Andheri West, Mumbai — 400 058
> GSTIN: 27AABCG1234R1ZP (synthetic)
> CIN: U67120MH2020PTC123456 (synthetic)

The firm claims to provide **portfolio-management services** in equities, crypto, and "AI-driven forex" products, promising returns of **3 % to 8 % per week** to its clients.

The company was incorporated in **March 2020**. In reality it has never placed a single trade on any exchange. It is a **Ponzi-style investment fraud** operating as a **boiler-room call centre**.

The company has a **website** at `goldenreturns.example` (offline in the lab) and a **Telegram support channel** `t.me/goldsupport_real` (synthetic).

## 2. The cast

| Role | Real name (synthetic) | Username on system | Hostname | Role in the fraud |
|---|---|---|---|---|
| **Ringleader / Manager** | Arjun Mehta | `arjun.m` | `MANAGER-PC` | Controls the master victim list, mule accounts, daily targets, and Telegram C2 channel |
| **Senior closer (Agent 1)** | Rahul Sharma | `rahul.s` | `AGENT-01` | The "closer" — converts leads into paying victims, runs the high-pressure script |
| **Lead generator (Agent 2)** | Priya Verma | `priya.v` | `AGENT-02` | Scrapes LinkedIn / Facebook / Instagram for "wealthy-looking" targets, dumps them into the CRM |
| **VoIP caller (Agent 3)** | Amit Patel | `amit.p` | `AGENT-03` | Operates the SIP softphone, records calls locally, uploads to the server nightly |
| **Payment chaser (Agent 4)** | Sneha Iyer | `sneha.i` | `AGENT-04` | Sends UPI QR codes, follows up on pending payments, holds the Telegram session for "support" |
| **IT support (Agent 5)** | Vikas Nair | `vikas.n` | `AGENT-05` | Set up all machines, maintains the malware stub that auto-exfiltrates browser passwords to a hidden USB, admin to CRM-SERVER |

## 3. How the scam operated (the playbook)

### 3.1 Lead generation
- `AGENT-02 (Priya)` uses LinkedIn Sales Navigator (trial), Facebook Ads Manager (audience scraping), and a purchased list of 3200 Indian mobile numbers to build a `leads_apr2026.csv` (12,000 rows, of which 487 will "convert").
- Each lead is tagged with a "heat score" — how likely they are to invest based on their profile (job title, location, age).

### 3.2 First contact
- `AGENT-03 (Amit)` calls from a SIP trunk using a softphone (X-Lite / Zoiper). The Caller ID is **spoofed** to show an HDFC relationship-manager number.
- The script is in `closer_script.docx` (on `AGENT-01`). It is a 12-page document with rebuttals for every objection ("but the SEBI website doesn't show you", "I'll call the police", etc.).
- A **recorded line** is used so management can audit calls. Recordings are stored on the agent's local MicroSD card and uploaded nightly to the server.

### 3.3 The "investment"
- The victim is asked to "start small" — Rs 5,000 or Rs 10,000 — paid via UPI to a "compliance account" that is actually a **mule account** controlled by `Arjun (MANAGER-PC)`.
- The dashboard at `goldenreturns.example/customer` (a static page served by the CRM-SERVER XAMPP stack) shows fake profits growing. The dashboard uses the victim's name and the amount they deposited.
- `AGENT-04 (Sneha)` chases payments and handles the Telegram support channel `t.me/goldsupport_real`.

### 3.4 The kill
- When the victim asks to **withdraw**, the closer uses a series of stalling scripts ("SEBI compliance check", "TDS deduction in process", "minimum holding period of 90 days").
- After 90 days, the closer either:
  - Asks for an "exit fee" (15 % of the principal)
  - Asks for "tax clearance" (another 10 %)
  - Goes silent and blocks the number
- The Telegram channel is renamed and the support agent rotates to a new handle.
- The CRM-SERVER `victims` table records the `final_outcome` = `BURNED`.

### 3.5 The accounting
- Mule accounts are rotated weekly. The current six mules are on `MANAGER-PC` in `D:\Manager\Mule_Accounts_Q4.xlsx` (also printed at the office printer).
- Daily collection reports are sent to a private Telegram channel `t.me/gr_daily_collect` at 23:00 every night by `MANAGER-PC` Task Scheduler.
- `Arjun` retains 35 %, the manager 10 %, the closer 5 %, the rest is reinvested into the next round of leads.

## 4. How money was collected

- UPI IDs: `arjun.collect@upi`, `gr.deposit@upi`, `compliance.gr@upi` (synthetic)
- Bank accounts (mules, all synthetic): **HDFC XXXXXX4242, ICICI XXXXXX9191, Axis XXXXXX7720, Kotak XXXXXX3344, SBI XXXXXX1008, Yes Bank XXXXXX5500**
- Crypto: TRC20 USDT to wallet `TXyzABC…fake` (synthetic)

## 5. How evidence exists on systems

- Every agent's browser history contains the victim-spoofing sites, the CRM admin URL, and the Telegram web URL.
- The CRM-SERVER's MySQL database `golden_crm` contains 487 `victims`, 12 000 `leads`, 2 314 `transactions`, 891 `call_logs`.
- The MANAGER-PC contains the master `victims_master.xlsx` with full PII, the mule accounts, the Telegram session file, and a VeraCrypt volume `vault.veracrypt` that may contain a "do-not-open" list of investigators who complained.
- The printer's spool folder contains 18 PDFs that were printed in the last 7 days — the daily collection report, the mule account list, the bonus list.
- The router's config contains a port-forward rule allowing RDP to CRM-SERVER, plus a static DHCP reservation for AGENT-05.

## 6. How criminals attempted to hide evidence

- `AGENT-05` installed a **benign malware stub** that, on detecting a USB insertion, copies a `passwords.txt` file to it. The stub also runs at startup from `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`. Trainees must find it in the registry and the scheduled task.
- The MANAGER-PC has a **VeraCrypt container** `D:\Manager\vault.veracrypt` mounted as `E:`. Inside: `mule_rota_history.xlsx`, `victims_to_burn.xlsx`, `private_keys.txt`, and an embarrassing audio confession.
- The CRM-SERVER has a **hidden share** `D:\Backups\old\` with yesterday's `golden_crm_backup_2026-04-15.sql` — the manager thought the share was hidden because the `$` suffix was missing, but it is still visible.
- AGENT-03 has a **Recycle Bin** entry for `closer_script_old.docx` containing an older, more incriminating version of the script.
- AGENT-04 has a **deleted Telegram session** with the victim-support handle in `C:\Users\sneha.i\AppData\Roaming\Telegram Desktop\tdata\` — the folder is present but most files are zeroed out, requiring file carving.
- The router's **DNS resolver cache** is wiped daily at 02:00 by a scheduled task on the MANAGER-PC, but the **DNS log file** in the router's `/tmp/dns.log` was not rotated and contains the Telegram lookups.

## 7. The trigger — why the raid is happening

A **complaint** was filed at **Andheri Cyber Cell** on **15-Apr-2026** by a retired school-teacher who lost Rs 14.3 lakh. The crime branch traced the UPI to `arjun.collect@upi` which led to a mule account at HDFC XXXXXX4242 in the name of "Arjun Mehta".

A **lookout circular (LOC)** was issued. On **18-Apr-2026** the Andheri police received an anonymous tip-off that the operation runs from a flat in Kuber Complex. A team of **two DSPs, one inspector, four sub-inspectors, two constables, and a forensic expert** is dispatched with a warrant under **Section 165 CrPC / Section 91 BNSS 2023** and a **Section 69 IT Act** interception order.

The team has **45 minutes** to secure the scene, image the systems, and pull out before the suspects' lawyer is tipped off.
