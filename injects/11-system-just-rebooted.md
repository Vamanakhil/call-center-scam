# Inject 11 — System Just Rebooted

**Time:** 12:40 IST
**Where:** AGENT-04
**Card:** "AGENT-04's screen is on the lock screen. Sneha says 'I just rebooted it.'"

## Response
1. `wevtutil qe System` — look for event **1074** (clean shutdown by user) or **6008** (unexpected).
2. Check the USN journal for the last `$J` time.
3. Check `USBSTOR` for any USB plugged in 30 seconds before the shutdown.

## Find
- Event 1074 at 12:38 — initiated by user `sneha.i` (she shut it down, not the OS).
- USN journal shows a `passwords.txt` was written to a USB at 12:38:30 (the malware stub).
- `USBSTOR` shows a new SanDisk 32 GB was plugged in at 12:38:15.

## Mistake
❌ Believing the user.

## Grading
- ✅ Check event log 1074/6008 + USN journal
- 🟡 Event log only
- ❌ Believe the user
