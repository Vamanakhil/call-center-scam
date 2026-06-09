# 27 — Tool: Browser History Examiner (Foxton)

## When to use it
- Parse Chrome / Edge / Firefox / Safari / Opera `History` SQLite.
- Recovers **deleted URLs** from the WAL file.
- Exports to CSV, HTML, XLSX.
- Free for personal use; commercial for law enforcement.

## Pre-flight
- `BrowserHistoryExaminer.exe` from `foxtonforensics.com`.
- Run on a Windows machine with the .E01 mounted read-only (or on a copy of the `History` file).

## Step-by-step

1. Launch BHE.
2. **Add History Files** → select the `History` files from one or more user profiles.
3. The tool lists all URLs: URL, Title, Visit Count, Last Visit Time, Typed Count, Hidden.
4. **Filter** by URL substring, date range, or user.
5. **Export → CSV / HTML / XLSX**.
6. Hash the export.

## Recovering deleted URLs
- Chrome uses a WAL (`-wal`) file in the same folder.
- BHE reads the WAL automatically. If the user deleted their history, the URLs may still be in the WAL.
- The `.log` and `-shm` files also help.

## Common mistakes
- ❌ Forgetting to **close Chrome** on the live system before copying the `History` file (Chrome locks the file with an exclusive lock).
- ❌ Using BHE on a non-copied `History` file — read-only mount, never analyse the original.
- ❌ Missing the `Default\History` AND `Profile 1\History`, `Profile 2\History` etc. — Chrome supports multiple profiles.

## Court admissibility
- BHE is widely used. Reports accepted.
- Always include the **exported CSV** + the **BHE version** + the **hash** in the case file.
- For court, also include the raw `History` SQLite file (hashed) so the opposing expert can verify.
