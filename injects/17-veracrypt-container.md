# Inject 17 — VeraCrypt Container

**Time:** 13:04 IST
**Where:** MANAGER-PC
**Card:** "Forensic expert: MANAGER-PC has an E: drive that isn't a normal partition. The drive label is 'VAULT'."

## Response
1. **Do not close the volume** — dismounting loses the mount and you have to re-enter the password.
2. Image the live volume header (first 512 bytes of `D:\Manager\vault.veracrypt`).
3. The password may be on a sticky note under the keyboard, in the manager's password manager, or guessable.
4. Mount the parent image in FTK Imager and read the volume header.
5. Use the same password if known, else use the header to brute-force (VeraCrypt supports header-only recovery).

## Find
- Container opens with `Gr@Vault2026!` (on a sticky note under the keyboard).
- Inside:
  - `mule_rota_history.xlsx` — the history of all 6 mule accounts and their rotation.
  - `victims_to_burn.xlsx` — the list of 3 victims who complained (stall them).
  - `private_keys.txt` — TRC20 USDT wallet key (synthetic).
  - `confession_2026-04-17.mp3` — a 6-minute audio confession.

## Mistake
❌ Dismounting the volume by mistake (typing `dismount` in VeraCrypt or restarting the PC). The header still allows mount of the E01.

## Grading
- ✅ Do not close, image the live header
- 🟡 Close the volume (loses mount)
- ❌ Dismount via VeraCrypt
