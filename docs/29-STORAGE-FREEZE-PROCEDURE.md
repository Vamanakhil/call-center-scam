# 29 — Storage Freeze Procedure (Cloud, UPI, Email, Phones)

> A major challenge in cyber crime is that critical evidence lives **outside** the seized systems — in cloud storage, in UPI rails, in email providers, on Telegram's servers, in a phone that is locked. This document covers the **paperwork and procedure** to **freeze / preserve / extract** that evidence before it disappears.

## 29.1 Cloud storage freeze

### 29.1.1 Google (Gmail, Drive, Photos)
- **Legal basis:** Section 91 CrPC / 94 BNSS production notice + Section 69 IT Act interception.
- **Address:** Google India, Block G, Bagmane Tech Park, C V Raman Nagar, Bangalore 560093.
- **Authorised officer:** Mr. S. Krishnan (or current Legal Compliance Manager).
- **Email for cyber cell:** `legal-india@google.com` (current as of 2026).
- **Preservation request turnaround:** 3-7 days.
- **Production request turnaround:** 30-60 days.

**Preservation request sample letter** in `printables/Section91_Cloud_Preservation_Letter.md`.

### 29.1.2 Microsoft (Outlook, OneDrive, Azure)
- **Address:** Microsoft India, DLF Cybercity, Gurgaon 122002.
- **Email:** `msindialegal@microsoft.com`.

### 29.1.3 Meta (WhatsApp, Instagram, Facebook)
- **Address:** Meta India, 1st Floor, East Wing, Kalpataru Synergy, Mumbai 400 070.
- **Email:** `legal@meta.com` (India).
- **Note:** WhatsApp content is **end-to-end encrypted**. Meta can only produce **metadata** (who, when, how long) for WhatsApp — not message content. They can produce full content for Instagram and Facebook.

### 29.1.4 Telegram
- **Address:** Telegram Messenger LLP, c/o CDA Global, Dubai.
- **Email:** `abuse@telegram.org`.
- **Note:** Telegram rarely responds to Indian legal requests unless routed via MLAT. They will preserve if a formal MLAT request is sent via the Ministry of Law.
- **Trick:** if you have the **phone number** of the suspect, you can request SMS-based 2FA reset via Telegram's Account Recovery — but this must be done **before** the suspect's arrest is public.

## 29.2 UPI / Bank freeze

### 29.2.1 NPCI
- **Address:** National Payments Corporation of India, 1001A, B Wing, 10th Floor, The Capital, Bandra Kurla Complex, Mumbai 400 051.
- **Email:** `complaints@npci.org.in`.
- **For UPI transaction logs:** include sender VPA, receiver VPA, UPI transaction reference number (12 digits), date/time, amount.

### 29.2.2 Bank nodal officer
Each bank has a nodal officer for fraud cases. The list is on RBI's website: `rbi.org.in/scripts/bs_viewcontent.aspx?Id=2011`.

**Section 91 to HDFC (sample):**
```
To,
Nodal Officer,
HDFC Bank Ltd.,
Mumbai Region

Subject: Production of account statements u/s 91 CrPC / 94 BNSS
          in connection with FIR 0147/2026, Andheri Cyber Cell

Sir/Madam,

You are hereby directed to produce within 7 days:
1. Statement of account XXXXXXXXXXXX4242 in the name of Arjun Mehta
   for the period 01-Jan-2024 to 18-Apr-2026.
2. KYC documents at account opening.
3. All debit/credit vouchers above Rs 50,000.
4. UPI transaction logs (sender VPA, receiver VPA, amount, time).
5. Mobile number and email registered with the account.
6. Internet banking login IP logs.
7. CCTV footage of branch visits, if any, for the period.

Non-compliance is punishable u/s 174 IPC.
```

**Concurrent request to NPCI** to freeze future credits to the mule account.

## 29.3 Phone preservation

### 29.3.1 Faraday bag
- Bag the phone within the first 30 minutes of seizure.
- **Airplane mode first, then bag** — never swipe to power off (may trigger wipe).
- Charge the phone inside the bag via a power bank (NOT wall power).
- Image via Cellebrite UFED within 4 hours (phone batteries die).

### 29.3.2 Cellebrite UFED
- Logical extraction: 30-90 min.
- Physical extraction: 4-12 hours.
- Generates a UFED report (XML + PDF). Hash the report.
- For locked phones: Cellebrite has a "Premium" service for some models; otherwise chip-off (destructive).

### 29.3.3 Apple iCloud
- If you have the suspect's Apple ID and password, use `iCloud.com` to access iCloud backups, Find My, etc.
- Otherwise, send a Section 91 to Apple India (c/o Apple India Pvt Ltd, Bangalore).

## 29.4 Email preservation

Same as cloud storage — Section 91 to the provider.
For Gmail: include the account email; Google can pull a MBOX.
For Outlook: include the account email; Microsoft can pull a PST.

## 29.5 Common timing mistakes

- ❌ Waiting until the IO is "ready" to send the Section 91 — by then, the money is gone.
- ❌ Sending the Section 91 to the local branch (they can't help). Send to the **nodal officer** (HQ).
- ❌ Forgetting to send a concurrent **freeze** request to NPCI / bank — production is too late.
- ❌ Forgetting the **chain-of-custody** for the digital evidence you receive back (the MBOX from Google is also evidence; hash it, log it, seal it).

## 29.6 Section 91 CrPC / 94 BNSS templates

The following ready-to-customise templates are in `printables/`:
- `Section91_Cloud_Preservation_Letter.md` — Google / Microsoft / Meta / Telegram
- `Section91_Bank_Production.md` — HDFC / ICICI / Axis (with IFSC and address fields)
- `Section91_Telecom_Production.md` — Airtel / Jio / Vi (for CDR + tower location)
