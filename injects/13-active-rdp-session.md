# Inject 13 — Active RDP Session

**Time:** 12:48 IST
**Where:** CRM-SERVER `qwinsta`
**Card:** "Constable: 'Sir, qwinsta on the server shows 2 active sessions. One is rdp-tcp#5 user arjun.m. The other is rdp-tcp#6 user Administrator from 103.41.218.91.'"

## Response
1. Photograph both sessions.
2. **Disconnect gracefully** via `rwinsta 6` (the AnyDesk session).
3. Keep session 5 (arjun.m) — it's the manager's own session from MANAGER-PC, useful evidence.
4. Preserve the source IP for the MLAT request to AnyDesk.

## Find
- Session 5: `arjun.m` from 192.168.10.50 (manager's own PC, useful).
- Session 6: `Administrator` from 103.41.218.91:49522 (the AnyDesk relay, Singapore).
- Security log shows 47 failed 4625 events for Administrator in 4 minutes (23:14-23:18) — classic brute-force.

## Mistake
❌ Killing rdp-tcp#5 (the manager's own session).

## Grading
- ✅ rwinsta 6, photograph, preserve for MLAT
- 🟡 rwinsta all sessions
- ❌ Kill the manager's session
