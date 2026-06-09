# Inject 01 — Suspect Shutdown Attempt

**Time:** 11:36 IST (4 min after entry)
**Where:** Manager's chair
**Card to read aloud:**

> "Manager Arjun lunges for the AGENT-05 power button, shouting 'Koi nahi chhuega' (No one will touch this)."

## What the trainee team should do
1. **Sub-inspector** grabs the manager's wrist, moves him away from any keyboard.
2. **Constable** stations at every workstation — no one touches a keyboard.
3. **Forensic expert** photographs the screen of every workstation before any power action.
4. The IO confirms the **VeraCrypt volume on MANAGER-PC is still mounted as E:** — DO NOT close it.
5. The manager is moved to a corner, hands visible, separate from the other suspects.

## What they should find
- The VeraCrypt volume is open. Closing it would lose the mount and require the password (`Gr@Vault2026!`) to re-open.
- The manager's screen shows Telegram open, an Excel spreadsheet (likely `victims_master.xlsx`), and a folder window with 6 mule bank account PDFs.

## Common mistake
❌ Yanking the power cable on AGENT-05 — that would lose RAM and possibly corrupt the VeraCrypt mount on MANAGER-PC.

## Grading
- ✅ (5) Subdue suspect, photograph every screen, NO power action
- 🟡 (3) Photograph some screens, then power off
- ❌ (0) Yank power cable
