# 21 — Tool: OSForensics (PassMark)

## When to use it
- All-in-one forensic suite.
- **Quick Image**, RAM view, Registry viewer, Password recovery, Recent Activity timeline, File search by hash/name/EXIF, Mismatch file detection, Signature analysis.
- Single-binary installer, no external database required.

## Pre-flight
- OSForensics 11.x installed and licensed (free trial available).
- Case folder with case number `0147-2026`.

## Step-by-step — Quick Image

1. **Tools → Quick Image** (similar to FTK Imager).
2. Source: physical drive.
3. Destination: `D:\CASES\0147-2026\AGENT-01.img`.
4. Format: DD or E01 (via dd).
5. Hash on completion: MD5, SHA1, SHA256.

## Step-by-step — Registry Viewer

1. **Tools → Registry Viewer.**
2. **File → Load Hive** → browse the mounted E01 → `C:\Windows\System32\config\SYSTEM` (or SOFTWARE, SAM, NTUSER.DAT).
3. The viewer shows the registry tree.
4. **Search** for `Updater`, `Run`, `USBSTOR`, `RecentDocs`.
5. **Export** selected key to `.reg` for the case file.

## Step-by-step — Recent Activity

1. **Investigate → Recent Activity** (or **Tools → Recent Activity**).
2. Autodetects: web history (Chrome, Edge, Firefox), recent files (LNK), USB devices, prefetch.
3. The timeline view shows the chronological order.
4. **Export to CSV** for the report.

## Step-by-step — Password Recovery

1. **Tools → Passwords → Recover Passwords** (or **Investigate → Windows Credentials**).
2. Loads `C:\Windows\System32\config\SAM` and `SYSTEM`.
3. Recovers NTLM hashes and (sometimes) plaintexts of local accounts.
4. Export to a CSV; hash the CSV.

## Step-by-step — File Search

1. **Investigate → File Search.**
2. Filter: name, extension, size, date, **hash** (NSRL lookup).
3. Tag matched files as "evidence" — they get added to the case.

## Common mistakes
- ❌ Forgetting to **mount the E01 first** (OSForensics works on a mounted read-only drive letter, not directly on the .E01).
- ❌ Using **Default Case** instead of creating a case folder. The case folder is what you zip up and send to the prosecutor.
- ❌ Editing the case on the original .E01 working copy. Always on a separate working folder.

## Court admissibility
- OSForensics is widely used in Indian cyber cells. Reports are accepted.
- Always include the **OSForensics case file** (`.ofc`) and the **activity log** (under the case folder).
