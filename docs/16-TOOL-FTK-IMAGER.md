# 16 — Tool: FTK Imager 4.7 (Exterro)

## When to use it
- **First tool** out of the bag for any disk or removable media.
- Creating forensic images in **E01 / DD / AFF** format.
- Verifying images via hash.
- Mounting evidence read-only for preview (do not analyse on the original).
- Logical-image export of specific folders.
- Capturing RAM (alternative to Belkasoft; FTK Imager 4.7+ has RAM capture built in).

## Pre-flight checklist
- [ ] Write-blocker connected and self-tested.
- [ ] Source drive on the write-blocker, target drive on a separate physical disk.
- [ ] Target drive formatted NTFS or exFAT, has enough free space (1.5× source size for E01, 2× for DD).
- [ ] FTK Imager installed on examiner workstation (never on the source).
- [ ] Blank case notebook, hash verification sheet, imaging log ready.

## Step-by-step — Create Disk Image (E01)

1. Launch **FTK Imager 4.7.1.2** as Administrator.
2. **File → Create Disk Image.**
3. **Source → Physical Drive** (or Logical Drive for a specific volume). Click **Next**.
4. Select the source drive from the dropdown (e.g., `\\.\PHYSICALDRIVE0`). Click **Finish**.
5. **Add Image Destination.**
6. **Image Destination(s):** click **Browse**, pick `E:\EVIDENCE\AGENT-01.E01`.
7. **Image Type:** E01.
8. **Segment Size:** 4096 MB (4 GB). Click **OK**.
9. **Compression:** 6 (Best). Tick **Enable compression**.
10. **Encryption (optional):** AES-256 — store the key in the evidence safe, do NOT log it in the case diary.
11. **Case Information** (auto-fills, fill in Examiner name, Evidence Number, Description).
12. Tick **Create a directory listing of the source drive.** (Produces an index file — extremely useful.)
13. **Tick "Verify images after they are created"** — CRITICAL.
14. Click **Start**. A progress bar appears.
15. **Do not interrupt.** For a 1 TB HDD on USB 3.0, expect 2-3 hours.
16. When complete, the log file is saved next to the .E01 as `AGENT-01.E01.txt`. **Print it, sign it.**
17. The Verify step runs automatically. The log will say "Verify result: MATCH" if hashes match.
18. Hash the log file (`AGENT-01.E01.txt`) with `Get-FileHash`. Record on the verification sheet.

## Step-by-step — Mount Evidence (for preview)

1. **File → Image Mounting.**
2. Click **Add Image**, select the .E01.
3. **Mount as:** read-only. Pick a free drive letter.
4. The image appears in Windows Explorer as a new drive.
5. You may **browse but not modify.** FTK enforces read-only.
6. To preview file contents without modifying, use FTK's **Export** to a working folder.

## Step-by-step — RAM capture (FTK Imager alternative)

1. Run FTK Imager on the **live system** you want to capture.
2. **File → Capture Memory.**
3. **Destination path:** `E:\EVIDENCE\AGENT-01.mem`.
4. Click **Capture Memory**. Wait 5-15 min.
5. Hash immediately. Record.

(We use Belkasoft for the lab because it's faster, but FTK Imager RAM is the fallback.)

## Expected output
- `AGENT-01.E01`, `AGENT-01.E02`, `AGENT-01.E03`... (4 GB segments)
- `AGENT-01.E01.txt` (log)
- `AGENT-01.E01.ufd` (directory listing)

## Common mistakes
- ❌ Skipping the Verify step. Always verify.
- ❌ Hashing only the first .E01 segment — the **whole image** is the concatenation of all segments. FTK's "Verify" checks the whole image, but you must manually hash the **log** to chain the log to the image.
- ❌ Imaging to the **same physical drive** as the source. Always to a separate drive.
- ❌ Using USB 2.0 write-blocker for a 1 TB drive (12+ hours).
- ❌ Letting the source drive spin down mid-imaging (laptop sleep settings). Disable sleep in Power Options.
- ❌ Writing the .E01 to a FAT32 USB (max file 4 GB — use NTFS or exFAT).

## Court admissibility notes (India)
- The .E01 + .txt log is **BS