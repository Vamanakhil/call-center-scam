# 14 — Debrief Guide

> How to run the post-lab debrief — typically 60-90 minutes.

## 1. Structure (90 min)

| Time | Activity |
|---|---|
| 0-10 | Round-robin: "one thing you learned, one thing that surprised you" |
| 10-25 | Walk through the SOP. What did you miss? What would you do differently? |
| 25-50 | Inject-by-inject review. Compare team actions to expected responses. |
| 50-75 | Cross-system correlation walkthrough. Reveal the answer key. |
| 75-85 | Discussion questions (see §3). |
| 85-90 | Wrap-up, hand out certificates, collect feedback forms. |

## 2. Talking points for each phase

### Phase 0 — Pre-raid
- The warrant is **not optional**. The defence will challenge every seizure that lacks one.
- Discuss Sec 165 CrPC (search without warrant in urgent cases) vs Sec 91 CrPC (production of documents).

### Phase 1 — Approach
- The first 10 seconds are the most important. After 30 seconds, suspects start destroying evidence.
- "Hands up" in the local language.

### Phase 2 — Scene stab
- **Photograph before you touch.** Every photo you don't take is one the defence will ask for.
- "Screen time vs. watch time" — if the screen shows 11:35 and your watch is 11:42, the suspect has been changing the clock.

### Phase 3 — Triage
- The decision tree exists for a reason. Most rookies go straight to "pull the plug". That loses RAM, may corrupt the FS, and loses any open encryption keys.

### Phase 4 — Volatile order
- RAM first. Processes second. Network third. Logs fourth. Order matters.
- `ipconfig /displaydns` is gold — shows every domain visited, including deleted history.

### Phase 5 — Network cable
- Trade-off: leaving in (preserves session) vs pulling (preserves disk).

### Phase 6 — Power-off
- For suspected-encryption workstations, **never** shut down until RAM is captured.
- For servers, **always** `mysqldump` first, then shut down.

### Phase 7 — Packaging
- Each device in its own bag. HDD separate from motherboard.
- Faraday for phones, even if you think the suspect didn't use the phone.

### Phase 8 — Documentation
- Contemporaneous notes are the **only** defence against "the officer added this line later".
- Who, what, when, where, why, how. Witness countersignature.

### Phase 9 — Chain of custody
- Every transfer is a risk. Minimise the number of transfers.
- Hashes checked at every transfer.

### Phase 10 — Live server
- Most common rookie mistake: **pulling the server plug**. Always controlled shutdown.
- `mysqldump` first. Always.

### Phase 11 — Mobile
- Airplane mode first, **then** Faraday bag.

## 3. Discussion questions (pick 5)

1. **"What would you do if the manager threw a hard drive out the window when he saw you?"**
   - Answer: photograph the trajectory, retrieve the drive, image it. Don't chase the suspect.
2. **"The manager's lawyer says the `closer_script.docx` is a 'sales training manual'. How do you counter that?"**
   - Answer: point to the §"When the victim says 'I will call SEBI'" passage. Also cross-reference to actual UPI transactions matching the script.
3. **"How do you prove the AnyDesk session was the manager, not a hacker?"**
   - Answer: the manager's AnyDesk log shows his username, his machine's GUID, and the same AnyDesk ID. Plus the suspect's DNA on the keyboard.
4. **"The mule bank says it can't give you the account statement without a court order. You have a Sec 91. What do you do?"**
   - Answer: the Sec 91 is the production notice. If they don't comply, file a contempt petition before the magistrate. Or send the Sec 91 to RBI's banking ombudsman.
5. **"You find a Telegram session in the deleted `tdata` folder but most files are zeroed out. Can you still use it?"**
   - Answer: yes. The folder structure reveals the user ID, the chat list may have metadata, and the SQLite cache may have rows. Even partial recovery is useful.
6. **"Vikas says the `updater.exe` is a 'Windows update' he downloaded. How do you disprove that?"**
   - Answer: it lives in `C:\ProgramData\Updater\` (not a Windows path). The file version is 0.0.0.0. The publisher is unsigned. The `stub.ps1` source is in his Documents.
7. **"You image a workstation and the verify step fails. What do you do?"**
   - Answer: re-image. Never use an unverified image. Document the failure in the chain of custody.
8. **"The defence asks for the raw RAM dump, not just your extracted strings. What do you do?"**
   - Answer: hand it over. The hash proves you didn't tamper with it. Discovery is mandatory under BNSS.
9. **"You forgot to photograph the back of the AGENT-01 PC. Now what?"**
   - Answer: you can still image the disk. The serial number is in the BIOS, in the E01's registry, and on the asset tag. Document the oversight in the case diary.
10. **"How do you decide which of the 487 victims to call as a witness?"**
    - Answer: pick the most articulate, the most cooperative, the most damaged (largest loss), and the one with the most documentary evidence. Aim for 5-10.

## 4. Real-world case parallels

Briefly mention these real Indian cases for context:

- **Mango Telecom fraud (2024)** — same pattern, 800+ victims, 11 crores.
- **HP trading scam (2023)** — same pattern, 1200+ victims, 18 crores.
- **CoinDCX phishing (2024)** — Telegram-based, 40 crores.
- **Punjab National Bank digital arrest (2024)** — AnyDesk-based, 23 crores.

## 5. The "one thing" round

End with: "If you could do **one** thing differently in your next real raid, what would it be?"

Collect the answers. Use them to improve the next iteration of the lab.

## 6. Feedback form

Hand each trainee a 1-page form (in `printables/`):
- What was most useful?
- What was least useful?
- What was missing?
- Pace: too fast / too slow / just right?
- Tool preferences?
- Comments for the instructor.
