# 22 — Tool: NirSoft Forensic Suite

NirSoft's `nirsoft.net` is the **workhorse** of live-system triage. Each utility reads a single Windows artifact and exports to CSV. All are **free, portable, single-EXE**.

## The 12 utilities every cyber cell officer should know

| Utility | Reads | Used for |
|---|---|---|
| **BrowserHistoryView** | IE/Edge/Chrome/Firefox/Safari history | Last 100 URLs per browser, all users |
| **USBDeview** | `USBSTOR` registry | Every USB ever plugged in, with VID/PID/serial/timestamp |
| **RecentFilesView** | `RecentDocs` registry | Last 100 files opened per user |
| **LastActivityView** | `UserAssist`, prefetch, scheduled tasks, run history | Combined activity timeline |
| **WinLogOnView** | Security logon events | Logon/logoff times per user |
| **NetworkConnectivityView** | `NetBIOS`, `SMB` | Mapped drives, shares used |
| **WirelessNetworkWatcher** | `WZCSVC` | All Wi-Fi networks joined + last password (in some Windows versions) |
| **ProduKey** | Registry | Windows + Office product keys |
| **MailPassView** | Registry | Email account passwords (POP3/IMAP/SMTP) |
| **WebBrowserPassView** | `Login Data` SQLite | Saved browser passwords (Chrome decrypts with DPAPI) |
| **RegistryChangesView** | registry snapshots | Diff two snapshots — see what changed |
| **TurnedOnTimesView** | Event log 6005/6008/6009 | Power-on / power-off times |

## Pre-flight
- Copy all `.exe` files to a folder on a write-blocked USB.
- Some utilities need **Administrator** to read other users' hives.

## Step-by-step — BrowserHistoryView

1. Run `BrowserHistoryView.exe` as Administrator.
2. It auto-detects all browsers' `History` SQLite files in `C:\Users\<user>\AppData\Local\`.
3. The table shows: URL, Title, Visit Time, Visit Count, Browser, User Profile.
4. **Options → Advanced Options →** tick "Load history from external folder" to point to a mounted E01.
5. **View → HTML Report** → save to the case folder.

## Step-by-step — USBDeview

1. Run `USBDeview.exe` as Administrator.
2. The table shows: Device Name, Description, Device Type, Connected, Disconnected, Vendor ID, Product ID, Serial Number.
3. **Sort** by "Connected" descending to see recent devices.
4. **Right-click → Properties** to see the registry key and the `FriendlyName`.
5. **File → Save Selected Items** → CSV. Hash the CSV.

## Step-by-step — WebBrowserPassView

1. Run `WebBrowserPassView.exe` as Administrator.
2. The table shows: URL, User, Password, Browser.
3. **Important:** Chrome encrypts with DPAPI. WebBrowserPassView decrypts using the **current user's** DPAPI key. If you run on another user's profile, you get blanks.
4. To extract Chrome passwords from another user, copy their `Login Data` and `Local State` to your examiner workstation, then point WebBrowserPassView at them (advanced).

## Common mistakes
- ❌ Running without Administrator on a system with multiple users — you only see your own profile.
- ❌ Failing to **export** the data. The tool shows on screen, but you must save to CSV for the case file.
- ❌ Trusting the "Connected" timestamp — Windows reports the *first* connection. Use the Event Log for the most recent activity.

## Court admissibility
- NirSoft utilities are **forensic-grade**. Used by FBI, Interpol, and Indian State Police.
- Always include the **exported CSV** + the **utility's version** + a **hash** of the CSV in the case file.
- Some defence lawyers challenge DPAPI-derived passwords. Best practice: pair with **OSForensics** or **Elcomsoft** to corroborate.
