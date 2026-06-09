# 06 — Chain of Custody

## 6.1 What is chain of custody?

A chronological, written record of:
- who seized the item
- when it was seized, where, why
- who has had physical or logical possession since
- what was done to it (image, hash, analysis)
- when it was transferred and to whom
- integrity at every transfer

Without this, evidence is **inadmissible** under **BSA 2023 Sec 63 (formerly IEA Sec 65B)**.

## 6.2 Form template

```
ANDHERI CYBER CELL — CHAIN OF CUSTODY  (CCTNS-EXHIBIT-COC)

Case FIR No.     : 0147/2026
Evidence Tag No. : MSL-2026-____
Item description : ________________________________________________

SEIZURE (initial)
Date / time      : _____ / _____ hrs IST
Location         : ________________________________________________
Seized by        : ____________________  (Badge: ______)
Witnessed by     : ____________________  (Address: ______________)
Reason           : ________________________________________________

TRANSFER 1
Date / time      : _____ / _____ hrs IST
From / To        : ____________________ / ____________________
Method           : ☐ Hand  ☐ Sealed bag  ☐ Courier (tracking # ____)
Seal intact?     : ☐ Yes  ☐ No (explain: ________________________)
Hash verified?   : ☐ Yes — matches original  ☐ No
Receiver notes   : ________________________________________________

TRANSFER 2 / 3 / 4 … (repeat as many times as the item moves)
[Full template in printables/Chain_of_Custody_Form.md]

FINAL DISPOSITION
Date / time      : _____ / _____ hrs IST
Disposed to      : ☐ Court Malkhana  ☐ FSL long-term store
                  ☐ Returned to owner (Sec 451 CrPC order attached)
                  ☐ Destroyed (Sec 452 CrPC order attached)
Authorising order no. : ________________________
```

## 6.3 Custody-history example (E-01, AGENT-01)

```
#  Date        Officer          Location           Action
1  18-Apr 11:48 Insp. Singh     Crime scene        Seized, RAM dumped, volatile captured
2  18-Apr 12:30 Insp. Singh     Transport to CCL   In tamper-evident bag MSL-2026-001
3  18-Apr 14:15 FSL Off. A.     CCL WS-3           Imaged (FTK Imager → E01, 1 TB)
4  18-Apr 17:42 FSL Off. A.     CCL WS-3           Hashed (SHA256) — matches seizure
5  19-Apr 10:00 FSL Off. A.     CCL Locker-7       Stored (sealed bag re-validated)
6  22-Apr 11:00 Insp. Singh     CCL WS-3           Reviewed, file-list exported
7  23-Apr 09:30 Insp. Singh     Court Malkhana     Lodged as Exhibit P-14
```

## 6.4 Rules every cyber cell officer must follow

1. **Every transfer is signed by both parties.** No exceptions — verbal handovers are not chain of custody.
2. **Hashes are verified at every transfer.** If the hash doesn't match, the item is treated as compromised and a fresh image is made.
3. **Seals are photographed at every transfer.** The bag is photographed sealed, opened, and re-sealed.
4. **The bag never leaves the sight of a sworn officer** unless the next custodian is a sworn officer or the item is in a locked CCL locker with a tamper-evident seal.
5. **No analyst touches the original image** — all analysis is done on a working copy, the original `.E01` is never written to after the initial creation.
6. **Every page of the chain-of-custody form is witnessed by an independent person** (preferably a magistrate, defence counsel, or independent witness).
7. **The chain-of-custody form is appended to the case diary** (roznamcha) at the end of each day.

## 6.5 Common trainee mistakes

- ❌ Taking a "quick look" at the original image "to confirm what's on it". Always work on a copy.
- ❌ Letting the IO handle the original item to the analyst without signing. The IO must counter-sign every transfer.
- ❌ Storing the evidence in a generic office drawer overnight. Use the CCL locker.
- ❌ Re-using the same tamper-evident bag for a different item.
- ❌ Writing the hash on the bag *after* the bag is sealed — the hash must be calculated on the imaged file *before* the bag is sealed.

## 6.6 Section 63 (BSA 2023) certificate — template

A separate **certificate under Section 63 of the Bharatiya Sakshya Adhiniyam 2023** must accompany the chain of custody. It certifies that:

1. The computer/system was in lawful custody of the IO at the time of production.
2. The information was produced from the computer in the course of its normal operation.
3. The information was stored in the computer in the ordinary course of activities.

```
SECTION 63 CERTIFICATE (BSA 2023)

I, Insp. R. K. Singh, Badge 4421, Andheri Cyber Cell, Mumbai,
do hereby certify that:

1. The electronic record produced as Exhibit P-14 was produced
   from a computer resource that was in my lawful custody at
   the time of production, having been lawfully seized on
   18-Apr-2026 from 301, Kuber Complex, Andheri W, Mumbai 58,
   under warrant W/2026/AC-145 (Sec 165 CrPC / Sec 94 BNSS).

2. The said electronic record was produced from the said computer
   resource in the course of its normal operation, in accordance
   with the standard forensic procedure laid down in the SOP of
   the Cyber Crime Cell, Mumbai Police, and under the supervision
   of FSL Officer A (Badge 5188).

3. The said electronic record was stored in the said computer
   resource in the ordinary course of activities of the said
   computer, and the chain of custody (CCTNS-EXHIBIT-COC) appended
   hereto is true and complete to the best of my knowledge and
   belief.

Date : _____  Place : _____

___________________________
Insp. R. K. Singh 4421
IO, Andheri Cyber Cell

Counter-signed :
___________________________
DSP (Cyber), Mumbai
```

The full printable form is in `printables/Chain_of_Custody_Form.md`.
