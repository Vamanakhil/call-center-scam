# 07 — Hash Verification

## 7.1 Why hashing?

Every piece of electronic evidence must be **hashed at the moment of acquisition** and again at **every transfer**. A hash is a one-way fingerprint:

- **MD5** (128-bit) — fast, widely supported, technically broken for collisions but still acceptable in Indian courts for cross-tool verification.
- **SHA1** (160-bit) — same caveats as MD5.
- **SHA256** (256-bit) — the **court-preferred** algorithm in India (BSA 2023 does not specify an algorithm; SHA-256 is the de-facto standard).
- **SHA512** — used in some CCL workflows for extra security.

We use **dual-hashing (MD5 + SHA256)** in this lab. MD5 ensures any third-party tool can verify, SHA256 ensures court-grade integrity.

## 7.2 When to hash

| When | Who | What is hashed |
|---|---|---|
| At seizure | IO + forensic expert | The volatile output files, the RAM dump, the disk image |
| At every transfer | Sender + receiver | The same files (must match) |
| Before analysis | Analyst | The working copy (must match the original) |
| After analysis | Analyst | The produced reports (chain the report to the source) |
| At court production | IO | The exhibit file as lodged |

## 7.3 Tools

### 7.3.1 Windows — PowerShell (built-in, no install)

```powershell
# MD5
Get-FileHash -Algorithm MD5 -Path E:\EVIDENCE\AGENT-01.mem
# SHA1
Get-FileHash -Algorithm SHA1 -Path E:\EVIDENCE\AGENT-01.mem
# SHA256
Get-FileHash -Algorithm SHA256 -Path E:\EVIDENCE\AGENT-01.mem
# SHA512
Get-FileHash -Algorithm SHA512 -Path E:\EVIDENCE\AGENT-01.mem

# Bulk: hash every file in a folder
Get-ChildItem E:\EVIDENCE -Recurse -File |
  Get-FileHash -Algorithm SHA256 |
  Export-Csv E:\EVIDENCE\HASHES_$((Get-Date).ToString('yyyyMMdd_HHmmss')).csv -NoTypeInformation
```

### 7.3.2 HashCalc (standalone, NirSoft)

```
HashCalc v2.02
1. File → Open → select file
2. Check MD5, SHA1, SHA256
3. Click Calculate
4. Copy each hash to the verification sheet
```

### 7.3.3 certutil (built-in Windows)

```cmd
certutil -hashfile E:\EVIDENCE\AGENT-01.mem MD5
certutil -hashfile E:\EVIDENCE\AGENT-01.mem SHA1
certutil -hashfile E:\EVIDENCE\AGENT-01.mem SHA256
```

### 7.3.4 md5sum / sha256sum (Linux/macOS)

```bash
md5sum E:/EVIDENCE/AGENT-01.mem
sha256sum E:/EVIDENCE/AGENT-01.mem
```

### 7.3.5 Within FTK Imager (during image creation)

FTK Imager calculates MD5 and SHA1 automatically and stores them in the image log. Always tick "Verify images after they are created".

## 7.4 Hash Verification Sheet (template)

```
ANDHERI CYBER CELL — HASH VERIFICATION SHEET
Case FIR No. : 0147/2026
Sheet no.    : ____ of ____
Page         : ____

Item Tag     : MSL-2026-____   Item : ________________________________
Created by   : ___________________________   Date : 18-Apr-2026
Verified by  : ___________________________   Date : ____________

FILE NAME                          SIZE      MD5                              SHA256
E:\EVIDENCE\AGENT-01.mem           8.2 GB    a1b2c3d4e5f6...                  9f8e7d6c5b4a...
E:\EVIDENCE\AGENT-01.E01           1.0 TB    f6e5d4c3b2a1...                  0c1d2e3f4a5b...
E:\EVIDENCE\AGENT-01.E02           4.0 GB    12ab34cd56ef...                  9876fedcba09...
E:\EVIDENCE\AGENT-01.E03           4.0 GB    ...
... (one row per E01 segment, or per evidence file)

VERIFICATION (each transfer)
Date      Transfer      MD5 Match   SHA256 Match   Verifier
18-Apr    Seizure→FSL   ✓            ✓              FSL Off. A
22-Apr    FSL→Court     ✓            ✓              Insp. Singh
          ...
```

A printable version of this sheet is in `printables/Hash_Verification_Sheet.md`.

## 7.5 Common mistakes

- ❌ Hashing only after the file is moved (you lose the chance to detect tampering at the original location).
- ❌ Trusting the FTK "Verify" output without copying the hash to the verification sheet manually.
- ❌ Hashing the wrong file (the .E01 is a *segment* of the image, not the whole image — must hash every segment, or use FTK's combined hash).
- ❌ Noting the hash on the bag in pencil (must be permanent ink or printed label).
- ❌ Using a different algorithm at verification than at creation (always use the same one).

## 7.6 Expected hashes (for instructor reference)

The PowerShell scripts in `scripts/` generate evidence files whose hashes are deterministic per role. After running the master setup, hashes for the key files are:

| File (on the seized system) | SHA256 (truncated) |
|---|---|
| `C:\Users\rahul.s\Desktop\closer_script.docx` | `7a1b…c2d3` |
| `C:\Users\arjun.m\Documents\victims_master.xlsx` | `2e9f…a8b1` |
| `C:\xampp\mysql\data\golden_crm\users.MYD` | `b4c6…d7e8` |
| `E:\EVIDENCE\AGENT-01.mem` | `a1b2…c3d4` (per-run) |
| `D:\Manager\vault.veracrypt` | `5f0a…b1c2` |

The full hash log is regenerated every time the master script runs and saved to `H:\EVIDENCE\HASHES_<timestamp>.csv`.
