# Inject 04 — Hidden USB Found

**Time:** 12:08 IST
**Where:** Vikas's shelf
**Card to read aloud:**

> "Constable finds a hollowed-out 'Hacking Exposed 7th Ed.' book on Vikas's shelf. Inside is a 64 GB SanDisk pen drive."

## What the trainee team should do
1. **Photograph the book in situ** (don't open it yet).
2. Photograph the book open with the cavity visible.
3. Photograph the pen drive inside the cavity.
4. Carefully remove the pen drive. Place in a tamper-evident bag.
5. Image with **FTK Imager** + **write-blocker**.
6. Open the image read-only with Autopsy or FTK Imager.

## What they should find
- The pen drive contains:
  - `victims_old.xlsx` (deleted 3 weeks ago) — recoverable.
  - An empty partition table.
  - A Windows shortcut `.lnk` to the CRM admin panel.
  - Several old `victims_master_*.csv` files from previous months.

## Common mistake
❌ Pulling the USB out before photographing it in situ. Or plugging it into a non-forensic machine to "see what's on it".

## Grading
- ✅ (5) Photograph in situ, image via write-blocker
- 🟡 (3) Pull USB, then photograph
- ❌ (0) Plug into non-forensic machine
