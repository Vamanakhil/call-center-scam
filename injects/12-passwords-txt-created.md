# Inject 12 — passwords.txt Created

**Time:** 12:44 IST
**Where:** The USB in AGENT-05's desk
**Card:** "Constable: 'Sir, this USB has a `passwords.txt` that wasn't here a minute ago.'"

## Response
1. That's the **AGENT-05 malware stub** triggering.
2. **Image the USB immediately**, do not pull the file.
3. Then go back to AGENT-05 and image it (the stub source is in `C:\Users\vikas.n\Documents\stub.ps1`).
4. Hash both the new file and the stub source.

## Find
- `passwords.txt` contains fake "saved passwords" — planted to suggest the victim's machine was compromised.
- Stub source: `C:\Users\vikas.n\Documents\stub.ps1` and `C:\ProgramData\Updater\stub.ps1`.
- The stub contains `# TODO: exfil to telegram when stable` — intent to commit future crime.

## Mistake
❌ Opening `passwords.txt` on a non-forensic machine.

## Grading
- ✅ Image USB immediately, image AGENT-05
- 🟡 Image the USB only
- ❌ Open passwords.txt on a non-forensic machine
