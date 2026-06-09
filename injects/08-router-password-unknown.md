# Inject 08 — Router Password Unknown

**Time:** 12:26 IST
**Where:** Router at 192.168.10.1
**Card:** "Router web UI asks for password, default admin/admin doesn't work."

## Response
1. **Do not brute-force the web UI** — locks the account.
2. Use the **console cable** (RJ45-to-USB, 9600 8N1) into the router.
3. `enable` (no password on TP-Link WR940N by default).
4. `copy running-config tftp://<laptop-ip>/router_<case>.cfg`.
5. Hash the saved config.
6. Photograph the console session before disconnecting.
7. Bag the router whole.

## Find
- Running config reveals the **port-forward rule** for RDP to CRM-SERVER (3389) and the **static DHCP reservation** for AGENT-05.
- The DNS resolver cache (frozen at 17-Apr 02:00) shows `t.me` and `relay.anydesk.com` lookups.

## Mistake
❌ Trying to brute-force the web UI.

## Grading
- ✅ Console cable + TFTP
- 🟡 Try default password only
- ❌ Brute-force the web UI
