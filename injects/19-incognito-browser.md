# Inject 19 — Incognito Browser

**Time:** 13:12 IST
**Where:** AGENT-01
**Card:** "Rahul says: 'I was just browsing in incognito, nothing to see.'"

## Response
1. Incognito ≠ invisible.
2. The URLs are still in the `chrome.exe` process memory.
3. `strings -e l AGENT-01.mem | grep -E "https?://" | sort -u` recovers them.
4. Also check the `chrome.exe` process's mapped file handles.
5. Examine the `History` SQLite file (Chrome keeps it in incognito too until the window closes — if the window is still open, it's a separate file but recoverable from RAM).

## Find
- 47 incognito URLs recovered, all to `t.me` and `goldenreturns.example/admin`.
- One URL: `t.me/gr_dispatch_internal/1234` — the private Telegram C2 channel for the team.

## Mistake
❌ Believing the suspect.

## Grading
- ✅ strings on the .mem, recover incognito URLs
- 🟡 Believe the suspect
- ❌ Do nothing
