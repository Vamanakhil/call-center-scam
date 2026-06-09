# 23 — Tool: VirusTotal

## When to use it
- **Triage** a suspect file (`.exe`, `.dll`, `.docm`, `.xlsxm`, `.js`, `.vbs`, `.ps1`, `.jar`).
- Check against 70+ antivirus engines.
- See behavioural sandbox detonation (the **Behavior** tab).
- Check community comments for known malware families.

## ⚠️ Critical — privacy leak warning
**Anything you upload to VirusTotal is shared with the AV community and is public.** This is a **major issue** for an active investigation because:
1. The file hash becomes a known IOC — the suspect's malware author will know they were detected.
2. The file content may tip off co-conspirators if it contains case-specific data.
3. Your **own** IP is logged.

## Mitigations
1. **For confidential files:** use **VirusTotal Enterprise** (paid) — your uploads are private.
2. **For free use:** **never** upload:
   - Documents containing case PII
   - Files that are obviously case-specific (e.g., named `victims_master.xlsx`)
   - Files that contain the **indictment**, **warrant**, or **suspect's name** in the metadata
3. **Best practice:** submit only the **hash** (SHA256) of the file, not the file itself. VT returns the result if it's been seen before; if not, you can re-evaluate whether to upload.

## Step-by-step — Hash-only submission

1. Compute SHA256:
   ```powershell
   Get-FileHash -Algorithm SHA256 -Path C:\ProgramData\Updater\updater.exe
   ```
2. Open `https://www.virustotal.com/gui/file/<SHA256>` in your browser.
3. If the file is known, the detection tab shows the AV verdicts.
4. If the file is unknown, you can choose to upload it (now that you have its hash, it's not "private" — you've committed to a submission decision).

## Step-by-step — File upload (only in a sandbox)

1. **Critical:** never upload from a non-sandbox machine.
2. **Use a fresh Windows 10/11 VM** with no network access to your case infrastructure.
3. Copy the suspect file via a USB that is then destroyed.
4. Submit the file via `https://www.virustotal.com/gui/home/upload` in the sandbox VM.
5. The Behaviour tab shows: file operations, registry changes, network connections, process injections.

## Step-by-step — Sandbox detonation

For unknown binaries:
1. Open `https://www.virustotal.com/gui/file/<hash>/behavior` after upload.
2. VT runs the file in a sandbox for 5-10 minutes and records:
   - **File actions** (created/modified/deleted files)
   - **Registry actions** (Run keys, services installed)
   - **Network actions** (DNS, HTTP, TCP connections)
   - **Process tree** (parent/child, command lines)
   - **Memory dumps** (URLs, mutexes)
3. Use this to triage — not as final forensic proof.

## For this lab (the AGENT-05 stub)
- The stub `updater.exe` is **benign** — only writes `passwords.txt` to a detected USB.
- On VT, it will show **~3-8 detections** as "Trojan:Win32/Wacatac" or similar.
- The Behaviour tab will show the USB detection (DRIVE_REMOVABLE arrival) and the file write.
- Instructor's note: this is **fake malware for training**. Real malware triage is far more complex.

## Common mistakes
- ❌ Uploading a case-specific file from a non-sandbox machine (privacy leak).
- ❌ Uploading from your official police IP — your department's IP becomes logged on VT.
- ❌ Treating VT verdicts as **proof of malware** — they are indicators, not legal proof. The file must be analysed by a qualified FSL.
- ❌ Failing to capture the VT report as a PDF — it is a critical piece of the malware triage report.

## Court admissibility
- VT reports are **admissible as expert opinion** when produced by a qualified FSL analyst.
- The report should include: the SHA256 of the file, the upload date/time, the analyst's name, the sandbox environment details.
- Always cross-reference VT with your own dynamic analysis in an isolated VM.
