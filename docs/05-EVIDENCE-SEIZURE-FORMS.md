# 05 — Evidence Seizure Forms (CCTNS-aligned templates)

> All field labels match the **CCTNS** (Crime and Criminal Tracking Network & Systems) and **ICJS** (Inter-operable Criminal Justice System) field reporting standards used by Indian State Police.

---

## 5.1 Seizure Memo (initial entry — Form CCTNS-FIR-EXHIBIT-A)

```
ANDHERI CYBER CELL — MUMBAI POLICE
SEIZURE MEMO  (Form CCTNS-FIR-EXHIBIT-A)

Case FIR No.       : 0147/2026
U/s                : Sec 66C, 66D IT Act 2008 / Sec 420 IPC / Sec 91 CrPC
Date of seizure    : 18-Apr-2026
Time of entry      : 11:32 hrs IST
Place              : 301, Kuber Complex, Andheri W, Mumbai 58
Search warrant     : W/2026/AC-145 (Sec 165 CrPC / Sec 94 BNSS)
Authorising mag.   : Metropolitan Magistrate, Andheri
Lead officer       : Insp. R. K. Singh (Badge 4421)
Assisted by        : SI P. Nair (Badge 3398), SI V. Desai (Badge 3401),
                    4 constables, 1 forensic expert (CCL Mumbai)

Suspects present at scene:
  1. Arjun Mehta    s/o R. Mehta, age 34, MANAGER         (apprehended)
  2. Rahul Sharma   s/o V. Sharma, age 26, AGENT-01       (apprehended)
  3. Priya Verma    d/o A. Verma, age 24, AGENT-02        (apprehended)
  4. Amit Patel     s/o H. Patel, age 27, AGENT-03        (apprehended)
  5. Sneha Iyer     d/o K. Iyer, age 23, AGENT-04         (apprehended)
  6. Vikas Nair     s/o S. Nair, age 29, AGENT-05         (apprehended)

Witnesses (independent, present during seizure):
  1. Mr. Suresh Patil, s/o B. Patil, age 51, neighbour flat 302
  2. Mrs. Anita Joshi, w/o R. Joshi, age 47, building watchman wife

ITEMS SEIZED — SUMMARY (detailed list on 5.2)

  E-01  Workstation HP ProDesk   AGENT-01 (Rahul)     seal # MSL-2026-001
  E-02  Workstation Lenovo M720q AGENT-02 (Priya)     seal # MSL-2026-002
  E-03  Workstation Ryzen 5 3600 AGENT-03 (Amit)      seal # MSL-2026-003
  E-04  Workstation Dell 5070    AGENT-04 (Sneha)     seal # MSL-2026-004
  E-05  Workstation HP EliteDesk AGENT-05 (Vikas)     seal # MSL-2026-005
  E-06  Workstation Custom i9    MANAGER-PC (Arjun)   seal # MSL-2026-006
  E-07  Server Dell T340         CRM-SERVER           seal # MSL-2026-007
  E-08  Router TP-Link WR940N                         seal # MSL-2026-008
  E-09  Switch TP-Link SG1008D                        seal # MSL-2026-009
  E-10  Printer HP M404n                             seal # MSL-2026-010
  E-11  Pen drive SanDisk 32 GB   (AGENT-05 desk)     seal # MSL-2026-011
  E-12  Pen drive SanDisk 16 GB   (labeled BACKUP)    seal # MSL-2026-012
  E-13  Pen drive SanDisk 8 GB    (CRM export)        seal # MSL-2026-013
  E-14  Pen drive SanDisk 64 GB   (in book)           seal # MSL-2026-014
  E-15  HDD Seagate 2 TB         (AGENT-05 drawer)    seal # MSL-2026-015
  E-16  MicroSD 64 GB            (AGENT-03 front)     seal # MSL-2026-016
  E-17  iPhone 14 Pro            (Arjun Mehta)        seal # MSL-2026-017
  E-18  Android Redmi Note 12    (no SIM)             seal # MSL-2026-018
  E-19  A4 file w/ 47 sheets     (printed complaints) seal # MSL-2026-019
  E-20  Raspberry Pi 4 + SD card (Vikas shelf)        seal # MSL-2026-020

Seized by : Insp. R. K. Singh (Badge 4421)
Witnessed : Mr. Suresh Patil
Photos    : IMG_4001-IMG_4455  (total 454 photos)
Seizure completed at  : 12:45 hrs IST (18-Apr-2026)
Items transported to  : CCL Mumbai, Worli

Signatures :
_______________________  _______________________  _______________________
Insp. R. K. Singh       Witness S. Patil          Defending counsel *
                        (if present)
```

## 5.2 Per-item seizure description (one block per item)

```
ITEM  : E-01
TAG   : MSL-2026-001
MAKE  : HP ProDesk 400 G5
S/N   : INA4521K8P (synthetic)
ASSET : Golden-Returns-AG-01
HOST  : AGENT-01
USER  : rahul.s
POWER : ON at entry (screen on, Chrome open to goldenreturns.example)
RAM   : captured via Belkasoft RAM Capturer to E:\EVIDENCE\AGENT-01.mem (8.2 GB)
        SHA256: a1b2c3d4e5... (see 07-HASH-VERIFICATION.md)
VOLATILE: tasklist, netstat, ipconfig, wevtutil saved to E:\EVIDENCE\VOLATILE\
DISK  : imaged via FTK Imager → E01, 1 TB, segmented 4 GB
        SHA256: f6e5d4c3b2... (see 07-HASH-VERIFICATION.md)
SEAL  : tamper-evident bag MSL-2026-001, signed by Insp. Singh & witness
CHAIN : see 06-CHAIN-OF-CUSTODY.md row #1
```

(Blocks 5.2.2 through 5.2.20 follow the same template — one block per seized item.)

## 5.3 Photograph log (front, back, side, screen)

```
PHOTO  SUBJECT                                  PHOTOGRAPHER   TIME
IMG_4001  Room overview, entrance              Insp. Singh    11:32
IMG_4002  Room overview, 360°                  Insp. Singh    11:33
...
IMG_4101  AGENT-01 screen, Chrome on CRM       Insp. Singh    11:41
IMG_4102  AGENT-01 system tray, AnyDesk icon   SI Nair        11:42
IMG_4103  AGENT-01 closer_script.docx open     SI Nair        11:42
IMG_4104  AGENT-01 desktop, hot_leads list     SI Nair        11:43
IMG_4105  AGENT-01 power button pressed, 4s    SI Desai       11:48
IMG_4106  AGENT-01 back panel, S/N sticker     SI Desai       11:49
IMG_4107  AGENT-01 HDD removed, label          SI Desai       12:01
...
IMG_4201  AGENT-05 book "Hacking Exposed 7"   Insp. Singh    12:10
IMG_4202  AGENT-05 book, hollowed-out cavity   Insp. Singh    12:10
IMG_4203  AGENT-05 pen drive, sealed           Insp. Singh    12:11
...
IMG_4301  MANAGER-PC screen, Telegram open     Insp. Singh    12:15
IMG_4302  MANAGER-PC E: drive (VeraCrypt)      Insp. Singh    12:15
IMG_4303  MANAGER-PC false-bottom drawer open  Insp. Singh    12:18
IMG_4304  MANAGER-PC pen drive, sealed         SI Nair        12:19
...
IMG_4401  CRM-SERVER console, all 4 disks      Insp. Singh    12:25
IMG_4402  CRM-SERVER mysqldump process running SI Desai       12:30
...
```

## 5.4 Volatile evidence checklist (one per workstation)

```
VOLATILE EVIDENCE — AGENT-01
Officer : ___________________________  Date/time : 18-Apr-2026 11:46 IST

[✓] Photo of screen with all windows visible
[✓] tasklist /v            → E:\VOL\AGENT-01_tasklist.txt   (SHA256: 9f8e...)
[✓] tasklist /svc          → E:\VOL\AGENT-01_tasklist_svc.txt
[✓] netstat -ano           → E:\VOL\AGENT-01_netstat.txt    (SHA256: 7d6c...)
[✓] netstat -b             → E:\VOL\AGENT-01_netstat_b.txt  (couldn't — admin needed, ran as admin)
[✓] ipconfig /all          → E:\VOL\AGENT-01_ipconfig.txt
[✓] ipconfig /displaydns   → E:\VOL\AGENT-01_dns.txt
[✓] arp -a                 → E:\VOL\AGENT-01_arp.txt
[✓] route print            → E:\VOL\AGENT-01_route.txt
[✓] net session            → E:\VOL\AGENT-01_netsession.txt
[✓] net share              → E:\VOL\AGENT-01_netshare.txt
[✓] net user               → E:\VOL\AGENT-01_netuser.txt
[✓] net localgroup administrators → E:\VOL\AGENT-01_admins.txt
[✓] wmic process list full → E:\VOL\AGENT-01_wmic.txt
[✓] wmic startup list full → E:\VOL\AGENT-01_startup.txt
[✓] wmic service list brief → E:\VOL\AGENT-01_services.txt
[✓] wevtutil epl Security  → E:\VOL\AGENT-01_security.evtx
[✓] wevtutil epl System    → E:\VOL\AGENT-01_system.evtx
[✓] wevtutil epl Application → E:\VOL\AGENT-01_app.evtx
[✓] sc query               → E:\VOL\AGENT-01_sc.txt
[✓] reg export HKLM\…\Run → E:\VOL\AGENT-01_run.txt
[✓] clipboard screenshot   → IMG_4108
[✓] Screenshot of desktop  → IMG_4109
[✓] RAM dump (Belkasoft)  → E:\EVIDENCE\AGENT-01.mem  (8.2 GB)
       SHA256 : a1b2c3d4e5f6... (recorded in 07-HASH-VERIFICATION.md)

ALL volatile files written to a write-blocked USB
(serial WUSB-A-44112, last self-test 17-Apr-2026).
```

## 5.5 Sealed-bag control label

```
┌────────────────────────────────────────────┐
│   EVIDENCE TAG — MSL-2026-001              │
│                                            │
│   Item  : HP ProDesk 400 G5                │
│   Host  : AGENT-01 (Rahul Sharma)          │
│   Date  : 18-Apr-2026                      │
│   Time  : 11:48 IST                        │
│   Seized by : Insp. R. K. Singh 4421       │
│   Witness   : S. Patil                     │
│                                            │
│   ☐ Sealed  ☐ Chain tag attached           │
│                                            │
│   [  Sealing signature — do not remove  ]  │
└────────────────────────────────────────────┘
```

## 5.6 Section 91 CrPC / 94 BNSS production notice (sample)

```
To,
The Nodal Officer,
HDFC Bank Ltd.,
Mumbai Region

Subject: Production of account statements u/s 91 CrPC / 94 BNSS
          in connection with FIR 0147/2026, Andheri Cyber Cell

Sir/Madam,

In connection with the above FIR registered at Andheri Police Station
for offences u/s 66C, 66D IT Act 2008 and Sec 420 IPC, you are hereby
directed to produce the following records pertaining to the account(s)
listed below, in original or as certified copies, before the
undersigned within 7 (seven) days of receipt of this notice:

  Account holder : ARJUN MEHTA
  Account number : XXXXXXXXXXXX4242
  Branch         : Andheri West
  IFSC           : HDFC0ANDHERI
  Period         : 01-Jan-2024 to 18-Apr-2026

Required records:
  1. Complete statement of account for the period
  2. KYC documents at the time of account opening
  3. All debit/credit vouchers above Rs 50,000
  4. UPI transaction logs (sender VPA, receiver VPA, amount, time)
  5. Mobile number and email registered with the account
  6. Login IP logs for internet banking sessions
  7. CCTV footage of branch visits, if any, for the period

Non-compliance is punishable u/s 174 IPC (refusing to take
lawful oath) and/or relevant sections of the IT Act.

Yours faithfully,

(Insp. R. K. Singh)
Investigating Officer
Andheri Cyber Cell, Mumbai
Date : 18-Apr-2026
```

A full set of **ready-to-customise** Word versions of every form in this chapter is in `printables/`.
