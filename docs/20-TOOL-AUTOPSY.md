# 20 — Tool: Autopsy 4.21 (Basis Technology)

## When to use it
- **Bulk analysis** of one or more disk images.
- Ingest modules: Recent Activity, Hash Lookup, Keyword Search, EXIF, Registry, Email, File Carving, etc.
- Produces a **report** in HTML, Excel, or KML.
- Free, open source, runs on Windows.

## Pre-flight
- Autopsy 4.21+ installed.
- Disk image (.E01) accessible (copy from the network share).
- Working folder with at least 5× the image size free.

## Step-by-step

1. Launch Autopsy. **New Case.**
2. **Case Name:** `0147-2026-GoldenReturns`.
3. **Base Directory:** `D:\CASES\0147-2026\`.
4. **Case Type:** Single-user.
5. **Optional:** add case number, examiner.
6. **Add Data Source → Disk Image** → select the .E01.
7. **Ingest Modules** — tick at minimum:
   - **Recent Activity** (browser history, recent files, USB)
   - **Hash Lookup** (NSRL, custom hash set)
   - **Keyword Search** (search for "UPI", "goldenreturns", "+91 9")
   - **EXIF Parser**
   - **File Carving** (deleted file recovery)
   - **Email Parser** (PST/OST)
   - **Registry** (parser)
   - **Encryption Detection** (find VeraCrypt containers)
8. Click **Next → Finish**. Ingest begins (15 min to several hours per image).
9. **Tree-view** on the left, **results table** on the right.
10. **Generate Report** → HTML → save to the case folder.

## Key analysis workflows

### Browser history
- Data Sources → Image → `/Users/<user>/AppData/Local/Google/Chrome/User Data/Default/History` → right-click → **Open in Extracted Viewer**.

### Deleted file recovery
- Data Sources → Image → **Unallocated Space** → right-click → **Carve files** → filter by extension.

### Registry
- Data Sources → Image → `C:\Windows\System32\config\` → open SYSTEM, SOFTWARE, SAM, NTUSER.DAT.

### EXIF on UPI screenshots
- Data Sources → Image → `C:\Users\sneha.i\Desktop\UPI_Screenshots\` → column **Make** shows phone model, **Date/Time Original** shows when the screenshot was taken.

## Common mistakes
- ❌ Running ingest on the **original .E01** without copying to a working folder. Always copy.
- ❌ Skipping the **Hash Lookup** module — you miss the chance to flag known-bad files automatically.
- ❌ Forgetting to enable **File Carving** — you miss deleted files.
- ❌ Closing Autopsy during ingest — the case database is not transactional; you may have to redo.

## Court admissibility
- Autopsy is a recognised, open-source tool. Its reports are **BSA Sec 63** compliant when accompanied by the .E01 image and the hash sheet.
- Always include the **Autopsy log file** (in the case folder) when producing a report.
