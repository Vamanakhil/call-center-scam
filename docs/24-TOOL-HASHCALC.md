# 24 — Tool: HashCalc

## When to use it
- Single-file hash calculation with multiple algorithms at once.
- Tiny standalone EXE (~100 KB). Can run from a USB.
- Useful when the trainee doesn't have admin rights to run PowerShell.

## Pre-flight
- Copy `HashCalc.exe` (NirSoft, free) to a USB or to the examiner workstation.
- No installation.

## Step-by-step

1. Double-click `HashCalc.exe`.
2. **File → Open** → select the file.
3. Tick **MD5, SHA1, SHA256, SHA512**.
4. Click **Calculate**.
5. Right-click each value → **Copy**.
6. Paste into the hash verification sheet.

## Alternatives
- **PowerShell:** `Get-FileHash -Algorithm SHA256 <path>`
- **certutil:** `certutil -hashfile <path> SHA256`
- **md5sum / sha256sum** (Linux/macOS)
- **7-Zip** (right-click → CRC SHA → SHA-256)

## Bulk hashing

PowerShell is faster for many files:

```powershell
Get-ChildItem E:\EVIDENCE -Recurse -File |
  Get-FileHash -Algorithm SHA256 |
  Export-Csv E:\EVIDENCE\HASHES.csv -NoTypeInformation
```

## Court admissibility
- HashCalc is widely used. Reports are admissible.
- The output of a hash is **not evidence** on its own — it is a **fingerprint** that proves the evidence file has not changed.
- The hash must be written on the bag label at the moment of acquisition, signed by IO and witness.
