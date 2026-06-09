# Inject 09 — Printer Jam

**Time:** 12:30 IST
**Where:** HP M404n printer
**Card:** "Sir, the printer has a paper jam. Paper tray has a half-printed `Mule_Accounts_Q4.pdf`."

## Response
1. **Photograph the LCD** showing the last job name.
2. **Photograph the paper in the tray in situ** before touching.
3. Do NOT clear the jam "to make the printer work".
4. Pull the **internal flash** (most office printers have an SD or DOM).
5. Image the internal flash with FTK Imager (DD).
6. Collect the paper in a tamper-evident bag.

## Find
- Internal flash contains the **last 32 print jobs**.
- The half-printed `Mule_Accounts_Q4.pdf` shows 6 mule account numbers in plaintext.
- The print job log shows the document was printed by `arjun.m`.

## Mistake
❌ Clearing the jam — destroys the in-tray document.

## Grading
- ✅ Photograph LCD + paper, pull internal flash, image
- 🟡 Photograph LCD only
- ❌ Clear the jam
