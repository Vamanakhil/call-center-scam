# 15 — SOP for Cyber Crime First Responder

> India Police Cyber Cell — first **90 minutes** at a live cyber-crime scene. Aligned with **I4C** and **MHA Cyber Crime Forensic SOP**.

## Phase 0 — Pre-raid (T-60 to T-0)

1. Confirm **warrant in writing**. Sec 165 CrPC / 94 BNSS for search; Sec 91 CrPC / 94 BNSS for production. Sec 69 IT Act for interception.
2. Team briefing — assign: **IO, photographer, evidence officer, network officer, scribe, witness**.
3. Tool kit checklist (one per officer):
   - [ ] Laptop with FTK Imager 4.7, Autopsy 4.21, Belkasoft RAM Capturer, WinPmem, Registry Explorer (EZ), BrowserHistoryView, USBDeview, Wireshark
   - [ ] Bootable USB with WriteCopier / Helix
   - [ ] Write-blocker (Tableau T8 USB3 or WiebeTech)
   - [ ] Faraday bags ×6, large evidence bags ×20
   - [ ] Tamper-evident seals (numbered)
   - [ ] DSLR or phone with timestamp + spare battery
   - [ ] Bound notebook, numbered pages, pen
   - [ ] Blank forms (printed from `printables/`)
   - [ ] Gloves, anti-static bags, "do not touch" stickers
4. **Do not discuss the raid on any network the suspect could monitor** (no office phone, no WhatsApp, no SMS).

## Phase 1 — Approach and entry (T+0 to T+15)

1. Approach silently. Two officers at door, one with camera.
2. Knock + announce: "Police, warrant, open the door." 3×, 30 s apart.
3. No response → force entry, document the force with photos.
4. **First 10 seconds inside:** shout "Sab kuch chhod do, haath upar karo". Separate all suspects. No phones, no smartwatches, no toilets unaccompanied. Constable at every workstation, no one touches a keyboard.
5. Photograph the room **360°** from the entrance, then move inward.

## Phase 2 — Scene stabilisation (T+5 to T+15)

1. **Photograph every workstation powered-on**, screen visible. Front, back, sides.
2. Note: hostname, logged-in user, OS, IP, **screen time vs. your watch** (suspicious if they differ).
3. Photograph paper documents in situ.
4. Identify the **router and server** — highest-value items.
5. **Do not pull any cables or shut anything down yet.** Use the decision tree in Phase 3.

## Phase 3 — Live system triage decision tree

```
            System is ON, display visible
                       │
        ┌──────────────┴──────────────┐
        │                             │
  Suspect is resisting        Suspect is co-operative
        │                             │
  Photograph screen,           Walk to the system.
  WIN+L to lock, then          Begin Phase 4.
  proceed with RAM             (continue ↓)
        ↓
  ───────────────────────────────────────
        ↓
  Insert prepared USB with Belkasoft
  RAM Capturer on a write-blocker.
  Run RAM capture FIRST.
  Hash immediately.
        ↓
  Run tasklist, netstat, ipconfig /displaydns,
  wevtutil qe Security  → pipe to USB.
        ↓
  Photograph screen again.
        ↓
  Pull network cable — LABEL the port!
  Photograph cable and port before unplugging.
        ↓
  Forensic disk image with FTK Imager.
  Verify hash matches.
  Label and bag.
```

## Phase 4 — Volatile evidence capture order

1. **RAM** (Belkasoft or WinPmem)
2. **Network connections** (`netstat -ano`, `net session`)
3. **Running processes** (`tasklist /v`, `wmic process list full`)
4. **Logged-in users** (`qwinsta`, `query user`)
5. **Clipboard** (screenshot)
6. **Mapped drives** (`net use`)
7. **Scheduled tasks** (`schtasks /query /fo LIST /v`)
8. **Registry Run keys** (`reg export HKLM\…\Run`)
9. **Event logs** (`wevtutil epl Security E:\…`)
10. **DNS cache** (`ipconfig /displaydns`)

## Phase 5 — Network cable decision

| Condition | Action |
|---|---|
| Active VoIP/IM session (Telegram, WhatsApp Web, SIP call) | Keep cable in until RAM captured and session token extracted. Then pull, photograph. |
| Suspect attempting to wipe | Pull cable now. RAM loses data but disk image is safer. |
| Server with active DB writes | Mirror the port to your laptop, then pull. Use a network tap. |
| Router | Photograph, then console-cable, then bag whole. |
| Phone (Faraday bag) | Once bagged, no further network action. |

## Phase 6 — Power-off methodology

- **Workstation, no encryption:** shut down via Start menu (clean flush).
- **Workstation with suspected encryption (BitLocker, VeraCrypt, FileVault):** **do not** shut down. RAM contains the keys. Capture RAM first. Then either hot-swap the disk or hibernate.
- **Server:** controlled shutdown via Start → Shutdown. Never pull the plug. `mysqldump --all-databases > evidence_<ts>.sql` first, then shut down.
- **Last resort, encryption suspected and you cannot capture RAM:** 4-second hold on the power button. The risk is losing keys; the alternative is the suspect's lawyer arguing you destroyed evidence.

## Phase 7 — Packaging and transport

1. Each device in its own anti-static bag.
2. HDD removed from PC, in a separate bag.
3. Tamper-evident seal across the bag opening, signed by IO and witness.
4. Server: full PC in a large bag, anti-static, marked "FRAGILE / THIS SIDE UP".
5. Phones in Faraday pouches, then in evidence bags.
6. Cool, dry transport. No direct sunlight. No magnets.
7. Hand over to CCL with signed chain-of-custody form, hash verification sheet, imaging log.

## Phase 8 — Documentation standard (case diary entry)

```
Date  : 18-Apr-2026
Time  : 11:32 to 12:45 hrs IST
Place : 301, Kuber Complex, Andheri W, Mumbai 58
Team  : Insp. R. K. Singh (4421) lead, SI P. Nair (3398),
        SI V. Desai (3401), 4 constables, FSL Expert A (5188)
Items : 20 items seized, MSL-2026-001 to MSL-2026-020
Photos: IMG_4001-IMG_4455 (454 photos)
Notes : Detailed contemporaneous notebook entries per phase
Warrant: W/2026/AC-145 (Sec 165 CrPC)
```

## Phase 9 — Chain-of-custody transfer

Every handoff is signed by both parties, dated, timed, photographed at the moment of transfer, with the hash re-verified.

## Phase 10 — Live-server seizure (CRM-SERVER style)

1. Do not pull the plug.
2. Photograph the screen and Disk Management.
3. Open a `cmd` as Administrator.
4. `mysqldump --all-databases --single-transaction --routines --triggers > E:\EVIDENCE\dump_<ts>.sql`
5. `mysql -u root -e "SHOW PROCESSLIST\G" > E:\EVIDENCE\processlist_<ts>.txt`
6. `mysql -u root -e "SHOW SLAVE STATUS\G" > E:\EVIDENCE\slave_<ts>.txt`
7. Screenshot Windows Computer Management → Services.
8. Screenshot Disk Management (volumes, hidden partitions).
9. RAM capture (15-30 min on a server).
10. Pull network cable **after** RAM is done.
11. Shut down via Start → Shutdown (not pull plug).
12. Image 4 disks in sequence (8+ hours).

## Phase 11 — Mobile device seizure (phone checklist)

1. Photograph phone ON, screen unlocked if possible.
2. Note model, IMEI, SIM ICCID, phone number.
3. **Enable airplane mode** (do NOT swipe to power off — that may trigger wipe).
4. Place in Faraday pouch, seal.
5. If phone is unlocked: do NOT scroll through apps (changes RAM, may trigger wipe).
6. Note battery %, last charge time.
7. If Android: photograph lock-screen type.
8. Bag charger, SIM ejector, original box.
9. Hand to Cellebrite UFED operator within 4 hours.

## Phase 12 — Common rookie mistakes

1. ❌ Pulling the plug to "stop the suspect from destroying data" — destroys RAM, may corrupt FS, loses any open encryption keys.
2. ❌ Closing a VeraCrypt/BitLocker window "to make the desktop clean" — dismounts the volume.
3. ❌ Letting the suspect "show you what's on their phone" — touches evidence, may trigger wipe.
4. ❌ Seizing the laptop whole instead of imaging the disk — analysis must happen on a copy, not the original.
5. ❌ Hashing only after the bag is sealed — must hash at the moment of acquisition.
6. ❌ Using the suspect's USB stick to transfer evidence to your laptop — that USB is evidence, you are contaminating it.
7. ❌ Discussing findings in front of the suspects.
8. ❌ Skipping the Sec 91 to the bank "for now" — by the time you send it, the money is gone.
