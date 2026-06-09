# Inject 05 — Deleted Database Recovered

**Time:** 12:14 IST
**Where:** Anywhere
**Card to read aloud:**

> "Constable: 'Sir, the manager says the CRM database was deleted last night. He says all the customer data is gone.'"

## What the trainee team should do
1. **Do not believe the manager.** Verify on the live server.
2. Connect to the CRM-SERVER (via KVM / iLO / iDRAC, or directly).
3. Run `mysqldump --all-databases` FIRST to capture the live DB.
4. Open File Explorer on the server. Check `D:\Backups\old\` for the hidden share.
5. Open the manager's Recycle Bin.
6. Image the CRM-SERVER as usual.

## What they should find
- The "deleted" database is **intact and running** on the CRM-SERVER.
- A **backup from yesterday** is on the `old` share: `golden_crm_backup_2026-04-15.sql` — the manager's "hidden" share that wasn't actually hidden (no `$` suffix).
- The manager's Recycle Bin contains `complaints_to_ignore.xlsx` (deleted because "they didn't need it anymore").

## Common mistake
❌ Believing the manager. MySQL data files persist even after "deletion" attempts.

## Grading
- ✅ (5) Run mysqldump first, check Recycle Bin, find backup share
- 🟡 (3) Check Recycle Bin only
- ❌ (0) Believe the manager
