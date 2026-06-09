# 18 — Tool: Magnet RAM Capture

## When to use it
- Alternative to Belkasoft. Same use-case.
- Magnet is a **commercial** tool (Magnet Forensics) but a free version exists.
- Output: `.raw` (raw memory dump) instead of `.mem`.
- Slightly different memory acquisition driver; sometimes captures more or less of the same RAM.

## Comparison with Belkasoft

| Feature | Belkasoft | Magnet |
|---|---|---|
| Format | `.mem` | `.raw` |
| Speed | Faster | Slower on some systems |
| Pagefile capture | No | Yes (optional) |
| Free | Yes | Yes (with attribution) |
| Driver type | User-mode | Kernel-mode |
| Hash output | SHA1 | MD5 + SHA1 |

## Step-by-step

1. Run `MagnetRAMCapture.exe` as Administrator.
2. **Destination:** `E:\EVIDENCE\AGENT-01.raw`.
3. **Include pagefile:** tick (Magnet can include the Windows pagefile for fuller memory reconstruction).
4. Click **Start**.
5. Wait for completion (10-20 min for 8 GB).
6. Magnet displays MD5 and SHA1 of the .raw.
7. Verify with PowerShell `Get-FileHash`.

## When to prefer Magnet over Belkasoft
- When you suspect **pagefile-backed** content (e.g., the suspect was running a process that swapped heavily).
- When you need the **MD5** hash for cross-tool verification (Magnet gives both).

## When to prefer Belkasoft
- Time-critical scenarios (Belkasoft is faster).
- Smaller USB sticks.
