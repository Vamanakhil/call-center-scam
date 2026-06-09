# 10 — Inject Events (20)

> Read each inject to the trainee team at the marked time. The inject forces a decision. The instructor observes and grades the decision.

Format: **Time**, **Trigger**, **Expected response**, **What they should find**, **Common mistake**.

---

## 1. Suspect shutdown attempt
- **Time:** 11:36 IST (4 min after entry)
- **Trigger:** Manager Arjun lunges for the AGENT-05 power button, shouting "Koi nahi chhuega".
- **Expected:** SI grabs the manager's wrist, seats him away. Constable at every workstation. Forensic expert **photographs every screen** before any power action.
- **Find:** Arjun's VeraCrypt volume was still mounted as `E:` — must NOT be closed.
- **Mistake:** Yanking the power cable (loses RAM, corrupts VeraCrypt mount).

## 2. AnyDesk session active
- **Time:** 11:42 IST
- **Trigger:** AGENT-01's system tray shows AnyDesk "Connected to 103.41.218.91".
- **Expected:** Photograph the AnyDesk window with the ID. **Do not disconnect** — capture the session token first. Then disconnect via system tray (graceful). Screenshot the disconnection prompt.
- **Find:** AnyDesk ID `823 411 902` remote from Singapore. Also visible in CRM-SERVER `qwinsta` as session 5.
- **Mistake:** Right-click → Disconnect without preserving the ID. The ID is needed for the MLAT request to AnyDesk.

## 3. Malware alert
- **Time:** 11:55 IST
- **Trigger:** Defender on AGENT-05: "Threat detected: Trojan:Win32/Wacatac.B!ml in C:\ProgramData\Updater\updater.exe".
- **Expected:** **Do not run it.** Photograph the alert. Hash the file *before* Defender quarantines (hash changes). Move via FTK logical image. Submit to VirusTotal in a **sandbox VM**.
- **Find:** The file is `updater.exe` from `stub.ps1` in Vikas's Documents. Benign — only creates a `passwords.txt` on USB. The stub's TODO comment reveals future intent.
- **Mistake:** Letting Defender quarantine. Hash changes, chain of custody broken.

## 4. Hidden USB found
- **Time:** 12:08 IST
- **Trigger:** Constable finds a hollowed-out "Hacking Exposed 7th Ed." in Vikas's shelf, 64 GB SanDisk inside.
- **Expected:** Photograph the book in situ. Photograph the pen drive in the cavity. Bag. Image via FTK Imager + write-blocker.
- **Find:** Deleted `victims_old.xlsx` (recoverable), empty partition table, .lnk to CRM admin.
- **Mistake:** Pulling the USB before photographing, plugging into a non-forensic machine.

## 5. Deleted database recovered
- **Time:** 12:14 IST
- **Trigger:** "Sir, manager says the CRM database was deleted."
- **Expected:** Check manager's Recycle Bin. Check `\\CRM-SERVER\old\`. Run `mysqldump` against the live server FIRST (DB is still running). Recover from disk image later.
- **Find:** DB intact, backup on `old` share, Recycle Bin has `complaints_to_ignore.xlsx`.
- **Mistake:** Believing the manager.

## 6. Cloud storage
- **Time:** 12:18 IST
- **Trigger:** Constable spots a Google Drive tab in AGENT-01's Chrome with URL `drive.google.com/drive/u/0/folders/1AB...`.
- **Expected:** Screenshot URL, file list, account email. Preserve in RAM. Draft Section 91 to Google within 24h.
- **Find:** `Golden_Returns_Marketing_Collateral` shared folder, 47 files including "Investor_Presentation_2026.pdf".
- **Mistake:** Closing the browser tab. Loses the URL in RAM.

## 7. Locked phone
- **Time:** 12:22 IST
- **Trigger:** Manager's iPhone 14 Pro is locked, 6-digit PIN, suspect refuses to give it.
- **Expected:** Image via Cellebrite UFED or chip-off. Note 30-attempt lockout warning. **Do not exceed 5 attempts.** Bag in Faraday pouch. Do not charge past 80%.
- **Find:** (off-lab) — instructor demo only on a separate training device.
- **Mistake:** Trying common PINs (123456, 000000). Burns attempts.

## 8. Router password unknown
- **Time:** 12:26 IST
- **Trigger:** Router web UI at 192.168.10.1 asks for password, default `admin`/`admin` doesn't work.
- **Expected:** Use the **console cable** (RJ45-to-USB) → terminal 9600 8N1 → `enable` → `copy running-config tftp://<laptop>`. Bag the router whole.
- **Find:** The running config reveals the port-forward rules + the static DHCP reservation for AGENT-05.
- **Mistake:** Trying to brute-force the web UI — locks the account.

## 9. Printer jam
- **Time:** 12:30 IST
- **Trigger:** "Sir, the printer has a paper jam, paper tray has a half-printed Mule_Accounts_Q4.pdf."
- **Expected:** Photograph the LCD showing the last job. **Pull the printer's internal flash** (most office printers have an SD card or DOM). Image it. The paper is evidence — photograph in situ then collect.
- **Find:** Internal flash contains the last 32 print jobs. Half-printed `Mule_Accounts_Q4.pdf` shows the 6 mule account numbers in plaintext.
- **Mistake:** Clearing the jam to "make the printer work" — destroys the in-tray document.

## 10. Manager denies
- **Time:** 12:36 IST
- **Trigger:** Manager says "I only use this PC for email."
- **Expected:** Cross-reference his browser history (Telegram web) vs. USB history (4 pen drives) vs. CRM access logs (admin user). Confront with the contradiction.
- **Find:** 23 visits to t.me in last 24h, 4 USBSTOR entries, 187 CRM admin logins.
- **Mistake:** Accepting the denial.

## 11. System just rebooted
- **Time:** 12:40 IST
- **Trigger:** AGENT-04's screen is on the lock screen; suspect says "I just rebooted it."
- **Expected:** `wevtutil qe System` → look for event **1074** (clean shutdown) or **6008** (unexpected). Check USN journal for the last `$J` time.
- **Find:** Event 1074 at 12:38 — initiated by user `sneha.i`. So the user shut it down, not the OS. Plus the USB history shows Sneha plugged in a pen drive 30 seconds before — likely USB-borne.
- **Mistake:** Believing the user. Check the event log every time.

## 12. passwords.txt created
- **Time:** 12:44 IST
- **Trigger:** A constable says "Sir, this USB has a `passwords.txt` that wasn't here a minute ago."
- **Expected:** That's the **AGENT-05 malware stub** triggering. Image the USB immediately, do not pull the file. Then go back to AGENT-05 and image it (the stub source is in Vikas's Documents).
- **Find:** `passwords.txt` contains fake "saved passwords" — it's a planted file to suggest the victim's machine was compromised. Stub source in `C:\Users\vikas.n\Documents\stub.ps1`.
- **Mistake:** Opening `passwords.txt` on a non-forensic machine.

## 13. Active RDP session
- **Time:** 12:48 IST
- **Trigger:** `qwinsta` on CRM-SERVER shows "rdp-tcp#5  arjun.m  192.168.10.50  Active".
- **Expected:** Disconnect gracefully via `rwinsta 5` (or right-click → Disconnect in Task Manager). Photograph the source. Preserve the source IP for the MLAT request.
- **Find:** This is the LOCAL session from the manager's own PC. The interesting one is `qwinsta` row 6: `rdp-tcp#6  Administrator  103.41.218.91  Active` — that's the AnyDesk relay.
- **Mistake:** Killing `rdp-tcp#5` — that's the manager's own session, useful evidence.

## 14. Low battery phone
- **Time:** 12:52 IST
- **Trigger:** The burner Android is at 8% battery.
- **Expected:** Plug into a **power bank inside the Faraday pouch** (do not use wall power — that defeats the pouch). Image via Cellebrite ASAP.
- **Find:** (off-lab demo) — instructor demonstrates Faraday + power bank.
- **Mistake:** Plugging into wall power — the pouch is no longer a Faraday pouch.

## 15. Personal pen drive
- **Time:** 12:56 IST
- **Trigger:** Sneha just plugged in a personal pen drive to her AGENT-04 front panel.
- **Expected:** **Image the USB BEFORE removing it.** Remove via write-blocker. Never let it touch a non-forensic machine.
- **Find:** The pen drive contains her own personal photos AND a copy of the daily collection report from yesterday that was not in her My Documents folder.
- **Mistake:** Letting Sneha "unplug it herself" — that's tampering.

## 16. CCTV DVR
- **Time:** 13:00 IST
- **Trigger:** A constable finds a small CCTV DVR in the corner under a cloth.
- **Expected:** Photograph. Pull the HDD (DVRs usually have a 2.5" SATA HDD). Image. Check the recycle bin on the embedded Linux.
- **Find:** DVR holds 14 days of footage. The recycle bin has 3 deleted .mp4 files from 16-Apr-2026 — the day before the raid. Recovered.
- **Mistake:** Dismantling the DVR without imaging the HDD first.

## 17. VeraCrypt container
- **Time:** 13:04 IST
- **Trigger:** The forensic expert notices MANAGER-PC has an `E:` drive that "isn't a normal partition."
- **Expected:** **Do not close the container.** Image the live volume header. Mount the parent image in FTK and read the volume header. Use the same password if known, else use the header to brute-force.
- **Find:** Container opens with `Gr@Vault2026!` (on a sticky note under the keyboard). Inside: `mule_rota_history.xlsx`, `victims_to_burn.xlsx`, `private_keys.txt`, `confession_2026-04-17.mp3`.
- **Mistake:** Dismounting the volume by mistake (typing `dismount` in VeraCrypt or restarting the PC). The header still allows mount of the E01.

## 18. WhatsApp Web
- **Time:** 13:08 IST
- **Trigger:** AGENT-01's Chrome has 12 WhatsApp Web tabs open with victim names.
- **Expected:** Export the chat via WhatsApp Web → Settings → Export Chat → Include media. Save to evidence USB. Screenshot each tab.
- **Find:** 12 chats with victims VICTIM-001 through VICTIM-012. All show payment confirmations and "compliance" replies.
- **Mistake:** Closing the tabs. Loses the chat data in browser memory.

## 19. Incognito browser
- **Time:** 13:12 IST
- **Trigger:** Rahul says "I was just browsing in incognito, nothing to see."
- **Expected:** RAM still contains the URLs in `chrome.exe` process memory. `strings -e l AGENT-01.mem | grep -E "https?://" | sort -u` recovers them. Also check the `chrome.exe` process's mapped file handles.
- **Find:** 47 incognito URLs, all to `t.me` and `goldenreturns.example/admin`.
- **Mistake:** Believing the suspect. Incognito ≠ invisible.

## 20. Hidden laptop
- **Time:** 13:16 IST
- **Trigger:** A constable says "Sir, I think there's something in the ceiling tile."
- **Expected:** Photograph the ceiling tile. Photograph the laptop being lowered. Treat as a **new seizure site** — start the SOP over for this device.
- **Find:** A Lenovo ThinkPad X1 Carbon, password-protected, with a sticker "Property of Vikas N. — DO NOT REMOVE FROM OFFICE".
- **Mistake:** Opening the laptop to "see what's on it" without going through the seizure checklist again.

---
