# 12 — Instructor Guide

> This is a complete "how to run the lab" manual for the trainer.

## 1. Pre-lab setup (T-7 days)

1. Read this entire lab (all docs in `docs/`).
2. Verify the lab room has:
   - 7 × Windows 10/11 VMs (one per workstation + manager + server) OR
   - 7 × physical Windows machines
   - 1 × network switch + 1 × router (or virtual equivalents)
   - 1 × printer (or print-spooler VM share)
   - 1 × Faraday bag + 3 × mock phones (locked screen)
   - 4 × USB pen drives (one hidden in a book)
   - Tamper-evident bags, evidence tape, numbered seals
   - DSLR camera, spare battery
   - Whiteboard for class
3. Prepare **roles cards** — print and hand each trainee a card with their role (IO, scribe, photographer, etc.).
4. Print the forms from `printables/`.
5. Install tools on the instructor laptop: FTK Imager, Autopsy, NirSoft suite, Registry Explorer, Belkasoft, HashCalc, Wireshark.
6. Pre-populate the lab machines by running the PowerShell scripts (`-Role ALL` on one machine, or per-role on the 7 machines). Allow 30-60 min.

## 2. Day-of-lab schedule

| Time | Activity |
|---|---|
| 09:00 - 09:30 | Welcome, briefing, handout forms |
| 09:30 - 10:00 | Pre-raid checklist — tools, warrants, team |
| 10:00 - 10:15 | Drive to "scene" (or move to lab room) |
| 10:15 - 11:00 | Phase 1-4 — approach, scene stab, RAM, volatile |
| 11:00 - 12:00 | Phase 5-7 — image, hash, package, transport |
| 12:00 - 13:00 | Lunch break |
| 13:00 - 14:00 | Worksheets 1-3 (RAM, processes, network) |
| 14:00 - 15:00 | Worksheets 4-7 (browser, email, USB, deleted) |
| 15:00 - 16:00 | Worksheets 8-10 (hashing, imaging, verification) |
| 16:00 - 16:30 | Cross-system correlation task |
| 16:30 - 17:00 | Inject event wrap-up + initial debrief |
| 17:00 - 18:00 | PIR compilation |
| 18:00 - 19:00 | Debrief (full) — answer key, mistakes, discussion |

## 3. Role assignments

For a class of 4-6 trainees:

| Role | Who | Responsibilities |
|---|---|---|
| **Lead IO (Insp.)** | 1 trainee | Overall command, signs all forms, calls injects |
| **Forensic Expert** | 1 trainee | Runs RAM, imaging, hashing |
| **Network Officer** | 1 trainee | Captures live traffic, screenshots connections |
| **Evidence Officer** | 1 trainee | Bags, tags, photographs, chains |
| **Scribe** | 1 trainee | Contemporaneous notes, fills forms |
| **Photographer** | 1 trainee | All photos, video if needed |
| **Witness** | (1 non-trainee) | Independent — e.g., a constable or a magistrate |

Rotate roles every 2 hours for fairness.

## 4. The 20 injects — when and how to call them

Injects are timed to force decisions at peak stress. Use the table in `docs/10-INJECT-EVENTS.md`.

For each inject:
- Read the **Trigger** to the team.
- Stop. Wait. Let them discuss.
- Observe. Grade the decision against **Expected response**.
- Read the **What they should find** AFTER the team takes action.
- Discuss the **Common mistake** in the debrief.

If the team freezes for > 60 seconds, give a hint from the Expected response. Don't give the answer.

## 5. Common mistakes to watch for

| Mistake | Inject | Coaching hint |
|---|---|---|
| Yanking the power cable | 1 | "What about the RAM?" |
| Closing VeraCrypt window | 17 | "Is the manager's E: drive a real partition?" |
| Letting suspect "show you" the phone | 7 | "What does that do to the RAM?" |
| Imaging the original without a write-blocker | 9 | "Are you sure the source drive is read-only?" |
| Hashing only after bagging | 3 | "Could the file have changed since the alert?" |
| Skipping the Sec 91 to the bank | (debrief) | "By the time we have warrants, the money is in 11 countries." |
| Using a single USB stick for evidence transfer | 12 | "Cross-contamination, your honour will love this." |

## 6. Grading rubric

Each trainee is graded on:

- **Procedure adherence (40%)** — did they follow the SOP?
- **Tool usage (30%)** — did they pick the right tool for the right job?
- **Decision making (20%)** — did they handle the injects correctly?
- **Documentation (10%)** — are the forms filled correctly?

A "pass" is 70%. A "distinction" is 90%.

## 7. Variations for repeat trainings

- **Variant A:** Different scam — crypto-rug-pull or loan-app extortion.
- **Variant B:** Different team size — solo trainee for a sub-inspector.
- **Variant C:** Different platform — add a Linux server and a macOS workstation.
- **Variant D:** Time-pressured — give them only 30 minutes total on scene.
- **Variant E:** Defence-counsel role — one trainee plays the defence, one plays the IO.

## 8. What to do if a trainee does exceptionally well

Promote them to a **senior trainee** role for the next iteration. Have them lead a small team.

## 9. What to do if a trainee does poorly

- Walk them through the SOP one-on-one.
- Have them do the worksheets solo, with the answer key.
- Pair them with a stronger trainee next time.
- Don't shame them. The goal is learning.

## 10. Common "real-world" overlay

For senior officers, add:
- "Now write the Section 91 to HDFC for the mule account."
- "Now write the Section 69 IT Act interception order for the AnyDesk relay."
- "Now draft the press release for the FIR."
- "Now write the witness statement for the building watchman."

These are not in the lab but are part of the IO's job.
