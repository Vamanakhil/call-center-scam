# Inject 02 — AnyDesk Session Active

**Time:** 11:42 IST
**Where:** AGENT-01 system tray
**Card to read aloud:**

> "Constable reports: AGENT-01's system tray shows an AnyDesk icon with status 'Connected to 103.41.218.91'."

## What the trainee team should do
1. Photograph the AnyDesk window with the **AnyDesk ID** visible.
2. **DO NOT** disconnect yet — preserve the session.
3. Run `wevtutil qe Security` to find recent 4624 / 4648 events.
4. Use the system-tray menu to **gracefully disconnect** (so the AnyDesk log records it).
5. Screenshot the disconnection prompt.
6. Document the AnyDesk ID for the MLAT request to AnyDesk (AnyDesk Singapore Pte Ltd).

## What they should find
- AnyDesk ID: `823 411 902` connected from `103.41.218.91` (Singapore AnyDesk relay).
- The same AnyDesk ID appears in MANAGER-PC's `AppData\Roaming\AnyDesk\ad_sessions.log`.
- The CRM-SERVER's `qwinsta` shows session 5 from `103.41.218.91:49522`.

## Common mistake
❌ Right-click → "Disconnect" without preserving the ID. The session token is needed for the MLAT request.

## Grading
- ✅ (5) Photograph ID, do not disconnect, capture token first
- 🟡 (3) Disconnect without preserving
- ❌ (0) Right-click Disconnect and lose ID
